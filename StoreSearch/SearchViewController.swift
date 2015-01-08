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
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    struct TableViewCellIdentifiers
    {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        searchBar.becomeFirstResponder()
    }

    func urlWithSearchText(searchText: String) -> NSURL
    {
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = String(format:"http://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
}

extension SearchViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if !searchBar.text.isEmpty
        {
            searchBar.resignFirstResponder()
            hasSearched = true
            searchResults = [SearchResult]()
            let url = urlWithSearchText(searchBar.text)
            println("URL: '\(url)'")
            tableView.reloadData()
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition
    {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
            
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        if searchResults.count == 0
        {
            return nil
        }
        else
        {
            return indexPath
        }
    }
            
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if !hasSearched
        {
            return 0
        }
        else if searchResults.count == 0
        {
            return 1
        }
        else
        {
            return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {

        if searchResults.count == 0
        {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
            return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate
{
    
}