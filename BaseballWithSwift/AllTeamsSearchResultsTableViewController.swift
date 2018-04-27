//
//  AllTeamsSearchResultsTableViewController.swift
//  BaseballQuery
//
//  Created by Mark Knopper on 2/19/15.
//  Copyright (c) 2015 Bulbous Ventures LLC. All rights reserved.
//

import UIKit

// First Swift class added to BaseballQuery project!
@objc class AllTeamsSearchResultsTableViewController: UITableViewController {
    
    @objc var teamsObjectsFromSearch: NSArray? = nil
    @objc var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.register(UINib(nibName: "BasicTableCell", bundle: nil), forCellReuseIdentifier: "BasicTableCell")
        self.tableView!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return teamsObjectsFromSearch!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableCell", for: indexPath) 

        let ourTeam = teamsObjectsFromSearch![indexPath.row] as! NSDictionary
        cell.textLabel!.text = (ourTeam["name"] as! String)
        if StatHead.isCurrentTeam(cell.textLabel!.text) {
            cell.textLabel!.textColor = self.tableView.tintColor
        } else {
            cell.textLabel!.textColor = UIColor.black
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath)
    {
        let ourTeam = teamsObjectsFromSearch![indexPath.row] as! NSDictionary
        let teamYearsController = self.presentingViewController?.storyboard!.instantiateViewController(withIdentifier: "teamYears") as! TeamYearsController
        teamYearsController.teamName = ourTeam["name"] as! String
        teamYearsController.managedObjectContext = self.managedObjectContext
        self.presentingViewController!.navigationController?.pushViewController(teamYearsController, animated: true)
    }
    
}
