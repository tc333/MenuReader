// Playground - noun: a place where people can play

import UIKit
import Foundation


class menuReader: NSObject, NSXMLParserDelegate {
    
    var mealArray:[String] = []
    var stationArray:[String] = []
    var dishArray:[String] = []
    var passData:Bool=false
    var passName:Bool=false
    var parser = NSXMLParser()
    
    var cDataString:String = ""
    
    func beginParse() {
        let url = NSURL(string: "http://www.bates.edu/dining/menu/feed/todays-menu/")
        let myparser = NSXMLParser(contentsOfURL: url!)
        myparser?.delegate = self
        myparser?.parse()

        mealArray = getDataPlz(cDataString, openTag: "<h1>", closeTag: "</h1>")
        print(mealArray)
        stationArray = getDataPlz(cDataString, openTag: "<h2>", closeTag: "</h2>")
        print(stationArray)
        dishArray = getDataPlz(cDataString, openTag: "<li>", closeTag: "</li>")
        
    }
    
    func getDataPlz(fromString:NSString, openTag:String, closeTag:String) -> [String] {
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

var reader = menuReader()
reader.beginParse()









