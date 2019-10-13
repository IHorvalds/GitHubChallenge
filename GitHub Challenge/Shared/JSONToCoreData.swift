//
//  JSONToCoreData.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 12/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import CoreData
import UIKit


struct JSONToCoreData {
    
    ///Discussion
    ///
    ///Use this function to deserialize the json from api requests for repositories. Pagination happens in the DownloadManager class, on a per api call basis.
    ///
    ///
    static func deserializeReposAndUsers(json: Data, container: NSPersistentContainer, sender: MasterTableViewController) throws {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: json, options: .fragmentsAllowed) as? [String : Any]
            
            container.performBackgroundTask { (context) in
                if let repos = jsonObject?["items"] as? [[String:Any]] { //array of repos
                    for repo in repos {
                        
                        let request: NSFetchRequest<Repository> = Repository.fetchRequest()
                        
                        let id              = repo["id"] as! Int32
                        request.predicate   = NSPredicate(format: "id = %d", id)
                        
                        let existingRepos = try? context.fetch(request)
                        
                        if existingRepos == nil || (existingRepos?.isEmpty ?? true) {
                            
                            //create a repo instance, but only if there isn't one with that id already
                            let r = Repository(context: context)
                            
                            r.id            = repo["id"] as! Int32
                            r.starsCount    = repo["stargazers_count"] as! Int32
                            r.title         = repo["full_name"] as! String
                            r.url           = repo["html_url"] as! String
                            r.apiUrl        = repo["url"] as! String
                            r.watchersCount = repo["watchers_count"] as! Int32
                            r.forksCount    = repo["forks_count"] as! Int32
                            
                            if let user = repo["owner"] as? [String : Any] {
                                
                                let request: NSFetchRequest<User> = User.fetchRequest()
                                
                                let id              = user["id"] as! Int32
                                request.predicate   = NSPredicate(format: "id = %d", id)
                                
                                let existingUsers = try? context.fetch(request)
                                
                                if existingUsers == nil || (existingUsers?.isEmpty ?? true) {
                                    let u = User(context: context)
                                    
                                    u.id        = user["id"] as! Int32
                                    u.name      = user["login"] as! String
                                    u.imageUrl  = user["avatar_url"] as? String
                                    u.url       = user["html_url"] as! String
                                    
                                    //relationships in the database
                                    u.addToRepos(r)
                                    u.addToContributesTo(r)
                                    
                                    r.addToContributors(u)
                                    r.owner = u
                                } else if let firstUser = existingUsers?[0] {
                                    firstUser.addToRepos(r)
                                    firstUser.addToContributesTo(r)
                                    
                                    r.addToContributors(firstUser)
                                    r.owner = firstUser
                                }
                            }
                            
                        }
                    }
                }
                
                try? context.save()
                
                DispatchQueue.main.async {
                    sender.updateUI()
                }
            }
            
        } catch {
            throw error
        }
        
    }
    
    static func deserializeLanguages(json: Data, container: NSPersistentContainer, sender: UITableViewController, repository: Repository) throws {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String: Any]
            
            container.performBackgroundTask { (context) in
                
                if let languageKeys = jsonObject?.keys {
                    
                    let languages = Array(languageKeys).sorted()
                    
                    for language in languages {
                        let request:NSFetchRequest<Language> = Language.fetchRequest()
                        request.predicate = NSPredicate(format: "name ==[c] %@", language as CVarArg)
                        
                        if  let existingLanguages = try? context.fetch(request), //there is a language with this name.
                            let lang = existingLanguages.first {
                            
                            if !(lang.reposContaining?.contains(repository as Any) ?? false) {
                                repository.addToLanguages(lang)
                                lang.addToReposContaining(repository)
                            }

                            
                        } else { //no language found with that name
                            
                            let lang = Language(context: context)
                            lang.name = language
                            lang.addToReposContaining(repository)
                        }
                        
                    }
                }
                
                try? context.save()
                
                DispatchQueue.main.async {
                    sender.tableView.reloadData()
                }
            }
        } catch {
            throw error
        }
        
    }
}
