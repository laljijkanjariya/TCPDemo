//
//  TCPBrodcastRespose.h
//  TCPMessageServer
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPResposeManager.h"

@interface TCPBroadcastRespose : TCPResposeManager
@property (nonatomic, readonly) int tcpID;

-(instancetype)initWithBroadcastData:(NSDictionary *)dictBroadcast broadcastID:(int)tcpID;
-(NSString *)getBrodcastResponseData;
@end
