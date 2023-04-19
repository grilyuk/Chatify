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
    
    public func reload(messages: [MessageModel]) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let groupedMessages = Dictionary(grouping: messages, by: { Calendar.current.startOfDay(for: $0.date) })
        let sortedDates = groupedMessages.keys.sorted()
        
        for date in sortedDates {
            var messages = groupedMessages[date] ?? []
//            titlesSections.append(formatter.string(from: date))
            messages.sort { $0.date < $1.date }
            snapshot.appendSections([date])
            snapshot.appendItems(messages)
        }
        apply(snapshot)
    }
    
}
