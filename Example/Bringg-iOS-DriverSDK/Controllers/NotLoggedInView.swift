//
//  Copyright © 2018 Bringg. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class NotLoggedInView: UIView {
    private lazy var notLoggedInLabel: UILabel = {
        let label = UILabel()
        label.text = "You are not logged in"
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        backgroundColor = .white
    }

    private func commonInit() {
        addSubview(notLoggedInLabel)

        notLoggedInLabel.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        })
    }
}
