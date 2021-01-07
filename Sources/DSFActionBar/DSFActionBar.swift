//
//  DSFActionBar.swift
//  testing ui stuff big sur
//
//  Created by Darren Ford on 7/1/21.
//

#if os(macOS)

import AppKit

@IBDesignable
public class DSFActionBar: NSView {
	@IBInspectable public var backgroundColor: NSColor = .clear {
		didSet {
			self.layer?.backgroundColor = self.backgroundColor.cgColor
		}
	}

	@IBInspectable public var moreButtonTooltip: String = NSLocalizedString("More actions…", comment: "Tooltip for the button that appears when there isn't enough space to display all action buttons") {
		didSet {
			self.moreButton.toolTip = self.moreButtonTooltip
		}
	}

	@IBInspectable public var centered: Bool = false {
		didSet {
			self.configurePosition()
		}
	}

	public var edgeInsets = NSEdgeInsets() {
		didSet {
			self.stack.edgeInsets = self.edgeInsets
		}
	}

	@IBInspectable public var leftInset: CGFloat = 0 {
		didSet {
			var ei = self.stack.edgeInsets
			ei.left = self.leftInset
			self.stack.edgeInsets = ei
		}
	}

	@IBInspectable public var rightInset: CGFloat = 0 {
		didSet {
			var ei = self.stack.edgeInsets
			ei.right = self.rightInset
			self.stack.edgeInsets = ei
		}
	}

	@IBInspectable public var topInset: CGFloat = 0 {
		didSet {
			var ei = self.stack.edgeInsets
			ei.top = self.topInset
			self.stack.edgeInsets = ei
		}
	}

	@IBInspectable public var bottomInset: CGFloat = 0 {
		didSet {
			var ei = self.stack.edgeInsets
			ei.bottom = self.bottomInset
			self.stack.edgeInsets = ei
		}
	}

	public var controlSize: NSControl.ControlSize = .regular {
		didSet {
			self.items.forEach {
				$0.controlSize = self.controlSize
				$0.needsLayout = true
			}
			self.needsLayout = true
		}
	}

	private lazy var stack: NSStackView = { self.createStack() }()
	var items: [NSButton] = []

	lazy var moreButton: NSButton = {
		let moreButton = NSButton()
		moreButton.translatesAutoresizingMaskIntoConstraints = false
		moreButton.isBordered = false
		moreButton.setButtonType(.momentaryChange)
		moreButton.image = Self.MoreImage
		moreButton.imageScaling = .scaleNone
		moreButton.imagePosition = .imageOnly

		moreButton.target = self
		moreButton.action = #selector(self.showButton(_:))

		return moreButton
	}()

	override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	private func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.wantsLayer = true
		self.layer?.backgroundColor = self.backgroundColor.cgColor

		self.addSubview(self.stack)

		// Constraints for the containing stack
		self.configurePosition()

		// Constraints for the 'more' button
		self.addSubview(self.moreButton)
		let constraints2 = [
			NSLayoutConstraint(item: self.moreButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.moreButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.moreButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),

			NSLayoutConstraint(item: self.moreButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 16),
		]
		self.addConstraints(constraints2)

