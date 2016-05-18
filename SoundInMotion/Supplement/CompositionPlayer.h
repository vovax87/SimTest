//
//  CompositionPlayer.h
//  SoundInMotion
//
//  Created by Konstianm on 05/04/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CompositionPlayer : NSObject

@property (strong, nonatomic) AVPlayer *videoPlayer;
@property (strong, nonatomic) AVPlayer *audioCompositionPlayer;

@property (strong, nonatomic) NSURL *videoURL;
@property (readonly, nonatomic) BOOL isPlaying;
@property (readonly, nonatomic) CMTime duration;
@property (readonly, nonatomic) float nominalFrameRate;

-(void)stepBackAtRewindRange:(float)rewindRange;
-(void)stepForwardAtRewindRange:(float)rewindRange;
-(void)goToStart;
-(void)seekToTime:(CMTime)time;
-(void)pause;
-(void)play;

//-(void)replaceAudioComposition:(AVMutableComposition*)compositionAsset;
-(void)composedTracksWithSoundEdition:(MovieSoundEdition*)soundEdition;



+(instancetype)sharedCompositionPlayer;

@end
