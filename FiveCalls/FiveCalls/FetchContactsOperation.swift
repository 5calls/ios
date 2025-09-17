//
//  FetchContactsOperation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/9/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation
import OneSignal

class FetchContactsOperation: BaseOperation, @unchecked Sendable {

    var location: UserLocation

    var httpResponse: HTTPURLResponse?
    var error: Error?
    var contacts: [Contact]?
    var splitDistrict: Bool?
    var district: String?
    var stateAbbreviation: String?
    var lowAccuracy: Bool?

    init(location: UserLocation, config: URLSessionConfiguration? = nil) {
        self.location = location

        super.init()
        if let config {
            self.session = URLSession(configuration: config)
        }
    }
    
    var url: URL {
        var components = URLComponents(string: "https://api.5calls.org/v1/reps")
        let locationQueryParam = URLQueryItem(name: "location", value: location.locationValue)
        components?.queryItems = [locationQueryParam]
        return components!.url!
    }
    
    override func execute() {
        let request = buildRequest(forURL: url)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let e = error {
               self.error = e
            } else {
                self.handleResponse(data: data, response: response)
            }
            self.finish()
        }
        task.resume()
    }
    
    private func handleResponse(data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        guard let http = response as? HTTPURLResponse else { return }
        
        print("HTTP \(http.statusCode)")
        httpResponse = http
        
        if http.statusCode == 200 {
            do {
                try parseContacts(data: data)
            } catch let e {
                print("Error parsing reps: \(e.localizedDescription)")
            }
        } else {
            print("Received HTTP \(http.statusCode)")
        }
    }
    
    private func parseContacts(data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let contactList = try decoder.decode(ContactList.self, from: data)

        splitDistrict = contactList.isSplit
        lowAccuracy = contactList.lowAccuracy
        if contactList.generalizedLocationID != "-" {
            district = contactList.generalizedLocationID
            OneSignal.sendTag("districtID", value: contactList.generalizedLocationID)
        }

        stateAbbreviation = contactList.state
        contacts = contactList.representatives
    }
}

