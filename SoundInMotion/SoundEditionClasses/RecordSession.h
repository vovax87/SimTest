//
//  RecordSession.h
//  SoundInMotion
//
//  Created by Konstianm on 26/04/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundRange.h"

@class SoundTrack;

@interface RecordSession : NSObject<NSCoding>

@property (strong, nonatomic) NSURL *encodingDirectoryURL;

@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CMTimeRange cropTimeRange;
@property (strong, nonatomic) NSMutableArray *soundRanges;
@property (nonatomic) CGFloat volume;
@property (weak, nonatomic) SoundTrack *soundTrack;

//@property (readonly, nonatomic) BOOL isCropped;


-(void) addSoundRange:(SoundRange*)range;
-(SoundRange*) addSoundFileURL:(NSURL*)soundFileURL atPosition:(CMTime)cmtimePosition;
-(void) sortSoundRanges;
-(void) removeSoundRange:(SoundRange*)soundRange;
-(void) removeSoundRangeAtTimePosition:(CMTime)timePosition;

-(void)removeFromSoundTrack;

@end
