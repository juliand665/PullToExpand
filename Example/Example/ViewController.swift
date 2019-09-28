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
		dampingLabel.text = formatter.string(from: dampingSlider.value as NSNumber)
	}
	
	@IBAction func stiffnessChanged() {
		pullableView.stiffness = CGFloat(stiffnessSlider.value)
		stiffnessLabel.text = formatter.string(from: stiffnessSlider.value as NSNumber)
	}
	
	let formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.minimumIntegerDigits = 1
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		return formatter
	}()
}
