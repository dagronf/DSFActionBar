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

	let CaterpillarIdentifier = NSUserInterfaceItemIdentifier("caterpillar")
	let FishieIdentifier = NSUserInterfaceItemIdentifier("fishie")

	var toggle: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		self.actionBar1.add("Jobs", target: self, action: #selector(self.jobItem(_:)))

		self.actionBar1.add("Caterpillar", identifier: CaterpillarIdentifier, target: self, action: #selector(self.caterpillarItem(_:)))
		self.actionBar1.item(for: CaterpillarIdentifier)?.disabled = true

		self.actionBar1.add("Toggle Some Items", target: self, action: #selector(self.toggle(_:)))
		self.actionBar1.add("Fishie!", identifier: FishieIdentifier, target: self, action: #selector(self.fishieItem(_:)))


		let m = NSMenu()
		m.addItem(withTitle: "first", action: #selector(self.firstItem(_:)), keyEquivalent: "")
		m.addItem(withTitle: "second", action: #selector(self.secondItem(_:)), keyEquivalent: "")
		m.addItem(withTitle: "third", action: #selector(self.thirdItem(_:)), keyEquivalent: "")

		self.actionBar1.add("Womble", menu: m)

		self.actionBar2.controlSize = .regular

		self.actionBar2.add("first item") { Swift.print("first item selected ") }
		self.actionBar2.add("second item") { Swift.print("second item selected ") }
		self.actionBar2.add("third item") { Swift.print("third item selected ") }


	}

	@objc func toggle(_ sender: AnyObject) {
		self.toggle.toggle()

		guard let fishie = self.actionBar1.item(for: FishieIdentifier),
			  let caterpillar = self.actionBar1.item(for: CaterpillarIdentifier) else {
			fatalError()
		}

		if self.toggle {
			let m = NSMenu()
			m.addItem(withTitle: "abc", action: nil, keyEquivalent: "")
			m.addItem(withTitle: "def", action: nil, keyEquivalent: "")
			m.addItem(withTitle: "ghi", action: nil, keyEquivalent: "")
			fishie.menu = m
		}
		else {
			fishie.setAction(#selector(self.fishieItem(_:)), for: self)
		}

		caterpillar.disabled = !self.toggle
	}

	@objc func firstItem(_: Any) {
		Swift.print("first selected!")
	}

	@objc func jobItem(_: Any) {
		Swift.print("job selected!")
	}

	@objc func caterpillarItem(_: Any) {
		Swift.print("caterpillar selected!")
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
