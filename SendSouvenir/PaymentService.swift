//
//  PaymentService.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 11.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxSwift
import Foundation

protocol PaymentServiceType {
	func validateCard(number: Int, month: Int, year: Int, cvc: Int) -> Observable<Bool>
	func charge(amount: Int, description: String) -> Observable<Bool>
}

struct PaymentService: PaymentServiceType {
	let token: String
	let session: URLSession
	
	func validateCard(number: Int, month: Int, year: Int, cvc: Int) -> Observable<Bool> {
		let request = URLRequest.cardToken(token: token, number: number, month: month, year: year, cvc: cvc)
		return session.dataRequest(request).flatMap { _ -> Observable<Bool> in return .just(true) }.catchErrorJustReturn(false)
	}
	
	func charge(amount: Int, description: String) -> Observable<Bool> {
		let request = URLRequest.charge(token: token, amount: amount, description: description)
		return session.dataRequest(request).flatMap { _ -> Observable<Bool> in return .just(true) }.catchErrorJustReturn(false)
	}
}
