//
//  TCPClint.h
//  TCPServerClint
//
//  Created by Siya9 on 22/12/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol TCPClientListenerDelegate <NSObject>

-(void)didReceiveMessage:(NSString *)dictMessage;
-(void)didBroadcastListenerError:(NSString *)strError;

@end

@interface TCPClient : NSObject
@property (assign) BOOL isLisning;
@property (nonatomic,weak) id<TCPClientListenerDelegate> delegate;
- (instancetype)initWithIp:(NSString *)ip withPort:(int)portNumber;
- (void)configureHostName:(NSString *)hostName withPort:(int)portNumber;
- (void)sendMessage:(NSString*)message;
@end
