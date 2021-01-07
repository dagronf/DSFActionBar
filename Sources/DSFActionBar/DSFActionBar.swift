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

internal let DefaultMoreTooltip = NSLocalizedString("More actions…", comment: "Tooltip for the button that appears when there isn't enough space to display all action buttons")

@IBDesignable
public class DSFActionBar: NSView {
	// MARK: Delegates

	/// If set, the delegate receives callbacks when the items are reordered in the action bar
	public weak var actionDelegate: DSFActionBarDelegate? {
		didSet {
			self.stack.dragDelegate = (self.actionDelegate == nil) ? nil : self
		}
	}

	// MARK: Public properties

	/// The background color for the control (defaults to clear)
	@IBInspectable public var backgroundColor: NSColor = .clear {
		didSet {
			self.needsDisplay = true
		}
	}

	/// Tooltip to display on the 'more items' button that appears when the items are clipped
	@IBInspectable public var moreButtonTooltip: String = DefaultMoreTooltip {
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

	/// Can the item bar be reordered via dragging?
	@IBInspectable public var canReorder: Bool = false {
		didSet {
			self.stack.canReorder = self.canReorder
		}
	}

	/// The inset to apply to the items bar
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

	/// The size of the control
	public var controlSize: NSControl.ControlSize = .small {
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

	deinit {
		self.actionDelegate = nil
		self.removeAll()
	}

	// MARK: Item Discovery

	/// Return all the items in the order they are presented left-to-right within the action bar
	@objc public var items: [DSFActionBarItem] {
		return self.buttonItems
	}

	/// The number of items in the action bar
	@inlinable @objc public var itemCount: Int {
		return self.items.count
	}

	/// Return an item that matches the provided identifier
	@objc public func item(for identifier: NSUserInterfaceItemIdentifier) -> DSFActionBarItem? {
		return self.actionButton(for: identifier)
	}

	/// Returns the item at the specified index.  If the index is out of range, returns nil
	@objc public func item(index: Int) -> DSFActionBarItem? {
		return self.actionButton(index: index)
	}

	// MARK: Add item

	/// Add an item with an (optional) menu
	@objc public func add(_ title: String,
						  identifier: NSUserInterfaceItemIdentifier? = nil,
						  menu: NSMenu? = nil) {
		let button = self.createButton(title, identifier)
		button.menu = menu
		self.stack.addArrangedSubview(button)
	}

	/// Add a new button item using a target/selector
	@objc public func add(_ title: String,
						  identifier: NSUserInterfaceItemIdentifier? = nil,
						  target: AnyObject,
						  action: Selector) {
		let button = self.createButton(title, identifier)
		button.action = action
		button.target = target
		self.stack.addArrangedSubview(button)
	}

	/// Add a new button item, using a callback block
	@objc public func add(_ title: String,
						  identifier: NSUserInterfaceItemIdentifier? = nil,
						  block: @escaping () -> Void) {
		let button = self.createButton(title, identifier)
		button.actionBlock = block
		self.stack.addArrangedSubview(button)
	}

	// MARK: Insert item

	/// Adds an item to the action bar at a specific index.
	@objc public func insert(at index: Int,
							 title: String,
							 identifier: NSUserInterfaceItemIdentifier? = nil) -> DSFActionBarItem
	{
		let button = self.createButton(title, identifier)
		self.stack.insertArrangedSubview(button, at: index)
		return button
	}

	// MARK: Remove item(s)

	/// Remove a item from the action bar
	@objc public func remove(item: DSFActionBarItem) -> Bool {
		if let itemButton = item as? DSFActionBarButton {
			self.stack.removeArrangedSubview(itemButton)
			return true
		}
		else {
			return false
		}
	}

	/// Remove an item from the action bar using the identifier
	@objc public func remove(identifier: NSUserInterfaceItemIdentifier) {
		if let button = self.actionButton(for: identifier) {
			self.stack.removeArrangedSubview(button)
			self.stack.needsLayout = true
		}
	}

	/// Remove all the items from the action bar
	@objc public func removeAll() {
		self.stack.arrangedSubviews.forEach { self.stack.removeArrangedSubview($0) }
		self.stack.needsLayout = true
	}

	// MARK: - Private definitions

	lazy var stack: DraggingStackView = {
		self.createStack()
	}()

	/// The arranged items in the stack as Action Bar Buttons
	var buttonItems: [DSFActionBarButton] {
		return self.stack.arrangedSubviews.map { $0 as! DSFActionBarButton }
	}

	/// The 'More Items' button
	lazy var moreButton: NSButton = {
		self.createMoreButton()
	}()

	// Constraints for positioning
	var currentPositioningConstraints: [NSLayoutConstraint] = []
}

#endif
