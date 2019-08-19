//
//  TCPRequestType.m
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPRequestType.h"

#define kRequestTypeEnumNamesArray @[@"Unknown",@"Login",@"Logoff",@"Signup",@"GetAllUser",@"SentMessage",@"UpdateMsgStatus"]

NSString *TCPRequestTypeToString(TCPRequestType enumType) {
    return [kRequestTypeEnumNamesArray objectAtIndex:enumType+1];
}

TCPRequestType TCPRequestTypeFromString(NSString *enumString) {
    NSUInteger enumType = [kRequestTypeEnumNamesArray indexOfObject:enumString];
    return (enumType != NSNotFound) ? (TCPRequestType) enumType-1 : TCPRequestTypeUnknown;
}

