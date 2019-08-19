//
//  TCPUpdateMsgStatusResponse.m
//  TCPMessageServer
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPUpdateMsgStatusResponse.h"
#import "Messages+CoreDataClass.h"
#import "User+CoreDataClass.h"

@interface TCPUpdateMsgStatusResponse ()

@property (nonatomic, readwrite) NSString * msgUID;
@property (nonatomic, readwrite) NSNumber * messageStatus;
@property (nonatomic, readwrite) NSDate * updateTime;
@property (nonatomic, readwrite) NSDictionary * responseData;
@end


@implementation TCPUpdateMsgStatusResponse
@dynamic responseData;

-(instancetype)initWithRequest:(NSDictionary *)dictRequest {
    self = [super initWithRequest:dictRequest];
    if (self) {
        NSDictionary * dictRequestData = dictRequest[@"requestData"];
        self.msgUID = dictRequestData[@"msgUID"];
        self.messageStatus = dictRequestData[@"newStatus"];
        self.updateTime = [TCPMessageUpdateManager getDateFrom:dictRequestData[@"time"]];
        
    }
    return self;
}

-(void)processesClientRequest{
    [super processesClientRequest];
    NSMutableDictionary * responseDict = self.responseData.mutableCopy;
    
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgUID == %@",self.msgUID];
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"Messages" predicate:predicate moc:moc];
    
    if (arrResult.count == 1) {
        Messages * newMessages = (Messages *)arrResult.firstObject;
        newMessages.status = self.messageStatus.intValue;
        newMessages.updated = self.updateTime;
        [TCPMessageUpdateManager saveContext:moc];
        responseDict[@"responseData"] = @{@"isError":@(0),@"message":@"Update Status",};
        
        if (newMessages.fromUser.status > 0) {
            NSMutableDictionary * dictUser = [NSMutableDictionary new];
            dictUser[@"requestType"] = @"Broadcast";
            dictUser[@"broadcastType"] = @"UpdateMsgStatus";
            dictUser[@"broadcastData"] = @{@"msgUID":newMessages.msgUID,@"status":self.messageStatus,@"time":[TCPMessageUpdateManager getStringDateFrom:self.updateTime]};
            [self addBrodcastResponseDataWith:(int)newMessages.fromUser.tcpID broadcastData:dictUser];
        }
    }
    else{
        responseDict[@"responseData"] = @{@"isError":@(1),@"message":@"Error in Update Status"};
    }
    self.responseData = responseDict.copy;
}
@end
