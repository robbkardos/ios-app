//
//  ChatMessageTableViewCell.m
//  AmoreDating
//
//  Created by Jose on 11/19/15.
//  Copyright © 2015 Jose. All rights reserved.
//

#import "ChatMessageTableViewCell.h"
#define padding 50
@implementation ChatMessageTableViewCell

static UIImage *redbubble;
static UIImage *greybubble;

+ (void)initialize{
    [super initialize];
    
    // init bubbles
    redbubble = [[UIImage imageNamed:@"redbubble"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
    greybubble = [[UIImage imageNamed:@"greybubble"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
+ (CGFloat)heightForCellWithMessage:(QBChatAbstractMessage *)message
{
    NSString *text = message.text;
    
    
    CGSize  textSize = {260.0, 10000.0};
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:20]
                   constrainedToSize:textSize
                       lineBreakMode:NSLineBreakByWordWrapping];
    
    
    size.height += 55.0;
    return size.height;
    //    UITextView *textView = [[UITextView alloc] init];
    //    textView.text = message.text;
    //    CGSize size = [textView sizeThatFits:CGSizeMake(appController.ww*3/4.0, 10000)];
    //    return size.height+50;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setFrame:CGRectMake(10, 5, 300, 20)];
        [self.dateLabel setFont:[UIFont systemFontOfSize:11.0]];
        [self.dateLabel setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.dateLabel];
        
        self.backgroundImageView = [[UIImageView alloc] init];
        [self.backgroundImageView setFrame:CGRectZero];
        [self.contentView addSubview:self.backgroundImageView];
        self.photoImage = [[UIImageView alloc] init];
        [self.photoImage setFrame:CGRectZero];
        self.photoImage.layer.cornerRadius = padding/2;
        [self.contentView addSubview:self.photoImage];
        
        self.messageTextView = [[UITextView alloc] init];
        [self.messageTextView setBackgroundColor:[UIColor clearColor]];
        [self.messageTextView setEditable:NO];
        [self.messageTextView setScrollEnabled:NO];
        [self.messageTextView sizeToFit];
        [self.contentView addSubview:self.messageTextView];
    }
    return self;
}
- (void)configureCellWithMessage:(QBChatAbstractMessage *)message{
    self.messageTextView.text = message.text;
    self.photoImage.layer.cornerRadius = padding/4.0;
    
    
    CGSize textSize = { appController.ww*3/4.0, 10000.0 };
    
    CGSize size = [self.messageTextView.text sizeWithFont:[UIFont boldSystemFontOfSize:25]
                                        constrainedToSize:textSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
    [ self.messageTextView setFont:[UIFont systemFontOfSize:20]];
    
    size.width = appController.ww*3/4;
    self.messageTextView.textAlignment = NSTextAlignmentCenter;
    int spaceval = 5;
    //NSString *time = [message.datetime timeAgoSinceNow];
    
    NSString *time = @"";
    
    // Left/Right bubble
    if ([ChatService shared].currentUser.ID == message.senderID) {
        
        [self.messageTextView setFrame:CGRectMake(padding+10, 10, size.width, size.height+10)];
        [self.messageTextView sizeToFit];
        
        [self.backgroundImageView setFrame:CGRectMake(padding-spaceval, 10-spaceval, size.width+2*spaceval, size.height+2*spaceval)];
        self.backgroundImageView.image = greybubble;
        
        
        [ self.photoImage setFrame:CGRectMake(0, size.height, padding, padding)];
        [commonUtils cropCircleImage:self.photoImage];
        
        NSString *imageUrl = [appController.currentUser objectForKey:@"user_profilephoto_url"];
        [commonUtils setImageViewAFNetworking:self.photoImage withImageUrl:imageUrl withPlaceholderImage:nil];
        
        self.dateLabel.textAlignment = NSTextAlignmentLeft;

        
    } else {
        
        [self.messageTextView setFrame:CGRectMake(appController.ww-size.width-padding+10, 10, size.width, size.height+10)];
        [self.messageTextView sizeToFit];
        
        [self.backgroundImageView setFrame:CGRectMake(appController.ww-size.width-padding-spaceval, 10-spaceval, size.width+2*spaceval, size.height+2*spaceval)];
        self.backgroundImageView.image = redbubble;
        
        [ self.photoImage setFrame:CGRectMake(appController.ww-padding, size.height, padding, padding)];
        [commonUtils cropCircleImage:self.photoImage]; 
        
        NSString *imageUrl = [appController.chatUser objectForKey:@"user_profilephoto_url"];
        [commonUtils setImageViewAFNetworking:self.photoImage withImageUrl:imageUrl withPlaceholderImage:nil];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        
        QBUUser *sender = [ChatService shared].usersAsDictionary[@(message.senderID)];
        //    self.dateLabel.text = [NSString stringWithFormat:@"%@, %@", sender.login == nil ? (sender.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)sender.ID] : sender.fullName) : sender.login, time];
    }
    
}
@end
