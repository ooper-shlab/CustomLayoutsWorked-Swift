//
//  MyConnectionView.swift
//  CustomLayoutsWorked
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/15.
//  Copyright © 2015-2017 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit

class MyConnectionView: UICollectionReusableView {
    var connectorColor: UIColor = UIColor.cyan
    
    private(set) var hasPreviousSibling: Bool = false
    private(set) var hasNextSibling: Bool = false
    private(set) var height: Int = 1
    private(set) var middle: CGFloat = 0
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        let attributes = layoutAttributes as! MySupplementaryAttributes
        self.hasPreviousSibling = attributes.hasPreviousSibling
        self.hasNextSibling = attributes.hasNextSibling
        self.height = attributes.height
        self.middle = attributes.baseFrame.midY
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let midY = self.middle - self.frame.origin.y
        let midX = self.frame.size.width / 2.0
        let leftX = self.frame.size.width
        path.move(to: CGPoint(x: leftX, y: midY))
        path.addLine(to: CGPoint(x: midX, y: midY))
        if hasPreviousSibling {
            path.addLine(to: CGPoint(x: midX, y: 0))
        } else {
            path.addLine(to: CGPoint(x: 0, y: midY))
        }
        if hasNextSibling {
            let maxY = self.frame.size.height
            path.move(to: CGPoint(x: midX, y: midY))
            path.addLine(to: CGPoint(x: midX, y: maxY))
        }
        connectorColor.setStroke()
        path.lineWidth = 2
        path.stroke()
    }
}
