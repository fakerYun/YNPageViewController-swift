//
//  YNPageViewController.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

let kDEFAULT_INSET_BOTTOM = 400.0
public class YNPageViewController: UIViewController {
    
    // MARK: Public property
    /// 配置信息
    public var config: YNPageConfigration = YNPageConfigration()
    /// 控制器数组
    public var controllersM: [UIViewController] = []
    /// 标题数组 默认 缓存 key 为 title 可通过数据源代理 进行替换
    public var titlesM: [String] = []
    /// 菜单栏
    public var scrollMenuView: YNPageScrollMenuView?
    /// 头部headerView
    public var headerView: UIView? {
        didSet {
            guard let headerView = headerView else { return }
            headerView.yn_height = ceil(headerView.yn_height)
        }
    }
    /// 代理
    public weak var delegate: YNPageViewControllerDelegate?
    /// 数据源
    public weak var dataSource: YNPageViewControllerDataSource?
    /// 当前页面index
    public var pageIndex: Int = 0
    /// 头部伸缩背景View
    public var scaleBackgroundView: UIView?
    /// 背景ScrollView
    public private(set) var bgScrollView = YNPageScrollView()
    
    // MARK: private property
    /// 页面ScrollView
    private lazy var pageScrollView: YNPageScrollView = {
        let scrollView = YNPageScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = self.config.pageScrollEnabled
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.backgroundColor = .white
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    /// HeaderView的背景View
    private var headerBgView: YNPageHeaderScrollView?
    /// 展示控制器的字典
    private var displayDictM: [String: UIViewController] = [:]
    /// 原始InsetBottom
    private var originInsetBottomDictM: [String: Any] = [:]
    /// 字典控制器的缓存
    private var cacheDictM: [String: UIViewController] = [:]
    /// 字典ScrollView的缓存
    private var scrollViewCacheDictionryM: [String: UIScrollView] = [:]
    /// 当前显示的页面
    private var currentScrollView: UIScrollView? {
        get {
            return self.getScrollView(index: pageIndex)
        }
    }
    /// 当前控制器
    private var currentViewController: UIViewController?
    /// 上次偏移的位置
    private var lastPositionX: CGFloat = 0
    /// TableView距离顶部的偏移量
    private var insetTop: CGFloat = 0
    /// 判断headerView是否在列表内
    private var headerViewInTableView: Bool = false
    /// 菜单栏的初始OriginY
    private var scrollMenuViewOriginY: CGFloat = 0
    /// headerView的原始高度 用来处理头部伸缩效果
    private var headerViewOriginHeight: CGFloat = 0
    /// 是否是悬浮状态
    private var supendStatus: Bool = false
    /// 记录bgScrollView Y 偏移量
    private var beginBgScrollOffsetY: CGFloat = 0
    /// 记录currentScrollView Y 偏移量
    private var beginCurrentScrollOffsetY: CGFloat = 0
    /// 记录上一次横向滑动位置
    private var startOffsetX: CGFloat = 0.0
    
    deinit {
//        print("-----：\(String(describing: type(of: self))) --deinit")
    }
    
    public convenience init(controllers: [UIViewController], titles: [String], config: YNPageConfigration) {
        self.init()
        UIScrollView.initializeMethod()
        self.controllersM = controllers
        self.titlesM = titles
        self.config = config
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        initData()
        setupSubViews()
        setSelectedPageIndex(index: pageIndex)
    }
    
    private func initData() {
        checkParams()
        
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .white
        self.automaticallyAdjustsScrollViewInsets = false
        headerViewInTableView = true
    }
    
    private func setupSubViews() {
        setupHeaderBgView()
        setupPageScrollMenuView()
        setupPageScrollView()
    }
    
    private func setupHeaderBgView() {
        guard isSuspensionBottomStyle || isSuspensionTopStyle || isSuspensionTopPauseStyle else { return }
        
        guard let headerView = self.headerView else {
#if DEBUG
            assert(false, "Please set headerView !")
#endif
            return
        }
        headerBgView = YNPageHeaderScrollView(frame: headerView.bounds)
        guard let headerBgView = self.headerBgView else { return }
        headerBgView.contentSize = CGSize(width: kYNPAGE_SCREEN_WIDTH * 2, height: headerView.yn_height)
        headerBgView.addSubview(headerView)
        self.headerViewOriginHeight = headerBgView.yn_height
        headerBgView.isScrollEnabled = !config.headerViewCouldScrollPage
        
        if let scaleBackgroundView = self.scaleBackgroundView, config.headerViewCouldScale {
            headerView.insertSubview(scaleBackgroundView, at: 0)
            scaleBackgroundView.isUserInteractionEnabled = false
        }
        
        config.tempTopHeight = headerBgView.yn_height + config.menuHeight
        insetTop = headerBgView.yn_height + config.menuHeight
        scrollMenuViewOriginY = headerView.yn_height
        if isSuspensionTopPauseStyle {
            insetTop = headerBgView.yn_height - config.suspenOffsetY
            
            bgScrollView.showsVerticalScrollIndicator = false
            bgScrollView.showsHorizontalScrollIndicator = false
            bgScrollView.delegate = self
            bgScrollView.backgroundColor = .white
            if #available(iOS 11.0, *) {
                bgScrollView.contentInsetAdjustmentBehavior = .never
            }
            bgScrollView.addSubview(headerBgView)
        }
    }
    
