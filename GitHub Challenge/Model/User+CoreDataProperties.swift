//
//  User+CoreDataProperties.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 11/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String //"html_url" in the json
    @NSManaged public var url: String
    @NSManaged public var imageUrl: String?
    @NSManaged public var contributesTo: NSSet?
    @NSManaged public var repos: NSSet?

}

// MARK: Generated accessors for contributesTo
extension User {

    @objc(addContributesToObject:)
    @NSManaged public func addToContributesTo(_ value: Repository)

    @objc(removeContributesToObject:)
    @NSManaged public func removeFromContributesTo(_ value: Repository)

    @objc(addContributesTo:)
    @NSManaged public func addToContributesTo(_ values: NSSet)

    @objc(removeContributesTo:)
    @NSManaged public func removeFromContributesTo(_ values: NSSet)

}

// MARK: Generated accessors for repos
extension User {

    @objc(addReposObject:)
    @NSManaged public func addToRepos(_ value: Repository)

    @objc(removeReposObject:)
    @NSManaged public func removeFromRepos(_ value: Repository)

    @objc(addRepos:)
    @NSManaged public func addToRepos(_ values: NSSet)

    @objc(removeRepos:)
    @NSManaged public func removeFromRepos(_ values: NSSet)

}
