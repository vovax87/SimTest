//
//  SelectedPerformanceArea.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/24/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectedPerformanceArea;

typedef void(^OverlapViewBlock)(SelectedPerformanceArea* overlapView);

@interface SelectedPerformanceArea : UIView

@property (assign,nonatomic,readonly) NSUInteger selectedIndex;


+(void)showWithApplyBlock:(OverlapViewBlock)blockApply cancelBlock:(OverlapViewBlock)blockCancel;

@end
