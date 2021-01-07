//
//  DSFActionBar.swift
//  DSFActionBar
//
//  Created by Darren Ford on 7/1/21.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

	// MARK: Initialize and cleanup

	override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
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
		button.actionBlock = nil
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
		button.actionBlock = nil
		button.controlSize = self.controlSize
		button.parent = self

		self.stack.addArrangedSubview(button)
	}

	public func add(
		_ title: String,
		identifier: NSUserInterfaceItemIdentifier? = nil,
		block: @escaping () -> Void)
	{
		let button = DSFActionBarButton(frame: NSZeroRect)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.title = title
		button.bezelStyle = .roundRect
		button.identifier = identifier
		button.action = nil
		button.target = nil
		button.actionBlock = block
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

	// MARK: - Private definitions

	lazy var stack: NSStackView = { self.createStack() }()
	var buttonItems: [DSFActionBarButton] {
		return self.stack.arrangedSubviews.map { $0 as! DSFActionBarButton }
	}
	lazy var moreButton: NSButton = {
		return self.createMoreButton()
	}()

	// Constraints for positioning
	var currentPositioningConstraints: [NSLayoutConstraint] = []
}

#endif
