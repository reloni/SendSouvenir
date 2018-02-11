//
//  AddCardController.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 11.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

struct AddCardControllerViewModel {
	let paymentService: PaymentServiceType
	
	func validateCard(_ card: BankCard) -> Observable<Bool> {
		return paymentService.validateCard(number: card.number, month: card.month, year: card.year, cvc: card.cvc)
			.do(onNext: { result in
				guard result else { return }
				BankCardManager.addCard(card)
			})
	}
}

class AddCardController: UIViewController {
	let bag = DisposeBag()
	var viewModel: AddCardControllerViewModel!
	
	@IBOutlet weak var cancelButtom: UIButton!
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var cardNumber: UITextField!
	
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var cardHolderTextField: UITextField!
	@IBOutlet weak var cvvTextField: UITextField!
	
	@IBOutlet weak var cardNumberLabel: UILabel!
	@IBOutlet weak var cardDateLabel: UILabel!
	@IBOutlet weak var cardCvvLabel: UILabel!
	@IBOutlet weak var cardCardHolderLabel: UILabel!
	@IBOutlet weak var cardIssuerImage: UIImageView!
	
	let cardNumberDelegate = CardNumberTextFieldDelegate()
	let cardDateDelegate = CardDateTextFieldDelegate()
	let cvvDelegate = CVVTextFieldDelegate()
	let cardHolderDelegate = CardHolderTextFieldDelegate()
	
	lazy var toolBar: UIToolbar = {
		let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
		toolbar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
						 UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTextField))]
		toolbar.sizeToFit()
		return toolbar
	}()
	
	
	let gradientLayer = CAGradientLayer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		cardView.layer.cornerRadius = 10

		cardView.clipsToBounds = true
		
		gradientLayer.colors = [UIColor(red: 106/255, green: 173/255, blue: 246/255, alpha: 1).cgColor,
								UIColor(red: 46/255, green: 110/255, blue: 191/255, alpha: 1).cgColor]
		cardView.layer.insertSublayer(gradientLayer, at: 0)

		cardNumber.inputAccessoryView = toolBar
		cardNumber.delegate = cardNumberDelegate
		dateTextField.inputAccessoryView = toolBar
		dateTextField.delegate = cardDateDelegate
		cardHolderTextField.inputAccessoryView = toolBar
		cardHolderTextField.delegate = cardHolderDelegate
		cvvTextField.inputAccessoryView = toolBar
		cvvTextField.delegate = cvvDelegate

		bind()
	}
	
	override func viewWillLayoutSubviews() {
		gradientLayer.frame = cardView.bounds
	}
	
	func bind() {
		cancelButtom.rx.tap.subscribe(onNext: { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
			.disposed(by: bag)
		
		cardNumber.rx.text.map { text -> BankCard.CardType? in return BankCard.CardType.from(cardNumber: text!) }
			.distinctUntilChanged { $0?.rawValue == $1?.rawValue }
			.map { $0 == nil ? nil : UIImage(named: $0!.rawValue) }
			.bind(to: cardIssuerImage.rx.image)
			.disposed(by: bag)
		
		cardNumber.rx.text.map { $0!.count > 0 ? $0! : "XXXX XXXX XXXX XXXX" }.bind(to: cardNumberLabel.rx.text).disposed(by: bag)
		dateTextField.rx.text.map { $0!.count > 0 ? $0! : "MM/YY" }.bind(to: cardDateLabel.rx.text).disposed(by: bag)
		cardHolderTextField.rx.text.map { $0!.count > 0 ? $0! : "CARD HOLDER" }.bind(to: cardCardHolderLabel.rx.text).disposed(by: bag)
		cvvTextField.rx.text.map { $0!.count > 0 ? $0! : "CVV" }.bind(to: cardCvvLabel.rx.text).disposed(by: bag)
	}
	
	@objc func doneTextField(sender: UITextField) {
		if cardNumber.isFirstResponder {
			guard CardFieldValidator.isValid(cardNumber: cardNumber.text!) else { cardNumber.shake(); return }
			dateTextField.becomeFirstResponder()
		} else if dateTextField.isFirstResponder {
			guard CardFieldValidator.isValid(cardDate: dateTextField.text!) else { dateTextField.shake(); return }
			cardHolderTextField.becomeFirstResponder()
		} else if cardHolderTextField.isFirstResponder {
			guard CardFieldValidator.isValid(cardHolder: cardHolderTextField.text!) else { cardHolderTextField.shake(); return }
			cvvTextField.becomeFirstResponder()
		} else {
			guard CardFieldValidator.isValid(cardCvv: cvvTextField.text!) else { cvvTextField.shake(); return }
			cvvTextField.resignFirstResponder()
			validateCard()
		}
	}
	
	func validateCard() {
		guard let card = BankCard(number: cardNumber.text!, date: dateTextField.text!, cvc: cvvTextField.text!) else { return }
		
		MBProgressHUD.showAdded(to: view, animated: true)
		viewModel.validateCard(card)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] result in
				MBProgressHUD.hide(for: self.view, animated: true)
				if result {
					self.dismiss(animated: true, completion: nil)
				} else {
					self.showAlert(with: "Error", message: "Invalid card data")
				}
			})
			.disposed(by: bag)
	}
}
