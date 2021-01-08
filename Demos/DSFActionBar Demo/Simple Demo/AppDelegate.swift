//
//  AppDelegate.swift
//  Simple Demo
//
//  Created by Darren Ford on 8/1/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	let safariStyle = SafariStyleActionBarWindowController()


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application

		safariStyle.loadWindow()
		safariStyle.showWindow(self)
		safariStyle.setup()

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

