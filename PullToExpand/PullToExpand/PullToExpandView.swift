//
//  PullToExpandView.swift
//  PullToExpand
//
//  Created by Julian Dunskus on 13.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import UIKit

@IBDesignable public class PullableView: UIView {
	@IBInspectable public var minHeight: CGFloat = 64 {
		didSet {
			if heightConstraint.constant == oldValue {
				heightConstraint.constant = minHeight
				superview?.setNeedsLayout()
			}
		}
	}
	@IBInspectable public var maxHeight: CGFloat = 256 {
		didSet {
			if heightConstraint.constant == oldValue {
				heightConstraint.constant = maxHeight
				superview?.setNeedsLayout()
			}
		}
	}
	@IBInspectable public var previewExpanded: Bool = false // need to define type explicitly for IB
	@IBInspectable public var expandsDownward: Bool = true
	/// opacity of the darkening (black) view that fades in as the pulable view is expanded
	@IBInspectable public var darkeningOpacity: CGFloat = 0.4
	/// the lower this is, the more jelly-like the animation will be
	@IBInspectable public var damping: CGFloat = 2
	/// the higher this is, the faster the animation will be
	@IBInspectable public var stiffness: CGFloat = 50
	
	@IBAction public func expand() {
		updateBarSize(compact: false)
	}
	
	@IBAction public func contract() {
		updateBarSize(compact: true)
	}
	
	@IBAction public func toggle() {
		updateBarSize(compact: !isCompact)
	}
	
	@objc public func viewPulled(_ recognizer: UIPanGestureRecognizer) {
		let multiplier: CGFloat = expandsDownward ? 1 : -1
		let translation = multiplier * recognizer.translation(in: superview).y
		let velocity = multiplier * recognizer.velocity(in: superview).y
		
		switch recognizer.state {
		case .possible:
			break
		case .began:
			animator?.stopAnimation(true)
			lastTranslation = 0
			animationProgress = (height - minHeight) / heightDifference
		fallthrough // already got some translation and velocity here
		case .changed:
			let progress = (translation - lastTranslation) / heightDifference
			lastTranslation = translation
			
			animationProgress += progress
		case .ended:
			let compact = 0.1 * velocity / heightDifference + animationProgress < 0.5
			updateBarSize(compact: compact, springVelocity: velocity)
		case .cancelled, .failed:
			updateBarSize(compact: isCompact, springVelocity: velocity)
		}
	}
	
	public var isCompact = true
	public lazy var panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(viewPulled))
	public lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expand))
	
	var heightDifference: CGFloat {
		return maxHeight - minHeight
	}
	
	/// 0 is fully compact; 1 is fully expanded
	var animationProgress: CGFloat = 0 {
		didSet {
			heightConstraint.constant = minHeight + animationProgress.softClamped() * heightDifference
			superview!.setNeedsLayout()
			darkeningView.alpha = animationProgress.clamped() * darkeningOpacity
		}
	}
	
	var lastTranslation: CGFloat = 0
	var darkeningView: UIView!
	var animator: UIViewPropertyAnimator?
	
	lazy var heightConstraint = heightAnchor.constraint(equalToConstant: minHeight)
	
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
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	public override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		addGestureRecognizer(panRecognizer)
		addGestureRecognizer(tapRecognizer)
		
		heightConstraint.isActive = true
		
		darkeningView = UIView(frame: CGRect(origin: .zero, size: superview?.frame.size ?? .zero))
		darkeningView.backgroundColor = .black
		darkeningView.alpha = 0
		darkeningView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		superview?.insertSubview(darkeningView, belowSubview: self)
		
		darkeningView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contract)))
	}
	
	public override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		heightConstraint.constant = previewExpanded ? maxHeight : minHeight
	}
	
	func timingParameters(initialVelocity: CGFloat = 0) -> UISpringTimingParameters {
		let component = initialVelocity / sqrt(2)
		let velocity = CGVector(dx: component, dy: component) // the magnitude is what matters in the end, but the top end wiggles if dx ≠ dy
		return UISpringTimingParameters(mass: 0.05, stiffness: stiffness, damping: damping, initialVelocity: velocity)
	}
	
	/// - Parameter compact: whether to resize to a compact or expanded view
	/// - Parameter velocity: the initial velocity, in points, to start the animation with
	func updateBarSize(compact: Bool, springVelocity velocity: CGFloat = 0) {
		let targetHeight = compact ? minHeight : maxHeight
		animator?.stopAnimation(true)
		let parameters = timingParameters(initialVelocity: velocity / (targetHeight - frame.height)) // have to normalize to animation distance
		animator = UIViewPropertyAnimator(duration: 10, timingParameters: parameters) // duration will be ignored because of advanced spring timing parameters
		
		heightConstraint.constant = compact ? minHeight : maxHeight
		
		animator!.addAnimations {
			self.superview?.layoutIfNeeded()
			self.darkeningView.alpha = compact ? 0 : self.darkeningOpacity
		}
		animator!.addCompletion { _ in
			self.isCompact = compact
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
