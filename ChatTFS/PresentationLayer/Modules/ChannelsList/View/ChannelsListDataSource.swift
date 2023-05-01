import UIKit

class ChannelsListDataSource: UITableViewDiffableDataSource<Int, UUID> {

    init(tableView: UITableView, themeService: ThemeServiceProtocol, view: ChannelsListViewProtocol) {
        self.view = view
        self.themeService = themeService
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let model = view.channels.first(where: { $0.uuid == itemIdentifier }),
                  let cell = tableView.dequeueReusableCell(withIdentifier: ChannelListCell.identifier, for: indexPath) as? ChannelListCell
            else {
                return ChannelListCell()
            }
            cell.configureTheme(theme: themeService)
            cell.configure(with: model)
            return cell
        }
    }
    
    weak var view: ChannelsListViewProtocol?
    weak var themeService: ThemeServiceProtocol?
    
    func applySnapshot(channels: [ChannelModel]) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(channels.map({ $0.uuid }))
        apply(snapshot)
    }
    
    func updateColorCells(channels: [ChannelModel]) {
        var snapshot = snapshot()
        snapshot.reloadItems(channels.map({ $0.uuid }))
        apply(snapshot, animatingDifferences: false)
    }
    
    func updateCell(channel: ChannelModel) {
        if let indexOfChannels = view?.channels.firstIndex(where: { $0.uuid == channel.uuid }) {
            view?.channels[indexOfChannels] = channel
        }
        let idCell = channel.uuid
        var snapshot = snapshot()
        guard let index = snapshot.indexOfItem(idCell),
              let firstCell = snapshot.itemIdentifiers.first
        else {
            return
        }
        snapshot.reloadItems([idCell])
        if index != 0 {
            snapshot.moveItem(idCell, beforeItem: firstCell)
        }
        apply(snapshot)
    }
    
    func addChannel(channel: ChannelModel) {
        var snapshot = snapshot()
        snapshot.appendItems([channel.uuid])
        apply(snapshot)
    }
    
    func deleteChannel(channel: ChannelModel) {
        var snapshot = snapshot()
        snapshot.deleteItems([channel.uuid])
        apply(snapshot)
    }
}
