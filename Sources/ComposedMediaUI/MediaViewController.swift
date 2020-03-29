import UIKit
import Photos
import Composed
import ComposedUI
import ComposedLayouts
import ComposedMedia

open class MediaViewController: UIViewController {

    open private(set) lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    open private(set) var collectionCoordinator: CollectionCoordinator?
    private lazy var imageManager: PHCachingImageManager = {
        let manager = PHCachingImageManager()
        manager.allowsCachingHighQualityImages = false
        return manager
    }()

    private lazy var layout: UICollectionViewLayout = {
        if #available(iOS 13.0, *) {
            return UICollectionViewCompositionalLayout { [weak self] index, environment in
                guard let coordinator = self?.collectionCoordinator,
                    coordinator.sectionProvider.sections.indices.contains(index),
                    let section = coordinator.sectionProvider.sections[index] as? CompositionalLayoutHandler else { return nil }
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

        let provider = ComposedSectionProvider()
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]

        provider.append(MediaAssetSection(fetchResult: PHAsset.fetchAssets(with: options), imageManager: imageManager))
        collectionCoordinator = CollectionCoordinator(collectionView: collectionView, sectionProvider: provider)
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        imageManager.stopCachingImagesForAllAssets()

        if layout is UICollectionViewFlowLayout {
            collectionCoordinator?.invalidateLayout()
        }
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        imageManager.stopCachingImagesForAllAssets()
    }

}
