//
//  StepsFrameController.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 4/6/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StepsFrameControllerDelegate <NSObject>

-(void)chooseTimeRangeRewind:(float)timerange;

@end

@interface StepsFrameController : UIViewController

@property (weak,nonatomic) id <StepsFrameControllerDelegate> delegate;

@end
