import XCTest
@testable import BDRCoreNetwork

final class BDRCoreNetworkTests: XCTestCase {
    func testExample() throws {
        BDRCoreNetwork.setup(BDRCoreNetwork.Parameters.init(apiKeyApp: "123", appId: "321"))
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
 
        XCTAssertEqual( BDRCoreNetwork.shared.appId , "321")
        XCTAssertEqual( BDRCoreNetwork.shared.apiKeyApp , "123")

    }
}
