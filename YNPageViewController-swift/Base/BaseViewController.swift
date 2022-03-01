//
//  BaseViewController.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

let KScreenWidth = UIScreen.main.bounds.size.width
let KScreenHeight = UIScreen.main.bounds.size.height

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .bottom
        navigationController?.definesPresentationContext = true
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .white
    }
    
    deinit {
//        print("-----：\(String(describing: type(of: self))) --deinit")
    }
    


}
