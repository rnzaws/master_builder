//
//  ViewController.swift
//  MasterBuilder
//
//  Created by Nitz, Ryan on 7/4/17.
//  Copyright © 2017 Nitz, Ryan. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer

class ItemViewController: UIViewController {

    @IBAction func nayVote(_ sender: Any) {
        print("voting nay")
        self.vote(yea: 0, nay: 1)
    }
    
    @IBAction func yeaVote(_ sender: Any) {
        print("voting yea")
        self.vote(yea: 1, nay: 0)
    }
    
    @IBOutlet weak var yeaCount: UILabel!
    
    @IBOutlet weak var nayCount: UILabel!
    
    var moviePlayer: MPMoviePlayerController?
    
    var eventId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playVideo()
        self.loadVotes()
    }
    
    func playVideo() {
        let path = "https://d77tspw0ctuxu.cloudfront.net/hls_83232342342-" + eventId + ".mp4.m3u8"
        
        guard let url = URL(string: path) else {
            print("unable to get")
            return
        }
        
        let screenSize: CGRect = UIScreen.main.bounds
        let videoView = UIView(frame: CGRect(x: 0, y: 40, width: screenSize.width, height: 500))

        moviePlayer = MPMoviePlayerController(contentURL: url)
        if let player = moviePlayer {
            player.view.frame = videoView.bounds
            player.prepareToPlay()
            player.scalingMode = .aspectFill
            videoView.addSubview(player.view)
        }
        
        self.view.addSubview(videoView)
    }
    
    func iso8601Str() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    

    func vote(yea: Int, nay: Int) -> Void {
        
        let data: [String: Any] = [
            "yea": yea,
            "nay": nay,
            "eventId": self.eventId,
            "userId": "somethingnew"
        ]
        
        let dataStr = try? JSONSerialization.data(withJSONObject: data)
    
        let json: [String: String] = [
            "PartitionKey": self.iso8601Str(),
            "StreamName": "raw-votes-btest",
            "Data": dataStr!.base64EncodedString(),
            ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "https://vfcr6coqwk.execute-api.us-east-1.amazonaws.com/prod/vote")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(responseJSON)
        }
 
        task.resume()
    }
    
    func loadVotes() -> Void {
        
        let json: [String: Any] = [
            "ConsistentRead": false,
            "ReturnConsumedCapacity": "TOTAL",
            "TableName": "event-votes-btest",
            "ProjectionExpression": "NayCount, YeaCount",
            "Key": [
                "EventId": [
                    "S": self.eventId
                ]
            ]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "https://vfcr6coqwk.execute-api.us-east-1.amazonaws.com/prod/votes")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let response = responseJSON as? NSDictionary {
                
                if var item = response["Item"] as? NSDictionary {
                    let nayCountRaw = item["NayCount"] as! NSDictionary
                    let yeaCountRaw = item["YeaCount"] as! NSDictionary
                    
                    print(yeaCountRaw["N"] as! String)
                    print(nayCountRaw["N"] as! String)
                    
                    if self.yeaCount != nil && self.yeaCount.text != nil {
                        self.yeaCount.text = yeaCountRaw["N"] as! String
                        self.yeaCount.setNeedsDisplay()
                    } else {
                        print("null yeaCount")
                        
                    }
                    
                    if self.nayCount != nil && self.nayCount.text != nil {
                        self.nayCount.text = nayCountRaw["N"] as! String
                        self.nayCount.setNeedsDisplay()
                    } else {
                        print("null nayCount")
                    }
                }
            }
            
            sleep(2)
            DispatchQueue.main.async {
                self.loadVotes()
            }
            
        }
        
        task.resume()
    }
    
}

