//
//  MessagesTabController.swift
//  
//
//  Created by kevin brennan on 9/20/16.
//
//

import Foundation
import UIKit
import Firebase


//This class subclasses the UITabBarController and adds messages that are updated in the FCViewController
//in the ViewWillAppear method. The parameter 'myMessages' will get its data from self.messages inside the FCViewController.
//In the MapViewController, inside viewDidLoad, the data is read from myMessages
//this allows forwarding of messages from the chat controller to the map controller
class MessagesTabController: UITabBarController {
  
  var myMessages: [FIRDataSnapshot]?
}