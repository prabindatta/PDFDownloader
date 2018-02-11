//
//  ViewController.swift
//  PDFDownloader
//
//  Created by Prabin Kumar Datta on 11/02/18.
//  Copyright © 2018 Prabin Kumar Datta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var downloadSizeLabel: UILabel!
    let downloadService = DownloadService()
    
    let pdfUrl = URL(string: "http://publications.gbdirect.co.uk/c_book/thecbook.pdf")
    //http://www.pdf995.com/samples/pdf.pdf
    //"https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview32/v4/7f/2f/27/7f2f27bf-1af7-4d46-a767-d989eadc2085/mzaf_7107069143306100047.plus.aac.p.m4a")//"
    
    lazy var downloadsSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
//        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
      let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.progressView.setProgress(0, animated: false)
        downloadService.downloadsSession = downloadsSession
        guard let url = pdfUrl else { return }
        downloadService.getDownloadSize(url: url) { (size, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.downloadSizeLabel.text = ByteCountFormatter.string(fromByteCount: size,
                                                                       countStyle: .file)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTappedDownload(_ sender: Any) {
        guard let url = pdfUrl else { return }
        downloadService.startDownload(url)
    }
    
    @IBAction func didTappedPause(_ sender: Any) {
        guard let url = pdfUrl else { return }
        downloadService.pauseDownload(url)
    }
    
    @IBAction func didTappedResume(_ sender: Any) {
        guard let url = pdfUrl else { return }
        downloadService.resumeDownload(url)
    }
    
    @IBAction func didTappedCancel(_ sender: Any) {
        guard let url = pdfUrl else { return }
        downloadService.cancelDownload(url)
    }
    
}

extension ViewController: URLSessionDownloadDelegate {
    // Stores downloaded file
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownload?.url
        downloadService.activeDownload = nil
        // 2
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
//            download?.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        // 4
//        if let index = download?.track.index {
//            DispatchQueue.main.async {
//                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
//            }
//        }
    }
    
    // Updates progress info
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // 1
        guard let url = downloadTask.originalRequest?.url,
            let download = downloadService.activeDownload else { return }
        // 2
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        // 3
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                                  countStyle: .file)
        // 4
        DispatchQueue.main.async {
            self.progressView.setProgress(download.progress, animated: true)
//            if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.track.index,
//                                                                       section: 0)) as? TrackCell {
//                trackCell.updateDisplay(progress: download.progress, totalSize: totalSize)
            }
    }
}

// MARK: - URLSessionDelegate

extension ViewController: URLSessionDelegate {
    
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
}

