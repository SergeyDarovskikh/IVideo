//
//  UIButton+.swift
//  IVideo
//
//  Created by Сергей Даровских on 08.03.2022.
//

import UIKit

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 111111
        if show {
            self.isEnabled = false
            let indicator = UIActivityIndicatorView()
            indicator.color = .white
            let buttonHeight = self.bounds.size.height
            indicator.center = CGPoint(x: self.bounds.maxX - 28, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}
