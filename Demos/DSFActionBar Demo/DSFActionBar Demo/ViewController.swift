//
//  ViewController.swift
//  DSFActionBar Demo
//
//  Created by Darren Ford on 7/1/21.
//

import Cocoa
import DSFActionBar

class ViewController: NSViewController {

	@IBOutlet weak var actionBar1: DSFActionBar!

	var toggle: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		actionBar1.add("Jobs", target: self, action: #selector(firstItem(_:)))
		actionBar1.add("Caterpillar")
		actionBar1.add("Toggle Fishie", target: self, action: #selector(toggle(_:)))
		actionBar1.add("Fishie!", identifier: NSUserInterfaceItemIdentifier("fishie"), target: self, action: #selector(fishieItem(_:)))

		let m = NSMenu()
		m.addItem(withTitle: "first", action: #selector(firstItem(_:)), keyEquivalent: "")
		m.addItem(withTitle: "second", action: #selector(secondItem(_:)), keyEquivalent: "")
		m.addItem(withTitle: "third", action: #selector(thirdItem(_:)), keyEquivalent: "")

		actionBar1.add("Womble", menu: m)
	}

	@objc func toggle(_ sender: Any) {
		self.toggle.toggle()

		if self.toggle {
			let m = NSMenu()
			m.addItem(withTitle: "abc", action: nil, keyEquivalent: "")
			m.addItem(withTitle: "def", action: nil, keyEquivalent: "")
			m.addItem(withTitle: "ghi", action: nil, keyEquivalent: "")
			self.actionBar1.setMenu(m, for: NSUserInterfaceItemIdentifier("fishie"))
		}
		else {
			self.actionBar1.setAction(#selector(fishieItem(_:)), for: self, with: NSUserInterfaceItemIdentifier("fishie"))
		}
	}

	@objc func firstItem(_ sender: Any) {
		Swift.print("first selected!")
	}
	@objc func secondItem(_ sender: Any) {
		Swift.print("second selected!")
	}
	@objc func thirdItem(_ sender: Any) {
		Swift.print("third selected!")
	}
	@objc func fishieItem(_ sender: Any) {
		Swift.print("fishie selected!")
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

