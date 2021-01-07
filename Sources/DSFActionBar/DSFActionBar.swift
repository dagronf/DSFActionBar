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

	/// The background color for the control
	@IBInspectable public var backgroundColor: NSColor = .clear {
		didSet {
			self.needsDisplay = true
		}
	}

	/// Tooltip to display on the 'more items' button that appears when the items are clipped
	@IBInspectable public var moreButtonTooltip: String = NSLocalizedString("More actions…", comment: "Tooltip for the button that appears when there isn't enough space to display all action buttons") {
		didSet {
			self.moreButton.toolTip = self.moreButtonTooltip
		}
	}

	/// Center the items horizontally within the action bar. Otherwise, left align
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
			self.buttonItems.forEach {
				$0.controlSize = self.controlSize
				$0.needsLayout = true
			}
			self.needsLayout = true
		}
	}

	// MARK: Private definitions

	private lazy var stack: NSStackView = { self.createStack() }()
	private var buttonItems: [DSFActionBarButton] {
		return self.stack.arrangedSubviews.map { $0 as! DSFActionBarButton }
	}
	private lazy var moreButton: NSButton = {
		return self.createMoreButton()
	}()

	// MARK: Initialize and cleanup

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

	// MARK: Display and layout

	override public func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		self.configurePosition()
	}

	public override func draw(_ dirtyRect: NSRect) {
		self.backgroundColor.setFill()
		self.bounds.fill()
	}

	override public func layout() {
		super.layout()

		var b = self.bounds
		b.size.width -= 12
		self.buttonItems.forEach { item in
			item.isHidden = !b.contains(item.frame)
		}

		self.moreButton.isHidden = self.buttonItems.first(where: { item in
			item.isHidden
		}) == nil ? true : false
	}

	// MARK: Item positioning

	private var currentPositioningConstraints: [NSLayoutConstraint] = []

	private func configurePosition() {
		if self.centered {
			self.configureCentered()
		}
		else {
			self.configureLeft()
		}
	}

	private func configureLeft() {
		self.removeConstraints(self.currentPositioningConstraints)

		let r = NSLayoutConstraint(item: self.stack, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
		r.priority = NSLayoutConstraint.Priority(10)

		let constraints = [
			NSLayoutConstraint(item: self.stack, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.stack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.stack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
			r,
		]
		self.addConstraints(constraints)
		self.currentPositioningConstraints = constraints
		self.needsLayout = true
	}

	private func configureCentered() {
		self.removeConstraints(self.currentPositioningConstraints)

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
		self.currentPositioningConstraints = constraints
		self.needsLayout = true
	}

	// MARK: Item Discovery

	/// Return an item that matches the provided identifier
	public func item(for identifier: NSUserInterfaceItemIdentifier) -> DSFActionBarItem? {
		return self.actionButton(for: identifier)
	}

	private func actionButton(for identifier: NSUserInterfaceItemIdentifier) -> DSFActionBarButton? {
		let first = self.stack.arrangedSubviews.first(where: { view in view.identifier == identifier })
		if let v = first, let b = v as? DSFActionBarButton {
			return b
		}
		return nil
	}

	public var allItems: [DSFActionBarItem] {
		return self.buttonItems.map { $0 as DSFActionBarItem }
	}

	// MARK: Add items

	/// Add an item with an (optional) menu
	public func add(
		_ title: String,
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
		button.parent = self

		self.stack.addArrangedSubview(button)
	}

	public func add(
		_ title: String,
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
		button.parent = self

		self.stack.addArrangedSubview(button)
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
}

// MARK: - 'More items' button handling

extension DSFActionBar {
	@objc func showButton(_ sender: NSButton) {
		let hiddenControls: [NSMenuItem] = self.allItems.compactMap { control in

			guard control.isHidden else {
				return nil
			}

			let a = (control.disabled == false) ? control.action : nil

			let mu = NSMenuItem(title: control.title,
								action: a,
								keyEquivalent: "")
			mu.target = control.target
			mu.isEnabled = (control.disabled == false)

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

// MARK: - Stack building

extension DSFActionBar {
	func createStack() -> NSStackView {
		let v = NSStackView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.orientation = .horizontal
		v.alignment = .centerY
		v.setHuggingPriority(.defaultHigh, for: .vertical)
		v.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(10), for: .horizontal)
		v.spacing = 0
		v.detachesHiddenViews = false
		return v
	}
}

// MARK: - Interface builder support

public extension DSFActionBar {
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		self.setup()

		self.add("Item 1")
		self.add("Item 2")
	}
}

// MARK: - 'More items' button definitions

extension DSFActionBar {

	private func createMoreButton() -> NSButton {
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
	}

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

extension DSFActionBar: DSFActionBarProtocol {
	
}

#endif
