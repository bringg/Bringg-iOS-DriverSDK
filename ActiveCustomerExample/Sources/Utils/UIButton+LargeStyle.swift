//
//  UIButton+LargeStyle.swift
//  BringgActiveCustomerSDKExample
//
//

import UIKit

extension UIButton {
    static func createLargeStyleButton(title: String, target: Any?, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 6
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.addTarget(target, action: selector, for: .touchUpInside)
        return button
    }
}
