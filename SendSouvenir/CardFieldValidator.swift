//
//  CardFieldValidator.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 11.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

struct CardFieldValidator {
	static func isValid(cardNumber: String) -> Bool {
		guard BankCard.CardType.from(cardNumber: cardNumber) != nil else { return false }
		let regex = "^[0-9]{16}$"
		let numberOnly = cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
		return matchesRegex(regex: regex, text: numberOnly)
	}
	
	static func isValid(cardDate: String) -> Bool {
		let regex = "^[0-9]{2}/[0-9]{2}$"
		guard matchesRegex(regex: regex, text: cardDate) else { return false }
		
		guard 1...12 ~= Int(cardDate.prefix(2)) ?? 0 else { return false }
		
		// can do better :(
		guard 18...99 ~= Int(cardDate.suffix(2)) ?? 0 else { return false }
		
		return true
	}
	
	static func isValid(cardHolder: String) -> Bool {
		// OK, if not empty :)
		return cardHolder.count > 1
	}
	
	static func isValid(cardCvv: String) -> Bool {
		let regex = "^[0-9]{3}$"
		return matchesRegex(regex: regex, text: cardCvv)
	}
	
	static func matchesRegex(regex: String, text: String!) -> Bool {
		do {
			let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
			let nsString = text as NSString
			let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
			return match != nil
		} catch {
			return false
		}
	}
}
