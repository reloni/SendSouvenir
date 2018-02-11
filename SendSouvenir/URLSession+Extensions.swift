//
//  URLSession+Extensions.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 11.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

public enum URLRequestError: Error {
	case urlRequestError(response: URLResponse, data: Data?)
	case urlRequestLocalError(Error)
}

extension URLSession {
	func dataRequest(_ request: URLRequest) -> Observable<Data> {
		return Observable.create { [weak self] observer in
			guard let session = self else { observer.onCompleted(); return Disposables.create() }
			let task = session.dataTask(with: request) { data, response, error in
				if let error = error {
					observer.onError(URLRequestError.urlRequestLocalError(error))
					return
				}
				
				if !(200...299 ~= (response as? HTTPURLResponse)?.statusCode ?? 0) {
					#if DEBUG
						if let data = data, let responseString = String.init(data: data, encoding: .utf8) {
							print("Response string: \(responseString)")
						}
					#endif
					
					observer.onError(URLRequestError.urlRequestError(response: response!, data: data))
					return
				}
				
				guard let data = data else { observer.onCompleted(); return }
				
				observer.onNext(data)
				observer.onCompleted()
			}
			
			#if DEBUG
				print("URL \(task.originalRequest!.url!.absoluteString)")
			#endif
			
			task.resume()
			
			return Disposables.create {
				task.cancel()
				observer.onCompleted()
			}
		}
	}
}

extension URLRequest {
	static func cardToken(token: String, number: Int, month: Int, year: Int, cvc: Int) -> URLRequest {
		var request = URLRequest(url: AppConstants.stripeCardTokenUrl)
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "POST"
		let body =
			"""
				card[number]=\(number)&
				card[exp_month]=\(month)&
				card[exp_year]=\(year)&
				card[cvc]=\(cvc)&
				"""
				.replacingOccurrences(of: "\n", with: "")
		request.httpBody = body.data(using: .utf8)
		return request
	}
	
	static func charge(token: String, amount: Int, description: String) -> URLRequest {
		var request = URLRequest(url: AppConstants.stripeChargeUrl)
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "POST"
		let body =
			"""
				amount=\(amount)&
				currency=EUR&
				source=tok_amex&
				description=\(description)&
				"""
				.replacingOccurrences(of: "\n", with: "")
		request.httpBody = body.data(using: .utf8)
		return request
	}
}
