import UIKit

class ChannelDataSource: UITableViewDiffableDataSource<Date, UUID> {
    
    init(tableView: UITableView, themeService: ThemeServiceProtocol, view: ChannelViewProtocol) {
        self.view = view
        self.themeService = themeService
        
        super.init(tableView: tableView) { tableView, indexPath, uuid in
            guard let model = view.messages.first(where: { $0.uuid == uuid }) else {
                return UITableViewCell()
            }
            
            switch model.myMessage {
            case true:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OutgoingChannelViewCell.identifier,
                                                               for: indexPath) as? OutgoingChannelViewCell else {
                    return UITableViewCell()
                }
                cell.configureTheme(theme: themeService)
                cell.configure(with: model)
                return cell
            case false:
                switch model.isSameUser {
                case true:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: SameIncomingChannelViewCell.identifier,
                                                                   for: indexPath) as? SameIncomingChannelViewCell else {
                        return UITableViewCell()
                    }
                    cell.configureTheme(theme: themeService)
                    cell.configure(with: model)
                    return cell
                case false:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: IncomingChannelViewCell.identifier,
                                                                   for: indexPath) as? IncomingChannelViewCell else {
                        return UITableViewCell()
                    }
                    cell.configureTheme(theme: themeService)
                    cell.configure(with: model)
                    return cell
                }
            }
        }
    }
    
    weak var view: ChannelViewProtocol?
    weak var themeService: ThemeServiceProtocol?
    
    func setupSnapshot() {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let groupedMessages = Dictionary(grouping: view?.messages ?? [], by: { Calendar.current.startOfDay(for: $0.date) })
        let sortedDates = groupedMessages.keys.sorted()

        for date in sortedDates {
            var messages = groupedMessages[date] ?? []
            view?.titlesSections.append(formatter.string(from: date))
            messages.sort { $0.date < $1.date }
            snapshot.appendSections([date])
            snapshot.appendItems(messages.map({ $0.uuid }))
        }
        apply(snapshot)
    }
    
    func addMessage(message: MessageModel) {
        var snapshot = snapshot()
        if snapshot.numberOfSections == 0 {
            snapshot.appendSections([message.date])
            snapshot.appendItems([message.uuid])
        } else {
            snapshot.appendItems([message.uuid])
        }
        apply(snapshot)
    }
    
    func updateImage(id: UUID) {
        var snapshot = snapshot()
        if id == snapshot.itemIdentifiers.first(where: { $0 == id }) {
            snapshot.reloadItems([id])
        }
        apply(snapshot)
    }
}
