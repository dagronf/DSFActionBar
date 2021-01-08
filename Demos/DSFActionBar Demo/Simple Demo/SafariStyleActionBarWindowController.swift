//
//  SafariStyleActionBarWindowController.swift
//  Simple Demo
//
//  Created by Darren Ford on 8/1/21.
//

import Cocoa
import DSFActionBar

class SafariStyleActionBarWindowController: NSWindowController {
	override var windowNibName: NSNib.Name? {
		return "SafariStyleActionBarWindowController"
	}

	@IBOutlet var actionBar: DSFActionBar!

	var fourthItemHasMenu = false

	override func windowDidLoad() {
		super.windowDidLoad()
	}

	func setup() {
		self.actionBar.actionDelegate = self
		self.actionBar.canReorder = true

		// Add with a callback block
		self.actionBar.add("first item") {
			Swift.print("first item selected ")
		}

		let m = NSMenu()
		m.addItem(withTitle: "first", action: #selector(self.firstItem(_:)), keyEquivalent: "")
		m.addItem(withTitle: "second", action: #selector(self.secondItem(_:)), keyEquivalent: "")
		m.addItem(withTitle: "third", action: #selector(self.thirdItem(_:)), keyEquivalent: "")
		self.actionBar.add("second item", menu: m)

		let thirdItem = self.actionBar.add("third item") {
			Swift.print("third item selected ")
		}
		thirdItem.disabled = true

		self.actionBar.add("fourth item", target: self, action: #selector(self.fourthItem(_:)))

		self.actionBar.add("toggle enabled") {
			if let item = self.actionBar.item(title: "third item") {
				item.disabled.toggle()
			}
		}

		self.actionBar.add("toggle menu") { [weak self] in
			guard let `self` = self else { return }
			if let item = self.actionBar.item(title: "fourth item") {
				self.fourthItemHasMenu.toggle()
				if self.fourthItemHasMenu {
					let m = NSMenu()
					m.addItem(withTitle: "five", action: nil, keyEquivalent: "")
					m.addItem(withTitle: "six", action: nil, keyEquivalent: "")
					item.menu = m
				}
				else {
					item.setAction(#selector(self.fourthItem(_:)), for: self)
				}
			}
		}

	}

	@objc func firstItem(_: Any) {
		Swift.print("first menu item selected!")
	}

	@objc func secondItem(_: Any) {
		Swift.print("second menu item selected!")
	}

	@objc func thirdItem(_: Any) {
		Swift.print("third menu item selected!")
	}

	@objc func fourthItem(_: Any) {
		Swift.print("fourth item selected!")
	}
}

extension SafariStyleActionBarWindowController: DSFActionBarDelegate {

	// Demo reorder detection

	func actionBar(_ actionBar: DSFActionBar, didReorderItems items: [DSFActionBarItem]) {
		let newOrder = items.map { $0.title }
		Swift.print("New item order is: \(newOrder)")
	}

	// Demo right-click support

	func actionBar(_ actionBar: DSFActionBar, didRightClickOnItem item: DSFActionBarItem) {
		Swift.print("Did right-click on item '\(item.title)'")
		let m = NSMenu()
		let mi1 = m.addItem(withTitle: "Open in tab", action: #selector(a1(_:)), keyEquivalent: "")
		mi1.representedObject = item
		let mi2 = m.addItem(withTitle: "Open in window", action: #selector(a2(_:)), keyEquivalent: "")
		mi2.representedObject = item

		let pos = self.window!.mouseLocationOutsideOfEventStream
		let ev = actionBar.convert(pos, from: nil)
		m.popUp(positioning: nil, at: ev, in: actionBar)
	}

	@objc func a1(_ sender: NSMenuItem) {
		let item = sender.representedObject as! DSFActionBarItem
		Swift.print(" > Open in tab selected for '\(item.title)'")
	}

	@objc func a2(_ sender: NSMenuItem) {
		let item = sender.representedObject as! DSFActionBarItem
		Swift.print(" > Open in window selected for '\(item.title)'")
	}
}
