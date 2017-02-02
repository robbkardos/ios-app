//
//  FirstViewController.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogsViewController.h"
@interface UsersViewController : UIViewController

@property (nonatomic, weak) DialogsViewController *dialogsViewController;
@end
