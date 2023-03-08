//
//  TableDataSource.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

class ConversationDataSource: UITableViewDiffableDataSource<DaySection, Message> {
    
    init(tableView: UITableView, messages: [MessageCellModel]) {
        super.init(tableView: tableView) {
            tableView, indexPath, itemIdentifier in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationViewCell.identifier, for: indexPath) as? ConversationViewCell else { return UITableViewCell()}
            
            cell.configure(with: messages[itemIdentifier.number])
            print("configure from \(itemIdentifier.number)")
            cell.selectionStyle = .none
            return cell
        }
    }
}
