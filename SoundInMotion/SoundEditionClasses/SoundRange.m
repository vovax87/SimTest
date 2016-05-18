//
//  SoundRange.m
//  SoundInMotion
//
//  Created by Konstianm on 26/03/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//


static NSString *const kSRSoundFileName = @"kSRSoundFileName";
static NSString *const kSRTimeRange     = @"kSRTimeRange";
static NSString *const kSRCropTimeRange = @"kSRCropTimeRange";
static NSString *const kSRSoundTrack    = @"kSRSoundTrack";
static NSString *const kSRRecordSession = @"kSRRecordSession";
static NSString *const kSRColor = @"kSRColor";

//static NSString *const kSRSoundFileName = @"kSRSoundFileName";


#import "SoundRange.h"

@implementation SoundRange
{
    NSString *_soundFileName;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _soundFileName = [coder decodeObjectForKey:kSRSoundFileName];

        _timeRange = [coder decodeCMTimeRangeForKey:kSRTimeRange];
//        _soundTrack = [coder decodeObjectForKey:kSRSoundTrack];
        _recordSession = [coder decodeObjectForKey:kSRRecordSession];
        _cropTimeRange = [coder decodeCMTimeRangeForKey:kSRCropTimeRange];
        _color = [coder decodeObjectForKey:kSRColor];
        
//        self.soundFileURL = [coder decodeObjectForKey:kSRSoundFileURL];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeCMTimeRange:_timeRange forKey:kSRTimeRange];
    [coder encodeObject:_soundFileURL.lastPathComponent forKey:kSRSoundFileName];
//    [coder encodeObject:_soundTrack forKey:kSRSoundTrack];
    [coder encodeObject:_recordSession forKey:kSRRecordSession];
    [coder encodeCMTimeRange:_cropTimeRange forKey:kSRCropTimeRange];
    [coder encodeObject:_color forKey:kSRColor];
}

///////////////////
#pragma mark - get & set

-(void)setEncodingDirectoryURL:(NSURL *)encodingDirectoryURL {
    _encodingDirectoryURL = encodingDirectoryURL;
    
    if (_soundFileName)
        _soundFileURL = [_encodingDirectoryURL URLByAppendingPathComponent:_soundFileName];
    
}

-(BOOL)isCropped {
    return CMTIME_IS_VALID(_cropTimeRange.duration) && CMTimeCompare(_timeRange.duration, _cropTimeRange.duration) != 0;
}


///////////////////
#pragma mark - funcs

-(void)removeFromRecordSession {
    [_recordSession removeSoundRange:self];
}

@end
