import UIKit

protocol ConfigurableViewProtocol {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}

class ConverstionListCell: UITableViewCell {
    static let identifier = "conListCell"

    //MARK: - UIConstants
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
        static let imageProfileTopColor: UIColor = #colorLiteral(red: 0.9541506171, green: 0.5699337721, blue: 0.6460854411, alpha: 1)
        static let imageProfileBottomColor: UIColor = #colorLiteral(red: 0.1823898468, green: 0.5700650811, blue: 0.6495155096, alpha: 1)
    }
    
    //MARK: - Private
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
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIConstants.avatarSize, height: UIConstants.avatarSize))
        let gradient = CAGradientLayer()
        gradient.colors = [UIConstants.imageProfileTopColor.cgColor,
                           UIConstants.imageProfileBottomColor.cgColor]
        gradient.frame = imageView.bounds
        imageView.layer.addSublayer(gradient)
        imageView.layer.cornerRadius = UIConstants.avatarSize/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var initialsLabel: UILabel = {
        let label = UILabel()
        let initialFontSizeCalc = UIConstants.avatarSize * 0.45
        let descriptor = UIFont.systemFont(ofSize: initialFontSizeCalc, weight: .semibold).fontDescriptor.withDesign(.rounded)
        label.font = UIFont(descriptor: descriptor!, size: initialFontSizeCalc)
        label.textColor = .white
        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 1))
        view.backgroundColor = .systemGray5
        return view
    }()
    
    //MARK: - Initializater
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func setInitials(from name: String) {
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: name)
        formatter.style = .abbreviated
        initialsLabel.text = formatter.string(from: components!)
    }
    
    //MARK: PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        userAvatar.image = nil
        nameLabel.text = nil
        lastMessageText.text = nil
        dateLabel.text = nil
        initialsLabel.text = nil
        lastMessageText.font = .systemFont(ofSize: UIConstants.lastMessageFontSize)
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        contentView.addSubviews(userAvatar, nameLabel, lastMessageText, dateLabel, initialsLabel, chevronIndicator, separatorLine)
        
        userAvatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageText.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronIndicator.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userAvatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userAvatar.heightAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            userAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UIConstants.avatarToContentEdge),
            userAvatar.widthAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.nameTopToContentTop),
            nameLabel.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: UIConstants.avatarToName),
            
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
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            initialsLabel.centerXAnchor.constraint(equalTo: userAvatar.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: userAvatar.centerYAnchor)
        ])
    }
}

//MARK: - ConverstionListCell + ConfigurableViewProtocol
extension ConverstionListCell: ConfigurableViewProtocol {
    func configure(with model: ConversationListModel) {
        if model.message == nil {
            dateLabel.text = nil
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
            setInitials(from: model.name ?? "Steve Jobs")
        }
        
        nameLabel.text = model.name
        
        guard let date = model.date else { return }
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
    
    func configureTheme(theme: ThemeServiceProtocol) {
        nameLabel.textColor = theme.currentTheme.textColor
        lastMessageText.textColor = theme.currentTheme.incomingTextColor
        contentView.backgroundColor = theme.currentTheme.backgroundColor
    }
}
