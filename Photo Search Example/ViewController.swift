//
//  ViewController.swift
//  Photo Search Example
//
//  Created by Leslie Borrell on 5/10/16.
//  Copyright © 2016 Slush Industries. All rights reserved.
//

import UIKit
import AFNetworking
import SimpleAuth
import OAuthSwift
import SwiftyJSON

class ViewController: UIViewController {
    
    var results:[AnyObject]? = []
    @IBOutlet weak var scrollView:UIScrollView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let oauthswift = OAuth2Swift(
            consumerKey:    "a67859ec1cdd4d748d69baf98e14ed8f",
            consumerSecret: "f72f5139f57c48489bcd7f66c6ae0491",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        oauthswift.authorizeWithCallbackURL(
            NSURL(string: "Photo-Search-Example://Photo-Search-Example-callback/instagram")!,
            scope: "basic+public_content", state:"INSTAGRAM",
            success: { credential, response, parameters in
                let accessToken = credential.oauth_token
                self.getPhotos(accessToken)
                print(credential.oauth_token)
                self.scrollView.contentSize = CGSizeMake(320, 320 * CGFloat(self.results!.count))
                self.loadImages()
            },
            failure: { error in
                print(error.localizedDescription)
            }
        )
    }
    
    
    func loadImages() {
        for i in 0 ..< 5 {
            
            if let imageData = NSData(contentsOfURL: NSURL(string: results![i] as! String)!)     {    //1
           // if let imageDataUnwrapped = imageData {                                     //2
                let imageView = UIImageView(image: UIImage(data: imageData))   //3
                imageView.frame = CGRectMake(0, 320 * CGFloat(i), 320, 320)               //4
                self.scrollView.addSubview(imageView)                                        //5
            }
        }

    }
    
    func getPhotos(accessToken: String) -> AnyObject? {
        let manager = AFHTTPSessionManager()
        
        manager.GET("https://api.instagram.com/v1/users/self/media/recent/?access_token=\(accessToken)",
                    parameters: nil,
                    progress: nil,
                    success: { (operation: NSURLSessionDataTask,responseObject: AnyObject?) in
                        let responseObject = JSON(responseObject!)
                        let dataCount = responseObject["data"].count
                        for var index = 0; index < dataCount; index++ {
                            if let imageString = responseObject["data"][index]["images"]["standard_resolution"]["url"].string {
                                let imageURL = NSURL(string: imageString)
                                print(imageURL)
                                self.results?.append(imageURL!)
                                print(self.results)
                            }
                            print("Response: " + responseObject.description)
                            print(self.results?.count)
                            
                        }
                        
            },
                    
                    failure: { (operation: NSURLSessionDataTask?,error: NSError) in
                        print("Error: " + error.localizedDescription)
        })
        return(results)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

