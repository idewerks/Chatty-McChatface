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
    }else{
      print("Location Services Disabled")
    }
  }
  
  override func viewWillAppear(_ animated : Bool) {
    if let tbc = self.tabBarController as? MessagesTabController {
      updatePinAnnotation(tbc.myMessages!)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
  
  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      locationManager.stopUpdatingLocation()
    }
  
  
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location = locations.last! as CLLocation
    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
    self.chattyMap.showsUserLocation = true
    self.chattyMap.setRegion(region, animated: true)
    self.chattyMap.isZoomEnabled = true
  }
  
  func updatePinAnnotation(_ pinMessage: [FIRDataSnapshot]!)  {
    print (pinMessage.count)
    for index in 0..<pinMessage.count //iterate through each message
  {
    
    print(index)
    //convert FIRDataSnapshot object to String:Anyobject dictionary
      if let snapLocation = pinMessage[index].value as? [String : String] {
        
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
