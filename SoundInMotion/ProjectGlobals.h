//
//  ProjectGlobals.h
//
//  Created by konstantin on 17/05/2012.
//  Copyright (c) 2012 KTTSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MovieSoundEdition.h"


#ifndef LOCALIZED
    #define LOCALIZED(arg) NSLocalizedString(arg, nil)
#endif



extern BOOL PRJ_Is_iPad;
extern BOOL PRJ_Is_iPhone;
extern CGFloat PRJ_SystemVersion;

extern NSString *PRJ_userID;
extern NSString *PRJ_token;
extern NSString *PRJ_displayName;


//extern AVPlayer *videoPlayerGlobal;

//extern NSString *PRJ_MovieSoundsDirectory;
extern NSURL *PRJ_MovieSoundsURL;
extern NSMutableArray *PRJ_MovieSoundsEditionsURLs;
extern NSMutableArray *PRJ_MovieSoundsEditionsNames;

extern BOOL PRJ_IsRecordingState;




void InitProjectGlobals(void);

void ShowTitleErrorAlert(NSString *title, NSError *error);
void ShowErrorAlert(NSError *error);

void ShowTitleAlert(NSString *title, NSString *message);
void ShowAlert(NSString *message);

BOOL validatePhone (NSString * phone);


// Supplement funcs
NSString* StringPercentEscaped(NSString *originalString);

// check for directory existance and create if it doesn't
void CreateDirectory(NSString *directory);

// check if MovieSounds directory exists and create it if doesn't; also fill SoundEditions arrays
void InitMovieSoundsEditions();

// create/load MovieSoundEdition
MovieSoundEdition* CreateMovieSoundEdition(NSString* editionName);
MovieSoundEdition* LoadMovieSoundEdition(NSString* editionName);

