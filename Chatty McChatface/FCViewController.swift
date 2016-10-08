//
//  FCViewController.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 5/31/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import Photos
import UIKit
import Firebase
import GoogleMobileAds

/**
 * AdMob ad unit IDs are not currently stored inside the google-services.plist file. Developers
 * using AdMob can store them as custom values in another plist, or simply use constants. Note that
 * these ad units are configured to return only test ads, and shouldvart be used outside this sample.
 */
let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
@objc(FCViewController)
class FCViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  // Instance variables
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var banner: GADBannerView!
  @IBOutlet weak var clientTable: UITableView!
  
  //class Parameters
  var ref: FIRDatabaseReference!
  var messages: [FIRDataSnapshot]! = []
  var msglength: NSNumber = 250
  fileprivate var _refHandle: FIRDatabaseHandle!
  var storageRef: FIRStorageReference!
  var remoteConfig: FIRRemoteConfig!
  
  
 //MARK: Action Methods
   //___________________________________________________________________________________________
  @IBAction func didSendMessage(_ sender: UIButton) {
    textFieldShouldReturn(textField)
    //clear the text box
    textField.text=""
    //hide the keyboard
    dismissKeyboard()
     }
   //___________________________________________________________________________________________
  @IBAction func didPressCrash(_ sender: AnyObject) {
    FIRCrashMessage("Cause Crash button clicked")
  }
   //___________________________________________________________________________________________
  @IBAction func didPressFreshConfig(_ sender: AnyObject) {
    fetchConfig()
  }
   //___________________________________________________________________________________________

  @IBAction func signOut(_ sender: UIButton) {
    let firebaseAuth = FIRAuth.auth()
    do {
      try firebaseAuth?.signOut()
      AppState.sharedInstance.signedIn = false
      performSegue(withIdentifier: Constants.Segues.FpToSignIn, sender: nil)
    } catch let signOutError as NSError {
      print ("Error signing out: \(signOutError)")
    }
  }

  //___________________________________________________________________________________________
  @IBAction func didTapAddPhoto(_ sender: AnyObject) {
    let picker = UIImagePickerController()
    picker.delegate = self
    if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
    }
    present(picker, animated: true, completion:nil)
    print("present vc")
    
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
    fetchConfig()
    
    loadAd()
    
    // set up chat view table view autosize
    
    self.clientTable.rowHeight = UITableViewAutomaticDimension
    self.clientTable.estimatedRowHeight = 85
    
    
    configureStorage()
    //self.messages.removeAll()
    //self.clientTable.reloadData()
    
    //-------------------need to move keyboard text box up when keyboard is showing
    NotificationCenter.default.addObserver(self, selector: #selector(FCViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(FCViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    FIRCrashMessage("View loaded")
    self.hideKeyboardWhenTappedAround()
  
  }
  //___________________________________________________________________________________________
  /*deinit {
    self.ref.child("messages").removeObserverWithHandle(_refHandle)
  }*/
  
  //need a couple methods here to move keyboard
  func keyboardWillShow(_ sender: Notification) {
    self.view.frame.origin.y = -160
  }
  //___________________________________________________________________________________________
  func keyboardWillHide(_ sender: Notification) {
    self.view.frame.origin.y = 0
  }
  //--------------------------------------------------------
  func loadAd() {
    self.banner.adUnitID = kBannerAdUnitID
    self.banner.rootViewController = self
    self.banner.load(GADRequest())
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
    remoteConfig.fetch(withExpirationDuration: expirationDuration) { (status, error) in
      if (status == .success) {
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
  
  override func viewWillAppear(_ animated: Bool) {
    
    self.clientTable.estimatedRowHeight = 100
    self.clientTable.rowHeight = UITableViewAutomaticDimension
    self.messages.removeAll()
    self.clientTable.reloadData()    // reloads the table view
    
    //This fires when a new message is added
    _refHandle = self.ref.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
    //add snapshot of next message to be appended to messages object(FIRdata snapshot object)
    self.messages.append(snapshot) //add the snapshot to messages array
    print("message observer fired")
    // Assign self.messages to MessagesTabController(instance of tabBarController)
      if let tbc = self.tabBarController as? MessagesTabController {
        tbc.myMessages = self.messages
      }
      
      
      
      
    //add another row to the clientTable (UITableView Object)
//self.clientTable.rowHeight = UITableViewAutomaticDimension
    self.clientTable.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
      //self.clientTable.reloadData()
     print("table rows inserted")
    self.scrollToLastRow()
     print("scrolled to last row")
    })
  }
  
    //___________________________________________________________________________________________
  
  override func viewWillDisappear(_ animated: Bool) {
    
    super.viewWillDisappear(animated)
    print("kill observers ")
    self.ref.child("messages").removeObserver(withHandle: _refHandle) //This fixed a bug where table view fired twice on an image add message
    
    //Release the keyboard observers
    
    
    //When starting a seques to mapview, releasing the NSNotification observer throws a hard compiler fault (compiler swift failure)
    
    
    //NotificationCenter.default.removeObserver( NSNotification.Name.UIKeyboardWillShow)
  //  NotificationCenter.default.removeObserver( NSNotification.Name.UIKeyboardWillHide )
  //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: Any?.self)
    
  /* strated as:
     NotificationCenter.default.addObserver(self, selector: #selector(FCViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(FCViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
     
 
 */
    
    
    
    
  }
  
  
  //___________________________________________________________________________________________
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    let newLength = text.utf16.count + string.utf16.count - range.length
    return newLength <= self.msglength.intValue // returns bool
  }

  
  // UITableViewDataSource protocol methods
  //___________________________________________________________________________________________
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("get message count")
    return messages.count
  }

  //get current message index
  //____________________________________________________________________________________________
  func indexOfMessage(_ snapshot: FIRDataSnapshot) -> Int {
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
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a cell
    let cell = self.clientTable .dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
    
    // Unpack message from Firebase DataSnapshot
    let messageSnapshot: FIRDataSnapshot! = self.messages[(indexPath as NSIndexPath).row]  //get message snapshot from messages array
    let message = messageSnapshot.value as! Dictionary<String, String>    //get message as dictionary
    let name = message[Constants.MessageFields.name] as String!           //get current name
    let dateSent = message[Constants.MessageFields.dateSent] as String!   //get current date
    // Done unpacking Firebase data
    //This block decodes an imageURL which is an embedded photo
    //imageUrl is the storage field used for a media(photo) item
    //avatarUrl is the storage field used for avatars
    if message[Constants.MessageFields.imageUrl]! != "" {
     // message has media attachment
    
      let imageUrl = message[Constants.MessageFields.imageUrl] as String!
      //message contains an embedded image media url
      //check to see if it has a firebase storage url prefix
      
            if (imageUrl?.hasPrefix("gs://"))! {
            //get image from firebase storage
            //async method returns object or error- exits at completion of media retrieval
              print("get image")
              FIRStorage.storage().reference(forURL: imageUrl!).data(withMaxSize: 4000000){ (data, error) in
              if let error = error {
                  print("Error downloading: \(error)")
                  return
                  }
              print("image received")
            //This fires when download of image is complete
            cell.CellLeftImage?.image = UIImage.init(data: data!)
            cell.CellTitleLabel.text = name
            cell.CellMessageLabel.text="Sent Image"
            cell.CellDateLabel.text = dateSent
           }//end get image from firebase storage
            print()
            return cell
      //}
             //if not stored in firebase storage, retrieve image from web url
            } else
              if let url = URL(string:imageUrl!), let data = try? Data(contentsOf: url) {
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
              cell.CellDateLabel.text = dateSent
              if let avatarUrl = message[Constants.MessageFields.avatarUrl], let url = URL(string:avatarUrl), let data = try? Data(contentsOf: url) {
                cell.CellLeftImage?.image = UIImage(data: data)
              }
            }

            return cell
          }
  
  //methods for autosizing table view row height
  //___________________________________________________________________________________________
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //print(UITableViewAutomaticDimension)
    return UITableViewAutomaticDimension
  }
  //___________________________________________________________________________________________
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //print(UITableViewAutomaticDimension)
    return UITableViewAutomaticDimension
  }

  //_________________________________________________________________________________________
  //swipe to delete method
  //note this has to be done programmatically. During compilation xcode checks for existence of this method, and if available, enables swipe to delete functionality
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    // swipe to delete message method
      if editingStyle == .delete {
      
        //following is a cell instance of FIRDataSnapshot
        let messageToDelete = messages[(indexPath as NSIndexPath).row]
        let messageSnapshot: FIRDataSnapshot! = self.messages[(indexPath as NSIndexPath).row]
        let message = messageSnapshot.value as! Dictionary<String, String>
        
        if message[Constants.MessageFields.imageUrl]! != "" {
        let imageUrl = message[Constants.MessageFields.imageUrl] as String?
        
          //check to see if message has an associated firebase storage image
            let deletionRef = FIRStorage.storage().reference(forURL: imageUrl! as String)
            deletionRef.delete { (error) -> Void in
            if (error != nil) {
              print("error")
              } else {
          // File deleted successfully
        }
      }//end delete with completion block
    }
  
      //remove message from firebase database
      messages.remove(at: (indexPath as NSIndexPath).row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      messageToDelete.ref.removeValue()
      self.scrollToLastRow()
        } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view. Not used here.
     
      }
  }
 
  
  
