//
//  ViewController.swift
//  MasterBuilder
//
//  Created by Nitz, Ryan on 7/4/17.
//  Copyright © 2017 Nitz, Ryan. All rights reserved.
//

import UIKit
import LoginWithAmazon
import AWSCognito
import AWSCore
import Foundation

class ViewController: UIViewController, AIAuthenticationDelegate {
    
    @IBAction func loginButton(_ sender: Any) {
        print("button pressed")
        LoginWithAmazonProxy.sharedInstance.login(delegate: self)
        //LoginWithAmazonProxy.sharedInstance.getAccessToken(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewDidLoad")
        print(Bundle.main.bundleIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    func requestDidSucceed(_ apiResult: APIResult) {
        print("requestDidSucceed")
        if (apiResult.api == API.authorizeUser) {
            print("redirect")
            AIMobileLib.getAccessToken(forScopes: Settings.Credentials.SCOPES, withOverrideParams: nil, delegate: self)
        }
        else {
            print("Success! Token: \(apiResult.result)")
            
            if apiResult.api == API.getAccessToken {
                
                DispatchQueue.main.async {
                
                    let credentialProvider = AWSCognitoCredentialsProvider(
                        regionType: .usEast1,
                        identityPoolId: "us-east-1:2bb8b6cf-96e9-48f3-a32d-87a1f550b214"
                    )
                    let configuration = AWSServiceConfiguration(region: .usEast1, credentialsProvider: credentialProvider)
                    AWSServiceManager.default().defaultServiceConfiguration = configuration
                
                    print("we got here")
                    credentialProvider?.logins = ["www.amazon.com": apiResult.result]
                
                    var task = credentialProvider?.refresh()
                
                    sleep(1)
                    print(credentialProvider?.accessKey)
                    print(credentialProvider?.secretKey)

                }
                
                
                /*
                task?.continueWithBlock {
                    (task: AWSTask!) -> AnyObject! in
                    if (task.error != nil) {
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        let currentDeviceToken: NSData? = userDefaults.objectForKey(Constants.DEVICE_TOKEN_KEY) as? NSData
                        var currentDeviceTokenString : String
                        
                        if currentDeviceToken != nil {
                            currentDeviceTokenString = currentDeviceToken!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                        } else {
                            currentDeviceTokenString = ""
                        }
                        
                        if currentDeviceToken != nil && currentDeviceTokenString != userDefaults.stringForKey(Constants.COGNITO_DEVICE_TOKEN_KEY) {
                            
                            AWSCognito.defaultCognito().registerDevice(currentDeviceToken).continueWithBlock { (task: AWSTask!) -> AnyObject! in
                                if (task.error == nil) {
                                    userDefaults.setObject(currentDeviceTokenString, forKey: Constants.COGNITO_DEVICE_TOKEN_KEY)
                                    userDefaults.synchronize()
                                }
                                return nil
                            }
                        }
                    }
                    return task
                }.continueWithBlock(nil)
 */
            }
 
        }
    }
    
    func requestDidFail(_ errorResponse: APIError) {
        print("Error: \(errorResponse.error.message)")
    }

}

