//
//  AppController.m


#import "AppController.h"

static AppController *_appController;

@implementation AppController

+ (AppController *)sharedInstance {
    static dispatch_once_t predicate;
    if (_appController == nil) {
        dispatch_once(&predicate, ^{
            _appController = [[AppController alloc] init];
        });
    }
    return _appController;
}

- (id)init {
    self = [super init];
    if (self) {
        
        // Utility Data
        _appMainColor = RGBA(0, 255, 126, 1.0f);
        _appTextColor = RGBA(255, 255, 255, 1.0f);
        _appSecondColor = [UIColor whiteColor];
        
        _vAlert = [[DoAlertView alloc] init];
        _vAlert.nAnimationType = 2;  // there are 5 type of animation
        _vAlert.dRound = 7.0;
        _vAlert.bDestructive = NO;  // for destructive mode
        
        // Data
        _currentUser = [[NSMutableDictionary alloc] init];
        _chatUser = [[NSMutableDictionary alloc] init];
        _currentDialog = nil;
        _groupchatDialog = [[NSMutableArray alloc] init];
        _allUser = [[NSMutableArray alloc] init];
        
        
    }
    return self;
}


+ (NSDictionary*) requestApi:(NSMutableDictionary *)params withFormat:(NSString *)url {
    return [AppController jsonHttpRequest:url jsonParam:params];
}

+ (id) jsonHttpRequest:(NSString*) urlStr jsonParam:(NSMutableDictionary *)params {
    NSString *paramStr = [commonUtils getParamStr:params];
    //NSLog(@"\n\nparameter string : \n\n%@", paramStr);
    NSData *requestData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];

    NSData *data = nil;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSHTTPURLResponse *response = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: requestData];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
//    NSLog(@"\n\nresponse string : \n\n%@", responseString);
    return [[SBJsonParser new] objectWithString:responseString];
}

-(void)QBLoginchat:(NSString*)userEmail
{
    
    QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
    extendedAuthRequest.userLogin = userEmail;
    extendedAuthRequest.userPassword = DEFAULT_QBPASSWORD;
    //
    //    __weak __typeof(self)weakSelf = self;
    [QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session) {
        // Save current user
        //
        QBUUser *currentUser = [QBUUser user];
        currentUser.ID = session.userID;
        appController.user_qbid = [NSString stringWithFormat:@"%lu",(unsigned long)currentUser.ID];
        [appController.currentUser setObject:appController.user_qbid forKey:@"user_qbid"];
        currentUser.login = userEmail;
        currentUser.password = DEFAULT_QBPASSWORD;
        // Login to QuickBlox Chat
        //
        [[ChatService shared] loginWithUser:currentUser completionBlock:^{
            
            NSLog(@"QB Log in !");
//                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QB Create Session Sucess Login"
//                                                                                    message:@"Sucess"
//                                                                                   delegate:nil
//                                                                          cancelButtonTitle:@"Ok"
//                                                                          otherButtonTitles:nil];
//                                    [alert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCreatedChatDialog object:nil];
        }];
        
    } errorBlock:^(QBResponse *response)
     {
         if (response.status == QBResponseStatusCodeUnAuthorized) {
         }
         else{
             //             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QB Create Session Failed!"
             //                                                                          message:[response.error description]
             //                                                                         delegate:nil
             //                                                                cancelButtonTitle:@"Ok"
             //                                                                otherButtonTitles:nil];
             //                          [alert show];
             //
             //             NSLog(@"QB Create Session Failed!");
             [commonUtils showAlert:@"" withMessage:@"Internet connection error"];
         }
         [self QBSignup:userEmail];
     }];
    
    
}
-(void)QBSignup:(NSString*)userEmail
{
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        
        QBUUser *user = [QBUUser user];
        user.password = DEFAULT_QBPASSWORD;
        user.login = userEmail;
        NSString * user_id =[[NSUserDefaults standardUserDefaults] objectForKey:KDAImageURL] ;
        user.customData =user_id;
        // create User
        [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
            [self QBLoginchat:userEmail];
            
            //                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sucess", "") message:NSLocalizedString(@"Signup sucess", "") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", "") otherButtonTitles:nil];
            //                        [alert show];
            
            //            [self dismissViewControllerAnimated:YES completion:nil];
            
        } errorBlock:^(QBResponse *response) {
            
            //                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
            //                                                                        message:[response.error description]
            //                                                                       delegate:nil
            //                                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
            //                                                              otherButtonTitles:nil];
            //                        [alert show];
            [commonUtils showAlert:@"" withMessage:@"Internet connection error"];
            
            
        }];
        
    } errorBlock:^(QBResponse *response) {
        //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
        //                                                                message:[response.error description]
        //                                                               delegate:nil
        //                                                      cancelButtonTitle:NSLocalizedString(@"OK", "")
        //                                                      otherButtonTitles:nil];
        //                [alert show];
        [commonUtils showAlert:@"" withMessage:@"Internet connection error"];
        
    }];
    
}
-(void)QbCreateChat:(NSString *)userEmail
{
    QBChatDialog *chatDialog = [QBChatDialog new];
    
    NSMutableArray *selectedUsersIDs = [NSMutableArray array];
    NSMutableArray *selectedUsersNames = [NSMutableArray array];
    
    //        chatDialog.photo = user.customData;
    
    chatDialog.occupantIDs = selectedUsersIDs;
    chatDialog.name = userEmail;
    
    chatDialog.type = QBChatDialogTypePrivate;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCreatedChatDialog object:nil];
        
    } errorBlock:^(QBResponse *response) {
        
        //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
        //                                                                message:response.error.error.localizedDescription
        //                                                               delegate:nil
        //                                                      cancelButtonTitle:@"Ok"
        //                                                      otherButtonTitles: nil];
        //                [alert show];
        [commonUtils showAlert:@"" withMessage:@"Internet connection error"];
        
    }];
    
}
-(void)QBlogout
{
    [[ChatService shared] logout];
    [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
        //Successful logout
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                        message:NSLocalizedString(@"Log out success",@"logout success")                                                               delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
        
    } errorBlock:^(QBResponse *response) {
        // Handle error
    }];
}


@end
