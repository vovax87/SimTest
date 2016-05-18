//
//  VideoController.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 2/22/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "VideoController.h"

@implementation VideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    _playerViewController = [[AVPlayerViewController alloc] init];
    _playerViewController.showsPlaybackControls = NO;
    _playerViewController.view.frame = self.view.bounds;
    [self.view addSubview:_playerViewController.view];
    self.view.autoresizesSubviews = YES;
    [self.view sendSubviewToBack:_playerViewController.view];
    // Do any additional setup after loading the view.
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
