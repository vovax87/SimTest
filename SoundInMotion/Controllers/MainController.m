
//
//  MainController.m
//  SoundInMotion
//
//  Created by Konstianm on 19/02/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//
#import "ProjectGlobals.h"

#import "MainController.h"
#import "VideoController.h"
#import "TracksView.h"
#import "SelectedPerformanceArea.h"
#import "StepsFrameController.h"
#import "MenuController.h"

#import "MovieSoundEdition.h"
#import "CompositionPlayer.h"

#import <MobileCoreServices/UTCoreTypes.h>

@interface MainController ()

@property (weak, nonatomic) IBOutlet TracksView *trackView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *recButton;

@property (weak, nonatomic) IBOutlet UIButton *backRewindButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardRewindButton;

@property (weak, nonatomic) IBOutlet UIButton *buttonSelectVideo;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end




@implementation MainController
{
    MovieSoundEdition *_soundEdition;
    float rewindRange;
    
    AVPlayer *_audioComposePlayer;
    CompositionPlayer *_compositionPlayer;
    CMTime startEditingTime;
    CMTime endEditingTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (UIInterfaceOrientationMask) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}



-(IBAction)exitController:(id)sender{

}



-(IBAction)tapToNewFolleyChannel:(UIButton*)sender{
    [SelectedPerformanceArea showWithApplyBlock:^(SelectedPerformanceArea *overlapView) {
        PerformanceAreaType type = (PerformanceAreaType)overlapView.selectedIndex;
        [self.trackView createNewTrackOfType:type];
    } cancelBlock:nil];
}




@end

