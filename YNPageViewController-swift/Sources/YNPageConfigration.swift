//
//  YNPageConfigration.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

/// YNPage样式
public enum YNPageStyle: Int {
    case Top  //MenuView在顶部
    case Navigation  //MenuView在系统导航条
    case SuspensionTop  //MenuView悬浮，刷新控件在HeaderView顶部
    case SuspensionCenter  //MenuView悬浮，刷新控件在HeaderView底部
    case SuspensionTopPause  //MenuView悬浮，刷新控件在HeaderView顶部 停顿 类似QQ联系人页面
}

/// 头部放大样式
public enum YNPageHeaderViewScaleMode: Int {
    case Top  //Top固定
    case Center  //Center固定
}

public class YNPageConfigration: NSObject {
    /** 是否显示导航条 true */
    public var showNavigation: Bool = true
    /** 是否显示Tabbar false */
    public var showTabbar: Bool = false
    /** 裁剪内容高度 用来添加最上层控件 添加在父类view上 */
    public var cutOutHeight: CGFloat = 0
    /** 菜单位置风格 默认 YNPageStyleTop */
    public var pageStyle: YNPageStyle = .Top
    /** 悬浮ScrollMenu偏移量 默认 0 */
    public var suspenOffsetY: CGFloat = 0
    /** 页面是否可以滚动 默认 true */
    public var pageScrollEnabled: Bool = true
    /** 是否开启头部伸缩效果   要伸缩效果最好不要有下拉刷新控件 false */
    public var headerViewCouldScale: Bool = false
    /** 头部伸缩样式 */
    public var headerViewScaleMode: YNPageHeaderViewScaleMode = .Top
    /** 头部是否可以滚页面 false */
    public var headerViewCouldScrollPage: Bool = false
    /** headerView + menu height */
    private(set) var pageHeaderViewOriginHeight: CGFloat = 44
    
    // MARK: UIScrollMenuView Config
    /** 是否显示遮盖 */
    public var showConver: Bool = false
    /** 是否显示线条 true */
    public var showScrollLine: Bool = true
    /** 是否显示底部线条 false */
    public var showBottomLine: Bool = false
    /** 颜色是否渐变 true */
    public var showGradientColor: Bool = true
    /** 是否显示自定义按钮 false */
    public var showAddButton: Bool = false
    /** 菜单是否滚动 true */
    public var scrollMenu: Bool = true
    /** 菜单弹簧效果 true */
    public var bounces: Bool = true
    /**
     *  是否是居中 (当所有的Item+margin的宽度小于ScrollView宽度)  默认 YES
     *  scrollMenu = NO，aligmentModeCenter = NO 会变成平分
     *  */
    public var aligmentModeCenter: Bool = true
    /** 当aligmentModeCenter 变为平分时 是否需要线条宽度等于字体宽度 默认 false */
    public var lineWidthEqualFontWidth: Bool = false
    /** 是否固定指示器宽度 false */
    public var isFixLineWidth: Bool = false
    /** 固定指示器宽度,默认0， isFixLineWidth为true生效  */
    public var fixLineWidth: CGFloat = 0
    
    /** 自定义Item数组 */
    public var buttonArray: [UIButton] = []
    /** 自定义按钮N图片 */
    public var addButtonNormalImageName: String?
    /** 自定义按钮H图片 */
    public var addButtonHightImageName: String?
    /** 线条color */
    public var lineColor: UIColor = .red
    /** 遮盖color */
    public var converColor: UIColor = .groupTableViewBackground
    /** 菜单背景color */
    public var scrollViewBackgroundColor: UIColor = .white
    /** 选项未选中color */
    public var normalItemColor: UIColor = .gray
    /** 选项选中color */
    public var selectedItemColor: UIColor = .red
    /** 线条圆角 0 */
    public var bottomLineCorner: CGFloat = 0
    /** 线条高度 2 */
    public var lineHeight: CGFloat = 2
    /** 线条底部距离 0 */
    public var lineBottomMargin: CGFloat = 0
    /** 线条左右偏移量 0 */
    public var lineLeftAndRightMargin: CGFloat = 0
    /** 线条圆角 0 */
    public var lineCorner: CGFloat = 0
    /** 线条左右增加 0  默认线条宽度是等于 item宽度 */
    public var lineLeftAndRightAddWidth: CGFloat = 0
    /** 底部线条颜色 */
    public var bottomLineBgColor: UIColor = .green
    /** 底部线height 1 */
    public var bottomLineHeight: CGFloat = 1
    /** 底部线条左右偏移量 0 */
    public var bottomLineLeftAndRightMargin: CGFloat = 0
    /** 遮盖height 28 */
    public var converHeight: CGFloat = 28
    /** 菜单height 默认 44 */
    public var menuHeight: CGFloat = 44
    /** 菜单widht 默认是 屏幕宽度 */
    public var menuWidth: CGFloat = kYNPAGE_SCREEN_WIDTH
    /** 遮盖圆角 14 */
    public var coverCornerRadius: CGFloat = 14
    /** 选项相邻间隙 15 */
    public var itemMargin: CGFloat = 15
    /** 选项左边或者右边间隙 15 */
    public var itemLeftAndRightMargin: CGFloat = 15
    /** 选项字体 14 */
    public var itemFont: UIFont = .systemFont(ofSize: 14)
    /** 选中字体 */
    public var selectedItemFont: UIFont = .systemFont(ofSize: 14)
    /** 缩放系数 */
    public var itemMaxScale: CGFloat = 0
    /** 临时Top高度 */
    public var tempTopHeight: CGFloat = 0
    /** 内容区域 */
    public var contentHeight: CGFloat = 0
    
    //##################################无需关注##########################################
    public var deltaScale: CGFloat {
        get { return self.itemMaxScale - 1.0 }
    }
    public var deltaNorR: CGFloat = 0
    public var deltaNorG: CGFloat = 0
    public var deltaNorB: CGFloat = 0
    public var deltaSelR: CGFloat = 0
    public var deltaSelG: CGFloat = 0
    public var deltaSelB: CGFloat = 0
}

extension YNPageConfigration {
    
    private var normalColorArrays: [CGFloat] {
        get {
            return self.getRGBArray(color: self.normalItemColor)
        }
    }
    
    private var selectedColorArrays: [CGFloat] {
        get {
            return self.getRGBArray(color: self.selectedItemColor)
        }
    }
    
    private var deltaColorArrays: [CGFloat] {
        get {
            var array: [CGFloat] = []
            for (idx, obj) in self.normalColorArrays.enumerated() {
                array.append(self.selectedColorArrays[idx] - obj)
            }
            return array
        }
    }
    
    private func getRGBArray(color: UIColor) -> [CGFloat] {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [r, g , b, a]
    }
    
    public func setRGB(progress: CGFloat) {
        self.deltaNorR = self.selectedColorArrays[0] - self.deltaColorArrays[0]*progress
        self.deltaNorG = self.selectedColorArrays[1] - self.deltaColorArrays[1]*progress
        self.deltaNorB = self.selectedColorArrays[2] - self.deltaColorArrays[2]*progress
        
        self.deltaSelR = self.normalColorArrays[0] + self.deltaColorArrays[0]*progress
        self.deltaSelG = self.normalColorArrays[1] + self.deltaColorArrays[1]*progress
        self.deltaSelB = self.normalColorArrays[2] + self.deltaColorArrays[2]*progress
    }
}
