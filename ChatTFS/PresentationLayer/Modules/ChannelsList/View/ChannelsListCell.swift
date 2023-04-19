import UIKit

protocol ConfigurableViewProtocol {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}

final class ChannelListCell: UITableViewCell {
    
    // MARK: - Initializater
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    static let identifier = String(describing: ChannelListCell.self)

    // MARK: - UIConstants
    
    private enum UIConstants {
        static let avatarToContentEdge: CGFloat = 5
        static let avatarSize: CGFloat = 60
        static let nameTopToContentTop: CGFloat = 17
        static let nameLabelFontSize: CGFloat = 16
        static let lastMessageFontSize: CGFloat = 15
        static let dateLabelFontSize: CGFloat = 15
        static let channelNameFontSize: CGFloat = 17
        static let meesageBottomToContentBottom: CGFloat = -17
        static let dateLabelToContentEdge: CGFloat = -5
        static let avatarToName: CGFloat = 10
        static let avatarToMessage: CGFloat = 10
        static let indicatorToContentTrailing: CGFloat = -10
        static let nameLabelToEdge: CGFloat = -65
    }
    
    // MARK: - Subviews
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.nameLabelFontSize, weight: .bold)
        return label
    }()
    
    private lazy var chevronIndicator: UIImageView = {
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
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.dateLabelFontSize, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private lazy var userAvatar: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                  width: UIConstants.avatarSize,
                                                  height: UIConstants.avatarSize))
        imageView.layer.cornerRadius = UIConstants.avatarSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 1))
        view.backgroundColor = .systemGray5
        return view
    }()
    
    // MARK: - Public methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userAvatar.image = nil
        nameLabel.text = nil
        lastMessageText.text = nil
        dateLabel.text = nil
        lastMessageText.font = .systemFont(ofSize: UIConstants.lastMessageFontSize)
    }
    
    // MARK: - Private methods
    
    private func setDateLabel(date: Date) {
        let nowDate = Date()
        let formatterNow = DateFormatter()
        formatterNow.dateFormat = "dd:MM:yyyy"
        let actualDate = formatterNow.string(from: nowDate)
        
        if formatterNow.string(from: date) == actualDate {
            let formatterToday = DateFormatter()
            formatterToday.dateFormat = "HH:mm"
            dateLabel.text = formatterToday.string(from: date)
        } else if formatterNow.string(from: date) != actualDate {
            let formatterNotToday = DateFormatter()
            formatterNotToday.locale = Locale(identifier: "en_US_POSIX")
            formatterNotToday.dateFormat = "dd, MMM"
            dateLabel.text = formatterNotToday.string(from: date)
        }
    }
    
    private func setNameLabel(rowName: String) {
        let trimmedNameLabel = rowName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedNameLabel == "" {
            nameLabel.text = "No name channel"
            nameLabel.font = .systemFont(ofSize: UIConstants.nameLabelFontSize, weight: .light)
        } else {
            nameLabel.text = trimmedNameLabel
            nameLabel.font = .systemFont(ofSize: UIConstants.nameLabelFontSize, weight: .semibold)
        }
    }
    
    private func setLastMessage(message: String?) {
        if message == nil {
            dateLabel.text = nil
            lastMessageText.font = .italicSystemFont(ofSize: UIConstants.lastMessageFontSize)
            lastMessageText.text = "No messages yet"
        } else {
            lastMessageText.text = message
        }
    }
    
    private func setOnlineIndicator(isOnline: Bool) {
        if isOnline == false {
            onlineIndicator.removeFromSuperview()
        } else {
            contentView.addSubview(onlineIndicator)
            onlineIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                onlineIndicator.topAnchor.constraint(equalTo: userAvatar.topAnchor),
                onlineIndicator.trailingAnchor.constraint(equalTo: userAvatar.trailingAnchor)
            ])
        }
    }
    
    private func setupUI() {
        contentView.addSubviews(userAvatar, nameLabel, lastMessageText, dateLabel, chevronIndicator, separatorLine)
        
        userAvatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageText.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronIndicator.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userAvatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userAvatar.heightAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            userAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.avatarToContentEdge),
            userAvatar.widthAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.nameTopToContentTop),
            nameLabel.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: UIConstants.avatarToName),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UIConstants.nameLabelToEdge),
            
            lastMessageText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: UIConstants.meesageBottomToContentBottom),
            lastMessageText.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: UIConstants.avatarToMessage),
            lastMessageText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            chevronIndicator.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            chevronIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UIConstants.indicatorToContentTrailing),
            
            dateLabel.trailingAnchor.constraint(equalTo: chevronIndicator.leadingAnchor, constant: UIConstants.dateLabelToContentEdge),
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

// MARK: - ChannelListCell + ConfigurableViewProtocol

extension ChannelListCell: ConfigurableViewProtocol {
    
    func configure(with model: ChannelModel) {
        setLastMessage(message: model.message)
        
        setOnlineIndicator(isOnline: model.isOnline)
        
        userAvatar.image = model.channelImage
        
        guard let name = model.name else { return }
        setNameLabel(rowName: name)
        
        guard let date = model.date else { return }
        setDateLabel(date: date)
    }
    
    func configureTheme(theme: ThemeServiceProtocol) {
        nameLabel.textColor = theme.currentTheme.textColor
        lastMessageText.textColor = theme.currentTheme.incomingTextColor
        contentView.backgroundColor = theme.currentTheme.backgroundColor
    }
}
