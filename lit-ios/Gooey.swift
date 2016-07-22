//
//  Gooey.swift
//  Gooey2
//
//  Created by Pål Forsberg on 2015-02-18.
//  Copyright (c) 2015 Pål Forsberg. All rights reserved.
//

import QuartzCore
import UIKit

enum State {
    case Open
    case Closed
    case Animating
}

@objc protocol GooeyDelegate{
    func gooeyDidSelectIndex(index : Int)
    func gooeyDidTapMainButton()
}

@objc class Gooey : UIView, GooeyItemDelegate{
    
    var gooey : GooeyLayer
    var state : State = State.Closed
    
    var items : [GooeyItem] = [GooeyItem]()
    
    let angles : [CGFloat] = [Gooey.radians(40), Gooey.radians(90), Gooey.radians(140)]
    let bridgeAngles : [CGFloat] = [Gooey.radians(-50), Gooey.radians(0), Gooey.radians(50)]
    var duration : Double = 0.11 // 0.13
    var delegate : GooeyDelegate?
    let gooeyImage = Cross()
    var color : UIColor?{
        didSet{
            gooey.color = color?.CGColor
            for i in items{
                i.color = color
            }
        }
    }
    
    class func radians(degrees: CGFloat)->CGFloat {
        return degrees * CGFloat(M_PI) / 180
    }
    
    override init(frame: CGRect) {
        gooey = GooeyLayer()
        
        let item1 = GooeyItem()
        let item2 = GooeyItem()
        let item3 = GooeyItem()
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.24;
        
        gooey.contentsScale = UIScreen.mainScreen().scale
        let gooeywidth = min(self.frame.size.width, self.frame.size.height)
        gooey.frame = CGRect(x:self.frame.size.width/2-gooeywidth/2, y:self.frame.size.height-gooeywidth, width:gooeywidth, height:gooeywidth)
        gooey.masksToBounds = false
        gooey.setNeedsDisplay()
        
        let width : CGFloat = 18
        gooeyImage.contentScaleFactor = UIScreen.mainScreen().scale
        gooeyImage.frame = CGRect(x: self.frame.size.width/2-width/2, y: self.frame.size.height/2-width/2-15, width: width, height: width)
        gooeyImage.setNeedsDisplay()
        gooeyImage.backgroundColor = UIColor.clearColor()
        
        self.layer.addSublayer(gooey)
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.addSubview(gooeyImage)
        
        let tapper = UITapGestureRecognizer(target: self, action: "tapped:")
        tapper.cancelsTouchesInView = false
        self.addGestureRecognizer(tapper)
        
        addItem(item1,imagePath: "gooeySounds.png")
        addItem(item2,imagePath: "gooeyDubs.png")
        addItem(item3,imagePath: "gooeyLyrics.png")
        
        self.bringSubviewToFront(gooeyImage)        
    }
    
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for v in items{
            if(point.x < v.frame.origin.x + v.frame.width && point.x > v.frame.origin.x
                && point.y < v.frame.origin.y + v.frame.height && point.y > v.frame.origin.y
                && self.state == State.Open){
                    return true;
            }
            
            /*if v.pointInside(point, withEvent: event) {
            return true;
            }*/

        }
        
        var frame = self.frame;
        frame.origin = CGPointMake(0, 0);
        if (CGRectContainsPoint(frame, point)) {
            return true
        } else {
            return false
        }

    }
    
    func tapped(tapper : UITapGestureRecognizer){
        
        for v in items{
            if v.state == State.Animating{
                return
            }
        }
        
        let point = tapper.locationInView(tapper.view)
        
        if(!CGRectContainsPoint(CGRectInset(gooey.frame, gooey.insets!, gooey.insets!), point)){
            return
        }
        if (state == State.Closed){
            
//            var delay = 0.25 * Double(NSEC_PER_SEC)
//            var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//            dispatch_after(time, dispatch_get_main_queue()) {
//                if(self.playerOne!.play()) { /*print("Play")*/ }
//                else { /*print("nope")*/ }
//            }
//            
//            delay = 0.45 * Double(NSEC_PER_SEC)
//            time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//            dispatch_after(time, dispatch_get_main_queue()) {
//                if(self.playerTwo!.play()) { /*print("Play")*/ }
//                else { /*print("nope")*/ }
//            }
//            
//            delay = 0.65 * Double(NSEC_PER_SEC)
//            time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//            dispatch_after(time, dispatch_get_main_queue()) {
//                if(self.playerThree!.play()) { /*print("Play")*/ }
//                else { /*print("nope")*/ }
//            }
            
            
            animateOpen(self.duration)
            state = State.Open
        } else if(state == State.Open){
            animateClose(self.duration)
            state = State.Closed
        }
        
        self.delegate?.gooeyDidTapMainButton()
    }

    
    func addItem(v : GooeyItem, imagePath : String){
        
        let angle = angles[items.count]
        let bridgeAngle = bridgeAngles[items.count]
        let point = CGPoint(x: self.frame.size.width/2 - cos(angle) * 85, y: self.frame.size.height/2 - sin(angle) * 85)
        v.frame = CGRect(x: 0, y: 0, width: 60, height: 70)
        v.angle = bridgeAngle
        v.center = CGPoint(x: gooey.frame.origin.x + point.x, y: gooey.frame.origin.y + point.y)
        v.color = self.color
        v.delegate = self
        
        v.imageView.image = UIImage(named: imagePath)
        v.clipsToBounds = false
        self.clipsToBounds = false
        
        self.addSubview(v)
        items.append(v)
        
    }
    
    func animateOpen(duration : Double){
        
        for i in 0...items.count-1{
            let b = items[i]
            
            let delay = duration * Double(i) + duration*2
            b.animateOpen(duration, delay: delay)
        }
        
        gooeyImage.animate(45, fromangle:0, duration: duration*2)
        
        let out1 = gooey.getAnimation(duration*2.5, direction: Direction.LeftOut, type: Animation.Calm)
        let out2 = gooey.getAnimation(duration*2.5, direction: Direction.RightOut, type: Animation.Calm)
        let in1 = gooey.getAnimation(duration * 8, direction: Direction.Back, type: Animation.Gooey)
        gooey.animateGroup([out1, out2, in1], opening: true)
    }
    
    func animateClose(duration : Double){
        
        for i in 1...items.count {
            let b = items[items.count - i]

            let delay = Double(i-1) * (duration) + duration/**1.5*/
            b.animateClose(duration, delay: delay)
        }
    
        gooeyImage.animate(0, fromangle:45, duration: duration*2)
        
        let out1 = gooey.getAnimation(duration * 3.0, direction: Direction.RightOut, type: Animation.Calm)
        let out2 = gooey.getAnimation(duration * 2.1, direction: Direction.LeftOut, type: Animation.Calm)
        let in1 = gooey.getAnimation(duration * 8, direction: Direction.Back, type: Animation.Gooey)
        gooey.animateGroup([out1, out2, in1], opening: false)
        
        state = State.Closed;
    }
    
    func gooeyItemDidSelect(item: GooeyItem) {
        var i = 0
        for v in items{
            if v == item{
                break
            }
            i++
        }
        let index = i
        self.delegate?.gooeyDidSelectIndex(index)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
