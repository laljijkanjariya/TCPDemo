//
//  TCPUserListVC.h
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@interface TCPUserListVC : UIViewController

@end
@interface UserListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * lblUserName;
@property (nonatomic, weak) IBOutlet UILabel * lblUserActive;
@property (nonatomic, weak) IBOutlet UIView * viewStatus;

-(void)updateView:(User*)user;
@end
