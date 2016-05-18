//
//  SelectedPerformanceArea.m
//  SoundInMotion
//
//  Created by Max Vasilevsky on 3/24/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import "SelectedPerformanceArea.h"
#import "UIView+MakeFromXib.h"
#import "iCarousel.h"

@interface SelectedPerformanceArea () <iCarouselDataSource,iCarouselDelegate>

@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@property (strong, nonatomic) NSArray *imageNameCarouselArray;
@property (assign,nonatomic) NSUInteger selectedIndex;


@end

@implementation SelectedPerformanceArea{
    OverlapViewBlock _blockCancel,  _blockApply;
}


#pragma mark - iCarouselDataSource

-(void)awakeFromNib{
    self.imageNameCarouselArray = @[@"step",@"rain",@"car"];
    self.carousel.type = iCarouselTypeLinear;
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return self.imageNameCarouselArray.count;
    
    
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view{
    UIImageView *itemView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.carousel.frame.size.width/ 2, self.carousel.frame.size.height)];
    itemView.image = [UIImage imageNamed:[self.imageNameCarouselArray objectAtIndex:index]];
    return itemView;
}

#pragma mark - iCarouselDelegate

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    self.selectedIndex = index;
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeScale(3, 3);
        [self buttonApplyAction:nil];
    }];
}

+(void)showWithApplyBlock:(OverlapViewBlock)blockApply cancelBlock:(OverlapViewBlock)blockCancel{
    SelectedPerformanceArea *view = [[self class] makeFromXib];
    view.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
    
    view->_blockApply = blockApply;
    view->_blockCancel = blockCancel;
    
    [view setAlpha:0];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:view];
    
    [UIView animateWithDuration:0.2 animations:^{
        [view setAlpha:1];
    }];
}

- (IBAction)buttonCancelAction:(id)sender
{
    if (_blockCancel)
        _blockCancel(self);
    
    [self dismiss];
}

- (IBAction)buttonApplyAction:(id)sender
{
    if (_blockApply)
        _blockApply(self);
    
    [self dismiss];
}

-(void) dismiss
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
