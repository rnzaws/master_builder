//
//  ViewController.swift
//  MasterBuilder
//
//  Created by Nitz, Ryan on 7/4/17.
//  Copyright © 2017 Nitz, Ryan. All rights reserved.
//

import UIKit


class ListViewController: UITableViewController {
    
    var TableData:Array< String > = Array < String >()
    var eventId = ""
    
    var updating = true
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        cell.textLabel?.text = TableData[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.eventId = TableData[indexPath.row]
        self.performSegue(withIdentifier: "viewItemSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itemViewController = segue.destination as! ItemViewController
        itemViewController.eventId = self.eventId
        self.updating = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadContent()
    }
    
    func loadContent() -> Void {
        
        let json: [String: Any] = [
            "AttributesToGet": [ "EventId", "CreateTime" ],
            "ReturnConsumedCapacity": "TOTAL",
            "TableName": "event-content-btest",
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "https://vfcr6coqwk.execute-api.us-east-1.amazonaws.com/prod/content")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                for item in responseJSON["Items"] as! [Dictionary<String, Dictionary<String, String>>] {
                    if let checkEventId = item["EventId"]?["S"] as String! {
                        print("eventId: " + checkEventId)
                        if self.TableData.contains(checkEventId) == false {
                            self.TableData.append(checkEventId)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            if self.updating {
                sleep(1)
                DispatchQueue.main.async {
                    self.loadContent()
                }
            }
        }
        
        task.resume()
    }
}