    private func setupPageScrollMenuView() {
        scrollMenuView = YNPageScrollMenuView(frame: CGRect(x: 0, y: 0, width: config.menuWidth, height: config.menuHeight),
                                              titles: titlesM,
                                              configration: config,
                                              delegate: self,
                                              currentIndex: pageIndex)
        switch config.pageStyle {
        case .Top, .SuspensionTop, .SuspensionCenter:
            view.addSubview(scrollMenuView!)
        case .Navigation:
            /// 在添加到父视图的时候再设置
            break
        case .SuspensionTopPause:
            bgScrollView.addSubview(scrollMenuView!)
        }
        
    }
    
    private func setupPageScrollView() {
        
        let navHeight: CGFloat = config.showNavigation ? kYNPAGE_NAVHEIGHT : 0
        let tabHeight: CGFloat = config.showTabbar ? kYNPAGE_TABBARHEIGHT : 0
        let cutOutHeight: CGFloat = config.cutOutHeight > 0 ? self.config.cutOutHeight : 0
        let contentHeight: CGFloat = kYNPAGE_SCREEN_HEIGHT - navHeight - tabHeight - cutOutHeight
        
        if isSuspensionTopPauseStyle {
            bgScrollView.frame = CGRect(x: 0, y: 0, width: kYNPAGE_SCREEN_WIDTH, height: contentHeight)
            bgScrollView.contentSize = CGSize(width: kYNPAGE_SCREEN_WIDTH, height: contentHeight + (headerBgView?.yn_height ?? 0) - config.suspenOffsetY)
            scrollMenuView?.yn_y = self.headerBgView?.yn_bottom ?? 0
            pageScrollView.frame = CGRect(x: 0, y: scrollMenuView?.yn_bottom ?? 0, width: kYNPAGE_SCREEN_WIDTH, height: contentHeight - config.menuHeight - config.suspenOffsetY)
            pageScrollView.contentSize = CGSize(width: kYNPAGE_SCREEN_WIDTH * CGFloat(controllersM.count), height: pageScrollView.yn_height)
            config.contentHeight = pageScrollView.yn_height
            bgScrollView.addSubview(pageScrollView)
            if kLESS_THAN_iOS11 {
                view.addSubview(UIView())
            }
            view.addSubview(bgScrollView)
        }else {
            pageScrollView.frame = CGRect(x: 0, y: isTopStyle ? config.menuHeight : 0, width: kYNPAGE_SCREEN_WIDTH, height: isTopStyle ? contentHeight - config.menuHeight : contentHeight)
            pageScrollView.contentSize = CGSize(width: kYNPAGE_SCREEN_WIDTH * CGFloat(controllersM.count), height: contentHeight - (isTopStyle ? config.menuHeight : 0))
            config.contentHeight = pageScrollView.yn_height - config.menuHeight
            if kLESS_THAN_iOS11 {
                view.addSubview(UIView())
            }
            view.addSubview(pageScrollView)
        }
    }
    
    /// 初始化子控制器
    private func initViewControllerWithIndex(index: Int) {
        currentViewController = controllersM[index]
        pageIndex = index
        let title = getPageTitle(index: index)
        let key = getKeyString(title: title)
        if displayDictM[key] == nil {
            if let cacheVC = cacheDictM[key] {
                addViewControllerToParent(viewController: cacheVC, index: index)
            }else {
                addViewControllerToParent(viewController: controllersM[index], index: index)
            }
        }
    }

}

extension YNPageViewController {
    
    /// 将headerView 从 view 上 放置 tableview 上
    private func replaceHeaderViewFromView() {
        if isSuspensionBottomStyle || isSuspensionTopStyle {
            if !headerViewInTableView {
 
                if let headerBgView = self.headerBgView, let scrollMenuView = self.scrollMenuView {
                    let headerViewY: CGFloat = headerBgView.superview?.convert(headerBgView.frame, to: currentScrollView).origin.y ?? 0
                    let scrollMenuViewY: CGFloat = scrollMenuView.superview?.convert(scrollMenuView.frame, to: currentScrollView).origin.y ?? 0
                    headerBgView.removeFromSuperview()
                    scrollMenuView.removeFromSuperview()
                    
                    headerBgView.yn_y = headerViewY
                    scrollMenuView.yn_y = scrollMenuViewY
                    
                    currentScrollView?.addSubview(headerBgView)
                    currentScrollView?.addSubview(scrollMenuView)
                    
                    headerViewInTableView = true
                }
            }
        }
    }
    
    /// 将headerView 从 tableview 上 放置 view 上
    private func replaceHeaderViewFromTableView() {
        if isSuspensionBottomStyle || isSuspensionTopStyle {
            if headerViewInTableView {
                if let headerBgView = self.headerBgView, let scrollMenuView = self.scrollMenuView {
                    let headerViewY: CGFloat = headerBgView.superview?.convert(headerBgView.frame, to: pageScrollView).origin.y ?? 0
                    let scrollMenuViewY: CGFloat = scrollMenuView.superview?.convert(scrollMenuView.frame, to: pageScrollView).origin.y ?? 0
                    
                    headerBgView.removeFromSuperview()
                    scrollMenuView.removeFromSuperview()
                    
                    headerBgView.yn_y = headerViewY
                    scrollMenuView.yn_y = scrollMenuViewY
                    
                    view.insertSubview(headerBgView, aboveSubview: pageScrollView)
                    view.insertSubview(scrollMenuView, aboveSubview: headerBgView)
                    
                    headerViewInTableView = false
                }
            }
        }
    }
    
