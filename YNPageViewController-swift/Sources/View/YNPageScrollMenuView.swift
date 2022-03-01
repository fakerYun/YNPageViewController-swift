//
//  YNPageScrollMenuView.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

@objc public protocol YNPageScrollMenuViewDelegate: NSObjectProtocol {
    /// 点击item
    @objc optional func pagescrollMenuViewItemOnClick(button: UIButton, index: Int)
    /// 点击Add按钮
    @objc optional func pagescrollMenuViewAddButtonAction(button: UIButton)
}

let kYNPageScrollMenuViewConverMarginX: CGFloat = 5
let kYNPageScrollMenuViewConverMarginW: CGFloat = 10

public class YNPageScrollMenuView: UIView {
    
    /// 标题数组
    public var titles: [String] = []
    
    /// 添加按钮
    public lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: configration.addButtonNormalImageName ?? ""), for: .normal)
        btn.setImage(UIImage(named: configration.addButtonHightImageName ?? ""), for: .highlighted)
        btn.addTarget(self, action: #selector(addButtonAction(button:)), for: .touchUpInside)
        return btn
    }()
    
    /// line指示器
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = configration.lineColor
        return view
    }()
    
    /// 蒙层
    private lazy var converView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = configration.converColor.cgColor
        view.layer.cornerRadius = configration.coverCornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    /// ScrollView
    private lazy var scrollView: YNPageScrollView = {
        let scrollView = YNPageScrollView()
        scrollView.isPagingEnabled = false
        scrollView.bounces = self.configration.bounces
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = self.configration.scrollMenu
        return scrollView
    }()
    /// 底部线条
    private var bottomLine: UIView?
    /// 配置信息
    private var configration: YNPageConfigration!
    /// 代理
    private weak var delegate: YNPageScrollMenuViewDelegate?
    /// 上次index
    private var lastIndex: Int = 0
    /// 当前index
    private var currentIndex: Int = 0
    /// items
    private var itemsArrayM: [UIButton] = []
    /// item宽度
    private var itemsWidthArraM: [CGFloat] = []
    
    convenience init(frame: CGRect,
                     titles: [String],
                     configration: YNPageConfigration,
                     delegate: YNPageScrollMenuViewDelegate?,
                     currentIndex: Int) {
        var newFrame: CGRect = frame
        newFrame.size.height = configration.menuHeight
        newFrame.size.width = configration.menuWidth
        self.init(frame: newFrame)
        self.titles = titles
        self.delegate = delegate
        self.configration = configration
        self.currentIndex = currentIndex
        self.itemsArrayM = []
        self.itemsWidthArraM = []
        
        setupSubviews()
    }
    
    // MARK: Private Method
    private func setupSubviews() {
        self.backgroundColor = configration.scrollViewBackgroundColor
        setupItems()
        setupOtherViews()
    }
    
    private func setupItems() {
        if configration.buttonArray.count > 0 && titles.count == configration.buttonArray.count {
            for (idx, item) in configration.buttonArray.enumerated() {
                setupButton(itemBtn: item, title: titles[idx], idx: idx)
            }
        }else {
            for (idx, title) in titles.enumerated() {
                let btn = UIButton(type: .custom)
                setupButton(itemBtn: btn, title: title, idx: idx)
//                btn.titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
    }
    
    private func setupOtherViews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: configration.showAddButton ? yn_width - yn_height : yn_width, height: yn_height)
        addSubview(scrollView)
        if configration.showAddButton {
            addButton.frame = CGRect(x: yn_width - yn_height, y: 0, width: yn_height, height: yn_height - configration.bottomLineHeight)
            addSubview(addButton)
        }
        
        var itemX: CGFloat = 0
        var itemY: CGFloat = 0
        var itemW: CGFloat = 0
        let itemH: CGFloat = self.yn_height - configration.lineHeight
        
        for (idx, btn) in itemsArrayM.enumerated() {
            if idx == 0 {
                itemX += configration.itemLeftAndRightMargin
            }else{
                itemX += configration.itemMargin + itemsWidthArraM[idx - 1]
            }
            btn.frame = CGRect(x: itemX, y: itemY, width: itemsWidthArraM[idx], height: itemH)
        }
        
        let scrollSizeWidht: CGFloat = configration.itemLeftAndRightMargin + (itemsArrayM.last?.frame.maxX ?? 0)
        //不超出宽度
        if scrollSizeWidht <= scrollView.yn_width {
            itemX = 0
            itemY = 0
            itemW = 0
            var left: CGFloat = 0
            for width in self.itemsWidthArraM {
                left += width
            }
            left = (scrollView.yn_width - left - configration.itemMargin * CGFloat((itemsWidthArraM.count - 1))) * 0.5
            /// 居中且有剩余间距
            if configration.aligmentModeCenter && left >= 0 {
                for (idx, btn) in itemsArrayM.enumerated() {
                    if idx == 0 {
                        itemX += left
                    }else {
                        itemX += configration.itemMargin + itemsWidthArraM[idx - 1]
                    }
                    btn.frame = CGRect(x: itemX, y: itemY, width: itemsWidthArraM[idx], height: itemH)
                }
                scrollView.contentSize = CGSize(width: left + (itemsArrayM.last?.frame.maxX ?? 0), height: scrollView.yn_height)
            }else {
                ///不能滚动则平分
                if !configration.scrollMenu {
                    for (idx, btn) in itemsArrayM.enumerated() {
                        itemW = scrollView.yn_width / CGFloat(itemsArrayM.count)
                        itemX = itemW * CGFloat(idx)
                        btn.frame = CGRect(x: itemX, y: itemY, width: itemW, height: itemH)
                    }
                    scrollView.contentSize = CGSize(width: (itemsArrayM.last?.frame.maxX ?? 0), height: scrollView.yn_height)
                }else {
                    scrollView.contentSize = CGSize(width: scrollSizeWidht, height: scrollView.yn_height)
                }
            }
        }else {
            scrollView.contentSize = CGSize(width: scrollSizeWidht, height: scrollView.yn_height)
        }
        
        var lineW: CGFloat = configration.isFixLineWidth ? configration.fixLineWidth:(itemsArrayM.first?.yn_width ?? 0)
        var lineX: CGFloat = (itemsArrayM.first?.yn_x ?? 0) + ((itemsArrayM.first?.yn_width ?? 0) - lineW)/2
        let lineY: CGFloat = scrollView.yn_height - configration.lineHeight
        let lineH: CGFloat = configration.lineHeight
        
        /// 处理Line宽度等于字体宽度
        if !configration.scrollMenu &&
            !configration.aligmentModeCenter &&
            configration.lineWidthEqualFontWidth {
            if configration.isFixLineWidth {
                lineX = (itemsArrayM.first?.yn_x ?? 0) + ((itemsArrayM.first?.yn_width ?? 0) - configration.fixLineWidth)/2
                lineW = configration.fixLineWidth
            }else {
                lineX = (itemsArrayM.first?.yn_x ?? 0) + ((itemsArrayM.first?.yn_width ?? 0) - (itemsWidthArraM.first ?? 0))/2
                lineW = itemsWidthArraM.first ?? 0
            }
        }
        
        /// conver
        if configration.showConver {
            converView.frame = CGRect(x: lineX - kYNPageScrollMenuViewConverMarginX, y: (scrollView.yn_height - configration.converHeight - configration.lineHeight)*0.5, width: kYNPageScrollMenuViewConverMarginW, height: configration.converHeight)
            scrollView.insertSubview(converView, at: 0)
        }
        
        /// bottomLine
        if configration.showBottomLine {
            bottomLine = UIView()
            bottomLine?.backgroundColor = configration.bottomLineBgColor
            bottomLine?.frame = CGRect (x: configration.bottomLineLeftAndRightMargin, y: self.yn_height - configration.bottomLineHeight, width: self.yn_width - configration.bottomLineLeftAndRightMargin*2, height: configration.bottomLineHeight)
            bottomLine?.layer.cornerRadius = configration.bottomLineCorner
            self.insertSubview(bottomLine!, at: 0)
        }
        
        /// scrollLine
        if configration.showScrollLine {
            lineView.frame = CGRect(x: lineX - configration.lineLeftAndRightAddWidth + configration.lineLeftAndRightMargin, y: lineY - configration.lineBottomMargin, width: lineW + configration.lineLeftAndRightAddWidth*2 - configration.lineLeftAndRightMargin*2, height: lineH)
            lineView.layer.cornerRadius = configration.lineCorner
            scrollView.addSubview(lineView)
        }
        
        setDefaultTheme()
        selectedItem(index: currentIndex, animated: false)
    }
    
    private func setupButton(itemBtn: UIButton, title: String, idx: Int) {
        itemBtn.setTitleColor(configration.normalItemColor, for: .normal)
        itemBtn.titleLabel?.font = configration.itemFont
        itemBtn.setTitle(title, for: .normal)
        itemBtn.tag = idx
        itemBtn.addTarget(self, action: #selector(itemButtonOnClick(button:)), for: .touchUpInside)
        itemBtn.sizeToFit()
        itemsWidthArraM.append(itemBtn.yn_width)
        itemsArrayM.append(itemBtn)
        scrollView.addSubview(itemBtn)
    }
    
    private func setDefaultTheme() {
        let currentBtn = itemsArrayM[currentIndex]
        if configration.itemMaxScale > 1 {
            currentBtn.transform = CGAffineTransform(scaleX: configration.itemMaxScale, y: configration.itemMaxScale)
        }
        currentBtn.isSelected = true
        currentBtn.setTitleColor(configration.selectedItemColor, for: .normal)
        currentBtn.titleLabel?.font = configration.selectedItemFont
        /// 线条
        if configration.showScrollLine {
            lineView.yn_width = (configration.isFixLineWidth ? configration.fixLineWidth:currentBtn.yn_width) + configration.lineLeftAndRightAddWidth*2 - configration.lineLeftAndRightMargin*2
            lineView.yn_x = (currentBtn.yn_x + (currentBtn.yn_width - lineView.yn_width)/2) - configration.lineLeftAndRightAddWidth + configration.lineLeftAndRightMargin
            /// 处理Line宽度等于字体宽度
            if !configration.scrollMenu &&
                !configration.aligmentModeCenter &&
                configration.lineWidthEqualFontWidth {
                if (configration.isFixLineWidth){
                    lineView.yn_x = currentBtn.yn_x + (currentBtn.yn_width - configration.fixLineWidth)/2 - configration.lineLeftAndRightAddWidth - configration.lineLeftAndRightAddWidth
                    lineView.yn_width = configration.fixLineWidth + configration.lineLeftAndRightAddWidth*2
                }else{
                    lineView.yn_x = currentBtn.yn_x + (currentBtn.yn_width - (itemsWidthArraM[currentBtn.tag]))/2 - configration.lineLeftAndRightAddWidth - configration.lineLeftAndRightAddWidth
                    lineView.yn_width = itemsWidthArraM[currentBtn.tag] + configration.lineLeftAndRightAddWidth*2
                }
                
            }
        }
        
        /// 遮盖
        if configration.showConver {
            converView.yn_x = currentBtn.yn_x - kYNPageScrollMenuViewConverMarginX
            converView.yn_width = currentBtn.yn_width + kYNPageScrollMenuViewConverMarginW
            /// 处理conver宽度等于字体宽度
            if (!configration.scrollMenu &&
                !configration.aligmentModeCenter &&
                configration.lineWidthEqualFontWidth) {
                converView.yn_x = currentBtn.yn_x + (currentBtn.yn_width - itemsWidthArraM[currentBtn.tag])/2 - kYNPageScrollMenuViewConverMarginX
                converView.yn_width = itemsWidthArraM[currentBtn.tag] + kYNPageScrollMenuViewConverMarginW
            }
        }
        lastIndex = currentIndex
    }
    
    private func adjustItem(animated: Bool) {
        let lastBtn = itemsArrayM[lastIndex]
        let currentBtn = itemsArrayM[currentIndex]
        
        UIView.animate(withDuration: animated ? 0.3 : 0) { [weak self] in
            guard let `self` = self else { return }
            /// 缩放
            if (self.configration.itemMaxScale > 1) {
                lastBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
                currentBtn.transform = CGAffineTransform(scaleX: self.configration.itemMaxScale, y: self.configration.itemMaxScale)
            }
            /// 颜色
            for (idx, btn) in self.itemsArrayM.enumerated() {
                btn.isSelected = false
                btn.setTitleColor(self.configration.normalItemColor, for: .normal)
                btn.titleLabel?.font = self.configration.itemFont
                if idx == self.itemsArrayM.count - 1 {
                    currentBtn.isSelected = true
                    currentBtn.setTitleColor(self.configration.selectedItemColor, for: .normal)
                    currentBtn.titleLabel?.font = self.configration.selectedItemFont
                }
            }
            /// 线条
            if self.configration.showScrollLine {
                self.lineView.yn_width = (self.configration.isFixLineWidth ? self.configration.fixLineWidth : currentBtn.yn_width) + self.configration.lineLeftAndRightAddWidth * 2 - self.configration.lineLeftAndRightMargin * 2
                self.lineView.yn_x = (currentBtn.yn_x + (currentBtn.yn_width - self.lineView.yn_width) / 2) - self.configration.lineLeftAndRightAddWidth + self.configration.lineLeftAndRightMargin
                
                if (!self.configration.scrollMenu &&
                    !self.configration.aligmentModeCenter &&
                    self.configration.lineWidthEqualFontWidth) {//处理Line宽度等于字体宽度
                    if (self.configration.isFixLineWidth){
                        self.lineView.yn_x = currentBtn.yn_x + (currentBtn.yn_width - self.configration.fixLineWidth) / 2 - self.configration.lineLeftAndRightAddWidth
                        self.lineView.yn_width = self.configration.fixLineWidth + self.configration.lineLeftAndRightAddWidth * 2
                    }else{
                        self.lineView.yn_x = currentBtn.yn_x + (currentBtn.yn_width - self.itemsWidthArraM[currentBtn.tag]) / 2 - self.configration.lineLeftAndRightAddWidth
                        self.lineView.yn_width = self.itemsWidthArraM[currentBtn.tag] + self.configration.lineLeftAndRightAddWidth * 2
                    }
                }
            }
            
            /// 遮盖
            if self.configration.showConver {
                self.converView.yn_x = currentBtn.yn_x - kYNPageScrollMenuViewConverMarginX
                self.converView.yn_width = currentBtn.yn_width + kYNPageScrollMenuViewConverMarginW
                /// 处理conver宽度等于字体宽度
                if !self.configration.scrollMenu &&
                    !self.configration.aligmentModeCenter &&
                    self.configration.lineWidthEqualFontWidth {
                    self.converView.yn_x = currentBtn.yn_x + (currentBtn.yn_width - self.itemsWidthArraM[currentBtn.tag]) / 2  - kYNPageScrollMenuViewConverMarginX
                    self.converView.yn_width = self.itemsWidthArraM[currentBtn.tag] + kYNPageScrollMenuViewConverMarginW
                }
            }
            self.lastIndex = self.currentIndex
            
        } completion: { finish in
            self.adjustItemPosition(index: self.currentIndex)
        }
        
    }
    
}


