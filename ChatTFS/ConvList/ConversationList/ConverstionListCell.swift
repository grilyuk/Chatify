//
//  ConverstionListCell.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 05.03.2023.
//

import UIKit

protocol ConfigurableViewProtocol {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}

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
        static let avatarToName: CGFloat = 10
        static let avatarToMessage: CGFloat = 10
        static let indicatorToContentTrailing: CGFloat = -10
    }
    
    //MARK: Private
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.nameLabelFontSize, weight: .bold)
        return label
    }()
    
    private lazy var indicatorImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var onlineIndicator: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .green
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var lastMessageText: UILabel = {
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
        return label
    }()
    
    private lazy var userAvatar: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIConstants.avatarSize, height: UIConstants.avatarSize))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = UIConstants.avatarSize/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 1))
        view.backgroundColor = .systemGray5
        return view
    }()
    
    //MARK: Initializater
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeSeparator() {
        separatorLine.removeFromSuperview()
    }
    
    //MARK: PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        userAvatar.image = nil
        nameLabel.text = nil
        lastMessageText.text = nil
        dateLabel.text = nil
    }
    
    //MARK: Setup UI
    private func setupUI() {
        contentView.addSubview(userAvatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(lastMessageText)
        contentView.addSubview(dateLabel)
        contentView.addSubview(indicatorImage)
        contentView.addSubview(separatorLine)
        
        userAvatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageText.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorImage.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userAvatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userAvatar.heightAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            userAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UIConstants.avatarToContentEdge),
            userAvatar.widthAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.nameTopToContentTop),
            nameLabel.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: UIConstants.avatarToName),
            
            lastMessageText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: UIConstants.meesageBottomToContentBottom),
            lastMessageText.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: UIConstants.avatarToMessage),
            
            indicatorImage.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            indicatorImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UIConstants.indicatorToContentTrailing),
            
            dateLabel.trailingAnchor.constraint(equalTo: indicatorImage.leadingAnchor, constant: UIConstants.dateLabelToContentEdge),
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

//MARK: ConverstionListCell + ConfigurableViewProtocol
extension ConverstionListCell: ConfigurableViewProtocol {
    
    func configure(with model: ConversationListCellModel) {
        if model.message == nil {
            lastMessageText.font = .italicSystemFont(ofSize: UIConstants.lastMessageFontSize)
            lastMessageText.text = "No messages yet"
        } else {
            lastMessageText.text = model.message
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
                self.userAvatar.image = ImageRender(fullName: model.name ?? "Steve Jobs",
                                                    size: CGSize(width: UIConstants.avatarSize,
                                                                 height: UIConstants.avatarSize)).render()
            }
        }
        
        nameLabel.text = model.name
        
        guard let date = model.date else { return }
        if date.timeIntervalSinceNow <= 24*60*60 {
            dateLabel.text = DateFormatter.localizedString(from: date,
                                                           dateStyle: .none,
                                                           timeStyle: .short)
        } else {
            dateLabel.text = DateFormatter.localizedString(from: date,
                                                           dateStyle: .short,
                                                           timeStyle: .none)
        }
    }
}
