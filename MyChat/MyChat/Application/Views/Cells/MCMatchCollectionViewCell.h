//
//  MCMatchCollectionViewCell.h
//  MyChat
//
//  Created by New Star on 3/1/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMatchCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *matchesPhotoContainView;
@property (strong, nonatomic) IBOutlet UILabel *matchesNameAgeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *matchesPhotoView;
@property (strong, nonatomic) IBOutlet UIView *containView;
@end
