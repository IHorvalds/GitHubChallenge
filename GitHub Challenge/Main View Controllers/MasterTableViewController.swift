//
//  MasterTableViewController.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 11/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData


class MasterTableViewController: UITableViewController {

    //when starting up:
    //display from core data or show loading indicator if there aren't records in the local database.
    //
    //in the background, fetch repos from github and when done, display it (on the main queue)
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<Repository>?
    let downloadManager = DownloadManager()
    
    //loading indicator for showing downloads
    let loadingIndicator = UIActivityIndicatorView(style: .gray)
    
    public func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Repository> = Repository.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "starsCount", ascending: false), NSSortDescriptor(key: "title", ascending: true)]
            
            fetchedResultsController = NSFetchedResultsController<Repository>(fetchRequest: request,
                                                                              managedObjectContext: context,
                                                                              sectionNameKeyPath: nil,
                                                                              cacheName: nil)
            
            do {
                try fetchedResultsController?.performFetch()
                tableView.reloadData()
            } catch {
                showError(title: "Database error", message: "There was an error getting the information from the local database. Make sure you're connected to the internet to see repos.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //if we haven't checked in at least 1 minute, we can check again
        //else, just display what we've got. Not much can happen in 1 minute, right?
        downloadManager.delegate = self
        
        let hasRunBefore = defaults.bool(forKey: hasRunKey)
        
        if !hasRunBefore { //only run it the first time. Maybe also useful for an eventual onboarding screen.
            buildDatabaseIfNecessary()
            defaults.set(true, forKey: hasRunKey)
        }
        
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indicatorButton = UIBarButtonItem(customView: loadingIndicator)
        navigationItem.rightBarButtonItem = indicatorButton
        
        tableView.register(UINib(nibName: "RepoTableViewCell", bundle: nil), forCellReuseIdentifier: repocellID)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count >= 1 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: repocellID, for: indexPath) as! RepoTableViewCell

        guard let repo = fetchedResultsController?.object(at: indexPath) else {
            cell.repoNameLabel.text = "Repo name"
            cell.starsLabel.text = "⭐"
            return cell
        }
        
        cell.repoNameLabel.text     = repo.title
        cell.userNameLabel.isHidden = (repo.owner == nil)
        cell.userNameLabel.text     = repo.owner?.name
        cell.starsLabel.text        = Double(repo.starsCount).kmFormatted + "⭐"
        
        if let imageUrl = repo.owner?.imageUrl {
            downloadManager.getImageFrom(urlString: imageUrl) { (data) in
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.userImageView.image = image
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            performSegue(withIdentifier: segueToRepoDetail, sender: cell)
        }
    }

}

extension MasterTableViewController { // MARK: - Helper functions
    fileprivate func buildDatabaseIfNecessary() {
        let lastChecked = (defaults.value(forKey: lastCheckedKey) as? Date) ?? Date.distantPast
        
        if Date.atLeastTenSeconds(between: lastChecked, and: Date()) {
            //we can download again
            buildDatabase()
            
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
    
    fileprivate func buildDatabase() {
        downloadManager.fetchRepos() { [weak self] (data) -> (Void) in
            guard let self = self else { return }
            
            
            do {
                if let container = self.container {
                    try JSONToCoreData.deserializeReposAndUsers(json: data, container: container, sender: self)
                }
            } catch {
                self.showError(title: "JSON Error", message: "Error decoding JSON.")
            }
            
            
        }
        
    }
}

extension MasterTableViewController: DownloadManagerDelegate {
    func didBeginDownloading(_ downloadManager: DownloadManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.loadingIndicator.startAnimating()
        }
    }
    
    func didEndDownloading(_ downloadManager: DownloadManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingIndicator.stopAnimating()
        }
    }
    
    func showErrorDownloading(_ downloadManager: DownloadManager, url: String, errorCode: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.showError(title: "Error downloading", message: "\(url) has thrown error code \(errorCode).")
            self.loadingIndicator.stopAnimating()
        }
    }
    
    
}

extension MasterTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension MasterTableViewController {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + view.frame.height) >= (scrollView.contentSize.height - 3 * 85) { //bottom of the viewable content is closer to the bottom of the content of the scrollview than 3 rows
            
            buildDatabaseIfNecessary()
            
        }
    }
}

extension MasterTableViewController { //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier == segueToRepoDetail,
            let destVC = segue.destination as? RepoDetailTableViewController,
            let cell = sender as? UITableViewCell,
            let index = tableView.indexPath(for: cell),
            let repo = fetchedResultsController?.object(at: index) {
            
            destVC.container = container
            destVC.downloadManager = downloadManager
            destVC.repository = repo
            
        }
    }
    
}
