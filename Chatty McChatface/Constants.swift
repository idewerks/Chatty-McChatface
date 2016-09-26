//
//  Constants.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 5/31/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

struct Constants {
  
  struct NotificationKeys {
    static let SignedIn = "onSignInCompleted"
  }
  
  struct Segues {
    static let SignInToFp = "SignInToFP"
    static let FpToSignIn = "FPToSignIn"
  }
  
  struct MessageFields {
    static let senderId = "senderId"
    static let name = "name"
    static let text = "text"
    static let avatarUrl = "avatarUrl"
    static let imageUrl = "imageUrl"
    static let dateSent = "dateSent"
    static let messageLat = "messageLat"
    static let messageLon = "messageLon"
    
  }
}