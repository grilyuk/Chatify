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
        static let avatarSize: CGFloat = 76
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
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.height, height: contentView.frame.height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "square")
        imageView.layer.cornerRadius = 76/2
        imageView.sizeToFit()
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
    
    enum Section: Hashable, CaseIterable {
        case online
        case offline
    }

    struct User: Hashable {
        let id = UUID()
    }
    
    //MARK: Configure
    func configure(with model: ConversationListCellModel) {
        if model.message == nil {
            lastMeassgeText.font = .systemFont(ofSize: UIConstants.lastMessageFontSize, weight: .medium)
            lastMeassgeText.text = "No messages yet"
        } else {
            lastMeassgeText.text = model.message
        }
        
        nameLabel.text = model.name
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
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
            userAvatar.topAnchor.constraint(equalTo: contentView.topAnchor),
            userAvatar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            userAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UIConstants.avatarToContentEdge),
            userAvatar.widthAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.nameTopToContentTop),
            nameLabel.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor),
            
            lastMeassgeText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: UIConstants.meesageBottomToContentBottom),
            lastMeassgeText.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor),
            
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UIConstants.dateLabelToContentEdge),
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
        ])
    }
}
