//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Andrew Liu on 1/11/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: class
{
    func menuViewControllerSendSupportEmail(MenuViewController)
}

class MenuViewController: UITableViewController
{
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0
        {
            delegate?.menuViewControllerSendSupportEmail(self)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }
}
