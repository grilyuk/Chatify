//
//  ConverstionListCell.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 05.03.2023.
//

import UIKit

struct ConversationListCellModel {
    let name: String?
    let message: String?
    let date: Date?
    let isOnline: Bool?
    let hasUnreadMessages: Bool?
}

class ConverstionListCell: UITableViewCell {

    static let identifier = "conListCell"
    
    //MARK: UIConstants
    private enum UIConstants {
        static let avatarToContentEdge: CGFloat = 5
        static let avatarSize: CGFloat = 60
        static let nameTopToContentTop: CGFloat = 17
        static let nameLabelFontSize: CGFloat = 16
        static let lastMessageFontSize: CGFloat = 15
        static let dateLabelFontSize: CGFloat = 15
        static let meesageBottomToContentBottom: CGFloat = -17
        static let dateLabelToContentEdge: CGFloat = -5
    }
    
    //MARK: Private
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.nameLabelFontSize, weight: .bold)
        return label
    }()
    
//    private lazy var indicatorImage
    
    private lazy var onlineIndicator: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .green
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var lastMeassgeText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.lastMessageFontSize, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.dateLabelFontSize, weight: .regular)
        label.textColor = .gray
        label.text = "09:41"
        return label
    }()
    
    private lazy var userAvatar: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIConstants.avatarSize, height: UIConstants.avatarSize))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = UIConstants.avatarSize/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //MARK: Initializater
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configure
    func configure(with model: ConversationListCellModel) {
        if model.message == nil {
            lastMeassgeText.font = .italicSystemFont(ofSize: UIConstants.lastMessageFontSize)
            lastMeassgeText.text = "No messages yet"
        } else {
            lastMeassgeText.text = model.message
        }
        
        if model.isOnline == false {
            onlineIndicator.removeFromSuperview()
        } else {
            contentView.addSubview(onlineIndicator)
            onlineIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                onlineIndicator.topAnchor.constraint(equalTo: userAvatar.topAnchor),
                onlineIndicator.trailingAnchor.constraint(equalTo: userAvatar.trailingAnchor)
            ])
        }
        
        if userAvatar.image == nil {
            DispatchQueue.main.async {
                self.userAvatar.image = ImageRender(fullName: model.name ?? "Steve Jobs").render()
            }
        }
        nameLabel.text = model.name
        print(nameLabel.text!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print(nameLabel.text! + " reuse")
    }
    
    //MARK: Setup UI
    private func setupUI() {
        contentView.addSubview(userAvatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(lastMeassgeText)
        contentView.addSubview(dateLabel)
        
        userAvatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMeassgeText.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userAvatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userAvatar.heightAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            userAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UIConstants.avatarToContentEdge),
            userAvatar.widthAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.nameTopToContentTop),
            nameLabel.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: 10),
            
            lastMeassgeText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: UIConstants.meesageBottomToContentBottom),
            lastMeassgeText.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: 10),
            
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UIConstants.dateLabelToContentEdge),
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
        ])
    }
}
