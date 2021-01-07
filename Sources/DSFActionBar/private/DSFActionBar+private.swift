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

// MARK: Setup

extension DSFActionBar {
	func setup() {
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
}

// MARK: Item positioning

extension DSFActionBar {
	func configurePosition() {
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

extension DSFActionBar: DSFActionBarProtocol {

}

#endif

