//
//  BaseViewController.swift
//  VirtualTourist
//
//  Created by Sabrina on 6/29/19.
//  Copyright © 2019 Sabrina Svedin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: Properties
    
    var myIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up activity indicator
        myIndicator = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.gray)
        self.view.addSubview(myIndicator)
        myIndicator.bringSubviewToFront(self.view)
        myIndicator.center = self.view.center
    }
    
    // MARK: Helper functions to show and hide activity indicators

    func showActivityIndicator() {
        myIndicator.isHidden = false
        myIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        myIndicator.stopAnimating()
        myIndicator.isHidden = true
    }
    
    // MARK: Alert helper function
    
    func showAlert(message: String, title: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }

}
