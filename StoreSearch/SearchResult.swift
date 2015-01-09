//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Andrew Liu on 1/5/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import Foundation

func < (lhs: SearchResult, rhs: SearchResult) -> Bool
{
    return lhs.name.localizedStandardCompare(rhs.name) == NSComparisonResult.OrderedAscending
}

class SearchResult
{
    var name = ""
    var artistName = ""
    var artworkURL60 = ""
    var artworkURL100 = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
}