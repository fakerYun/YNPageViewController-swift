//
//  SuspendTopBaseVC.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

class SuspendTopBaseVC: BaseTableViewVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.mj_header?.ignoredScrollViewContentInsetTop = self.yn_pageViewController?.config.tempTopHeight ?? 0
    }

}


