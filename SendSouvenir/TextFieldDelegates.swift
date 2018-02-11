//
//  TextFieldDelegates.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 11.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit

class CardDateTextFieldDelegate: NSObject, UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard range.length == 0 else {
			return true
		}
		
		if textField.text!.count < 2 {
			return true
		} else if textField.text!.count == 2 {
			textField.text = "\(textField.text!)/"
			return true
		} else if textField.text!.count >= 5 {
			return false
		} else {
			return true
		}
	}
}

class CVVTextFieldDelegate: NSObject, UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard range.length == 0 else {
			return true
		}
		
		if textField.text!.count < 3 {
			return true
		} else {
			return false
		}
	}
}

class CardNumberTextFieldDelegate: NSObject, UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard range.length == 0 else {
			return true
		}
		
		if textField.text!.count < 4 {
			return true
		} else if textField.text!.count == 4 {
			textField.text = "\(textField.text!) "
			return true
		} else if textField.text!.count < 9 {
			return true
		} else if textField.text!.count == 9 {
			textField.text = "\(textField.text!) "
			return true
		} else if textField.text!.count < 14 {
			return true
		} else if textField.text!.count == 14 {
			textField.text = "\(textField.text!) "
			return true
		} else if textField.text!.count < 19 {
			return true
		} else {
			return false
		}
	}
}

class CardHolderTextFieldDelegate: NSObject, UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard range.length == 0 else {
			return true
		}
		
		if textField.text!.count < 30 {
			return true
		} else {
			return false
		}
	}
}
