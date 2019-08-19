//
//  TCPBroadcastManager.h
//  TCPMessage
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPBroadcastManager : NSObject
+ (TCPBroadcastManager*)sharedTCPBroadcastManager;
-(void)updateBroadcastMessage:(NSDictionary *)dictMessage;
@end
