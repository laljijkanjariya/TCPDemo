//
//  TCPResposeManager.m
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPResposeManager.h"
#import "TCPBroadcastRespose.h"

@interface TCPResposeManager ()
@property (nonatomic, readwrite) NSNumber * requestID;
@property (nonatomic, readwrite) TCPRequestType requestType;
@property (nonatomic, readwrite) NSString * requestData;
@property (nonatomic, readwrite) NSDictionary * responseData;
@property (nonatomic, readwrite) NSMutableArray * brodcastResponseData;
@property (nonatomic, readwrite) NSManagedObjectContext * managedObjectContext;
@end

@implementation TCPResposeManager
-(instancetype)initWithRequest:(NSDictionary *)dictRequest {
    self = [super init];
    if (self) {
        self.requestID = dictRequest[@"requestID"];
        self.requestType = TCPRequestTypeFromString(dictRequest[@"requestType"]);
        self.managedObjectContext = [TCPMessageDBManager sharedTCPMessageDBManager].persistentContainer.viewContext;
    }
    return self;
}
-(void)processesClientRequest{
    NSMutableDictionary * responseDict = [NSMutableDictionary new];
    responseDict[@"requestID"] = self.requestID;
    responseDict[@"requestType"] = TCPRequestTypeToString(self.requestType);
    self.responseData = responseDict.copy;
}
-(NSString *)getResponseData{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.responseData
                                                       options:0
                                                         error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
-(void)addBrodcastResponseDataWith:(int)tcpID broadcastData:(NSDictionary *)dictBroadcast {
    if (self.brodcastResponseData == nil) {
        self.brodcastResponseData = [NSMutableArray new];
    }
    TCPBroadcastRespose * broadcast = [[TCPBroadcastRespose alloc]initWithBroadcastData:dictBroadcast broadcastID:tcpID];
    [self.brodcastResponseData addObject:broadcast];
}

-(NSArray *)getBrodcastData {
    return self.brodcastResponseData;
}
@end
