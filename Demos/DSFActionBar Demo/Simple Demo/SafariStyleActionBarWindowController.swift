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

	@IBOutlet weak var actionBar: DSFActionBar!

	override func windowDidLoad() {
		super.windowDidLoad()
	}

	func setup() {
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

		self.actionBar.add("fourth item", target: self, action: #selector(fourthItem(_:)))

		self.actionBar.add("toggle enabled") {
			if let item = self.actionBar.item(title: "third item") {
				item.disabled.toggle()
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
