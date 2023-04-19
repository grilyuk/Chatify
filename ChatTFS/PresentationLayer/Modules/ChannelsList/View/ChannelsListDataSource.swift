import UIKit

final class ChannelsListDataSource: UITableViewDiffableDataSource<Int, ChannelModel> {
    
    // MARK: - Initialization
    
    init(tableView: UITableView, themeService: ThemeServiceProtocol) {
        super.init(tableView: tableView) {tableView, _, itemIdentifier in
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: ChannelListCell.identifier) as? ChannelListCell
            else {
                return ChannelListCell()
            }
            
            cell.configureTheme(theme: themeService)
            cell.configure(with: itemIdentifier)
            
            return cell
        }
    }

    public func reload(channels: [ChannelModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(channels, toSection: 0)
        apply(snapshot, animatingDifferences: animated)
    }
    
    public func updateColorsCells(animated: Bool = false) {
        var snapshot = snapshot()
        snapshot.itemIdentifiers.forEach { item in
            snapshot.reloadItems([item])
        }
        apply(snapshot, animatingDifferences: animated)
    }
}
