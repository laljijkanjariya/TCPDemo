//
//  TCPGetAllUserRespose.m
//  TCPMessageServer
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPGetAllUserRespose.h"
#import "User+CoreDataClass.h"

@interface TCPGetAllUserRespose ()
@property (nonatomic, readwrite) NSDictionary * responseData;

@property (nonatomic, readwrite) NSString * userName;
@end

@implementation TCPGetAllUserRespose
@dynamic responseData;

-(instancetype)initWithRequest:(NSDictionary *)dictRequest {
    self = [super initWithRequest:dictRequest];
    if (self) {
        NSDictionary * dictRequestData = dictRequest[@"requestData"];
        self.userName = dictRequestData[@"userName"];
    }
    return self;
}

-(void)processesClientRequest{
    [super processesClientRequest];
    NSMutableDictionary * responseDict = self.responseData.mutableCopy;
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID == %@ AND password = %@",self.userName,self.userPassword];
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:nil moc:moc];
    NSMutableArray * arrUsers = [NSMutableArray new];
    for (User * objUser in arrResult) {
        [arrUsers addObject:@{@"displayName":objUser.displayName,@"userID":objUser.userID,@"status":@(objUser.status)}];
    }
    responseDict[@"responseData"] = @{@"isError":@(0),@"message":@"",@"Data":arrUsers};
    self.responseData = responseDict.copy;
}
@end
