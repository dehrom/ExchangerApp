import UIKit

extension AmountTextField {
    struct Appearance {
        var normalColor = UIColor.lightGray.withAlphaComponent(0.6)
        var selectedColor = UIColor.black
        var lineHeight: CGFloat = 2
    }
}

class AmountTextField: UITextField {
    private let appearance: Appearance
    
    private lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        lineView.isUserInteractionEnabled = false
        lineView.frame.size.height = appearance.lineHeight
        lineView.backgroundColor = appearance.normalColor
        return lineView
    }()
    
    init(appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: .zero)
        addSubview(lineView)
        textColor = appearance.normalColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleColors() {
        if isFirstResponder {
            lineView.backgroundColor = appearance.selectedColor
            textColor = appearance.selectedColor
        } else {
            lineView.backgroundColor = appearance.normalColor
            textColor = appearance.normalColor
        }
    }
}

