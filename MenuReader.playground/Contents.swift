//
//  MenuReader.swift
//  MenuParser
//
//  Created by Tim on 2/23/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class MenuReader: NSObject, NSXMLParserDelegate {
    
    var parser = NSXMLParser()
    var stationExcerpt:[String] = []
    var menuArray:[[[String]]] = []
    var dishExcerpt: [String] = []
    var mealArray = [String]()
    var meals = [String]()
    
    var cDataString:String = ""
    
    func beginParse() {
        let url = NSURL(string: "http://www.bates.edu/dining/menu/feed/todays-menu/")!
        
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
        
        menuArray = makeArray(cDataString)
    }
    
    func makeArray(mealString:String) -> [[[String]]] {
        var mealExcerpt = getStringFromRange(mealString, openTag: "<meal>", closeTag: "</meal>")
        
        for var i=0; i < mealExcerpt.count; i++ {
            var station = [String]()
            var dishes = [String]()
            var stationsArray:[[String]] = []
            
            mealArray = getStringFromRange(mealExcerpt[i], openTag: "<h1>", closeTag: "</h1>")
            meals.append(mealArray[0])
            stationExcerpt = getStringFromRange(mealExcerpt[i], openTag: "<station>", closeTag: "</station>")
            
            for var j=0; j <= stationExcerpt.count-1; j++ {
                station = getStringFromRange(stationExcerpt[j], openTag: "<h2>", closeTag: "</h2>")
                dishExcerpt = getStringFromRange(stationExcerpt[j], openTag: "<ul>", closeTag: "</ul>")
                dishes = getStringFromRange(dishExcerpt[0], openTag: "<li>", closeTag: "</li>")
                dishes.insert(station[0], atIndex: 0)
                // Remove not open to the general public message
                dishes = dishes.filter {$0 != "[Not open to the general public]"}
                stationsArray.append(dishes)
            }
            menuArray.append(stationsArray)
        }
        
        return menuArray
    }
    
    
    func getStringFromRange(fromString:NSString, openTag:String, closeTag:String) -> [String] {
        var array:[String] = []
        var openTagRanges = getRanges(fromString as String, searchstr: openTag)!
        var closeTagRanges = getRanges(fromString as String, searchstr: closeTag)!
        
        for var i=0; i < openTagRanges.count; i++ {
            let index:Int = (openTagRanges[i].location + openTagRanges[i].length)
            let length:Int = (closeTagRanges[i].location - index)
            let range:NSRange = NSMakeRange(index, length)
            let result = fromString.substringWithRange(range)
            array.append(result)
        }
        return array
    }
    
    func getRanges(string: String, searchstr: String) -> [NSRange]? {
        let text = string as String
        var ranges:[NSRange] = []
        
        do {
            let regex = try NSRegularExpression(pattern: searchstr, options: [])
            ranges = regex.matchesInString(string, options: [], range: NSMakeRange(0, text.characters.count)).map {$0.range}
        }
        catch {
            // There was a problem creating the regular expression
            ranges = []
        }
        //        print(ranges)
        return ranges
    }
    
    
    
    // MARK: XML Parser methods
    
    func parserDidStartDocument(parser: NSXMLParser) {
        //        print("started parsing")
    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print("XML parse error")
    }
    
    func parser(parser: NSXMLParser, foundCDATA CDATABlock: NSData) {
        cDataString = NSString(data: CDATABlock, encoding: NSUTF8StringEncoding) as! String
        // Line breaks
        cDataString = cDataString.stringByReplacingOccurrencesOfString("\r", withString: "")
        // Ampersands
        cDataString = cDataString.stringByReplacingOccurrencesOfString("\u{26}amp;", withString: "\u{26}")
        // Single quotes
        cDataString = cDataString.stringByReplacingOccurrencesOfString("\u{26}quot;", withString: "'")
        // Apostrophe
        cDataString = cDataString.stringByReplacingOccurrencesOfString("\u{26}\u{23}039;", withString: "'")
    }
}
