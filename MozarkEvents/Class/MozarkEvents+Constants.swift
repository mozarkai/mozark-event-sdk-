//
//  MozarkEvents+Constants.swift
//  MozarkEventsSDK
//
//  Created by Mohamed Ali BELHADJ on 17/02/2023.
//

import Foundation
struct MozarkEventsConstants {
    struct Link {
        static let speedLink = "https://images.apple.com/v/imac-with-retina/a/images/overview/5k_image.jpg"
        static let hotStarBaseUrl = "https://bifrost-api.hotstar.com/v1/events/track/t1re_host_info?host="
        static let hotStarUrl = "www.hotstar.com"
        static let apiHotStarUrl = "api.hotstar.com"
        static let tizenHotStarUrl = "tizen.hotstar.com"
        static let webosHotStarUrl = "webos.hotstar.com"
        static let hsesAkamaizedUrl = "hses.akamaized.net"
        static let hsesAkamaized2Url = "hses2.akamaized.net"
        static let hsesAkamaized3Url = "hses3.akamaized.net"
        static let hsesAkamaized4Url = "hses4.akamaized.net"
        static let hsprepackAkamaizedUrl = "hsprepack.akamaized.net"
        static let live09pHotStarUrl = "live09p.hotstar.com"
        static let live11pHotStarUrl = "live11p.hotstar.com"
        static let live12pHotStarUrl = "live12p.hotstar.com"
        static let live13pHotStarUrl = "live13p.hotstar.com"
        static let live14pHotStarUrl = "live14p.hotstar.com"
        static let tailorAktHotStarUrl = "tailor.akt.hotstar-cdn.net"
        static let live11pAktHotStarUrl = "live11p.akt.hotstar-cdn.net"
        static let live12pAktHotStarUrl = "live12p.akt.hotstar-cdn.net"
        static let hostArray = [MozarkEventsConstants.Link.hotStarUrl, MozarkEventsConstants.Link.apiHotStarUrl, MozarkEventsConstants.Link.tizenHotStarUrl, MozarkEventsConstants.Link.webosHotStarUrl, MozarkEventsConstants.Link.hsesAkamaizedUrl,MozarkEventsConstants.Link.hsesAkamaized2Url, MozarkEventsConstants.Link.hsesAkamaized3Url,MozarkEventsConstants.Link.hsesAkamaized4Url
                                ,MozarkEventsConstants.Link.hsprepackAkamaizedUrl,MozarkEventsConstants.Link.live09pHotStarUrl,MozarkEventsConstants.Link.live11pHotStarUrl,MozarkEventsConstants.Link.live12pHotStarUrl,MozarkEventsConstants.Link.live13pHotStarUrl,MozarkEventsConstants.Link.live14pHotStarUrl, MozarkEventsConstants.Link.tailorAktHotStarUrl,MozarkEventsConstants.Link.live11pAktHotStarUrl,MozarkEventsConstants.Link.live12pAktHotStarUrl]
        static let sendEventEndPoint = "/event/batchevent/"
    }
    
    struct Name
    {
        static let mozarkAttributesJsonFileName = "mozark_attributes.json"
        static let mozarkAttributesFileName = "mozark_attributes"
        static let shortVersionKey = "CFBundleShortVersionString"
        static let versionKey = "CFBundleVersion"
    }
}



