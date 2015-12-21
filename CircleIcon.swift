//
//  CircleIcon.swift
//  CircleAnimation
//
//  Created by 鹏 朱 on 15/12/18.
//  Copyright © 2015年 鹏 朱. All rights reserved.
//

import UIKit

class CircleIcon: UIView {

    var fixedPath:CGMutablePath!
    var path0:CGMutablePath!
    var path1:CGMutablePath!
    var animationLength:NSTimeInterval = 20.0 //动画总时长
    var frameInSecond:Int = 60 //每秒帧数
    var accuracy:CGFloat = 0.05 //精度
    var turns:Int = 10 //圈数
    var currentRadian:CGFloat = 0
    var frameAccuracy:Int = 0
    
    var maxRadius:CGFloat = 71.0
    var currentRadius:CGFloat = 1.0
    var radiusAccuracy:CGFloat = 0
    
    var isAnimated:Bool = false
    var calculatePathDispatchQueque:dispatch_queue_t = dispatch_queue_create("calculatePath", DISPATCH_QUEUE_CONCURRENT)
    
    var timer:NSTimer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initCurrentRadian()
        initFrameAccuracy()
        initRadiusAccuracy()
        initFrameInSecond()
    }
    
    func setCircleAttribute(animationLength animationLength:NSTimeInterval, maxframeInSecond frameInSecond:Int, turns:Int, maxRadius:CGFloat,accuracy:CGFloat = 0.05)
    {
        self.animationLength = animationLength
        self.frameInSecond = frameInSecond
        self.turns = turns
        self.accuracy = accuracy
        self.maxRadius = maxRadius
        
        initCurrentRadian()
        initFrameAccuracy()
        initRadiusAccuracy()
        initFrameInSecond()
    }
    
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
        initCurrentRadian()
        self.currentRadius = 1.0
        //print(NSDate())
    }
    
    private func initRadiusAccuracy()
    {
        self.radiusAccuracy = maxRadius / ( 2.0 * CGFloat(M_PI) * CGFloat(turns) / accuracy)
    }
    
    //初始化弧度
    private func initCurrentRadian()
    {
        self.currentRadian = 2.0 * CGFloat(M_PI) * CGFloat(turns)
    }
    
    private func initFrameInSecond()
    {
        let framesInSecondActually = Int(2.0 * CGFloat(M_PI) * CGFloat(turns) / accuracy / CGFloat(animationLength)) + 1
        
        if framesInSecondActually < frameInSecond
        {
            self.frameInSecond = framesInSecondActually
        }
    }
    
    //每帧中包含的精度
    private func initFrameAccuracy()
    {
        self.frameAccuracy = Int(2.0 * CGFloat(M_PI) * CGFloat(turns) / accuracy / CGFloat(animationLength) / CGFloat(frameInSecond)) + 1
    }
    
    
   
    
    private func calculatePath(pathSource:CGMutablePathRef!)->CGMutablePathRef
    {
        let path = CGPathCreateMutable()
        
        dispatch_sync(calculatePathDispatchQueque) { [unowned self]() -> Void in
            var step:Int = 0
            
            if self.currentRadian <= 0.0 || self.currentRadius >= self.maxRadius
            {
                self.resetAnimation()
                
            }else if pathSource != nil
            {
                CGPathAddPath(path, nil, pathSource)
            }
            
            while self.currentRadian > 0.0 && step < self.frameAccuracy && self.currentRadius < self.maxRadius
            {
                CGPathAddArc(path, nil, self.frame.size.width / 2, self.frame.size.height / 2, self.currentRadius, self.currentRadian, self.currentRadian - self.accuracy, true)
                step++
                self.currentRadius += self.radiusAccuracy
                self.currentRadian -= self.accuracy
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
        CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
        
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
        CGContextAddLineToPoint(context, 0, 0)
        CGContextStrokePath(context)
        
        
    }
    
}











