//
//  MovieSoundEdition.h
//  SoundInMotion
//
//  Created by Konstianm on 25/03/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundTrack.h"

@interface MovieSoundEdition : NSObject<NSCoding>

@property (strong, nonatomic) NSURL *encodingDirectoryURL;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *videoURL;
@property (readonly, nonatomic) CMTime videoDuration;
@property (strong, nonatomic) NSMutableArray *tracks;
@property (strong, nonatomic) NSMutableArray *flags;
@property (nonatomic) BOOL changed;


-(void) save;

+(void) saveObject:(MovieSoundEdition*)movieSoundEdition;
+(instancetype) loadObjectFromURL:(NSURL*)encodedDataURL;

-(SoundTrack*) createSoundTrack;
-(void)removeSoundTrack:(SoundTrack*)soundTrack;


@end
