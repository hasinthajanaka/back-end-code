//
//  AudioPlayManagr.swift
//  Yaalu
//
//  Created by Platinum Lanka Pvt Ltd on 2/23/17.
//  Copyright © 2017 Platinum Lanka Pvt Ltd. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioPlayerManagerDelegate {
    func playerDidFinishedPlaying(player:AVAudioPlayer, succfully:Bool) ->Void
}


class AudioPlayManager: NSObject, AVAudioPlayerDelegate{
    
    static let sharedManager = AudioPlayManager()
    
    //var player: AVAudioPlayer?
    var player: AVPlayer?
    
    var mDelegate: AudioPlayerManagerDelegate?
    
    var urlString: String?
    
    var totalDuration: Int?
    
    var progressView: UIProgressView?
    
    var timer: Timer?
    
    func setup(urlString:String, duration:Int, progressView: UIProgressView) {
        
        do {
            if(AFNetworkReachabilityManager.shared().isReachable) {
                let url = URL(string:urlString)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
                player = AVPlayer(playerItem: playerItem)

            }
            
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.pause()
    }
    
    func currentTime() -> TimeInterval {
        if(player == nil) {
            return TimeInterval(floatLiteral: 0)
        } else {
            let currentItem = player?.currentItem;
         return CMTimeGetSeconds((currentItem?.currentTime())!)
        }
    }
    
    func download(Url url:String, completion: @escaping (_ result: Bool, _ message: String) -> Void) {
        
        if(!AFNetworkReachabilityManager.shared().isReachable) {
            return
        }
        
        if(url == "") {
            completion(false, "Please select a Ring Tone !")
        }
        
        if let audioUrl = URL(string: url) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                completion(false, "The file already exists at path")
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        completion(true, "")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        completion(false, "")
                    }
                }).resume()
            }
        }
    }
    
    //MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        mDelegate?.playerDidFinishedPlaying(player: player, succfully: flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription)
    }
    
    
}
