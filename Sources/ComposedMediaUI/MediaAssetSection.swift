import UIKit
import Photos
import Composed
import ComposedUI
import ComposedMedia
import ComposedLayouts

open class MediaAssetSection: MediaSection<PHAsset> {

    private let configuration: Configuration
    private let imageManager: PHCachingImageManager
    public private(set) var allowsMultipleSelection: Bool = false

    private lazy var metrics: CollectionFlowLayoutMetrics = .init()

    public init(fetchResult: PHFetchResult<PHAsset>, configuration: Configuration = .init(), imageManager: PHCachingImageManager? = nil) {
        self.configuration = configuration
        self.imageManager = imageManager ?? .init()
        super.init(fetchResult: fetchResult)
    }

}

extension MediaAssetSection {

    public struct Configuration {

        public var options: PHImageRequestOptions?
        public var contentMode: PHImageContentMode = .aspectFill
        public var preferredThumbnailSize: CGSize = .init(width: 320, height: 320)

        static var `default`: Configuration {
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.resizeMode = .fast

            var config = Configuration()
            config.options = options
            config.contentMode = UIDevice.current.userInterfaceIdiom == .pad
                ? .aspectFit
                : .aspectFill
            return config
        }

        public init() { }

    }

}

extension MediaAssetSection: CollectionSectionProvider {

    public func section(with traitCollection: UITraitCollection) -> CollectionSection {
        let cell = CollectionCellElement(section: self, dequeueMethod: .fromClass(MediaAssetCell.self), configure: { cell, index, section in
            let config = section.configuration
            let asset = section.element(at: index)

            let imageRequestId = section.imageManager.requestImage(for: asset, targetSize: config.preferredThumbnailSize, contentMode: config.contentMode, options: config.options) { image, userInfo in
                guard cell.asset?.localIdentifier == asset.localIdentifier else { return }

                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }

            cell.prepareAsset(asset, onReuse: {
                section.imageManager.cancelImageRequest(imageRequestId)
            })
        })

        return CollectionSection(section: self, cell: cell)
    }

}

extension MediaAssetSection {

    private func columnCount(for contentSize: CGSize, traitCollection: UITraitCollection) -> Int {
        var multiplier: CGFloat = 1
        if traitCollection.preferredContentSizeCategory > .extraExtraExtraLarge {
            multiplier = 0.75
        }

        let prefersLargerContent = traitCollection.userInterfaceIdiom == .pad
            ? contentSize.width > UIScreen.main.bounds.width / 2
            : UIScreen.main.nativeBounds.width > UIScreen.main.nativeBounds.height
        
        let preferredWidth: CGFloat = prefersLargerContent ? 190 : 120
        let count = Int(floor(contentSize.width / preferredWidth * multiplier))

        return count
    }

    private func spacing(for contentSize: CGSize, traitCollection: UITraitCollection) -> CGFloat {
        return traitCollection.horizontalSizeClass == .compact ? 1 : 10
    }

    private func inset(for contentSize: CGSize, traitCollection: UITraitCollection) -> CGFloat {
        return traitCollection.horizontalSizeClass == .compact ? 0 : 1
    }

}

@available(iOS 13.0, *)
extension MediaAssetSection: CompositionalLayoutHandler {

    public func compositionalLayoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let count = columnCount(for: environment.container.contentSize, traitCollection: environment.traitCollection)
        let spacing = self.spacing(for: environment.container.contentSize, traitCollection: environment.traitCollection)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1 / CGFloat(count)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: count)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        
        let inset = self.inset(for: environment.container.contentSize, traitCollection: environment.traitCollection)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

        return section
    }

}

extension MediaAssetSection: CollectionFlowLayoutHandler {

    public func layoutMetrics(suggested: CollectionFlowLayoutMetrics, environment: CollectionFlowLayoutEnvironment) -> CollectionFlowLayoutMetrics {
        let spacing = self.spacing(for: environment.contentSize, traitCollection: environment.traitCollection)
        var metrics = CollectionFlowLayoutMetrics()
        metrics.minimumLineSpacing = spacing
        metrics.minimumInteritemSpacing = spacing
        metrics.contentInsets = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        return metrics
    }

    public func sizingStrategy(at index: Int, metrics: CollectionFlowLayoutMetrics, environment: CollectionFlowLayoutEnvironment) -> CollectionFlowLayoutSizingStrategy? {
        let columnCount = self.columnCount(for: environment.contentSize, traitCollection: environment.traitCollection)
        return CollectionFlowLayoutSizingStrategy(prototype: nil, columnCount: columnCount, sizingMode: .aspect(ratio: 1), metrics: metrics)
    }

}

extension MediaAssetSection: CollectionSelectionHandler {
    public func didSelect(at index: Int) { }
}

extension MediaAssetSection: CollectionEditingHandler {

    public func didSetEditing(_ editing: Bool) {
        allowsMultipleSelection = editing
    }

    public func setEditing(_ editing: Bool, at index: Int, cell: UICollectionViewCell, animated: Bool) {
        guard let cell = cell as? MediaAssetCell else { return }
        cell.isEditing = editing
    }

}
