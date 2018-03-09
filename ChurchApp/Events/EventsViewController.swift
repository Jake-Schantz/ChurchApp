//
//  EventsViewController.swift
//  ChurchApp
//
//  Created by Jacob Schantz on 3/6/18.
//  Copyright © 2018 Jake Schantz. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {


    @IBOutlet weak var collectionView: UICollectionView!
    let months: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var currentYear: Int = 2018
    var eventsList: [Event] = []
    let lightBlue = UIColor(red: 75/255, green: 150/255, blue: 230/255, alpha: 1)
    
    
    func findCurrentYear() -> Int{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return Int(formatter.string(from: date))!
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.tintColor = lightBlue
    }
    
    
    func setupNav() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = lightBlue
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.view.backgroundColor = .white
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentYear = findCurrentYear()
        setupNav()
        refresh()
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.currentYear = findCurrentYear()
        navigationItem.largeTitleDisplayMode = .always
//        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    func styleNavBar(){
        self.title = "\(currentYear)"
        let backButton = UIBarButtonItem(title: "\(currentYear-1)", style: .done, target: self, action: #selector(backButtonTapped))
        let forwardButton = UIBarButtonItem(title: "\(currentYear+1)", style: .done, target: self, action: #selector(forwardButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = forwardButton
    }
    @objc func backButtonTapped(){
        currentYear -= 1
        refresh()
    }
    @objc func forwardButtonTapped(){
        currentYear += 1
        refresh()
    }

    
    func refresh(){
        eventsList.removeAll()
        collectionView.reloadData()
        styleNavBar()
        getEvents()
    }
    
    
    func getEvents(){
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
        if let events = json["events"] as? [String:Any],
            let selectedYear = events["\(currentYear)"] as? [[String:Any]] {
            for eachEvent in selectedYear {
                guard let title = eachEvent["title"] as? String,
                    let month = eachEvent["month"] as? String,
                    let day = eachEvent["day"] as? String
                    else{return}
                let newEvent = Event(title: title, date: "\(day).\(month).\(currentYear)")
                eventsList.append(newEvent)
            }
        
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    
    func isToday(inputDate: String) -> Bool{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from: date)
        return result == inputDate
    }
    
    func hasEvent(inputDate: String) -> Bool{
        for event in eventsList {
            if event.date == inputDate {
                return true
            }
        }
        return false
    }
    
    
    func stringDate(from indexPath: IndexPath) -> String {
        let day = (indexPath.row+1 < 10) ? "0\(indexPath.row+1)" : "\(indexPath.row+1)"
        let month = (indexPath.section+1 < 10) ? "0\(indexPath.section+1)" : "\(indexPath.section+1)"
        return "\(day).\(month).\(currentYear)"
    }
    
    
    func isLeapYear(_ year: Int) -> Bool {
        let isLeapYear = ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
        return isLeapYear
    }
}



extension EventsViewController : UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ((section+1)%2 == 0){
            let daysInFeb = (isLeapYear(currentYear) ? 29 : 28)
            return section == 1 ? daysInFeb : 30
        }
        else {
            return 31
        }
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCollectionViewCell", for: indexPath) as! DayCollectionViewCell
        
        cell.backgroundColor = isToday(inputDate: stringDate(from: indexPath)) ? lightBlue : .clear
        if isToday(inputDate: stringDate(from: indexPath)) {
            cell.layer.cornerRadius = ((collectionView.frame.width/7)-5)/2
            cell.layer.masksToBounds = true
            cell.numberLabel.textColor = .white
        }
        cell.eventIndicator.backgroundColor = hasEvent(inputDate: stringDate(from: indexPath)) ? lightBlue : .clear
        if cell.eventIndicator.backgroundColor == cell.backgroundColor {
            cell.eventIndicator.backgroundColor = .white
        }
        cell.numberLabel.text = String(indexPath.row+1)
        return cell
    }
}


extension EventsViewController : UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = ((collectionView.frame.width)/7)-5
        return CGSize(width: itemSize, height: itemSize)
    }

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionReusableView", for: indexPath) as! HeaderCollectionReusableView
            headerView.titleLabel.text = months[indexPath.section]
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if !hasEvent(inputDate: stringDate(from: indexPath)) {
            return
        }
        if let dayVC = storyBoard.instantiateViewController(withIdentifier: "DayViewController") as? DayViewController {
            for event in eventsList {
                if event.date == stringDate(from: indexPath) {
                    dayVC.events.append(event)
                }
            }
            dayVC.title = "\(months[indexPath.section]) \(indexPath.row+1)"
            self.navigationController?.pushViewController(dayVC, animated: true)
        }
    }
}
