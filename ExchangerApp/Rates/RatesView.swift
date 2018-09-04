import SnapKit
import UIKit

class RatesView: UIView {
    private(set) lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
        view.keyboardDismissMode = .interactive
        view.backgroundColor = .white
        return view
    }()

    private lazy var errorLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textColor = UIColor.black.withAlphaComponent(0.8)
        view.font = UIFont.boldSystemFont(ofSize: 17)
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()

    init() {
        super.init(frame: .zero)
        addSubviews()
        makeConstraints()
        backgroundColor = UIColor.white
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showError(message: String?) {
        errorLabel.text = message
        errorLabel.sizeToFit()
        tableView.isHidden = true
        errorLabel.isHidden = false
    }

    func hideError() {
        errorLabel.text = nil
        tableView.isHidden = false
        errorLabel.isHidden = true
    }

    func scrollToTop() {
        tableView.scrollToRow(at: .init(item: 0, section: 0), at: .top, animated: false)
    }

    private func addSubviews() {
        addSubview(tableView)
        addSubview(errorLabel)
    }

    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        errorLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview()
        }
    }
}
