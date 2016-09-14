//
//  Appstate.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 5/31/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import Foundation
class AppState: NSObject {
  
  static let sharedInstance = AppState()
  
  var signedIn = false
  var displayName: String?
  var avatarUrl: NSURL?
  var imageUrl: NSURL?
  var dateSent: String?
  //var messageLat: String?
  //var messageLon: String?
  
}
