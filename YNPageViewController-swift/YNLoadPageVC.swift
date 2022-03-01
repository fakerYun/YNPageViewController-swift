//
//  YNLoadPageVC.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

class YNLoadPageVC: BasePageViewController {
    
    var indicatorView: UIActivityIndicatorView?
    
    var pageVC: YNPageViewController?
    var vcArr: [BaseTableViewVC] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        indicatorView = UIActivityIndicatorView(style: .gray)
        indicatorView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        indicatorView?.center = view.center
        indicatorView?.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.indicatorView?.stopAnimating()
            self.indicatorView?.isHidden = true
            self.setupPageVC()
        }
        view.addSubview(indicatorView!)
    }
    
    func setupPageVC() {
        
        let config = YNPageConfigration()
        config.showTabbar = false
        config.showNavigation = false
        config.showBottomLine = true
        config.pageStyle = .SuspensionCenter
        config.aligmentModeCenter = false
        config.scrollMenu = false
        config.isFixLineWidth = true
        config.fixLineWidth = 30
        config.suspenOffsetY = 64
        config.cutOutHeight = 44
        
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
        pageVC?.pageIndex = 0
        pageVC?.addSelfToParent(parentVC: self)

    }

}

extension YNLoadPageVC: YNPageViewControllerDelegate, YNPageViewControllerDataSource {
    
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
