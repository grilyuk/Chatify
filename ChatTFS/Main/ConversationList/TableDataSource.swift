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

struct User: Hashable {
    let id = UUID()
}

//MARK: DataSource
class DataSource: UITableViewDiffableDataSource<Section, User> {
    
    
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConverstionListCell.identifier, for: indexPath) as?  ConverstionListCell else {return UITableViewCell()}
            
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
