//
//  Utils.swift
//  WallDota2
//
//  Created by QuangHo on 19/9/24.
//

import Foundation
import UIKit
import SwiftUI
import WebKit
import RegexBuilder
import GoogleMobileAds

extension String {
    func htmlToMarkDown() -> String {
        
        var text = self
        
        var loop = true

        // Replace HTML comments, in the format <!-- ... comment ... -->
        // Stop looking for comments when none is found
        while loop {
            
            // Retrieve hyperlink
            let searchComment = Regex {
                Capture {
                    
                    // A comment in HTML starts with:
                    "<!--"
                    
                    ZeroOrMore(.any, .reluctant)
                    
                    // A comment in HTML ends with:
                    "-->"
                }
            }
            if let match = text.firstMatch(of: searchComment) {
                let (_, comment) = match.output
                text = text.replacing(comment, with: "")
            } else {
                loop = false
            }
        }

        // Replace line feeds with nothing, which is how HTML notation is read in the browsers
        text = self.replacing("\n", with: "")
        
        // Line breaks
        text = text.replacing("<div>", with: "\n")
        text = text.replacing("</div>", with: "")
        text = text.replacing("<p>", with: "\n")
        text = text.replacing("<br>", with: "\n")

        // Text formatting
        text = text.replacing("<strong>", with: "**")
        text = text.replacing("</strong>", with: "**")
        text = text.replacing("<b>", with: "**")
        text = text.replacing("</b>", with: "**")
        text = text.replacing("<em>", with: "*")
        text = text.replacing("</em>", with: "*")
        text = text.replacing("<i>", with: "*")
        text = text.replacing("</i>", with: "*")
        
        // Replace hyperlinks block
        
        loop = true
        
        // Stop looking for hyperlinks when none is found
        while loop {
            
            // Retrieve hyperlink
            let searchHyperlink = Regex {

                // A hyperlink that is embedded in an HTML tag in this format: <a... href="<hyperlink>"....>
                "<a"

                // There could be other attributes between <a... and href=...
                // .reluctant parameter: to stop matching after the first occurrence
                ZeroOrMore(.any)
                
                // We could have href="..., href ="..., href= "..., href = "...
                "href"
                ZeroOrMore(.any)
                "="
                ZeroOrMore(.any)
                "\""
                
                // Here is where the hyperlink (href) is captured
                Capture {
                    ZeroOrMore(.any)
                }
                
                "\""

                // After href="<hyperlink>", there could be a ">" sign or other attributes
                ZeroOrMore(.any)
                ">"
                
                // Here is where the linked text is captured
                Capture {
                    ZeroOrMore(.any, .reluctant)
                }
                One("</a>")
            }
                .repetitionBehavior(.reluctant)
            
            if let match = text.firstMatch(of: searchHyperlink) {
                let (hyperlinkTag, href, content) = match.output
                let markDownLink = "[" + content + "](" + href + ")"
                text = text.replacing(hyperlinkTag, with: markDownLink)
            } else {
                loop = false
            }
        }

        return text
    }
}


struct htmlAttributedLabel: UIViewRepresentable {
    @Binding var htmlText: String
    var width: CGFloat
    @Binding var size:CGSize
    var lineLimit = 0
    //var textColor = Color(.label)
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = lineLimit
        label.preferredMaxLayoutWidth = width
        //label.textColor = textColor.uiColor()
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        let htmlData = NSString(string: htmlText).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        DispatchQueue.main.async {
            do {
                let attributedString = try NSMutableAttributedString(data: htmlData!, options: options, documentAttributes: nil)
                //add attributedstring attributes here if you want
                uiView.attributedText = attributedString
                size = uiView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
                print("htmlAttributedLabel size: \(size)")
            } catch {
                print("htmlAttributedLabel unexpected error: \(error).")
            }
        }
    }
}


struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

extension String {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d" // Input format: "June 3"
        
        if let date = formatter.date(from: self) {
            formatter.dateFormat = "MMM d, yyyy" // Desired output format: "Jun 3, 2023"
            return formatter.string(from: date)
        }
        
        return self // Return original if parsing fails
    }
    func getFirstTenWords() -> String {
        // Split the text into words by spaces
        let words = self.split(separator: " ").map(String.init)
        
        // Get the first 10 words (or fewer if there are less than 10)
        let firstTenWords = words.prefix(10)
        
        // Join the first 10 words back into a single string
        return firstTenWords.joined(separator: " ")
    }
}

extension Double {
    func formatTimestamp() -> String {
        if self == 0 {
            let date = Date(timeIntervalSince1970: 1717641150.505393)
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d" // "June 3" format
            return formatter.string(from: date)
        }
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d" // "June 3" format
        return formatter.string(from: date)
    }
}

func getCurrentLanguage() -> String {
    // Access the AppleLanguages key in UserDefaults
    if let languageCode = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first {
        return languageCode
    }
    // Default to English if no language is found
    return "en"
}

var adSizeGlobal : GADAdSize = GADAdSize(size: CGSize(width: UIScreen.main.bounds.width, height: 60), flags: 1)

extension Float {
    static func randomRating() -> String {
       

        // Step 1: Generate a random floating-point number between 0 and 10
        let randomFloat = Float.random(in: 03...10)

        // Step 2: Format the float to one decimal place
        let formattedString = String(format: "%.1f", randomFloat)

        // Step 3: Print or use the formatted string
        print(formattedString)
        return formattedString
    }
}
extension Date {
    func timeAgoDisplay() -> String {
        let now = Date()
        let secondsAgo = Int(now.timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return "Now"
        } else if secondsAgo < 2 * minute {
            return "A minute ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < 2 * hour {
            return "An hour ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < 2 * day {
            return "Yesterday"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        } else if secondsAgo < 4 * week {
            return "\(secondsAgo / week) weeks ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }
}
