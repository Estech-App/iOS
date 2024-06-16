import XCTest
@testable import BDRModel

final class BDRModelTests: XCTestCase {
    func test_createDetailPromotion() throws {
        XCTAssertNotNil(PromotionDetailMock.create())
    }
}
