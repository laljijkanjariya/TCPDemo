//
//  UserListVC.h
//  TCPMessage
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+CoreDataClass.h"

@interface UserListVC : UIViewController

@end
@interface UserListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * lblUserName;
@property (nonatomic, weak) IBOutlet UILabel * lblUserActive;
@property (nonatomic, weak) IBOutlet UIView * viewStatus;

-(void)updateView:(User*)user;
@end
