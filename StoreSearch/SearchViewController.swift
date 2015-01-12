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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let search = Search()
    var landscapeViewController: LandscapeViewController?
    
    struct TableViewCellIdentifiers
    {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        searchBar.becomeFirstResponder()
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    override func willTransitionToTraitCollection( newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        switch newCollection.verticalSizeClass
        {
            case .Compact:
                showLandscapeViewWithCoordinator(coordinator)
            case .Regular, .Unspecified:
                hideLandscapeViewWithCoordinator(coordinator)
        }
    }
    
    func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator)
    {
        precondition(landscapeViewController == nil)
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeViewController
        {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChildViewController(controller)
            coordinator.animateAlongsideTransition({ _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil
                {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }, completion: { _ in
                controller.didMoveToParentViewController(self)
            })
        }
    }
    
    func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator)
    {
        if let controller = landscapeViewController
        {
            controller.willMoveToParentViewController(nil)
            coordinator.animateAlongsideTransition({ _ in
                controller.view.alpha = 0
                if self.presentedViewController != nil
                {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            })
        }
    }
    
    func showNetworkError()
    {
        let alert = UIAlertController(title: "Whoops...", message:"There was an error reading from the iTunes Store. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl)
    {
//        println("Segment changed: \(sender.selectedSegmentIndex)")
        performSearch()
    }
}

extension SearchViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        performSearch()
    }
            
    func performSearch()
    {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex)
        {
            search.performSearchForText(searchBar.text, category: category, completion: { success in
                if let controller = self.landscapeViewController
                {
                    controller.searchResultsReceived()
                }
                if !success
                {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
            })
        tableView.reloadData()
        searchBar.resignFirstResponder()
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition
    {
        return .TopAttached
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowDetail"
        {
            switch search.state
            {
                case .Results(let list):
                    let detailViewController = segue.destinationViewController as DetailViewController
                    let indexPath = sender as NSIndexPath
                    let searchResult = list[indexPath.row]
                    detailViewController.searchResult = searchResult
                default:
                    break
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
            
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        switch search.state
        {
            case .NotSearchedYet,.Loading, .NoResults:
                return nil
            case .Results:
                return indexPath
        }
    }
            
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch search.state
        {
            case .NotSearchedYet:
                return 0
            case .Loading:
                return 1
            case .NoResults:
                return 1
            case .Results(let list):
                return list.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch search.state
        {
            case .NotSearchedYet:
                fatalError("Should never get here")
            case .Loading:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath:indexPath) as UITableViewCell
                let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
                spinner.startAnimating()
                return cell
            case .NoResults:
                return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
            case .Results(let list):
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
                let searchResult = list[indexPath.row]
                cell.configureForSearchResult(searchResult)
                return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate
{
    
}