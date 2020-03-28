import UIKit
import Photos

final class MediaAssetCell: UICollectionViewCell {

    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = traitCollection.horizontalSizeClass == .regular ? .scaleAspectFit : .scaleAspectFill
        return view
    }()

    private(set) weak var asset: PHAsset?
    private(set) var onReuse: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepare() {
        contentView.layoutMargins = .zero
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            imageView.leadingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.contentMode = traitCollection.horizontalSizeClass == .regular ? .scaleAspectFit : .scaleAspectFill
    }

    func prepareAsset(_ asset: PHAsset, onReuse: @escaping () -> Void) {
        self.asset = asset
        self.onReuse = onReuse
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()

        imageView.image = nil
        asset = nil
        onReuse = nil
    }

    deinit {
        onReuse = nil
    }

}
