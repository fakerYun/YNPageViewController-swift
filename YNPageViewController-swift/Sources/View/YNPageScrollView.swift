//
//  YNPageScrollView.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

public class YNPageScrollView: UIScrollView, UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.panBack(gesture: gestureRecognizer) {
            return true
        }
        return false
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.panBack(gesture: gestureRecognizer) {
            return false
        }
        return true
    }

}

extension YNPageScrollView {
    
    private func panBack(gesture: UIGestureRecognizer) -> Bool {
        let locationX = 0.15 * self.yn_width
        if gesture == self.panGestureRecognizer {
            if let pan = gesture as? UIPanGestureRecognizer {
                let point = pan.translation(in: self)
                let state = gesture.state
                if state == .began || state == .possible {
                    let location = gesture.location(in: self)
                    let temp1 = location.x
                    let temp2 = self.yn_width
                    let XX = temp1.truncatingRemainder(dividingBy: temp2)
                    if point.x > 0 && XX < locationX {
                        return true
                    }
                }
            }
        }
        return false
    }
    
}
