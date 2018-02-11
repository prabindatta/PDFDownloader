//
//  Download.swift
//  PDFDownloader
//
//  Created by Prabin Kumar Datta on 11/02/18.
//  Copyright © 2018 Prabin Kumar Datta. All rights reserved.
//

import Foundation

// Download service creates Download objects
class Download {

  var url: URL
  init(url: URL) {
    self.url = url
  }

  // Download service sets these values:
  var task: URLSessionDownloadTask?
  var isDownloading = false
  var resumeData: Data?

  // Download delegate sets this value:
  var progress: Float = 0

}
