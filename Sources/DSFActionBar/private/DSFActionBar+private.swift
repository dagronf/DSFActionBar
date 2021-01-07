//
//  DSFActionBar+private.swift
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

// Internal protocol for the button to ask or provide information to the action bar
internal protocol DSFActionBarProtocol {
	// Retrieve the current position (in Action Bar coordinates) of the specified iten
	func rect(for child: DSFActionBarButton) -> CGRect
	// Notify the bar that the user right-clicked on a bar item
	func rightClick(for child: DSFActionBarButton)
	// Returns the current background color set for the bar
	var backgroundColor: NSColor { get }
}

// MARK: Setup

internal extension DSFActionBar {
	func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.stack.canReorder = self.canReorder

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

	func actionButton(for identifier: NSUserInterfaceItemIdentifier) -> DSFActionBarButton? {
		let first = self.stack.arrangedSubviews.first(where: { view in view.identifier == identifier })
		if let v = first, let b = v as? DSFActionBarButton {
			return b
		}
		return nil
	}

	func actionButton(index: Int) -> DSFActionBarButton? {
		guard index >= 0, index < self.stack.arrangedSubviews.count else {
			return nil
		}
		return self.stack.arrangedSubviews[index] as? DSFActionBarButton
	}
}

// MARK: Display and layout

public extension DSFActionBar {
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		self.configurePosition()
	}

	override func draw(_: NSRect) {
		self.backgroundColor.setFill()
		self.bounds.fill()
	}

	override func layout() {
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
}

// MARK: Item positioning

extension DSFActionBar {
	internal func configurePosition() {
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
}

// MARK: - 'More items' button handling

extension DSFActionBar {
	@objc func showButton(_ sender: NSButton) {
		let hiddenControls: [NSMenuItem] = self.items.compactMap { control in

			guard control.isHidden else {
				return nil
			}

			// If the control is disabled, set the action to nil to disable the menu item
			let action = (control.disabled == false) ? #selector(menuSelected(_:)) : nil

			let mu = NSMenuItem(title: control.title,
								action: action,
								keyEquivalent: "")
			mu.target = self
			mu.isEnabled = (control.disabled == false)
			mu.state = control.state
			mu.representedObject = control

			if let menu = control.menu {
				mu.submenu = menu
			}

			return mu
		}

		let menu = NSMenu()
		menu.items = hiddenControls

		menu.popUp(positioning: nil, at: NSPoint(x: sender.frame.minX, y: sender.frame.minY), in: self)
	}

	@objc func menuSelected(_ sender: NSMenuItem) {
		guard let control = sender.representedObject as? DSFActionBarButton,
			  let c = control.cell as? NSButtonCell else {
			fatalError("Unexpected control type in action bar")
		}

		if c.type.rawValue == NSButton.ButtonType.toggle.rawValue {
			control.state = .on
		}

		// Force the action
		_ = control.target?.perform(control.action, with: control)
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

internal extension DSFActionBar {
	func createMoreButton() -> NSButton {
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

// MARK: - Stack building

internal extension DSFActionBar {

	func updateTags() {
		self.buttonItems.enumerated().forEach { $0.element.tag = $0.offset }
	}

	func createStack() -> DraggingStackView {
		let v = DraggingStackView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.orientation = .horizontal
		v.alignment = .centerY
		v.setHuggingPriority(.defaultHigh, for: .vertical)
		v.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(10), for: .horizontal)
		v.spacing = 0
		v.detachesHiddenViews = false
		v.dragDelegate = self
		return v
	}

	func createButton(_ title: String, _ identifier: NSUserInterfaceItemIdentifier?) -> DSFActionBarButton {
		let button = DSFActionBarButton(frame: NSZeroRect)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.title = title
		button.identifier = identifier
		button.bezelStyle = .shadowlessSquare

		button.action = nil
		button.target = nil
		button.actionBlock = nil
		button.menu = nil

		button.parent = self
		button.controlSize = self.controlSize

		return button
	}
}

extension DSFActionBar: DSFActionBarProtocol {
	func rect(for child: DSFActionBarButton) -> CGRect {
		if child.isHidden {
			/// If the child is hidden, it won't be visible in the UI.
			return .zero
		}
		let pos = child.convert(child.bounds, to: self)
		return pos
	}

	func rightClick(for child: DSFActionBarButton) {
		self.actionDelegate?.actionBar?(self, didRightClickOnItem: child)
	}
}

// MARK: - DraggingStackView reorder events

extension DSFActionBar: DraggingStackViewProtocol {
	func stackViewDidReorder() {
		self.updateTags()
		self.actionDelegate?.actionBar?(self, didReorderItems: self.items)
	}
}

#endif
