//
//  RecordButton.swift
//  Instant
//
//  Created by Samuel Beek on 21/06/15.
//  Copyright (c) 2015 Samuel Beek. All rights reserved.
//

import UIKit

enum RecordButtonState : Int {
    case Recording, Idle, Hidden;
}

class RecordButton : UIButton {
    
    var buttonColor: UIColor! = UIColor.blue {
        didSet {
            circleLayer.backgroundColor = buttonColor.cgColor
            circleBorder.borderColor = buttonColor.cgColor
        }
    }
    var progressColor: UIColor!  = UIColor.red {
        didSet {
            gradientMaskLayer.colors = [progressColor.cgColor, progressColor.cgColor]
        }
    }
    var progressLineWidth: CGFloat = 4 {
        didSet {
            progressLayer.lineWidth = progressLineWidth
            let startAngle: CGFloat = CGFloat(M_PI) + CGFloat(M_PI_2)
            let endAngle: CGFloat = CGFloat(M_PI) * 3 + CGFloat(M_PI_2)
            let centerPoint: CGPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
            progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - progressLineWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        }
    }
    var gestureDeplay: Double = 1.5 {
        didSet {
            for gesture in self.gestureRecognizers ?? [] {
                if gesture is UILongPressGestureRecognizer {
                    (gesture as! UILongPressGestureRecognizer).minimumPressDuration = self.gestureDeplay
                }
            }
        }
    }
    
    /// Closes the circle and hides when the RecordButton is finished
    var closeWhenFinished: Bool = false
    
    var buttonState : RecordButtonState = .Idle {
        didSet {
            switch buttonState {
            case .Idle:
                self.alpha = 1.0
                currentProgress = 0
                setProgress(newProgress: 0)
                setRecording(recording: false)
            case .Recording:
                self.alpha = 1.0
                setRecording(recording: true)
            case .Hidden:
                self.alpha = 0
            }
        }
        
    }
    
    private var circleLayer: CALayer!
    private var circleBorder: CALayer!
    private var progressLayer: CAShapeLayer!
    private var gradientMaskLayer: CAGradientLayer!
    private var currentProgress: CGFloat! = 0

    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    func commonInit() {
        
        self.addTarget(self, action: #selector(RecordButton.didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpOutside)
        
        self.drawButton()
    }
    
    private func drawButton() {
        
        self.backgroundColor = UIColor.clear
        let layer = self.layer
        circleLayer = CALayer()
        circleLayer.backgroundColor = buttonColor.cgColor
        
        let size: CGFloat = self.frame.size.width / 1.5
        circleLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleLayer.cornerRadius = size / 2
        layer.insertSublayer(circleLayer, at: 0)
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 1
        circleBorder.borderColor = buttonColor.cgColor
        circleBorder.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width - 1.5, height: self.bounds.size.height - 1.5)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)
        
