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

	@IBOutlet weak var actionTabBar1: DSFActionTabBar!


	let CaterpillarIdentifier = NSUserInterfaceItemIdentifier("caterpillar")
	let FishieIdentifier = NSUserInterfaceItemIdentifier("fishie")

	var toggle: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		self.actionBar1.actionDelegate = self

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


		self.actionBar2.actionDelegate = self
		self.actionBar2.controlSize = .regular

		self.actionBar2.add("first item") {
			Swift.print("first item selected ")
		}
		self.actionBar2.add("second item") {
			Swift.print("second item selected ")
		}
		self.actionBar2.add("third item") {
			Swift.print("third item selected ")
		}

		self.actionTabBar1.actionTabDelegate = self

		self.actionTabBar1.add("All Items")
		self.actionTabBar1.add("Passwords")
		self.actionTabBar1.add("Secure Notes")
		self.actionTabBar1.add("My Certificates")
		self.actionTabBar1.add("Keys")
		self.actionTabBar1.add("Certificates")
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

		guard let r = self.actionBar1.item(for: CaterpillarIdentifier)?.position else {
			fatalError()
		}

		Swift.print("Caterpillar button is located at \(r) within first action bar")

		// Overlay something (like a text field for renaming)
		//	let b = NSTextField(frame: r!)
		//	self.actionBar1.addSubview(b)
		//	self.view.window?.makeFirstResponder(b)

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

extension ViewController: DSFActionBarDelegate {
	func actionBar(_ actionBar: DSFActionBar, didReorderItems items: [DSFActionBarItem]) {
		guard actionBar === self.actionBar2 else { return }
		Swift.print("Did reorder items '\(items)'")
	}

	func actionBar(_ actionBar: DSFActionBar, didRightClickOnItem item: DSFActionBarItem) {
		guard actionBar === self.actionBar1 else { return }

		Swift.print("Did right-click on item '\(item.title)'")
		let m = NSMenu()
		let mi1 = m.addItem(withTitle: "Open in tab", action: #selector(a1(_:)), keyEquivalent: "")
		mi1.representedObject = item
		let mi2 = m.addItem(withTitle: "Open in window", action: #selector(a2(_:)), keyEquivalent: "")
		mi2.representedObject = item

		let pos = self.view.window!.mouseLocationOutsideOfEventStream
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

extension ViewController: DSFActionTabBarDelegate {
	func actionTabBar(_ actionTabBar: DSFActionTabBar, didSelectItem item: DSFActionBarItem, atIndex index: Int) {
		Swift.print("Selected tab \(index) for item '\(item.title)'")
	}
}
