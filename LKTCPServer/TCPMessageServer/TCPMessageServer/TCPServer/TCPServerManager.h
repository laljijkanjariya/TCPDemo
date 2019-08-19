//
//  TCPServerManager.h
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPServerManager : NSObject
-(instancetype)initWithPort:(int)port;
-(void)stratServer;
-(void)stopServer;

-(NSString *)processesClientRequest:(NSString *)strRequest withSocketId:(int)SocketId;
@end
