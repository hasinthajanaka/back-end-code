//
//  ContactManager.swift
//  Yaalu
//
//  Created by Platinum Lanka Pvt Ltd on 2/22/17.
//  Copyright © 2017 Platinum Lanka Pvt Ltd. All rights reserved.
//

import UIKit
import Contacts

class ContactManager: NSObject {
    
    public lazy var contacts: [String] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        var contacts: [String] = []
        
        var manager = ContactManager.init()
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
                
                for contact in results {
                    let givenName = contact.givenName
                    let phoneNumbers = contact.phoneNumbers
                    var mobileNumber:String?
                    
                    for number in phoneNumbers {
                        if number.label == CNLabelPhoneNumberMobile {
                            mobileNumber = number.value.stringValue
                        }
                    }
                    if(mobileNumber != nil) {
                        mobileNumber = manager.format(phoneNumber: mobileNumber!)
                        contacts.append("\(givenName)-\(mobileNumber!)")
                    }
                }
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return contacts
    }()
    
    public func format(phoneNumber number:String) -> String{
        let phoneNo = number.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "")
        
        return phoneNo
    }
    
}
