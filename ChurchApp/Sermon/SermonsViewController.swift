//
//  ViewController.swift
//  66-foursquareAPI
//
//  Created by Jacob Schantz on 11/9/17.
//  Copyright © 2017 Jacob Schantz. All rights reserved.


import UIKit
import MapKit
import AVFoundation

class SermonsViewController: UIViewController {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var sermons: [Sermon] = []
    var currentSermon: Sermon?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        toolBar.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        playButton.isEnabled = false
        getSermons()
    }
    
    
    func play(){
        AppDelegate.getAppDelegate().player?.play()
        AppDelegate.getAppDelegate().setupNowPlaying(title: currentSermon?.title ?? "Unknown", imageString: "Lockscreen")
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer {
            if player == AppDelegate.getAppDelegate().player && keyPath == "status" {
                if AppDelegate.getAppDelegate().player?.status == .readyToPlay {
                    playButton.isEnabled = true
                    activityIndicator.stopAnimating()
                } else if AppDelegate.getAppDelegate().player?.status == .failed {
                    playButton.isEnabled = true
                }
            }
        }
    }

    
    @IBAction func playButtonTapped(_ sender: Any) {
        play()
    }
    @IBAction func pauseButtonTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().player?.pause()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.tintColor = UIColor(red: 215/255, green: 90/255, blue: 90/255, alpha: 1)
    }

    
    
    func setupNav() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 215/255, green: 90/255, blue: 90/255, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.view.backgroundColor = .white
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.lightGray
        tabBarController?.tabBar.barTintColor = .white
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.largeTitleDisplayMode = .always
//        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = true
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
        if let listOfSermons = json["sermons"] as? [[String:Any]] {
            for eachSermon in listOfSermons{
                guard let title = eachSermon["title"] as? String,
                    let author = eachSermon["author"] as? String,
                    let url = eachSermon["url"] as? String
                    else{return}
                let newSermon = Sermon(title: title, author: author, url: url)
                sermons.append(newSermon)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}



extension SermonsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sermons.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currentSermon = sermons[indexPath.row]
        cell.textLabel?.text = currentSermon.title
        cell.detailTextLabel?.text = currentSermon.author
        cell.imageView?.image = #imageLiteral(resourceName: "bill")
        return cell
    }
    
}



extension SermonsViewController : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSermon = sermons[indexPath.row]
        guard let url = URL(string: sermons[indexPath.row].url)
            else {
                print("bad Url")
                return
        }
        toolBar.isHidden = false
        AppDelegate.getAppDelegate().player = AVPlayer(url: url)
        AppDelegate.getAppDelegate().player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        activityIndicator.startAnimating()
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


