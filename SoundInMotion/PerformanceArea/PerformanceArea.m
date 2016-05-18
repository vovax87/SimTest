//
//  PerformanceArea.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/23/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "PerformanceArea.h"
#import "PerformanceAreaCar.h"
#import "PerformanceAreaStep.h"
#import "PerformanceAreaRain.h"
#import "UIView+MakeFromXib.h"

NSString *const kPmATierName       = @"name";
NSString *const kPmATierThumbNail  = @"thumbNail";
NSString *const kPmATierBigImage   = @"bigImage";



static NSString *const plistFileName            = @"soundform.plist";
static NSString *const subDirectorySoundsForms   = @"SoundsForms";
static NSString *const subDirectoryImages       = @"images";
static NSString *const subDirectorySounds       = @"sounds";


@implementation PerformanceArea
{
    NSDictionary *_soundsDictionary;
}

#pragma mark - init


////////////////////////
#pragma mark - funcs

-(void)loadPlistURL:(NSURL*)plistURL
{
    _baseURL = plistURL;
    NSURL *filePlistURL = [_baseURL URLByAppendingPathComponent:plistFileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:plistURL.path])
    {
        _contentDictionary = [NSDictionary dictionaryWithContentsOfURL:filePlistURL];
        _tiers = _contentDictionary[@"tiers"];
        _soundsDictionary = _contentDictionary[@"sounds"];
        _typeArea = (PerformanceAreaType)[((NSNumber*)_contentDictionary[@"type"]) integerValue];
        _title = _contentDictionary[@"title"];
        _titleImage = [self imageOfFileName:_contentDictionary[@"titleImage"]];
        
        _soundsURL = [_baseURL URLByAppendingPathComponent:subDirectorySounds isDirectory:YES];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDirecrory = NO;

        if (![fm fileExistsAtPath:_soundsURL.path isDirectory:&isDirecrory] || !isDirecrory) {
            ShowAlert(@"This form does not have subdirectory \"sounds\"");
            _soundsURL = nil;
        }
        
        _imagesURL = [_baseURL URLByAppendingPathComponent:subDirectoryImages isDirectory:YES];
        
        if (![fm fileExistsAtPath:_imagesURL.path isDirectory:&isDirecrory] || !isDirecrory) {
            ShowAlert(@"This form does not have subdirectory \"images\"");
            _imagesURL = nil;
        }
    };
}

-(void)loadEmbeddedAreaName:(NSString*)plistName
{
    NSURL *formURL = [[NSBundle mainBundle] URLForResource:plistName withExtension:nil subdirectory:subDirectorySoundsForms];
    if (formURL) {
        _pathOfImages = [NSString pathWithComponents:@[subDirectorySoundsForms, plistName, subDirectoryImages]];
        _pathOfSounds = [NSString pathWithComponents:@[subDirectorySoundsForms, plistName, subDirectorySounds]];
        [self loadPlistURL:formURL];
    }
}

-(NSURL*)urlOfImageFile:(NSString*)imageFileName
{
    if (imageFileName.length == 0)
        return nil;
    
    NSURL *resURL = [_baseURL URLByAppendingPathComponent:subDirectoryImages isDirectory:YES];
    resURL = [resURL URLByAppendingPathComponent:imageFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:resURL.path])
        return resURL;
    
    return nil;
}

-(NSURL*)urlOfSoundFile:(NSString*)soundFileName
{
    if (soundFileName.length == 0)
        return nil;
    
    NSURL *resURL = [_baseURL URLByAppendingPathComponent:subDirectorySounds isDirectory:YES];
    resURL = [resURL URLByAppendingPathComponent:soundFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:resURL.path])
        return resURL;
    
    return nil;
}


-(NSURL*)urlOfThumbNailInTier:(NSUInteger)tierIndex index:(NSUInteger)index
{
    if (tierIndex < _tiers.count && index < ((NSArray*)_tiers[tierIndex]).count)
    {
        NSString *fileName = _tiers[tierIndex][index][kPmATierThumbNail];
        return [self urlOfImageFile:fileName];
    }
    
    return nil;
}

-(UIImage*)imageOfFileName:(NSString*)fileName
{
    NSURL *imgURL = [self urlOfImageFile:fileName];
    if (imgURL)
        return [UIImage imageWithContentsOfFile:imgURL.path];
    
    return nil;
}


-(NSURL*)urlOfSoundFileAtIndexes:(NSUInteger)index, ...
{
    va_list args;
    va_start(args, index);
    
    id currenLevelObj = _soundsDictionary;
    
//    for(int i=0, ind = index; i<_tiers.count; i++, ind = va_arg(args, NSUInteger))
//    {
////        NSUInteger ind = va_arg(args, NSUInteger);
//        NSDictionary *elementDict =  _tiers[i][ind];
//        NSString *key = elementDict[kPmATierName];
//        
//        currenLevelObj = ((NSDictionary*)currenLevelObj)[key];
//    }
    
    va_end(args);
    
//    if ([currenLevelObj isKindOfClass:[NSString class]])
//    {
//        return [self urlOfSoundFile:currenLevelObj];
//    }
    return nil;
}


/////////////
#pragma mark - class methods

+(Class)performanceAreaWithType:(PerformanceAreaType)type{
    switch (type) {
        case PerformanceAreaTypeCar:
            return [PerformanceAreaCar class];
            break;
        case PerformanceAreaTypeRain:
            return [PerformanceAreaRain class];
            break;
        case PerformanceAreaTypeSteps:
            return [PerformanceAreaStep class];
            break;
        default:
            return nil;
            break;
    }
}

+(instancetype) makeFromXibWithAreaName:(NSString*)areaName withSettings:(NSDictionary*)settings
{
    PerformanceArea *pma = [self makeFromXib];
    if (settings) {
        pma.settings = settings;
    }
    [pma loadEmbeddedAreaName:areaName];
    return pma;
}


@end
