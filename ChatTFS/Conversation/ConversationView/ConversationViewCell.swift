//
//  ConversationViewCell.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

struct MessageCellModel {
    let text: String
    let date: Date
    let myMessage: Bool
}

class ConversationViewCell: UITableViewCell {
    
    static let identifier = "conCell"
    
    //MARK: UIConstants
    private enum UIConstants {
        static let edge: CGFloat = 5
        static let cornerRadius: CGFloat = 5
        static let fontSizeDate: CGFloat = 10
    }
    
    //MARK: Private
    private lazy var messageText: UILabel = {
        let message = UILabel()
        message.textAlignment = .left
        message.backgroundColor = .clear
        message.numberOfLines = 0
        return message
    }()
    
    private lazy var messageBubble: UIView = {
        let bubble = UIView()
        bubble.frame = contentView.frame
        bubble.backgroundColor = .systemBlue
        bubble.layer.cornerRadius = UIConstants.cornerRadius
        bubble.clipsToBounds = true
        return bubble
    }()
    
    private lazy var dateLabel: UILabel = {
        let date = UILabel()
        date.textColor = .white
        date.font = .systemFont(ofSize: UIConstants.fontSizeDate, weight: .regular)
        date.text = "09:41"
        return date
    }()
    
    //MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: SetupUI
    private func setupUI() {
        contentView.addSubview(messageBubble)
        messageBubble.addSubview(messageText)
        messageBubble.addSubview(dateLabel)
        
        messageBubble.translatesAutoresizingMaskIntoConstraints = false
        messageText.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageBubble.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UIConstants.edge),
            messageBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.edge),
            messageText.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor, constant: UIConstants.edge),
            messageText.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -UIConstants.edge),
            messageText.topAnchor.constraint(equalTo: messageBubble.topAnchor, constant: UIConstants.edge),
            messageText.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor, constant:  -UIConstants.edge),
            messageBubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 3/4),
            dateLabel.bottomAnchor.constraint(equalTo: messageText.bottomAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: messageBubble.trailingAnchor, constant: -UIConstants.edge)
        ])
    }
    
    //MARK: Configure
    func configure(with model: MessageCellModel) {
        if model.myMessage == true {
            messageText.textColor = .white
            NSLayoutConstraint.activate([
                messageBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.edge)
            ])
        } else {
            messageBubble.backgroundColor = .systemGray5
            NSLayoutConstraint.activate([
                messageBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.edge)
            ])
        }
        messageText.text = model.text
    }
}
