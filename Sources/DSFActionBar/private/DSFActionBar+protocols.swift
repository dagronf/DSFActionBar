//
//  DSFActionBar+protocols.swift
//  
//  Created by Darren Ford on 7/1/21.
//

#if os(macOS)

import AppKit

@objc public protocol DSFActionBarItem: NSObjectProtocol {

	/// Is the item disabled?
	var disabled: Bool { get set }

	/// Is the item hidden or not?
	var isHidden: Bool { get }

	/// The item's title
	var title: String { get set }

	/// The item's identifier
	var identifier: NSUserInterfaceItemIdentifier? { get }

	/// The menu to be displayed for the item
	var menu: NSMenu? { get set }

	/// The action to perform on 'target' when the item is clicked
	func setAction(_ action: Selector, for target: AnyObject)

	var action: Selector? { get }
	var target: AnyObject? { get }

}

protocol DSFActionBarProtocol {
	var backgroundColor: NSColor { get }
}

#endif
