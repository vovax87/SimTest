//
//  TracksView.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/15/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "TracksView.h"


static NSString *const key = @"soundFileURL";

@interface TracksView () <UIGestureRecognizerDelegate,UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, PerformanceAreaDelegate>

@property (weak, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (weak, nonatomic) IBOutlet UILabel *countFlagLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentFlagLabel;

@property (strong, nonatomic) PerformanceArea *performanceArea;


@end



@implementation TracksView
{
    NSMutableArray *_tracks;

    SoundTrack *_currentSoundTrack;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
}




-(void) createNewTrackOfType:(PerformanceAreaType)pmaType
{
    SoundTrack *soundTrack = [_soundEdition createSoundTrack];
    soundTrack.performanceAreaType = pmaType;
    [_tracks addObject:soundTrack];
    
    if (_currentSoundTrack) {
        [self removePerformanceArea];
    }
    
    
    [_soundsTableView reloadData];
    [self showPerformanceAreaOfType:pmaType];
    [_soundEdition save];
}






-(void)showPerfomanceAreaAtIndex:(NSIndexPath*)indexPath{
    if (self.performanceArea) {
        return;
//        [self removePerformanceArea];
    }
    _currentIndexPath = indexPath;
    [self showPerfomanceArea];
    
}

-(void)showPerformanceAreaOfType:(PerformanceAreaType)type
{
    CGFloat topOffset = self.rullerView.frame.size.height + self.soundsTableView.rowHeight;
    
    if (type == PerformanceAreaTypeSteps)
    {
        self.performanceArea = [[PerformanceArea performanceAreaWithType:type] makeFromXibWithAreaName:@"FootSteps" withSettings:_currentSoundTrack.settingsPerfomanceArea];
//        self.performanceArea.settings = _currentSoundTrack.settingsPerfomanceArea;
        self.performanceArea.delegate = self;
        
        CGRect  frame = { 0 ,self.frame.size.height, self.frame.size.width, self.frame.size.height - topOffset};
        _performanceArea.frame = frame;
        [self addSubview:_performanceArea];
        
        frame.origin.y = topOffset;
        
        [UIView animateWithDuration:0.3 animations:^{
            _performanceArea.frame = frame;
        }];
        
//        [self shiftTableView:_currentIndexPath];
    }
    else
    {
        [self notFoundPerformanceArea];
    }
}


-(void)showPerfomanceArea{
    _currentPerfomanceAreaIndexPath = _currentIndexPath;
    _currentSoundTrack = _tracks[_currentIndexPath.row];
    [self showPerformanceAreaOfType:(PerformanceAreaType)_currentSoundTrack.performanceAreaType];
}


-(void)removePerformanceArea
{
    if (!_performanceArea)
        return;
    _currentSoundTrack.settingsPerfomanceArea = [_performanceArea saveSettings];
    [_soundEdition save];
    CGRect frame = _performanceArea.frame;
    frame.origin.y += frame.size.height;
    
    UIView *copyView = _performanceArea;
    
    [UIView animateWithDuration:0.3 animations:^{
        copyView.frame = frame;
    }completion:^(BOOL finished) {
        [copyView removeFromSuperview];
    }];
    _performanceArea = nil;
    
}


-(BOOL)checkPinchTouchsInChannelsFrame:(CGPoint)point{
    BOOL check = point.x > self.rullerView.frame.origin.x ? YES : NO;
    return check;
}

-(void)notFoundPerformanceArea{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"NOT FOUND";
    label.font = [UIFont systemFontOfSize:200];
    [label sizeToFit];
    label.center = [[[UIApplication sharedApplication] delegate] window].center;
    label.textColor = [UIColor redColor];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:label];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    });
}


#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}





////////////////////////////////
#pragma mark - UITableViewDataSource, UITableViewDelegate methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tracks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"soundCell";
    
    SoundTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    return cell;
}


////////////////////////////////
#pragma mark - PerformanceAreaDelegate methods

-(void)performanceArea:(PerformanceArea *)performanceArea didSelectSoundURL:(NSURL *)soundURL atTime:(CMTime)cmTime color:(UIColor*)color
{
}





@end
