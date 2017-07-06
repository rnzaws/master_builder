

import Foundation
import LoginWithAmazon

class LoginWithAmazonProxy {
    
    static let sharedInstance = LoginWithAmazonProxy()
    
    func login(delegate: AIAuthenticationDelegate) {
        print("proxy - login")
        AIMobileLib.authorizeUser(forScopes: Settings.Credentials.SCOPES, delegate: delegate)
    }
    
    func logout(delegate: AIAuthenticationDelegate) {
        print("proxy - logout")
        AIMobileLib.clearAuthorizationState(delegate)
    }
    
    func getAccessToken(delegate: AIAuthenticationDelegate) {
        print("proxy - getAccessToken")
        AIMobileLib.getAccessToken(forScopes: Settings.Credentials.SCOPES, withOverrideParams: nil, delegate: delegate)
    }
}
