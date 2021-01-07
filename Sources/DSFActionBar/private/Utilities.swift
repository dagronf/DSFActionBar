//
//  Utilities.swift
//  DSFActionBar
//
//  Created by Darren Ford on 7/1/21.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#if os(macOS)

import AppKit

/// Perform the supplied block using the appearance settings of the specified view
@inlinable func UsingEffectiveAppearance<T>(of view: NSView, perform block: () throws -> T) rethrows -> T {
	let saved = NSAppearance.current
	NSAppearance.current = view.effectiveAppearance
	let result = try block()
	NSAppearance.current = saved
	return result
}

extension NSColor {
	/// Returns a black or white contrasting color for this color
	/// - Parameter defaultColor: If the color cannot be converted to the genericRGB colorspace, or the input color is .clear, the fallback color
	/// - Returns: black or white depending on which provides the greatest contrast to this color
	func flatContrastColor(defaultColor: NSColor = .textColor) -> NSColor {
		if let rgbColor = self.usingColorSpace(.genericRGB),
			rgbColor != NSColor.clear {
			let r = 0.299 * rgbColor.redComponent
			let g = 0.587 * rgbColor.greenComponent
			let b = 0.114 * rgbColor.blueComponent
			let avgGray: CGFloat = 1 - (r + g + b)
			return (avgGray >= 0.45) ? .white : .black
		}
		return defaultColor
	}
}

#endif
