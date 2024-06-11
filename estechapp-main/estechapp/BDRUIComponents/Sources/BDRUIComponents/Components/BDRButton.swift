//
//
//  RoundedButton.swift
//  Bederr
//
//  Created by JUNIOR on 11/15/18.
//  Copyright © 2018 Bederr. All rights reserved.
//

import UIKit
public enum TypeStatusButton {
    case enabled
    case disable
    case secondary
}

@IBDesignable public class BDRButton: UIButton {

    var currentBackground: UIColor?
    public var status: TypeStatusButton = .enabled {
        didSet {
            switch status {
            case .enabled:
                backgroundColor = UIColor.button
                setTitleColor(UIColor.white, for:  .normal)
                layer.borderWidth = 0
                isUserInteractionEnabled = true
            case .disable:
                backgroundColor = .disabledButton
                layer.borderWidth = 0
                isUserInteractionEnabled = false
            case .secondary:
                backgroundColor = .accent
                isUserInteractionEnabled = true
            }
        }
    }
    
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 5 {
        didSet {
            self.layer.borderWidth = self.borderWidth
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var borderColor:UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor.white, for:  .normal)
        cornerRadius = 20
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTitleColor(UIColor.white, for:  .normal)
        cornerRadius = 20
        setupButton()
    }
    
    // MARK: - Private
    fileprivate func setupButton() {
        heightAnchor.constraint(equalToConstant: 65).isActive = true
        titleLabel?.font = .bederrBold(19)
        titleLabel?.textColor = UIColor.white
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        backgroundColor = .button
        currentBackground = .button
    }
    
    public override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            }
            else {
                switch status {
                case .enabled:
                    backgroundColor = UIColor.button
                case .disable:
                    backgroundColor = UIColor.disabledButton
                case .secondary:
                    backgroundColor = UIColor.accent
                }
            }
            super.isHighlighted = newValue
        }
    }
   
}
