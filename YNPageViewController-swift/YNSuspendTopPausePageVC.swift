//
//  YNSuspendTopPausePageVC.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

class YNSuspendTopPausePageVC: BasePageViewController {
    
    var pageVC: YNPageViewController?
    var vcArr: [SuspendTopPauseBaseVC] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageVC()
    }
    
    func setupPageVC() {
        
        let config = YNPageConfigration()
        config.showTabbar = false
        config.showBottomLine = true
        config.pageStyle = .SuspensionTopPause
        config.aligmentModeCenter = false
        config.scrollMenu = false
        config.isFixLineWidth = true
        config.fixLineWidth = 30
        
        let titles: [String] = ["鞋子", "衣服", "帽子"]
        vcArr = [SuspendTopPauseBaseVC(),
                 SuspendTopPauseBaseVC(),
                 SuspendTopPauseBaseVC()]
        pageVC = YNPageViewController(controllers: vcArr, titles: titles, config: config)
        pageVC?.delegate = self
        pageVC?.dataSource = self
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 150))
        headerView.backgroundColor = .red
        pageVC?.headerView = headerView
        pageVC?.pageIndex = 0
        pageVC?.addSelfToParent(parentVC: self)
        pageVC?.bgScrollView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.reloadData()
        })

    }
    
    func reloadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.pageVC?.bgScrollView.mj_header?.endRefreshing()
        }
    }

}

extension YNSuspendTopPausePageVC: YNPageViewControllerDelegate, YNPageViewControllerDataSource {
    
    func pageViewController(pageViewController: YNPageViewController, pageForIndex index: Int) -> UIScrollView {
        let vc = vcArr[index]
        return vc.tableView
    }
    
    func pageViewController(pageViewController: YNPageViewController, scrollView: UIScrollView, progress: CGFloat, fromIndex: Int, toIndex: Int) {
//        print("--- progress = \(progress), fromIndex = \(fromIndex),  toIndex = \(toIndex)")
    }
    
    func pageViewController(pageViewController: YNPageViewController, contentOffsetY: CGFloat, progress: CGFloat) {
        
    }
    
}
