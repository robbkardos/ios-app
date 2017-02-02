//
//  MCMyProfileViewController.m
//  MyChat
//
//  Created by New Star on 3/1/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "MCMyProfileViewController.h"
#import "MCMatchViewController.h"

@interface MCMyProfileViewController (){
    
    NSMutableArray *matchesUserArray;
}
@property (strong, nonatomic) IBOutlet UIButton *cotinueBtn;
@property (strong, nonatomic) IBOutlet UILabel *userGenderAgeLabel;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundPhotoView;
@property (strong, nonatomic) IBOutlet UIImageView *userPhotoView;

@end

@implementation MCMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [commonUtils cropCircleImage:_userPhotoView];
    [commonUtils setRoundedRectBorderImage:_backgroundPhotoView withBorderWidth:2.0f withBorderColor:appController.appMainColor withBorderRadius:_backgroundPhotoView.frame.size.width/2.0f];
    [commonUtils setRoundedRectBorderButton:_cotinueBtn withBorderWidth:2.0f withBorderColor:appController.appMainColor withBorderRadius:_cotinueBtn.frame.size.height/2.0f];
    
    [_cotinueBtn setTitleColor:appController.appMainColor forState:UIControlStateNormal];
    
    [self initData];
}

- (void) initData{
    
    if ([[appController.currentUser objectForKey:@"user_gender"] isEqualToString:@"1"]) {
        
        [commonUtils setImageViewAFNetworking:_userPhotoView withImageUrl:[appController.currentUser objectForKey:@"user_profilephoto_url"] withPlaceholderImage:[UIImage imageNamed:@"user_avatar_male"]];
        
    }else if ([[appController.currentUser objectForKey:@"user_gender"] isEqualToString:@"2"]) {
        
        [commonUtils setImageViewAFNetworking:_userPhotoView withImageUrl:[appController.currentUser objectForKey:@"user_profilephoto_url"] withPlaceholderImage:[UIImage imageNamed:@"user_avatar_female"]];
    }
    
    _userName.text = [appController.currentUser objectForKey:@"user_firstname"];
    
    NSString *strGender;
    if ([[appController.currentUser objectForKey:@"user_gender"] isEqualToString:@"1"]) {
        strGender = @"Male";
    }else{
        
        strGender = @"Female";
    }
    
    
    //Get Current Age
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYearStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"%@", currentYearStr);
    
    NSInteger currentYear = [[currentYearStr stringByReplacingOccurrencesOfString:@"" withString:@""] integerValue];
    
    NSInteger birthdayYear = 2016;
    
    if([commonUtils checkKeyInDic:@"user_birthday" inDic:[appController.currentUser mutableCopy]]) {
        
        NSString *string = [appController.currentUser objectForKey:@"user_birthday"];
        if (string.length == 10) {
            NSString *birthdaySring = [appController.currentUser objectForKey:@"user_birthday"];
            NSArray  *birthdayArray = [birthdaySring componentsSeparatedByString:@"/"];
            birthdayYear = [[birthdayArray[2] stringByReplacingOccurrencesOfString:@"" withString:@""] integerValue];
        }        
        
    }
    
  
    NSString *age = [NSString stringWithFormat:@"%ld", currentYear - birthdayYear];
    
    NSString *strAgeGender = [NSString stringWithFormat:@"%@, %@", age, strGender];
    _userGenderAgeLabel.text = strAgeGender;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickContinueBtn:(id)sender {
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[appController.currentUser objectForKey:@"user_facebook_id"] forKey:@"user_facebook_id"];
    [userInfo setObject:[appController.currentUser objectForKey:@"user_qbid"] forKey:@"user_qbid"];
    
    [commonUtils showActivityIndicatorColored:self.view];
    [NSThread detachNewThreadSelector:@selector(requestData:) toTarget:self withObject:userInfo];

    
}

#pragma mark - API Request - User Signup After FB Login

- (void) requestData:(id)params{
    
    NSDictionary *resObj = nil;
    resObj = [commonUtils httpJsonRequest:API_URL_GET_ALL_USER withJSON:(NSMutableDictionary *) params];
    [commonUtils hideActivityIndicator];
    if (resObj != nil) {
        NSDictionary *result = (NSDictionary*)resObj;
        NSDecimalNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 0) {
            
            NSMutableArray *allUsers = [[NSMutableArray alloc] init];
            allUsers = [result objectForKey:@"all_users"];
            
            matchesUserArray = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *tempUser = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < [allUsers count]; i++) {
                
                tempUser = [allUsers objectAtIndex:i];
                NSString *userCurrentID = [tempUser objectForKey:@"user_id"];
                if (![userCurrentID isEqualToString:[appController.currentUser objectForKey:@"user_id"]]) {
                    
                    [matchesUserArray addObject:tempUser];
                }
            }

            if ([matchesUserArray count] != 0) {
                
                appController.allUser = matchesUserArray;
                [self performSelector:@selector(requestOver) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
            } else{
                
                [commonUtils showVAlertSimple:@"Warning" body:@"No your matching users" duration:1.2];
            }
            
        } else {
            NSString *msg = (NSString *)[resObj objectForKey:@"msg"];
            if([msg isEqualToString:@""]) msg = @"Please complete entire form";
            [commonUtils showVAlertSimple:@"Warning" body:msg duration:1.2];
        }
    } else {
        
        [commonUtils showVAlertSimple:@"Connection Error" body:@"Please check your internet connection status" duration:1.0];
    }
    
    
}

- (void) requestOver{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MCMatchViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"matchViewPage"];
        [self.navigationController pushViewController:pageController animated:YES];    });
    
   
}

@end
