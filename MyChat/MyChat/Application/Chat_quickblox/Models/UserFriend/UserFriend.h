//
//  UserFriend.h
//  Tadaa
//
//  Created by Yosemite on 5/15/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserFriend : NSObject

@property (nonatomic, copy) NSString *friendId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *friendName;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic) BOOL isInvited;

- (instancetype) initWithDictionary:(NSDictionary*)dic;

@end
