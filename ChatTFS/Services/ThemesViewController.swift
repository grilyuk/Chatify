//
//  ThemesViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 11.03.2023.
//

import UIKit

class ThemesViewController: UIViewController {
    
    //MARK: UIConstants
    enum UIConstants {
        static let cornerRadius: CGFloat = 16
        static let borderOnExample: CGFloat = 1.5
        static let fontSize: CGFloat = 15
    }
    
    //MARK: Private properties
    private lazy var bubble: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var lightExample: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "lightTheme")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.borderWidth = UIConstants.borderOnExample
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private lazy var darkExample: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "darkTheme")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .black
        view.layer.borderWidth = UIConstants.borderOnExample
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.fontSize)
        label.text = "Day"
        return label
    }()
    
    private lazy var nightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.fontSize)
        label.text = "Night"
        return label
    }()
    
    private lazy var dayTickButton: UIButton = {
        let checkmarkButton = UIButton(type: .custom)
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkmarkButton.addTarget(self, action: #selector(selectedDayButton), for: .touchUpInside)
        return checkmarkButton
    }()
    
    private lazy var nightTickButton: UIButton = {
        let checkmarkButton = UIButton(type: .custom)
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkmarkButton.addTarget(self, action: #selector(selectedNightButton), for: .touchUpInside)
        return checkmarkButton
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        fetchTheme()
        setNavigationBar()
        setupConstraints()
    }
    
    //MARK: - Private methods
    private func themeChanged(to theme: UIUserInterfaceStyle ) {
        guard let window = UIApplication.shared.windows.first else { return }
        UIView.transition (with: window, duration: 0.2, options: .transitionCrossDissolve, animations: {
            window.overrideUserInterfaceStyle = theme
        })
    }
    
    private func fetchTheme() {
        if traitCollection.userInterfaceStyle == .light {
            dayTickButton.isSelected = true
        } else {
            nightTickButton.isSelected = true
        }
    }

    @objc
    private func selectedDayButton(_ sender: UIButton) {
        sender.isSelected = true
        nightTickButton.isSelected = false
        themeChanged(to: .light)
    }
    
    @objc
    private func selectedNightButton(_ sender: UIButton) {
        sender.isSelected = true
        dayTickButton.isSelected = false
        themeChanged(to: .dark)
    }
    
    private func setNavigationBar() {
        self.title = "Settings"
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupConstraints() {
        view.addSubview(bubble)
        bubble.addSubviews(lightExample, darkExample, dayTickButton, nightTickButton, dayLabel, nightLabel)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        lightExample.translatesAutoresizingMaskIntoConstraints = false
        darkExample.translatesAutoresizingMaskIntoConstraints = false
        dayTickButton.translatesAutoresizingMaskIntoConstraints = false
        nightTickButton.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        nightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            bubble.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bubble.widthAnchor.constraint(equalTo: view.widthAnchor,constant: -32),
            bubble.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1/4),
            
            lightExample.widthAnchor.constraint(equalTo: bubble.widthAnchor, multiplier: 1/3),
            lightExample.heightAnchor.constraint(equalTo: bubble.heightAnchor, multiplier: 1/3),
            lightExample.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 30),
            lightExample.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 30),
            
            darkExample.widthAnchor.constraint(equalTo: bubble.widthAnchor, multiplier: 1/3),
            darkExample.heightAnchor.constraint(equalTo: bubble.heightAnchor, multiplier: 1/3),
            darkExample.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -30),
            darkExample.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 30),
            
            dayLabel.centerXAnchor.constraint(equalTo: lightExample.centerXAnchor),
            dayLabel.topAnchor.constraint(equalTo: lightExample.bottomAnchor, constant: 20),
            
            nightLabel.centerXAnchor.constraint(equalTo: darkExample.centerXAnchor),
            nightLabel.topAnchor.constraint(equalTo: darkExample.bottomAnchor, constant: 20),

            dayTickButton.centerXAnchor.constraint(equalTo: lightExample.centerXAnchor),
            dayTickButton.widthAnchor.constraint(equalTo: lightExample.widthAnchor),
            dayTickButton.heightAnchor.constraint(equalTo: view.heightAnchor),
            dayTickButton.centerYAnchor.constraint(equalTo: bubble.bottomAnchor,constant: -30),
            
            nightTickButton.centerXAnchor.constraint(equalTo: darkExample.centerXAnchor),
            nightTickButton.widthAnchor.constraint(equalTo: darkExample.widthAnchor),
            nightTickButton.heightAnchor.constraint(equalTo: view.heightAnchor),
            nightTickButton.centerYAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -30)
        ])
    }
}
