//
//  TCPRequestType.h
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, TCPRequestType) {
    TCPRequestTypeUnknown = -1,
    TCPRequestTypeLogin,
    TCPRequestTypeLogoff,
    TCPRequestTypeSignup,
    TCPRequestTypeGetAllUser,
    TCPRequestTypeSentMessage,
    TCPRequestTypeUpdateMsgStatus,
};
NSString *TCPRequestTypeToString(TCPRequestType enumType);
TCPRequestType TCPRequestTypeFromString(NSString *enumString);
