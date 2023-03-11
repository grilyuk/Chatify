//
//  TableDataSource.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 05.03.2023.
//

import UIKit

enum Section: Hashable, CaseIterable {
    case online
    case offline
}

//MARK: DataSource
class ConvListDataSource: UITableViewDiffableDataSource<Section, ConversationListCellModel> {
    
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, user in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConverstionListCell.identifier, for: indexPath) as? ConverstionListCell else { return UITableViewCell()}
            
            let onlineUsersCount = tableView.numberOfRows(inSection: 0)
            let historyUsersCount = tableView.numberOfRows(inSection: 1)
            
            if indexPath == [0, onlineUsersCount - 1] || indexPath == [0, historyUsersCount - 1] {
                cell.removeSeparator()
            }
            
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
