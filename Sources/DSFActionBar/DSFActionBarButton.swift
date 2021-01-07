//
//  DSFActionBarButton.swift
//  testing ui stuff big sur
//
//  Created by Darren Ford on 7/1/21.
//

#if os(macOS)

import AppKit

@IBDesignable
class DSFActionBarButton: NSButton {

	// MARK: - Init and setup

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	private func setup() {
		self.wantsLayer = true
	}

	override open var wantsUpdateLayer: Bool {
		return true
	}

	private lazy var buttonLayer: CALayer = {
		return self.layer!
	}()

	// MARK: - Cleanup

	deinit {
		if let t = self.trackingArea {
			self.removeTrackingArea(t)
			self.trackingArea = nil
		}
	}

	// MARK: - Sizing

	override var intrinsicContentSize: NSSize {
		var sz = super.intrinsicContentSize
		sz.width -= 4
		//sz.height += 2
		return sz
	}


	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		self.updateMenuStatus()
	}

	func updateMenuStatus() {
		if let _ = self.menu {
			self.image = Self.menuImage
			self.imageScaling = .scaleNone
			self.imagePosition = .imageRight
		}
		else {
			self.image = nil
			self.imageScaling = .scaleNone
			self.imagePosition = .imageRight
		}
	}

	override open func drawFocusRingMask() {
		let r = NSBezierPath(roundedRect: self.bounds, xRadius: 4, yRadius: 4)
		r.fill()
	}

	override func updateLayer() {
		self.buttonLayer.cornerRadius = self.frame.height / 3.0
	}

	// MARK: - Tracking Area

	private var trackingArea: NSTrackingArea? = nil
	override open func updateTrackingAreas() {
		super.updateTrackingAreas()

		if let t = self.trackingArea {
			self.removeTrackingArea(t)
		}
		let newTrackingArea = NSTrackingArea(
			rect: self.bounds,
			options: [
				.mouseEnteredAndExited,
				.activeInActiveApp
			],
			owner: self,
			userInfo: nil
		)
		self.addTrackingArea(newTrackingArea)
		//self.trackingArea = newTrackingArea
	}

	// MARK: - Mouse Actions

	private var mouseIsDown: Bool = false
	private var mouseInside: Bool = false

	override func mouseEntered(with event: NSEvent) {
		// Highlight with quaternary label color
		if mouseIsDown {
			self.buttonLayer.backgroundColor = NSColor.tertiaryLabelColor.cgColor
		}
		else {
			self.buttonLayer.backgroundColor = NSColor.quaternaryLabelColor.cgColor
		}
		self.mouseInside = true
	}

	override func mouseExited(with event: NSEvent) {
		self.buttonLayer.backgroundColor = nil
		self.mouseInside = false
	}

	override func mouseDown(with event: NSEvent) {
		self.buttonLayer.backgroundColor = NSColor.tertiaryLabelColor.cgColor
		self.mouseIsDown = true
	}

	override func mouseUp(with event: NSEvent) {
		if mouseInside {
			self.buttonLayer.backgroundColor = NSColor.quaternaryLabelColor.cgColor
			_ = self.target?.perform(self.action, with: self)
			if let menu = self.menu {
				menu.popUp(positioning: nil, at: NSPoint(x: self.bounds.minX, y: self.bounds.maxY + 8), in: self)
			}
		}
		else {
			self.buttonLayer.backgroundColor = nil
		}
		self.mouseIsDown = false
	}
}


extension DSFActionBarButton {
	static var menuImage: NSImage = {
		let im = NSImage(size: NSSize(width: 9, height: 16))
		im.lockFocus()

		NSColor.white.setStroke()

		let path = NSBezierPath()
		path.move(to: NSPoint(x: 2, y: 9))
		path.line(to: NSPoint(x: 5, y: 6))
		path.line(to: NSPoint(x: 8, y: 9))
		path.lineWidth = 1.5
		path.lineCapStyle = .round
		path.stroke()
		im.unlockFocus()
		im.isTemplate = true
		return im
	}()
}

#endif
