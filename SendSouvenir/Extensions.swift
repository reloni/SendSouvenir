//
//  Extensions.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 11.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit

extension UIViewController {
	func showAlert(with title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		present(alert, animated: true, completion: nil)
	}
}

extension UIView {
	func shake() {
		let midX = center.x
		let midY = center.y
		
		let animation = CABasicAnimation(keyPath: "position")
		animation.duration = 0.06
		animation.repeatCount = 4
		animation.autoreverses = true
		animation.fromValue = CGPoint(x: midX - 10, y: midY)
		animation.toValue = CGPoint(x: midX + 10, y: midY)
		layer.add(animation, forKey: "position")
	}
}
