//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

import FirebaseAuth
import TwitterKit
import FBSDKCoreKit
import FBSDKLoginKit

@objc(SignInViewController)
class SignInViewController: UIViewController {
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  
  override func viewDidAppear(_ animated: Bool) {
    if let user = FIRAuth.auth()?.currentUser {
      self.signedIn(user)
    }
  }
  
  @IBAction func didTapSignIn(_ sender: AnyObject) {
    // Sign In with credentials.
    let email = emailField.text
    let password = passwordField.text
    FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      self.signedIn(user!)
    }
  }
  
  
  
  @IBAction func didTapSignUp(_ sender: AnyObject) {
    let email = emailField.text
    let password = passwordField.text
    FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      self.setDisplayName(user!)
    }
  }
  
  
  
  
  
  func setDisplayName(_ user: FIRUser) {
    let changeRequest = user.profileChangeRequest()
    changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
    changeRequest.commitChanges(){ (error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      self.signedIn(FIRAuth.auth()?.currentUser)
    }
  }
  
  
  
  
  
  
  
  @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
    let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action) in
      let userInput = prompt.textFields![0].text
      if (userInput!.isEmpty) {
        return
      }
      FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
        if let error = error {
          print(error.localizedDescription)
          return
          
        }
      }
    }
    
    prompt.addTextField(configurationHandler: nil)
    prompt.addAction(okAction)
    present(prompt, animated: true, completion: nil)
  }
  
 
  @IBAction func TwitterLoginButton(_ sender: AnyObject) {
    
    Twitter.sharedInstance().logIn { session, error in
      if (session != nil) {
        print("signed in as \(session!.userName)")
        let credential = FIRTwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
       
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
          
          if (user != nil){
           self.signedIn(FIRAuth.auth()?.currentUser)
            
          }else{
           print("user nil error: \(error!.localizedDescription)")
          }
        }
      
      } else {
        print("session error: \(error!.localizedDescription)")
      }
    }
  }
  
  
  
  @IBAction func FacebookLoginButton(_ sender: AnyObject) {
    
    let loginManager = FBSDKLoginManager()
    loginManager.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
      if let error = error {
        print(error.localizedDescription)
      } else if(result?.isCancelled)! {
        print("FBLogin cancelled")
      } else {
        // [START headless_facebook_auth]
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        // [END headless_facebook_auth]
        self.firebaseLogin(credential)
        
      }
    })
  }
  
  func firebaseLogin(_ credential: FIRAuthCredential) {
    
      if let user = FIRAuth.auth()?.currentUser {
        user.link(with: credential) { (user, error) in       
            if let error = error {
              print(error.localizedDescription)
              return
            }
          }
        }else {
        //link success
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
              print(error.localizedDescription)
              return
            }
          if (user != nil){
            self.signedIn(FIRAuth.auth()?.currentUser)
            
          }else{
            print("user nil error: \(error!.localizedDescription)")
          }
          
        }
        
      }
    }

 
  
  
  func signedIn(_ user: FIRUser?) {
    
    MeasurementHelper.sendLoginEvent()
    AppState.sharedInstance.displayName = user?.displayName ?? user?.email
    AppState.sharedInstance.avatarUrl = user?.photoURL
    AppState.sharedInstance.signedIn = true
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKeys.SignedIn), object: nil, userInfo: nil)
    performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
  }
  
  
  
}

