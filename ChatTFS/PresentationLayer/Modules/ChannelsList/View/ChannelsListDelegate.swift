import UIKit

extension ChannelsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UIConstants.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idCell = dataSource.snapshot().itemIdentifiers[indexPath.row]
        guard let navigationController = navigationController,
              let channelID = channels.first(where: { $0.uuid == idCell })?.channelID
        else {
            return
        }
        presenter?.didTappedChannel(to: channelID, navigationController: navigationController)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var snapshot = dataSource.snapshot()
        let identifiers = snapshot.itemIdentifiers

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, _) in
            
            guard let self,
                  let idChannel = channels.first(where: { $0.uuid == identifiers[indexPath.item] })?.channelID
            else {
                return
            }
            self.presenter?.deleteChannel(id: idChannel)
            snapshot.deleteItems([identifiers[indexPath.row]])
            self.dataSource.apply(snapshot)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