    private func yn_pageScrollViewBeginDragginScrollView(scrollView: UIScrollView?) {
        guard let scrollView = scrollView else { return }
        beginBgScrollOffsetY = bgScrollView.contentOffset.y
        beginCurrentScrollOffsetY = scrollView.contentOffset.y
    }
    
    private func yn_pageScrollViewDidScrollView(scrollView: UIScrollView?) {
        guard let scrollView = scrollView else { return }
        if isSuspensionBottomStyle || isSuspensionTopStyle {
            if !headerViewInTableView { return }
            if scrollView != currentScrollView { return }
            let title = getPageTitle(index: pageIndex)
            let key = getKeyString(title: title)
            let originInsetBottom: CGFloat = originInsetBottomDictM[key] as? CGFloat ?? 0
            if (scrollView.contentInset.bottom - originInsetBottom) > kDEFAULT_INSET_BOTTOM {
                scrollView.contentInset = UIEdgeInsets(top: scrollView.contentInset.top, left: 0, bottom: originInsetBottom, right: 0)
            }
            let offsetY = scrollView.contentOffset.y
            /// 悬浮临界点
            if let scrollMenuView = self.scrollMenuView, let headerBgView = self.headerBgView {
                if offsetY > -scrollMenuView.yn_height - config.suspenOffsetY {
                    headerBgView.yn_y = -headerBgView.yn_height + offsetY + config.suspenOffsetY
                    scrollMenuView.yn_y = offsetY + config.suspenOffsetY
                    self.supendStatus = true
                } else {
                    /// headerView往下拉置顶
                    if offsetY >= -insetTop {
                        headerBgView.yn_y = -insetTop
                    } else {
                        if isSuspensionBottomStyle {
                            headerBgView.yn_y = offsetY
                        }
                    }
                    scrollMenuView.yn_y = headerBgView.yn_bottom
                    supendStatus = false
                }
            }
            
            adjustSectionHeader(scrollview: scrollView)
            invokeDelegateForScroll(offsetY: offsetY)
            headerScaleWithOffsetY(offsetY: offsetY)
        }else if isSuspensionTopPauseStyle {
            calcuSuspendTopPauseWithCurrentScrollView(scrollView: scrollView)
        }else {
            invokeDelegateForScroll(offsetY: scrollView.contentOffset.y)
        }
 
    }
    
    private func adjustSectionHeader(scrollview: UIScrollView) {
        if scrollview.subviews.last != scrollMenuView {
            if let scrollMenuView = self.scrollMenuView, let headerBgView = self.headerBgView {
                scrollview.bringSubviewToFront(headerBgView)
                scrollview.bringSubviewToFront(scrollMenuView)
            }
        }
    }
    
    
    /// 最终效果 current 拖到指定时 bg 才能下拉 ， bg 悬浮时 current 才能上拉
    /// - Parameter scrollView: 计算悬浮顶部偏移量 - BgScrollView
    private func calcuSuspendTopPauseWithBgScrollView(scrollView: UIScrollView) {
        guard isSuspensionTopPauseStyle && scrollView == bgScrollView else { return }
        let bg_OffsetY = scrollView.contentOffset.y
        let cu_OffsetY = self.currentScrollView?.contentOffset.y ?? 0
        /// 求出拖拽方向
        let dragBottom = beginBgScrollOffsetY - bg_OffsetY > 0 ? true : false
        /// cu 大于 0 时
        if dragBottom && cu_OffsetY > 0 {
            /// 设置原来的 出生偏移量
            scrollView.yn_setContentOffsetY(offsetY: beginBgScrollOffsetY)
            /// 设置实时滚动的 cu 偏移量
            beginCurrentScrollOffsetY = cu_OffsetY
        }
        /// 初始 begin 时超过了 实时 设置
        else if beginBgScrollOffsetY == insetTop && beginCurrentScrollOffsetY != 0 {
            scrollView.yn_setContentOffsetY(offsetY: beginBgScrollOffsetY)
            beginCurrentScrollOffsetY = cu_OffsetY
        }
        /// 设置边界
        else if bg_OffsetY >= insetTop {
            scrollView.yn_setContentOffsetY(offsetY: insetTop)
            beginCurrentScrollOffsetY = cu_OffsetY
        }
        /// 设置边界
        else if bg_OffsetY <= 0 && cu_OffsetY > 0 {
            scrollView.yn_setContentOffsetY(offsetY: 0)
        }
    }
    
