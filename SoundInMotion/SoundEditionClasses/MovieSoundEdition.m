//
//  MovieSoundEdition.m
//  SoundInMotion
//
//  Created by Konstianm on 25/03/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

static NSString *kMSERoot               = @"kMSERoot";
static NSString *kMSEName               = @"kMSEName";
static NSString *kMSEsoundNameCounter   = @"kMSEsoundNameCounter";
static NSString *kMSEtracks             = @"kMSEtracks";
static NSString *kMSEflags              = @"kMSEflags";
static NSString *kMSEVideoFile          = @"kMSEVideoFile";

static NSString *encodedDataFileName = @"MovieSounds.plist";


#import "MovieSoundEdition.h"

@implementation MovieSoundEdition
{
    NSUInteger _soundNameCounter;
    NSString *_videoFileName;
    dispatch_queue_t _queueArchiving;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _soundNameCounter = 0;
        _tracks = [NSMutableArray array];
        _flags = [NSMutableArray array];
        _videoDuration = CMTimeMake(0, 0);

        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:kMSEName];
        _soundNameCounter = [coder decodeIntegerForKey:kMSEsoundNameCounter];
        _tracks = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:kMSEtracks]];
        _flags = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:kMSEflags]];
        _videoFileName = [coder decodeObjectForKey:kMSEVideoFile];
        
        _videoDuration = CMTimeMake(0, 0);

        [self commonInit];
    }
    
    return self;
}

-(void)setupVideoURL
{
    if (_encodingDirectoryURL && _videoFileName) {
        _videoURL = [_encodingDirectoryURL URLByAppendingPathComponent:_videoFileName];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_videoURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
        _videoDuration = asset.duration;
    }
}

-(void)commonInit
{
    [self setupVideoURL];
    _queueArchiving = dispatch_queue_create("MovieSoundEdition_queueArchiving", DISPATCH_QUEUE_SERIAL);
    _changed = NO;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
//    if ([super respondsToSelector:@selector(encodeObject:forKey:)])
//        [super encodeWithCoder:coder];
    
    [coder encodeObject:_name forKey:kMSEName];
    [coder encodeInteger:_soundNameCounter forKey:kMSEsoundNameCounter];
    [coder encodeObject:_tracks forKey:kMSEtracks];
    [coder encodeObject:_flags forKey:kMSEflags];
    [coder encodeObject:_videoURL.lastPathComponent forKey:kMSEVideoFile];
}



///////////////////
#pragma mark - get & set

-(void)setEncodingDirectoryURL:(NSURL *)encodingDirectoryURL {
    _encodingDirectoryURL = encodingDirectoryURL;
    
    [self setupVideoURL];
    
    for (SoundTrack *st in _tracks)
        st.encodingDirectoryURL = encodingDirectoryURL;
}

-(void)setVideoURL:(NSURL *)videoURL
{
    if ([videoURL.scheme isEqualToString:@"assets-library"]) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
        _videoURL = videoURL;
        _videoDuration = asset.duration;
        return;
    }
//         assets-library://asset/asset.mov?id=568C312C-661B-4780-B63E-67C8F899667A&ext=mov
    if (_encodingDirectoryURL)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *lastComponent = videoURL.lastPathComponent;
        NSURL *destURL = [_encodingDirectoryURL URLByAppendingPathComponent:lastComponent];
        NSError * __autoreleasing error;
        
        BOOL isFileExist = [fm fileExistsAtPath:destURL.path];
        if (!isFileExist)
            isFileExist = [fm copyItemAtURL:videoURL toURL:destURL error:&error];
        
        if (isFileExist)
        {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:destURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
            _videoURL = destURL;
            _videoDuration = asset.duration;
            _videoFileName = _videoURL.lastPathComponent;
    
        }
        else
        {
            ShowErrorAlert(error);
        }
    }

}




///////////////////
#pragma mark - funcs

-(void) save
{
    if (!self.encodingDirectoryURL.path.length)
        return;

    UIBackgroundTaskIdentifier __block bgArchivingIdent = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgArchivingIdent];
        bgArchivingIdent = UIBackgroundTaskInvalid;
    }];
    
    
        NSURL *encodingFileURL = [self.encodingDirectoryURL URLByAppendingPathComponent:encodedDataFileName];
        NSMutableData *encdedData = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:encdedData];
        [archiver encodeObject:self forKey:kMSERoot];
        [archiver finishEncoding];
        
        [encdedData writeToURL:encodingFileURL atomically:YES];
    
    if (bgArchivingIdent != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgArchivingIdent];
        bgArchivingIdent = UIBackgroundTaskInvalid;
        _changed = NO;
    }
}


-(SoundTrack*) createSoundTrack
{
    SoundTrack *soundTrack = [SoundTrack new];
    soundTrack.encodingDirectoryURL = self.encodingDirectoryURL;
    soundTrack.movieSoundEdition = self;
    return soundTrack;
}

-(void)removeSoundTrack:(SoundTrack*)soundTrack
{
    [_tracks removeObject:soundTrack];
}

///////////////////
#pragma mark - class methods

+(void) saveObject:(MovieSoundEdition*)movieSoundEdition
{
    if (!movieSoundEdition.encodingDirectoryURL.path.length)
        return;
    
    NSURL *encURL = [movieSoundEdition.encodingDirectoryURL URLByAppendingPathComponent:encodedDataFileName];
    NSMutableData *encdedData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:encdedData];
    [archiver encodeObject:movieSoundEdition forKey:kMSERoot];
    [archiver finishEncoding];
    
    [encdedData writeToURL:encURL atomically:YES];
    
}


+(instancetype) loadObjectFromURL:(NSURL*)encodedDataURL
{
    NSData *encodedData = [NSData dataWithContentsOfURL:[encodedDataURL URLByAppendingPathComponent:encodedDataFileName]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:encodedData];
    MovieSoundEdition *edition = [unarchiver decodeObjectForKey:kMSERoot];
    [unarchiver finishDecoding];
    
    edition.encodingDirectoryURL = encodedDataURL;
    return edition;
}


@end
