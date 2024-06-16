//
//  File.swift
//  
//
//  Created by Junior on 5/12/21.
//

import Foundation
import Alamofire

public class HeaderBuilder {
    public static func build() -> HTTPHeaders  {
        var headers: HTTPHeaders = [BDRCoreNetworkConstants.HTTPHeaders.accept.rawValue: "application/json",
                BDRCoreNetworkConstants.HTTPHeaders.contentType.rawValue: "application/json"
               ]
        
        if let token = TokenManager.shared.fetchAccessToken() {
            headers.add(name: BDRCoreNetworkConstants.HTTPHeaders.authorization.rawValue, value: "Bearer " + token)
        }
    
        return headers
    }
}
