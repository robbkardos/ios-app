//
//  СhatViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, ChatServiceDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate>
{
    NSInteger tableheight;
}

@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *nav_title;
@property (strong, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) IBOutlet UIView *containView;

- (IBAction)sendMessage:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [commonUtils setRoundedRectBorderButton:_sendMessageButton withBorderWidth:1.0f withBorderColor:appController.appMainColor withBorderRadius:5.0f];
    
    [_containView setFrame:CGRectMake(0, 64, _containView.frame.size.width, _containView.frame.size.height)];
    
    tableheight = self.messagesTableView.frame.size.height;
    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (appController.currentDialog) {
        _dialog = appController.currentDialog;
        appController.currentDialog = nil;
    }
    
    appController.hh = self.view.frame.size.height;
    appController.ww = self.view.frame.size.width;
    
    _nav_title.text = [appController.chatUser objectForKey:@"user_firstname"];
    
    [self.containerScrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTappedScreen)]];
    
    [ self.containerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [ChatService shared].delegate = self;
    
    // Set title
    if(self.dialog.type == QBChatDialogTypePrivate){
        QBUUser *recipient = [ChatService shared].usersAsDictionary[@(self.dialog.recipientID)];
        self.nav_title.text = recipient.login == nil ? recipient.email : recipient.login;
    }else{
        self.nav_title.text = self.dialog.name;
    }

    // Join room
    //
    if(self.dialog.type != QBChatDialogTypePrivate){
        [self joinDialog];
    }
    
    // sync messages history
    //
    [self syncMessages];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [ChatService shared].delegate = nil;
    
    [self leaveDialog];
}

- (IBAction)onClickBackBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)animateBottomViewUp:(UIView *)view {
    CGRect newFrame = view.frame;
    newFrame.origin.y -= newFrame.size.height/2 ;
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}
- (void)animateBottomViewDown:(UIView *)view {
    CGRect newFrame = view.frame;
    newFrame.origin.y += newFrame.size.height/2 ;
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}
-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)joinDialog{
    if(![[self.dialog chatRoom] isJoined]){
        [commonUtils showActivityIndicatorColored:self.view];
        [[ChatService shared] joinRoom:[self.dialog chatRoom] completionBlock:^(QBChatRoom *joinedChatRoom) {
            [commonUtils hideActivityIndicator];
        }];
    }
}

- (void)leaveDialog{
    [[self.dialog chatRoom] leaveRoom];
}

- (void)syncMessages{
    NSArray *messages = [[ChatService shared] messagsForDialogId:self.dialog.ID];
    NSDate *lastMessageDateSent = nil;
    if(messages.count > 0){
        QBChatAbstractMessage *lastMsg = [messages lastObject];
        lastMessageDateSent = lastMsg.datetime;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [QBRequest messagesWithDialogID:self.dialog.ID
                    extendedRequest:lastMessageDateSent == nil ? nil : @{@"date_sent[gt]": @([lastMessageDateSent timeIntervalSince1970])}
                            forPage:nil
                       successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
        if(messages.count > 0){
            [[ChatService shared] addMessages:messages forDialogId:self.dialog.ID];
        }
                           
        [weakSelf.messagesTableView reloadData];
        NSInteger count = [[ChatService shared] messagsForDialogId:self.dialog.ID].count;
        if(count > 0){
           [weakSelf.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count-1 inSection:0]
                                         atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    } errorBlock:^(QBResponse *response) {
        
    }];
}

#pragma mark Actions

- (IBAction)sendMessage:(id)sender{
    if(self.messageTextField.text.length == 0){
        return;
    }
    
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = self.messageTextField.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    
    // 1-1 Chat
    if(self.dialog.type == QBChatDialogTypePrivate){
        // send message
        message.recipientID = [self.dialog recipientID];
        message.senderID = [ChatService shared].currentUser.ID;

        [[ChatService shared] sendMessage:message];
        
        // save message
        [[ChatService shared] addMessage:message forDialogId:self.dialog.ID];

    // Group Chat
    }else {
        [[ChatService shared] sendMessage:message toRoom:[self.dialog chatRoom]];
    }
    
    // Reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        NSUInteger i;
        i = [[ChatService shared] messagsForDialogId:self.dialog.ID].count;
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Clean text field
    [self.messageTextField setText:nil];
}

#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[ChatService shared] messagsForDialogId:self.dialog.ID] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if(cell == nil){
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    QBChatAbstractMessage *message = [[ChatService shared] messagsForDialogId:self.dialog.ID][indexPath.row];
    //
    [cell configureCellWithMessage:message];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatAbstractMessage *chatMessage = [[[ChatService shared] messagsForDialogId:self.dialog.ID] objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage];
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{

        CGSize keyboardSize = [[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [ self.containerScrollView setContentOffset:CGPointMake(0, keyboardSize.height) animated:YES];
        self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                                  self.messagesTableView.frame.origin.y,
                                                  self.messagesTableView.frame.size.width,
                                                  tableheight);

    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{
//		self.messageTextField.transform = CGAffineTransformIdentity;
//        self.sendMessageButton.transform = CGAffineTransformIdentity;
        self.bottomView.transform =CGAffineTransformIdentity;
        self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                                  self.messagesTableView.frame.origin.y,
                                                  self.messagesTableView.frame.size.width,
                                                  tableheight);

    }];
}


