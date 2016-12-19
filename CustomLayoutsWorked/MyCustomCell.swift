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
            let subframe = CGRect(origin: CGPoint.zero, size: newValue.size)
            self.textLabel.frame = subframe
        }
    }
    
    override init(frame: CGRect) {
        let subframe = CGRect(origin: CGPoint.zero, size: frame.size)
        textLabel = UILabel(frame: subframe)
        textLabel.backgroundColor = UIColor.blue
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.adjustsFontSizeToFitWidth = true
        super.init(frame: frame)
        self.contentView.addSubview(self.textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}
