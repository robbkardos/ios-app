//
//  MCChatViewController.m
//  MyChat
//
//  Created by New Star on 3/1/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "MCChatViewController.h"
#import "ChatMessageTableViewCell.h"

@interface MCChatViewController () <UITableViewDataSource, UITableViewDelegate, ChatServiceDelegate, UITextFieldDelegate>{
    
    NSInteger tableheight;
    
}


@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *nav_title;
@end

@implementation MCChatViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [commonUtils setRoundedRectBorderButton:_sendMessageButton withBorderWidth:1.0f withBorderColor:appController.appMainColor withBorderRadius:5.0f];
    
    tableheight = self.messagesTableView.frame.size.height;
    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (appController.currentDialog) {
        _dialog = appController.currentDialog;
        appController.currentDialog = nil;
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickBackBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark
#pragma mark UITextFieldDelegate


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    //   [self.containerScrollView setContentOffset:CGPointMake(0, 220) animated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //  [self.containerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    return [ textField resignFirstResponder];
    
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
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{
        //		self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -250);
        //        self.sendMessageButton.transform = CGAffineTransformMakeTranslation(0, -250);
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -260);
        self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                                  self.messagesTableView.frame.origin.y,
                                                  self.messagesTableView.frame.size.width,
                                                  tableheight - 260);
        [self.messagesTableView reloadData];
        
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
        [self.messagesTableView reloadData];
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



@end
