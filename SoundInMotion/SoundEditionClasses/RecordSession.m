//
//  RecordSession.m
//  SoundInMotion
//
//  Created by Konstianm on 26/04/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

static NSString *kRSTimeRange = @"kRSTimeRange";
static NSString *kRSSoundRanges = @"kRSSoundRanges";
static NSString *kRSVolume = @"kRSVolume";
static NSString *kRSSoundTrack = @"kRSSoundTrack";


#import "RecordSession.h"

@implementation RecordSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        _soundRanges = [NSMutableArray array];
    }
    return self;
}



- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _timeRange = [coder decodeCMTimeRangeForKey:kRSTimeRange];
        NSArray *array = [coder decodeObjectForKey:kRSSoundRanges];
        _soundRanges = [NSMutableArray arrayWithArray:array];
        _volume = [coder decodeDoubleForKey:kRSVolume];
        _soundTrack = [coder decodeObjectForKey:kRSSoundTrack];
        
        [self sortSoundRanges];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeCMTimeRange:_timeRange forKey:kRSTimeRange];
    [coder encodeObject:_soundRanges forKey:kRSSoundRanges];
    [coder encodeDouble:_volume forKey:kRSVolume];
    [coder encodeObject:_soundTrack forKey:kRSSoundTrack];
    
}


///////////////////
#pragma mark - get & set

-(void)setEncodingDirectoryURL:(NSURL *)encodingDirectoryURL {
    _encodingDirectoryURL = encodingDirectoryURL;
    
    for (SoundRange *sr in _soundRanges)
        sr.encodingDirectoryURL = encodingDirectoryURL;
}

//-(BOOL)isCropped {
//    return CMTIME_IS_VALID(_cropTimeRange.duration) && CMTimeCompare(_timeRange.duration, _cropTimeRange.duration) != 0;
//}

///////////
#pragma mark - funcs

-(void) addSoundRange:(SoundRange*)range {
    [_soundRanges addObject:range];
}

-(SoundRange*) addSoundFileURL:(NSURL*)soundFileURL atPosition:(CMTime)cmtimePosition
{
    SoundRange *range = nil;
    
    if (_encodingDirectoryURL)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *destURL = [_encodingDirectoryURL URLByAppendingPathComponent:soundFileURL.lastPathComponent];
        NSError * __autoreleasing error;
        
        BOOL isFileExist = [fm fileExistsAtPath:destURL.path];
        if (!isFileExist)
            isFileExist = [fm copyItemAtURL:soundFileURL toURL:destURL error:&error];
        
        if (isFileExist)
        {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:destURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
            if (asset)
            {
                range = [SoundRange new];
                range.timeRange = CMTimeRangeMake(cmtimePosition, asset.duration);
                range.cropTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
                range.soundFileURL = destURL;
                range.recordSession = self;
                range.encodingDirectoryURL = _encodingDirectoryURL;
                
                [_soundRanges addObject:range];
                
                [self sortSoundRanges];
                _soundTrack.isChanged = YES;
            }
        }
        else
        {
            ShowErrorAlert(error);
        }
    }
    return range;
}

-(void)sortSoundRanges
{
    [_soundRanges sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        SoundRange *object1 = (SoundRange*)obj1;
        SoundRange *object2 = (SoundRange*)obj2;
                if(object1.isCropped && object2.isCropped) {
                    return CMTimeCompare(object1.cropTimeRange.start, object2.cropTimeRange.start);
                } else if (object1.isCropped) {
                    return CMTimeCompare(object1.cropTimeRange.start, object2.timeRange.start);
                } else if (object2.isCropped){
                    return CMTimeCompare(object1.timeRange.start, object2.cropTimeRange.start);
                } else {
        return CMTimeCompare(object1.timeRange.start, object2.timeRange.start);
                }
    }];
}

-(void) removeSoundRange:(SoundRange*)soundRange {
    [_soundRanges removeObject:soundRange];
}

-(void) removeSoundRangeAtTimePosition:(CMTime)timePosition
{
    NSUInteger ind = [_soundRanges indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return CMTimeCompare(((SoundRange*)obj).timeRange.start, timePosition) == 0;
    }];
    
    if (ind != NSNotFound) {
        [_soundRanges removeObjectAtIndex:ind];
    }
}

#pragma mark - funcs

-(void)removeFromSoundTrack {
    [_soundTrack removeRecordSession:self];
}


@end
