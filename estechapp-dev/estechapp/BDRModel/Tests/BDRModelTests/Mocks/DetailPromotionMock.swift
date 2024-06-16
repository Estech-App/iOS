//
//  PromotionDetailMock.swift
//  
//
//  Created by Junior on 4/12/21.
//

import Foundation
import XCTest
@testable import BDRModel

class PromotionDetailMock {
    
    static func create() -> PromotionDetail? {
        let data = String.json(withFile: "DetailPromotion", bundle: Bundle.module)
        guard let detailPromotion = PromotionDetail(jsonBody: data) else {
            XCTFail("Missing file: DetailPromotion.json")
            return nil
        }
        return detailPromotion
    }
}
