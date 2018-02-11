//
//  SelectCardView.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 11.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit

final class SelectCardView: UIView {
	@IBOutlet var contentView: UIView!
	@IBOutlet weak var leftImage: UIImageView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var rightImage: UIImageView!
	var tapped: (() -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	func initialize() {
		Bundle.main.loadNibNamed("SelectCardView", owner: self, options:nil)
		addSubview(contentView)
		contentView.frame = bounds
		contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(itemTapped))
		contentView.addGestureRecognizer(recognizer)
	}
	
	@objc func itemTapped() {
		tapped?()
	}
}

