//
//  TCPBroadcastManager.m
//  TCPMessage
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPBroadcastManager.h"
#import "TCPMessageUpdateManager.h"
#import "User+CoreDataClass.h"
#import "Message+CoreDataClass.h"
#import "TCPClientManager.h"

static TCPBroadcastManager * sharedTCPBroadcastManager = nil;

@interface TCPBroadcastManager () {
    NSManagedObjectContext * managedObjectContext;
}
@end
@implementation TCPBroadcastManager
+ (TCPBroadcastManager*)sharedTCPBroadcastManager {
    @synchronized(self) {
        if (!sharedTCPBroadcastManager) {
            sharedTCPBroadcastManager = [[TCPBroadcastManager alloc] init];
            sharedTCPBroadcastManager->managedObjectContext = [TCPMessageDBManager sharedTCPMessageDBManager].persistentContainer.viewContext;
        }
    }
    return sharedTCPBroadcastManager;
}
-(void)updateBroadcastMessage:(NSDictionary *)dictMessage {
    if ([dictMessage[@"broadcastType"] isEqualToString:@"UpdateUser"]) {
        [self updateUserDetail:dictMessage[@"broadcastData"]];
    }
    else if ([dictMessage[@"broadcastType"] isEqualToString:@"SentMessage"]) {
        [self recievedMessage:dictMessage[@"broadcastData"]];
    }
    else if ([dictMessage[@"broadcastType"] isEqualToString:@"UpdateMsgStatus"]) {
        [self updateMessageStatus:dictMessage[@"broadcastData"]];
    }
}
-(void)updateUserDetail:(NSDictionary *)dictMessage {
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:managedObjectContext];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID == %@",dictMessage[@"userID"]];
    User * user = (User *)[TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate isCreate:TRUE moc:moc];
    if (user) {
        if ([dictMessage objectForKey:@"displayName"]) {
            user.displayName = dictMessage[@"displayName"];
        }
        if ([dictMessage objectForKey:@"displayName"]) {
            user.status = [dictMessage[@"status"] intValue];
        }
    }

    [TCPMessageUpdateManager saveContext:moc];
}
-(void)recievedMessage:(NSDictionary *)dictMessage {
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:managedObjectContext];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"serverID == %@",dictMessage[@"msgUID"]];
    
    Message * newMessages = (Message *)[TCPMessageUpdateManager fetchEntitysWithName:@"Message" predicate:predicate isCreate:false moc:moc];
    if (newMessages == nil) {
        newMessages = (Message *)[TCPMessageUpdateManager fetchEntitysWithName:@"Message" predicate:predicate isCreate:TRUE moc:moc];
        User * fromUser = [TCPMessageUpdateManager getUserFromUserID:dictMessage[@"fromUser"] fromMOC:moc];
        User * toUser = [TCPMessageUpdateManager getUserFromUserID:dictMessage[@"toUser"] fromMOC:moc];
        
        newMessages.serverID = dictMessage[@"msgUID"];
        newMessages.message = dictMessage[@"message"];
        newMessages.fromUser = fromUser;
        newMessages.toUser = toUser;
        newMessages.created = [TCPMessageUpdateManager getDateFrom:dictMessage[@"created"]];
        [fromUser addSentMessagesObject:newMessages];
        [toUser addRecievedMessageObject:newMessages];

    }
    
    newMessages.updated = [TCPMessageUpdateManager getDateFrom:dictMessage[@"updated"]];
    if ([dictMessage objectForKey:@"status"]) {
        newMessages.status = [dictMessage[@"status"] intValue];
    }
    else{
        newMessages.status = 1;
    }
    
    [TCPMessageUpdateManager saveContext:moc];
    NSString * strTime = [TCPMessageUpdateManager getStringDateFrom:[NSDate date]];
    if (newMessages.status == 1) {
        [self conformToServerRequest:@{@"msgUID":newMessages.serverID,@"newStatus":@(1),@"time":strTime} forRequest:@"UpdateMsgStatus" withCompletionHandler:nil];
    }
}
-(void)updateMessageStatus:(NSDictionary *)dictMessage {
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:managedObjectContext];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"serverID == %@",dictMessage[@"msgUID"]];

    Message * messageStatus = (Message *)[TCPMessageUpdateManager fetchEntitysWithName:@"Message" predicate:predicate isCreate:FALSE moc:moc];

    messageStatus.status = [dictMessage[@"status"] intValue];
    messageStatus.updated = [TCPMessageUpdateManager getDateFrom:dictMessage[@"updated"]];
    
    [TCPMessageUpdateManager saveContext:moc];
}
-(void)conformToServerRequest:(NSDictionary *)dictRquest forRequest:(NSString *)strRequest withCompletionHandler:(CompletionHandler)completionHandler {
    [[TCPClientManager sharedTCPClientManager] sendRequestData:dictRquest forRequest:strRequest withCompletionHandler:completionHandler];
}
@end