#pragma mark
#pragma mark ChatServiceDelegate

- (void)chatDidLogin{
    [self joinDialog];
    
    // sync messages history
    //
    [self syncMessages];
}

- (BOOL)chatDidReceiveMessage:(QBChatMessage *)message{
    
    if(message.senderID != self.dialog.recipientID){
        return NO;
    }
    
    // save message
    [[ChatService shared] addMessage:message forDialogId:self.dialog.ID];
    
    // Reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return YES;
}

- (BOOL)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID{
    if(![[self.dialog chatRoom].JID isEqualToString:roomJID]){
        return NO;
    }
    
    // save message
    [[ChatService shared] addMessage:message forDialogId:self.dialog.ID];
    
    // Reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return YES;
}
- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)uploadimage_click:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Take a Photo", @"Photo Library" ,nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self onAddImageFromCamera];
    }else if (buttonIndex == 1)
    {
        [self onAddImageFromLibrary];
    }
}
- (void)onAddImageFromCamera
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}
- (void)onAddImageFromLibrary
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        UIImage *resultImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!resultImage) {
            resultImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
//        NSData* imageData = UIImagePNGRepresentation(resultImage);
//        [QBRequest TUploadFile:imageData fileName:@"image.png" contentType:@"image/png" isPublic:NO successBlock:^(QBResponse* response,QBCBlob* uploadedBlob){
//            NSUInteger uploadedFileID = uploadedBlob.ID;
//            QBChatMessage *message = [[QBChatMessage alloc] init];
//            QBChatAttachment* attachment = [QBChatAttachment new];
//            attachment.type = @"iamge";
//            attachment.ID = [NSString stringWithFormat:@"%lu",(unsigned long)uploadedFileID];
//            [message setAttachments:@[attachment]];
//            
//       
//            NSMutableDictionary *params = [NSMutableDictionary dictionary];
//            params[@"save_to_history"] = @YES;
//            [message setCustomParameters:params];
//            
//            // 1-1 Chat
//            if(self.dialog.type == QBChatDialogTypePrivate){
//                // send message
//                message.recipientID = [self.dialog recipientID];
//                message.senderID = [ChatService shared].currentUser.ID;
//                
//                [[ChatService shared] sendMessage:message];
//                
//                // save message
//                [[ChatService shared] addMessage:message forDialogId:self.dialog.ID];
//                
//                // Group Chat
//            }else {
//                [[ChatService shared] sendMessage:message toRoom:[self.dialog chatRoom]];
//            }
//            
//            // Reload table
//            [self.messagesTableView reloadData];
//            if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
//                [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            }
//
//        }statusBlock:^(QBRequest* request,QBRequestStatus* status){
//        
//        }errorBlock:^(QBResponse* response){
//            
//        }];
        CGFloat maxSize = 256.0f;
        CGFloat width = resultImage.size.width;
        CGFloat height = resultImage.size.height;
        CGFloat newWidth = width;
        CGFloat newHeight = height;
        
        // If any side exceeds the maximun size, reduce the greater side to 1200px and proportionately the other one
        if (width > maxSize || height > maxSize) {
            if (width > height) {
                newWidth = maxSize;
                newHeight = (height*maxSize)/width;
            } else {
                newHeight = maxSize;
                newWidth = (width*maxSize)/height;
            }
        }
        
        // Resize the image
        CGSize newSize = CGSizeMake(newWidth, newHeight);
        UIGraphicsBeginImageContext(newSize);
        [resultImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        QBChatMessage *message = [[QBChatMessage alloc] init];
        message.text = [commonUtils encodeToBase64String:newImage byCompressionRatio:0.0];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"save_to_history"] = @YES;
        [message setCustomParameters:params];
        
        // 1-1 Chat
        if(self.dialog.type == QBChatDialogTypePrivate){
            // send message
            message.recipientID = [self.dialog recipientID];
            message.senderID = [ChatService shared].currentUser.ID;
            
            [[ChatService shared] sendMessage:message];
            
            // save message
            [[ChatService shared] addMessage:message forDialogId:self.dialog.ID];
            
            // Group Chat
        }else {
            [[ChatService shared] sendMessage:message toRoom:[self.dialog chatRoom]];
        }
        
        // Reload table
        [self.messagesTableView reloadData];
        if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
            [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }

    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ScrollView Tap
- (void) onTappedScreen {
    [ self.containerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [_messageTextField resignFirstResponder];
}
@end
