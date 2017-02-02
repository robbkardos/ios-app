//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "DialogsViewController.h"
#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"
#import "UsersViewController.h"
//#import "UIImageView+WebCache.h"
//#import "UIView+WebCacheOperation.h"
//#import "UIImage+ImageEffects.h"
//#import "AccountViewController.h"
@interface DialogsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;

@end

@implementation DialogsViewController

#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dialogUpdated:)
                                                 name:kDialogUpdatedNotification object:nil];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    if([ChatService shared].currentUser != nil){
        // get dialogs
        //
        [SVProgressHUD showWithStatus:@"Loading"];
        __weak __typeof(self)weakSelf = self;
        [[ChatService shared] requestDialogsWithCompletionBlock:^{
            [weakSelf.dialogsTableView reloadData];
            [SVProgressHUD dismiss];
        }];
    }

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Show splash
//        [self.navigationController performSegueWithIdentifier:kShowSplashViewControllerSegue sender:nil];
//        [Appdelegate loginQBchat:@"cha1"];
    });
    
    if(self.createdDialog != nil){
//        [self performSegueWithIdentifier:kShowNewChatViewControllerSegue sender:nil];
    }
}


#pragma mark
#pragma mark Actions

- (IBAction)createDialog:(id)sender{
    UsersViewController * controller = [self.storyboard instantiateViewControllerWithIdentifier:@"usersVC"];
    controller.dialogsViewController = self;
    [self.navigationController pushViewController:controller animated:YES];
//    [self performSegueWithIdentifier:kShowUsersViewControllerSegue sender:nil];
    
}


#pragma mark
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.destinationViewController isKindOfClass:ChatViewController.class]){
        ChatViewController *destinationViewController = (ChatViewController *)segue.destinationViewController;
        
        if(self.createdDialog != nil){
            destinationViewController.dialog = self.createdDialog;
            self.createdDialog = nil;
        }else{
            QBChatDialog *dialog = [ChatService shared].dialogs[((UITableViewCell *)sender).tag];
            destinationViewController.dialog = dialog;
        }
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[ChatService shared].dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"];
    
    QBChatDialog *chatDialog = [ChatService shared].dialogs[indexPath.row];
    cell.tag  = indexPath.row;
    
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate:{
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            QBUUser *recipient = [ChatService shared].usersAsDictionary[@(chatDialog.recipientID)];
            cell.textLabel.text = recipient.login == nil ? (recipient.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)recipient.ID] : recipient.fullName) : recipient.login;
//            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:chatDialog.photo]
//                              placeholderImage:[UIImage imageNamed:@"user_image.png"]
//                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
//                                         if (!error)
//                                         {
//                                             NSLog(@"Photo Successful Loaded");
//                                             //                                       [activityIndicator stopAnimating];
//                                         }
//                                         else
//                                         {
//                                             NSLog(@"Photo Not Successful Loaded\n, %@", error);
//                                             //                                       [activityIndicator stopAnimating];
//                                         }
//                                     }];

        }
            break;
        case QBChatDialogTypeGroup:{
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            cell.textLabel.text = chatDialog.name;
            cell.imageView.image = [UIImage imageNamed:@"chatRoomIcon.png"];
        }
            break;
        case QBChatDialogTypePublicGroup:{
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            cell.textLabel.text = chatDialog.name;
            cell.imageView.image = [UIImage imageNamed:@"chatRoomIcon.png"];
        }
            break;
            
        default:
            break;
    }
    
    // set unread badge
    UILabel *badgeLabel = (UILabel *)[cell.contentView viewWithTag:201];
    if(chatDialog.unreadMessagesCount > 0){
        badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)chatDialog.unreadMessagesCount];
        badgeLabel.hidden = NO;
        
        badgeLabel.layer.cornerRadius = 10;
        badgeLabel.layer.borderColor = [[UIColor blueColor] CGColor];
        badgeLabel.layer.borderWidth = 1;
    }else{
        badgeLabel.hidden = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark
#pragma Notifications

- (void)dialogUpdated:(NSNotification *)notification{
    NSString *dialogId = notification.userInfo[@"dialog_id"];
    
    __weak __typeof(self)weakSelf = self;
    [[ChatService shared] requestDialogUpdateWithId:dialogId completionBlock:^{
        [weakSelf.dialogsTableView reloadData];
    }];
}
- (IBAction)back_btn:(id)sender {
   
}



@end
