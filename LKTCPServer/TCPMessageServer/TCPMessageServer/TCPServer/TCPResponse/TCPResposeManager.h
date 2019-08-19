//
//  TCPResposeManager.h
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPRequestType.h"
#import "TCPMessageUpdateManager.h"

@interface TCPResposeManager : NSObject

@property (nonatomic, readonly) NSNumber * requestID;
@property (nonatomic, readonly) TCPRequestType requestType;
@property (nonatomic, readonly) NSString * requestData;
@property (nonatomic, readonly) NSDictionary * responseData;
@property (nonatomic, readonly) NSManagedObjectContext * managedObjectContext;
-(instancetype)initWithRequest:(NSDictionary *)dictRequest;
-(void)processesClientRequest;
-(NSString *)getResponseData;
-(void)addBrodcastResponseDataWith:(int)tcpID broadcastData:(NSDictionary *)dictBroadcast;
-(NSArray *)getBrodcastData;
@end
