//
//  ConversationViewCell.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

class ConversationViewCell: UITableViewCell {
    
    static let identifier = "conCell"
    
    //MARK: UIConstants
    private enum UIConstants {
        static let edge: CGFloat = 12
        static let edgeVertical: CGFloat = 8
        static let edgeToTable: CGFloat = 10
        static let cornerRadius: CGFloat = 16
        static let fontSizeDate: CGFloat = 10
    }
    
    //MARK: Private
    private lazy var messageText: UILabel = {
        let message = UILabel()
        message.isUserInteractionEnabled = true
        message.textAlignment = .natural
        message.backgroundColor = .clear
        message.numberOfLines = 0
        return message
    }()
    
    private lazy var messageBubble: UIView = {
        let bubble = UIView()
        bubble.frame = contentView.frame
        bubble.layer.cornerRadius = UIConstants.cornerRadius
        bubble.clipsToBounds = true
        return bubble
    }()
    
    private lazy var dateLabel: UILabel = {
        let date = UILabel()
        date.font = .systemFont(ofSize: UIConstants.fontSizeDate, weight: .regular)
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
    
    //MARK: PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        messageText.text = nil
        dateLabel.text = nil
    }
    
    //MARK: SetupUI
    func setupUI() {
        contentView.addSubview(messageBubble)
        messageBubble.addSubview(messageText)
        messageBubble.addSubview(dateLabel)
        
        messageBubble.translatesAutoresizingMaskIntoConstraints = false
        messageText.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        let maxBubbleWidht = messageBubble.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.75)
        maxBubbleWidht.priority = .required
        maxBubbleWidht.isActive = true
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            messageBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.edgeVertical),
            messageBubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.edgeVertical),
            dateLabel.trailingAnchor.constraint(equalTo: messageBubble.trailingAnchor, constant: -UIConstants.edge),
            dateLabel.leadingAnchor.constraint(equalTo: messageText.trailingAnchor, constant: UIConstants.edge),
            dateLabel.bottomAnchor.constraint(equalTo: messageText.bottomAnchor),
            messageText.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor, constant: UIConstants.edge),
            messageText.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor, constant: -UIConstants.edge + 2),
            messageText.topAnchor.constraint(equalTo: messageBubble.topAnchor, constant: UIConstants.edgeVertical)
        ])
    }
}

//MARK: ConversationViewCell + ConfigurableViewProtocol
extension ConversationViewCell: ConfigurableViewProtocol {
    func configure(with model: MessageCellModel) {
        if model.myMessage {
            if traitCollection.userInterfaceStyle == .light {
                messageText.textColor = .white
                dateLabel.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9607843137, alpha: 1)
                messageBubble.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.5411764706, blue: 0.968627451, alpha: 1)
            } else {
                messageText.textColor = .white
                dateLabel.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9607843137, alpha: 1)
                messageBubble.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.5411764706, blue: 0.968627451, alpha: 1)
            }
            messageText.text = model.text
            messageBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.edgeToTable).isActive = true
        } else {
            if traitCollection.userInterfaceStyle == .light {
                messageText.textColor = .black
                dateLabel.textColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.59)
                messageBubble.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1)
            } else {
                messageText.textColor = .white
                dateLabel.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9607843137, alpha: 1)
                messageBubble.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1)
            }
            messageBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.edgeToTable).isActive = true
            messageText.text = model.text
        }
        
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        dateLabel.text = format.string(from: model.date)
    }
}
