//
//  ViewController.swift
//  trimAudio
//
//  Created by Appnap WS02 on 23/1/20.
//  Copyright © 2020 Appnap WS02. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

 

    @IBAction func downloadPressed(_ sender: Any) {
        let duration : Int64 = 60
        let starting : Int64 = 0
        
        
        audioURLParse(starting: starting, duration: duration, success:{(status,URL) in
            print("\(status) \(URL)")
        })
        
        
    }
    
    func audioURLParse(starting: Int64, duration: Int64, success: @escaping(_ status: Int, _ URL: URL) -> Void) -> Void
    {
        let preferredTimeScale : Int32 = 1
        let composition = AVMutableComposition()
        
        let strartingPoint : CMTime = CMTimeMake(value: starting, timescale: preferredTimeScale)
        let endingPoint : CMTime = CMTimeMake(value: duration, timescale: preferredTimeScale)
        
        do {
            let sourceUrl = Bundle.main.url(forResource: "UUU", withExtension: "m4a")!
            let asset = AVURLAsset(url: sourceUrl)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
            try audioCompositionTrack.insertTimeRange(CMTimeRangeMake(start: strartingPoint,
                                                                      duration: endingPoint), of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
        }
        
        // Get url for output
        let audioURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "out.m4a")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        }
        
        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputUrl
        
        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }
            
            DispatchQueue.main.async {
                // Present a UIActivityViewController to share audio file
                guard let outputURL = exportSession.outputURL else { return }
                let activityViewController = UIActivityViewController(activityItems: [outputURL], applicationActivities: [])
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        success(200, audioURL)
    }
    
}

