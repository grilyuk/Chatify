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
            if message.myMessage {
                guard let outgoingMessage = tableView.dequeueReusableCell(withIdentifier: OutgoingConversationViewCell.identifier, for: indexPath) as? OutgoingConversationViewCell else { return UITableViewCell() }
                outgoingMessage.configure(with: message)
                return outgoingMessage
            } else {
                guard let incomingMessage = tableView.dequeueReusableCell(withIdentifier: IncomingConversationViewCell.identifier, for: indexPath) as? IncomingConversationViewCell else { return UITableViewCell() }
                incomingMessage.configure(with: message)
                return incomingMessage
            }
        }
    }
}
