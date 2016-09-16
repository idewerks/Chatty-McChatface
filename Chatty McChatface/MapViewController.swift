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



/*protocol MapViewControllerDelegate {
  
  //func getMessagesArray(messagesArray: [FIRDataSnapshot]!)
  func getMessagesArray(data: Data)
  
}*/



class MapViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
  
  //var delegate: MapViewControllerDelegate?
//  var messagesArray:[FIRDataSnapshot]?
  
  
  
  
  @IBOutlet weak var chattyMap: MKMapView!
  var locationManager: CLLocationManager!

  //var messages: [FIRDataSnapshot]! = []
  
  override func viewDidLoad() {
        super.viewDidLoad()
//print(messagesArray)
        // Do any additional setup after loading the view.
    if (CLLocationManager.locationServicesEnabled())
    {
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestAlwaysAuthorization()
      locationManager.startUpdatingLocation()
      

   /*   func getMessagesArray()->[FIRDataSnapshot!] {
        
        return messages*/
      //messages=getMessagesArray()
      
      
      
      
      
      
    }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  override func viewWillDisappear(animated: Bool) {
    
    super.viewWillDisappear(animated)
    
    //free up some resources
    locationManager.stopUpdatingLocation()  }
   // self.delegate?.getMessagesArray(messagesArray)!
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
  {
    
    let location = locations.last! as CLLocation
    
    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    self.chattyMap.showsUserLocation = true
    self.chattyMap.setRegion(region, animated: true)
  }
  
      // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
   // }
  
}
