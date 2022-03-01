//
//  UIViewController+YN.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import Foundation
import UIKit

extension UIViewController {
    
    var yn_pageViewController: YNPageViewController? {
        get {
            return self.parent as? YNPageViewController
        }
    }
    
    
}
