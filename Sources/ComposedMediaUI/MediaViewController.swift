import UIKit
import Photos
import Composed
import ComposedUI
import ComposedLayouts
import ComposedMedia

public protocol MediaPickerDelegate: class {
    func mediaPicker(_ controller: MediaViewController, didPickAssets assets: [PHAsset])
    func mediaPickerWasCancelled(_ controller: MediaViewController)
}

open class MediaViewController: UIViewController {

    open var pickerDelegate: MediaPickerDelegate?

    open var allowsMultipleSelection: Bool = false {
        didSet {
            updateNavigationItems(editing: isEditing, animated: false)
        }
    }

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

    public init() {
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Media", comment: "")
        preferredContentSize = CGSize(width: 375, height: 568)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

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
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)

        let provider = ComposedSectionProvider()
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]

        provider.append(MediaAssetSection(fetchResult: PHAsset.fetchAssets(with: options), imageManager: imageManager))
        collectionCoordinator = CollectionCoordinator(collectionView: collectionView, sectionProvider: provider)

        updateNavigationItems(editing: false, animated: false)
    }

    @objc private func beginEditing(_ sender: Any?) {
        setEditing(true, animated: true)
    }

    @objc private func endEditing(_ sender: Any?) {
        setEditing(false, animated: true)
    }

    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        collectionCoordinator?.setEditing(editing, animated: animated)
        updateNavigationItems(editing: editing, animated: animated)
    }

    @objc private func open(_ sender: Any?) {
        pickerDelegate?.mediaPicker(self, didPickAssets: [])
    }

    @objc private func cancel(_ sender: Any?) {
        pickerDelegate?.mediaPickerWasCancelled(self)
    }

    private func updateNavigationItems(editing: Bool, animated: Bool) {
        switch editing {
        case false:
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancel(_:))),
                UIBarButtonItem(title: NSLocalizedString("Select", comment: ""), style: .plain, target: self, action: #selector(beginEditing(_:))),
            ]
            navigationItem.leftBarButtonItem = nil
        case true:
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing(_:))),
                UIBarButtonItem(title: NSLocalizedString("Open", comment: ""), style: .plain, target: self, action: #selector(open(_:))),
            ]

            let editingIndexes = collectionCoordinator?.sectionProvider.sections
                .compactMap { $0 as? (EditingHandler & SelectionHandler) }
                .flatMap { $0.editingIndexes } ?? []

            if (collectionView.indexPathsForSelectedItems?.count ?? 0) < editingIndexes.count {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Select All", comment: ""), style: .plain, target: self, action: #selector(performSelectAll(_:)))
            } else {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Select None", comment: ""), style: .plain, target: self, action: #selector(performDeselectAll(_:)))
            }

            navigationItem.rightBarButtonItems?.last?.isEnabled = collectionView.indexPathsForSelectedItems?.isEmpty == false
        }

        navigationItem.title = editing
            ? collectionView.indexPathsForSelectedItems?.isEmpty == true
                ? NSLocalizedString("Select Items", comment: "")
                : "\(collectionView.indexPathsForSelectedItems?.count ?? 0) \(NSLocalizedString("Selected", comment: ""))"
            : title
    }

    @objc private func performSelectAll(_ sender: Any?) {
        collectionCoordinator?.sectionProvider.sections
            .compactMap { $0 as? SelectionHandler }
            .forEach { $0.selectAll() }

        updateNavigationItems(editing: isEditing, animated: false)
    }

    @objc private func performDeselectAll(_ sender: Any?) {
        collectionCoordinator?.sectionProvider.sections
            .compactMap { $0 as? SelectionHandler }
            .forEach { $0.deselectAll() }

        updateNavigationItems(editing: isEditing, animated: false)
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if layout is UICollectionViewFlowLayout {
            collectionCoordinator?.invalidateLayout()
        }
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        imageManager.stopCachingImagesForAllAssets()
    }

}

extension MediaViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return false
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateNavigationItems(editing: isEditing, animated: false)
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateNavigationItems(editing: isEditing, animated: false)
    }

}
