//
//  BasePageViewController.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

class BasePageViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "功能操作",
                                                            style: .plain, target: self,
                                                            action: #selector(rightButtonOnClick))
    }
    

    @objc func rightButtonOnClick() {
        
    }
    

}
