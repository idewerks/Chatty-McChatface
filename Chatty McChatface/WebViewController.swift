//
//  WebViewController.swift
//  Chatty McChatface
//
//  Created by kevin brennan on 10/5/16.
//  Copyright © 2016 kevin brennan. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
class WebViewController: UIViewController {

  @IBOutlet weak var IDWebView: UIWebView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
     // let url = NSURL(string:"http://blog.idewerks.com")
     // let request = NSURLRequest(URL: url)
    //  IDWebView.loadRequest(request as URLRequest)
      
      IDWebView.loadRequest(NSURLRequest(url: NSURL(string: "https://blog.idewerks.com")! as URL) as URLRequest)
      // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
