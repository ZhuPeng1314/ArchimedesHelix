//
//  CircleIcon.swift
//  CircleAnimation
//
//  Created by 鹏 朱 on 15/12/18.
//  Copyright © 2015年 鹏 朱. All rights reserved.
//

import UIKit

class CircleIconLineSpeed: UIView {
    
    // MARK:- 帧数据

    var fixedPath:CGMutablePath!
    var path0:CGMutablePath!
    var path1:CGMutablePath!
    
    // MARK:- 原始参数
    var frameInSecond:Int = 40 //每秒帧数
    var maxRadius:CGFloat = 71.0 //最大半径
    var lineSpeed:CGFloat = 20 //线速度
    var turns:Int = 5 //圈数
    
    var mixRadius:CGFloat = 1.0 //最小半径
    var accuracy:CGFloat = 0.03 //每一帧的最小精度
    
    // MARK:- 中间量
    
    var currentRadius:CGFloat = 0
    var currentRadian:CGFloat = 3.14
    
    var timeInframe:NSTimeInterval = 0.0 //每一帧的时长
    
    var R_ARatio:CGFloat = 0 //半径与角度的比值
    
    // MARK:- 动画控制属性
    var isAnimated:Bool = false
    var calculatePathDispatchQueque:dispatch_queue_t = dispatch_queue_create("calculatePath", DISPATCH_QUEUE_CONCURRENT)
    
    var timer:NSTimer!
    
    // MARK:- 初始化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        calculateAttribute()
    }
    
    func setCircleAttribute(maxframeInSecond frameInSecond:Int, lineSpeed:CGFloat, maxRadius:CGFloat, turns:Int)
    {
        self.frameInSecond = frameInSecond
        self.maxRadius = maxRadius
        self.lineSpeed = lineSpeed
        self.turns = turns
        
        calculateAttribute()
    }
    
    // MARK: - 动画控制
    
    func startOrStopAnimation()
    {
        if self.isAnimated == false
        {
            startAnimation()
        }else
        {
            stopAnimation()
        }
    }
    
    func startAnimation()
    {
        if self.isAnimated == false
        {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / Double(frameInSecond), target: self, selector: "updateAnimationFrame", userInfo: nil, repeats: true)
            self.isAnimated = true
            self.fixedPath = nil
        }
    }
    
    func stopAnimation()
    {
        if self.isAnimated == true
        {
            self.timer.invalidate()
            self.isAnimated = false
        }
    }
    
    func updateAnimationFrame()
    {
        self.setNeedsDisplay()
    }
    
    func resetAnimation()
    {
        self.currentRadius = self.mixRadius
        self.currentRadian = CGFloat(M_PI)
        //print(NSDate())
    }
    
    // MARK: - 中间量计算
    
    private func calculateAttribute()
    {
        resetAnimation()
        
        initTimeInFrame()
        initR_ARatio()
        
    }
    
    private func initTimeInFrame()
    {
        self.timeInframe = 1.0 / Double(self.frameInSecond)
    }
    
    private func initR_ARatio()
    {
        self.R_ARatio = self.maxRadius / (2.0 * CGFloat(M_PI) * (CGFloat(self.turns) + 0.5))
    }
    
    /*
    Theta是瞬时角度，dt是每帧时长，dTheta每帧角位移，dR是 每帧半径改变量
    r= a * Theta
    dR = a * dTheta
    dTheta = w*dt = (v / （a * Theta))*dt
    dR = a * dTheta =  a * (v / （a * Theta))*dt = dt * v / Theta
    */
    
    //当前角位移
    private func calculateCurrentAngularDisplacement(dRadius:CGFloat) -> CGFloat
    {
        return dRadius / self.R_ARatio
    }
    
    //当前dR
    private func calculate_dRadius(currentRadian:CGFloat) -> CGFloat
    {
        return self.lineSpeed * CGFloat(self.timeInframe) / currentRadian
    }
    
   
    // MARK: - 帧数据计算
    
    private func calculatePath(pathSource:CGMutablePathRef!)->CGMutablePathRef
    {
        let path = CGPathCreateMutable()
        
        dispatch_sync(calculatePathDispatchQueque) { [unowned self]() -> Void in
            
            if self.currentRadius >= self.maxRadius
            {
                self.resetAnimation()
                
            }else if pathSource != nil
            {
                CGPathAddPath(path, nil, pathSource)
            }
            
            //当前dR
            let current_dR = self.calculate_dRadius(self.currentRadian)
            let currentAD = self.calculateCurrentAngularDisplacement(current_dR)
            
            if (currentAD > self.accuracy)
            {
                let steps = Int(currentAD / self.accuracy)
                var tempRadius = self.currentRadius
                var tempRadian = self.currentRadian
                
                
                for var i=0; i<steps; i++
                {
                    let current_dR1 = self.R_ARatio * self.accuracy

                    CGPathAddArc(path, nil, self.center.x, self.center.y, tempRadius, tempRadian, tempRadian + self.accuracy, false)
                    
                    tempRadius += current_dR1
                    tempRadian += self.accuracy
                }
                
                CGPathAddArc(path, nil, self.center.x, self.center.y, tempRadius, tempRadian, self.currentRadian + currentAD, false)
                self.currentRadius += current_dR
                self.currentRadian += currentAD
                
            }else
            {
                CGPathAddArc(path, nil, self.frame.size.width / 2, self.frame.size.height / 2, self.currentRadius, self.currentRadian, self.currentRadian + currentAD, false)
                
                self.currentRadius += current_dR
                self.currentRadian += currentAD
            }

        }
        
        return path
        
        
    }
    
    private func asyncGenaratePath1()
    {
        let pathSource = self.path0
        dispatch_async(dispatch_get_main_queue()) { [unowned self]() -> Void in
            self.path1 = self.calculatePath(pathSource)
        }
    }
    
    private func fillPathPool()
    {
        if (self.path0 != nil && self.path1 == nil)
        {
            asyncGenaratePath1()
        }
        else if (self.path0 == nil && self.path1 != nil)
        {
            self.path0 = self.path1
            asyncGenaratePath1()
        }else if (self.path0 == nil && self.path1 == nil)
        {
            self.path0 = self.calculatePath(nil)
            asyncGenaratePath1()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        
        var path:CGMutablePathRef
        if self.isAnimated == true
        {
            fillPathPool()
            path = self.path0
            self.path0 = nil
        }else
        {
            if self.fixedPath == nil
            {
                fillPathPool()
                self.fixedPath = self.path0
            }
            path = self.fixedPath
        }
        
        CGContextAddPath(context, path)
        CGContextAddLineToPoint(context, self.frame.size.width, 0)
        CGContextStrokePath(context)
        
        
    }
    
}











