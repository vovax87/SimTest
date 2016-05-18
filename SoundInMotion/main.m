//
//  main.m
//  SoundInMotion
//
//  Created by Konstianm on 19/02/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ProjectGlobals.h"

int main(int argc, char * argv[]) {
    
    InitProjectGlobals();
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
