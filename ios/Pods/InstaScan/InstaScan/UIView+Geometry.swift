//
//  UIView+Geometry.swift
//  Geometry
//
//  Created by Tuomas Artman on 7.9.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import CoreGraphics
import Foundation
import UIKit

/// Extends CGRect with helper properties for positioning and setting dimensions

extension CGRect: ExpressibleByStringLiteral {
    
    /// The top coordinate of the rect.
     var top: CGFloat {
        get {
            return origin.y
        }
        set(value) {
            origin.y = value
        }
    }
    
    // The left-side coordinate of the rect.
     var left: CGFloat {
        get {
            return origin.x
        }
        set(value) {
            origin.x = value
        }
    }
    
    // The bottom coordinate of the rect. Setting this will change origin.y of the rect according to
    // the height of the rect.
     var bottom: CGFloat {
        get {
            return origin.y + size.height
        }
        set(value) {
            origin.y = value - size.height
        }
    }
    
    // The right-side coordinate of the rect. Setting this will change origin.x of the rect according to
    // the width of the rect.
     var right: CGFloat {
        get {
            return origin.x + size.width
        }
        set(value) {
            origin.x = value - size.width
        }
    }
    
    // The center x coordinate of the rect.
     var centerX: CGFloat {
        get {
            return origin.x + size.width / 2
        }
        set (value) {
            origin.x = value - size.width / 2
        }
    }
    
    // The center y coordinate of the rect.
     var centerY: CGFloat {
        get {
            return origin.y + size.height / 2
        }
        set (value) {
            origin.y = value - size.height / 2
        }
    }
    
    // The center of the rect.
     var center: CGPoint {
        get {
            return CGPoint(x: centerX, y: centerY)
        }
        set (value) {
            centerX = value.x
            centerY = value.y
        }
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    public init(stringLiteral value: StringLiteralType) {
        self.init()
        let rect: CGRect
        if value[value.startIndex] != "{" {
            let comp = value.components(separatedBy: ",")
            if comp.count == 4 {
                rect = NSCoder.cgRect(for: "{{\(comp[0]),\(comp[1])}, {\(comp[2]), \(comp[3])}}")
            } else {
                rect = CGRect.zero
            }
        } else {
            rect = NSCoder.cgRect(for: value)
        }
        
        self.size = rect.size;
        self.origin = rect.origin;
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public typealias UnicodeScalarLiteralType = StringLiteralType

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
}

extension CGPoint: ExpressibleByStringLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        
        let point:CGPoint;
        if value[value.startIndex] != "{" {
            point = NSCoder.cgPoint(for: "{\(value)}")
        } else {
            point = NSCoder.cgPoint(for: value)
        }
        self.x = point.x;
        self.y = point.y;
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public typealias UnicodeScalarLiteralType = StringLiteralType

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
}

extension UIView {
    
    /// The top coordinate of the UIView.
     var top: CGFloat {
        get {
            return frame.top
        }
        set(value) {
            var frame = self.frame
            frame.top = value
            self.frame = frame
        }
    }
    
    /// The left coordinate of the UIView.
     var left: CGFloat {
        get {
            return frame.left
        }
        set(value) {
            var frame = self.frame
            frame.left = value
            self.frame = frame
        }
    }
    
    /// The bottom coordinate of the UIView.
     var bottom: CGFloat {
        get {
            return frame.bottom
        }
        set(value) {
            var frame = self.frame
            frame.bottom = value
            self.frame = frame
        }
    }
    
    /// The right coordinate of the UIView.
     var right: CGFloat {
        get {
            return frame.right
        }
        set(value) {
            var frame = self.frame
            frame.right = value
            self.frame = frame
        }
    }
    
    // The width of the UIView.
     var width: CGFloat {
        get {
            return frame.width
        }
        set(value) {
            var frame = self.frame
            frame.size.width = value
            self.frame = frame
        }
    }
    
    // The height of the UIView.
     var height: CGFloat {
        get {
            return frame.height
        }
        set(value) {
            var frame = self.frame
            frame.size.height = value
            self.frame = frame
        }
    }
    
    /// The horizontal center coordinate of the UIView.
     var centerX: CGFloat {
        get {
            return frame.centerX
        }
        set(value) {
            var frame = self.frame
            frame.centerX = value
            self.frame = frame
        }
    }
    
    /// The vertical center coordinate of the UIView.
     var centerY: CGFloat {
        get {
            return frame.centerY
        }
        set(value) {
            var frame = self.frame
            frame.centerY = value
            self.frame = frame
        }
    }
}
