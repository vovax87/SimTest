//
//  MenuController.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 4/21/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MenuControllerDelegate <NSObject>

-(void)didSelectReplaceVideo;
-(void)didSelectExit;

@end

@interface MenuController : UIViewController


@property (weak,nonatomic) id <MenuControllerDelegate> delegate;



@end
