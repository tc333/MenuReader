//
//  MenuReader.swift
//  MenuParser
//
//  Created by Tim on 10/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class Meal {
    var name: String = ""
    var stations: [Station] = []
    
    init(name: String, stations: [Station]) {
        self.name = name
        self.stations = stations
    }
}

class Station {
    var name: String = ""
    var dishes: [Dish] = []
    
    init(name: String, dishes: [Dish]) {
        self.name = name
        self.dishes = dishes
    }
}

class Dish {
    var name: String = ""
    
    init(name: String) {
        self.name = name
    }
}

class MenuReader: NSObject {
    
    let menuURL = URL(string: "http://www.bates.edu/dining/menu/feed/todays-menu/")
    
    var parser: XMLParser?
    
    var meals: [Meal] = []
    
    func initializeParser() {
        guard let menuURL = menuURL else {
            print("Invalid url: \(String(describing: self.menuURL))")
            return
        }
        parser = XMLParser(contentsOf: menuURL)
        parser?.delegate = self
        parser?.parse()
    }
    
    // MARK: - Helper Functions
    
    func getHTMLTagValues(tag: String, fromString superString: String) -> [String]? {
        guard let ranges = getRangesForHTMLTag(tag: tag, inSuperString: superString) else {
            print("Couldn't find given tag in the superString")
            return nil
        }
        
        var returnArray = [String]()
        let beginningTagRanges = ranges.beginningRanges
        let endingTagRanges = ranges.endingRanges
        
        for i in 0..<beginningTagRanges.count {
            
            let startingIndex = superString.index(superString.startIndex, offsetBy: beginningTagRanges[i].location + beginningTagRanges[i].length)
            let endingIndex = superString.index(superString.startIndex, offsetBy: endingTagRanges[i].location)
            
            let tagValue: String = superString[startingIndex..<endingIndex]
            returnArray.append(tagValue)
        }
        return returnArray
    }
    
    // Searches a string for the given HTML tag and returns an array of NSRanges that describe the location(s) of the beginning and ending tag within the string
    func getRangesForHTMLTag(tag: String, inSuperString superString: String) -> (beginningRanges: [NSRange], endingRanges: [NSRange])? {
        
        let beginningTag = "<\(tag)>"
        let endingTag = "</\(tag)>"
        
        var beginningRanges: [NSRange] = []
        var endingRanges: [NSRange] = []
        
        
        do {
            let beginningRegex = try NSRegularExpression(pattern: beginningTag, options: [])
            beginningRanges = beginningRegex.matches(in: superString, options: [], range: NSMakeRange(0, superString.characters.count)).map { $0.range }
            
            let endingRegex = try NSRegularExpression(pattern: endingTag, options: [])
            endingRanges = endingRegex.matches(in: superString, options: [], range: NSMakeRange(0, superString.characters.count)).map { $0.range }
            
            return (beginningRanges, endingRanges)
        } catch let error {
            // There was a problem creating the regular expression
            print("Regular expression error: \(error.localizedDescription)")
            return nil
        }
    }
}

extension MenuReader: XMLParserDelegate {
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard var CDATAString = String(data: CDATABlock, encoding: String.Encoding.utf8) else {
            print("Cannot convert CDATABlock to string")
            return
        }
        formatCDATAString(cDataString: &CDATAString)
        parseMenuXMLWithCDATAString(CDATAString: CDATAString)
    }
    
    // MARK: - Helper Functions
    
    func parseMenuXMLWithCDATAString(CDATAString: String) {
        if let mealExcerpts = getHTMLTagValues(tag: "meal", fromString: CDATAString) {
            for mealExcerpt in mealExcerpts {
                if let mealNames = getHTMLTagValues(tag: "h1", fromString: mealExcerpt) {
                    for mealName in mealNames {
                        let meal = Meal(name: mealName, stations: [])
                        if let stationExcerpts = getHTMLTagValues(tag: "station", fromString: mealExcerpt) {
                            for stationExcerpt in stationExcerpts {
                                if let stationNames = getHTMLTagValues(tag: "h2", fromString: stationExcerpt) {
                                    for stationName in stationNames {
                                        let station = Station(name: stationName, dishes: [])
                                        meal.stations.append(station)
                                        if let disheNames = getHTMLTagValues(tag: "li", fromString: stationExcerpt) {
                                            for dishName in disheNames {
                                                let dish = Dish(name: dishName)
                                                station.dishes.append(dish)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        self.meals.append(meal)
                    }
                }
            }
        }
    }
    
    func formatCDATAString(cDataString: inout String) {
        // Line breaks
        cDataString = cDataString.replacingOccurrences(of: "\r", with: "")
        // Ampersands
        cDataString = cDataString.replacingOccurrences(of: "\u{26}amp;", with: "\u{26}")
        // Single quotes
        cDataString = cDataString.replacingOccurrences(of: "\u{26}quot;", with: "'")
        // Apostrophe
        cDataString = cDataString.replacingOccurrences(of: "\u{26}\u{23}039;", with: "'")
    }
}


// Implementation

let menuReader = MenuReader()
menuReader.initializeParser()

