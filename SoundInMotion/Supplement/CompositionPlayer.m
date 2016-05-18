//
//  CompositionPlayer.m
//  SoundInMotion
//
//  Created by Konstianm on 05/04/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "CompositionPlayer.h"

@implementation CompositionPlayer
{
    AVAssetTrack *_mainAudioAssetTrack;
    AVAssetTrack *_mainVideoAssetTrack;
    
    CMTimeRange _mainTimeRange;
    
}



- (instancetype)init
{
    self = [super init];
    if (self) {
        _videoPlayer = [[AVPlayer alloc] init];
        _audioCompositionPlayer = [[AVPlayer alloc] init];
        _duration = kCMTimeZero;

    }
    return self;
}

////////////////////////////////////
#pragma mark - get & set

-(void)setVideoURL:(NSURL *)videoURL
{
    if (!_videoPlayer)
        return;
    
//    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:videoURL];
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
    _duration = asset.duration;
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [_videoPlayer replaceCurrentItemWithPlayerItem:item];

    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    _mainVideoAssetTrack = videoTracks.firstObject;
    _nominalFrameRate = _mainVideoAssetTrack.nominalFrameRate;
}


-(BOOL)isPlaying {
    return _videoPlayer.rate != 0.0;
}

////////////////////////////////////
#pragma mark - funcs

-(void)stepBackAtRewindRange:(float)rewindRange
{
    CMTime currentTime = _videoPlayer.currentTime;
    if (currentTime.timescale == 1) {
        currentTime = CMTimeMake(currentTime.value * 100000000, 100000000);
    }
    CMTime newTime = CMTimeMake(currentTime.value - rewindRange/_nominalFrameRate * currentTime.timescale,
                                currentTime.timescale);
    [self seekToTime:newTime];
}

-(void)stepForwardAtRewindRange:(float)rewindRange
{
    CMTime currentTime = _videoPlayer.currentTime;
    if (currentTime.timescale == 1) {
        currentTime = CMTimeMake(currentTime.value * 100000000, 100000000);
    }
    CMTime newTime = CMTimeMake(currentTime.value + rewindRange/_nominalFrameRate * currentTime.timescale,
                                currentTime.timescale);
    if (CMTimeCompare(newTime, _videoPlayer.currentItem.duration) == 1  ) {
        newTime = _videoPlayer.currentItem.duration;
    }
    [self seekToTime:newTime];
}

-(void)goToStart
{
    [_videoPlayer seekToTime:kCMTimeZero];
    [_audioCompositionPlayer seekToTime:kCMTimeZero];
}

-(void)seekToTime:(CMTime)time
{
    [_videoPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [_audioCompositionPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


-(void)pause
{
    [_videoPlayer pause];
    [_audioCompositionPlayer pause];
}

-(void)play
{
    [_videoPlayer play];
    [_audioCompositionPlayer play];
}

-(void)replaceAudioComposition:(AVMutableComposition*)compositionAsset
{
//     NSError * __autoreleasing error;
//    AVMutableCompositionTrack *audioMainTrack = [compositionAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    [audioMainTrack insertTimeRange:_mainAudioAssetTrack.timeRange ofTrack:_mainAudioAssetTrack atTime:kCMTimeZero error:&error];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:compositionAsset];
    [_audioCompositionPlayer replaceCurrentItemWithPlayerItem:item];
    
    [_audioCompositionPlayer seekToTime:_videoPlayer.currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)composedTracksWithSoundEdition:(MovieSoundEdition*)soundEdition
{
    NSError * __autoreleasing error;
    
    AVMutableComposition *compositionAsset = [AVMutableComposition composition];
    
    for (SoundTrack *strack in soundEdition.tracks)
    {
        if (strack.recordSessions.count)
        {
            
            for (RecordSession *rsessions in strack.recordSessions)
            {
                if (rsessions.soundRanges.count)
                {
                    CMTime sesssionStart = rsessions.timeRange.start;
                    
                    AVMutableCompositionTrack *mutableTrack = [compositionAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                    
                    for (SoundRange *srange in rsessions.soundRanges)
                    {
                        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:srange.soundFileURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
                        NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
                        
                        if (audioTracks.count) {
                            AVAssetTrack *assetTrack = audioTracks[0];
                            
                            CMTimeRange insertRange = assetTrack.timeRange;
                            CMTime start = CMTimeAdd(sesssionStart, srange.timeRange.start);
                            
                            if (srange.isCropped) {
                                insertRange = srange.cropTimeRange;
                                CMTimeAdd(start, srange.cropTimeRange.start);
                            }
                            
                            
                            [mutableTrack insertTimeRange:insertRange ofTrack:assetTrack atTime:start error:&error];
                        }
                    }
                }
            }
        }
        
        
    }
    
//        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:compositionAsset];
    
    //    [videoPlayerGlobal replaceCurrentItemWithPlayerItem:playerItem];
    [self replaceAudioComposition:compositionAsset];
}



////////////////////////////////////
#pragma mark - class methods

+(instancetype)sharedCompositionPlayer
{
    static CompositionPlayer *_compositionPlayer;
    
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _compositionPlayer = [[CompositionPlayer alloc] init];
            
        });
    
    return _compositionPlayer;

}


@end
