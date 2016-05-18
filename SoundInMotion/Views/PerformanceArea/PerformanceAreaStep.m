//
//  PerformanceAreaStep.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/24/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "PerformanceAreaStep.h"
#import "PerfomanceAreaStepGraphicFX.h"
#import <AVFoundation/AVFoundation.h>
#import "CompositionPlayer.h"

static NSString *const keyMovingTypeScuff = @"scuff";

@interface PerformanceAreaStep () <AVAudioPlayerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageviewFloor;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *subClassButton;
@property (weak, nonatomic) IBOutlet UIScrollView *level1ScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *level2ScrollView;
@property (weak, nonatomic) IBOutlet PerfomanceAreaStepGraphicFX *graphicFXImage;

@property (weak, nonatomic) IBOutlet UIView *viewWithGallery;
@property (weak, nonatomic) IBOutlet UIView *viewWithFilters;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStairsWidth;

- (IBAction)actionMovingTypeTapped:(UITapGestureRecognizer *)sender;

@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGestureScuff;
- (IBAction)actionScuff:(UISwipeGestureRecognizer *)sender;

@end



@implementation PerformanceAreaStep
{
    NSUInteger _selectedIndexes[2];
    NSArray *_levelScrollsArray;
    NSDictionary *_soundsDictLevel0, *_soundsDictLevel2;
    CGFloat _savedConstraintStairWidthConstant;
    NSMutableArray *_playersArray;
    CMTime _soundTime;
    NSString *_lastSoundName;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    _playersArray = [NSMutableArray new];
    [self tapToSubclass:self.subClassButton];
    _selectedIndexes[0] = _selectedIndexes[1] = 0;
    _levelScrollsArray = @[_level1ScrollView, _level2ScrollView];
    _savedConstraintStairWidthConstant = _constraintStairsWidth.constant;
    
    _swipeGestureScuff.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
}



-(void)layoutSubviews
{
   
    if ( _level1ScrollView.contentSize.width) {
        CGFloat shift = _level1ScrollView.frame.size.width -  _level1ScrollView.contentSize.width;
        if (shift > 2.0)
            _level1ScrollView.contentInset = UIEdgeInsetsMake(0, floor(shift/2), 0, 0);
        else
            _level1ScrollView.contentInset = UIEdgeInsetsZero;
    }
    
    
    if (_level2ScrollView.contentSize.width) {
        CGFloat shift = _level2ScrollView.frame.size.width -  _level2ScrollView.contentSize.width;
        if (shift > 2.0)
            _level2ScrollView.contentInset = UIEdgeInsetsMake(0, floor(shift/2), 0, 0);
        else
            _level2ScrollView.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark - Setter's

-(void)setSettings:(NSDictionary *)settings{
    [super setSettings:settings];
    _selectedIndexes[1] = [[settings valueForKey:@"index1"] integerValue];
    _selectedIndexes[0] = [[settings valueForKey:@"index2"] integerValue];
}


//////////////////////////////
#pragma mark - funcs

-(NSDictionary *)saveSettings{
    /////////// Индексы наброт стоят!
    NSNumber *index1 = [NSNumber numberWithInteger:_selectedIndexes[1]];
    NSNumber *index2 = [NSNumber numberWithInteger:_selectedIndexes[0]];
    NSDictionary *settings = @{@"index1": index1,
                               @"index2": index2};
    return settings;
}

-(void)loadEmbeddedAreaName:(NSString *)plistName
{
    [super loadEmbeddedAreaName:plistName];
    
    if (self.tiers.count < 3) {
        ShowAlert(@"The number of tiers arrays is not equals 3");
        return;
    }
    
    if (self.soundsURL == nil || self.imagesURL == nil)
        return;

    _soundsDictLevel0 = self.contentDictionary[@"sounds"];

    [self fillLevelScrollView:_level1ScrollView fromTierIndex:0];
    [self fillLevelScrollView:_level2ScrollView fromTierIndex:1];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self selectImageView:[self imageviewInView:_level1ScrollView atIndex:_selectedIndexes[0]] doSelect:YES];
    [self selectImageView:[self imageviewInView:_level2ScrollView atIndex:_selectedIndexes[1]] doSelect:YES];
    [self extractDictAtGalleriesSelection];
    
}


-(void) fillLevelScrollView:(UIScrollView*)levelScrollView fromTierIndex:(NSInteger)tierIndex
{
    if (levelScrollView == nil || tierIndex >= self.tiers.count)
        return;
    
    
    NSArray *tierLevel = self.tiers[tierIndex];
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (NSDictionary *dict in tierLevel)
    {
        UIImage *img = [self imageOfFileName:dict[kPmATierThumbNail]];
        if (img)
            [imagesArray addObject:img];
    }
    
    CGFloat x = 4.0;
    CGFloat imgSide = levelScrollView.frame.size.height - 4.0;
    CGRect imgFrame = CGRectMake(x, 2.0, imgSide, imgSide);
    
    
    NSUInteger imageIndex = 0;
    for (UIImage *img in imagesArray)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgFrame];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = img;


        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionLevelImageTaped:)];
        [imgView addGestureRecognizer:tap];
        imgView.userInteractionEnabled = YES;
        
        CALayer *layer = imgView.layer;
        //    layer.cornerRadius = 8.0;
        layer.borderWidth = 0;
        layer.borderColor = [UIColor cyanColor].CGColor;
        layer.masksToBounds = YES;
        
        imgView.tag = imageIndex++;

        [levelScrollView addSubview:imgView];
        
        // for next circle iteration
        x += imgSide + 4.0;
        imgFrame.origin.x = x;
        
    }
    
    [levelScrollView setContentSize:CGSizeMake(x, levelScrollView.frame.size.height)];
}


