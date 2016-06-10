//
//  FCViewController.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 5/31/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import Photos
import UIKit

import FirebaseAuth
import FirebaseCrash
import FirebaseDatabase
import FirebaseRemoteConfig
import FirebaseStorage
import GoogleMobileAds

/**
 * AdMob ad unit IDs are not currently stored inside the google-services.plist file. Developers
 * using AdMob can store them as custom values in another plist, or simply use constants. Note that
 * these ad units are configured to return only test ads, and should not be used outside this sample.
 */
let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

@objc(FCViewController)
class FCViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  //@IBOutlet weak var CellTitleText: UILabel!
  //@IBOutlet weak var CellMessageText: UILabel!
 
  // Instance variables
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sendButton: UIButton!
  var ref: FIRDatabaseReference!
  var messages: [FIRDataSnapshot]! = []
  var msglength: NSNumber = 128
  private var _refHandle: FIRDatabaseHandle!
  
  var storageRef: FIRStorageReference!
  var remoteConfig: FIRRemoteConfig!
  
  @IBOutlet weak var banner: GADBannerView!
  @IBOutlet weak var clientTable: UITableView!
 /// @IBOutlet weak var ClientCell: UITableViewCell!
  
  //@IBOutlet var ClientCell: [UITableViewCell]!
  
  //@IBOutlet weak var ClientCell: UITableViewCell!
  
   //___________________________________________________________________________________________
  @IBAction func didSendMessage(sender: UIButton) {
    textFieldShouldReturn(textField)
    textField.text=""//clear the text box
    dismissKeyboard() //hide the keyboard
    //
    
    //self.scrollToLastRow()
  }
   //___________________________________________________________________________________________
  @IBAction func didPressCrash(sender: AnyObject) {
    FIRCrashMessage("Cause Crash button clicked")
  }
   //___________________________________________________________________________________________
  @IBAction func didPressFreshConfig(sender: AnyObject) {
    fetchConfig()
  }
  
  
   //___________________________________________________________________________________________
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = FIRDatabase.database().reference()
    
    remoteConfig = FIRRemoteConfig.remoteConfig()
    // Create Remote Config Setting to enable developer mode.
    // Fetching configs from the server is normally limited to 5 requests per hour.
    // Enabling developer mode allows many more requests to be made per hour, so developers
    // can test different config values during development.
    let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
    remoteConfig.configSettings = remoteConfigSettings!
    
    loadAd()
    //self.clientTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
  //----------------added
    
    
   // self.clientTable.estimatedRowHeight = 80
    //self.clientTable.rowHeight = UITableViewAutomaticDimension
    
    //self.clientTable.setNeedsLayout()
    //self.clientTable.layoutIfNeeded()
    
    //self.clientTable.contentInset = UIEdgeInsetsMake(20, 0, 0, 0) // Status bar inset
    
    
    
   self.clientTable.estimatedRowHeight = 40
    self.clientTable.rowHeight = UITableViewAutomaticDimension
    
    
    
    //--------------
