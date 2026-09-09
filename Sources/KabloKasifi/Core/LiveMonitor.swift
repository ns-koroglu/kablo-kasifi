import Foundation
import AppKit
import IOKit
import IOKit.ps

/// Güç, USB ve ekran değişimlerini IOKit/AppKit bildirimleriyle **anında** yakalar.
///
/// Önceki tasarımda yalnızca panel açıkken 4 saniyede bir tam tarama yapılıyordu:
/// menü çubuğundaki watt değeri panel kapalıyken hiç güncellenmiyor, açıkken de
/// 4 saniyeye kadar gecikiyordu; üstelik her tarama iki `system_profiler` alt süreci
/// açıyordu (ölçüldü: ~250 ms). Artık yoklama yok, olay var:
///   • güç kaynağı değişimi → IOPSNotificationCreateRunLoopSource
///   • USB tak/çıkar        → IOServiceAddMatchingNotification (matched + terminated)
///   • ekran değişimi       → NSApplication.didChangeScreenParametersNotification
final class LiveMonitor {

    enum Trigger { case power, usb, display }

    /// Değişiklik olduğunda ana kuyrukta çağrılır.
    private let onChange: (Trigger) -> Void

    private var powerSource: CFRunLoopSource?
    private var notifyPort: IONotificationPortRef?
    private var addedIterator: io_iterator_t = 0
    private var removedIterator: io_iterator_t = 0
    private var screenObserver: NSObjectProtocol?
    private var running = false

    init(onChange: @escaping (Trigger) -> Void) {
        self.onChange = onChange
    }

    deinit { stop() }

    func start() {
        guard !running else { return }
        running = true
        startPowerNotifications()
        startUSBNotifications()
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.onChange(.display)
        }
    }

    func stop() {
        guard running else { return }
        running = false

        if let powerSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), powerSource, .defaultMode)
        }
        powerSource = nil

        if addedIterator != 0 { IOObjectRelease(addedIterator); addedIterator = 0 }
        if removedIterator != 0 { IOObjectRelease(removedIterator); removedIterator = 0 }
        if let notifyPort { IONotificationPortDestroy(notifyPort) }
        notifyPort = nil

        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
        screenObserver = nil
    }

    // MARK: - Güç kaynağı

    private func startPowerNotifications() {
        let context = Unmanaged.passUnretained(self).toOpaque()
        let callback: IOPowerSourceCallbackType = { context in
            guard let context else { return }
            Unmanaged<LiveMonitor>.fromOpaque(context).takeUnretainedValue().onChange(.power)
        }
        guard let source = IOPSNotificationCreateRunLoopSource(callback, context)?.takeRetainedValue() else { return }
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
        powerSource = source
    }

    // MARK: - USB tak/çıkar

    private func startUSBNotifications() {
        guard let port = IONotificationPortCreate(kIOMainPortDefault) else { return }
        notifyPort = port
        IONotificationPortSetDispatchQueue(port, .main)

        let context = Unmanaged.passUnretained(self).toOpaque()
        let callback: IOServiceMatchingCallback = { context, iterator in
            // Yineleyiciyi boşaltmak zorunlu; aksi hâlde bildirim yeniden silahlanmaz.
            while case let service = IOIteratorNext(iterator), service != 0 {
                IOObjectRelease(service)
            }
            guard let context else { return }
            Unmanaged<LiveMonitor>.fromOpaque(context).takeUnretainedValue().onChange(.usb)
        }

        register(port: port, type: kIOMatchedNotification, callback: callback,
                 context: context, iterator: &addedIterator)
        register(port: port, type: kIOTerminatedNotification, callback: callback,
                 context: context, iterator: &removedIterator)
    }

    private func register(port: IONotificationPortRef,
                          type: String,
                          callback: @escaping IOServiceMatchingCallback,
                          context: UnsafeMutableRawPointer,
                          iterator: inout io_iterator_t) {
        let matching = IOServiceMatching("IOUSBHostDevice")
        guard IOServiceAddMatchingNotification(port, type, matching, callback, context, &iterator) == KERN_SUCCESS
        else { return }
        // İlk çağrıda mevcut aygıtlar sırada bekler; boşaltmadan bildirim başlamaz.
        while case let service = IOIteratorNext(iterator), service != 0 {
            IOObjectRelease(service)
        }
    }
}
