//
//  PerformanceArea.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/23/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PerformanceAreaTypeSteps,
    PerformanceAreaTypeCar,
    PerformanceAreaTypeRain
}PerformanceAreaType;


extern NSString *const kPmATierName;
extern NSString *const kPmATierThumbNail;
extern NSString *const kPmATierBigImage;

@class PerformanceArea;

@protocol PerformanceAreaDelegate <NSObject>

@optional

-(void) performanceArea:(PerformanceArea*)performanceArea didSelectSoundURL:(NSURL*)soundURL atTime:(CMTime)cmTime color:(UIColor*)color;

@end



@interface PerformanceArea : UIView
{
    NSString *_pathOfImages, *_pathOfSounds;
}

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) PerformanceAreaType typeArea;
@property (strong, nonatomic) UIImage *titleImage;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSURL *soundsURL;
@property (strong, nonatomic) NSURL *imagesURL;

@property (strong, nonatomic) NSURL *selectedSoundURL;

@property (strong, readonly, nonatomic) NSDictionary *contentDictionary;

// array of arrays - optionals of sounds
@property (strong, readonly, nonatomic) NSArray *tiers;

@property (strong,nonatomic) NSDictionary *settings;


@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;

@property (weak, nonatomic) id<PerformanceAreaDelegate> delegate;

// load data defining sounds
-(void)loadPlistURL:(NSURL*)plistURL;
-(void)loadEmbeddedAreaName:(NSString*)plistName;


-(NSURL*)urlOfImageFile:(NSString*)imageFileName;
-(NSURL*)urlOfThumbNailInTier:(NSUInteger)tierIndex index:(NSUInteger)index;
-(UIImage*)imageOfFileName:(NSString*)fileName;

-(NSURL*)urlOfSoundFile:(NSString*)soundFileName;

// sound file url selected by sequence of indexes from rows of tiers
-(NSURL*)urlOfSoundFileAtIndexes:(NSUInteger)index, ...;

// save settings

-(NSDictionary*)saveSettings;

+(Class)performanceAreaWithType:(PerformanceAreaType)type;
+(instancetype) makeFromXibWithAreaName:(NSString*)areaName;
+(instancetype) makeFromXibWithAreaName:(NSString*)areaName withSettings:(NSDictionary*)settings;

@end
