//
//  UIScrollView+YN.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import Foundation
import UIKit

typealias YNPageScrollViewDidScrollView = (_ scrollView: UIScrollView) -> ()
typealias YNPageScrollViewBeginDragginScrollView = (_ scrollView: UIScrollView) -> ()
extension UIScrollView {
    
    private struct RuntimeKey {
        static let yn_observerDidScrollKey = UnsafeRawPointer(bitPattern: "yn_observerDidScrollKey".hashValue)
        static let yn_pageScrollViewDidScrollKey = UnsafeRawPointer(bitPattern: "yn_pageScrollViewDidScrollKey".hashValue)
        static let yn_pageScrollViewBeginDragginScrollKey = UnsafeRawPointer(bitPattern: "yn_pageScrollViewBeginDragginScrollKey".hashValue)
        /// ...其他Key声明
    }
    
    var yn_observerDidScrollView: Bool {
        set {
            objc_setAssociatedObject(self, RuntimeKey.yn_observerDidScrollKey!, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.yn_observerDidScrollKey!) as? Bool ?? false
        }
    }
    
    @objc var yn_pageScrollViewDidScrollBlock: YNPageScrollViewDidScrollView? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.yn_pageScrollViewDidScrollKey!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.yn_pageScrollViewDidScrollKey!) as? YNPageScrollViewDidScrollView
        }
    }
    
    @objc var yn_pageScrollViewBeginDragginScrollBlock: YNPageScrollViewBeginDragginScrollView? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.yn_pageScrollViewBeginDragginScrollKey!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, RuntimeKey.yn_pageScrollViewBeginDragginScrollKey!) as? YNPageScrollViewBeginDragginScrollView
        }
    }
    
    @objc func yn_scrollViewDidScrollView() {
        self.yn_scrollViewDidScrollView()
        if self.yn_observerDidScrollView && (self.yn_pageScrollViewDidScrollBlock != nil) {
            self.yn_pageScrollViewDidScrollBlock?(self)
        }
    }
    
    @objc func yn_scrollViewWillBeginDragging() {
        self.yn_scrollViewWillBeginDragging()
        if self.yn_observerDidScrollView && (self.yn_pageScrollViewBeginDragginScrollBlock != nil) {
            self.yn_pageScrollViewBeginDragginScrollBlock?(self)
        }
    }
    
}

extension UIScrollView {
    
    static func initializeMethod() {
        if self !== UIScrollView.self {
            return
        }
        DispatchQueue.yn_shareOnce(token: "YNPageScrollViewExtend") {
            self.swizzleMethod(oldSelector: NSSelectorFromString("_notifyDidScroll"), newSelector: #selector(yn_scrollViewDidScrollView))
            self.swizzleMethod(oldSelector: NSSelectorFromString("_scrollViewWillBeginDragging"), newSelector: #selector(yn_scrollViewWillBeginDragging))
        }
        
    }
    
    class func swizzleMethod(oldSelector: Selector, newSelector: Selector) {

        let originalMethod = class_getInstanceMethod(UIScrollView.self, oldSelector)
        let swizzledMethod = class_getInstanceMethod(UIScrollView.self, newSelector)

        // 运行时为类添加我们自己写的my_sendAction(_:to:forEvent:)
        let didAddMethod = class_addMethod(UIScrollView.self, oldSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))

        if didAddMethod {
            // 如果添加成功，则交换方法
            class_replaceMethod(UIScrollView.self, newSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            // 如果添加失败，则交换方法的具体实现
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    public func yn_setContentOffsetY(offsetY: CGFloat) {
        if self.contentOffset.y != offsetY {
            self.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
    
}

public extension DispatchQueue {
    private static var _tracker = [String]()
    static func yn_shareOnce(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _tracker.contains(token) {
            return
        }
        _tracker.append(token)
        block()
    }
}
