//
//  LocationHelper.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 9/13/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

//This method retrieves the current users location- returns a CLLocation object to caller
func getMessageLocation()->CLLocation! {
 
  let locManager = CLLocationManager()
  locManager.requestWhenInUseAuthorization()
  locManager.desiredAccuracy = kCLLocationAccuracyBest
  locManager.requestAlwaysAuthorization()
  locManager.startUpdatingLocation()
  
  var currentLocation: CLLocation!
  
  if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
    CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
    currentLocation = locManager.location
    locManager.stopUpdatingLocation()
  }else {
  print("Error- Location Authorization Failure")
  }
  return currentLocation
  }
