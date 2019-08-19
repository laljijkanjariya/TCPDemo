//
//  TCPLoginRespose.h
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPResposeManager.h"

@interface TCPLoginRespose : TCPResposeManager
-(instancetype)initWithRequest:(NSDictionary *)dictRequest withSocketId:(int)SocketId;
@end
