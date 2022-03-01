//
//  BaseTableViewVC.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

class BaseTableViewVC: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 40
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BaseTableViewVCCellID")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.reloadData()
        })
    }
    
    func reloadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tableView.mj_header?.endRefreshing()
        }
    }

}

extension BaseTableViewVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(arc4random_uniform(10)) + 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewVCCellID", for: indexPath)
        cell.textLabel?.text = "row：\(indexPath.row)"
        return cell
    }
    
}
