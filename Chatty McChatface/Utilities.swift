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
//get current date, format it, and return a formatted date string to the caller. Returns a date string to the calling method.

func StringDate()->String {
  //returns the current date as string
  let date = Date()
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "MM-dd-yy 'at' HH:mm a"
  let dateString = dateFormatter.string(from: date)
  return dateString
}


//This function creates a circular masked image. Parameters are the original unmasked image & the new mask radius. This radius is calculated in the calling method. This is calculated by using the original imageView frame height/2 to set the clip boundaries. Sample for the calling method is let radius = Double(cell.CellLeftImage.frame.height)/2. In this case a forced cast to Double is needed for the mask function. Returns a UIImage circular masked to those boundaries.

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



//This function resizes a uiimage. Parameters are the original image and a CGSize struct containing width & height for the new image. Returns a resized UIImage. There seems to be an issue with this method with regards to auto layout in the table view- table view cell doesnt size properly

func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
  let size = image.size
  
  let widthRatio  = targetSize.width  / image.size.width
  let heightRatio = targetSize.height / image.size.height
  
  // Figure out what our orientation is, and use that to form the rectangle
  var newSize: CGSize
  if(widthRatio > heightRatio) {
    newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
  } else {
    newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
  }
  
  // This is the rect that we've calculated out and this is what is actually used below
  let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
  
  // Actually do the resizing to the rect using the ImageContext
  UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
  image.draw(in: rect)
  let newImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  return newImage!
}
