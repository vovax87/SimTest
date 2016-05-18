//
//  TracksView_Private.h
//  SoundInMotion
//
//  Created by Konstianm on 18/04/2016.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "TracksView.h"
#import "RegionMenuView.h"
#import "SoundRangeView.h"
#import "RecordSessionMenu.h"
#import "RegionEditView.h"

@interface TracksView ()

@property (strong, nonatomic) RegionMenuView *regionMenuView;
@property (strong, nonatomic) RecordSessionMenu *recordSessionMenu;
@property (strong, nonatomic) RecordSessionView *recordSessionViewUnderMenu;
@property (strong, nonatomic) SoundRangeView *soundRangeViewUnderMenu;
@property (strong, nonatomic) WrapRegionMenuView *wrapRegionMenu;
@property (strong, nonatomic) AMPopTip *popmenu;
@property (strong, nonatomic) PopoverView *popview;
@property (strong, nonatomic) RegionEditView *regEditView;

@property (nonatomic) CGFloat editingOffsetX;
@property (nonatomic) CGFloat editingWidth;
@property (nonatomic) CGFloat minEditingWidth;




@end


@interface TracksView (Menu)

//-(void)setupActionsOnRegionMenu;
-(void)setupActionsOnRecordSessionMenu;

-(void)actionMovingSoundRange:(SoundRangeView*)soundRangeView;
//-(void)actionMovingRecordSession:(RecordSessionView*)recordSessionView;

-(void)actionMenu:(SoundRangeView*)soundRangeView;
-(void)actionCropping:(SoundRangeView*)soundRangeView;

//Menu RecordSessionView
-(void)actionReccordSessionMenu:(RecordSessionView*)recordSessionView;
-(void)actionRearrangeTrackWithRecordSession:(RecordSessionView*)recordSessionView;

@end
