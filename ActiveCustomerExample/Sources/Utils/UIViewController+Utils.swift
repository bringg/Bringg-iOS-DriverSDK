//
//  UIViewController+Utils.swift
//  BringgActiveCustomerSDKExample
//
//

import BringgDriverSDK
import UIKit

extension UIViewController {
    func showError(_ error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func showMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
