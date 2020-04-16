//
//  MainViewController.swift
//  ai 11
//
//  Created by Youngmok Cho on 2020-03-31.
//  Copyright © 2020 Youngmok Cho. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let sampleData = SampleData()
    
    
    // When MainBoard is first generated, this fucntion is called
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    // viewWillAppear is from UIViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // viewWillDisappear is from UIViewController
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sampleData.samples.count
    }
    
    // Return Cell in UITable
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainFeatureCell", for: indexPath) as! MainFeatureCell
        
        let sample = self.sampleData.samples[indexPath.row]
        cell.titleLabel.text = sample.title
        cell.descriptionLabel.text = sample.description
        cell.featureImageView.image = UIImage(named: sample.image)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect the selected row(i.e. turn it to an original state
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row { 
        case 0: self.performSegue(withIdentifier: "photoObjectDetection", sender: nil)
        case 1: self.performSegue(withIdentifier: "realTimeObjectDetection", sender: nil)
        case 2: self.performSegue(withIdentifier: "facialAnalysis", sender: nil)
        default: return
            
        }
        
    }
    
}
