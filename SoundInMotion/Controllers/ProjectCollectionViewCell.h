//
//  ProjectCollectionViewCell.h
//  SoundInMotion
//
//  Created by Max Vasilevsky on 4/19/16.
//  Copyright © 2016 SoundInMotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectCollectionViewCell : UICollectionViewCell

@property (weak,nonatomic) IBOutlet UIImageView *imageProject;
@property (weak,nonatomic) IBOutlet UILabel *nameProject;

@end
