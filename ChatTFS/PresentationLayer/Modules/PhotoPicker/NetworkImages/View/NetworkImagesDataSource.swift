import UIKit

class NetworkImagesDataSource: UICollectionViewDiffableDataSource<Int, NetworkImageModel> {
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NetworkImagesCell.identifier,
                                                                for: indexPath) as? NetworkImagesCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: itemIdentifier)
            
            return cell
        }
    }
    
    func reload(images: [NetworkImageModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(images, toSection: 0)
        apply(snapshot, animatingDifferences: animated)
    }
}
