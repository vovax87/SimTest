//
//  SoundRange.h
//  SoundInMotion
//
//  Created by Konstianm on 26/03/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class SoundTrack;
@class RecordSession;

@interface SoundRange : NSObject<NSCoding>

//@property (assign, nonatomic) CGFloat timePosition;
//@property (assign, nonatomic) CGFloat timeLength;

@property (strong, nonatomic) NSURL *encodingDirectoryURL;
//@property (weak, nonatomic) SoundTrack *soundTrack;
@property (weak, nonatomic) RecordSession *recordSession;

//@property (readonly, nonatomic) NSString *soundFileName;
@property (strong, nonatomic) NSURL *soundFileURL;
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CMTimeRange cropTimeRange;
@property (readonly, nonatomic) BOOL isCropped;
@property (strong, nonatomic) UIColor *color;


-(void)removeFromRecordSession;

@end
