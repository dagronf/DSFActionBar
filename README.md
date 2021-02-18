# DSFActionBar

<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/safari-style-tab-bar-expanded.png?raw=true"><img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/safari-style-tab-bar-expanded.png?raw=true" width="690"></a>

<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/keychain-style-tab-bar-complete.png?raw=true"><img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/keychain-style-tab-bar-complete.png?raw=true" width="490"></a>

An editable, draggable bar of buttons and menus similar to Safari's Favorites bar with overflow support for macOS (10.11 and later).

![](https://img.shields.io/github/v/tag/dagronf/DSFActionBar) ![](https://img.shields.io/badge/macOS-10.11+-red) ![](https://img.shields.io/badge/Swift-5.3-orange.svg)
![](https://img.shields.io/badge/License-MIT-lightgrey) [![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

# Classes

## DSFActionBar

A collection of buttons (items).  If not enough space is available to display all the items, a 'More Items' button appears with the hidden buttons in it.

This control was inspired by Safari's favorites bar.

<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/safari-style-tab-bar-expanded.png?raw=true"><img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/safari-style-tab-bar-expanded.png?raw=true" width="600"></a>
<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/safari-style-tab-bar-overflow.png?raw=true"><img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/safari-style-tab-bar-overflow.png?raw=true" width="300"></a>

<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/safari-style.mp4?raw=true">Demo Movie</a>

### Features

* Center or left-align the item collection
* Set the background color
* Add, remove, rename items
* Enable/Disable items
* Right-click on item detection
* Overflow support when the available space is too narrow
* (Optional) dropdown menu support for items
* (Optional) reordering via dragging the items

### Example

```swift
self.actionBar.actionDelegate = self

// Add a simple 'job' button with a target/action
self.actionBar.add("Jobs", target: self, action: #selector(self.jobItem(_:)))

// Add a button with a drop-down menu
let menu = NSMenu()
menu.addItem(withTitle: "first", action: #selector(self.firstItem(_:)), keyEquivalent: "")
menu.addItem(withTitle: "second", action: #selector(self.secondItem(_:)), keyEquivalent: "")
menu.addItem(withTitle: "third", action: #selector(self.thirdItem(_:)), keyEquivalent: "")
self.actionBar.add("Ordering", menu: menu)
```

## DSFActionTabBar

A collection of buttons that act as a tab bar.  If not enough space is available, a 'More Items' button appears with the 'hidden' tabs in it.

For an example of this, look at detail pane in KeyChain Access - "All Items", "Password" etc. It is this KeyChain Access app that partially inspired this control - as you will notice that if you resize the window smaller than the tabs it just draws off-screen)

### Screenshots

<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/keychain-style-tab-bar-complete.png?raw=true"><img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/keychain-style-tab-bar-complete.png?raw=true" width="600"></a>

<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/keychain-style-tab-bar-overflow.png?raw=true"><img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFActionBar/keychain-style-tab-bar-overflow.png?raw=true" width="500"></a>

<a href="https://github.com/dagronf/dagronf.github.io/raw/master/art/projects/DSFActionBar/keychain-style.mp4">Demo Movie</a>

### Features

* Center or left-align the item collection
* Set the background color
* Add, remove, rename items
* Enable/Disable items
* Overflow support when the available space is too narrow

### Example

```swift
// Set the delegate so that we receive tab selection messages
self.actionTabBar.actionTabDelegate = self

// Add our items
self.actionTabBar.add("All Items")
self.actionTabBar.add("Passwords")
self.actionTabBar.add("Secure Notes")
self.actionTabBar.add("My Certificates")
self.actionTabBar.add("Keys")
self.actionTabBar.add("Certificates")

...

extension MyViewController: DSFActionTabBarDelegate {
	func actionTabBar(_ actionTabBar: DSFActionTabBar, didSelectItem item: DSFActionBarItem, atIndex index: Int) {
		Swift.print("Selected tab \(index) for item '\(item.title)'")
	}
}
```

# Demo

You can find some demo apps in the `Demos` subfolder.

# Installation

## Swift Package Manager

Add `https://github.com/dagronf/DSFActionBar` to your project.

# Usage

## Via Interface Builder

* Add a custom NSView using Interface Builder, then change the class type to `DSFActionBar` or `DSFActionTabBar` as needed.

## Programatically

```swift
let actionBar = DSFActionBar(frame: rect)
let tabBar = DSFActionTabBar(frame: rect)
```

# Known issues

* Dragging after changing the theme (ie. dark mode -> standard) the draw background still uses the color of the previous theme.

# Thanks

## DraggableStackView - Mark Onyschuk

* Mark Onyschuk on [GitHub](https://github.com/monyschuk) -- [Draggable Stack View](https://gist.github.com/monyschuk/cbca3582b6b996ab54c32e2d7eceaf25)

# Changes

## `1.0.0`

* Fixed issue when dragging off the bar not resetting the cursor. ([link](https://github.com/dagronf/DSFActionBar/issues/1))


# License
```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
