//
//  PerfomanceAreaStepGraphicFX.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/31/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "PerfomanceAreaStepGraphicFX.h"

@implementation PerfomanceAreaStepGraphicFX

-(void)setGraphicState:(GraphicState)graphicState{
    _graphicState = graphicState;
    switch (graphicState) {
        case GraphicStateLeftFX:
            self.image = [UIImage imageNamed:@"StepsGraphicLeftFx"];
            break;
        case GraphicStateRightFX:
            self.image = [UIImage imageNamed:@"StepsGraphicRightFx"];
            break;
        case GraphicStateAllFX:
            self.image = [UIImage imageNamed:@"StepsGraphicAllFx"];
            break;
        default:
            self.image = [UIImage imageNamed:@""];
            break;
    }
}

-(void)addGraphicState:(GraphicState)state{
    self.graphicState = self.graphicState | state;
}

-(void)removeGraphicState:(GraphicState)state{
    if (self.graphicState & state) {
        self.graphicState = self.graphicState ^ state;
    }
}

@end
