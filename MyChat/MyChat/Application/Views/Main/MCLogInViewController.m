//
//  MCLogInViewController.m
//  MyChat
//
//  Created by New Star on 3/1/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "MCLogInViewController.h"
#import "MCMyProfileViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface MCLogInViewController ()

@property (strong, nonatomic) IBOutlet UIButton *fbLogInBtn;
@end

@implementation MCLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   
    [commonUtils setRoundedRectBorderButton:_fbLogInBtn withBorderWidth:0 withBorderColor:[UIColor clearColor] withBorderRadius:_fbLogInBtn.frame.size.height/2.0f];
    
    appController.screenwidth = self.view.bounds.size.width;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateChatDialog:) name:kNotificationCreatedChatDialog object:nil];
    
//    if([commonUtils getUserDefault:@"current_user_user_id"] != nil) {
//        appController.currentUser = [commonUtils getUserDefaultDicByKey:@"current_user"];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[[appController currentUser] objectForKey:@"user_id" ] forKey:KDAImageURL];
//        
//        
//        NSString* userlogin = [[appController.currentUser objectForKey:@"user_email"] stringByReplacingOccurrencesOfString:@" " withString:@""];
//        
//        [appController QBLoginchat:userlogin];
//        
//        return;
//    }}
}

-(void)didCreateChatDialog:(NSNotification *)notification{
    [commonUtils hideActivityIndicator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self navToMainView];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Facebook Login
- (IBAction)onLoginFacebook:(id)sender {
    
    if ([commonUtils getUserDefault:@"user_facebook_id"] != nil && ![[commonUtils getUserDefault:@"user_facebook_id"] isEqualToString:@""]) {
        
        appController.currentUser = [commonUtils getUserDefaultDicByKey:@"current_user"];
        
        NSLog(@"current_user: %@", appController.currentUser);
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self navToMainView];
//        });
//        
//        [self navToMainView];
        [commonUtils showActivityIndicatorColored:self.view];
        [[NSUserDefaults standardUserDefaults] setObject:[[appController currentUser] objectForKey:@"user_id" ] forKey:KDAImageURL];
        
        NSLog(@"current_user : %@", appController.currentUser);
        
        NSString* userlogin = [[appController.currentUser objectForKey:@"user_email"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [appController QBLoginchat:userlogin];
        return;
    }
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_birthday", @"user_photos"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             
             NSLog(@"Logged in with token : @%@", result.token);
             if ([result.grantedPermissions containsObject:@"email"]) {
                 NSLog(@"result is:%@",result);
                 [self fetchUserInfo];
             }
         }
     }];
}

