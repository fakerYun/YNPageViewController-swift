//
//  DemosListVC.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

public enum YNVCType: Int {
    case SuspendTopPauseVC
    case SuspendCenterVC
    case SuspendTopVC
    case TopVC
    case SuspendCustomNavOrSuspendPositionVC
    case NavigationVC
    case ScrollMenuVC
    case LoadVC
    case TestVC
}

class DemosListVC: BaseViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 55
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemosListCellID")
        return tableView
    }()
    
    var dataArrayM: [[String: Any]] = [[:]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demos"
        view.addSubview(tableView)
        initData()
    }
    
    func initData() {
        dataArrayM = [["title": "悬浮样式--下拉刷新在顶部(QQ联系人样式)", "type": YNVCType.SuspendTopPauseVC],
                      ["title": "悬浮样式--下拉刷新在中间", "type": YNVCType.SuspendCenterVC],
                      ["title": "悬浮样式--下拉刷新在顶部", "type": YNVCType.SuspendTopVC],
                      ["title": "悬浮样式--自定义导航条或自定义悬浮位置", "type": YNVCType.SuspendCustomNavOrSuspendPositionVC],
                      ["title": "加载数据后显示页面(隐藏导航条)", "type": YNVCType.LoadVC],
                      ["title": "顶部样式", "type": YNVCType.TopVC],
                      ["title": "导航条样式", "type": YNVCType.NavigationVC],
                      ["title": "菜单栏样式", "type": YNVCType.ScrollMenuVC],
                      ["title": "测试专用", "type": YNVCType.TestVC]]
        
    }

}

extension DemosListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArrayM.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemosListCellID", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        let dic = dataArrayM[indexPath.row]
        cell.textLabel?.text = dic["title"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dic = dataArrayM[indexPath.row]
        guard let type = dic["type"] as? YNVCType else { return }
        let title = dic["title"] as? String
        var vc: UIViewController?
        switch type {
        case .SuspendTopPauseVC:
            vc = YNSuspendTopPausePageVC()
        case .SuspendCenterVC:
            vc = YNSuspendCenterPageVC()
        case .SuspendTopVC:
            vc = YNSuspendTopPageVC()
        case .SuspendCustomNavOrSuspendPositionVC:
            vc = YNSuspendCustomNavOrSuspendPositionVC()
        case .LoadVC:
            vc = YNLoadPageVC()
        case .TopVC:
            vc = YNTopPageVC()
        case .NavigationVC:
            vc = YNNavPageVC()
        case .ScrollMenuVC:
            vc = YNScrollMenuStyleVC()
        case .TestVC:
            vc = YNTestVC()
        }
        
        if let vc = vc {
            vc.title = title
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
