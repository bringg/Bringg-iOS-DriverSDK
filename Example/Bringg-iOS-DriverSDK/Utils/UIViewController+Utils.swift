//
//  UIViewController+Utils.swift
//  BringgDriverSDKExampleApp
//
//  Created by Michael Tzach on 07/03/2018.
//  Copyright © 2018 Bringg. All rights reserved.
//

import UIKit
import BringgDriverSDK

extension UIViewController {
    func showError(_ error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showMerchantList(_ merchantList: [Merchant], merchantChosen: @escaping ((Int)->Void)) {
        let alertController = UIAlertController(title: "Merchants", message: nil, preferredStyle: .actionSheet)
        
        for merchant in merchantList {
            let merchantAction = UIAlertAction(title: merchant.name, style: .default, handler: { (action) in
                merchantChosen(merchant.id)
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(merchantAction)
        }
        
        let doneAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
