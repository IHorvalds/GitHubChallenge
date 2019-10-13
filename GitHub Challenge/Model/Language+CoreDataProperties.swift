//
//  Language+CoreDataProperties.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 13/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//
//

import Foundation
import CoreData


extension Language {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Language> {
        return NSFetchRequest<Language>(entityName: "Language")
    }

    @NSManaged public var name: String
    @NSManaged public var reposContaining: NSSet?

}

// MARK: Generated accessors for reposContaining
extension Language {

    @objc(addReposContainingObject:)
    @NSManaged public func addToReposContaining(_ value: Repository)

    @objc(removeReposContainingObject:)
    @NSManaged public func removeFromReposContaining(_ value: Repository)

    @objc(addReposContaining:)
    @NSManaged public func addToReposContaining(_ values: NSSet)

    @objc(removeReposContaining:)
    @NSManaged public func removeFromReposContaining(_ values: NSSet)

}
