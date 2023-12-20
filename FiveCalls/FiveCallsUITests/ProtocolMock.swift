//
//  ProtocolMock.swift
//  FiveCallsUITests
//
//  Created by Nick O'Neill on 12/19/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

class ProtocolMock: URLProtocol {
    let testData: [URL: Data]
    
    let testJSON = """
[
  {
    "id": 1,
    "createdAt": "2023-10-17T22:23:05Z",
    "name": "Call to demand support for x",
    "reason": "Recently there have been reports of x happening, scary",
    "script": "Hi, my name is **[NAME]** and I’m a constituent from [CITY, ZIP]. Please support x",
    "categories": [
      {
        "name": "Foreign Affairs"
      }
    ],
    "contactType": "REPS",
    "contacts": null,
    "contactAreas": [
      "US Senate",
      "US House"
    ],
    "outcomeModels": [
      {
        "label": "unavailable",
        "status": "unavailable"
      },
      {
        "label": "voicemail",
        "status": "voicemail"
      },
      {
        "label": "contact",
        "status": "contact"
      },
      {
        "label": "skip",
        "status": "skip"
      }
    ],
    "stats": {
      "calls": 0
    },
    "slug": "demand-support-x",
    "active": true,
    "hidden": false,
    "meta": "recI4yxMrGYyuc2QY"
  },
  {
    "id": 801,
    "createdAt": "2023-01-25T22:19:23Z",
    "name": "Demand a Federal Ban on Assault Weapons",
    "reason": "In 2004, the National Rifle Association (NRA) successfully pressured the Republican-controlled government into preventing the renewal of the [1994 Federal Assault Weapons Ban.](https://www.politico.com/story/2018/09/13/clinton-signs-assault-weapons-ban-sept-13-1994-813552).",
    "script": "Hi, my name is **[NAME]** and I’m a constituent from [CITY, STATE].",
    "categories": [
      {
        "name": "Gun Safety"
      }
    ],
    "contactType": "REPS",
    "contacts": null,
    "contactAreas": [
      "US Senate"
    ],
    "outcomeModels": [
      {
        "label": "unavailable",
        "status": "unavailable"
      },
      {
        "label": "voicemail",
        "status": "voicemail"
      },
      {
        "label": "contact",
        "status": "contact"
      },
      {
        "label": "skip",
        "status": "skip"
      }
    ],
    "stats": {
      "calls": 8242
    },
    "slug": "assault-weapon-ban-gun-safety",
    "active": true,
    "hidden": false,
    "meta": "recB3QevCIxKUkSDN"
  },
  {
    "id": 732,
    "createdAt": "2021-01-03T17:13:40Z",
    "name": "Urge Congress to Act on the Climate Change Crisis",
    "reason": "In November of 2018, an extensive federally mandated report on climate change was released by the US Global Change Research Program,",
    "script": "Hi, my name is **[NAME]** and I'm a constituent from [CITY, ZIP].",
    "categories": [
      {
        "name": "Environment"
      }
    ],
    "contactType": "REPS",
    "contacts": null,
    "contactAreas": [
      "US Senate",
      "US House"
    ],
    "outcomeModels": [
      {
        "label": "unavailable",
        "status": "unavailable"
      },
      {
        "label": "voicemail",
        "status": "voicemail"
      },
      {
        "label": "contact",
        "status": "contact"
      },
      {
        "label": "skip",
        "status": "skip"
      }
    ],
    "stats": {
      "calls": 3481
    },
    "slug": "global-climate-change-crisis",
    "active": false,
    "hidden": false,
    "meta": "recC3RsZ2itAIFlBa"
  },
  {
    "id": 806,
    "createdAt": "2023-03-03T18:48:18Z",
    "name": "Support Workers Right to Organize: Support the PRO Act",
    "reason": "Income and wealth inequality (how evenly or unevenly income is distributed across the population) is higher in the United States than [in almost any other developed nation.](https://www.cfr.org/backgrounder/us-inequality-debate) From 1979 to 2020, annual wages for the bottom 90% of households increased by only 26%, while",
    "script": "Hi, my name is **[NAME]** and I’m a constituent from [CITY, ZIP]. ",
    "categories": [
      {
        "name": "Worker's Rights"
      }
    ],
    "contactType": "REPS",
    "contacts": null,
    "contactAreas": [
      "US Senate",
      "US House"
    ],
    "outcomeModels": [
      {
        "label": "unavailable",
        "status": "unavailable"
      },
      {
        "label": "voicemail",
        "status": "voicemail"
      },
      {
        "label": "contact",
        "status": "contact"
      },
      {
        "label": "skip",
        "status": "skip"
      }
    ],
    "stats": {
      "calls": 1286
    },
    "slug": "protecting-right-organize-pro-act",
    "active": true,
    "hidden": false,
    "meta": "recTXb8d9MY8sM77R"
  }
]
"""

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        testData = [
            URL(string: "https://api.5calls.org/v1/issues")!: testJSON.data(using: .utf8)!,
        ]

        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            // remove query strings from urls because they shouldn't change the shape of the response
            var trimmedURL = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            trimmedURL.query = nil
            if let data = testData[trimmedURL.url!] {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            self.client?.urlProtocol(self, didReceive: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}