		self.moreButton.toolTip = self.moreButtonTooltip
	}

	override public func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		self.configurePosition()
	}

	// MARK: - Positions

	private var lastC: [NSLayoutConstraint] = []

	func configurePosition() {
		if self.centered {
			self.configureCentered()
		}
		else {
			self.configureLeft()
		}
	}

	private func configureLeft() {
		self.removeConstraints(self.lastC)

		let r = NSLayoutConstraint(item: self.stack, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
		r.priority = NSLayoutConstraint.Priority(10)

		let constraints = [
			NSLayoutConstraint(item: self.stack, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.stack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.stack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
			r,
		]
		self.addConstraints(constraints)
		self.lastC = constraints
		self.needsLayout = true
	}

	private func configureCentered() {
		self.removeConstraints(self.lastC)

		let r = NSLayoutConstraint(item: self.stack, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .left, multiplier: 1, constant: 0)

		let c = NSLayoutConstraint(item: self.stack, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
		c.priority = NSLayoutConstraint.Priority(10)

		let constraints = [
			c,
			NSLayoutConstraint(item: self.stack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.stack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
			r,
		]
		self.addConstraints(constraints)
		self.lastC = constraints
		self.needsLayout = true
	}

	public func add(_ title: String,
					identifier: NSUserInterfaceItemIdentifier? = nil,
					menu: NSMenu? = nil)
	{
		let button = DSFActionBarButton(frame: NSZeroRect)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.title = title
		button.bezelStyle = .roundRect
		button.identifier = identifier
		button.menu = menu
		button.controlSize = self.controlSize

		self.stack.addArrangedSubview(button)
		self.items.append(button)
	}

	public func rename(_ title: String, identifier: NSUserInterfaceItemIdentifier) {
		if let button = self.actionButton(for: identifier) {
			button.title = title
			self.needsDisplay = true
		}
	}

	private func actionButton(for identifier: NSUserInterfaceItemIdentifier) -> DSFActionBarButton? {
		let first = self.stack.arrangedSubviews.first(where: { view in view.identifier == identifier })
		if let v = first, let b = v as? DSFActionBarButton {
			return b
		}
		return nil
	}

	public func setMenu(_ menu: NSMenu?, for identifier: NSUserInterfaceItemIdentifier) {
		if let button = actionButton(for: identifier) {
			button.menu = menu
			button.action = nil
			button.target = nil
			button.updateMenuStatus()
		}
	}

	public func setAction(_ action: Selector, for target: AnyObject, with identifier: NSUserInterfaceItemIdentifier) {
		if let button = actionButton(for: identifier) {
			button.menu = nil
			button.action = action
			button.target = target
			button.updateMenuStatus()
		}
	}

	public func add(_ title: String,
					identifier: NSUserInterfaceItemIdentifier? = nil,
					target: AnyObject,
					action: Selector)
	{
		let button = DSFActionBarButton(frame: NSZeroRect)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.title = title
		button.bezelStyle = .roundRect
		button.identifier = identifier
		button.action = action
		button.target = target
		button.controlSize = self.controlSize

		self.stack.addArrangedSubview(button)
		self.items.append(button)
	}

	public func remove(identifier: NSUserInterfaceItemIdentifier) {
		if let v = self.stack.arrangedSubviews.first(where: { view in
			view.identifier == identifier
		}) {
			self.stack.removeArrangedSubview(v)
		}
	}

	public func removeAll() {
		self.stack.arrangedSubviews.forEach { self.stack.removeArrangedSubview($0) }
	}

	override public func layout() {
		super.layout()

		var b = self.bounds
		b.size.width -= 12
		self.items.forEach { item in
			item.isHidden = !b.contains(item.frame)
		}

		self.moreButton.isHidden = self.items.first(where: { item in
			item.isHidden
		}) == nil ? true : false
	}

	@objc func showButton(_ sender: NSButton) {
		let hiddenControls: [NSMenuItem] = self.items.compactMap { item in

			guard let control = item as? NSButton else {
				return nil
			}

			guard control.isHidden else {
				return nil
			}

			let mu = NSMenuItem(title: control.title,
								action: control.action,
								keyEquivalent: "")
			mu.target = control.target

			if let menu = control.menu {
				mu.submenu = menu
			}

			return mu
		}
		
		let menu = NSMenu()
		menu.items = hiddenControls

		menu.popUp(positioning: nil, at: NSPoint(x: sender.frame.minX, y: sender.frame.minY), in: self)
	}
}

extension DSFActionBar {
	func createStack() -> NSStackView {
		let v = NSStackView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.orientation = .horizontal
		v.alignment = .centerY
		v.setHuggingPriority(.defaultHigh, for: .vertical)
		v.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(10), for: .horizontal)
		// v.edgeInsets = NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
		v.spacing = 4
		v.detachesHiddenViews = false
		return v
	}
}

public extension DSFActionBar {
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		self.setup()

		self.add("Item 1")
		self.add("Item 2")
	}
}

extension DSFActionBar {
	static var MoreImage: NSImage = {
		let im = NSImage(size: NSSize(width: 24, height: 16))
		im.lockFocus()

		NSColor.white.setStroke()

		let path = NSBezierPath()
		path.move(to: NSPoint(x: 4, y: 4))
		path.line(to: NSPoint(x: 8, y: 8))
		path.line(to: NSPoint(x: 4, y: 12))

		path.move(to: NSPoint(x: 8, y: 4))
		path.line(to: NSPoint(x: 12, y: 8))
		path.line(to: NSPoint(x: 8, y: 12))

		path.lineWidth = 1.5
		path.lineCapStyle = .round
		path.stroke()
		im.unlockFocus()
		im.isTemplate = true
		return im
	}()
}

#endif
