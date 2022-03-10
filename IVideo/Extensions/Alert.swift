//
//  Alert.swift
//  IVideo
//
//  Created by Сергей Даровских on 08.03.2022.
//

import UIKit

extension UIViewController {
    func showDefaultAlert(title: String?, message: String?, presentCompletion: (()->Void)? = nil, actionCompletion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: actionCompletion)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: presentCompletion)
    }
}
