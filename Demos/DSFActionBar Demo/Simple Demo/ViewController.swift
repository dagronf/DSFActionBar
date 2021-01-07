//
//  ViewController.swift
//  Simple Demo
//
//  Created by Darren Ford on 8/1/21.
//

import Cocoa
import DSFActionBar

class ViewController: NSViewController {

	@IBOutlet weak var keychainStyleTabBar: DSFActionTabBar!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		self.keychainStyleTabBar.actionTabDelegate = self

		self.keychainStyleTabBar.edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		self.keychainStyleTabBar.itemSpacing = 4

		self.keychainStyleTabBar.add("All Items")
		self.keychainStyleTabBar.add("Passwords")
		self.keychainStyleTabBar.add("Secure Notes")
		self.keychainStyleTabBar.add("My Certificates")
		self.keychainStyleTabBar.add("Keys")
		self.keychainStyleTabBar.add("Certificates")

	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

extension ViewController: DSFActionTabBarDelegate {
	func actionTabBar(_ actionTabBar: DSFActionTabBar, didSelectItem item: DSFActionBarItem, atIndex index: Int) {
		Swift.print("Selected tab \(index) for item '\(item.title)'")
	}
}
