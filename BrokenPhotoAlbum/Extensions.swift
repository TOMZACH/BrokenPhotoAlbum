//
//  Extensions.swift
//  BrokenPhotoAlbum
//
//  Created by Tomzach Inc. on 9/26/19.
//  Copyright © 2019 Tomzach Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    static var backgroundColor = UIColor.white
    static var tileColor = UIColor.green
}

extension CGRect {
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.remainder.origin.x += 2
            slices.remainder.size.width -= 2
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += 2
            slices.remainder.size.height -= 2
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
}
