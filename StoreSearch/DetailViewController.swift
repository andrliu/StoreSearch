//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Andrew Liu on 1/10/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    var searchResult: SearchResult!
    var downloadTask: NSURLSessionDownloadTask?
    var dismissAnimationStyle = AnimationStyle.Fade
    enum AnimationStyle
    {
        case Slide
        case Fade
    }
    
    deinit
    {
        println("deinit \(self)")
        downloadTask?.cancel()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    @IBAction func close(sender: UIButton)
    {
        dismissAnimationStyle = .Slide
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        if searchResult != nil
        {
            updateUI()
        }
        view.backgroundColor = UIColor.clearColor()
    }

    func updateUI()
    {
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty
        {
            artistNameLabel.text = "Unknown"
        }
        else
        {
            artistNameLabel.text = searchResult.artistName
        }
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        var priceText: String
        if searchResult.price == 0
        {
            priceText = "Free"
        }
        else if let text = formatter.stringFromNumber(searchResult.price)
        {
            priceText = text
        }
        else
        {
            priceText = ""
        }
        priceButton.setTitle(priceText, forState: .Normal)
        if let url = NSURL(string: searchResult.artworkURL100)
        {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
    }
    
    @IBAction func openInStore(sender: UIButton)
    {
        if let url = NSURL(string: searchResult.storeURL)
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
}

extension DetailViewController: UIViewControllerTransitioningDelegate
{
    func presentationControllerForPresentedViewController( presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController)
    -> UIPresentationController?
    {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController( presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return BounceAnimationController()
    }
    
    func animationControllerForDismissedController( dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        switch dismissAnimationStyle
        {
            case .Slide:
                return SlideOutAnimationController()
            case .Fade:
                return FadeOutAnimationController()
        }
    }
}

extension DetailViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        return (touch.view === view)
    }
}