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
  
  // Instance variables
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sendButton: UIButton!
  var ref: FIRDatabaseReference!
  var messages: [FIRDataSnapshot]! = []
  var msglength: NSNumber = 25
  private var _refHandle: FIRDatabaseHandle!
  var storageRef: FIRStorageReference!
  var remoteConfig: FIRRemoteConfig!
  @IBOutlet weak var banner: GADBannerView!
  @IBOutlet weak var clientTable: UITableView!
  
   //___________________________________________________________________________________________
  @IBAction func didSendMessage(sender: UIButton) {
    textFieldShouldReturn(textField)
    textField.text=""//clear the text box
    dismissKeyboard() //hide the keyboard
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
    self.clientTable.estimatedRowHeight = 40
    self.clientTable.rowHeight = UITableViewAutomaticDimension
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
    
    self.clientTable.estimatedRowHeight = 40
    self.clientTable.rowHeight = UITableViewAutomaticDimension
    self.messages.removeAll()
    self.clientTable.reloadData()    // Listen for new messages in the Firebase database
    
    //This fires when a new message is added
    _refHandle = self.ref.child("messages").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
    //add snapshot of next message to be appended to messages object(FIRdata snapshot object)
    self.messages.append(snapshot)
    //add another row to the clientTable (UITableView Object)
    self.clientTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
    self.scrollToLastRow()
      
    })
  }
  
  //-----------------------------------------------------------------------------------------
  func indexOfMessage(snapshot: FIRDataSnapshot) -> Int {
    var index = 0
    for  message in self.messages {
      if (snapshot.key == message.key) {
        return index
      }
      index += 1
    }
    return -1
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
        // Create a cell
    let cell = self.clientTable .dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
    
    // Unpack message from Firebase DataSnapshot---------------------------------------------
    let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
    let message = messageSnapshot.value as! Dictionary<String, String>
    let name = message[Constants.MessageFields.name] as String!
    // Done unpacking Firebase data
    //This block decodes an imageURL which is an embedded photo
    //imageUrl is the storage field used for a media(photo) item
    //photoUrl is the storage field used for avatars
    
    if let imageUrl = message[Constants.MessageFields.imageUrl] {
      //message contains an embedded image media url
      //check to see if it has a firebase storage url prefix
      
            if imageUrl.hasPrefix("gs://") {
            //get image from firebase storage
            //async method returns object or error- exits at completion of media retrieval
              
              FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX){ (data, error) in
              if let error = error {
                  print("Error downloading: \(error)")
                  return
                  }
                
            //This fires when download of image is complete
            cell.CellLeftImage?.image = UIImage.init(data: data!)
            cell.CellTitleLabel.text = name
            cell.CellMessageLabel.text="image"
            }//end get image from firebase storage
              
                  return cell
              
             //if not stored in firebase storage, retrieve image from web url
            } else
              if let url = NSURL(string:imageUrl), data = NSData(contentsOfURL: url) {
                cell.CellLeftImage?.image = UIImage.init(data: data)
            }
                cell.CellTitleLabel.text = name
                cell.CellMessageLabel.text = "media message"
      
              } else {
              //if no imageUrl field in message, treat it as a text message:
      
              let text = message[Constants.MessageFields.text] as String!
              cell.CellMessageLabel.text=text
              cell.CellTitleLabel.text = name
              cell.CellLeftImage?.image = UIImage(named: "ic_account_circle")
              if let photoUrl = message[Constants.MessageFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
                cell.CellLeftImage?.image = UIImage(data: data)
              }
            }

            return cell
          }
  //-------------------------methods for autosize
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  //-----------------------------------------
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  //-----------------------------------------
  
  //swipe to delete method
  //note this has to be done programmatically. During compilation xcode checks for existence of this method, and if available, enables swipe to delete functionality
  
   func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
      if editingStyle == .Delete {
      
        //following is a cell instance of FIRDataSnapshot
        let messageToDelete = messages[indexPath.row]
        let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, String>
        if let imageUrl = message[Constants.MessageFields.imageUrl] as String? {
      
          //check to see if message has an associated firebase storage image
            let deletionRef = FIRStorage.storage().referenceForURL(imageUrl as String)
            deletionRef.deleteWithCompletion { (error) -> Void in
            if (error != nil) {
              print("error")
              } else {
          // File deleted successfully
        }
      }//end delete with completion block
    }
  
      //remove message from firebase database
      messages.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      messageToDelete.ref.removeValue()
      self.scrollToLastRow()
        } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
      //not currently used
      }//end insert row
    }//end swipe to delete
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
   // Send Message to Firebase
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
      //picker.sourceType = .Camera
      //force temporary to library only
      picker.sourceType = .Camera
    } else {
      picker.sourceType = .PhotoLibrary
    }
    
    presentViewController(picker, animated: true, completion:nil)
  }
   //___________________________________________________________________________________________
  
  //selector for saving to photo album
  //This is functional- commenting fornow to try another approach
   /* func image(myimage: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
    if error == nil {
      let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
      ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      presentViewController(ac, animated: true, completion: nil)
    } else {
      let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
      ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      presentViewController(ac, animated: true, completion: nil)
    }
  }*/
  
  
  
  func imagePickerController(picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    picker.dismissViewControllerAnimated(true, completion:nil)
  
    if picker.sourceType == .Camera{
  //this is functional-comment out to try another approach
          let myimage = info[UIImagePickerControllerOriginalImage] as! UIImage
      
           /*     UIImageWriteToSavedPhotosAlbum(myimage, self, #selector(FCViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    */
       
       //start new method try
      let imageData = UIImageJPEGRepresentation(myimage, 0.5)
      let imagePath = FIRAuth.auth()!.currentUser!.uid +
        "/\(Int64(NSDate.timeIntervalSinceReferenceDate() * 1000))/asset.jpg"
      
      print(imagePath)
      let metadata = FIRStorageMetadata()
      metadata.contentType = "image/jpeg"
      self.storageRef.child(imagePath)
        .putData(imageData!, metadata: metadata) { (metadata, error) in
          if let error = error {
            print("Error uploading: \(error)")
            return
          }
          self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description])
      }
      
      
      
      
      
    
    }else{
    
    
    let referenceUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
    //print(referenceUrl) //looks like this for photo library>assets-library://asset/asset.JPG?id=B84E8479-475C-4727-A4A4-B77AA9980897&ext=JPG
    let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl], options: nil)
    let asset = assets.firstObject
    //print(asset) //looks like this for photo library>Optional(<PHAsset: 0x7ffbc6045a90> B84E8479-475C-4727-A4A4-B77AA9980897/L0/001 mediaType=1/0, sourceType=1, (4288x2848), creationDate=2009-10-09 21:09:20 +0000, location=0, hidden=0, favorite=0 )
    asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
      let imageFileUrl = contentEditingInput?.fullSizeImageURL
      //print(imageFile)//looks like this for photo library>Optional(file:///Users/admin/Library/Developer/CoreSimulator/Devices/C7BD0D2D-D1F0-4644-8D33-95E2BDA65D10/data/Media/DCIM/100APPLE/IMG_0002.JPG)
      
      let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int64(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(referenceUrl.lastPathComponent!)"
      print(filePath)//looks like this for photo library>Optional("KmIQDystKVM2v3A9GRZ9LqcgwwC2")/488942327742/asset.JPG
      let metadata = FIRStorageMetadata()
      metadata.contentType = "image/jpeg"
      //print(metadata)//looks like this for photo library>FIRStorageMetadata 0x7fb321ebb7e0: {contentType = "image/jpeg";}
      
      
      
      self.storageRef.child(filePath)
        .putFile(imageFileUrl!, metadata: metadata) { (metadata, error) in
      if let error = error {
            print("Error uploading: \(error.description)")
            return
          }
      self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description])
      }
    })
  }
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
  }//end signout
   //___________________________________________________________________________________________
  
  func showAlert(title:String, message:String) {
    dispatch_async(dispatch_get_main_queue()) {
      let alert = UIAlertController(title: title,
                                    message: message, preferredStyle: .Alert)
      let dismissAction = UIAlertAction(title: "Dismiss", style: .Destructive, handler: nil)
      alert.addAction(dismissAction)
      self.presentViewController(alert, animated: true, completion: nil)
    }//end dispatch
  }//end show alert
}


