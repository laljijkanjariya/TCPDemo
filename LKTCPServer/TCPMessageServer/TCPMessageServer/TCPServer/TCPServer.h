//
//  TCPServer.h
//  TCPServerClint
//
//  Created by Siya9 on 22/12/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol TCPServerListenerDelegate <NSObject>

//-(void)didReceiveMessage:(NSString *)dictMessage;
-(NSString *)processesClientRequest:(NSString *)strRequest withSocketId:(int)socketId;
-(void)updateNumberOfUsersTCPIds:(NSArray *)numUsersTCP;
-(void)didofflinechanale:(int)connfd;
//-(void)didBroadcastListenerError:(NSString *)strError;

@end


@interface TCPServer : NSObject
-(instancetype)initWithPort:(int)port;
-(void)stratServer;
-(void)stopServer;
-(void)sentMessageToClient:(int)tcpID withMessage:(NSString *)strMessage;
@property (nonatomic,weak) id<TCPServerListenerDelegate> delegate;
@end
