import UIKit

enum Section: Hashable, CaseIterable {
    case online
    case offline
}

class ConvListDataSource: UITableViewDiffableDataSource<Section, ConversationListModel> {
    
    //MARK: - Initializer
    init(tableView: UITableView, themeService: ThemeServiceProtocol) {
        super.init(tableView: tableView) { tableView, indexPath, user in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConverstionListCell.identifier, for: indexPath) as? ConverstionListCell else { return UITableViewCell()}
            
            let onlineUsersCount = tableView.numberOfRows(inSection: 0)
            let historyUsersCount = tableView.numberOfRows(inSection: 1)
            
            if indexPath == [0, onlineUsersCount - 1] {
                cell.removeSeparator()
            } else if indexPath == [1, historyUsersCount - 1] {
                cell.removeSeparator()
            }
            cell.configureTheme(theme: themeService)
            cell.configure(with: user)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "ONLINE"
        case 1:
            return "HISTORY"
        default:
            return nil
        }
    }
}
