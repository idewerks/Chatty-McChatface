//
//  Utilities.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 6/3/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import Foundation
import UIKit



// extend the view controller- add 2 methods
// 1. Dismiss Keyboard when tapped around
// 2. dismiss the keyboard

extension UIViewController {

  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
 
  func dismissKeyboard() {
    view.endEditing(true)
  }
}
//------------------------------------------
//get current date, format it, and return a formatted date string to the caller

func StringDate()->String {
  //returns the current date as string
  let date = Date()
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "MM-dd-yy 'at' HH:mm a"
  let dateString = dateFormatter.string(from: date)
  return dateString
}



func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
  let imageView: UIImageView = UIImageView(image: image)
  var layer: CALayer = CALayer()
  layer = imageView.layer
  
  layer.masksToBounds = true
  layer.cornerRadius = CGFloat(radius)
  
  UIGraphicsBeginImageContext(imageView.bounds.size)
  layer.render(in: UIGraphicsGetCurrentContext()!)
  let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  return roundedImage!
}
