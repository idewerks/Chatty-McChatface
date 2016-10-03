//
//  MeasurementHelper.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 5/31/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import Firebase

class MeasurementHelper: NSObject {
  
  static func sendLoginEvent() {
    FIRAnalytics.logEvent(withName: kFIREventLogin, parameters: nil)
  }
  
  static func sendLogoutEvent() {
    FIRAnalytics.logEvent(withName: "logout", parameters: nil)
  }
  
  static func sendMessageEvent() {
    FIRAnalytics.logEvent(withName: "message", parameters: nil)
  }
}

