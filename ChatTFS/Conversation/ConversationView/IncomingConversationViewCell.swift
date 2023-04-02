import UIKit

class IncomingConversationViewCell: UITableViewCell {
    static let identifier = String(describing: IncomingConversationViewCell.self)
    
    // MARK: - UIConstants
    
    private enum UIConstants {
        static let edge: CGFloat = 12
        static let edgeVertical: CGFloat = 8
        static let edgeToTable: CGFloat = 10
        static let cornerRadius: CGFloat = 16
        static let fontSizeDate: CGFloat = 10
    }
    
    // MARK: - Private
    
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
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        messageText.text = nil
        dateLabel.text = nil
    }
    
    // MARK: - SetupUI
    
    func setupUI() {
        contentView.addSubview(messageBubble)
        messageBubble.addSubviews(messageText, dateLabel)
        
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
            messageText.topAnchor.constraint(equalTo: messageBubble.topAnchor, constant: UIConstants.edgeVertical),
            messageBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.edgeToTable)
        ])
    }
}

// MARK: - ConversationViewCell + ConfigurableViewProtocol

extension IncomingConversationViewCell: ConfigurableViewProtocol {
    func configure(with model: MessageCellModel) {
        messageText.text = model.text
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        dateLabel.text = format.string(from: model.date)
    }
    
    func configureTheme(theme: ThemeServiceProtocol) {
        messageText.textColor = theme.currentTheme.incomingTextColor
        dateLabel.textColor = theme.currentTheme.incomingTextColor
        messageBubble.backgroundColor = theme.currentTheme.incomingBubbleColor
        contentView.backgroundColor = theme.currentTheme.backgroundColor
    }
}
