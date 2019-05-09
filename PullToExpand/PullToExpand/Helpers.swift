// Created by Julian Dunskus

import CoreGraphics

extension CGFloat {
	func clamped(to bounds: (min: CGFloat, max: CGFloat) = (0, 1)) -> CGFloat {
		let (min, max) = bounds
		return self < min ? min : self > max ? max : self
	}
	
	/// clamps a value to (`min`, `max`), allowing it to go out of bounds up to `scaling * (max - min)` smoothly
	func softClamped(to bounds: (min: CGFloat, max: CGFloat) = (0, 1), scale: CGFloat = 0.5) -> CGFloat {
		let (min, max) = bounds
		let space = (max - min) * scale
		func soften(offset: CGFloat) -> CGFloat {
			return space * offset / (space + offset) // goes from 0 to space, with a gradient of 1 at 0 (and 0 at ∞)
		}
		
		if self < min {
			return min - soften(offset: min - self)
		} else if self > max {
			return max + soften(offset: self - max)
		} else {
			return self
		}
	}
}
