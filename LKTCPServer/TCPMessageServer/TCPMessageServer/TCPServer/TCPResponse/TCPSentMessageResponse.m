//
//  TCPSentMessageResponse.m
//  TCPMessageServer
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPSentMessageResponse.h"
#import "Messages+CoreDataClass.h"
#import "User+CoreDataClass.h"


@interface TCPSentMessageResponse ()

@property (nonatomic, readwrite) NSString * fromUserID;
@property (nonatomic, readwrite) NSString * toUserID;
@property (nonatomic, readwrite) NSString * message;
@property (nonatomic, readwrite) NSDate * messageTime;

@property (nonatomic, readwrite) NSDictionary * responseData;
@end

@implementation TCPSentMessageResponse
@dynamic responseData;

-(instancetype)initWithRequest:(NSDictionary *)dictRequest {
    self = [super initWithRequest:dictRequest];
    if (self) {
        NSDictionary * dictRequestData = dictRequest[@"requestData"];
        self.fromUserID = dictRequestData[@"fromUserID"];
        self.toUserID = dictRequestData[@"toUserID"];
        self.message = dictRequestData[@"message"];
        self.messageTime = [TCPMessageUpdateManager getDateFrom:dictRequestData[@"messageTime"]];
    }
    return self;
}

-(void)processesClientRequest{
    [super processesClientRequest];
    NSMutableDictionary * responseDict = self.responseData.mutableCopy;
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    Messages * newMessages = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:moc];
    
    newMessages.msgUID = newMessages.objectID.URIRepresentation.absoluteString;
    newMessages.message = self.message;
    newMessages.created = self.messageTime;
    newMessages.updated = self.messageTime;
    
    User * fromUser = [TCPMessageUpdateManager getUserFromUserID:self.fromUserID fromMOC:moc];
    User * toUser = [TCPMessageUpdateManager getUserFromUserID:self.toUserID fromMOC:moc];
    
    newMessages.fromUser = fromUser;
    [fromUser addSentMessagesObject:newMessages];
    
    newMessages.toUser = toUser;
    [toUser addRecievedMessageObject:newMessages];
    
    [TCPMessageUpdateManager saveContext:moc];
    
    if (toUser.status > 0) {
        NSMutableDictionary * dictUser = [NSMutableDictionary new];
        dictUser[@"requestType"] = @"Broadcast";
        dictUser[@"broadcastType"] = @"SentMessage";
        dictUser[@"broadcastData"] = @{@"msgUID":newMessages.msgUID,@"message":newMessages.message,@"fromUser":fromUser.userID,@"toUser":toUser.userID,@"updated":[TCPMessageUpdateManager getStringDateFrom:self.messageTime],@"created":[TCPMessageUpdateManager getStringDateFrom:self.messageTime]};
        [self addBrodcastResponseDataWith:(int)toUser.tcpID broadcastData:dictUser];
    }
    responseDict[@"responseData"] = @{@"isError":@(0),@"message":@"",@"Data":newMessages.msgUID};

    self.responseData = responseDict.copy;
}
@end
