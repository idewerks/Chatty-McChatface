//
//  MapViewController.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 7/14/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MapViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
  
  
  @IBOutlet weak var chattyMap: MKMapView!
  var locationManager: CLLocationManager!
  
  override func viewDidLoad() {
        super.viewDidLoad()
    if (CLLocationManager.locationServicesEnabled())
    {
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestAlwaysAuthorization()
      locationManager.startUpdatingLocation()
    }
  }
  
  override func viewWillAppear(animated : Bool) {
    if let tbc = self.tabBarController as? MessagesTabController {
      updatePinAnnotation(tbc.myMessages!)
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
  
  override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
      locationManager.stopUpdatingLocation()
    }
  
  
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location = locations.last! as CLLocation
    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    self.chattyMap.showsUserLocation = true
    self.chattyMap.setRegion(region, animated: true)
    self.chattyMap.zoomEnabled = true
  }

  
  
  func updatePinAnnotation(pinMessage: [FIRDataSnapshot]!)  {
    
    for index in 0..<pinMessage.count //iterate through each message
  {
    //convert FIRDataSnapshot object to String:Anyobject dictionary
      if let snapLocation = pinMessage[index].value as? [String : String] {
        /*print(snapLocation)
        print(snapLocation["name"]!)
        print(snapLocation["dateSent"]!)
        print(snapLocation["avatarUrl"]!)
        print(snapLocation["text"]!)
        print(snapLocation["messageLat"]!)
        print(snapLocation["messageLon"]!)*/
      
      let annotation = MKPointAnnotation()
      annotation.title = snapLocation["name"]!//"blank title"
      annotation.subtitle = "blank subtitle"
      let coordlat = Double(snapLocation["messageLat"]!)
      let coordlong = Double(snapLocation["messageLon"]!)
     
     annotation.coordinate = CLLocationCoordinate2D(latitude: coordlat!, longitude: coordlong!)
    chattyMap.addAnnotation(annotation)
      
      }
    }
  }
}
