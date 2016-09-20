//
//  LocationHelper.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 9/13/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import Foundation
import CoreLocation



//get current location
func getMessageLocation()->CLLocation! {
 
  let locManager = CLLocationManager()
  locManager.desiredAccuracy = kCLLocationAccuracyBest
  locManager.requestAlwaysAuthorization()
  locManager.startUpdatingLocation()
  
  var currentLocation: CLLocation!
  locManager.requestWhenInUseAuthorization()
  
  if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
    CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
  
    
    
    
    currentLocation = locManager.location
    locManager.stopUpdatingLocation()
  }
  return currentLocation
}