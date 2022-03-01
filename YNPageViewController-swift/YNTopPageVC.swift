//
//  YNTopPageVC.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

class YNTopPageVC: BasePageViewController {
    
    var pageVC: YNPageViewController?
    var vcArr: [BaseTableViewVC] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageVC()
    }
    
    func setupPageVC() {
        
        let config = YNPageConfigration()
        config.showTabbar = false
        config.showBottomLine = true
        config.pageStyle = .Top
        config.aligmentModeCenter = false
        config.scrollMenu = false
        config.isFixLineWidth = true
        config.fixLineWidth = 30
        
        let titles: [String] = ["鞋子", "衣服", "帽子"]
        vcArr = [BaseTableViewVC(),
                 BaseTableViewVC(),
                 BaseTableViewVC()]
        pageVC = YNPageViewController(controllers: vcArr, titles: titles, config: config)
        pageVC?.delegate = self
        pageVC?.dataSource = self
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 150))
        headerView.backgroundColor = .red
        pageVC?.headerView = headerView
        pageVC?.pageIndex = 1
        pageVC?.addSelfToParent(parentVC: self)

    }

}

extension YNTopPageVC: YNPageViewControllerDelegate, YNPageViewControllerDataSource {
    
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

