import UIKit

class EmitterAnimation: CAEmitterLayer {
    
    override init(layer: Any) {
        super.init(layer: layer)
        emitterCells = [logoCell]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    func setupPanGesture(sender: UIGestureRecognizer, view: UIView) {
        self.birthRate = 50
        self.emitterSize = CGSize(width: 50, height: 50)
        self.emitterShape = CAEmitterLayerEmitterShape.point
        let location = sender.location(in: view)
        self.emitterPosition = location
        view.window?.layer.addSublayer(self)
        if sender.state == .ended {
            self.birthRate = 0
        }
    }
}
