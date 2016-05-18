//
//  SoundsTableView.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 2/22/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PerformanceArea.h"


@interface SoundsTableView : UITableView



@property (assign, nonatomic) CGSize contentSizeForWaves;

-(PerformanceAreaType)allocationDoubleTap:(CGPoint)point;


-(NSArray*)wavesViewsInTableView;


@end
