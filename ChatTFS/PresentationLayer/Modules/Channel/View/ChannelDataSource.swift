import Foundation
import UIKit

class ChannelDataSource: UITableViewDiffableDataSource<Date, MessageModel> {
    
    // MARK: - Initialization
    
    init(tableView: UITableView, themeService: ThemeServiceProtocol) {
       
        super.init(tableView: tableView) { tableView, _, itemIdentifier in
            
            switch itemIdentifier.myMessage {
            case true:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OutgoingChannelViewCell.identifier) as? OutgoingChannelViewCell
                else {
                    return UITableViewCell()
                }
                cell.configureTheme(theme: themeService)
                cell.configure(with: itemIdentifier)
                return cell
            case false:
                switch itemIdentifier.isSameUser {
                case true:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: SameIncomingChannelViewCell.identifier) as? SameIncomingChannelViewCell
                    else {
                        return UITableViewCell()
                    }
                    cell.configureTheme(theme: themeService)
                    cell.configure(with: itemIdentifier)
                    return cell
                case false:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: IncomingChannelViewCell.identifier) as? IncomingChannelViewCell
                    else {
                        return UITableViewCell()
                    }
                    cell.configureTheme(theme: themeService)
                    cell.configure(with: itemIdentifier)
                    return cell
                }
            }
        }
    }
}
