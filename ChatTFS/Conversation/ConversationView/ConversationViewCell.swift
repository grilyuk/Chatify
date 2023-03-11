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
        static let edge: CGFloat = 7
        static let edgeToTable: CGFloat = 10
        static let cornerRadius: CGFloat = 7
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
        date.textColor = .gray
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
            messageBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.edge),
            messageBubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.edge),
            dateLabel.trailingAnchor.constraint(equalTo: messageBubble.trailingAnchor, constant: -UIConstants.edge),
            dateLabel.leadingAnchor.constraint(equalTo: messageText.trailingAnchor, constant: UIConstants.edge),
            dateLabel.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor, constant: -UIConstants.edge),
            messageText.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor, constant: UIConstants.edge),
            messageText.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor, constant: -UIConstants.edge),
            messageText.topAnchor.constraint(equalTo: messageBubble.topAnchor, constant: UIConstants.edge)
        ])
    }
}

//MARK: ConversationViewCell + ConfigurableViewProtocol
extension ConversationViewCell: ConfigurableViewProtocol {
    
    func configure(with model: MessageCellModel) {
        if model.myMessage {
            messageBubble.backgroundColor = .systemBlue
            dateLabel.textColor = .systemGray5
            messageText.textColor = .white
            messageText.text = model.text
        } else {
            dateLabel.textColor = .white
            messageText.textColor = .black
            messageBubble.backgroundColor = .systemGray5
            messageText.text = model.text
        }
        
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        dateLabel.text = format.string(from: model.date)
    }
}
