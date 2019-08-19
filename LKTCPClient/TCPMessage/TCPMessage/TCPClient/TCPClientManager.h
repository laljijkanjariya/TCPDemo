//
//  TCPClinetManager.h
//  TCPMessage
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ CompletionHandler)(NSDictionary * response);

@interface TCPClientManager : NSObject
+ (TCPClientManager*)sharedTCPClientManager;
-(void)connectToServer:(NSString *)ipAdd withPort:(int)port;
-(void)sendRequestData:(NSDictionary *)dictRequest forRequest:(NSString *)strRequest withCompletionHandler:(CompletionHandler)completionHandler;
@end
