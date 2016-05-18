//
//  TracksView+Menu.m
//  SoundInMotion
//
//  Created by Konstianm on 18/04/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "TracksView.h"
#import "TracksView_Private.h"


@implementation TracksView (Menu)


////////////////////////////////
#pragma mark - funcs

-(void)setupActionsOnRecordSessionMenu
{
    self.recordSessionMenu = [RecordSessionMenu makeFromXib];
    [self.recordSessionMenu.buttonDelete addTarget:self action:@selector(menuRecordActionDelete) forControlEvents:UIControlEventTouchUpInside];
    [self.recordSessionMenu.buttonEdit addTarget:self action:@selector(menuRecordActionEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.recordSessionMenu.buttonSplit addTarget:self action:@selector(menuRecordActionSplit) forControlEvents:UIControlEventTouchUpInside];
    [self.recordSessionMenu.buttonVolume addTarget:self action:@selector(menuRecordActionVolume) forControlEvents:UIControlEventTouchUpInside];
    
}


-(CMTime)convertPointToSecond:(CGPoint)point widthTimeLine:(float)width duration:(CMTime)duration{
    return CMTimeMakeWithSeconds(CMTimeGetSeconds(duration)*point.x/width, 10000000);
}

-(void)shiftTableForRecordSession:(RecordSession*)recordSession{
    NSUInteger indexTrack = [self.soundEdition.tracks indexOfObject:recordSession.soundTrack];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexTrack inSection:0];
    float offsetY = self.soundsTableView.contentOffset.y;
    float bottomInset;
    if (indexPath) {
        //        offsetY = indexPath.row * self.soundsTableView.rowHeight;
//        UITableViewCell *cell = [self.soundsTableView cellForRowAtIndexPath:indexPath];
//        
//        CGRect cRect = [cell convertRect:_performanceArea.frame fromView:self];
//        
//        CGFloat dh = cell.frame.size.height - cRect.origin.y;
//        if (dh > 0)
//            offsetY += + dh;
        offsetY = self.soundsTableView.rowHeight * indexTrack;
        bottomInset =  self.regionMenuView.frame.size.height; //self.soundsTableView.frame.size.height - self.soundsTableView.rowHeight;
    } else {
        //        offsetY = self.soundsTableView.contentOffset.y;
        bottomInset = 0;
    }
    [self.soundsTableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    self.soundsTableView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
}


////////////////////////////////
#pragma mark - SoundRange menu

-(void)actionMenu:(SoundRangeView*)soundRangeView
{
    
    self.soundRangeViewUnderMenu = soundRangeView;
    CGPoint point = [self convertPoint:CGPointMake(floor(soundRangeView.frame.size.width/2), 0) fromView:soundRangeView];
    self.popview = [PopoverView showPopoverAtPoint:point inView:self withTitle:nil withContentView:self.regionMenuView delegate:nil];
}


#pragma mark - moving along wavesView

-(void)actionMovingSoundRange:(SoundRangeView*)soundRangeView
{
    SoundRange *srange = soundRangeView.soundRange;
    CMTime startTime = [self convertPointToSecond:CGPointMake(soundRangeView.frame.origin.x - self.rullerView.contentOffset.x,
                                                              soundRangeView.frame.origin.y)
                                    widthTimeLine:self.rullerView.contentSize.width
                                         duration:[CompositionPlayer sharedCompositionPlayer].duration];
    CMTime duration = srange.isCropped ? srange.cropTimeRange.duration : srange.timeRange.duration;

    CMTimeRange range = CMTimeRangeMake(startTime, duration);
    if (srange.isCropped) {
        srange.cropTimeRange = range;
    } else {
        srange.timeRange = range;
    }
    
    self.soundEdition.changed = YES;
    [[CompositionPlayer sharedCompositionPlayer] composedTracksWithSoundEdition:self.soundEdition];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.soundEdition.tracks indexOfObject:srange.recordSession] inSection:0];
    CGPoint contentOffset = self.soundsTableView.contentOffset;
    [self.soundsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.soundsTableView.contentOffset = contentOffset;
}




//-(void)actionMovingRecordSession:(RecordSessionView*)recordSessionView
//{
//    RecordSession *rsession = recordSessionView.recordSession;
//    CMTime startTime = [self convertPointToSecond:recordSessionView.frame.origin
//                                    widthTimeLine:self.rullerView.contentSize.width
//                                         duration:[CompositionPlayer sharedCompositionPlayer].videoPlayer.currentItem.duration];
//    
//    CMTimeRange range = CMTimeRangeMake(startTime, rsession.timeRange.duration);
//    rsession.timeRange = range;
//    
//    self.soundEdition.changed = YES;
//    [[CompositionPlayer sharedCompositionPlayer] composedTracksWithSoundEdition:self.soundEdition];
//}


