//
//  Issue.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

/*
 
 {
 "contacts": [],
 "id": "recNqspdW0JHxisu8",
 "name": "Reject the Appointment of Steve Bannon to the National Security Council",
 "reason": "Trump has removed the existing Director of National Intelligence and Chairman of Joint Chiefs of Staff from the \u201cprincipals committee\u201d of the National Security Council and replaced them with his Chief Strategist, Steve Bannon. Bannon is the former leader of Breitbart News, an anti-Semitic and white supremacist right-wing opinion and \"news\" outlet whose notable output includes articles comparing Planned Parenthood to the Holocaust. \n\nThe purpose of the National Security Council is to ensure that the president has the best possible advice from his Cabinet, the military, and the intelligence community before making major decisions.  Steve Bannon not only lacks the considerable experience needed to be the principal foreign policy adviser to the president, he has personally avowed a desire to \"bring everything crashing down, and destroy all of today\u2019s establishment.\" Allowing Trump to continue to be guided by Bannon in matters of national security will bring about the deaths of many innocent people. ",
 "script": "Hi, my name is [NAME] and I\u2019m a constituent from [CITY, ZIP]. \n\nI\u2019m calling today becuase I am outraged by the appointment of Steve Bannon to the National Security Council. I expect [Senator/Rep's Name]  to take an immediate stand against both Bannon's appointment and the removal of more experienced staff from the \"principals committee\".                           \n\nThank you for your hard work answering the phones.\n\n[IF LEAVING A VOICEMAIL: please leave your full street address to ensure your call is tallied] ",
 "categories": [{
   "name": "Foreign Affairs"
 }],
 "inactive": false,
 "outcomes": ["unavailable", "voicemail", "contact", "skip"]
 }
 
 */

struct Issue {
    let id: String
    let name: String
    let reason: String
    let script: String
    let category: Category?
    let inactive: Bool
    let contacts: [Contact]
    let outcomes: [Outcome]
}

extension Issue : JSONSerializable {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let reason = dictionary["reason"] as? String,
            let script = dictionary["script"] as? String,
            let contactsJSON = dictionary["contacts"] as? [JSONDictionary],
            let outcomesJSON = dictionary["outcomeModels"] as? [JSONDictionary],
            let categoriesJSON = dictionary["categories"] as? [JSONDictionary],
            let inactive = dictionary["inactive"] as? Bool
        else {
            print("Unable to parse JSON as Issue: \(dictionary)")
            return nil
        }
        
        let contacts = contactsJSON.flatMap({ Contact(dictionary: $0) })
        let outcomes = outcomesJSON.flatMap({ Outcome(dictionary: $0) })
        let category = categoriesJSON.flatMap({ Category(dictionary: $0) }).first
        
        self.init(id: id, name: name, reason: reason, script: script, category: category, inactive: inactive, contacts: contacts, outcomes: outcomes)
    }
}