    /// 计算悬浮顶部偏移量
    /// - Parameter scrollView: CurrentScrollView
    private func calcuSuspendTopPauseWithCurrentScrollView(scrollView: UIScrollView) {
        guard isSuspensionTopPauseStyle && scrollView.isDragging else { return }
        let bg_OffsetY = bgScrollView.contentOffset.y
        let cu_offsetY = scrollView.contentOffset.y
        /// 求出拖拽方向
        let dragBottom = beginCurrentScrollOffsetY - cu_offsetY < 0 ? true : false
        /// cu 是大于 0 的 且 bg 要小于 _insetTop
        if dragBottom && cu_offsetY > 0 && bg_OffsetY < insetTop {
            /// 设置之前的拖动位置
            scrollView.yn_setContentOffsetY(offsetY: beginCurrentScrollOffsetY)
            /// 修改 bg 原先偏移量
            beginBgScrollOffsetY = bg_OffsetY
        }
        /// cu 拖到 小于 0 就设成0
        else if cu_offsetY < 0 {
            scrollView.yn_setContentOffsetY(offsetY: 0)
        }
        /// bg 超过了 insetTop 就设置初始化为 _insetTop
        else if bg_OffsetY >= insetTop {
            beginBgScrollOffsetY = insetTop
        }
    }
    
}

extension YNPageViewController {
    
    private func checkParams() {
#if DEBUG
        assert(controllersM.count > 0, "ViewControllers`count is 0 or nil")
        assert(titlesM.count > 0, "TitleArray`count is 0 or nil")
        assert(controllersM.count == titlesM.count, "ViewControllers`count is not equal titleArray!")
#endif
        if !respondsToCustomCachekey() {
            var isHasNotEqualTitle: Bool = true
            for i in 0..<titlesM.count {
                for j in i+1..<titlesM.count {
                    if i != j && titlesM[i] == titlesM[j] {
                        isHasNotEqualTitle = false
                        break
                    }
                }
            }
#if DEBUG
            assert(isHasNotEqualTitle, "TitleArray Not allow equal title.");
#endif
        }
    }
    
    private func respondsToCustomCachekey() -> Bool {
        if (dataSource != nil) && ((dataSource?.responds(to: #selector(dataSource?.pageViewController(pageViewController:customCacheKeyForIndex:)))) != nil) {
            return true
        }
        return false
    }
}

// MARK: Private Method
extension YNPageViewController {
    
    /// 移除缓存控制器
    private func removeViewController() {
        let title: String = getPageTitle(index: pageIndex)
        let displayKey: String = getKeyString(title: title)
        for key in displayDictM.keys {
            if key != displayKey {
                removeChildVcFromParent(childVC: displayDictM[key], key: key)
            }
        }
    }
    
    /// 从父类控制器移除控制器
    private func removeChildVcFromParent(childVC: UIViewController?, key: String) {
        guard let childVC = childVC else { return }
        removeViewController(childVC: childVC)
        displayDictM.removeValue(forKey: key)
        if cacheDictM[key] == nil {
            cacheDictM[key] = childVC
        }
    }
    
    /// 子控制器移除自己
    private func removeViewController(childVC: UIViewController?) {
        guard let childVC = childVC else { return }
        childVC.willMove(toParent: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
    }
    
    /// 添加子控制器
    private func addChildViewController(childVC: UIViewController?, parentVC: UIViewController) {
        guard let childVC = childVC else { return }
        parentVC.addChild(childVC)
        parentVC.view.addSubview(childVC.view)
        childVC.didMove(toParent: parentVC)
    }
    
    private func updateViewWithIndex(pageIndex: Int) {
        pageScrollView.contentSize = CGSize(width: kYNPAGE_SCREEN_WIDTH * CGFloat(controllersM.count), height: pageScrollView.yn_height)
        let vc = controllersM[pageIndex]
        vc.view.yn_x = kYNPAGE_SCREEN_WIDTH * CGFloat(pageIndex)
        scrollMenuView?.reloadView()
        scrollMenuView?.selectedItem(index: pageIndex, animated: false)
        
        let frame: CGRect = CGRect(x: pageScrollView.yn_width * CGFloat(pageIndex), y: 0, width: pageScrollView.yn_width, height: pageScrollView.yn_height)
        pageScrollView.scrollRectToVisible(frame, animated: false)
        scrollViewDidEndDecelerating(pageScrollView)
        self.pageIndex = pageIndex
    }
    
    /// 添加到父类控制器中
    private func addViewControllerToParent(viewController: UIViewController, index: Int) {
        self.addChild(viewController)
        viewController.view.frame = CGRect(x: kYNPAGE_SCREEN_WIDTH * CGFloat(index), y: 0, width: pageScrollView.yn_width, height: pageScrollView.yn_height)
        pageScrollView.addSubview(viewController.view)
        let title = getPageTitle(index: index)
        let key = getKeyString(title: title)
        displayDictM[key] = viewController

        guard let scrollView = currentScrollView else { return }
        if let dataSoure = self.dataSource {
            if dataSoure.responds(to: #selector(dataSoure.pageViewController(pageViewController:heightForScrollViewAtIndex:))) {
                let scrollViewHeight = dataSoure.pageViewController?(pageViewController: self, heightForScrollViewAtIndex: index)
                scrollView.frame = CGRect(x: 0, y: 0, width: viewController.view.yn_width, height: scrollViewHeight ?? 0)
            }else {
                scrollView.frame = viewController.view.bounds
            }
        }
        viewController.didMove(toParent: self)
        if isSuspensionBottomStyle || isSuspensionTopStyle {
            if cacheDictM[key] == nil {
                let bottom = scrollView.contentInset.bottom > 2 * kDEFAULT_INSET_BOTTOM ? 0 : scrollView.contentInset.bottom
                originInsetBottomDictM[key] = bottom
                
                /// 设置TableView内容偏移
                scrollView.contentInset = UIEdgeInsets(top: insetTop, left: 0, bottom: scrollView.contentInset.bottom + 3 * kDEFAULT_INSET_BOTTOM, right: 0)
            }
            
            if isSuspensionBottomStyle {
                scrollView.scrollIndicatorInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
            }
            
            if cacheDictM.count == 0 {
                /// 初次添加headerView、scrollMenuView
                if let scrollMenuView = self.scrollMenuView {
                    if let headerBgView = self.headerBgView {
                        headerBgView.yn_y = -insetTop
                        scrollMenuView.yn_y = headerBgView.yn_bottom
                        scrollView.addSubview(headerBgView)
                    }
                    scrollView.addSubview(scrollMenuView)
                    /// 设置首次偏移量置顶
                    scrollView.setContentOffset(CGPoint(x: 0, y: -insetTop), animated: false)
                }
            }else {
                let scrollMenuViewY = scrollMenuView?.superview?.convert(scrollMenuView?.frame ?? .zero, to: self.view).origin.y ?? 0
                if supendStatus {
                    /// 首次已经悬浮 设置初始化 偏移量
                    if cacheDictM[key] == nil {
                        scrollView.setContentOffset(CGPoint(x: 0, y: -config.menuHeight - config.suspenOffsetY), animated: false)
                    }else {
                        /// 再次悬浮 已经加载过 设置偏移量
                        if scrollView.contentOffset.y < -config.menuHeight - config.suspenOffsetY {
                            scrollView.setContentOffset(CGPoint(x: 0, y: -config.menuHeight - config.suspenOffsetY), animated: false)
                        }
                    }
                }else {
                    var scrollMenuViewDeltaY = scrollMenuViewOriginY - scrollMenuViewY
                    scrollMenuViewDeltaY = -insetTop + scrollMenuViewDeltaY
                    /// 求出偏移了多少 未悬浮 (多个ScrollView偏移量联动)
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollMenuViewDeltaY)
                }
            }
        }

        /// 缓存控制器
        if cacheDictM[key] == nil {
            cacheDictM[key] = viewController
        }
    }
    
//    private func setHeaderView(headerView: UIView?) {
//        headerView?.yn_height = ceil(headerView?.yn_height ?? 0)
//    }
}

// MARK: UIScrollViewDelegate && YNPageScrollMenuViewDelegate
extension YNPageViewController: UIScrollViewDelegate, YNPageScrollMenuViewDelegate {
    
    /// 开始滚动视图
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isSuspensionTopPauseStyle {
            if scrollView == self.bgScrollView {
                beginBgScrollOffsetY = scrollView.contentOffset.y
                beginCurrentScrollOffsetY = currentScrollView?.contentOffset.y ?? 0
            }else {
                currentScrollView?.isScrollEnabled = false
            }
        }
        
        if scrollView != bgScrollView {
            startOffsetX = scrollView.contentOffset.x
        }
    }
    
    ///  滑动视图，当手指离开屏幕执行该方法
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView != self.bgScrollView else { return }
        if isSuspensionBottomStyle || isSuspensionTopStyle {
            if !decelerate {
                self.scrollViewDidScroll(scrollView)
                self.scrollViewDidEndDecelerating(scrollView)
            }
        }else if isSuspensionTopPauseStyle {
            currentScrollView?.isScrollEnabled = true
        }
    }
    