/////////////////////////////////
#pragma mark - cropping sound region

-(void)actionCropping:(SoundRangeView*)soundRangeView
{
    self.soundEdition.changed = YES;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[CompositionPlayer sharedCompositionPlayer] composedTracksWithSoundEdition:self.soundEdition];
    });
}


#pragma mark - RecordSessionMenu actions

-(void)actionReccordSessionMenu:(RecordSessionView*)recordSessionView
{
    self.recordSessionViewUnderMenu = recordSessionView;
    CGPoint point = [self convertPoint:CGPointMake(floor(recordSessionView.frame.size.width/2), 0) fromView:recordSessionView];
    self.popview = [PopoverView showPopoverAtPoint:point inView:self withTitle:nil withContentView:self.recordSessionMenu delegate:nil];
}


-(void)menuRecordActionDelete
{
    if (self.recordSessionViewUnderMenu) {
        [self.recordSessionViewUnderMenu.recordSession removeFromSoundTrack];
        self.soundEdition.changed = YES;
        [self.recordSessionViewUnderMenu removeFromSuperview];
        NSIndexPath *indexPath = [self.soundsTableView indexPathForRowAtPoint:[self.soundsTableView convertPoint:CGPointZero fromView:self.recordSessionViewUnderMenu]];
        if (indexPath) {
            [self.soundsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.popview dismiss];
        self.recordSessionViewUnderMenu = nil;
        [self.regEditView hide];
    }
}

-(void)zoomInToRecordSession:(RecordSessionView*)recordSessionView
{
    CGFloat k = self.rullerView.frame.size.width / recordSessionView.frame.size.width;
    self.editingOffsetX = floor(recordSessionView.frame.origin.x*k);
    self.editingWidth = self.rullerView.frame.size.width;
//    NSLog(@"zoomIn _editingOffsetX:%.2f _editingWidth:%.2f", self.editingOffsetX, self.editingWidth);
    
    
    CGSize contentSize = self.rullerView.contentSize;
    contentSize.width *= k;
    self.minEditingWidth = contentSize.width;
    
    CGPoint contentOffset = self.rullerView.contentOffset;
    contentOffset.x = self.editingOffsetX;
    
    [UIView animateWithDuration:1 animations:^{
        self.rullerView.contentSize = contentSize;
        self.rullerView.contentOffset = contentOffset;
    } completion:^(BOOL finished) {
//        [self.soundsTableView reloadData];
        [self.rullerView movePointerToTime:recordSessionView.recordSession.timeRange.start];
        self.regEditView.coefPixelsSecond = self.recordSessionViewUnderMenu.coefPixelsSecond;
        self.regEditView.recordSession = self.recordSessionViewUnderMenu.recordSession;
    }];
}


-(void)menuRecordActionEdit
{
    [self.popview dismiss:YES];
    [self removePerformanceArea];
    CMTime startTime = self.recordSessionViewUnderMenu.recordSession.timeRange.start;
    CMTime endTime = CMTimeRangeGetEnd(self.recordSessionViewUnderMenu.recordSession.timeRange);
    NSDictionary *userInfo = @{@"startTime": @(CMTimeGetSeconds(startTime)),
                               @"endTime": @(CMTimeGetSeconds(endTime))};
    [[NSNotificationCenter defaultCenter] postNotificationName:startEditingModeNotification object:@(YES) userInfo:userInfo];
    if (self.regEditView.isShowed) {
        return;
    }
    
    self.editingRecordSession = YES;
    self.regEditView.recordSession = nil;

    self.regEditView.targetTrack = self;
//    self.regEditView.actionEndMoving = @selector(actionMovingSoundRange:);
    self.regEditView.contentSize = self.rullerView.contentSize;
    self.regEditView.contentOffset = self.rullerView.contentOffset;
//    self.regEditView.coefPixelsSecond = self.recordSessionViewUnderMenu.coefPixelsSecond;
//    self.regEditView.recordSession = self.recordSessionViewUnderMenu.recordSession;
    [self.regEditView show];
    [self zoomInToRecordSession:self.recordSessionViewUnderMenu];
    self.recordSessionViewUnderMenu.tag = 1;
//    [self.soundsTableView reloadData];
    [self shiftTableForRecordSession:self.recordSessionViewUnderMenu.recordSession];
    [[CompositionPlayer sharedCompositionPlayer] seekToTime:self.recordSessionViewUnderMenu.recordSession.timeRange.start];
    
}

-(void)menuRecordActionVolume
{
    
}

-(void)menuRecordActionSplit
{
    [self.popview dismiss:YES];
    RegionSplitterView *splitterView = [RegionSplitterView makeFromXib];
    
    CGRect frame = [self convertRect:self.recordSessionViewUnderMenu.frame fromView:self.recordSessionViewUnderMenu.superview];
    frame.origin.y -= 12.0;
    frame.size.height += 12.0;
    splitterView.frame = frame;
    
    splitterView.target = self;
    splitterView.action = @selector(actionHandleSplit:);
    
    [self addSubview:splitterView];
    
}

-(void)actionHandleSplit:(RegionSplitterView*)splitterView
{
    [self actionSplitRecordSessionView:self.recordSessionViewUnderMenu dividerCoef:splitterView.coefDivider];
    [splitterView removeFromSuperview];
    self.recordSessionViewUnderMenu = nil;
}


// returns the array of 2 new splitted views
-(NSArray*)actionSplitRecordSessionView:(RecordSessionView*)recordSessionView dividerCoef:(CGFloat)dividerCoef
{
    RecordSession *recordSession = recordSessionView.recordSession;
    CMTimeRange sourceTimeRange = recordSession.timeRange;
    
    CGFloat secondsDuration = CMTimeGetSeconds(sourceTimeRange.duration);
    CGFloat secondsPeriod01 =  secondsDuration * dividerCoef;
    CMTime duration01 = CMTimeMakeWithSeconds(secondsPeriod01, 10000000);
    CMTimeRange range01 = CMTimeRangeMake(sourceTimeRange.start, duration01);
    
    CMTime start02 = CMTimeAdd(sourceTimeRange.start, duration01);
    CMTime end02 = CMTimeRangeGetEnd(sourceTimeRange);
    CMTimeRange range02 = CMTimeRangeFromTimeToTime(start02, end02);
    
    RecordSession *recordSession01 = [recordSession.soundTrack createRecordSession];
    recordSession01.timeRange = range01;
    
    RecordSession *recordSession02 = [recordSession.soundTrack createRecordSession];
    recordSession02.timeRange = range02;
    
    for (SoundRange *srange in recordSession.soundRanges)
    {
        if (CMTimeCompare(CMTimeRangeGetEnd(srange.timeRange), range01.duration) <= 0) {
            [recordSession01 addSoundRange:srange];
        }
        else
        {
            CMTime rangeStart = CMTimeSubtract(srange.timeRange.start, range01.duration);
            if (rangeStart.value >= 0) {
                srange.timeRange = CMTimeRangeMake(rangeStart, srange.timeRange.duration);
                [recordSession02 addSoundRange:srange];
            }
        }
    }
    
    [recordSession.soundTrack addRecordSession:recordSession01];
    [recordSession.soundTrack addRecordSession:recordSession02];
    
    [recordSession removeFromSoundTrack];
    
    [self.soundEdition save];
    
    NSArray *splittedViews = nil;
    
    NSIndexPath *indexPath = [self.soundsTableView indexPathForRowAtPoint:[self.soundsTableView convertPoint:CGPointZero fromView:recordSessionView]];
    
    if (indexPath) {
        SoundTableCell *cell = [self.soundsTableView cellForRowAtIndexPath:indexPath];
        RecordSessionView *rview01 = [self addRecordSession:recordSession01 toCell:cell];
        RecordSessionView *rview02 = [self addRecordSession:recordSession02 toCell:cell];
        rview01.alpha = rview02.alpha = 0;
        
        splittedViews = @[rview01, rview02];
        
        [UIView animateWithDuration:0.3 animations:^{
            recordSessionView.alpha = 0.0;
            rview01.alpha = rview02.alpha = 1.0;
        } completion:^(BOOL finished) {
            [recordSessionView removeFromSuperview];
        }];
    }
    else {
        [recordSessionView removeFromSuperview];
    }
    
    return splittedViews;
}



///////////////////////////////////
#pragma mark - rearrange Record Session

-(void)actionRearrangeTrackWithRecordSession:(RecordSessionView*)recordSessionView
{
    //    if (recordSessionView.state == RecordSessionViewStateSelected) {
    //        float time = recordSessionView.frame.origin.x / self.rullerView.contentSize.width * CMTimeGetSeconds([CompositionPlayer sharedCompositionPlayer].videoPlayer.currentItem.duration);
    //        [recordSessionView setCropFrame:recordSessionView.frame];
    //        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    //    }
    
//    NSUInteger indexTrack = [_soundEdition.tracks indexOfObject:recordSessionView.recordSession.soundTrack];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexTrack inSection:0];
    
    ////    WavesScrollView *superWaveView = recordSessionView.superview;
    //    for (RecordSessionView *rSessionView in recordSessionView.superview.subviews) {
    //        if (rSessionView != recordSessionView) {
    //            CMTimeRange searchTimeRange = rSessionView.recordSession.timeRange;
    //            if (rSessionView.recordSession.isCropped) {
    //                searchTimeRange = rSessionView.recordSession.cropTimeRange;
    //            }
    //            BOOL newRecordSessionOverlap = CMTimeRangeContainsTimeRange(recordSessionView.recordSession.timeRange,searchTimeRange);
    //            if (newRecordSessionOverlap) {
    //                [rSessionView.recordSession removeFromSoundTrack];
    //                continue;
    //            }
    //            BOOL oldRecordSessionOverlap = CMTimeRangeContainsTimeRange(searchTimeRange,recordSessionView.recordSession.timeRange);
    //            if (oldRecordSessionOverlap) {
    //                NSLog(@"FWFW");
    //                break;
    //            }
    //            BOOL containsStart = CMTimeRangeContainsTime(searchTimeRange, recordSessionView.recordSession.timeRange.start);
    //            if (containsStart) {
    //                CGRect frame = rSessionView.frame;
    //                frame.size.width = CGRectGetMinX(recordSessionView.frame) - CGRectGetMinX(frame);
    //                [rSessionView setCropFrame:frame];
    ////                rSessionView.recordSession.cropTimeRange = CMTimeRangeFromTimeToTime(searchTimeRange.start, recordSessionView.recordSession.timeRange.start);
    //            }
    //            BOOL containsEnd = CMTimeRangeContainsTime(searchTimeRange, CMTimeRangeGetEnd(recordSessionView.recordSession.timeRange));
    //            if (containsEnd) {
    //                CGRect frame = rSessionView.frame;
    //                frame.origin.x = CGRectGetMaxX(recordSessionView.frame);
    //                CGFloat width = CGRectGetMinX(frame) - CGRectGetMinX(rSessionView.frame);
    //                frame.size.width = width;
    //                [rSessionView setCropFrame:frame];
    ////                rSessionView.recordSession.cropTimeRange = CMTimeRangeFromTimeToTime(CMTimeRangeGetEnd(recordSessionView.recordSession.timeRange),
    ////                                                                                     CMTimeRangeGetEnd(searchTimeRange));
    //            }
    //        }
    //    }
    
    
    NSArray *trackSubviews = [NSArray arrayWithArray:recordSessionView.superview.subviews]; // to avoid the splitted views be passed
    
    for (RecordSessionView *rview in trackSubviews)
    {
        if (rview != recordSessionView && [rview isKindOfClass:[RecordSessionView class]])
        {
            CGRect intersFrame = CGRectIntersection(rview.frame, recordSessionView.frame);
            if (!CGRectIsNull(intersFrame))
            {
                if (CGRectEqualToRect(CGRectIntegral(intersFrame), CGRectIntegral(rview.frame))) { // delete
                    [rview removeFromSuperview];
                    [rview.recordSession removeFromSoundTrack];
                }
                else if (CGRectEqualToRect(CGRectIntegral(intersFrame), CGRectIntegral(recordSessionView.frame))) { // split
                    intersFrame = [rview convertRect:intersFrame fromView:rview.superview];
                    CGFloat dividerCoef  = CGRectGetMaxX(intersFrame) / rview.frame.size.width;
                    NSArray *splittedViews = [self actionSplitRecordSessionView:rview dividerCoef:dividerCoef];
                    // crop the left view
                    RecordSessionView *leftView = splittedViews[0];
                    CGRect leftFrame = leftView.frame;
                    leftFrame.size.width = intersFrame.origin.x;
                    [UIView animateWithDuration:0.3 animations:^{
                        [leftView setCropFrame:leftFrame];
                    }];
                }
                else if (intersFrame.origin.x > rview.frame.origin.x) {
                    CGRect cropFrame = rview.frame;
                    cropFrame.size.width = intersFrame.origin.x - cropFrame.origin.x;
                    [UIView animateWithDuration:0.3 animations:^{
                        [rview setCropFrame:cropFrame];
                    }];
                }
                else if (CGRectGetMaxX(intersFrame) > rview.frame.origin.x) {
                    CGRect cropFrame = rview.frame;
                    cropFrame.origin.x =  CGRectGetMaxX(intersFrame);
                    cropFrame.size.width -= intersFrame.size.width;
                    [UIView animateWithDuration:0.3 animations:^{
                        [rview setCropFrame:cropFrame];
                    }];
                }
            }
        }
    }
    
    [self.soundEdition save];
//    [self.soundsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}





@end
