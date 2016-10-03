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
  
  if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
    CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
    
    
    //I hacked this to make sure location data is valid
    //need to clean this up
    //repeat until valid data is present
    repeat {
    currentLocation = locManager.location
    } while locManager.location == nil
    
    
    
    
    locManager.stopUpdatingLocation()
  }else {
  print("Error- Location Authorization Failure")
  }
  return currentLocation
  }
