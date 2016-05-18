//
//  SoundTableCell.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 2/23/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "SoundTableCell.h"
#import "FDWaveformView.h"
//#import "WavesScrollView.h"


@interface SoundTableCell () <FDWaveformViewDelegate,UIPopoverControllerDelegate>

@end

@implementation SoundTableCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setDoubleTapImage:(UITapGestureRecognizer *)doubleTapImage{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.soundImageView removeGestureRecognizer:self.soundImageView.gestureRecognizers.firstObject];
        doubleTapImage.numberOfTapsRequired = 2;
        [self.soundImageView addGestureRecognizer:doubleTapImage];
    });
}


#pragma mark - Action's


-(IBAction)changeVolumeChannel:(UISlider*)sender{
    NSLog(@"changeVolumeChannel");
}


@end
