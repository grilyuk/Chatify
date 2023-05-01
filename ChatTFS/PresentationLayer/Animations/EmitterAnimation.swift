import UIKit

class EmitterAnimation: CAEmitterLayer {
    
    lazy var logoCell: CAEmitterCell = {
        var cell = CAEmitterCell()
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.emissionRange = .pi
        cell.birthRate = 5
        cell.velocityRange = -20
        cell.yAcceleration = 30
        cell.xAcceleration = 5
        let image = UIImage(named: "tinkoff")
        cell.contents = image?.cgImage
        cell.velocity = 25
        cell.lifetime = 1
        cell.spin = -0.5
        cell.spinRange = 1.0
        return cell
    }()
    
    func setupLogoLayer(layer: CAEmitterLayer) {
        layer.emitterSize = CGSize(width: 50, height: 50)
        layer.emitterShape = CAEmitterLayerEmitterShape.point
        layer.emitterCells = [logoCell]
    }
    
    func setupGesture(sender: UIGestureRecognizer, view: UIView) {
        self.birthRate = 50
        setupLogoLayer(layer: self)
        let location = sender.location(in: view.window)
        self.emitterPosition = CGPoint(x: location.x, y: location.y)
        view.window?.layer.addSublayer(self)
        if sender.state == .ended {
            self.birthRate = 0
        }
    }
}
