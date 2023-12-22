//
//  FetchContactsOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/9/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation
import OneSignal

class FetchContactsOperation : BaseOperation {
    
    var location: UserLocation
    
    var httpResponse: HTTPURLResponse?
    var error: Error?
    var contacts: [Contact]?
    
    lazy var sessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration)
    }()
    
    init(location: UserLocation) {
        self.location = location
    }

    init(location: NewUserLocation, config: URLSessionConfiguration? = nil) {
        let loc = UserLocation()
        loc.locationType = UserLocation.LocationType(rawValue: location.locationType.rawValue)
        loc.locationValue = location.locationValue
        loc.locationDisplay = location.locationDisplay
        self.location = loc
        
        super.init()
        
        if let config {
            self.session = URLSession(configuration: config)
        }
    }
    
    private func buildURL() -> URL? {
        var components = URLComponents(string: "https://api.5calls.org/v1/reps")
        let locationQueryParam = URLQueryItem(name: "location", value: location.locationValue ?? "")
        components?.queryItems = [locationQueryParam]
        return components?.url
    }
    
    override func execute() {
        guard let url = buildURL() else {
            finish()
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let e = error {
               self.error = e
            } else {
                self.handleResponse(data: data, response: response)
            }
            self.finish()
        }
        print("Fetching reps...\(url)")
        task.resume()
    }
    
    private func handleResponse(data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        guard let http = response as? HTTPURLResponse else { return }
        
        print("HTTP \(http.statusCode)")
        httpResponse = http
        
        if http.statusCode == 200 {
            do {
                self.contacts = try parseContacts(data: data)
            } catch let e {
                print("Error parsing reps: \(e.localizedDescription)")
            }
        } else {
            print("Received HTTP \(http.statusCode)")
        }
    }
    
    private func parseContacts(data: Data) throws -> [Contact] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let contactList = try decoder.decode(ContactList.self, from: data)
        if contactList.generalizedLocationID != "-" {
            OneSignal.sendTag("districtID", value: contactList.generalizedLocationID)
        }
        return contactList.representatives
    }
}

