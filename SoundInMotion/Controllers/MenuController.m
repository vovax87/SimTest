//
//  MenuController.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 4/21/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "MenuController.h"

@interface MenuController ()

@end

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapReplaceVideo:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate didSelectReplaceVideo];
}

- (IBAction)tapExitProject:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate didSelectExit];
}

@end
