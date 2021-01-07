//
//  DSFActionTabBar.swift
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
public class DSFActionTabBar: DSFActionBar {

	@objc public weak var actionTabDelegate: DSFActionTabBarDelegate?

	public override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.configure()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configure()
	}

	internal func configure() {
		self.setup()
		self.canReorder = false
	}

	/// Add an item to the tab bar.
	@objc public func add(_ title: String, identifier: NSUserInterfaceItemIdentifier? = nil) -> DSFActionBarItem {
		let item = super.add(title, identifier: identifier)
		item.setAction(#selector(clicked(_:)), for: self)
		if self.itemCount == 1 {
			// First item.  Select it!
			guard let button = item as? DSFActionBarButton else {
				fatalError("Internal error - arranged subviews is empty after add")
			}
			self.select(button)
		}
		return item
	}

	// MARK: Select tab item

	@objc public func select(_ item: DSFActionBarItem) {
		guard let button = item as? DSFActionBarButton else {
			fatalError("Unexpected bar item type")
		}
		self.buttonItems.forEach { $0.state = (button === $0) ? .on : .off }
		self.clicked(button)
	}

	@objc public func select(index: Int) {
		guard let item = self.item(index: index) else {
			return
		}
		self.select(item)
	}

	@objc public func select(title: String) {
		guard let item = self.item(title: title) else {
			return
		}
		self.select(item)
	}

	/// Bar button callbacks

	@objc internal func clicked(_ sender: DSFActionBarButton) {
		self.items.forEach { $0.state = (sender === $0) ? .on : .off }

		self.actionTabDelegate?.actionTabBar?(self, didSelectItem: sender, atIndex: sender.tag)
	}

}

#endif
