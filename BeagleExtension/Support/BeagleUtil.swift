//
//  BeagleUtil.swift
//  TestBeagle
//
//  Created by Minh Mon on 06/06/2021.
//

import Foundation

class BeagleUtil {
    static let shared = BeagleUtil()
    
    func matches(regex: String, text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                return String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print(error)
            return []
        }
    }
}
