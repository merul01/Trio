import SwiftUI
import AppKit

/// NSView wrapper that reports:
/// - continuous max mapped pressure (0.0, 0.6, 0.9) during a click
/// - a single (maxPressure, normalizedSpot) value when the click ends
///
/// 0.0  → "Soft" (idle / no click)
/// 0.6  → "Medium" (normal click)
/// 0.9  → "Firm" (hard press)
struct PressureCaptureView: NSViewRepresentable {

    /// Called continuously with the current *max-so-far* mapped pressure for this click.
    var onPressureChanged: (Double) -> Void

    /// Called once on mouseUp with (maxPressure, normalizedSpot),
    /// where normalizedSpot is 0...1 for both x and y.
    var onClickEnded: ((Double, CGPoint) -> Void)?

    final class PressureNSView: NSView {
        var onPressureChanged: ((Double) -> Void)?
        var onClickEnded: ((Double, CGPoint) -> Void)?

        private var maxThisClick: Double = 0.0
        private var lastPointInView: CGPoint = .zero
        private var isClicking: Bool = false

        /// Hard presses should only be "Firm" if pressure exceeds this threshold.
        /// We set it quite high so normal clicks stay Medium.
        private let firmThreshold: Double = 0.9

        override func mouseDown(with event: NSEvent) {
            isClicking = true
            maxThisClick = 0.0
            updatePoint(with: event)

            // First click → default to "Medium"
            let mapped = PressureLevel.medium.representativeValue
            maxThisClick = mapped
            onPressureChanged?(maxThisClick)
        }

        override func pressureChange(with event: NSEvent) {
            guard isClicking else { return }
            updatePoint(with: event)
            updatePressure(with: event)
        }

        override func mouseDragged(with event: NSEvent) {
            guard isClicking else { return }
            updatePoint(with: event)
            updatePressure(with: event)
        }

        override func mouseUp(with event: NSEvent) {
            updatePoint(with: event)
            updatePressure(with: event)

            if !isClicking {
                // No real click; treat as idle.
                maxThisClick = 0.0
            }

            let norm = normalizedPoint(lastPointInView)
            onClickEnded?(maxThisClick, norm)

            isClicking = false
        }

        private func updatePoint(with event: NSEvent) {
            lastPointInView = convert(event.locationInWindow, from: nil)
        }

        private func updatePressure(with event: NSEvent) {
            guard isClicking else { return }

            // Raw pressure 0...1
            let raw = Double(event.pressure)

            var mapped = PressureLevel.medium.representativeValue
            if raw >= firmThreshold {
                mapped = PressureLevel.firm.representativeValue
            }

            maxThisClick = max(maxThisClick, mapped)
            onPressureChanged?(maxThisClick)
        }

        private func normalizedPoint(_ p: CGPoint) -> CGPoint {
            let w = max(bounds.width, 1)
            let h = max(bounds.height, 1)
            let x = min(max(p.x / w, 0.0), 1.0)
            let y = min(max(p.y / h, 0.0), 1.0)
            return CGPoint(x: x, y: y)
        }
    }

    func makeNSView(context: Context) -> PressureNSView {
        let view = PressureNSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.layer?.backgroundColor = NSColor.clear.cgColor
        view.onPressureChanged = onPressureChanged
        view.onClickEnded = onClickEnded
        return view
    }

    func updateNSView(_ nsView: PressureNSView, context: Context) {
        nsView.onPressureChanged = onPressureChanged
        nsView.onClickEnded = onClickEnded
    }
}
