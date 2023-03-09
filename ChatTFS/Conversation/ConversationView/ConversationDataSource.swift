//
//  TableDataSource.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

struct MessageCellModel: Hashable {
    let text: String
    let date: Date
    let myMessage: Bool
    let id = UUID()
}

class ConversationDataSource: UITableViewDiffableDataSource<Date, MessageCellModel> {
    
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, message in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationViewCell.identifier,
                                                           for: indexPath) as? ConversationViewCell else { return UITableViewCell() }
            
            cell.configure(with: message)
            cell.selectionStyle = .none
            return cell
        }
    }
}
