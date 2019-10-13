//
//  DownloadManager.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 11/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation
import Network

protocol DownloadManagerDelegate {
    func didBeginDownloading(_ downloadManager: DownloadManager)
    func didEndDownloading(_ downloadManager: DownloadManager)
    func showErrorDownloading(_ downloadManager: DownloadManager, url: String, errorCode: Int)
}


///Discussion
///
///Create a single entity and pass it around to download from links.
///
class DownloadManager {
    
    //we can save this in UD because we're only even using 1 instance of this class.
    var nextPage = (defaults.value(forKey: nextPageKey) as? Int) ?? 1
    var lastPage = (defaults.value(forKey: lastPageKey) as? Int) ?? 1
    var delegate: DownloadManagerDelegate?
    
    var errorCode = 0
    
    ///Discussion
    ///
    ///You have to set the delegate first. Use the completionHandler to process the data from the url.
    ///Paginated by default.
    ///
    /// - Parameters:
    ///     - completionHandler: Use it for processing the data.
    ///
    func fetchRepos(completionHandler: @escaping (Data) -> (Void)) {
        
        //URL for the request already exists. No need to bother too much about the local database
        let urlString = "https://api.github.com/search/repositories?q=android&sort=stars&order=desc"
        
        let session = URLSession.shared
        
        if  lastPage >= nextPage, let url = URL(string: urlString + "&page=\(nextPage)") {
            let request = URLRequest(url: url)
            print(url)
            
            let task = session.dataTask(with: request) { [weak self] (data, response, err) in
                guard let self = self else { return }
                
                if let e = err { // we've got an error.
                    if self.errorCode == 0 { // we haven't shown an error yet
                        self.delegate?.showErrorDownloading(self, url: urlString, errorCode: (e as NSError).code)
                        self.errorCode = (e as NSError).code
                    }
                }
                
                guard   err == nil,
                        let res = (response as? HTTPURLResponse) else { return } //no error and we're on http
                
                self.errorCode = 0 // resetting error code so we can show the error after having a connection
                
                //setting the last page and next page from the Link header.
                let _ = (res.allHeaderFields["Link"] as! String).split(separator: ",").map { (link) -> Void in
                    
                    if  link.contains("next"),
                        var l = link.split(separator: ";")[0].split(separator: "=").last {
                        
                        l.removeAll(where: {$0 == ">"})
                        self.nextPage = Int(String(l))!
                        defaults.set(self.nextPage, forKey: nextPageKey)
                        return
                    }
                    
                    if  link.contains("last"),
                        var l = link.split(separator: ";")[0].split(separator: "=").last {
                        
                        l.removeAll(where: {$0 == ">"})
                        self.lastPage = Int(String(l))!
                        defaults.set(self.lastPage, forKey: lastPageKey)
                        return
                    }
                }
                
                if res.statusCode == 200 { // we got a response
                    
                    self.delegate?.didEndDownloading(self) //let our delegate know we finished downloading
                                                           //and it should respond accordingly
                    
                    if let data = data {
                        completionHandler(data)
                    }
                    
                } else {
                    self.delegate?.showErrorDownloading(self, url:  urlString, errorCode: res.statusCode)
                }
                
                if self.nextPage == self.lastPage { //when we request the last page, we cycle back o the first page
                    self.nextPage = 1
                }
            }
            self.delegate?.didBeginDownloading(self) //let out delegate know we started downloading. Maybe start a loading indicator
            task.resume()
        }
    }
    
    private func baseFetchFromURL(urlString: String, completionHandler: @escaping (Data) -> Void) {
        let session = URLSession.shared
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            
            let task = session.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }
                
                if let e = error {
                    if self.errorCode == 0 {
                        self.errorCode = (e as NSError).code
                    }
                }
                
                guard   error == nil,
                        let res = (response as? HTTPURLResponse) else { return }
                
                self.errorCode = 0 // if we're here, we've got internet.
                
                if res.statusCode == 200 {
                    self.delegate?.didEndDownloading(self)
                    
                    if let data = data {
                        completionHandler(data)
                    }
                } else {
                    self.delegate?.showErrorDownloading(self, url: urlString, errorCode: res.statusCode)
                }
            }
            
            delegate?.didBeginDownloading(self)
            
            task.resume()
        }
    }
    
    func getImageFrom(urlString: String, completionHandler: @escaping (Data) -> Void) {
        baseFetchFromURL(urlString: urlString, completionHandler: completionHandler)
    }
    
    func fetchLanguagesForRepo(urlString: String, completionHandler: @escaping (Data) -> Void) {
        baseFetchFromURL(urlString: urlString, completionHandler: completionHandler)
    }
    
    func getReadMeForRepo(urlString: String, completionHandler: @escaping (Data) -> Void) {
        let session = URLSession.shared
        
        if let url = URL(string: urlString) {
            
            var request = URLRequest(url: url)
            request.setValue("application/vnd.github.html", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }
                
                if let e = error {
                    if self.errorCode == 0 {
                        self.errorCode = (e as NSError).code
                    }
                }
                
                guard   error == nil,
                        let res = (response as? HTTPURLResponse) else { return }
                
                self.errorCode = 0
                
                if res.statusCode == 200 {
                    self.delegate?.didEndDownloading(self)
                    
                    if let data = data {
                        completionHandler(data)
                    }
                } else {
                    self.delegate?.showErrorDownloading(self, url: urlString, errorCode: res.statusCode)
                }
            }
            
            delegate?.didBeginDownloading(self)
            
            task.resume()
            
        }
    }
}
