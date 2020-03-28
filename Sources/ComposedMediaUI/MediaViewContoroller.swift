import UIKit
import Composed
import ComposedUI

open class MediaViewController: UIViewController {

    @IBOutlet lazy open var collectionView: UICollectionView = {
        let layout: UICollectionViewLayout

        layout = UICollectionViewCompositionalLayout(section: NSCollectionLayoutSection(group: NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))))

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout))
    }()

}
