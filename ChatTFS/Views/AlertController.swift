//
//  AlertController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 24.02.2023.
//

import UIKit

class AlertController: UIAlertController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addActions()
    }
    
    private func addActions() {
        self.addAction(UIAlertAction(title: "Сделать фото", style: .default) { UIAlertAction in
            
        })
        
        self.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { UIAlertAction in

        })
        
        self.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    }
}
