//
//  TCPClinetManager.m
//  TCPMessage
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPClientManager.h"
#import "TCPClient.h"
#import "TCPBroadcastManager.h"

static TCPClientManager * sharedTCPClientManager = nil;

@interface TCPClientManager ()<TCPClientListenerDelegate>{
    TCPClient * client;
    int requestID;
    NSMutableArray * arrRequests;
    TCPBroadcastManager * broadcastManager;
}
@end

@implementation TCPClientManager
+ (TCPClientManager*)sharedTCPClientManager {
    @synchronized(self) {
        if (!sharedTCPClientManager) {
            sharedTCPClientManager = [[TCPClientManager alloc] init];
            sharedTCPClientManager->requestID = 0;
            sharedTCPClientManager->arrRequests = [NSMutableArray new];
            sharedTCPClientManager->broadcastManager = [TCPBroadcastManager sharedTCPBroadcastManager];
        }
    }
    return sharedTCPClientManager;
}

-(void)connectToServer:(NSString *)ipAdd withPort:(int)port {
    if (ipAdd.length > 0 && port > 0) {
        client = [[TCPClient alloc]initWithIp:ipAdd withPort:port];
        client.delegate = self;
    }
}

-(void)sendRequestData:(NSDictionary *)dictRequest forRequest:(NSString *)strRequest withCompletionHandler:(CompletionHandler)completionHandler;
{
    requestID++;
    NSMutableDictionary * dictLogin = [NSMutableDictionary new];
    dictLogin[@"requestType"] = strRequest;
    dictLogin[@"requestID"] = @(requestID);
    dictLogin[@"requestData"] = dictRequest;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictLogin
                                                       options:0
                                                         error:nil];
    NSString * request = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [client sendMessage:request];
    if (completionHandler) {
        dictLogin[@"responseBlock"] = completionHandler;
        [arrRequests addObject:dictLogin];
    }
    NSLog(@"REQUEST %@",dictLogin);
}
-(void)didReceiveMessage:(NSString *)strMessage {
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[strMessage dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:0 error:NULL];
    if (jsonObject) {
        NSLog(@"RESPONSE %@",jsonObject);
        if ([jsonObject[@"requestType"] isEqualToString:@"Broadcast"]) {
            [broadcastManager updateBroadcastMessage:jsonObject];
//            NSLog(@"Broadcast message \n%@",jsonObject);
        }
        else {
            NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"requestID == %@", jsonObject[@"requestID"]];
            NSArray *filteredArray = [arrRequests filteredArrayUsingPredicate:filterPredicate];
            if (filteredArray.count > 0) {
                for (NSDictionary * dictResponse in filteredArray) {
                    CompletionHandler completionHandler = (CompletionHandler)dictResponse[@"responseBlock"];
                    if (completionHandler) {
                        completionHandler(jsonObject);
                        [arrRequests removeObject:dictResponse];
                    }
                }
            }
        }
    }
}
-(void)didBroadcastListenerError:(NSString *)strError {
    NSLog(@"didBroadcastListenerError %@",strError);
}
@end
