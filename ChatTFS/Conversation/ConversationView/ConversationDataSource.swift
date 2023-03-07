//
//  TableDataSource.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

class ConversationDataSource: UITableViewDiffableDataSource<Dates, Message> {
    
    init(tableView: UITableView, messages: [MessageCellModel]) {
        super.init(tableView: tableView) {
            tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationViewCell.identifier, for: indexPath) as? ConversationViewCell else { return UITableViewCell()}
            
            cell.configure(with: messages[indexPath.section])
            
            return cell
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Date 1"
        case 1:
            return "Date 2"
        case 2:
            return "Date 3"
        default:
            return ""
        }
    }
}
