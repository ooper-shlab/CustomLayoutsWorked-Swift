//
//  MyCustomLayout.swift
//  CustomLayoutsWorked
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/15.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit

let INSET_TOP: CGFloat = 20
let INSET_LEFT: CGFloat = 20
let INSET_BOTTOM: CGFloat = 20
let INSET_RIGHT: CGFloat = 20
//###
let GAP_WIDTH = INSET_LEFT + INSET_RIGHT
let GAP_HEIGHT = INSET_TOP + INSET_BOTTOM
//###
let ITEM_WIDTH: CGFloat = 180
let ITEM_HEIGHT: CGFloat = 48
//###
let OFFSET_TOP: CGFloat = 20
let OFFSET_LEFT: CGFloat = 0
//###
let ARRANGE_WIDTH = GAP_WIDTH + ITEM_WIDTH
let ARRANGE_HEIGHT = GAP_HEIGHT + ITEM_HEIGHT

class MyCustomLayoutAttributes: UICollectionViewLayoutAttributes {
    var children: [NSIndexPath] = []
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let otherAttributes = object as? MyCustomLayoutAttributes
        where self.children == otherAttributes.children {
            return super.isEqual(object)
        }
        return false
    }
}


class MySupplementaryAttributes: UICollectionViewLayoutAttributes {
    
    var baseFrame: CGRect = CGRect()
    var hasPreviousSibling: Bool = false
    var hasNextSibling: Bool = false
    var height: Int = 1

    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! MySupplementaryAttributes
        copy.baseFrame = self.baseFrame
        copy.hasPreviousSibling = self.hasPreviousSibling
        copy.hasNextSibling = self.hasNextSibling
        copy.height = self.height
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let otherAttributes = object as? MySupplementaryAttributes
            where CGRectEqualToRect(self.baseFrame, otherAttributes.baseFrame)
            && self.hasPreviousSibling == otherAttributes.hasPreviousSibling
            && self.hasNextSibling == otherAttributes.hasNextSibling
            && self.height == otherAttributes.height
        {
                return super.isEqual(object)
        }
        return false
    }
    
    private func fillFrame() {
        var myFrame = baseFrame
        myFrame.origin.x = baseFrame.origin.x - GAP_WIDTH
        myFrame.size.width = GAP_WIDTH
        assert(height > 0)
        if hasNextSibling {
            myFrame.size.height += CGFloat(height - 1) * ARRANGE_HEIGHT
        }
        if hasPreviousSibling {
            myFrame.size.height += GAP_HEIGHT
            myFrame.origin.y -= GAP_HEIGHT
        }
        self.frame = myFrame
    }
}


@objc protocol MyCustomProtocol {
    func numRowsForClassAndChildrenAtIndexPath(indexPath: NSIndexPath) -> Int
    //###
    func numChildrenForClassAtIndexPath(indexPath: NSIndexPath) -> Int
}


class MyCustomLayout: UICollectionViewLayout {
    weak var customDataSource: MyCustomProtocol!
    
