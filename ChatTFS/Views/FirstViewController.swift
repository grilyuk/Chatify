//
//  FirstViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 16.02.2023.
//

import UIKit

class FirstViewController: UIViewController {

    //MARK: Properties
    private let buttonToSecView = UIButton(type: .custom)

    //MARK: ViewController Lifeсycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Called method: \(#function)")
        view.backgroundColor = .systemYellow
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Called method: \(#function)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Called method: \(#function)")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("Called method: \(#function)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Called method: \(#function)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Called method: \(#function)")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Called method: \(#function)")
    }

    //MARK: SetupUI
    private func setupUI() {
        setButton()
    }

    private func setButton() {
        view.addSubview(buttonToSecView)
        buttonToSecView.translatesAutoresizingMaskIntoConstraints = false
        buttonToSecView.setTitle("Go to second view", for: .normal)
        buttonToSecView.titleLabel?.font = .systemFont(ofSize: 30)
        buttonToSecView.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        buttonToSecView.sizeToFit()
        buttonToSecView.layer.cornerRadius = buttonToSecView.frame.height/2
        buttonToSecView.backgroundColor = .systemGray4
        buttonToSecView.setTitleColor(.blue, for: .normal)
        buttonToSecView.setTitleColor(.darkGray, for: .highlighted)
        buttonToSecView.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            buttonToSecView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            buttonToSecView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    @objc func buttonTapped(sender: UIButton) {
        navigationController?.pushViewController(SecondViewController(), animated: true)
    }
}