-(UIImageView*) imageviewInView:(UIView*)view atIndex:(NSUInteger)index
{
    if (index >= view.subviews.count)
        return nil;
    
    NSUInteger ind = 0;
    for(UIImageView *imgView in view.subviews) {
        if ([imgView isKindOfClass:[UIImageView class]]) {
            if (ind == index)
                return imgView;
            
            ind++;
        }
    }
    return nil;
}

-(NSUInteger) indexInView:(UIView*)view ofImageView:(UIImageView*)imageview
{
    if (imageview == nil)
        return NSNotFound;
    
    NSUInteger ind = 0;
    
    for(UIImageView *imgView in view.subviews) {
        if ([imgView isKindOfClass:[UIImageView class]]) {
            if (imgView == imageview)
                return ind;
            
            ind++;
        }
    }
    return NSNotFound;
}

-(void)selectImageView:(UIView*)view doSelect:(BOOL)doSelect
{
    view.layer.borderWidth = doSelect? 2:0;
}


-(void)extractDictAtGalleriesSelection
{
    NSString *key1 = self.tiers[0][_selectedIndexes[0]][kPmATierName];
    NSString *key2 = self.tiers[1][_selectedIndexes[1]][kPmATierName];
    
    _soundsDictLevel2 = _soundsDictLevel0[key1][key2];
    
    // check if stair sounds are presented
    NSString *stairsSet = _soundsDictLevel2[self.tiers[2][0][kPmATierName]];
    if (!stairsSet.length && _constraintStairsWidth.constant) {
        _constraintStairsWidth.constant = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
    else if (stairsSet.length && !_constraintStairsWidth.constant) {
        _constraintStairsWidth.constant = _savedConstraintStairWidthConstant;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
    
    
    // floor/ground image
    NSString *bigImageName = self.tiers[0][_selectedIndexes[0]][kPmATierBigImage];
    UIImage *img = nil;
    
    if (bigImageName.length) {
        img = [self imageOfFileName:bigImageName];
    }
    _imageviewFloor.image = img;

}

-(void)selectSoundByMovingType:(NSString*)keyMovingType
{
    NSString *dirName = _soundsDictLevel2[keyMovingType];
    if (dirName.length)
    {
        NSString *setSoundsPath = [NSString pathWithComponents:@[self->_pathOfSounds, dirName]];
        NSArray *list =  [[NSBundle mainBundle] URLsForResourcesWithExtension:nil subdirectory:setSoundsPath];
        
        if (list.count) {
            NSUInteger ind = arc4random() % list.count;
            NSURL *selectedSoundURL = list[ind];
            while ([selectedSoundURL.lastPathComponent isEqualToString:_lastSoundName] && list.count > 1) {
                ind = arc4random() % list.count;
                selectedSoundURL = list[ind];
            }
            _lastSoundName = selectedSoundURL.lastPathComponent;
            NSLog(@"selectedSound: %@", selectedSoundURL.lastPathComponent);
            
            __autoreleasing NSError *error;
             AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:selectedSoundURL error:&error];
            [_playersArray addObject:player];
            player.delegate = self;
            [player play];
            
            //                            self.selectedSoundURL = soundURL;
            UIColor *colorSr = [self chooseColorSoundRange:keyMovingType];
            // run delegate method
            if ([self.delegate respondsToSelector:@selector(performanceArea:didSelectSoundURL:atTime:color:)]) {
                [self.delegate performanceArea:self didSelectSoundURL:selectedSoundURL atTime:_soundTime color:colorSr];
            }
        }
    }
}

-(UIColor*)chooseColorSoundRange:(NSString*)keyMovingType{
    UIColor *colorSoundRange;
    if ([keyMovingType isEqualToString:@"scuff"]) {
        colorSoundRange = [UIColor redColor];
    } else if ([keyMovingType isEqualToString:@"up stairs"]){
        colorSoundRange = [UIColor blackColor];
    } else if ([keyMovingType isEqualToString:@"down stairs"]){
        colorSoundRange = [UIColor blueColor];
    } else if ([keyMovingType isEqualToString:@"run"]){
        colorSoundRange = [UIColor yellowColor];
    } else if ([keyMovingType isEqualToString:@"walk"]){
        colorSoundRange = [UIColor grayColor];
    }
    return colorSoundRange;
}

////////////////////////////////////////
#pragma mark - actions

static float heightTopViewForGallery = 92;
static float heightTopViewForFX = 150;

- (IBAction)tapToFilter:(UIButton *)sender {
    sender.selected = YES;
    [self hiddenViewWithGallery];
    [self showViewWithFilters];
    [self heightTopView:heightTopViewForFX];
    [self bringSubviewToFront:sender];
    [self.viewWithFilters sendSubviewToBack:self.subClassButton];
}
- (IBAction)tapToSubclass:(UIButton *)sender {
    if (sender.selected) {
        [UIView animateWithDuration:0.3 animations:^{
            self.constraintTopViewHeight.constant = self.constraintTopViewHeight.constant == 0 ? heightTopViewForGallery : 0;
            self.level2ScrollView.hidden = self.level1ScrollView.hidden = YES;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (self.constraintTopViewHeight.constant != 0) {
                self.level2ScrollView.hidden = self.level1ScrollView.hidden = NO;
            }
        }];
    } else {
        sender.selected = YES;
        [self hiddenViewWithFilters];
        [self showViewWithGallery];
        [self heightTopView:heightTopViewForGallery];
        [self bringSubviewToFront:sender];
        [self.viewWithGallery sendSubviewToBack:self.filterButton];
    }
}

-(IBAction)tapToLeftFx:(UIButton *)sender{
    sender.selected = !sender.selected;
    sender.selected ? [self.graphicFXImage addGraphicState:GraphicStateLeftFX] : [self.graphicFXImage removeGraphicState:GraphicStateLeftFX];
}

-(IBAction)tapToRightFx:(UIButton *)sender{
    sender.selected = !sender.selected;
    sender.selected ? [self.graphicFXImage addGraphicState:GraphicStateRightFX] : [self.graphicFXImage removeGraphicState:GraphicStateRightFX];
}



-(void) actionLevelImageTaped:(UITapGestureRecognizer*)sender
{
    NSUInteger levelInd;
    UIView *selectedLevelScroll;
    
    for (levelInd=0; levelInd<_levelScrollsArray.count; levelInd++)
    {
        selectedLevelScroll = _levelScrollsArray[levelInd];
        CGPoint p = [sender locationInView:selectedLevelScroll];
        if ([selectedLevelScroll pointInside:p withEvent:nil])
            break;
    }
    
    if (levelInd < _levelScrollsArray.count)
    {
        NSUInteger imgIndex = sender.view.tag; //[self indexInView:selectedLevelScroll ofImageView:(UIImageView*)sender.view];
        if (imgIndex != NSNotFound)
        {
            UIImageView *prevImageView = [self imageviewInView:selectedLevelScroll atIndex:_selectedIndexes[levelInd]];
            [self selectImageView:prevImageView doSelect:NO];
            
            _selectedIndexes[levelInd] = imgIndex;
            [self selectImageView:sender.view doSelect:YES];

            [self extractDictAtGalleriesSelection];
            
        }
    }
    
}

- (IBAction)actionMovingTypeTapped:(UIButton*)sender
{
    _soundTime = [CompositionPlayer sharedCompositionPlayer].videoPlayer.currentTime;
    
    NSUInteger ind = sender.tag;
    NSString *key = self.tiers[2][ind][kPmATierName];
    [self selectSoundByMovingType:key];
}

- (IBAction)actionScuff:(UISwipeGestureRecognizer *)sender
{
    [self selectSoundByMovingType:keyMovingTypeScuff];
}



#pragma mark ================================

-(void)heightTopView:(float)height{
    [UIView animateWithDuration:0.2 animations:^{
        self.constraintTopViewHeight.constant = height;
        [self layoutIfNeeded];
    }];
}

-(void)hiddenViewWithGallery{
    self.subClassButton.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.viewWithGallery.alpha = 0;
    } completion:^(BOOL finished) {
        self.viewWithGallery.hidden = YES;
    }];
}

-(void)showViewWithGallery{
    self.filterButton.selected = NO;
    self.viewWithGallery.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.viewWithGallery.alpha = 1;
    }];
}

-(void)hiddenViewWithFilters{
    [UIView animateWithDuration:0.2 animations:^{
        self.viewWithFilters.alpha = 0;
    } completion:^(BOOL finished) {
        self.viewWithFilters.hidden = YES;
    }];
}

-(void)showViewWithFilters{
    self.viewWithFilters.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.viewWithFilters.alpha = 1;
    }];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_playersArray removeObject:player];
}

///////////
#pragma mark - UIGestureRecognizerDelegate methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    NSLog(@"touch timestamp:%.6f", touch.timestamp);
    _soundTime = [CompositionPlayer sharedCompositionPlayer].videoPlayer.currentTime;
    return YES;
}


@end
