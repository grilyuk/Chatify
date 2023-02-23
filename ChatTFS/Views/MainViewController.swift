//
//  FirstViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 16.02.2023.
//

import UIKit

class MainViewController: UIViewController {

    let log = Logger(shouldLog: false, logType: .viewController)

    //MARK: ViewController Lifeсycle methods
    override func loadView() {
        super.loadView()
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.handleLog(actualState: nil, previousState: nil)
        let profileVC = ProfileViewController()
        present(profileVC, animated: true)
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