    /// scrollView滚动结束
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView != self.bgScrollView else { return }
        if isSuspensionTopPauseStyle {
            currentScrollView?.isScrollEnabled = true
        }
        replaceHeaderViewFromView()
        removeViewController()
        scrollMenuView?.adjustItemPosition(index: pageIndex)
        
        delegate?.pageViewController?(pageViewController: self, didEndDecelerating: scrollView)
    }
    
    /// scrollView滚动ing
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView != self.bgScrollView else {
            calcuSuspendTopPauseWithBgScrollView(scrollView: scrollView)
            invokeDelegateForScroll(offsetY: scrollView.contentOffset.y)
            return
        }
        var progress: CGFloat = 0.0
        var fromIndex: Int = 0
        var toIndex: Int = 0

        // 判断是左滑还是右滑
        let currentOffsetX = scrollView.contentOffset.x
        let scrollViewW = scrollView.bounds.size.width
        let percent = currentOffsetX / scrollViewW
        if currentOffsetX > startOffsetX { // 左滑
            progress = percent - floor(percent)
            fromIndex = Int(percent)
            toIndex = fromIndex + 1
            if toIndex >= controllersM.count {
                progress = 1
                toIndex = fromIndex
            }
            // 完全划过去
            if (currentOffsetX - startOffsetX) == scrollViewW {
                progress = 1
                if fromIndex == toIndex {
                    fromIndex -= 1
                }else {
                    fromIndex -= 1
                    toIndex -= 1
                }
            }
        } else if currentOffsetX < startOffsetX { // 右滑
            progress = 1 - (percent - floor(percent))
            toIndex = Int(percent)
            fromIndex = toIndex + 1
            if fromIndex >= controllersM.count {
                fromIndex = controllersM.count - 1
            }
        }
        if fromIndex != toIndex {
            delegate?.pageViewController?(pageViewController: self, scrollView: scrollView, progress: progress, fromIndex: fromIndex, toIndex: toIndex)
        }

        let offX = currentOffsetX > startOffsetX ? CGFloat(ceilf(Float(percent))) : percent
        let floorfX: Int = Int(floorf(Float(percent)))
        let ceilfX: Int = Int(ceilf(Float(percent)))
        replaceHeaderViewFromTableView()
        initViewControllerWithIndex(index: Int(offX))
        scrollMenuView?.adjustItemWithProgress(progress: percent - floor(percent), lastIndex: floorfX, currentIndex: ceilfX)
        if floorfX == ceilfX {
            scrollMenuView?.adjustItemWithAnimated(animated: true)
        }
        
    }
    
    /// YNPageScrollMenuViewDelegate
    public func pagescrollMenuViewItemOnClick(button: UIButton, index: Int) {
        delegate?.pageViewController?(pageViewController: self, itemButton: button, index: index)
        setSelectedPageIndex(index: index)
    }
    
    public func pagescrollMenuViewAddButtonAction(button: UIButton) {
        delegate?.pageViewController?(pageViewController: self, addButton: button)
    }
    
}


