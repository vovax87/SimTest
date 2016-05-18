//
//  SoundTrack.h
//  SoundInMotion
//
//  Created by Konstianm on 26/03/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundRange.h"
#import "RecordSession.h"
//#import "MovieSoundEdition.h"

@class MovieSoundEdition;

@interface SoundTrack : NSObject<NSCoding>

@property (strong, nonatomic) NSURL *encodingDirectoryURL;

//@property (strong, nonatomic) NSMutableArray *soundRanges;
@property (strong, nonatomic) NSMutableArray *recordSessions;
@property (nonatomic) CGFloat volume;
@property (nonatomic) BOOL isMute;
@property (strong, nonatomic) NSURL *performanceAreaImageURL;
@property (nonatomic) NSInteger performanceAreaType;
@property (weak, nonatomic) MovieSoundEdition *movieSoundEdition;
@property (nonatomic) BOOL isChanged;

@property (strong,nonatomic) NSDictionary *settingsPerfomanceArea;

-(RecordSession*)createRecordSession;
-(void)addRecordSession:(RecordSession*)item;
-(void)sortRecordSessions;
-(void)removeRecordSession:(RecordSession*)item;

//-(void) addSoundRange:(SoundRange*)range;
//-(SoundRange*) addSoundFileURL:(NSURL*)soundFileURL atPosition:(CMTime)cmtimePosition;
//-(void) sortSoundRanges;
//-(void) removeSoundRange:(SoundRange*)soundRange;
//-(void) removeSoundRangeAtTimePosition:(CMTime)timePosition;



@end
