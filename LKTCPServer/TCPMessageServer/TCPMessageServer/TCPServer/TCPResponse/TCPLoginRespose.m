//
//  TCPLoginRespose.m
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPLoginRespose.h"
#import "User+CoreDataClass.h"
#import "Messages+CoreDataClass.h"

@interface TCPLoginRespose ()
@property (nonatomic, readwrite) NSDictionary * responseData;

@property (nonatomic, readwrite) NSString * userName;
@property (nonatomic, readwrite) NSString * userPassword;
@property (nonatomic, readwrite) int socketId;
@property (nonatomic, readwrite) NSArray * brodcastResponseData;
@end

@implementation TCPLoginRespose
@dynamic responseData,brodcastResponseData;

-(instancetype)initWithRequest:(NSDictionary *)dictRequest withSocketId:(int)socketId {
    self = [super initWithRequest:dictRequest];
    if (self) {
        NSDictionary * dictRequestData = dictRequest[@"requestData"];
        self.userName = dictRequestData[@"userName"];
        self.userPassword = dictRequestData[@"userPassword"];
        self.socketId = socketId;
    }
    return self;
}

-(void)processesClientRequest{
    [super processesClientRequest];
    NSMutableDictionary * responseDict = self.responseData.mutableCopy;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID == %@ AND password = %@",self.userName,self.userPassword];
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];

    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate moc:moc];
    NSMutableDictionary * dictUser;

    if (arrResult.count == 1) {
        responseDict[@"responseData"] = @{@"isError":@(0),@"message":@"user successfully logged in"};
        User * loginUser = (User *)arrResult.firstObject;
        loginUser.status = 1;
        loginUser.tcpID = self.socketId;
        NSDate * date = loginUser.updatedInfo;
        NSString * strGetDate = [TCPMessageUpdateManager getStringDateFrom:[NSDate date]];
        loginUser.updatedInfo = [TCPMessageUpdateManager getDateFrom:strGetDate];
        [TCPMessageUpdateManager saveContext:moc];
        
        dictUser = [NSMutableDictionary new];
        
        dictUser[@"requestType"] = @"Broadcast";
        dictUser[@"broadcastType"] = @"UpdateUser";
        dictUser[@"broadcastData"] = @{@"displayName":loginUser.displayName,@"userID":loginUser.userID,@"status":@(loginUser.status)};
        
        if (date != nil) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(fromUser.userID == %@ OR toUser.userID == %@) AND updated >= %@",loginUser.userID,loginUser.userID,date];
            //        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fromUser.userID == %@ OR toUser.userID == %@",loginUser.userID,loginUser.userID];
            
            NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"Messages" predicate:predicate moc:moc];
            
            [self addMessageBroadcast:arrResult];
        }
    }
    else{
        responseDict[@"responseData"] = @{@"isError":@(1),@"message":@"invalid username or password"};
    }
    
    if (dictUser != nil) {
        [self addBroadCast:dictUser];
    }
    self.responseData = responseDict.copy;
}
-(void)addMessageBroadcast:(NSArray *)arrMessage {
    for (Messages * objMessage in arrMessage) {
        NSMutableDictionary * dictUser = [NSMutableDictionary new];
        dictUser[@"requestType"] = @"Broadcast";
        dictUser[@"broadcastType"] = @"SentMessage";
        dictUser[@"broadcastData"] = @{@"msgUID":objMessage.msgUID,@"message":objMessage.message,@"status":@(objMessage.status),@"fromUser":objMessage.fromUser.userID,@"toUser":objMessage.toUser.userID,@"updated":[TCPMessageUpdateManager getStringDateFrom:objMessage.updated],@"created":[TCPMessageUpdateManager getStringDateFrom:objMessage.created]};
        [self addBroadCast:dictUser];

    }
}
-(void)addBroadCast:(NSDictionary *)userData{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID != %@ AND status = %@",self.userName,@(1)];
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"status = %@",@(1)];

    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate moc:self.managedObjectContext];
    if (arrResult.count > 0) {
        for (User * objUser in arrResult) {
            [self addBrodcastResponseDataWith:(int)objUser.tcpID broadcastData:userData];
        }
    }
}

@end
