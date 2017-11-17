//
//  PullToExpandView.swift
//  PullToExpand
//
//  Created by Julian Dunskus on 13.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import UIKit

@IBDesignable public class PullableView: UIView {
	@IBInspectable public var minHeight: CGFloat = 64
	@IBInspectable public var maxHeight: CGFloat = 512
	@IBInspectable public var darkeningOpacity: CGFloat = 0.4
	@IBInspectable public var dampingRatio: CGFloat = 1
	
	@IBAction public func expand() {
		updateBarSize(compact: false)
	}
	
	@IBAction public func contract() {
		updateBarSize(compact: true)
	}
	
	@IBAction public func toggle() {
		updateBarSize(compact: !isCompact)
	}
	
	@objc func viewPulled(_ recognizer: UIPanGestureRecognizer) {
		let velocity = recognizer.velocity(in: superview).y
		let translation = recognizer.translation(in: superview).y
		
		switch recognizer.state {
		case .possible:
			break
		case .began:
			animator?.stopAnimation(true)
			lastTranslation = 0
			animationProgress = (height - minHeight) / heightDifference
			startedCompact = isCompact
		fallthrough // already got some translation and velocity here
		case .changed:
			defer {
				lastTranslation = translation
			}
			let progress = (translation - lastTranslation) / heightDifference
			
			animationProgress += progress
			//height = newHeight.softClamped(min: minHeight, max: maxHeight)
			//darkeningView.alpha = progress * darkeningOpacity
		case .ended:
			let shouldCompact = 0.1 * velocity / heightDifference + animationProgress < 0.5
			//print("0.1 * \(velocity) / \(heightDifference) + \(animationProgress) = \(0.1 * velocity / heightDifference + animationProgress) vs 0.5")
			updateBarSize(compact: shouldCompact, springVelocity: velocity)
		case .cancelled, .failed:
			updateBarSize(compact: startedCompact, springVelocity: velocity)
		}
	}
	
	var heightDifference: CGFloat {
		return maxHeight - minHeight
	}
	
	var animationProgress: CGFloat = 0 {
		didSet {
			height = minHeight + animationProgress.softClamped() * heightDifference
			darkeningView.alpha = animationProgress.clamped() * darkeningOpacity
		}
	}
	
	var isCompact: Bool {
		return height <= minHeight + heightDifference / 2
	}
	
	var lastTranslation: CGFloat = 0
	var startedCompact = false
	var darkeningView: UIView!
	var animator: UIViewPropertyAnimator?
	lazy var minConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: minHeight)
	lazy var maxConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: maxHeight)
	
	/**
	Programmatically instantiate the view in its compact form
	
	- Parameter frame: frame of the view in its compact state; determines `minHeight`
	- Parameter expandedHeight: height of the view in its expanded state; determines `maxHeight`
	*/
	public init(frame: CGRect, expandedHeight: CGFloat) {
		minHeight = frame.height
		maxHeight = expandedHeight
		super.init(frame: frame)
	}
	
	/// Please use `init(frame:expandedHeight:)` to programmatically instantiate this view.
	/// 
	/// This initializer is necessary for @IBDesignable
	public override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	/// Please use `init(frame:expandedHeight:)` to programmatically instantiate this view.
	/// 
	/// This initializer is necessary for storyboard-based instantiation
	required public init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override public func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(viewPulled)))
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expand)))
		
		minConstraint.isActive = true
		maxConstraint.isActive = false
		
		darkeningView = UIView(frame: CGRect(origin: .zero, size: superview?.frame.size ?? .zero))
		darkeningView.backgroundColor = .black
		darkeningView.alpha = 0
		darkeningView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		superview?.insertSubview(darkeningView, belowSubview: self)
		
		darkeningView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contract)))
	}
	
	func timingParameters(initialVelocity: CGFloat = 0) -> UISpringTimingParameters {
		let mass: CGFloat = 1
		let stiffness: CGFloat = 50
		let damping = dampingRatio * 2 * sqrt(mass * stiffness)
		let velocity = CGVector(dx: initialVelocity, dy: 0) // only magnitude is considered for 1D animations
		return UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: velocity)
	}
	
	/// - Parameter compact: whether to resize to a compact or expanded view
	/// - Parameter velocity: the initial velocity, in points, to start the animation with
	func updateBarSize(compact: Bool, springVelocity velocity: CGFloat = 0) {
		let targetHeight = compact ? minHeight : maxHeight
		animator?.stopAnimation(true)
		let parameters = timingParameters(initialVelocity: velocity / (targetHeight - frame.height)) // have to normalize to animation distance
		animator = UIViewPropertyAnimator(duration: 10, timingParameters: parameters) // duration will be ignored because of advanced spring timing parameters
		
		maxConstraint.isActive = false // to avoid unsatisfiable constraint warnings
		minConstraint.isActive = compact
		maxConstraint.isActive = !compact
		superview!.setNeedsLayout()
		animator!.addAnimations {
			self.superview!.layoutIfNeeded()
			self.darkeningView.alpha = compact ? 0 : self.darkeningOpacity
		}
		animator!.startAnimation()
	}
}

private extension UIView {
	var height: CGFloat {
		get { return frame.size.height            }
		set {        frame.size.height = newValue }
	}
}
