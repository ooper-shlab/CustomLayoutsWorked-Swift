//
//  MyCustomCell.swift
//  CustomLayoutsWorked
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/15.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit

class MyCustomCell: UICollectionViewCell {
    let textLabel: UILabel
    
    override var frame: CGRect {
        get {return super.frame}
        set {
            super.frame = newValue
            let subframe = CGRect(origin: CGPointZero, size: newValue.size)
            self.textLabel.frame = subframe
        }
    }
    
    override init(frame: CGRect) {
        let subframe = CGRect(origin: CGPointZero, size: frame.size)
        textLabel = UILabel(frame: subframe)
        textLabel.backgroundColor = UIColor.blueColor()
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.adjustsFontSizeToFitWidth = true
        super.init(frame: frame)
        self.contentView.addSubview(self.textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
}