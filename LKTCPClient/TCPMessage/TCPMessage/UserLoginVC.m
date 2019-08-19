//
//  UserLoginVC.m
//  TCPMessage
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "UserLoginVC.h"
#import "TCPClientManager.h"
#import "UserListVC.h"

@interface UserLoginVC (){
    TCPClientManager * clienManager;
}
@property (nonatomic,weak) IBOutlet UITextField * txtUsername;
@property (nonatomic,weak) IBOutlet UITextField * txtUserPassword;
@end

@implementation UserLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    clienManager = [TCPClientManager sharedTCPClientManager];
    [clienManager connectToServer:@"192.168.0.218" withPort:6633];
    
    NSDictionary* dictUserDetail = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginDetail"];
    if (dictUserDetail != nil) {
        self.txtUsername.text = dictUserDetail[@"UserID"];
        self.txtUserPassword.text = dictUserDetail[@"UserPassword"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)btnLoginTappede:(id)sender {
    if (self.txtUsername.text.length == 0) {
        self.txtUsername.backgroundColor = [UIColor redColor];
    }
    else if (self.txtUserPassword.text.length == 0){
        self.txtUserPassword.backgroundColor = [UIColor redColor];
    }
    else{
        NSMutableDictionary * dictLoging = [NSMutableDictionary new];

        dictLoging[@"UserID"] = self.txtUsername.text;
        dictLoging[@"UserPassword"] = self.txtUserPassword.text;
        [[NSUserDefaults standardUserDefaults] setObject:dictLoging forKey:@"LoginDetail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.txtUsername.backgroundColor = [UIColor whiteColor];
        self.txtUserPassword.backgroundColor = [UIColor whiteColor];
        [clienManager sendRequestData:@{@"userName":self.txtUsername.text,@"userPassword":self.txtUserPassword.text} forRequest:@"Login" withCompletionHandler:^(NSDictionary *response) {
            if (response != nil && [response[@"responseData"][@"isError"] intValue] == 0) {
                NSLog(@"Login Response %@",response[@"responseData"][@"message"]);
                UserListVC * objUserListVC =
                [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"UserListVC_sid"];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.txtUsername.text forKey:@"userName"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.navigationController pushViewController:objUserListVC animated:TRUE];
            }
            else{
                NSLog(@"Login Response %@",response[@"responseData"][@"message"]);
            }
        }];
    }
}

@end