// MARK: Public Method
extension YNPageViewController {
    
    
    /// 当前PageScrollViewVC作为子控制器
    /// - Parameter parentVC: 父类控制器
    public func addSelfToParent(parentVC: UIViewController) {
        addChildViewController(childVC: self, parentVC: parentVC)
        if isNavigationStyle {
            var vc: UIViewController?
            if parentVC.isKind(of: UINavigationController.self) {
                vc = self
            }else {
                vc = self.parent
            }
            vc?.navigationItem.titleView = scrollMenuView
        }
    }
    
    ///从父类控制器里面移除自己（PageScrollViewVC）
    public func removeSelf() {
        removeViewController(childVC: self)
    }
    
    /// 选中页码
    /// - Parameter index: 页面下标
    public func setSelectedPageIndex(index: Int) {
        if cacheDictM.count > 0 && index == pageIndex { return }
        if index > controllersM.count - 1 { return }
        let frame = CGRect(x: pageScrollView.yn_width * CGFloat(index), y: 0, width: pageScrollView.yn_width, height: pageScrollView.yn_height)
        if frame.origin.x == pageScrollView.contentOffset.x {
            scrollViewDidScroll(pageScrollView)
        }else {
            pageScrollView.scrollRectToVisible(frame, animated: false)
        }
        scrollViewDidEndDecelerating(pageScrollView)
        startOffsetX = CGFloat(index) * pageScrollView.yn_width
    }
    
    /**
     刷新数据页面、所有View、菜单栏、headerView - 默认移除缓存控制器
     刷新菜单栏配置 标题数组
     
     e.g: vc.config = ...
     vc.titlesM = [self getArrayTitles].mutableCopy;
     
     如果需要重新走控制器的ViewDidLoad方法则需要重新赋值 controllers
     e.g:
     vc.controllersM = [self getArrayVCs].mutableCopy;
     */
    public func reloadData() {
        checkParams()
        pageIndex = (pageIndex < 0 ? 0 : pageIndex)
        pageIndex = (pageIndex >= controllersM.count ? (controllersM.count - 1) : pageIndex)
        for vc in displayDictM.values {
            removeViewController(childVC: vc)
        }
        displayDictM.removeAll()
        originInsetBottomDictM.removeAll()
        cacheDictM.removeAll()
        scrollViewCacheDictionryM.removeAll()
        headerBgView?.removeFromSuperview()
        bgScrollView.removeFromSuperview()
        pageScrollView.removeFromSuperview()
        scrollMenuView?.removeFromSuperview()
        
        setupSubViews()
        setSelectedPageIndex(index: pageIndex)
    }

    /// 更新菜单栏标题
    /// - Parameters:
    ///   - title: 标题
    ///   - index: 页面下标
    public func updateMenuItem(title: String, index: Int) {
        if index < 0 || index > titlesM.count - 1 { return }
        if title.count == 0 { return }
        let oldTitle: String = getPageTitle(index: index)
        let cacheVC = cacheDictM[getKeyString(title: oldTitle)]
        if (cacheVC != nil) {
            let newKey = getKeyString(title: title)
            let oldKey = getKeyString(title: oldTitle)
            cacheDictM[newKey] = cacheVC
            if newKey != oldKey {
                cacheDictM[oldKey] = nil
            }
            titlesM[index] = title
            scrollMenuView?.reloadView()
        }
    }

    /// 批量插入控制器
    /// - Parameters:
    ///   - titles: 标题数组
    ///   - controllers: 控制器数组
    ///   - index: 插入的下标
    public func insertPageChildControllers(titles: [String], controllers: [UIViewController], insertIndex: Int) {
        
        var index = insertIndex < 0 ? 0 : insertIndex
        index = index > controllersM.count ? controllersM.count : index
        var tarIndex: Int = index
        var insertSuccess: Bool = false
        if titles.count == controllers.count && controllers.count > 0 {
            for i in 0..<titles.count {
                let title = titles[i]
                if title.count == 0 || (titlesM.contains(title) && !respondsToCustomCachekey()) {
                    continue
                }
                insertSuccess = true
                titlesM.insert(title, at: tarIndex)
                controllersM.insert(controllers[i], at: tarIndex)
                tarIndex += 1
            }
        }
        if !insertSuccess { return }
        let pageIndex = index > pageIndex ? pageIndex : pageIndex + controllers.count
        updateViewWithIndex(pageIndex: pageIndex)
    }

