//  AppController.h
//  Created by BE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define DEFAULT_QBPASSWORD @"abc123456"
#define kNotificationCreatedChatDialog  @"createdChatDialog"
#define KDAImageURL                     @"ent_image_url"

@interface AppController : NSObject

@property (nonatomic, strong) NSMutableDictionary *currentUser, *apnsMessage, *chatUser;
@property (nonatomic, strong) NSMutableArray *allUser;


// Temporary Variables

// Utility Variables
@property (nonatomic, strong) UIColor *appMainColor, *appSecondColor, *appTextColor, *appThirdColor;
@property (nonatomic, strong) DoAlertView *vAlert;

//chat module
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, strong) NSMutableArray* groupchatDialog;
@property (nonatomic,retain) QBChatDialog* currentDialog;
@property (nonatomic,strong) NSString* user_qbid;

//Temperary Variable
@property (nonatomic,assign) NSUInteger screenwidth,currentdate;
@property (nonatomic, strong) NSMutableArray *users,*usersimage;
@property (nonatomic) int ww,hh, crusts;

+ (AppController *)sharedInstance;
-(void)QBLoginchat:(NSString*)userEmail;
-(void)QBSignup:(NSString*)userEmail;
-(void)QbCreateChat:(NSString *)userEmail;
-(void)QBlogout;

@end