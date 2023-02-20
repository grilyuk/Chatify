//
//  FirstViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 16.02.2023.
//

import UIKit

class FirstViewController: UIViewController {

    let log = Logger()
    
    //MARK: ViewController Lifeсycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        log.handleLog(actualState: nil, previousState: nil)
        view.backgroundColor = .systemYellow
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }
}
