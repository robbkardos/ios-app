//
//  UserFriend.m
//  Tadaa
//
//  Created by Yosemite on 5/15/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "UserFriend.h"

@implementation UserFriend

- (instancetype) initWithDictionary:(NSDictionary*)dic {
    self = [super init];
    if (self) {
        self.friendId = dic[@"id"];
        self.userId = dic[@"userId"];
        self.email = dic[@"email"];
        self.friendName = dic[@"friendName"];
        
        self.isInvited = [dic[@"invited"] intValue] == 1;
    }
    return self;
}

@end
