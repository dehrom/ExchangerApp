import SnapKit
import UIKit

extension RatesCell {
    struct Appearance {
        var imageEdgeLength: CGFloat = 40
        var generalOffset: CGFloat = 6
        var selectedColor: UIColor = .black
        var normalColor: UIColor = .lightGray
        var amountFieldWidthMultiplier: CGFloat = 0.25
    }
}

class RatesCell: UITableViewCell {

    // MARK: - Properties

    let appearance: Appearance = Appearance()

    // MARK: - Views

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
        view.font = UIFont.boldSystemFont(ofSize: 16)
        view.textColor = UIColor.black
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = UIFont.boldSystemFont(ofSize: 12)
        view.textColor = UIColor.lightGray.withAlphaComponent(0.6)
        return view
    }()

    private(set) lazy var amountField: UITextField = {
        let view = UITextField()
        view.keyboardType = .decimalPad
        view.textAlignment = .right
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
            make.width.greaterThanOrEqualTo(snp.width).multipliedBy(appearance.amountFieldWidthMultiplier).priority(.medium)
            make.left.greaterThanOrEqualTo(snp.centerX).priority(.high)
            make.centerY.equalToSuperview()
        }
    }
}
