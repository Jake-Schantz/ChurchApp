//
//  MembersViewController.swift
//  ChurchApp
//
//  Created by Jacob Schantz on 3/8/18.
//  Copyright © 2018 Jake Schantz. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var members: [Member] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        tableView.dataSource = self
        tableView.delegate = self
        getSermons()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.largeTitleDisplayMode = .always
//        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.tintColor = UIColor(red: 130/255, green: 190/255, blue: 115/255, alpha: 1)
    }
    
    
    func setupNav() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 130/255, green: 190/255, blue: 115/255, alpha: 1)
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
        if let listOfMembers = json["members"] as? [[String:Any]] {
            for eachMember in listOfMembers {
                guard let name = eachMember["name"] as? String,
                    let attributesGroup = eachMember["attributes"] as? [[String: String]]
                else{return}
                let newMember = Member(name: name)
                for attributes in attributesGroup {
                    for eachAttribute in attributes {
                        newMember.titles.append(eachAttribute.key)
                        newMember.info.append(eachAttribute.value)
                    }
                }
                members.append(newMember)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}



extension MembersViewController : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
        let selectedMember = members[indexPath.row]
        cell.textLabel?.text = selectedMember.name
        return cell
    }
    
}



extension MembersViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let detailVC = storyBoard.instantiateViewController(withIdentifier: "MemberDetailViewController") as? MemberDetailViewController {
            detailVC.selectedMember = members[indexPath.row]
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
