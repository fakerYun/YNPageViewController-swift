//
//  UIView+YN.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import Foundation
import UIKit

let kYNPAGE_SCREEN_WIDTH = UIScreen.main.bounds.size.width
let kYNPAGE_SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let kYNPAGE_STATUSBAR_HEIGHT = UIApplication.shared.statusBarFrame.size.height
let kYNPAGE_IS_IPHONE_X = kYNPAGE_STATUSBAR_HEIGHT > 20 ? true:false
let kYNPAGE_NAVHEIGHT = kYNPAGE_STATUSBAR_HEIGHT + 44.0
let kYNPAGE_TABBARHEIGHT = kYNPAGE_IS_IPHONE_X ? 83.0 : 49.0
let kLESS_THAN_iOS11 = (UIDevice.current.systemVersion as NSString).integerValue < 11 ? true:false

public extension UIView {
    
    var yn_x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var yn_y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var yn_width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var yn_height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var yn_bottom: CGFloat {
        get {
            self.frame.origin.y + self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }
    
}
