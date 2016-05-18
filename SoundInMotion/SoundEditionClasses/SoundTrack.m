//
//  SoundTrack.m
//  SoundInMotion
//
//  Created by Konstianm on 26/03/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

static NSString *kSTSoundRanges             = @"kSTSoundRanges";
static NSString *kSTRecordSessions          = @"kSTRecordSessions";
static NSString *kSTVolume                  = @"kSTVolume";
static NSString *kSTIsMute                  = @"kSTIsMute";
static NSString *kSTPerformanceAreaImageURL = @"kSTPerformanceAreaImageURL";
static NSString *kSTPerformanceAreaType     = @"kSTPerformanceAreaType";
static NSString *kSTMovieSoundEdition       = @"kSTMovieSoundEdition";
static NSString *kSTSettingsPerformanceArea = @"kSTSettingsPerformanceArea";


#import "SoundTrack.h"

@implementation SoundTrack

- (instancetype)init
{
    self = [super init];
    if (self) {
        _recordSessions = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        NSArray *array = [coder decodeObjectForKey:kSTRecordSessions];
//        _soundRanges = [NSMutableArray arrayWithArray:array];
        _recordSessions = [NSMutableArray arrayWithArray:array];
        _volume = [coder decodeDoubleForKey:kSTVolume];
        _isMute = [coder decodeBoolForKey:kSTIsMute];
        _performanceAreaType = [coder decodeIntegerForKey:kSTPerformanceAreaType];
        _performanceAreaImageURL = [coder decodeObjectForKey:kSTPerformanceAreaImageURL];
        _movieSoundEdition = [coder decodeObjectForKey:kSTMovieSoundEdition];
        _settingsPerfomanceArea = [coder decodeObjectForKey:kSTSettingsPerformanceArea];
        
        [self sortRecordSessions];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
//    [super encodeWithCoder:coder];
//    [coder encodeObject:_soundRanges forKey:kSTSoundRanges];
    [coder encodeObject:_recordSessions forKey:kSTRecordSessions];
    [coder encodeDouble:_volume forKey:kSTVolume];
    [coder encodeBool:_isMute forKey:kSTIsMute];
    [coder encodeObject:_performanceAreaImageURL forKey:kSTPerformanceAreaImageURL];
    [coder encodeInteger:_performanceAreaType forKey:kSTPerformanceAreaType];
    [coder encodeObject:_movieSoundEdition forKey:kSTMovieSoundEdition];
    [coder encodeObject:_settingsPerfomanceArea forKey:kSTSettingsPerformanceArea];
}


///////////////////
#pragma mark - get & set

-(void)setEncodingDirectoryURL:(NSURL *)encodingDirectoryURL {
    _encodingDirectoryURL = encodingDirectoryURL;
    
       for (RecordSession *rs in _recordSessions)
        rs.encodingDirectoryURL = encodingDirectoryURL;
}



///////////
#pragma mark - funcs

-(RecordSession*)createRecordSession {
    RecordSession *recSess = [RecordSession new];
    recSess.encodingDirectoryURL = self.encodingDirectoryURL;
    recSess.soundTrack = self;
    recSess.timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero, kCMTimeZero);
    return recSess;
}

-(void) addRecordSession:(RecordSession*)item {
    [_recordSessions addObject:item];
    [self sortRecordSessions];
}

-(void)sortRecordSessions
{
    [_recordSessions sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return CMTimeCompare(((RecordSession*)obj1).timeRange.start, ((RecordSession*)obj2).timeRange.start);
    }];
}

-(void)removeRecordSession:(RecordSession*)item {
    [_recordSessions removeObject:item];
}




//-(void) addSoundRange:(SoundRange*)range {
//    [_soundRanges addObject:range];
//}

//-(SoundRange*) addSoundFileURL:(NSURL*)soundFileURL atPosition:(CMTime)cmtimePosition
//{
//    SoundRange *range = nil;
//    
//    if (_encodingDirectoryURL)
//    {
//        NSFileManager *fm = [NSFileManager defaultManager];
//        NSURL *destURL = [_encodingDirectoryURL URLByAppendingPathComponent:soundFileURL.lastPathComponent];
//        NSError * __autoreleasing error;
//        
//        BOOL isFileExist = [fm fileExistsAtPath:destURL.path];
//        if (!isFileExist)
//            isFileExist = [fm copyItemAtURL:soundFileURL toURL:destURL error:&error];
//        
//        if (isFileExist)
//        {
//            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:destURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
//            if (asset)
//            {
//                range = [SoundRange new];
//                range.timeRange = CMTimeRangeMake(cmtimePosition, asset.duration);
//                range.cropTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
//                range.soundFileURL = destURL;
//                range.soundTrack = self;
//                range.encodingDirectoryURL = _encodingDirectoryURL;
//                
//                [_soundRanges addObject:range];
//                
//                [self sortSoundRanges];
//                _movieSoundEdition.changed = YES;
//            }
//        }
//        else
//        {
//            ShowErrorAlert(error);
//        }
//    }
//    return range;
//}

//-(void)sortSoundRanges
//{
//    [_soundRanges sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        return CMTimeCompare(((SoundRange*)obj1).timeRange.start, ((SoundRange*)obj2).timeRange.start);
//    }];
//}
//
//-(void) removeSoundRange:(SoundRange*)soundRange {
//    [_soundRanges removeObject:soundRange];
//}

//-(void) removeSoundRangeAtTimePosition:(CMTime)timePosition
//{
//    NSUInteger ind = [_soundRanges indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        return CMTimeCompare(((SoundRange*)obj).timeRange.start, timePosition) == 0;
//    }];
//    
//    if (ind != NSNotFound) {
//        [_soundRanges removeObjectAtIndex:ind];
//    }
//}


@end
