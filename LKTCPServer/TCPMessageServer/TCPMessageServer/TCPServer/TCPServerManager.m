//
//  TCPServerManager.m
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPServerManager.h"
#import "TCPServer.h"
#import "TCPResposeManager.h"
#import "TCPMessageUpdateManager.h"
#import "User+CoreDataClass.h"

#import "TCPBroadcastRespose.h"
#import "TCPLoginRespose.h"
#import "TCPLogoffRespose.h"
#import "TCPSignupRespose.h"
#import "TCPGetAllUserRespose.h"
#import "TCPSentMessageResponse.h"
#import "TCPUpdateMsgStatusResponse.h"

@interface TCPServerManager ()<TCPServerListenerDelegate>
@property (nonatomic, strong) TCPServer * objTCPServer;
@end
@implementation TCPServerManager
-(instancetype)initWithPort:(int)port {
    self.objTCPServer = [[TCPServer alloc]initWithPort:port];
    self.objTCPServer.delegate = self;
    return self;
}
-(void)stratServer {
    [self.objTCPServer stratServer];
}
-(void)stopServer {
    [self.objTCPServer stopServer];
}
-(NSString *)processesClientRequest:(NSString *)strRequest withSocketId:(int)socketId {
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[strRequest dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:0 error:NULL];
    TCPRequestType requestType = TCPRequestTypeFromString(jsonObject[@"requestType"]);
    
    TCPResposeManager * response;
    switch (requestType) {
        case TCPRequestTypeLogin:
            response = [[TCPLoginRespose alloc]initWithRequest:jsonObject withSocketId:socketId];
            break;
        case TCPRequestTypeLogoff:
            response = [[TCPLogoffRespose alloc]initWithRequest:jsonObject];
            break;
        case TCPRequestTypeSignup:
            response = [[TCPSignupRespose alloc]initWithRequest:jsonObject];
            break;
        case TCPRequestTypeGetAllUser:
            response = [[TCPGetAllUserRespose alloc]initWithRequest:jsonObject];
            break;
        case TCPRequestTypeSentMessage:
            response = [[TCPSentMessageResponse alloc]initWithRequest:jsonObject];
            break;
        case TCPRequestTypeUpdateMsgStatus:
            response = [[TCPUpdateMsgStatusResponse alloc]initWithRequest:jsonObject];
            break;
        default:
            break;
    }
    if (response) {
        [response processesClientRequest];
        if (response.getBrodcastData != nil && response.getBrodcastData.count > 0) {
            [self sendBroadcast:response.getBrodcastData];
        }
        return [response getResponseData];
    }
    else{
        NSMutableDictionary * responseDict = [NSMutableDictionary new];
        responseDict[@"requestID"] = jsonObject[@"requestID"];
        responseDict[@"requestType"] = jsonObject[@"requestType"];
        responseDict[@"responseData"] = @{@"isError":@(-1),@"message":@"invalid request type"};
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDict
                                                           options:0
                                                             error:nil];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
-(void)sendBroadcast:(NSArray *)arrBroadcast {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (TCPBroadcastRespose * broadcast in arrBroadcast) {
            [self.objTCPServer sentMessageToClient:broadcast.tcpID withMessage:[broadcast getBrodcastResponseData]];
        }
    });
}
-(void)updateNumberOfUsersTCPIds:(NSArray *)numUsersTCP {
}
-(void)didofflinechanale:(int)connfd {
    NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:[TCPMessageDBManager sharedTCPMessageDBManager].persistentContainer.viewContext];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"tcpID == %d",connfd];
    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate moc:moc];
    if (arrResult.count > 0) {
        
        NSString * strGetDate = [TCPMessageUpdateManager getStringDateFrom:[NSDate date]];
        NSDate * date = [TCPMessageUpdateManager getDateFrom:strGetDate];
        [arrResult setValue:date forKey:@"updatedInfo"];
        [arrResult setValue:@(0) forKey:@"status"];
        [TCPMessageUpdateManager saveContext:moc];
        
        User *loginUser = arrResult.firstObject;
        
        NSMutableDictionary *dictUser = [NSMutableDictionary new];
        
        dictUser[@"requestType"] = @"Broadcast";
        dictUser[@"broadcastType"] = @"UpdateUser";
        dictUser[@"broadcastData"] = @{@"displayName":loginUser.displayName,@"userID":loginUser.userID,@"status":@(loginUser.status)};
        [self addBroadCast:dictUser];
    }
}

-(void)addBroadCast:(NSDictionary *)userData{
    //    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID != %@ AND status = %@",self.userName,@(1)];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"status = %@",@(1)];
    
    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate moc:[TCPMessageDBManager sharedTCPMessageDBManager].persistentContainer.viewContext];
    NSMutableArray * arrBroadcast = [NSMutableArray new];
    if (arrResult.count > 0) {
        for (User * objUser in arrResult) {
            [arrBroadcast addObject:[[TCPBroadcastRespose alloc] initWithBroadcastData:userData broadcastID:(int)objUser.tcpID]];
        }
    }
    if (arrBroadcast.count > 0) {
        [self sendBroadcast:arrBroadcast];
    }
}
@end
