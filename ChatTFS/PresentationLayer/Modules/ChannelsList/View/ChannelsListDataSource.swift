import UIKit

class ChannelsListDataSource: UITableViewDiffableDataSource<Int, UUID> {
    
    // MARK: - Initialization
    
    init(tableView: UITableView, themeService: ThemeServiceProtocol, cellModels: [ChannelModel]) {
        
        self.cellModels = cellModels
        
        super.init(tableView: tableView) { tableView, indexPath, idCell in

            guard let model = cellModels.first(where: { $0.uuid == idCell }),
                let cell = tableView.dequeueReusableCell(withIdentifier: ChannelListCell.identifier, for: indexPath) as? ChannelListCell
            else {
                return ChannelListCell()
            }
            
            cell.configureTheme(theme: themeService)

            cell.configure(with: model)
            
            return cell
        }

        self.defaultRowAnimation = .fade
        
    }
    
    // MARK: - Public properties
    
    var cellModels: [ChannelModel]
    
    // MARK: - Public methods
    
    func reload(channels: [ChannelModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        let ids = channels.map { $0.uuid }
        snapshot.appendItems(ids, toSection: 0)
        apply(snapshot, animatingDifferences: animated)
    }
    
    func addChannel(channel: ChannelModel) {
        var snapshot = snapshot()
        snapshot.appendItems([channel.uuid], toSection: 0)
        apply(snapshot)
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
        guard let item = snapshot.itemIdentifiers.first(where: { $0 == channel.uuid })
        else {
            return
        }
        snapshot.reloadItems([item])
        apply(snapshot, animatingDifferences: true)
    }
}
