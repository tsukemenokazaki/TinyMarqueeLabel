
import UIKit

public class TinyMarqueeLabel: UILabel {

	typealias MyClass = TinyMarqueeLabel

	private weak var _body1: UILabel! = nil
	private weak var _body2: UILabel! = nil
	private var _scrollInterval: NSTimeInterval = 0
	private var _pixelsPerSecond: NSTimeInterval = 70.0	// How fast does this label do scrolling?


	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		_initializeInternally()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		_initializeInternally()
	}

	private func _initializeInternally() -> Void {
		self.clipsToBounds = true

		let body1 = _cloneMyself()
		self.addSubview(body1)
		_body1 = body1

		let body2 = _cloneMyself()
		self.addSubview(body2)
		_body2 = body2

		_scrollInterval = 3.0

		// Start scrolling
		self.text = String(super.text ?? "")
	}

	private func _cloneMyself() -> UILabel {
		let frame: CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
		let label = UILabel(frame: frame)

		label.textAlignment		= self.textAlignment
		label.font				= self.font
		label.textColor			= self.textColor
//		label.text				= self.text
		label.backgroundColor	= UIColor.clearColor()

		return label
	}

	public override var text: String? {
		get {
			return _body1.text
		}
		set {
			super.text = ""

			_body1.text = newValue
			_body2.text = newValue
			_adjustBodyLabelSize(_body1)
			_adjustBodyLabelSize(_body2)
			_cancelAnimations()
			self.performSelector(#selector(MyClass._onChangedText), withObject: nil, afterDelay: 0.05)
		}
	}

	public override var attributedText: NSAttributedString? {
		get {
			return _body1.attributedText
		}
		set {
			super.attributedText = nil

			_body1.attributedText = newValue
			_body2.attributedText = newValue
			_adjustBodyLabelSize(_body1)
			_adjustBodyLabelSize(_body2)
			_cancelAnimations()
			self.performSelector(#selector(MyClass._onChangedText), withObject: nil, afterDelay: 0.05)
		}
	}

	public override var textColor: UIColor? {
		didSet {
			_body1.textColor = self.textColor
			_body2.textColor = self.textColor
		}
	}

	public override func layoutSubviews() {
		super.layoutSubviews()

		self._adjustBodyLabelSize(_body1)
		self._adjustBodyLabelSize(_body2)
	}

	private func _adjustBodyLabelSize(label: UILabel) -> Void {
		label.sizeToFit()

		// Revert the height of the label because it has been changed to the same height as the height of the text.
		label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, self.frame.size.height)

		if (CGRectGetWidth(label.frame) < CGRectGetWidth(self.frame)) {
//			label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, self.frame.size.width, label.frame.size.height)
			label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
		}
	}

	private func _cancelAnimations() -> Void {
		self.layer.removeAllAnimations()
		_body1.layer.removeAllAnimations()
		_body2.layer.removeAllAnimations()
		NSObject.cancelPreviousPerformRequestsWithTarget(self)
	}

	@objc private func _onChangedText() -> Void {
		self._cancelAnimations()
		if (_body1.frame.size.width > self.frame.size.width) {
			_applyGradientMaskForFadeLength(14.0)
			_doMarqueeScroll()
		} else {
			self.layer.mask = nil
		}
	}

	private func _doMarqueeScroll() -> Void {
		let gapBetweenBodies: CGFloat = self.frame.width / 3.5

		_body1.frame = CGRectMake(
				0, _body1.frame.minY,
				_body1.frame.width, _body1.frame.height)
		_body2.frame = CGRectMake(
				_body1.frame.maxX + gapBetweenBodies, _body2.frame.minY,
				_body2.frame.width, _body1.frame.height)

		let distance = _body1.frame.size.width + gapBetweenBodies
		UIView.animateWithDuration(NSTimeInterval(distance) / _pixelsPerSecond,
			delay: _scrollInterval,
			options: UIViewAnimationOptions.CurveLinear,
			animations: { () -> Void in
				self._body1.frame = CGRectMake(
					self._body1.frame.minX - distance, self._body1.frame.minY,
					self._body1.frame.width, self._body1.frame.height)
				self._body2.frame = CGRectMake(
					self._body2.frame.minX - distance, self._body2.frame.minY,
					self._body2.frame.width, self._body2.frame.height)
			},
			completion: { (finished) -> Void in
				if (finished) {
					self._doMarqueeScroll()
				}
		})
	}

	public override func willMoveToSuperview(newSuperview: UIView?) {
		super.willMoveToSuperview(newSuperview)

		if (newSuperview == nil) {
			self._cancelAnimations()
		}
	}


	private func _applyGradientMaskForFadeLength(fadeLength: CGFloat) -> Void {
		var gradientMask: CAGradientLayer! = nil
		if (fadeLength != 0.0) {
			// Recreate gradient mask with new fade length
			gradientMask = CAGradientLayer()

			gradientMask.bounds = self.layer.bounds
			gradientMask.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)

			gradientMask.shouldRasterize = true
			gradientMask.rasterizationScale = UIScreen.mainScreen().scale

			gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY(self.frame))
			gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY(self.frame))
			let fadePoint: CGFloat = CGFloat(fadeLength) / CGFloat(self.frame.width)

			let gradientColors: [CGColor] = [
					UIColor.clearColor().CGColor,
					UIColor.blackColor().CGColor,
					UIColor.blackColor().CGColor,
					UIColor.clearColor().CGColor]
			gradientMask.colors = gradientColors
			gradientMask.locations = [ 0.0, fadePoint, 1 - fadePoint, 1.0 ]
		}

		CATransaction.begin()
		CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
		self.layer.mask = gradientMask
		CATransaction.commit()
	}



	public var scrollIntervael: NSTimeInterval {
		get { return _scrollInterval }
		set { _scrollInterval = newValue }
	}

	public var pixelsPerSecond: NSTimeInterval {
		get {
			return _pixelsPerSecond
		}
		set {
			_pixelsPerSecond = newValue
			_cancelAnimations()
			self.performSelector(#selector(MyClass._onChangedText), withObject: nil, afterDelay: 0.05)
		}
	}
}
