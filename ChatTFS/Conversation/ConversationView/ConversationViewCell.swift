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
    
    private lazy var messageText: UILabel = {
        let message = UILabel()
        message.textAlignment = .left
        message.text = "Testing cell for resizing this text"
        message.backgroundColor = .clear
        return message
    }()
    
    private lazy var messageBubble: UILabel = {
        let bubble = UILabel()
        bubble.layer.cornerRadius = 5
        bubble.clipsToBounds = true
        return bubble
        
    }()
    
    private lazy var dateLabel: UILabel = {
        let date = UILabel()
        date.backgroundColor = .clear
        
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
    
    private func setupUI() {
        contentView.addSubview(messageBubble)
        messageBubble.addSubview(messageText)
        messageBubble.addSubview(dateLabel)
        
        messageBubble.translatesAutoresizingMaskIntoConstraints = false
        messageText.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            messageBubble.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width/(3*4)),
            messageText.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor),
            messageText.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: messageText.trailingAnchor)
        ])
    }
    
    func configure(with model: MessageCellModel) {
        if model.myMessage == true {
            NSLayoutConstraint.activate([
                messageBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                messageBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            ])
        }
    }
    
    
}
