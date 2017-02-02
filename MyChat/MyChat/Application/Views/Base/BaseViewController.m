//
//  WFBaseViewController.m
//  Woof
//
//  Created by Mac on 1/9/15.
//  Copyright (c) 2015 Silver. All rights reserved.
//

#import "BaseViewController.h"
//#import "CustomCameraViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    if(![commonUtils checkKeyInDic:@"user_id" inDic:appController.currentUser] || ![commonUtils checkKeyInDic:@"user_photo_url" inDic:appController.currentUser] || ![commonUtils checkKeyInDic:@"user_name" inDic:appController.currentUser]) {
//        if([commonUtils getUserDefault:@"current_user_user_id"] != nil) {
//            appController.currentUser = [commonUtils getUserDefaultDicByKey:@"current_user"];
//        } else {
//            //[self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.isLoadingBase = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden {
    return NO;
}

# pragma Top Menu Events
//- (IBAction)menuClicked:(id)sender {
//    if(self.isLoadingBase) return;
//    [self.sidePanelController showLeftPanelAnimated: YES];
//}

- (IBAction)menuBackClicked:(id)sender {
    if(self.isLoadingBase) return;
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)menuPostBarkClicked:(id)sender {
    if(self.isLoadingBase) return;
    
    
}

@end
