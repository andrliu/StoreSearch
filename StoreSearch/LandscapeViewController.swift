//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Andrew Liu on 1/11/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var search: Search!
    private var firstTime = true
    private var downloadTasks = [NSURLSessionDownloadTask]()
    
    deinit
    {
        println("deinit \(self)")
        for task in downloadTasks
        {
            task.cancel()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.removeConstraints(view.constraints())
        view.setTranslatesAutoresizingMaskIntoConstraints(true)
        pageControl.removeConstraints(pageControl.constraints())
        pageControl.setTranslatesAutoresizingMaskIntoConstraints(true)
        scrollView.removeConstraints(scrollView.constraints())
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(true)
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.contentSize = CGSize(width: 1000, height: 1000)
        pageControl.numberOfPages = 0
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        pageControl.frame = CGRect( x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
        if firstTime
        {
            firstTime = false
            switch search.state
            {
                case .NotSearchedYet:
                    break
                case .Loading:
                    showSpinner()
                case .NoResults:
                    showNothingFoundLabel()
                case .Results(let list):
                    tileButtons(list)
            }
        }
    }
    
    func searchResultsReceived()
    {
        hideSpinner()
        switch search.state
        {
            case .NotSearchedYet, .Loading:
                break
            case .NoResults:
                showNothingFoundLabel()
            case .Results(let list):
                tileButtons(list)
        }
    }
    
    private func showNothingFoundLabel()
    {
        let label = UILabel(frame: CGRect.zeroRect)
        label.text = "Nothing Found"
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        var rect = label.frame
        rect.size.width = ceil(rect.size.width/2) * 2
        rect.size.height = ceil(rect.size.height/2) * 2
        label.frame = rect
        label.center = CGPoint(x: CGRectGetMidX(scrollView.bounds), y: CGRectGetMidY(scrollView.bounds))
        view.addSubview(label)
    }
    
    private func showSpinner()
    {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.center = CGPoint(x: CGRectGetMidX(scrollView.bounds) + 0.5, y: CGRectGetMidY(scrollView.bounds) + 0.5)
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func hideSpinner()
    {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    private func tileButtons(searchResults: [SearchResult])
    {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        let scrollViewWidth = scrollView.bounds.size.width
        switch scrollViewWidth
        {
            case 568:
                columnsPerPage = 6
                itemWidth = 94
                marginX = 2
            case 667:
                columnsPerPage = 7
                itemWidth = 95
                itemHeight = 98
                marginX = 1
                marginY = 29
            case 736:
                columnsPerPage = 8
                rowsPerPage = 4
                itemWidth = 92
            default:
                break
        }
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        var row = 0
        var column = 0
        var x = marginX
        for (index, searchResult) in enumerate(searchResults)
        {
            let button = UIButton.buttonWithType(.Custom) as UIButton
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), forState: .Normal)
            downloadImageForSearchResult(searchResult, andPlaceOnButton: button)
            button.frame = CGRect(x: x + paddingHorz, y: marginY + CGFloat(row)*itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
            scrollView.addSubview(button)
            ++row
            if row == rowsPerPage
            {
                row = 0
                ++column
                x += itemWidth
                if column == columnsPerPage
                {
                    column = 0
                    x += marginX * 2
                }
            }
            button.tag = 2000 + index
            button.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
        }
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages)*scrollViewWidth, height: scrollView.bounds.size.height)
        println("Number of pages: \(numPages)")
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0

    }
    
    func buttonPressed(sender: UIButton)
    {
        performSegueWithIdentifier("ShowDetail", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowDetail"
        {
            switch search.state
            {
                case .Results(let list):
                    let detailViewController = segue.destinationViewController as DetailViewController
                    let searchResult = list[sender!.tag - 2000]
                    detailViewController.searchResult = searchResult
                    detailViewController.isPopUp = true
                default:
                    break
            }
        }
    }
    
    @IBAction func pageChanged(sender: UIPageControl)
    {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
    }
    
    private func downloadImageForSearchResult(searchResult: SearchResult, andPlaceOnButton button: UIButton)
    {
        if let url = NSURL(string: searchResult.artworkURL60)
        {
            let session = NSURLSession.sharedSession()
            let downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak button] url, response, error in
                if error == nil && url != nil
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        if let image = UIImage(data: data)
                        {
                            dispatch_async(dispatch_get_main_queue()) {
                                if let button = button
                                {
                                    button.setImage(image, forState: .Normal)
                                }
                            }
                        }
                    }
                }
            })
            downloadTask.resume()
            downloadTasks.append(downloadTask)
        }
    }
}

extension LandscapeViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
        pageControl.currentPage = currentPage
    }
}

