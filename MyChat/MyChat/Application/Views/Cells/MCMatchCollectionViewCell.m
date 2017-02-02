//
//  MCMatchCollectionViewCell.m
//  MyChat
//
//  Created by New Star on 3/1/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "MCMatchCollectionViewCell.h"

@implementation MCMatchCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [commonUtils cropCircleImage:_matchesPhotoView];
    [commonUtils setRoundedRectBorderImage:_matchesPhotoContainView withBorderWidth:1.0f withBorderColor:appController.appSecondColor withBorderRadius:_matchesPhotoContainView.frame.size.width/2.0f];
    
}

@end
