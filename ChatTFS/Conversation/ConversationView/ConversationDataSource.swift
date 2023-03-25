import UIKit

class ConversationDataSource: UITableViewDiffableDataSource<Date, MessageCellModel> {
    
    //MARK: - Initializer
    init(tableView: UITableView, themeService: ThemeServiceProtocol) {
        super.init(tableView: tableView) { tableView, indexPath, message in
            
            if message.myMessage {
                guard let outgoingMessage = tableView.dequeueReusableCell(withIdentifier: OutgoingConversationViewCell.identifier, for: indexPath) as? OutgoingConversationViewCell else { return UITableViewCell() }
                outgoingMessage.configureTheme(theme: themeService)
                outgoingMessage.configure(with: message)
                return outgoingMessage
            } else {
                guard let incomingMessage = tableView.dequeueReusableCell(withIdentifier: IncomingConversationViewCell.identifier, for: indexPath) as? IncomingConversationViewCell else { return UITableViewCell() }
                incomingMessage.configureTheme(theme: themeService)
                incomingMessage.configure(with: message)
                return incomingMessage
            }
        }
    }
}
