//
//  Search.swift
//  StoreSearch
//
//  Created by Andrew Liu on 1/11/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import Foundation
import UIKit
typealias SearchComplete = (Bool) -> Void

class Search
{

    enum State
    {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results([SearchResult])
    }
    enum Category: Int
    {
        case All = 0
        case Music = 1
        case Software = 2
        case EBook = 3
        var entityName: String
        {
            switch self
            {
                case .All: return ""
                case .Music: return "musicTrack"
                case .Software: return "software"
                case .EBook: return "ebook"
            }
        }
    }
    enum AnimationStyle
    {
        case Slide
        case Fade
    }
    private(set) var state: State = .NotSearchedYet
    private var dataTask: NSURLSessionDataTask? = nil
    
    func performSearchForText(text: String, category: Category, completion: SearchComplete)
    {
        if !text.isEmpty
        {
            dataTask?.cancel()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            state = .Loading
            let url = urlWithSearchText(text, category: category)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {data, response, error in
                self.state = .NotSearchedYet
                var success = false
                if let error = error
                {
                    if error.code == -999 { return }
                }
                else if let httpResponse = response as? NSHTTPURLResponse
                {
                    if httpResponse.statusCode == 200
                    {
                        if let dictionary = self.parseJSON(data)
                        {
                            var searchResults = self.parseDictionary(dictionary)
                            if searchResults.isEmpty
                            {
                                self.state = .NoResults
                            }
                            else
                            {
                                searchResults.sort(<)
                                self.state = .Results(searchResults)
                            }
                            success = true
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()){
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(success)
                }
            })
            dataTask?.resume()
        }
    }
    
    private func urlWithSearchText(searchText: String, category: Category) -> NSURL
    {
        var entityName = category.entityName
        let locale = NSLocale.autoupdatingCurrentLocale()
        let language = locale.localeIdentifier
        let countryCode = locale.objectForKey(NSLocaleCountryCode) as String
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = String(format:"http://itunes.apple.com/search?term=%@&limit=200&entity=%@&lang=%@&country=%@", escapedSearchText, entityName, language, countryCode)
        let url = NSURL(string: urlString)
        println("URL: \(url!)")
        return url!
    }
    
    private func parseJSON(data: NSData) -> [String: AnyObject]?
    {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(0), error: &error) as? [String: AnyObject]
        {
            return json
        }
        else if let error = error
        {
            println("JSON Error: \(error)")
        }
        else
        {
            println("Unknown JSON Error")
        }
        return nil
    }
    
    private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult]
    {
        var searchResults = [SearchResult]()
        if let array: AnyObject = dictionary["results"]
        {
            for resultDict in array as [AnyObject]
            {
                if let resultDict = resultDict as? [String: AnyObject]
                {
                    var searchResult: SearchResult?
                    if let wrapperType = resultDict["wrapperType"] as? NSString
                    {
                        switch wrapperType
                        {
                            case "track":
                                searchResult = parseTrack(resultDict)
                            case "audiobook":
                                searchResult = parseAudioBook(resultDict)
                            case "software":
                                searchResult = parseSoftware(resultDict)
                            default:
                                break
                        }
                    }
                    else if let kind = resultDict["kind"] as? NSString
                    {
                        if kind == "ebook"
                        {
                            searchResult = parseEBook(resultDict)
                        }
                    }
                    if let result = searchResult
                    {
                        searchResults.append(result)
                    }
                }
                else
                {
                    println("Expected a dictionary")
                }
            }
        }
        else
        {
            println("Expected 'results' array")
        }
        return searchResults
    }
    
    private func parseTrack(dictionary: [String: AnyObject]) -> SearchResult
    {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as NSString
        searchResult.artistName = dictionary["artistName"] as NSString
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
        searchResult.storeURL = dictionary["trackViewUrl"] as NSString
        searchResult.kind = dictionary["kind"] as NSString
        searchResult.currency = dictionary["currency"] as NSString
        if let price = dictionary["trackPrice"] as? NSNumber
        {
            searchResult.price = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? NSString
        {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    private func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult
    {
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as NSString
        searchResult.artistName = dictionary["artistName"] as NSString
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
        searchResult.storeURL = dictionary["collectionViewUrl"] as NSString
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as NSString
        if let price = dictionary["collectionPrice"] as? NSNumber
        {
            searchResult.price = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? NSString
        {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    private func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult
    {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as NSString
        searchResult.artistName = dictionary["artistName"] as NSString
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
        searchResult.storeURL = dictionary["trackViewUrl"] as NSString
        searchResult.kind = dictionary["kind"] as NSString
        searchResult.currency = dictionary["currency"] as NSString
        if let price = dictionary["price"] as? NSNumber
        {
            searchResult.price = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? NSString
        {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    private func parseEBook(dictionary: [String: AnyObject]) -> SearchResult
    {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as NSString
        searchResult.artistName = dictionary["artistName"] as NSString
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
        searchResult.storeURL = dictionary["trackViewUrl"] as NSString
        searchResult.kind = dictionary["kind"] as NSString
        searchResult.currency = dictionary["currency"] as NSString
        if let price = dictionary["price"] as? NSNumber
        {
            searchResult.price = Double(price)
        }
        if let genres: AnyObject = dictionary["genres"]
        {
            searchResult.genre = ", ".join(genres as [String])
        }
        return searchResult
    }
}




