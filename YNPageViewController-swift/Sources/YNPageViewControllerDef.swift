//
//  YNPageViewControllerDef.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import Foundation
import UIKit

@objc public protocol YNPageViewControllerDelegate: NSObjectProtocol {
    /**
     滚动列表内容时回调
     
     @param pageViewController PageVC
     @param contentOffsetY 内容偏移量
     @param progress 进度
     */
    @objc optional func pageViewController(pageViewController: YNPageViewController,
                                           contentOffsetY: CGFloat,
                                           progress: CGFloat)
    
    /**
     UIScrollView拖动停止时回调, 可用来自定义 ScrollMenuView
     
     @param pageViewController PageVC
     @param scrollView UIScrollView
     */
    @objc optional func pageViewController(pageViewController: YNPageViewController,
                                           didEndDecelerating scrollView: UIScrollView)
    
    /**
     UIScrollView滚动时回调, 可用来自定义 ScrollMenuView
     
     @param pageViewController PageVC
     @param scrollView UIScrollView
     @param progress 进度
     @param fromIndex 从哪个页面
     @param toIndex 到哪个页面
     */
    @objc optional func pageViewController(pageViewController: YNPageViewController,
                                           scrollView: UIScrollView,
                                           progress: CGFloat,
                                           fromIndex: Int,
                                           toIndex: Int)
    
    /**
     点击菜单栏Item的即刻回调
     
     @param pageViewController PageVC
     @param itemButton item
     @param index 下标
     */
    @objc optional func pageViewController(pageViewController: YNPageViewController,
                                           itemButton: UIButton,
                                           index: Int)
    
    /**
     点击UIScrollMenuView AddAction
     
     @param pageViewController PageVC
     @param button Add按钮
     */
    @objc optional func pageViewController(pageViewController: YNPageViewController,
                                           addButton: UIButton)
    
}


@objc public protocol YNPageViewControllerDataSource: NSObjectProtocol {
    
    /**
     根据 index 取 数据源 ScrollView
     
     @param pageViewController PageVC
     @param index pageIndex
     @return 数据源
     */
    func pageViewController(pageViewController: YNPageViewController,
                            pageForIndex index: Int) -> UIScrollView
    
    /**
     取得ScrollView(列表)的高度 默认是控制器的高度 可用于自定义底部按钮(订单、确认按钮)等控件
     
     @param pageViewController PageVC
     @param index pageIndex
     @return ScrollView高度
     */
    @objc optional func pageViewController(pageViewController: YNPageViewController,
                                           heightForScrollViewAtIndex index: Int) -> CGFloat
    
    /**
     自定义缓存Key 如果不实现，则不允许相同的菜单栏title
     如果对页面进行了添加、删除、调整顺序、请一起调整传递进来的数据源，防止缓存Key取错
     
     @param pageViewController pageVC
     @param index pageIndex
     @return 唯一标识 (一般是后台ID)
     */
    @objc optional func pageViewController(pageViewController: YNPageViewController,
                                           customCacheKeyForIndex index: Int) -> String
    
}
