//
//  ConstantsTests.swift
//  MozarkEventsSDKTests
//
//  Created by Mohamed Ali BELHADJ on 02/03/2023.
//

import XCTest
@testable import MozarkEventsSDK

final class ConstantsTests: XCTestCase {
    
    
    
    func testConstants()  {
        XCTAssert(MozarkEventsConstants.Link.speedLink == "https://images.apple.com/v/imac-with-retina/a/images/overview/5k_image.jpg", "speed link is wrong")
        XCTAssert(MozarkEventsConstants.Link.hotStarBaseUrl == "https://bifrost-api.hotstar.com/v1/events/track/t1re_host_info?host=", "hotStarBaseUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.hotStarUrl == "www.hotstar.com", "hotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.apiHotStarUrl == "api.hotstar.com", "apiHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.tizenHotStarUrl == "tizen.hotstar.com", "tizenHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.webosHotStarUrl == "webos.hotstar.com", "webosHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.hsesAkamaizedUrl == "hses.akamaized.net", "hsesAkamaizedUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.hsesAkamaized2Url == "hses2.akamaized.net", "hsesAkamaized2Url link is wrong")
        XCTAssert(MozarkEventsConstants.Link.hsesAkamaized3Url == "hses3.akamaized.net", "hsesAkamaized3Url link is wrong")
        XCTAssert(MozarkEventsConstants.Link.hsesAkamaized4Url == "hses4.akamaized.net", "hsesAkamaized4Url link is wrong")
        XCTAssert(MozarkEventsConstants.Link.hsprepackAkamaizedUrl == "hsprepack.akamaized.net", "hsprepackAkamaizedUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.live09pHotStarUrl == "live09p.hotstar.com", "live09pHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.live11pHotStarUrl == "live11p.hotstar.com", "live11pHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.live12pHotStarUrl == "live12p.hotstar.com", "live12pHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.live13pHotStarUrl == "live13p.hotstar.com", "live13pHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.live14pHotStarUrl == "live14p.hotstar.com", "live14pHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.tailorAktHotStarUrl == "tailor.akt.hotstar-cdn.net", "tailorAktHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.live11pAktHotStarUrl == "live11p.akt.hotstar-cdn.net", "live11pAktHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.live12pAktHotStarUrl == "live12p.akt.hotstar-cdn.net", "live12pAktHotStarUrl link is wrong")
        XCTAssert(MozarkEventsConstants.Link.sendEventEndPoint == "/event/batchevent/", "sendEventEndPoint  is wrong")
        XCTAssert(MozarkEventsConstants.Link.hostArray.count == 17, "hostArray link is wrong")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.hotStarUrl), "hostArray dont contain hotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.apiHotStarUrl), "hostArray dont contain apiHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.tizenHotStarUrl), "hostArray dont contain tizenHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.webosHotStarUrl), "hostArray dont contain webosHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.hsesAkamaizedUrl), "hostArray dont contain hsesAkamaizedUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.hsesAkamaized2Url), "hostArray dont contain hsesAkamaized2Url")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.hsesAkamaized3Url), "hostArray dont contain hsesAkamaized3Url")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.hsesAkamaized4Url), "hostArray dont contain hsesAkamaized4Url")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.hsprepackAkamaizedUrl), "hostArray dont contain hsprepackAkamaizedUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.live09pHotStarUrl), "hostArray dont contain live09pHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.live11pHotStarUrl), "hostArray dont contain live11pHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.live12pHotStarUrl), "hostArray dont contain live12pHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.live13pHotStarUrl), "hostArray dont contain live12pHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.live14pHotStarUrl), "hostArray dont contain live14pHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.tailorAktHotStarUrl), "hostArray dont contain tailorAktHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.live11pAktHotStarUrl), "hostArray dont contain live11pAktHotStarUrl")
        XCTAssert(MozarkEventsConstants.Link.hostArray.contains(MozarkEventsConstants.Link.live12pAktHotStarUrl), "hostArray dont contain live12pAktHotStarUrl")
    }
}

