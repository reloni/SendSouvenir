//
//  SendSouvenirTests.swift
//  SendSouvenirTests
//
//  Created by Anton Efimenko on 10.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import XCTest
@testable import SendSouvenir

class SendSouvenirTests: XCTestCase {
    
	func testValidCardNumber() {
		XCTAssertTrue(CardFieldValidator.isValid(cardNumber: "4500 1234 1234 5431"))
		XCTAssertTrue(CardFieldValidator.isValid(cardNumber: "4100 12341234 5431"))
		XCTAssertTrue(CardFieldValidator.isValid(cardNumber: "5500132412345431"))
		XCTAssertTrue(CardFieldValidator.isValid(cardNumber: "45111234 1234 5431        "))
		XCTAssertTrue(CardFieldValidator.isValid(cardNumber: "5100 1234 1234 5431"))
		XCTAssertTrue(CardFieldValidator.isValid(cardNumber: "5100-1234-1234-5431"))
		
		XCTAssertFalse(CardFieldValidator.isValid(cardNumber: "1100 1234 1234 5431"))
		XCTAssertFalse(CardFieldValidator.isValid(cardNumber: "a 5100 1234 1234 5431"))
		XCTAssertFalse(CardFieldValidator.isValid(cardNumber: "5900 1234 1234 5431"))
	}
	
	func testValidCardDate() {
		XCTAssertTrue(CardFieldValidator.isValid(cardDate: "11/19"))
		XCTAssertTrue(CardFieldValidator.isValid(cardDate: "01/22"))
		XCTAssertTrue(CardFieldValidator.isValid(cardDate: "07/99"))
		XCTAssertTrue(CardFieldValidator.isValid(cardDate: "12/18"))
		
		XCTAssertFalse(CardFieldValidator.isValid(cardDate: "12 18"))
		XCTAssertFalse(CardFieldValidator.isValid(cardDate: "12/17"))
		XCTAssertFalse(CardFieldValidator.isValid(cardDate: "121/18"))
		XCTAssertFalse(CardFieldValidator.isValid(cardDate: "00/18"))
	}
	
	func testValidateCardCvv() {
		XCTAssertTrue(CardFieldValidator.isValid(cardCvv: "222"))
		XCTAssertTrue(CardFieldValidator.isValid(cardCvv: "123"))
		XCTAssertTrue(CardFieldValidator.isValid(cardCvv: "000"))
		XCTAssertTrue(CardFieldValidator.isValid(cardCvv: "999"))
		
		XCTAssertFalse(CardFieldValidator.isValid(cardCvv: ""))
		XCTAssertFalse(CardFieldValidator.isValid(cardCvv: "1"))
		XCTAssertFalse(CardFieldValidator.isValid(cardCvv: "afds"))
		XCTAssertFalse(CardFieldValidator.isValid(cardCvv: "1234"))
	}
    
}
