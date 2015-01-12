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

}
