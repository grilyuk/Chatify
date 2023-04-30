import UIKit

class EmitterAnimation {
    
    lazy var snowLayer = CAEmitterLayer()
    
    lazy var snowCell: CAEmitterCell = {
        var snowCell = CAEmitterCell()
        snowCell.scale = 0.06
        snowCell.scaleRange = 0.3
        snowCell.emissionRange = .pi
        snowCell.birthRate = 5
        snowCell.velocityRange = -20
        snowCell.yAcceleration = 30
        snowCell.xAcceleration = 5
        let image = UIImage(named: "tinkoff")
        snowCell.contents = image?.cgImage
        snowCell.velocity = 25
        snowCell.lifetime = 1
        snowCell.spin = -0.5
        snowCell.spinRange = 1.0
        return snowCell
    }()
    
    func setupSnowLayer(layer: CAEmitterLayer) {
        layer.emitterSize = CGSize(width: 50, height: 50)
        layer.emitterShape = CAEmitterLayerEmitterShape.point
        layer.emitterCells = [snowCell]
    }
}
