//
//  MCPreviewChatViewController.m
//  MyChat
//
//  Created by New Star on 3/1/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "MCPreviewChatViewController.h"
#import "MCChatViewController.h"

@interface MCPreviewChatViewController ()

@property (strong, nonatomic) IBOutlet UIButton *ignoreBtn;
@property (strong, nonatomic) IBOutlet UIButton *chatBtn;
@property (strong, nonatomic) IBOutlet UIImageView *mePhotoBackground;
@property (strong, nonatomic) IBOutlet UIImageView *mePhoto;
@property (strong, nonatomic) IBOutlet UILabel *meAgeGenderLabel;
@property (strong, nonatomic) IBOutlet UILabel *meUserNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *youNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *youAgeGenderLabel;
@property (strong, nonatomic) IBOutlet UIImageView *youPhotoBackground;
@property (strong, nonatomic) IBOutlet UIImageView *youPhoto;


@end

@implementation MCPreviewChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [commonUtils setRoundedRectBorderButton:_ignoreBtn withBorderWidth:2.0 withBorderColor:appController.appSecondColor withBorderRadius:_ignoreBtn.frame.size.height/2];
    [commonUtils setRoundedRectBorderButton:_chatBtn withBorderWidth:2.0f withBorderColor:appController.appMainColor withBorderRadius:_chatBtn.frame.size.height/2];
    [commonUtils setRoundedRectBorderImage:_mePhotoBackground withBorderWidth:2.0f withBorderColor:appController.appSecondColor withBorderRadius:_mePhotoBackground.frame.size.height/2];
    [commonUtils setRoundedRectBorderImage:_youPhotoBackground withBorderWidth:2.0f withBorderColor:appController.appMainColor withBorderRadius:_youPhotoBackground.frame.size.height/2];
    [commonUtils cropCircleImage:_mePhoto];
    [commonUtils cropCircleImage:_youPhoto];
    
    [self initData];
    
}

- (void) initData{
    
    NSString *strTempGender =[appController.currentUser objectForKey:@"user_gender"];
    
    UIImage *tempImage;
    if ([strTempGender isEqualToString:@"1"]) {
        tempImage = [UIImage imageNamed:@"user_avatar_male"];
    }else{
        tempImage = [UIImage imageNamed:@"user_avatar_female"];
    }
    
    [commonUtils setImageViewAFNetworking:_mePhoto withImageUrl:[appController.currentUser objectForKey:@"user_profilephoto_url"] withPlaceholderImage:tempImage];
    _meUserNameLabel.text = [appController.currentUser objectForKey:@"user_firstname"];
    
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
        if (string.length != 0) {
            NSString *birthdaySring = [appController.currentUser objectForKey:@"user_birthday"];
            NSArray  *birthdayArray = [birthdaySring componentsSeparatedByString:@"/"];
            birthdayYear = [[birthdayArray[2] stringByReplacingOccurrencesOfString:@"" withString:@""] integerValue];
        }

        
    }
    
    
    NSString *age = [NSString stringWithFormat:@"%ld", currentYear - birthdayYear];
    
    NSString *strAgeGender = [NSString stringWithFormat:@"%@, %@", age, strGender];
    _meAgeGenderLabel.text = strAgeGender;
    
    
    
    // Chat User Init
    
    birthdayYear = 2016;
    
    strTempGender =[appController.chatUser objectForKey:@"user_gender"];

    if ([strTempGender isEqualToString:@"1"]) {
        tempImage = [UIImage imageNamed:@"user_avatar_male"];
    }else{
        tempImage = [UIImage imageNamed:@"user_avatar_female"];
    }
    
    [commonUtils setImageViewAFNetworking:_youPhoto withImageUrl:[appController.chatUser objectForKey:@"user_profilephoto_url"] withPlaceholderImage:tempImage];
    _youNameLabel.text = [appController.chatUser objectForKey:@"user_firstname"];
    
    NSString *strYouGender;
    if ([[appController.chatUser objectForKey:@"user_gender"] isEqualToString:@"1"]) {
        strYouGender = @"Male";
    }else{
        
        strYouGender = @"Female";
    }
    
    if([commonUtils checkKeyInDic:@"user_birthday" inDic:[appController.chatUser mutableCopy]]) {
        
        NSString *string = [appController.chatUser objectForKey:@"user_birthday"];
        if (string.length != 0) {
            NSString *birthdaySring = [appController.chatUser objectForKey:@"user_birthday"];
            NSArray  *birthdayArray = [birthdaySring componentsSeparatedByString:@"/"];
            birthdayYear = [[birthdayArray[2] stringByReplacingOccurrencesOfString:@"" withString:@""] integerValue];
        }
    }
    
    
    NSString *youAge = [NSString stringWithFormat:@"%ld", currentYear - birthdayYear];
    
    NSString *strYouAgeGender = [NSString stringWithFormat:@"%@, %@", youAge, strYouGender];
    _youAgeGenderLabel.text = strYouAgeGender;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickBackBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickChatBtn:(id)sender {
    
//    MCChatViewController* chatController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
    
    NSLog(@"choose------------%@",appController.chatUser);
    //   Create QBChatDialog
    QBChatDialog *chatDialog = [ QBChatDialog new];
    chatDialog.type = QBChatDialogTypePrivate;
    chatDialog.occupantIDs =[ [ NSArray alloc] initWithObjects:[appController.chatUser objectForKey:@"user_qbid"], nil];
    
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        appController.currentDialog = createdDialog;
        //[ self performSegueWithIdentifier:@"chatViewController" sender:self];
        
        MCChatViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
        [self.navigationController pushViewController:pageController animated:YES];
        //[weakSelf.navigationController popViewControllerAnimated:YES];
        
    } errorBlock:^(QBResponse *response) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:response.error.error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
        
    }];

}

@end
