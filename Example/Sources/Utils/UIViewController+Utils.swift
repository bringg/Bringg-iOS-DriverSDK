//
//  UIViewController+Utils.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
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

    func showMerchantList(_ merchantList: [MerchantSelection], merchantChosen: @escaping ((Int) -> Void)) {
        let alertController = UIAlertController(title: "Merchants", message: nil, preferredStyle: .actionSheet)

        for merchant in merchantList {
            let merchantAction = UIAlertAction(title: merchant.name, style: .default, handler: { _ in
                merchantChosen(merchant.id)
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(merchantAction)
        }

        let doneAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
