import UIKit
import Composed
import ComposedUI
import ComposedLayouts

open class MediaViewController: UIViewController {

    open private(set) lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    open private(set) lazy var collectionCoordinator: CollectionCoordinator = {
        #warning("Replace with appropriate provider when available")
        let provider = ComposedSectionProvider()
        return CollectionCoordinator(collectionView: collectionView, sectionProvider: provider)
    }()

    private lazy var layout: UICollectionViewLayout = {
        let layout: UICollectionViewLayout

        if #available(iOS 13.0, *) {
            return UICollectionViewCompositionalLayout { [weak self] index, environment in
                guard let self = self,
                    self.collectionCoordinator.sectionProvider.sections.indices.contains(index),
                    let section = self.collectionCoordinator.sectionProvider.sections[index] as? CompositionalLayoutHandler else { return nil }
                return section.compositionalLayoutSection(environment: environment)
            }
        } else {
            return UICollectionViewFlowLayout()
        }
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .groupTableViewBackground
        }

        collectionView.alwaysBounceVertical = true
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }

    /// Required specifically for `UICollectionViewFlowLayout` since some rotations don't cause an invalidation!?
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionCoordinator.invalidateLayout()
    }

}
