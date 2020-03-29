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

    internal var isEditing: Bool = false {
        didSet { setSelected(isSelected) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet { setSelected(isSelected) }
    }

    private func setSelected(_ selected: Bool) {
        let t = CATransition()
        t.duration = 0.1
        imageView.layer.add(t, forKey: nil)
        imageView.alpha = isEditing && selected ? 0.5 : 1
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

        setSelected(false)
    }

    deinit {
        onReuse = nil
    }

}
