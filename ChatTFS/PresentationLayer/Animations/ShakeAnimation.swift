import UIKit

class ShakeAnimation: CAAnimationGroup {
    
    func startShake(targetView: UIView) {
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = [
            0.0,
            CGFloat.pi / 10,
            0.0,
            -CGFloat.pi / 10,
            0.0
        ]
        
        let position = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        position.values = [
            targetView.layer.position,
            CGPoint(x: targetView.center.x, y: targetView.center.y - 5),
            CGPoint(x: targetView.center.x - 5, y: targetView.center.y),
            CGPoint(x: targetView.center.x, y: targetView.center.y + 5),
            CGPoint(x: targetView.center.x + 5, y: targetView.center.y),
            targetView.layer.position
        ]
        
        self.animations = [rotation, position]
        self.duration = 0.3
        self.repeatCount = .infinity
        targetView.layer.add(self, forKey: "shake")
    }
    
    func stopShake(targetView: UIView) {
        let currentPosition = targetView.layer.presentation()?.value(forKeyPath: #keyPath(CALayer.position))
        let currentAngle = targetView.layer.presentation()?.value(forKeyPath: "transform.rotation")
        targetView.layer.removeAllAnimations()
        
        let endShakePosition = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        endShakePosition.fromValue = currentPosition
        endShakePosition.toValue = targetView.center
        
        let endShakeRotation = CABasicAnimation(keyPath: "transform.rotation")
        
        endShakeRotation.fromValue = currentAngle
        endShakeRotation.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.duration = 0.5
        group.animations = [endShakePosition, endShakeRotation]
        group.fillMode = .forwards
        
        targetView.layer.add(group, forKey: nil)
    }
}
