//
//  UserMessageDetailVC.h
//  TCPMessage
//
//  Created by Siya9 on 30/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Message,User;
@interface UserMessageDetailVC : UIViewController
@property (nonatomic, strong) User * toUser;
@end

@interface UserMessageListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * lblUserName;
@property (nonatomic, weak) IBOutlet UILabel * lblMessage;
@property (nonatomic, weak) IBOutlet UILabel * lblMessageTime;
@property (nonatomic, weak) IBOutlet UIView * viewStatus;

-(void)updateViewWithOtherUserMessage:(Message *)objMessage;
-(void)updateViewWithCurrentUserMessage:(Message *)objMessage;
@end
