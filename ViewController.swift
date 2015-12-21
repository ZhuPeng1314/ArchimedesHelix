//
//  ViewController.swift
//  CircleAnimation
//
//  Created by 鹏 朱 on 15/12/18.
//  Copyright © 2015年 鹏 朱. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var circleIconView: CircleIconLineSpeed!
    @IBOutlet var circleIcon2View: CircleIcon!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        self.circleIconView.setCircleAttribute(maxframeInSecond: 30, lineSpeed: 100, maxRadius: 50, turns: 6)
        
        self.circleIcon2View.setCircleAttribute(animationLength: 5, maxframeInSecond: 40, turns: 6, maxRadius: 100, accuracy: 0.03)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonPressed(sender: UIButton) {
        self.circleIconView.startOrStopAnimation()
    }

    @IBAction func startButton2Pressed(sender: UIButton) {
        self.circleIcon2View.startOrStopAnimation()
    }
}

