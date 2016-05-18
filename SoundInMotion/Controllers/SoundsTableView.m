//
//  SoundsTableView.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 2/22/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "SoundsTableView.h"
#import "SoundTableCell.h"

@interface SoundsTableView () <UIScrollViewDelegate>

@end

@implementation SoundsTableView


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)setContentSizeForWaves:(CGSize)contentSizeForWaves{
    _contentSizeForWaves = contentSizeForWaves;
    for (UIScrollView *waves in [self wavesViewsInTableView]) {
        waves.contentSize = contentSizeForWaves;
    }
}

#pragma mark - UITableViewDataSource


-(PerformanceAreaType)allocationDoubleTap:(CGPoint)point{
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    if (indexPath) {
        return PerformanceAreaTypeSteps;
    }
    return -1;
}


#pragma mark - Func's


-(NSArray*)cellsForTableView{
    NSInteger sections = self.numberOfSections;
    NSMutableArray *cells = [NSMutableArray new];
    for (int section = 0; section < sections; section++) {
        NSInteger rows =  [self numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
            if (cell) {
                [cells addObject:cell];
            }
        }
    }
    return cells;
}
//
-(NSArray*)wavesViewsInTableView{
    NSMutableArray *waves = [NSMutableArray new];
    for (SoundTableCell *cell in [self cellsForTableView]) {
        [waves addObject:cell.wavesView];
    }
    return waves;
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


@end
