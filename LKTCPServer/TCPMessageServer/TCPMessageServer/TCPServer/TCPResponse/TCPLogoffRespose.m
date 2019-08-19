//
//  TCPLogoffRespose.m
//  TCPMessageServer
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPLogoffRespose.h"
#import "User+CoreDataClass.h"
@interface TCPLogoffRespose ()
@property (nonatomic, readwrite) NSDictionary * responseData;

@property (nonatomic, readwrite) NSString * userName;
@end

@implementation TCPLogoffRespose
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
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID == %@",self.userName];
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];

    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate moc:moc];
    NSMutableDictionary * dictUser;
    
    if (arrResult.count == 1) {
        responseDict[@"responseData"] = @{@"isError":@(0),@"message":@"user successfully logoff"};
        User * loginUser = (User *)arrResult.firstObject;
        loginUser.status = 0;
        loginUser.tcpID = 0;
        NSString * strGetDate = [TCPMessageUpdateManager getStringDateFrom:[NSDate date]];
        loginUser.updatedInfo = [TCPMessageUpdateManager getDateFrom:strGetDate];

        [TCPMessageUpdateManager saveContext:moc];
        
        dictUser = [NSMutableDictionary new];
        
        dictUser[@"requestType"] = @"Broadcast";
        dictUser[@"broadcastType"] = @"UpdateUser";
        dictUser[@"broadcastData"] = @{@"displayName":loginUser.displayName,@"userID":loginUser.userID,@"status":@(loginUser.status)};
    }
    else{
        responseDict[@"responseData"] = @{@"isError":@(1),@"message":@"can't we log off you"};
    }
    
    if (dictUser != nil) {
        [self addBroadCast:dictUser];
    }
    self.responseData = responseDict.copy;
}
-(void)addBroadCast:(NSDictionary *)userData{
    //    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID != %@ AND status = %@",self.userName,@(1)];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"status = %@",@(1)];
    
    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate moc:self.managedObjectContext];
    if (arrResult.count > 0) {
        for (User * objUser in arrResult) {
            [self addBrodcastResponseDataWith:(int)objUser.tcpID broadcastData:userData];
        }
    }
}
@end
