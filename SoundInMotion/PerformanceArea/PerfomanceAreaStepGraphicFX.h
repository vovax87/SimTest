//
//  PerfomanceAreaStepGraphicFX.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/31/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GraphicStateNone = 0,
    GraphicStateLeftFX = 1 << 0,
    GraphicStateRightFX = 1 << 1,
    GraphicStateAllFX = GraphicStateLeftFX | GraphicStateRightFX,
} GraphicState;

@interface PerfomanceAreaStepGraphicFX : UIImageView

@property (assign,nonatomic) GraphicState graphicState;

-(void)addGraphicState:(GraphicState)state;
-(void)removeGraphicState:(GraphicState)state;

@end
