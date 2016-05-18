//
//  SoundTableCell.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 2/23/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "WavesScrollView.h"

@interface SoundTableCell : UITableViewCell

@property (weak,nonatomic) IBOutlet UIImageView *soundImageView;
@property (weak,nonatomic) IBOutlet UIScrollView *wavesView;
@property (weak,nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak,nonatomic) IBOutlet UIView *settingView;

@property (assign, nonatomic) float volumeLevel;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapImage;



@end
