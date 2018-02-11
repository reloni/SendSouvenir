//
//  Souvenir.swift
//  SendSouvenir
//
//  Created by Anton Efimenko on 10.02.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit

final class Souvenir: UIView {
	@IBOutlet var contentView: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	func initialize() {
		Bundle.main.loadNibNamed("Souvenir", owner: self, options:nil)
		addSubview(contentView)
		contentView.frame = bounds
		contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
	}
}
