//
//  ViewController.swift
//  StoreSearch
//
//  Created by Andrew Liu on 1/4/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchResults = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }


}

extension SearchViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchResults = [String]()
        for i in 0...2
        {
            searchResults.append(String(format: "Fake Result %d for '%@'", i, searchBar.text))
        }
        tableView.reloadData()
    }
    

}

extension SearchViewController: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellIdentifier = "SearchResultCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        if cell == nil
        {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        cell.textLabel!.text = searchResults[indexPath.row]
        return cell
    }
}

extension SearchViewController: UITableViewDelegate
{
    
}