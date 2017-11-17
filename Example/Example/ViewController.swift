//
//  ViewController.swift
//  Example
//
//  Created by Julian Dunskus on 27.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import UIKit
import PullToExpand

class ViewController: UIViewController {
	@IBOutlet weak var pullableView: PullableView!
	
	@IBOutlet weak var dampingSlider: UISlider!
	@IBOutlet weak var dampingLabel: UILabel!
	@IBOutlet weak var stiffnessSlider: UISlider!
	@IBOutlet weak var stiffnessLabel: UILabel!
	
	@IBAction func dampingRatioChanged() {
		pullableView.damping = CGFloat(dampingSlider.value)
		dampingLabel.text = String(dampingSlider.value)
	}
	
	@IBAction func stiffnessChanged() {
		pullableView.stiffness = CGFloat(stiffnessSlider.value)
		stiffnessLabel.text = String(stiffnessSlider.value)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
