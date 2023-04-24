import UIKit

extension UITableViewDiffableDataSource<Int, UUID> {
    
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
    
    func updateCell(channel: ChannelModel, view: ChannelsListViewController ) {
        let channels = view.channels
        if let indexOfChannels = channels.firstIndex(where: { $0.uuid == channel.uuid }) {
            view.channels[indexOfChannels] = channel
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
}
