//
//  YNScrollMenuStyleVC.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit

class YNScrollMenuStyleVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    

    func setupUI() {
        
        /// style 1
        let firstConfig = YNPageConfigration()
        let firstStype = YNPageScrollMenuView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 44),
                                              titles: ["swift", "Object-C", "JAVA"],
                                              configration: firstConfig,
                                              delegate: nil,
                                              currentIndex: 0)
        
        /// style 2
        let secondConfig = YNPageConfigration()
        secondConfig.showBottomLine = true
        secondConfig.bottomLineBgColor = .green
        secondConfig.bottomLineHeight = 1
        let secondStype = YNPageScrollMenuView(frame: CGRect(x: 0, y: firstStype.yn_bottom + 20, width: KScreenWidth, height: 44),
                                               titles: ["系统偏好设置", "网易云音乐", "有道词典", "微信", "QQ游戏", "QQ邮箱", "数码测色计"],
                                               configration: secondConfig,
                                               delegate: nil,
                                               currentIndex: 0)
        
        /// style 3
        let thirdConfig = YNPageConfigration()
        thirdConfig.showBottomLine = true
        thirdConfig.bottomLineBgColor = .green
        thirdConfig.bottomLineHeight = 1
        thirdConfig.scrollMenu = false
        thirdConfig.aligmentModeCenter = false
        thirdConfig.lineWidthEqualFontWidth = false
        thirdConfig.itemFont = .systemFont(ofSize: 14)
        thirdConfig.selectedItemColor = .red
        thirdConfig.normalItemColor = .black
        let thirdStype = YNPageScrollMenuView(frame: CGRect(x: 0, y: secondStype.yn_bottom + 20, width: KScreenWidth, height: 44),
                                               titles: ["QQ游戏", "QQ邮箱", "数码测色计"],
                                               configration: thirdConfig,
                                               delegate: nil,
                                               currentIndex: 0)
        
        /// style 4
        let fourthConfig = YNPageConfigration()
        fourthConfig.converColor = .gray
        fourthConfig.showConver = true
        fourthConfig.itemFont = .systemFont(ofSize: 16)
        fourthConfig.selectedItemFont = .systemFont(ofSize: 16)
        fourthConfig.selectedItemColor = .red
        fourthConfig.normalItemColor = .black
        fourthConfig.itemMaxScale = 1.2
        let fourthStype = YNPageScrollMenuView(frame: CGRect(x: 0, y: thirdStype.yn_bottom + 20, width: KScreenWidth, height: 44),
                                               titles: ["QQ游戏", "QQ邮箱", "数码测色计"],
                                               configration: fourthConfig,
                                               delegate: nil,
                                               currentIndex: 2)
        
        /// style 5
        let fifthConfig = YNPageConfigration()
        fifthConfig.isFixLineWidth = true
        fifthConfig.fixLineWidth = 30
        let fifthStype = YNPageScrollMenuView(frame: CGRect(x: 0, y: fourthStype.yn_bottom + 20, width: KScreenWidth, height: 44),
                                               titles: ["swift", "Object-C", "JAVA"],
                                               configration: fifthConfig,
                                               delegate: nil,
                                               currentIndex: 0)
        
        /// style 6
        let sixthConfig = YNPageConfigration()
        sixthConfig.scrollMenu = true
        sixthConfig.aligmentModeCenter = false
        sixthConfig.bottomLineHeight = 1
        sixthConfig.bottomLineBgColor = .green
        sixthConfig.showBottomLine = true
        let sixthStype = YNPageScrollMenuView(frame: CGRect(x: 0, y: fifthStype.yn_bottom + 20, width: KScreenWidth, height: 44),
                                               titles: ["swift", "Object-C", "JAVA"],
                                               configration: sixthConfig,
                                               delegate: nil,
                                               currentIndex: 1)
        
        /// style 7
        let seventhConfig = YNPageConfigration()
        seventhConfig.scrollMenu = false
        seventhConfig.aligmentModeCenter = false
        
        var btnArr: [UIButton] = []
        for _ in 0..<3 {
            let btn = UIButton()
            btn.setImage(UIImage(named: "menu_star_nor"), for: .normal)
            btn.setImage(UIImage(named: "menu_star_select"), for: .selected)
            btnArr.append(btn)
        }
        seventhConfig.buttonArray = btnArr
        let seventhStype = YNPageScrollMenuView(frame: CGRect(x: 0, y: sixthStype.yn_bottom + 20, width: KScreenWidth, height: 44),
                                               titles: ["美团", "腾讯", "阿里"],
                                               configration: seventhConfig,
                                               delegate: nil,
                                               currentIndex: 1)
        
        
        view.addSubview(firstStype)
        view.addSubview(secondStype)
        view.addSubview(thirdStype)
        view.addSubview(fourthStype)
        view.addSubview(fifthStype)
        view.addSubview(sixthStype)
        view.addSubview(seventhStype)
    }

}