//    self.clientTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
    
    //self.clientTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
   
    
    fetchConfig()
    configureStorage()
    
    
   
    //-------------------need to move keyboard text box up when keyboard is showing
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FCViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FCViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    FIRCrashMessage("View loaded")
    self.hideKeyboardWhenTappedAround()
  }
  //___________________________________________________________________________________________
  
  //need a couple methods here to move keyboard
  func keyboardWillShow(sender: NSNotification) {
    self.view.frame.origin.y = -150
  }
  //___________________________________________________________________________________________
  func keyboardWillHide(sender: NSNotification) {
    self.view.frame.origin.y = 0
  }
  //--------------------------------------------------------
  func loadAd() {
    self.banner.adUnitID = kBannerAdUnitID
    self.banner.rootViewController = self
    self.banner.loadRequest(GADRequest())
  }
  //___________________________________________________________________________________________
  func fetchConfig() {
    var expirationDuration: Double = 3600
    // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
    // the server.
    if (self.remoteConfig.configSettings.isDeveloperModeEnabled) {
      expirationDuration = 0
    }
    
    // cacheExpirationSeconds is set to cacheExpiration here, indicating that any previously
    // fetched and cached config would be considered expired because it would have been fetched
    // more than cacheExpiration seconds ago. Thus the next fetch would go to the server unless
    // throttling is in progress. The default expiration duration is 43200 (12 hours).
    remoteConfig.fetchWithExpirationDuration(expirationDuration) { (status, error) in
      if (status == .Success) {
        print("Config fetched!")
        self.remoteConfig.activateFetched()
        self.msglength = self.remoteConfig["chatty_msg_length"].numberValue!
        print(" msg length config: \(self.msglength)")
      } else {
        print("Config not fetched")
        print("Error \(error)")
      }
    }
  }
   //___________________________________________________________________________________________
  func configureStorage() {
    storageRef = FIRStorage.storage().reference()
  }
   //___________________________________________________________________________________________
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    
    let newLength = text.utf16.count + string.utf16.count - range.length
    return newLength <= self.msglength.integerValue // Bool
  }
   //___________________________________________________________________________________________
  
  override func viewWillAppear(animated: Bool) {
   // self.clientTable.cell
    
    
    
    self.clientTable.estimatedRowHeight = 40
    self.clientTable.rowHeight = UITableViewAutomaticDimension
    
    
    
    self.messages.removeAll()
    self.clientTable.reloadData()    // Listen for new messages in the Firebase database
    _refHandle = self.ref.child("messages").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
      self.messages.append(snapshot)
      self.clientTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
     self.scrollToLastRow()
      
    })
  }
   //___________________________________________________________________________________________
  
  override func viewWillDisappear(animated: Bool) {
    // self.ref.removeObserverWithHandle(_refHandle)
    self.ref.child("messages").removeObserverWithHandle(_refHandle) //This fixed a bug where table view fired twice on an image add message
    
    
  }
   //___________________________________________________________________________________________
  // UITableViewDataSource protocol methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
 //___________________________________________________________________________________________
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue cell
    let cell = self.clientTable .dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
 
    // Unpack message from Firebase DataSnapshot---------------------------------------------
    let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
    let message = messageSnapshot.value as! Dictionary<String, String>
    let name = message[Constants.MessageFields.name] as String!
    // Done unpacking Firebase data ----------------------------------------------------------
    
    if let imageUrl = message[Constants.MessageFields.imageUrl] {
      
      if imageUrl.hasPrefix("gs://") {
        FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX){ (data, error) in
          if let error = error {
            print("Error downloading: \(error)")
            return
          }
          
          
      //cell.CellMessageLabel.numberOfLines=0
      //cell.CellMessageLabel.sizeToFit()
          
          cell.imageView?.image = UIImage.init(data: data!)
        }
      } else if let url = NSURL(string:imageUrl), data = NSData(contentsOfURL: url) {
        cell.imageView?.image = UIImage.init(data: data)
      }

      cell.CellMessageLabel.text = "media message"
    } else {
      let text = message[Constants.MessageFields.text] as String!
   
      
      cell.CellMessageLabel.text=text
      cell.CellTitleLabel.text = name
      
      //cell.textLabel?.text = name + ": " + text
   
      cell.imageView?.image = UIImage(named: "ic_account_circle")
      if let photoUrl = message[Constants.MessageFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
        cell.imageView?.image = UIImage(data: data)
      }
    }
   //scrollToLastRow()
    return cell
    
  }
  //-------------------------methods for autosize
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  //-----------------------------------------
  
  
  
  
  
  
  
  
  
  //___________________________________________________________________________________________
  func scrollToLastRow() {
   let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
    self.clientTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
  }

  
   //___________________________________________________________________________________________
  // UITextViewDelegate protocol methods
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    let data = [Constants.MessageFields.text: textField.text! as String]
    sendMessage(data)
    return true
  }
  
   //___________________________________________________________________________________________
  
  func sendMessage(data: [String: String]) {
    var mdata = data
    mdata[Constants.MessageFields.name] = AppState.sharedInstance.displayName
    if let photoUrl = AppState.sharedInstance.photoUrl {
      mdata[Constants.MessageFields.photoUrl] = photoUrl.absoluteString
    }
    // Push data to Firebase Database
    self.ref.child("messages").childByAutoId().setValue(mdata)
  }
  
  // MARK: - Image Picker
   //___________________________________________________________________________________________
  @IBAction func didTapAddPhoto(sender: AnyObject) {
    let picker = UIImagePickerController()
    picker.delegate = self
    if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
      picker.sourceType = .Camera
    } else {
      picker.sourceType = .PhotoLibrary
    }
    
    presentViewController(picker, animated: true, completion:nil)
  }
   //___________________________________________________________________________________________
  
  func imagePickerController(picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    picker.dismissViewControllerAnimated(true, completion:nil)
    
    let referenceUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
    let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl], options: nil)
    let asset = assets.firstObject
    asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
      let imageFile = contentEditingInput?.fullSizeImageURL
      print(Int64(NSDate.timeIntervalSinceReferenceDate() * 1000))
      
      
      //Note: Changed Int to Int64 in next line as floating to Int is > Int.max
      let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int64(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(referenceUrl.lastPathComponent!)"
      let metadata = FIRStorageMetadata()
      metadata.contentType = "image/jpeg"
      self.storageRef.child(filePath)
        .putFile(imageFile!, metadata: metadata) { (metadata, error) in
          if let error = error {
            print("Error uploading: \(error.description)")
            return
          }
          self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description])
      }
    })
  }
   //___________________________________________________________________________________________
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion:nil)
  }
   //___________________________________________________________________________________________
  
  @IBAction func signOut(sender: UIButton) {
    let firebaseAuth = FIRAuth.auth()
    do {
      try firebaseAuth?.signOut()
      AppState.sharedInstance.signedIn = false
      performSegueWithIdentifier(Constants.Segues.FpToSignIn, sender: nil)
    } catch let signOutError as NSError {
      print ("Error signing out: \(signOutError)")
    }
  }
   //___________________________________________________________________________________________
  
  func showAlert(title:String, message:String) {
    dispatch_async(dispatch_get_main_queue()) {
      let alert = UIAlertController(title: title,
                                    message: message, preferredStyle: .Alert)
      let dismissAction = UIAlertAction(title: "Dismiss", style: .Destructive, handler: nil)
      alert.addAction(dismissAction)
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  

}
class MessageCell: UITableViewCell {
  
  
  @IBOutlet weak var CellTitleLabel: UILabel!
  
  @IBOutlet weak var CellMessageLabel: UILabel!
}

