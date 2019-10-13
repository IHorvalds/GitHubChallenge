//
//  RepoDetailTableViewController.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 11/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import SafariServices

class RepoDetailTableViewController: UITableViewController {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var downloadManager: DownloadManager?
    
    var repository: Repository?
    
    var readMeHeight: CGFloat = UITableView.automaticDimension
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLanguagesIfNecessary()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = repository?.title
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .systemGroupedBackground
        } else {
            tableView.backgroundColor = .groupTableViewBackground
        }
        
        tableView.register(UINib(nibName: "RepoHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: repoHeaderCellID)
        tableView.register(UINib(nibName: "TextViewTableViewCell", bundle: nil), forCellReuseIdentifier: languagesCellID)
        tableView.register(UINib(nibName: "WebViewTableViewCell", bundle: nil), forCellReuseIdentifier: webViewCellID)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3 //1. Name + picture; 2. Languages, watchers, stars, forks, repo link, user link; 3. Readme
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 4
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 100
            }
            
            return 50
        case 1:
            if indexPath.row == 0 {
                return UITableView.automaticDimension
            }
            
            return 50
        default:
            return readMeHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: //repo owner
                let headerCell = tableView.dequeueReusableCell(withIdentifier: repoHeaderCellID) as! RepoHeaderTableViewCell
                
                if let owner = repository?.owner {
                    if let imageUrl = owner.imageUrl {
                        downloadManager?.getImageFrom(urlString: imageUrl, completionHandler: { (data) in
                            
                            if let uiImage = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    headerCell.userImageView.image = uiImage
                                }
                            }
                        })
                    }
                    
                    headerCell.userNameLabel.text = owner.name
                } else {
                    headerCell.userNameLabel.text = "Anonymous"
                }
                
                cell = headerCell
            case 1: //owner link
                cell = tableView.dequeueReusableCell(withIdentifier: textCellID)!
                
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = .link
                } else {
                    cell.detailTextLabel?.textColor = .systemBlue
                }
                
                cell.accessoryType = .disclosureIndicator
                
                cell.textLabel?.text        = "User URL"
                cell.detailTextLabel?.text  = repository?.owner?.url
                
            default: //repo link
                cell = tableView.dequeueReusableCell(withIdentifier: textCellID)!
                
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = .link
                } else {
                    cell.detailTextLabel?.textColor = .systemBlue
                }
                
                cell.accessoryType = .disclosureIndicator
                
                cell.textLabel?.text        = "Repo URL"
                cell.detailTextLabel?.text  = repository?.url
            }
            
        case 1:
            switch indexPath.row {
            case 0: //languages
                let languageCell = tableView.dequeueReusableCell(withIdentifier: languagesCellID) as! TextViewTableViewCell
                
                if  let id = repository?.id,
                    let context = container?.viewContext {
                    
                    let request: NSFetchRequest<Language> = Language.fetchRequest()
                    request.predicate = NSPredicate(format: "any reposContaining.id == %d", id)
                    
                    if let langs = try? context.fetch(request) {
                        var languages = [String]()
                        
                        for lang in langs {
                            languages.append(lang.name)
                        }
                        
                        languageCell.textView.text = languages.joined(separator: ", ")
                        
                        
                        if #available(iOS 13.0, *) {
                            languageCell.textView.textColor = .systemIndigo
                        } else {
                            languageCell.textView.textColor = .purple
                        }
                        
                    } else {
                        languageCell.textView.text = "Languages"
                    }
                }
                
                cell = languageCell
            case 1://watchers
                cell = tableView.dequeueReusableCell(withIdentifier: textCellID)!
                
                cell.textLabel?.text = "Watchers"
                cell.detailTextLabel?.text = (repository?.watchersCount != nil) ? "\(repository!.watchersCount) 👀" : "0 👀"
            case 2://stars
                cell = tableView.dequeueReusableCell(withIdentifier: textCellID)!
                
                cell.textLabel?.text = "Stars"
                cell.detailTextLabel?.text = (repository?.starsCount != nil) ? "\(repository!.starsCount) ⭐️" : "0 ⭐️"
            case 3: //forks
                cell = tableView.dequeueReusableCell(withIdentifier: textCellID)!
                
                cell.textLabel?.text = "Forks"
                cell.detailTextLabel?.text = (repository?.forksCount != nil) ? "\(repository!.forksCount) 🍴" : "0 🍴"
            default:
                break
            }
        default://readme
            let webCell = tableView.dequeueReusableCell(withIdentifier: webViewCellID) as! WebViewTableViewCell
            
            webCell.delegate = self
            if let readme = repository?.readme {
                webCell.webView.loadHTMLString(readme, baseURL: nil)
            }
            
            cell = webCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, indexPath.row != 0 {
            let urlString = (indexPath.row == 1) ? repository?.owner?.url : repository?.url
            
            if let url = urlString {
                showSafari(for: url)
            }
        }
    }

}

extension RepoDetailTableViewController { //MARK: - Helper functions
    
    fileprivate func getLanguagesIfNecessary() {
        let lastChecked = (defaults.value(forKey: lastCheckedKey) as? Date) ?? Date.distantPast
        
        if Date.atLeastTwoSeconds(between: lastChecked, and: Date()) {
            //we can download again
            getLanguages()
            getReadMe()
            
            //and set lastChecked to now
            defaults.set(Date(), forKey: lastCheckedKey)
        } else {
            showError(title: "Wait a second", message: "Too many requests at once. Take a breath. :D")
        }
    }
    
    fileprivate func showError(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func getLanguages() {
        
        if var url = repository?.apiUrl {
            url = url + "/languages"
            
            downloadManager?.fetchLanguagesForRepo(urlString: url) { [weak self] (data) -> (Void) in
                guard let self = self else { return }
                
                
                do {
                    if  let container = self.container,
                        let repo = self.repository {
                        try JSONToCoreData.deserializeLanguages(json: data, container: container, sender: self, repository: repo)
                    }
                } catch {
                    self.showError(title: "JSON Error", message: "Error decoding JSON.")
                }
            }
        }
    }
    
    fileprivate func getReadMe() {
        if var url = repository?.apiUrl {
            url = url + "/readme"
            
            downloadManager?.getReadMeForRepo(urlString: url) { [weak self] (data) in
                guard let self = self else { return }
                
                if let readMeString = String(data: data, encoding: .utf8) {
                    self.repository?.readme = readMeString
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    fileprivate func showSafari(for urlString: String) {
        if let url = URL(string: urlString) {
            
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
            
        } else {
            showError(title: "Oops", message: "The link is wrong. Can't find anything there.")
        }
    }
}

extension RepoDetailTableViewController: WebViewCellDelegate {
    func didUpdateWebView(_ webView: WKWebView, height: CGFloat) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.readMeHeight = height
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
}