    typealias CellInformationType = [NSIndexPath: UICollectionViewLayoutAttributes]
    private var layoutInformation: [String: CellInformationType] = [:]
    private var maxNumRows: Int = 0
    private let insets: UIEdgeInsets = UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGHT)
    
    private var itemCountInSection: [Int] = []
    override func prepareLayout() {
        //###var layoutInformation: [String: CellInformationType] = [:]
        var cellInformation: CellInformationType = [:]
        let numSections = self.collectionView!.numberOfSections()
        itemCountInSection = Array(count: numSections, repeatedValue: 0) //###used in attributesWithChildrenAtIndexPath
        for section in 0..<numSections {
            let numItems = self.collectionView!.numberOfItemsInSection(section)
            for item in 0..<numItems {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let attributes = self.attributesWithChildrenAtIndexPath(indexPath)
                cellInformation[indexPath] = attributes
            }
        }
        layoutInformation["MyCellKind"] = cellInformation //###
        //
        for section in (0..<numSections).reverse() {
            let numItems = self.collectionView!.numberOfItemsInSection(section)
            var totalHeight = 0
            for item in 0..<numItems {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let attributes = cellInformation[indexPath]! // 1
                attributes.frame = self.frameForCellAtIndexPath(indexPath, withHeight: totalHeight)
                self.adjustFramesOfChildrenAndConnectorsForClassAtIndexPath(indexPath) // 2
                totalHeight += self.customDataSource.numRowsForClassAndChildrenAtIndexPath(indexPath) // 3
            }
            if section == 0 {
                self.maxNumRows = totalHeight // 4
            }
        }
        //
        var supplementaryInfo: CellInformationType = [:]
        for section in 1..<numSections {    //###
            let numItems = self.collectionView!.numberOfItemsInSection(section)
            for item in 0..<numItems {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let supplementaryAttributes = MySupplementaryAttributes(forSupplementaryViewOfKind: "ConnectionViewKind", withIndexPath: indexPath)
                supplementaryInfo[indexPath] = supplementaryAttributes
            }
        }
        //###
        layoutInformation["ConnectionViewKind"] = supplementaryInfo
        for section in 0..<numSections - 1 {    //###
            let numItems = self.collectionView!.numberOfItemsInSection(section)
            for item in 0..<numItems {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let layoutAttribute = layoutInformation["MyCellKind"]![indexPath]! as! MyCustomLayoutAttributes
                fillSupplementaryAttribute(layoutAttribute)
            }
        }
        //self.layoutInformation = layoutInformation //###
    }
    
    private func fillSupplementaryAttribute(layoutAttribute: MyCustomLayoutAttributes) {
        for (index, childIndexPath) in layoutAttribute.children.enumerate() {
            let childLayoutAttribute = layoutInformation["MyCellKind"]![childIndexPath]! as! MyCustomLayoutAttributes
            let childSupplementaryAttribute = layoutInformation["ConnectionViewKind"]![childIndexPath]! as! MySupplementaryAttributes
            childSupplementaryAttribute.hasPreviousSibling = (index > 0)
            childSupplementaryAttribute.hasNextSibling = (index < layoutAttribute.children.count - 1)
            childSupplementaryAttribute.baseFrame = childLayoutAttribute.frame
            childSupplementaryAttribute.height = customDataSource.numRowsForClassAndChildrenAtIndexPath(childIndexPath)
            childSupplementaryAttribute.fillFrame()
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        let width = CGFloat(self.collectionView!.numberOfSections()) * (ITEM_WIDTH + self.insets.left + self.insets.right)
        let height = CGFloat(self.maxNumRows) * (ITEM_HEIGHT + insets.top + insets.bottom)
        return CGSizeMake(width, height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var myAttributes: [UICollectionViewLayoutAttributes] = []
        myAttributes.reserveCapacity(self.layoutInformation.count)
        for (_, attributesDict) in self.layoutInformation {
            for (_, attributes) in attributesDict {
                if CGRectIntersectsRect(rect, attributes.frame) {
                    myAttributes.append(attributes) //###
                }
            }
        }
        return myAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutInformation["MyCellKind"]![indexPath] //###
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutInformation[kind]?[indexPath] //###
    }

    //###
    override class func layoutAttributesClass() -> AnyClass {
        return MyCustomLayoutAttributes.self
    }
    
    private func attributesWithChildrenAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        //###
        //instantiate layout attributes
        let attributesClass = self.dynamicType.layoutAttributesClass() as! MyCustomLayoutAttributes.Type
        let attributes = attributesClass.init(forCellWithIndexPath: indexPath)
        //fill children indexPaths
        let section = indexPath.section
        let numChildren = customDataSource.numChildrenForClassAtIndexPath(indexPath)
        if numChildren > 0 {
            var item = itemCountInSection[section + 1]
            for _ in 0..<numChildren {
                let childIndexPath = NSIndexPath(forItem: item, inSection: section + 1)
                attributes.children.append(childIndexPath)
                ++item
            }
            itemCountInSection[section + 1] = item
        }
        return attributes
    }
    
    private func frameForCellAtIndexPath(indexPath: NSIndexPath, withHeight height: Int) -> CGRect {
        //###
        let x = CGFloat(indexPath.section) * ARRANGE_WIDTH + insets.left + OFFSET_LEFT
        let y = CGFloat(height) * ARRANGE_HEIGHT + insets.top + OFFSET_TOP
        let rect = CGRect(x: x, y: y, width: ITEM_WIDTH, height: ITEM_HEIGHT)
        return rect
    }
    
    private func adjustFramesOfChildrenAndConnectorsForClassAtIndexPath(indexPath: NSIndexPath) {
        //###
        let attributes = layoutInformation["MyCellKind"]![indexPath]! as! MyCustomLayoutAttributes
        var height = 0
        for childIndexPath in attributes.children {
            let childAttributes = layoutInformation["MyCellKind"]![childIndexPath]!
            var childFrame = childAttributes.frame
            childFrame.origin.y = attributes.frame.origin.y + CGFloat(height) * ARRANGE_HEIGHT
            childAttributes.frame = childFrame
            height += customDataSource.numRowsForClassAndChildrenAtIndexPath(childIndexPath)
        }
    }
    
    //###
//    private func frameForSupplementaryViewOfKind(kind: String, atIndexPath indexPath: NSIndexPath) -> CGRect {
//        //...
//        return CGRect()
//    }
}