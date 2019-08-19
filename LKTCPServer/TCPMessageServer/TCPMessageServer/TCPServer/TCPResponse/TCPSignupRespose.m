//
//  TCPSignupRespose.m
//  TCPMessageServer
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPSignupRespose.h"
#import "User+CoreDataClass.h"

@interface TCPSignupRespose ()
@property (nonatomic, readwrite) NSDictionary * responseData;

@property (nonatomic, readwrite) NSString * userDisplayName;
@property (nonatomic, readwrite) NSString * userName;
@property (nonatomic, readwrite) NSString * userPassword;
@end


@implementation TCPSignupRespose
@dynamic responseData;

-(instancetype)initWithRequest:(NSDictionary *)dictRequest {
    self = [super initWithRequest:dictRequest];
    if (self) {
        NSDictionary * dictRequestData = dictRequest[@"requestData"];
        self.userName = dictRequestData[@"userName"];
        self.userPassword = dictRequestData[@"userPassword"];
        self.userDisplayName = dictRequestData[@"userDisplayName"];
    }
    return self;
}

-(void)processesClientRequest{
    [super processesClientRequest];
    NSMutableDictionary * responseDict = self.responseData.mutableCopy;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID == %@",self.userName];
    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate moc:self.managedObjectContext];
    if (arrResult.count > 0) {
        responseDict[@"responseData"] = @{@"isError":@(1),@"message":@"invalid username"};
    }
    else{
        NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];
        User * loginUser = (User *)[TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate isCreate:TRUE moc:moc];
        loginUser.status = 0;
        loginUser.tcpID = 0;
        loginUser.userID = self.userName;
        loginUser.password = self.userPassword;
        loginUser.displayName = self.userDisplayName;
        [TCPMessageUpdateManager saveContext:moc];
        responseDict[@"responseData"] = @{@"isError":@(0),@"message":@"You have been successfully registered and need to logged in."};
    }
    self.responseData = responseDict.copy;
}
@end
