//
//  ChurchViewController.swift
//  ChurchApp
//
//  Created by Jacob Schantz on 3/8/18.
//  Copyright © 2018 Jake Schantz. All rights reserved.
//

import UIKit

class ChurchViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var info: [String] = []
    var titles: [String] = []
    var churchName = "Church"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        getSermons()
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.tintColor = UIColor(red: 255/255, green: 220/255, blue: 55/255, alpha: 1)
    }
    
    
    func setupNav() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 220/255, blue: 55/255, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.view.backgroundColor = .white
    }
    
    
    func getSermons(){
        guard let url = URL(string: Constants.apiUrl)
            else{return}
        
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            if let validData = data{
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: validData, options: [])
                    if let validJson = jsonObject as? [String:Any] {
                        self.populateList(validJson)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    
    
    func populateList(_ json: [String:Any]){
        if let listOfChurches = json["churches"] as? [[String:Any]] {
            for eachChurch in listOfChurches {
                guard let attributesGroup = eachChurch["attributes"] as? [[String: String]]
                    else{return}
                for attributes in attributesGroup {
                    for eachAttribute in attributes {
                        titles.append(eachAttribute.key)
                        info.append(eachAttribute.value)
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}




extension ChurchViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChurchCell", for: indexPath) as! ChurchTableViewCell
        cell.mainLabel.text = info[indexPath.section]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
}



extension ChurchViewController : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

