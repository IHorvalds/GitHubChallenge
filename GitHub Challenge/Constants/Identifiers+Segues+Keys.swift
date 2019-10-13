//
//  Identifiers+Segues+Keys.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 11/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation

// table view cells ids
let repocellID = "repocell"
let repoHeaderCellID = "repoHeaderCell"
let textCellID = "textCell"
let languagesCellID = "languagesCell"
let webViewCellID = "webViewCell"

// segue ids
let segueToRepoDetail = "seguetorepodetail"
let segueToWebView = "seguetowebview"

//user defaults - for saving the last checked date.
let defaults = UserDefaults.standard
let hasRunKey = "hasRunBeforeKey"
let lastCheckedKey = "lastCheckedKey"
let nextPageKey = "next page key for link header" //somehow getting weird value here
let lastPageKey = "last page key for link header"
