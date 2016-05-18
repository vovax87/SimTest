//
//  TracksView.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/15/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundsTableView.h"
#import "MovieSoundEdition.h"
#import "SoundTableCell.h"
#import "UIView+MakeFromXib.h"
#import "CompositionPlayer.h"
#import <EZAudio/EZAudio.h>


@interface TracksView : UIView

@property (weak,nonatomic) IBOutlet UIScrollView *rullerView;
@property (weak,nonatomic) IBOutlet SoundsTableView *soundsTableView;
@property (strong, nonatomic) MovieSoundEdition *soundEdition;


@property (strong,nonatomic) NSIndexPath *currentPerfomanceAreaIndexPath;
@property (strong,nonatomic) NSIndexPath *currentIndexPath;
-(void)showPerfomanceAreaAtIndex:(NSIndexPath*)indexPath;
-(void)removePerformanceArea;

//-(void)createPerfomanceAreaWithType:(PerformanceAreaType)type withCell:(BOOL)withCell;
-(void) createNewTrackOfType:(PerformanceAreaType)pmaType;



@end
