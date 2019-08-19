//
//  TCPBrodcastRespose.m
//  TCPMessageServer
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPBroadcastRespose.h"

@interface TCPBroadcastRespose ()
@property (nonatomic, readwrite) int tcpID;
@property (nonatomic, readwrite) NSDictionary * dictResponseData;
@end

@implementation TCPBroadcastRespose

-(instancetype)initWithBroadcastData:(NSDictionary *)dictBroadcast broadcastID:(int)tcpID {
    self = [super init];
    if (self) {
        self.dictResponseData = dictBroadcast;
        self.tcpID = tcpID;
    }
    return self;

}
-(NSString *)getBrodcastResponseData {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.dictResponseData
                                                       options:0
                                                         error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
