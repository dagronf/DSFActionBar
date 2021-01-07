//
//  DSFActionBar+protocols.swift
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

/// ActionBar delegate callbacks
@objc public protocol DSFActionBarDelegate {
	/// Callback when the items within an action bar reordered
	@objc optional func actionBar(_ actionBar: DSFActionBar, didReorderItems: [DSFActionBarItem])

	/// Callback when an item is right-clicked on
	@objc optional func actionBar(_ actionBar: DSFActionBar, didRightClickOnItem item: DSFActionBarItem)
}

/// ActionTabBar delegate callbacks
@objc public protocol DSFActionTabBarDelegate {
	/// Callback when an item in the tab bar is selected.
	@objc optional func actionTabBar(_ actionTabBar: DSFActionTabBar, didSelectItem item: DSFActionBarItem, atIndex index: Int)
}

/// An ActionBar item
@objc public protocol DSFActionBarItem {
	/// The item's title
	var title: String { get set }

	/// Is the item disabled?
	var disabled: Bool { get set }

	/// The current position of the item (in DSFActionBar coordinates)
	var position: CGRect { get }

	/// Is the item currently hidden (ie. only available in the menu)
	var isHidden: Bool { get }

	/// The item's identifier
	var identifier: NSUserInterfaceItemIdentifier? { get }

	/// The item's state
	var state: NSControl.StateValue { get set }

	/// The menu to be displayed for the item
	var menu: NSMenu? { get set }

	/// The action to perform on 'target' when the item is clicked
	func setAction(_ action: Selector, for target: AnyObject)
	/// The action associated with the item
	var action: Selector? { get }
	/// The target for the action associated with the item
	var target: AnyObject? { get }

	/// Block handling
	var actionBlock: (() -> Void)? { get set }
}

#endif
