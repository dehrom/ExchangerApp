import SnapKit
import UIKit

extension RatesCell {
    struct Appearance {
        var imageEdgeLength: CGFloat = 40
        var cellMinWidth: CGFloat = 40
        var generalOffset: CGFloat = 6
        var selectedColor = UIColor.black
        var normalColor = UIColor.lightGray.withAlphaComponent(0.6)
        var countryTitleLabelFont = UIFont.boldSystemFont(ofSize: 16)
        var descriptionLabelFont = UIFont.boldSystemFont(ofSize: 12)
    }
}

class RatesCell: UITableViewCell {
    private let appearance: Appearance = Appearance()

    private lazy var countryImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.layer.cornerRadius = appearance.imageEdgeLength / 2
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var countryTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = appearance.countryTitleLabelFont
        view.textColor = appearance.selectedColor
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = appearance.descriptionLabelFont
        view.textColor = appearance.normalColor
        return view
    }()

    private(set) lazy var amountField: AmountTextField = {
        let view = AmountTextField()
        view.keyboardType = .decimalPad
        view.textAlignment = .right
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Initializer

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        makeConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        amountField.isUserInteractionEnabled = false
    }

    func configure(with model: Rate) {
        countryImageView.image = model.image
        countryTitleLabel.text = model.title
        descriptionLabel.text = model.subTitle
        selectionStyle = .none
        if let value = model.value {
            amountField.text = value
        } else {
            amountField.placeholder = "0.0"
        }
        amountField.sizeToFit()
    }

    // MARK: - Private methods

    private func addSubviews() {
        contentView.addSubview(countryImageView)
        contentView.addSubview(countryTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(amountField)
    }

    private func makeConstraints() {
        countryImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(appearance.generalOffset)
            make.width.height.equalTo(appearance.imageEdgeLength)
        }

        countryTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(countryImageView.snp.right).offset(appearance.generalOffset)
            make.top.equalTo(countryImageView)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(countryTitleLabel)
            make.top.equalTo(countryTitleLabel.snp.bottom).inset(appearance.generalOffset / 2)
        }

        amountField.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(appearance.generalOffset)
            make.width.equalTo(appearance.cellMinWidth).priority(.medium)
            make.left.greaterThanOrEqualTo(descriptionLabel.snp.right).offset(appearance.generalOffset).priority(.high)
            make.centerY.equalToSuperview()
        }
    }
}