// func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
  //  
//  }
  
  
  
  
  //Scroll the table view to last row
  //____________________________________________________________________________________________
  func scrollToLastRow() {
   let indexPath = IndexPath(row: messages.count - 1, section: 0)
    self.clientTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
  }
  
  
  //UITextViewDelegate protocol methods
  //____________________________________________________________________________________________
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let data = [Constants.MessageFields.text: textField.text! as String]
    print("data passed to SendMessage:")
    print(data)
    let messageType=true
    sendMessage(data, messageType: messageType)//true =text message
    //print (data)
    return true
  }
  
  
  // Send Message to Firebase
  //____________________________________________________________________________________________
  func sendMessage(_ data: [String: String], messageType: Bool) {
    //pass an imageUrl or text message
    //assemble the firebase message
    //this passes either a text or imageUrl
    
    //empty data is delimited by empty string ("") to prevent nil
    print("start send message")
    //make a mutable copy of data
    var mdata = data
    //for media messages, mdata already contains a key-value for imageUrl
    //for text messages, mdata already contains a key-value for text
    //collect common properties for both text & media messages
    
    
    mdata[Constants.MessageFields.name] = AppState.sharedInstance.displayName
    mdata[Constants.MessageFields.dateSent] = StringDate()
    
    
    if let currentLocation = getMessageLocation() {
    mdata[Constants.MessageFields.messageLat] = "\(currentLocation.coordinate.latitude)"
    mdata[Constants.MessageFields.messageLon] = "\(currentLocation.coordinate.longitude)"
      
    
    
    }else{
      print("Location Failure")
    }
    //ddetect whether text or media message
    if messageType == true { //text message
      
      //text message
      print("text")
      if let avatarUrl = AppState.sharedInstance.avatarUrl {
        mdata[Constants.MessageFields.avatarUrl] = avatarUrl.absoluteString
      }
      //set imageUrl to empty string
      mdata[Constants.MessageFields.imageUrl] = ""
      
      print(mdata[Constants.MessageFields.messageLat])
      print(mdata[Constants.MessageFields.messageLon])
      
      
      self.ref.child("messages").childByAutoId().setValue(mdata)
     
    }else{
      
      //media message
      print("media")
      
      mdata[Constants.MessageFields.text] = ""
      mdata[Constants.MessageFields.avatarUrl] = "" //blank the avatarUrl since the space is used for media
      
      print(mdata[Constants.MessageFields.messageLat])
      print(mdata[Constants.MessageFields.messageLon])
      
      self.ref.child("messages").childByAutoId().setValue(mdata)
      
       }
    print("end of send message")
   }
  
  // image picker
  //___________________________________________________________________________________________
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : Any]) {
    picker.allowsEditing = true
    //picker.showsCameraControls = true
    picker.dismiss(animated: true, completion:nil)
  
    if picker.sourceType == .camera{
      // Camera Use
      let myimage = info[UIImagePickerControllerOriginalImage] as! UIImage
      let imageData = UIImageJPEGRepresentation(myimage, 0.0)
      let imagePath = FIRAuth.auth()!.currentUser!.uid +
        "/\(Int64(Date.timeIntervalSinceReferenceDate * 1000))/asset.jpg"
      
      let metadata = FIRStorageMetadata()
      metadata.contentType = "image/jpeg"
      print("start image store")
      SwiftSpinner.show("uploading camera image")
      self.storageRef.child(imagePath)
        .put(imageData!, metadata: metadata) { (metadata, error) in
          if let error = error {
            print("Error uploading: \(error)")
            SwiftSpinner.hide()
            return
          }
          let messageType = false
          self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description], messageType: messageType)
          SwiftSpinner.hide()
      }
    
    }else{
    
    //This is for photolibrary use, camera cannot be processed this way
    let referenceUrl = info[UIImagePickerControllerReferenceURL] as! URL
    let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceUrl], options: nil)
    let asset = assets.firstObject
    
    asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
      let imageFileUrl = contentEditingInput?.fullSizeImageURL//displaySizeImage
      //}
      
      let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int64(Date.timeIntervalSinceReferenceDate * 1000))/\(referenceUrl.lastPathComponent)"
      
      let metadata = FIRStorageMetadata()
      metadata.contentType = "image/jpeg"
      
      
      
      //This takes forever to store an image
      print("start lib image store")
      SwiftSpinner.show("uploading camera image")
      
      self.storageRef.child(filePath).putFile(imageFileUrl!, metadata: metadata) { (metadata, error) in
      if error != nil {
            //print("Error uploading: \(error)")
        print("error uploading")
        SwiftSpinner.hide()
        return
      }else {
          print("image store complete")
          SwiftSpinner.hide()
        }
          
          
         // [Constants.MessageFields.text] = ""
          let messageType = false
      self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description], messageType: messageType)
        }
       }
      )
      
     }
    }
  
   //___________________________________________________________________________________________
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion:nil)
  }
   //___________________________________________________________________________________________
  
  func showAlert(_ title:String, message:String) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title,
                                    message: message, preferredStyle: .alert)
      let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
      alert.addAction(dismissAction)
      self.present(alert, animated: true, completion: nil)
    }
  }
  
}

