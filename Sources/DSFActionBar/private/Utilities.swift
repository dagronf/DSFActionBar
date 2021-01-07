//
//  Utilities.swift
//  
//
//  Created by Darren Ford on 7/1/21.
//

#if os(macOS)

import AppKit

@inlinable
func UsingEffectiveAppearance<T>(of view: NSView, perform block: () throws -> T) rethrows -> T {
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