- (void)fetchUserInfo {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken] tokenString]);
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, link, first_name, last_name, picture.type(large), email, birthday, gender, bio, location, friends, hometown, friendlists"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"facebook fetched info : %@", result);
                 
                 NSDictionary *temp = (NSDictionary *)result;
                 NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                 [userInfo setObject:[temp objectForKey:@"id"] forKey:@"user_facebook_id"];
                 
                 [commonUtils setUserDefault:@"user_facebook_id" withFormat:[temp objectForKey:@"id"]];
                 
                 [userInfo setObject:[temp objectForKey:@"email"] forKey:@"user_email"];
                 
                 if([commonUtils checkKeyInDic:@"first_name" inDic:[temp mutableCopy]] || [commonUtils checkKeyInDic:@"last_name" inDic:[temp mutableCopy]]) {
                     
                     NSString *strUserFirstName = [temp objectForKey:@"first_name"];
                     [userInfo setObject:strUserFirstName forKey:@"user_firstname"];
                     
                     NSString *strUserLastName = [temp objectForKey:@"last_name"];
                     [userInfo setObject:strUserLastName forKey:@"user_lastname"];
                     
                     NSString *strUserFullName = [NSString stringWithFormat:@"%@ %@", [temp objectForKey:@"first_name"], [temp objectForKey:@"last_name"]];
                     [userInfo setObject:strUserFullName forKey:@"user_fullname"];
                     
                 }
                 
                 // Get Current User's Age.

                 if([commonUtils checkKeyInDic:@"birthday" inDic:[temp mutableCopy]]) {
                     
                     NSString *birthdayString = [temp objectForKey:@"birthday"];
                     [userInfo setObject:birthdayString forKey:@"user_birthday"];

                 }else{
                     [userInfo setObject:@"" forKey:@"user_birthday"];
                 }
                 
                 NSString *age = @"30";
                 if([commonUtils checkKeyInDic:@"age" inDic:[temp mutableCopy]]) {
                     age = [NSString stringWithFormat:@"%@", [temp objectForKey:@"age"]];
                 }
                 [userInfo setObject:age forKey:@"user_age"];
                 
                 
                NSString *gender = @"1";
                if([commonUtils checkKeyInDic:@"gender" inDic:[temp mutableCopy]]) {
                    if([[temp objectForKey:@"gender"] isEqualToString:@"female"]) gender = @"2";
                }
                [userInfo setObject:gender forKey:@"user_gender"];
                 
                 NSString *fbProfilePhoto = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [temp objectForKey:@"id"]];
                 [userInfo setObject:fbProfilePhoto forKey:@"user_profilephoto_url"];
                 
                 [userInfo setObject:@"2" forKey:@"signup_mode"];
                 [userInfo setObject:@"" forKey:@"user_qbid"];
                 
                 if([commonUtils getUserDefault:@"user_apns_id"] != nil) {
                     [userInfo setObject:[commonUtils getUserDefault:@"user_apns_id"] forKey:@"user_apns_id"];
                     
                     [commonUtils showActivityIndicatorColored:self.view];
                     [self requestData:userInfo];
                    
                 } else {
                     [appController.vAlert doAlert:@"Notice" body:@"Failed to get your device token.\nTherefore, you will not be able to receive notification." duration:2.0f done:^(DoAlertView *alertView) {
                      
                         [userInfo setObject:@"" forKey:@"user_apns_id"];
                         [commonUtils showActivityIndicatorColored:self.view];
                         [self requestData:userInfo];
                        
                     }];
                 }
                 
             } else {
                 NSLog(@"Error %@",error);
             }
         }];
        
    }
    
}

#pragma mark - API Request - User Signup After FB Login

- (void) requestData:(id)params{
    
    NSDictionary *resObj = nil;
    resObj = [commonUtils httpJsonRequest:API_URL_USER_SIGNUP withJSON:(NSMutableDictionary *) params];
    if (resObj != nil) {
        NSDictionary *result = (NSDictionary*)resObj;
        NSDecimalNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 0) {
            
            appController.currentUser = [result objectForKey:@"current_user"];
            NSLog(@"current user : %@", appController.currentUser);

            [commonUtils setUserDefaultDic:@"current_user" withDic:appController.currentUser];
            [[NSUserDefaults standardUserDefaults] setObject:[[appController currentUser] objectForKey:@"user_id" ] forKey:KDAImageURL];
            
            
            NSString* userlogin = [[appController.currentUser objectForKey:@"user_email"] stringByReplacingOccurrencesOfString:@" " withString:@""];

            [appController QBLoginchat:userlogin];
            
            
        } else {
            
           [commonUtils hideActivityIndicator];
            NSString *msg = (NSString *)[resObj objectForKey:@"msg"];
            if([msg isEqualToString:@""]) msg = @"Please complete entire form";
            [commonUtils showVAlertSimple:@"Warning" body:msg duration:1.4];
        }
    } else {
        
        [commonUtils hideActivityIndicator];
        
        [commonUtils showVAlertSimple:@"Connection Error" body:@"Please check your internet connection status" duration:1.0];
    }
    
    
}

- (void) requestOver{
   }

- (void) navToMainView{
    
    MCMyProfileViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfilePage"];
    [self.navigationController pushViewController:pageController animated:YES];

}



@end
