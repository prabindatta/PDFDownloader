//
//  DownloadService.swift
//  PDFDownloader
//
//  Created by Prabin Kumar Datta on 11/02/18.
//  Copyright © 2018 Prabin Kumar Datta. All rights reserved.
//

import Foundation

// Downloads song snippets, and stores in local file.
// Allows cancel, pause, resume download.
class DownloadService {

  // SearchViewController creates downloadsSession
  var downloadsSession: URLSession!
  var activeDownload: Download?

  // MARK: - Download methods called by TrackCell delegate methods
    func getDownloadSize(url: URL, completion: @escaping (Int64, Error?) -> Void) {
        let timeoutInterval = 15.0
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            completion(contentLength, error)
            }.resume()
    }
    
  func startDownload(_ url: URL) {
    // 1
    let download = Download(url: url)
    // 2
    download.task = downloadsSession.downloadTask(with: url)
    // 3
    download.task!.resume()
    // 4
    download.isDownloading = true
    // 5
    activeDownload = download
  }

  func pauseDownload(_ url: URL) {
    guard let download = activeDownload else { return }
    if download.isDownloading {
      download.task?.cancel(byProducingResumeData: { data in
        download.resumeData = data
      })
      download.isDownloading = false
    }
  }

  func cancelDownload(_ url: URL) {
    if let download = activeDownload {
      download.task?.cancel()
      activeDownload = nil
    }
  }

  func resumeDownload(_ url: URL) {
    guard let download = activeDownload else { return }
    if let resumeData = download.resumeData {
      download.task = downloadsSession.downloadTask(withResumeData: resumeData)
    } else {
      download.task = downloadsSession.downloadTask(with: download.url)
    }
    download.task!.resume()
    download.isDownloading = true
  }

}
