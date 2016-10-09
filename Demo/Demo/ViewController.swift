
import UIKit
import TinyMarqueeLabel

class ViewController: UIViewController {

	@IBOutlet weak var _marqueeLabel: TinyMarqueeLabel!
	@IBOutlet weak var _fasterButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		_fasterButton.addTarget(self,
				action: #selector(ViewController._didTouchFasterButton(_:)),
				forControlEvents: .TouchUpInside)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	@objc private func _didTouchFasterButton(sender: AnyObject) {
		_marqueeLabel.pixelsPerSecond = 200
		_marqueeLabel.scrollIntervael = 0
		_fasterButton.hidden = true
	}
}

