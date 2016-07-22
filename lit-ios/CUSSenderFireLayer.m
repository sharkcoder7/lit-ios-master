//
//  CUSSenderGoldLayer.m
//  CUSSenderExample
//
//  Created by zhangyu on 14-2-24.
//  Copyright (c) 2014年 zhangyu. All rights reserved.
//

#import "CUSSenderFireLayer.h"

@implementation CUSSenderFireLayer
- (id)init
{
    self = [self initWithImageName:@"CUSSenderFire.png"];
    
    return self;
}

-(CAEmitterCell *)createSubLayer:(UIImage *)image{
    
    CAEmitterCell *cellLayer = [CAEmitterCell emitterCell];
    
    cellLayer.birthRate		= 10.0;
    cellLayer.lifetime		= 20;
	
	cellLayer.velocity		= -650;				// falling down slowly
	cellLayer.velocityRange = 0.3;
	cellLayer.yAcceleration = 4;
    cellLayer.emissionRange = 0.25 * M_PI;		// some variation in angle
    cellLayer.spinRange		= 0.35 * M_PI;		// slow spin
    cellLayer.scale = 0.45;
    cellLayer.scaleRange = 0.2;
    cellLayer.contents		= (id)[image CGImage];
    
    cellLayer.color			= [[UIColor whiteColor] CGColor];
    return cellLayer;
}
@end