// MARK: Public Method
extension YNPageScrollMenuView {
    
    // 选中下标
    public func selectedItem(index: Int, animated: Bool) {
        currentIndex = index
        adjustItem(animated: animated)
    }
    
    // 调整Item
    public func adjustItemWithAnimated(animated: Bool) {
        if lastIndex == currentIndex { return }
        adjustItem(animated: animated)
    }
    
    // 根据标题修下标修改标题
    public func updateTitle(title: String, index: Int) {
        if index < 0 || index > title.count - 1 { return }
        if title.count == 0 { return }
        reloadView()
    }
    
    // 根据标题数组刷新标题
    public func updateTitles(titles: [String]) {
        if titles.count != titles.count { return }
        reloadView()
    }
    
    // 刷新视图
    public func reloadView() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        itemsArrayM.removeAll()
        itemsArrayM.removeAll()
        setupSubviews()
    }
    
    // 根据下标调整Item位置
    public func adjustItemPosition(index: Int) {
        if scrollView.contentSize.width != (scrollView.yn_width + 20) {
            let btn = itemsArrayM[index]
            var offSex: CGFloat = btn.center.x - scrollView.yn_width * 0.5
            offSex = offSex > 0 ? offSex : 0
            var maxOffSetX: CGFloat = scrollView.contentSize.width - scrollView.yn_width
            maxOffSetX = maxOffSetX > 0 ? maxOffSetX : 0
            offSex = offSex > maxOffSetX ? maxOffSetX : offSex
            scrollView.setContentOffset(CGPoint(x: offSex, y: 0), animated: true)
        }
    }
    
    // 根据上个下标和当前点击的下标调整进度
    public func adjustItemWithProgress(progress: CGFloat, lastIndex: Int, currentIndex: Int) {
        self.lastIndex = lastIndex
        self.currentIndex = currentIndex
        guard lastIndex != currentIndex else { return }
        let lastButton = itemsArrayM[self.lastIndex]
        let currentButton = itemsArrayM[self.currentIndex]
        
        ///缩放系数
        if configration.itemMaxScale > 1 {
            let scaleB: CGFloat = configration.itemMaxScale - configration.deltaScale * progress
            let scaleS: CGFloat = 1 + configration.deltaScale * progress
            lastButton.transform = CGAffineTransform(scaleX: scaleB, y: scaleB)
            currentButton.transform = CGAffineTransform(scaleX: scaleS, y: scaleS)
        }
        
        if configration.showGradientColor {
            /// 颜色渐变
            configration.setRGB(progress: progress)
            let norColor = UIColor(red: configration.deltaNorR, green: configration.deltaNorG, blue: configration.deltaNorB, alpha: 1)
            let selColor = UIColor(red: configration.deltaSelR, green: configration.deltaSelG, blue: configration.deltaSelB, alpha: 1)
            lastButton.setTitleColor(norColor, for: .normal)
            currentButton.setTitleColor(selColor, for: .normal)
        }else {
            if progress > 0.5 {
                lastButton.isSelected = false
                currentButton.isSelected = true
                lastButton.setTitleColor(configration.normalItemColor, for: .normal)
                currentButton.setTitleColor(configration.selectedItemColor, for: .normal)
                currentButton.titleLabel?.font = configration.selectedItemFont
            }else if progress < 0.5 && progress > 0 {
                lastButton.isSelected = true
                lastButton.setTitleColor(configration.selectedItemColor, for: .normal)
                lastButton.titleLabel?.font = configration.selectedItemFont
                currentButton.isSelected = false
                currentButton.setTitleColor(configration.normalItemColor, for: .normal)
                currentButton.titleLabel?.font = configration.itemFont
            }
        }
        
        if progress > 0.5 {
            lastButton.titleLabel?.font = configration.itemFont
            currentButton.titleLabel?.font = configration.selectedItemFont
        } else if progress < 0.5 && progress > 0 {
            lastButton.titleLabel?.font = configration.selectedItemFont
            currentButton.titleLabel?.font = configration.itemFont
        }
        
        var xD: CGFloat = 0
        var wD: CGFloat = 0
        if !configration.scrollMenu &&
            !configration.aligmentModeCenter &&
            configration.lineWidthEqualFontWidth {
            if configration.isFixLineWidth {
                xD = currentButton.yn_width - configration.fixLineWidth/2 + currentButton.yn_x - (lastButton.yn_width - configration.fixLineWidth)/2 + lastButton.yn_x
            }else {
                xD = (currentButton.titleLabel?.yn_x ?? 0) + currentButton.yn_x - ((lastButton.titleLabel?.yn_x ?? 0) + lastButton.yn_x)
                wD = (currentButton.titleLabel?.yn_width ?? 0) - (lastButton.titleLabel?.yn_width ?? 0)
            }
        } else {
            if configration.isFixLineWidth {
                xD = (currentButton.yn_x + (currentButton.yn_width - configration.fixLineWidth)/2) - (lastButton.yn_x + (lastButton.yn_width - configration.fixLineWidth)/2)
            }else {
                xD = currentButton.yn_x - lastButton.yn_x
                wD = currentButton.yn_width - lastButton.yn_width
            }
        }
        
        /// 线条
        if configration.showScrollLine {
            if !configration.scrollMenu &&
                !configration.aligmentModeCenter &&
                configration.lineWidthEqualFontWidth { /// 处理Line宽度等于字体宽度
                if configration.isFixLineWidth {
                    lineView.yn_x = lastButton.yn_x + (lastButton.yn_width - configration.fixLineWidth)/2 - configration.lineLeftAndRightAddWidth + (xD * progress)
                    lineView.yn_width = configration.fixLineWidth + configration.lineLeftAndRightAddWidth*2 + (wD * progress)
                }else {
                    lineView.yn_x = lastButton.yn_x + (lastButton.yn_width - itemsWidthArraM[lastButton.tag])/2 - configration.lineLeftAndRightAddWidth + (xD * progress)
                    lineView.yn_width = itemsWidthArraM[lastButton.tag] + configration.lineLeftAndRightAddWidth*2 + (wD * progress)
                }
            } else {
                if configration.isFixLineWidth {
                    lineView.yn_x = (lastButton.yn_x + (lastButton.yn_width - configration.fixLineWidth)/2) + (xD * progress) - configration.lineLeftAndRightAddWidth + configration.lineLeftAndRightMargin;
                    lineView.yn_width = configration.fixLineWidth + (wD * progress) + configration.lineLeftAndRightAddWidth*2 - configration.lineLeftAndRightMargin*2
                }else {
                    lineView.yn_x = lastButton.yn_x + (xD * progress) - configration.lineLeftAndRightAddWidth + configration.lineLeftAndRightMargin
                    lineView.yn_width = lastButton.yn_width + (wD * progress) + configration.lineLeftAndRightAddWidth*2 - configration.lineLeftAndRightMargin*2
                }
            }
        }
        
        /// 遮盖
        if configration.showConver {
            converView.yn_x = lastButton.yn_x + (xD * progress) - kYNPageScrollMenuViewConverMarginX
            converView.yn_width = lastButton.yn_width + (xD * progress) + kYNPageScrollMenuViewConverMarginW
            if !configration.scrollMenu &&
                !configration.aligmentModeCenter &&
                configration.lineWidthEqualFontWidth { /// 处理cover宽度等于字体宽度
                converView.yn_x = lastButton.yn_x + (lastButton.yn_width - itemsWidthArraM[lastButton.tag]) / 2 -  kYNPageScrollMenuViewConverMarginX + (xD * progress)
                converView.yn_width = itemsWidthArraM[lastButton.tag] + kYNPageScrollMenuViewConverMarginW + (xD * progress)
            }
        }
    }
}


extension YNPageScrollMenuView {
    
    @objc func itemButtonOnClick(button: UIButton) {
        currentIndex = button.tag
        adjustItemWithAnimated(animated: true)
        delegate?.pagescrollMenuViewItemOnClick?(button: button, index: lastIndex)
    }
    
    @objc func addButtonAction(button: UIButton) {
        delegate?.pagescrollMenuViewAddButtonAction?(button: button)
    }
    
}
