import UIKit

class ChannelsListDataSource: UITableViewDiffableDataSource<Int, ChannelModel> {
    
    // MARK: - Initialization
    
    init(tableView: UITableView, themeService: ThemeServiceProtocol) {
        super.init(tableView: tableView) {tableView, indexPath, itemIdentifier in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChannelListCell.identifier, for: indexPath) as? ChannelListCell
            else {
                return ChannelListCell()
            }
            
            cell.configureTheme(theme: themeService)
            cell.configure(with: itemIdentifier)
            
            return cell
        }

        self.defaultRowAnimation = .fade
        
    }
    
    // MARK: - Public methods
    
    func reload(channels: [ChannelModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(channels, toSection: 0)
        apply(snapshot, animatingDifferences: animated)
    }
    
    func updateColorsCells(animated: Bool = false) {
        var snapshot = snapshot()
        snapshot.itemIdentifiers.forEach { item in
            snapshot.reloadItems([item])
        }
        apply(snapshot, animatingDifferences: animated)
    }
    
    func updateCell(with channel: ChannelModel) {
        var snapshot = self.snapshot()
        guard let item = snapshot.itemIdentifiers.first(where: { $0.channelID == channel.channelID }) else {
            return
        }
        snapshot.reloadItems([item])
        apply(snapshot, animatingDifferences: true)
    }
}
