//
//  TestFacebook.swift
//  Gocci
//
//  Created by Ma Wa on 20.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import XCTest

class TestFacebook: XCTestCase {
    

    
    func testIfLoginFailsWithExpiredToken() {
        
        let expired_token = "CAAJkM7KbcYYBAInz97XHPf166pPnpRcZBkK5D3YsAkxFHQeg5iWSWxa26306ghtMEAtK0VeiZABDBn5dZBNpAjN8S7Ydud53u9Cb6UY9ZCZBFUYXqrvOq1SgTJNFFF6ArNVrZBPwOP5ZAE1q7BgBLv9uCygmpFbFr1NAHVHYwO1XXGnBwHLWDWg8C4jPZAtfJ6GJ0EeiUqcLaAZDZD"
     
        //FacebookAuthentication.setTokenDirect(facebookTokenString: expired_token)
        
        FacebookAuthentication.authenticadedAndReadyToUse { (succ) -> () in
            XCTAssertFalse(succ)
        }
        
    }
    

    
}
