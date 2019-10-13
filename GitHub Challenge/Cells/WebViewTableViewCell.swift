//
//  WebViewTableViewCell.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 13/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import WebKit

protocol WebViewCellDelegate {
    func didUpdateWebView(_ webView: WKWebView, height: CGFloat)
}

class WebViewTableViewCell: UITableViewCell {

    
    @IBOutlet weak var webView: WKWebView!
    
    var delegate: WebViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        webView.scrollView.isScrollEnabled  = false
        webView.scrollView.bounces          = false
        webView.navigationDelegate          = self
    }
}

extension WebViewTableViewCell: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webView.evaluateJavaScript("document.readyState", completionHandler: { [weak self] (complete, error) in
            guard let self = self else { return }
            
            if complete != nil {
                
                let size = webView.scrollView.contentSize
                
                self.delegate?.didUpdateWebView(webView, height: size.height)
            }
        })
    }
}