    /// 根据标题移除控制器
    /// - Parameter title: 标题
    public func removePageControllerWithTitle(title: String) {
        if respondsToCustomCachekey() { return }
        var index: Int = -1
        for i in 0..<titlesM.count {
            if title == titlesM[i] {
                index = i
                break
            }
        }
        if index == -1 { return }
        removePageControllerWithIndex(index: index)
    }
    
    /// 根据下标移除控制器
    /// - Parameter index: 下标
    public func removePageControllerWithIndex(index: Int) {
        if index < 0 || index >= titlesM.count || titlesM.count == 1 { return }
        var pageIndex: Int = 0
        if self.pageIndex >= index {
            pageIndex = self.pageIndex - 1
            pageIndex = pageIndex < 0 ? 0 : pageIndex
        }
        /// 等于 0 先选中 + 1个才能移除
        if pageIndex == 0 {
            setSelectedPageIndex(index: 1)
        }
        
        titlesM.remove(at: index)
        controllersM.remove(at: index)
        
        let title: String = titlesM[index]
        let key: String = getKeyString(title: title)
        originInsetBottomDictM.removeValue(forKey: key)
        scrollViewCacheDictionryM.removeValue(forKey: key)
        cacheDictM.removeValue(forKey: key)
        updateViewWithIndex(pageIndex: pageIndex)
    }
    
    /// 调整标题数组顺序 - 控制器也会跟着调整
    /// - Parameter titleArray: 标题数组 需要与原来的titles数组相同
    public func replaceTitlesArrayForSort(titleArray: [String]) {
        var condition: Bool = true
        for str in titleArray {
            if !titlesM.contains(str) {
                condition = false
                break
            }
        }
        if !condition || titleArray.count != titlesM.count { return }
        
        var resultArrayM: [UIViewController] = []
        let currentPage: Int = pageIndex
        for i in 0..<titleArray.count {
            let title = titleArray[i]
            if let oldIndex = titlesM.firstIndex(of: title) {
                /// 等于上次选择的页面 更换之后的页面
                if currentPage == oldIndex {
                    self.pageIndex = i
                }
                resultArrayM.append(controllersM[oldIndex])
            }
        }
        titlesM.removeAll()
        titlesM.append(contentsOf: titleArray)
        
        controllersM.removeAll()
        controllersM.append(contentsOf: resultArrayM)
        updateViewWithIndex(pageIndex: self.pageIndex)
    }
    
    /// 刷新悬浮视图frame
    public func reloadSuspendHeaderViewFrame() {
        if (headerView != nil) && (isSuspensionTopStyle || isSuspensionBottomStyle) {
            /// 重新初始化headerBgView
            setupHeaderBgView()
            for i in 0..<titlesM.count {
                let title = titlesM[i]
                if cacheDictM[getKeyString(title: title)] != nil {
                    if let scrollView = getScrollView(index: i) {
                        scrollView.contentInset = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
                        if isSuspensionBottomStyle {
                            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
                        }
                    }
                }
            }
            /// 更新布局
            replaceHeaderViewFromTableView()
            replaceHeaderViewFromView()
            yn_pageScrollViewDidScrollView(scrollView: currentScrollView)
            self.scrollViewDidScroll(pageScrollView)
            if !pageScrollView.isDragging {
                self.scrollViewDidEndDecelerating(pageScrollView)
            }
        }else if isSuspensionTopPauseStyle {
            /// 重新初始化headerBgView
            setupHeaderBgView()
            setupPageScrollView()
        }
    }
    
    
    /// 滚动到顶部(置顶)
    /// - Parameter animated: 是否动画
    public func scrollToTop(animated: Bool) {
        if isSuspensionTopStyle || isSuspensionBottomStyle {
            currentScrollView?.setContentOffset(CGPoint(x: 0, y: -config.tempTopHeight), animated: animated)
        }else if isSuspensionTopPauseStyle {
            currentScrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            bgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        }else {
            currentScrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        }
    }
    
    
    /// 滚动到某一位置
    /// - Parameters:
    ///   - point: 点
    ///   - animated: 是否动画
    public func scrollToContentOffset(point: CGPoint, animated: Bool) {
        if isSuspensionTopStyle || isSuspensionBottomStyle {
            currentScrollView?.setContentOffset(point, animated: animated)
        }else if isSuspensionTopPauseStyle {
            currentScrollView?.setContentOffset(point, animated: false)
            bgScrollView.setContentOffset(point, animated: animated)
        }else {
            currentScrollView?.setContentOffset(point, animated: animated)
        }
    }
    
}

// MARK: 样式取值
extension YNPageViewController {
    
    private var isTopStyle: Bool {
        get { return config.pageStyle == .Top ? true : false }
    }
    
    private var isNavigationStyle: Bool {
        get { return config.pageStyle == .Navigation ? true : false }
    }
    
