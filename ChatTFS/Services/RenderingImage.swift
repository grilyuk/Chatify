//
//  RenderingImage.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 05.03.2023.
//

import UIKit

class ImageRender {
    
    init(fullName: String, size: CGSize) {
        self.fullName = fullName
        self.size = size
    }
    
    var size: CGSize
    var fullName: String
    private let userInitialsLabel = UILabel()
    private let gradient = CAGradientLayer()
    private let imageProfileTopColor: UIColor = UIColor(red: 241/255, green: 159/255, blue: 180/255, alpha: 1)
    private let imageProfileBottomColor: UIColor = UIColor(red: 238/255, green: 123/255, blue: 149/255, alpha: 1)
    
    func render() -> UIImage {
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        
        gradient.colors = [imageProfileTopColor.cgColor,
                           imageProfileBottomColor.cgColor]
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
        view.addSubview(userInitialsLabel)
        userInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let initialFontSizeCalc = size.height * 0.45
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: fullName)
        formatter.style = .abbreviated
        userInitialsLabel.text = formatter.string(from: components!)
        let descriptor = UIFont.systemFont(ofSize: initialFontSizeCalc,
                                           weight: .semibold).fontDescriptor.withDesign(.rounded)
        
        userInitialsLabel.font = UIFont(descriptor: descriptor!,
                                        size: initialFontSizeCalc)
        userInitialsLabel.textColor = .white

        NSLayoutConstraint.activate([
            userInitialsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userInitialsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
             view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        return image
    }
}
