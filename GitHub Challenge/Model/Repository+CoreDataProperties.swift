//
//  Repository+CoreDataProperties.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 11/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//
//

import Foundation
import CoreData


extension Repository {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Repository> {
        return NSFetchRequest<Repository>(entityName: "Repository")
    }

    @NSManaged public var title: String
    @NSManaged public var id: Int32
    @NSManaged public var url: String
    @NSManaged public var starsCount: Int32 //"stargazers_count" in json
    @NSManaged public var contributors: NSSet?
    @NSManaged public var owner: User?
    @NSManaged public var apiUrl: String
    @NSManaged public var readme: String?
    @NSManaged public var forksCount: Int32
    @NSManaged public var watchersCount: Int32
    @NSManaged public var languages: NSSet?

}

// MARK: Generated accessors for contributors
extension Repository {

    @objc(addContributorsObject:)
    @NSManaged public func addToContributors(_ value: User)

    @objc(removeContributorsObject:)
    @NSManaged public func removeFromContributors(_ value: User)

    @objc(addContributors:)
    @NSManaged public func addToContributors(_ values: NSSet)

    @objc(removeContributors:)
    @NSManaged public func removeFromContributors(_ values: NSSet)
    
    @objc(addLanguagesObject:)
    @NSManaged public func addToLanguages(_ value: Language)
    
    @objc(removeLanguagesObject:)
    @NSManaged public func removeFromLanguages(_ value: Language)

}
