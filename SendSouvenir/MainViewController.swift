//
//  ViewController.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 10.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

final class MainControllerViewModel {
	let paymentService: PaymentServiceType
	
	init(paymentService: PaymentServiceType) {
		self.paymentService = paymentService
	}
	
	let souvenirData: [SouvenirData] = [
		SouvenirData(imageName: "small_souvenir", labelText: "Small Souvenir", price: 10),
		SouvenirData(imageName: "medium_souvenir", labelText: "Medium Souvenir", price: 50),
		SouvenirData(imageName: "big_souvenir", labelText: "Big Souvenir", price: 100)
	]
	
	var bankCards: [CardSelector] {
		return BankCardManager.loadCards().map { CardSelector.card($0) } + [.addNew]
	}
	
	func charge(souvenir: SouvenirData) -> Observable<Bool> {
		return paymentService.charge(amount: souvenir.price * 100, description: "Charge for \(souvenir.labelText)")
	}
}

class MainViewController: UIViewController {
	let bag = DisposeBag()
	var viewModel: MainControllerViewModel!
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var smallSouvenirView: Souvenir!
	@IBOutlet weak var mediumSouvenirView: Souvenir!
	@IBOutlet weak var bigSouvenirView: Souvenir!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var sendButtonContainer: UIView!
	
	var cardSelector: UIView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initialize()
		bind()
	}
	
	func initialize() {
		zip(viewModel.souvenirData, scrollView.subviews.first?.subviews.flatMap { $0 as? Souvenir } ?? []).forEach {
			$0.1.imageView.image = UIImage(named: "\($0.0.imageName)")
			$0.1.nameLabel.text = $0.0.labelText
			$0.1.priceLabel.text = "\($0.0.price) EUR"
		}
		
		sendButton.titleLabel?.text = "SEND \(viewModel.souvenirData[0].labelText.uppercased())"
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
		view.addGestureRecognizer(recognizer)
	}
	
	@objc func viewTapped() {
		hideCardSelector()
	}
	
	func bind() {
		sendButton.rx.tap.subscribe(onNext: { [weak self] _ in
			guard let controller = self else { return }
			controller.showCardSelector(cards: controller.viewModel.bankCards)
		}).disposed(by: bag)
	}
	
	func charge() {
		MBProgressHUD.showAdded(to: view, animated: true)
		viewModel.charge(souvenir: viewModel.souvenirData[pageControl.currentPage])
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [unowned self] result in
				MBProgressHUD.hide(for: self.view, animated: true);
				if result {
					self.showAlert(with: "Success", message: "Operation completed successfully")
				} else {
					self.showAlert(with: "Error", message: "Unable to perform purchase")
				}
			})
			.disposed(by: bag)
	}
	
	func hideCardSelector() {
		guard let cardSelector = cardSelector else { return }
		
		self.cardSelector = nil
		
		scrollView.isScrollEnabled = true
		let c = view.constraints.first(where: { $0.identifier == "cardSelectorTopConstraint" })!
		view.removeConstraint(c)
		let topConstraint = NSLayoutConstraint(item: cardSelector, attribute: .top, relatedBy: .equal,
											   toItem: sendButtonContainer, attribute: .bottom, multiplier: 1, constant: 0)
		view.addConstraint(topConstraint)
		UIView.animate(withDuration: 0.4, animations: { self.view.layoutIfNeeded() }, completion: { _ in self.cardSelector?.removeFromSuperview(); self.cardSelector = nil })
	}
	
	func showAddCardController() {
		let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddCardContoller") as! AddCardController
		controller.viewModel = AddCardControllerViewModel(paymentService: viewModel.paymentService)
		present(controller, animated: true, completion: nil)
	}
	
	func showCardSelector(cards: [CardSelector]) {
		guard cardSelector == nil else {
			hideCardSelector()
			return
		}
		
		scrollView.isScrollEnabled = false

		let contentView = UIView()
		cardSelector = contentView
		
		contentView.clipsToBounds = true
		contentView.backgroundColor = .white
		contentView.translatesAutoresizingMaskIntoConstraints = false
		
		let itemHeight: CGFloat = 56
		let viewHeight: CGFloat = CGFloat(integerLiteral: cards.count) * itemHeight
		
		view.addSubview(contentView)
		
		
		let topConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal,
											   toItem: sendButtonContainer, attribute: .bottom, multiplier: 1, constant: viewHeight)
		view.addConstraint(topConstraint)
		view.addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal,
											  toItem: view, attribute: .leading, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal,
											  toItem: view, attribute: .trailing,multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal,
											  toItem: nil, attribute: .height, multiplier: 1, constant: viewHeight))
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
			self.view.removeConstraint(topConstraint)
			let topConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal,
												   toItem: self.sendButtonContainer, attribute: .top, multiplier: 1, constant: 0)
			topConstraint.identifier = "cardSelectorTopConstraint"
			self.view.addConstraint(topConstraint)
			UIView.animate(withDuration: 0.4, animations: { self.view.layoutIfNeeded() })
		}

		cards.enumerated().forEach { offset, selector in
			let cardView = SelectCardView(frame: .zero)
			cardView.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(cardView)
			
			cardView.tapped = { [weak self] in
				self?.hideCardSelector()
				if case .addNew = selector {
					self?.showAddCardController()
				} else {
					self?.charge()
				}
			}
			
			contentView.addConstraint(NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
														 toItem: contentView, attribute: .top, multiplier: 1, constant: CGFloat(integerLiteral: offset) * itemHeight))
			contentView.addConstraint(NSLayoutConstraint(item: cardView, attribute: .leading, relatedBy: .equal,
														 toItem: contentView, attribute: .leading, multiplier: 1, constant: 0))
			contentView.addConstraint(NSLayoutConstraint(item: cardView, attribute: .trailing, relatedBy: .equal,
														 toItem: contentView, attribute: .trailing,multiplier: 1, constant: 0))
			contentView.addConstraint(NSLayoutConstraint(item: cardView, attribute: .height, relatedBy: .equal,
														 toItem: nil, attribute: .height, multiplier: 1, constant: itemHeight))
			
			switch selector {
			case .addNew:
				cardView.leftImage.image = UIImage(named: "add")
				cardView.label.text = "ADD NEW CARD"
			case .card(let card):
				cardView.leftImage.image = UIImage(named: card.type.rawValue)
				cardView.label.text = card.cardNumber
				if card.isSelected {
					cardView.rightImage.image = UIImage(named: "selected")
				}
			}
		}
	}
}

extension MainViewController: UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let viewWidth = scrollView.frame.size.width
		let pageNumber = Int(floor((scrollView.contentOffset.x - viewWidth / 50) / viewWidth) + 1)
		pageControl.currentPage = pageNumber
		sendButton.setTitle("SEND \(viewModel.souvenirData[pageNumber].labelText.uppercased())", for: UIControlState.normal)
	}
}
