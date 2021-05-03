//
//  VirtualStickView.swift
//  DJISimulatorDemo
//
//  Created by Samuel Scherer on 5/1/21.
//  Copyright © 2021 Demo. All rights reserved.
//

import Foundation
import UIKit

let kStickCenterTargetPositionLength : CGFloat = 20.0

class VirtualStickView : UIView {
    
    @IBOutlet var stickViewBase : UIImageView!
    @IBOutlet var stickView : UIImageView!
    var imageStickNormal : UIImage
    var imageStickHold : UIImage
    
    var mCenter : CGPoint //TODO: rename
    var mUpdateTimer : Timer? //TODO: rename
    var mTouchPoint : CGPoint? //TODO: rename... isn't it a java thing to prefix instance variables with m?

    //TODO: how to avoid repeated setup code? (can't call a setup function b/c no method calls until super.init())
    init(with frame:CGRect) {
        self.imageStickNormal = UIImage(named: "stick_normal.png")!
        self.imageStickHold = UIImage(named: "stick_hold.png")!
        self.mCenter = CGPoint(x: 64, y: 64)
        super.init(frame: frame)
    }

    required init?(coder:NSCoder) {
        self.imageStickNormal = UIImage(named: "stick_normal.png")!
        self.imageStickHold = UIImage(named: "stick_hold.png")!
        self.mCenter = CGPoint(x: 64, y: 64)
        super.init(coder: coder)
    }

    func notifyDir(dir:CGPoint) {//TODO: rename
        let vdir = NSValue(cgPoint: dir)
        let userInfo = ["dir" : vdir]
            
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "StickChanged"), object: self, userInfo: userInfo)
    }

    func stickMoveTo(deltaToCenter:CGPoint) {
        var frame = stickView.frame
        frame.origin.x = deltaToCenter.x
        frame.origin.y = deltaToCenter.y
        stickView.frame = frame
    }
    
    func touchEvent(touches:Set<UITouch>) {
        if touches.count != 1 { return }

        let touch = touches.first
        let view = touch?.view
        if view !== self { return }

        let touchPoint = touch?.location(in: view) ?? self.mCenter
        var dtarget : CGPoint?//TODO: rename
        var dir = CGPoint(x: touchPoint.x - mCenter.x, y: touchPoint.y - mCenter.y)//TODO: rename
        let length = sqrt(pow(dir.x,2) + pow(dir.y,2))

        if (length < 10.0) && (length > -10.0) {
            dtarget = CGPoint(x: 0.0, y: 0.0)
            dir.x = 0
            dir.y = 0
        } else {
            let inverseLength = 1.0 / length
            dir.x *= inverseLength
            dir.y *= inverseLength
            dtarget = CGPoint(x: dir.x * kStickCenterTargetPositionLength, y: dir.y * kStickCenterTargetPositionLength)
            //TODO: swift point class to replace CGPoint?
        }
        if let target = dtarget {
            self.stickMoveTo(deltaToCenter: target)
            self.notifyDir(dir: dir)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.stickView.image = self.imageStickHold

        if touches.count != 1 { return }

        let touch = touches.first
        guard let view = touch?.view else { return }
        if view !== self { return }

        self.mTouchPoint = touch?.location(in: view)
        self.startUpdateTimer()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count != 1 { return }
        let touch = touches.first
        let view = touch?.view
        if view !== self { return }
        self.mTouchPoint = touch?.location(in: view)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.recenterSticks()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.recenterSticks()
    }
    
    func recenterSticks() {
        self.stickView.image = imageStickNormal
        let dir = CGPoint(x: 0.0, y: 0.0)//TODO: both points necessary?
        let dTarget = CGPoint(x: 0.0, y: 0.0)
        self.stickMoveTo(deltaToCenter: dTarget)
        self.notifyDir(dir: dir)
        self.stopUpdateTimer()
    }

    @objc func onUpdateTimerTicked() {//TODO: id type in swift = Any?
        guard let touchPoint = self.mTouchPoint else { return }
        var dir = CGPoint(x: touchPoint.x - self.mCenter.x, y: touchPoint.y - mCenter.y )
        var dTarget = dir
        let length = sqrt(pow(dir.x, 2) + pow(dir.y,2))
        
        if length > kStickCenterTargetPositionLength {
            let inverseLength = 1.0 / length
            dir.x *= inverseLength
            dir.y *= inverseLength
            dTarget.x = dir.x * kStickCenterTargetPositionLength
            dTarget.y = dir.y * kStickCenterTargetPositionLength
        } else {
            dTarget.x = dir.x //TODO: can remove this ???
            dTarget.y = dir.y
        }

        dir.x = dTarget.x / kStickCenterTargetPositionLength
        dir.y = dTarget.y / kStickCenterTargetPositionLength
        self.stickMoveTo(deltaToCenter: dTarget)
        self.notifyDir(dir: dir)
    }
    
    func startUpdateTimer() {
        if self.mUpdateTimer == nil {
            self.mUpdateTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(onUpdateTimerTicked), userInfo: nil, repeats: true)
            self.mUpdateTimer?.fire()
        }
    }

    func stopUpdateTimer() {
        if let updateTimer = self.mUpdateTimer {
            updateTimer.invalidate()
            mUpdateTimer = nil
        }
    }
}
