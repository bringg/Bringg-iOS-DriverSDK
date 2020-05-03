//
//  NotLoggedInView.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(notLoggedInLabel)

        notLoggedInLabel.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        })
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