        let startAngle: CGFloat = CGFloat(M_PI) + CGFloat(M_PI_2)
        let endAngle: CGFloat = CGFloat(M_PI) * 3 + CGFloat(M_PI_2)
        let centerPoint: CGPoint = CGPoint(x : self.frame.size.width / 2, y : self.frame.size.height / 2)
        gradientMaskLayer = self.gradientMask()
        progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - progressLineWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = progressLineWidth
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        gradientMaskLayer.mask = progressLayer
        layer.insertSublayer(gradientMaskLayer, at: 0)
    }
    
    private func setRecording(recording: Bool) {
        
        let duration: TimeInterval = 0.15
        circleLayer.contentsGravity = "center"
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = recording ? 1.0 : (bounds.size.width - 2.5*progressLineWidth)/bounds.size.width/*0.88*/
        scale.toValue = recording ? (bounds.size.width - 2.5*progressLineWidth)/bounds.size.width/*0.88*/ : 1
        scale.duration = duration
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        
        let color = CABasicAnimation(keyPath: "backgroundColor")
        color.duration = duration
        color.fillMode = kCAFillModeForwards
        color.isRemovedOnCompletion = false
        color.toValue = recording ? progressColor.cgColor : buttonColor.cgColor
        
        let circleAnimations = CAAnimationGroup()
        circleAnimations.isRemovedOnCompletion = false
        circleAnimations.fillMode = kCAFillModeForwards
        circleAnimations.duration = duration
        circleAnimations.animations = [scale, color]
        
        let borderColor: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColor.duration = duration
        borderColor.fillMode = kCAFillModeForwards
        borderColor.isRemovedOnCompletion = false
        borderColor.toValue = recording ? UIColor(red: 0.83, green: 0.86, blue: 0.89, alpha: 1).cgColor : buttonColor
        
        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        borderScale.fromValue = recording ? 1.0 : (bounds.size.width - 2.5*progressLineWidth)/bounds.size.width/*0.88*/
        borderScale.toValue = recording ? (bounds.size.width - 2.5*progressLineWidth)/bounds.size.width/*0.88*/ : 1.0
        borderScale.duration = duration
        borderScale.fillMode = kCAFillModeForwards
        borderScale.isRemovedOnCompletion = false
        
        let borderAnimations = CAAnimationGroup()
        borderAnimations.isRemovedOnCompletion = false
        borderAnimations.fillMode = kCAFillModeForwards
        borderAnimations.duration = duration
        borderAnimations.animations = [borderColor, borderScale]
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = recording ? 0.0 : 1.0
        fade.toValue = recording ? 1.0 : 0.0
        fade.duration = duration
        fade.fillMode = kCAFillModeForwards
        fade.isRemovedOnCompletion = false
        
        circleLayer.add(circleAnimations, forKey: "circleAnimations")
        progressLayer.add(fade, forKey: "fade")
        circleBorder.add(borderAnimations, forKey: "borderAnimations")
        
    }
    
    private func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 1.0]
        let topColor = progressColor
        let bottomColor = progressColor
        gradientLayer.colors = [topColor?.cgColor, bottomColor?.cgColor]
        return gradientLayer
    }
    
    override func layoutSubviews() {
        circleLayer.anchorPoint = CGPoint(x : 0.5, y : 0.5)
        circleLayer.position = CGPoint(x : self.bounds.midX, y : self.bounds.midY)
        circleBorder.anchorPoint = CGPoint(x : 0.5, y : 0.5)
        circleBorder.position = CGPoint(x : self.bounds.midX ,y : self.bounds.midY)
        super.layoutSubviews()
    }
    
    
    func didTouchDown(){
        self.buttonState = .Recording
    }
    
    func didTouchUp() {
        if(closeWhenFinished) {
            self.setProgress(newProgress: 1)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.buttonState = .Hidden
                }, completion: { completion in
                    self.setProgress(newProgress: 0)
                    self.currentProgress = 0
            })
        } else {
            self.buttonState = .Idle
        }
    }
    
    
    /**
    Set the relative length of the circle border to the specified progress
    
    - parameter newProgress: the relative lenght, a percentage as float.
    */
    func setProgress(newProgress: CGFloat) {
        progressLayer.strokeEnd = newProgress
    }
}

enum GestureType {
    case Tap, LongPress
}

extension RecordButton {
    
    func rb_addTarget(target: AnyObject?, action: Selector, forGestureEvents gestureEvents: GestureType) {
        switch gestureEvents {
        case .Tap:
            for gesture in self.gestureRecognizers ?? [] {
                if gesture is UITapGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                }
            }
            let tapGesture = UITapGestureRecognizer(target: target, action: action)
            tapGesture.numberOfTapsRequired = 1
            self.addGestureRecognizer(tapGesture)
        default:
            for gesture in self.gestureRecognizers ?? [] {
                if gesture is UILongPressGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                }
            }
            let longGesture = UILongPressGestureRecognizer(target: target, action: action)
            longGesture.minimumPressDuration = gestureDeplay
            self.addGestureRecognizer(longGesture)
        }
    }

}

