//
//  UserSignupVC.m
//  TCPMessage
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "UserSignupVC.h"
#import "TCPClientManager.h"

@interface UserSignupVC (){
    TCPClientManager * clienManager;
}
@property (nonatomic,weak) IBOutlet UITextField * txtDisplayName;
@property (nonatomic,weak) IBOutlet UITextField * txtUsername;
@property (nonatomic,weak) IBOutlet UITextField * txtUserPassword;
@property (nonatomic,weak) IBOutlet UITextField * txtCUserPassword;
@end

@implementation UserSignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    clienManager = [TCPClientManager sharedTCPClientManager];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)btnSignupTappede:(id)sender {
    if (self.txtDisplayName.text.length == 0) {
        self.txtDisplayName.backgroundColor = [UIColor redColor];
    }
    else if (self.txtUsername.text.length == 0) {
        self.txtUsername.backgroundColor = [UIColor redColor];
    }
    else if (self.txtUserPassword.text.length == 0){
        self.txtUserPassword.backgroundColor = [UIColor redColor];
    }
    else if (![self.txtUserPassword.text isEqualToString:self.txtCUserPassword.text]){
        self.txtCUserPassword.backgroundColor = [UIColor redColor];
    }
    else{
        self.txtDisplayName.backgroundColor = [UIColor whiteColor];
        self.txtUsername.backgroundColor = [UIColor whiteColor];
        self.txtUserPassword.backgroundColor = [UIColor whiteColor];
        self.txtCUserPassword.backgroundColor = [UIColor whiteColor];

        [clienManager sendRequestData:@{@"userName":self.txtUsername.text,@"userPassword":self.txtUserPassword.text,@"userDisplayName":self.txtDisplayName.text} forRequest:@"Signup" withCompletionHandler:^(NSDictionary *response) {
            if (response != nil && [response[@"responseData"][@"isError"] intValue] == 0) {
                [self.navigationController popViewControllerAnimated:TRUE];
            }
            else{
                NSLog(@"Signup Response %@",response[@"responseData"][@"message"]);
            }
        }];
    }

}
-(IBAction)btnLoginTappede:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}
@end
