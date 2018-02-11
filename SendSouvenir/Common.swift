//
//  Common.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 11.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

struct AppConstants {
	static let stripeToken = "token"
	static let stripeCardTokenUrl = URL(string: "https://api.stripe.com/v1/tokens")!
	static let stripeChargeUrl = URL(string: "https://api.stripe.com/v1/charges")!
}

struct BankCardManager {
	static func loadCards() -> [BankCard] {
		guard let data = Keychain().dataForAccount(account: "Cards") else { return [] }
		return (try? JSONDecoder().decode([BankCard].self, from: data)) ?? []
	}
	
	static func addCard(_ value: BankCard) {
		let cards = loadCards() + [value]
		saveCards(cards)
	}
	
	static func saveCards(_ value: [BankCard]) {
		guard let data = try? JSONEncoder().encode(value) else { return }
		Keychain().setData(data: data, forAccount: "Cards", synchronizable: false, background: false)
	}
}

struct SouvenirData {
	let imageName: String
	let labelText: String
	let price: Int
}

enum CardSelector {
	case card(BankCard)
	case addNew
}

struct BankCard: Codable {
	enum CardType: String, Codable {
		case mastercard
		case visa
		static func from(cardNumber: String) -> CardType? {
			switch Int(cardNumber.prefix(2)) {
			case let n? where 40...49 ~= n:
				return BankCard.CardType.visa
			case let n? where 51...55 ~= n:
				return BankCard.CardType.mastercard
			default:
				return nil
			}
		}
	}
	let number: Int
	let month: Int
	let year: Int
	let cvc: Int
	let type: CardType
	let isSelected: Bool
	
	var cardNumber: String {
		return "**** **** **** \(String(number).suffix(4))"
	}
}

extension BankCard {
	init?(number: String, date: String, cvc: String) {
		guard let n = Int(number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)) else { return nil }
		guard let m = Int(date.prefix(2)) else { return nil }
		guard let y = Int(date.suffix(2)) else { return nil }
		guard let c = Int(cvc) else { return nil }
		guard let t = CardType.from(cardNumber: number) else { return nil }
		
		self.number = n
		self.month = m
		self.year = y
		self.cvc = c
		self.type = t
		self.isSelected = false
	}
}
