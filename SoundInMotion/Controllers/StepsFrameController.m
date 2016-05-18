//
//  StepsFrameController.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 4/6/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "StepsFrameController.h"

@interface StepsFrameController ()

@end

@implementation StepsFrameController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.borderWidth = 2;
    self.view.layer.borderColor = [UIColor blueColor].CGColor;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tap1sec:(id)sender {
    [self.delegate chooseTimeRangeRewind:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tap5frame:(id)sender {
    [self.delegate chooseTimeRangeRewind:5];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tap1frame:(id)sender {
    [self.delegate chooseTimeRangeRewind:1];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
