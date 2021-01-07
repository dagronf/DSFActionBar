//
//  ViewController.swift
//  DSFActionBar Demo
//
//  Created by Darren Ford on 7/1/21.
//

import Cocoa
import DSFActionBar

class ViewController: NSViewController {
	@IBOutlet var actionBar1: DSFActionBar!
	@IBOutlet var actionBar2: DSFActionBar!

	var toggle: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		self.actionBar1.add("Jobs", target: self, action: #selector(self.firstItem(_:)))
		self.actionBar1.add("Caterpillar")
		self.actionBar1.add("Toggle Fishie", target: self, action: #selector(self.toggle(_:)))
		self.actionBar1.add("Fishie!", identifier: NSUserInterfaceItemIdentifier("fishie"), target: self, action: #selector(self.fishieItem(_:)))

		let m = NSMenu()
		m.addItem(withTitle: "first", action: #selector(self.firstItem(_:)), keyEquivalent: "")
		m.addItem(withTitle: "second", action: #selector(self.secondItem(_:)), keyEquivalent: "")
		m.addItem(withTitle: "third", action: #selector(self.thirdItem(_:)), keyEquivalent: "")

		self.actionBar1.add("Womble", menu: m)


		self.actionBar2.controlSize = .small

		self.actionBar2.add("first item")
		self.actionBar2.add("second item")
		self.actionBar2.add("third item")


	}

	@objc func toggle(_: Any) {
		self.toggle.toggle()

		if self.toggle {
			let m = NSMenu()
			m.addItem(withTitle: "abc", action: nil, keyEquivalent: "")
			m.addItem(withTitle: "def", action: nil, keyEquivalent: "")
			m.addItem(withTitle: "ghi", action: nil, keyEquivalent: "")
			self.actionBar1.setMenu(m, for: NSUserInterfaceItemIdentifier("fishie"))
		}
		else {
			self.actionBar1.setAction(#selector(self.fishieItem(_:)), for: self, with: NSUserInterfaceItemIdentifier("fishie"))
		}
	}

	@objc func firstItem(_: Any) {
		Swift.print("first selected!")
	}

	@objc func secondItem(_: Any) {
		Swift.print("second selected!")
	}

	@objc func thirdItem(_: Any) {
		Swift.print("third selected!")
	}

	@objc func fishieItem(_: Any) {
		Swift.print("fishie selected!")
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}
