//
//  Utilities.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 6/3/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import Foundation
import UIKit
// Put this piece of code anywhere you like
extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
}