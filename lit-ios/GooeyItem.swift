//
//  GooeyItem.swift
//  Gooey2
//
//  Created by Pål Forsberg on 2015-03-02.
//  Copyright (c) 2015 Pål Forsberg. All rights reserved.
//

import UIKit

protocol GooeyItemDelegate {
    func gooeyItemDidSelect(item : GooeyItem)
}
class GooeyItem : UIView{
    let bridge : BridgeLayer = BridgeLayer()
    let imageView : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
    var state : State = State.Closed
    var delegate : GooeyItemDelegate?
    
    var color : UIColor? {
        didSet {
            bridge.color = color
        }
    }
    
    var angle : CGFloat = 0.0 {
        didSet{
            self.transform = CGAffineTransformMakeRotation(self.angle)
        }
    }
    
    override var frame : CGRect{
        didSet {
            bridge.frame = CGRect(origin: CGPointZero, size: self.frame.size)
            bridge.setNeedsDisplay()
            bridge.masksToBounds = false
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bridge.frame = frame
        bridge.setNeedsDisplay()
        bridge.masksToBounds = false
        
        imageView.center = CGPoint(x: 0, y: 102-10)
        imageView.alpha = 0.0
        imageView.clipsToBounds = false
        
        self.userInteractionEnabled = true
        self.layer.addSublayer(bridge)
        self.addSubview(imageView)
        
        self.clipsToBounds = false
        self.layer.masksToBounds = false

        let tapper = UITapGestureRecognizer(target: self, action: "tapped:")
        self.addGestureRecognizer(tapper)
    }
        
    func tapped(tapper : UITapGestureRecognizer){
        let loc = tapper.locationInView(self)
        if(loc.y < 44 && self.state == State.Open){
            self.delegate?.gooeyItemDidSelect(self)
        }
    }
    
    func animateOpen(duration : Double, delay : Double){
        state = State.Animating
        bridge.animateOpen(duration, delay: delay)
        animateImageOut(duration, delay: delay)
    }
    
    func animateClose(duration : Double, delay : Double){
        state = State.Animating
        bridge.animateClose(duration, delay: delay)
        animateImageIn(duration, delay: delay)
    }
    
    func animateImageOut(duration : Double, delay : Double){
        UIView.animateWithDuration(duration*1.5, delay: delay*1.2, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.imageView.alpha = 1.0
            self.imageView.center = CGPoint(x: 30, y: 24)
            self.imageView.transform = CGAffineTransformMakeRotation(-self.angle)
        }) { (ended) -> Void in
            UIView.animateWithDuration(duration*2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.imageView.center = CGPoint(x: 30, y: 28)
                }) { (ended) -> Void in
                    self.state = State.Open
            }
        }
    }
    
    func animateImageIn(duration : Double, delay : Double){
        UIView.animateWithDuration(duration*3, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.imageView.center = CGPoint(x: 30, y: 80)
            self.imageView.alpha = 0.0
            }) { (ended) -> Void in
                UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    self.imageView.alpha = 0.0
                    self.imageView.center = CGPoint(x: 30, y: 98)
                    self.imageView.transform = CGAffineTransformMakeRotation(-self.angle)
                    }) { (ended) -> Void in
                        self.state = State.Closed
                }
        }
    }    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