    private var isSuspensionTopStyle: Bool {
        get { return config.pageStyle == .SuspensionTop ? true : false }
    }
    
    private var isSuspensionBottomStyle: Bool {
        get { return config.pageStyle == .SuspensionCenter ? true : false }
    }
    
    private var isSuspensionTopPauseStyle: Bool {
        get { return config.pageStyle == .SuspensionTopPause ? true : false }
    }
    
    private func getPageTitle(index: Int) -> String {
        return titlesM[index]
    }
    
    private func getPageIndex(title: String) -> Int {
        guard let index = self.titlesM.firstIndex(where: {$0 == title}) else { return -1 }
        return index
    }
    
    private func getKeyString(title: String) -> String {
        if respondsToCustomCachekey() {
            if let ID = dataSource?.pageViewController?(pageViewController: self, customCacheKeyForIndex: pageIndex) {
                return ID
            }
        }
        return title
    }
}




extension YNPageViewController {
    
    /// 回调监听列表滚动代理
    private func invokeDelegateForScroll(offsetY: CGFloat) {
        guard let delegate = self.delegate else { return }
        guard delegate.responds(to: #selector(delegate.pageViewController(pageViewController:contentOffsetY:progress:))) else {
            return
        }
        switch config.pageStyle {
//        case .Top: break
        case .SuspensionTop, .SuspensionCenter:
            var progress: CGFloat = (offsetY + (scrollMenuView?.yn_height ?? 0) + config.suspenOffsetY) / ((headerBgView?.yn_height ?? 0) + config.suspenOffsetY) + 1.0
            progress = progress > 1 ? 1 : progress
            progress = progress < 0 ? 0 : progress
            delegate.pageViewController?(pageViewController: self, contentOffsetY: offsetY, progress: progress)
        case .SuspensionTopPause:
            var progress: CGFloat = offsetY / ((headerBgView?.yn_height ?? 0) - config.suspenOffsetY)
            progress = progress > 1 ? 1 : progress
            progress = progress < 0 ? 0 : progress
            delegate.pageViewController?(pageViewController: self, contentOffsetY: offsetY, progress: progress)
        default:
            delegate.pageViewController?(pageViewController: self, contentOffsetY: offsetY, progress: 1)
        }
    }
    
    private func getScrollView(index: Int) -> UIScrollView? {
        
        let title: String = getPageTitle(index: pageIndex)
        let key: String = getKeyString(title: title)
        var scrollView: UIScrollView?
        if (scrollViewCacheDictionryM[key] == nil) {
            if let dataSource = self.dataSource, dataSource.responds(to: #selector(dataSource.pageViewController(pageViewController:pageForIndex:))) {
                scrollView = dataSource.pageViewController(pageViewController: self, pageForIndex: index)
                scrollView?.yn_observerDidScrollView = true
                weak var weakSelf = self
                scrollView?.yn_pageScrollViewDidScrollBlock = { scrollV in
                    weakSelf?.yn_pageScrollViewDidScrollView(scrollView: scrollV)
                }
                if config.pageStyle == .SuspensionTopPause {
                    scrollView?.yn_pageScrollViewBeginDragginScrollBlock = { scrollV in
                        weakSelf?.yn_pageScrollViewBeginDragginScrollView(scrollView: scrollV)
                    }
                }
                
                if #available(iOS 11.0, *) {
                    scrollView?.contentInsetAdjustmentBehavior = .never
                }
            }
        }else {
            return scrollViewCacheDictionryM[key]
        }
#if DEBUG
    assert(scrollView != nil, "请设置pageViewController 的数据源！");
#endif
        scrollViewCacheDictionryM[key] = scrollView
        return scrollView
    }
    
    /// 处理头部伸缩
    private func headerScaleWithOffsetY(offsetY: CGFloat) {
        guard config.headerViewCouldScale && scaleBackgroundView != nil else { return }
        let yOffset  = offsetY + insetTop
        let xOffset = yOffset / 2
        var headerBgViewFrame = headerBgView?.frame
        var scaleBgViewFrame = scaleBackgroundView?.frame
        if config.headerViewScaleMode == .Top {
            if yOffset < 0 {
                headerBgViewFrame?.origin.y = yOffset - insetTop
                headerBgViewFrame?.size.height = -yOffset + headerViewOriginHeight
                
                scaleBgViewFrame?.size.height = -yOffset + headerViewOriginHeight
                scaleBgViewFrame?.origin.x = xOffset
                scaleBgViewFrame?.size.width = kYNPAGE_SCREEN_WIDTH + abs(xOffset) * 2
            }
        }else {
            if yOffset < 0 {
                headerBgViewFrame?.origin.y = yOffset - insetTop;
                headerBgViewFrame?.size.height = abs(yOffset) + headerViewOriginHeight
                
                scaleBgViewFrame?.size.height = abs(yOffset) + headerViewOriginHeight
                scaleBgViewFrame?.origin.x = xOffset
                scaleBgViewFrame?.size.width = kYNPAGE_SCREEN_WIDTH + abs(xOffset) * 2
            }
        }
        
        headerBgView?.frame = headerBgViewFrame ?? .zero
        scaleBackgroundView?.frame = scaleBgViewFrame ?? .zero
    }

}
