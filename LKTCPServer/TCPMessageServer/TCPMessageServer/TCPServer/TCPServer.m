//
//  TCPServer.m
//  TCPServerClint
//
//  Created by Siya9 on 22/12/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import "TCPServer.h"
#import <netinet/in.h>
//#include <sys/xattr.h>

@interface TCPServer (){
    int port;
    BOOL isLisning;
    NSMutableArray<NSNumber *> * arrTCPIDs;
}
@end

@implementation TCPServer
-(instancetype)initWithPort:(int)port{
    self = [super init];
    if (self) {
        [self configure:port];
    }
    return self;
}
-(void)configure:(int)aport{
    port = aport;
}
-(void)stratServer{
    isLisning = true;
    arrTCPIDs = [NSMutableArray new];
    [self lisner];
}
-(void)stopServer{
    [arrTCPIDs removeAllObjects];
    isLisning = FALSE;
}
-(void)lisner{
    int listenfd = 0;
    struct sockaddr_in serv_addr;
    
    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    memset(&serv_addr, '0', sizeof(serv_addr));
    
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(port);
    
    bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    
    listen(listenfd, 10);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"Waiting for connections...");
        [self.delegate updateNumberOfUsersTCPIds:arrTCPIDs];
        while (isLisning)
        {
            __block int connfd = accept(listenfd, (struct sockaddr*)NULL, NULL);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"Connection accepted");
                [arrTCPIDs addObject:@(connfd)];
                [self.delegate updateNumberOfUsersTCPIds:arrTCPIDs];
                char buffer[1024];
                bzero(buffer, 1024);
                NSString *message = @"";
                bool continueReading = true;
                do
                {
                    recv(connfd , buffer , 1024 , 0);
                    int size = (int)strlen(buffer);
                    if (buffer[size-1] == '\n')// && buffer[size-2] == '\\'))
                    {
                        buffer[size-1] = '\0';
                        message = [NSString stringWithFormat: @"%@%s", message, buffer];
                        NSString * strClintResponse = [self.delegate processesClientRequest:message withSocketId:connfd];
                        [self writeDataTo:connfd withMessage:strClintResponse];
//                        char* charClintResponse = (char*)[strClintResponse UTF8String];
//                        write(connfd, charClintResponse, strlen(charClintResponse));
                        message = @"";
                        bzero(buffer, 1024);
                    }
                    else if(size == 0){
                        continueReading = FALSE;
                    }
                    else {
                        message = [NSString stringWithFormat: @"%@%s", message, buffer];
                    }
                }while (continueReading);
                NSLog(@"Connection Closed");
                [arrTCPIDs removeObject:@(connfd)];
                [self.delegate updateNumberOfUsersTCPIds:arrTCPIDs];
                [self.delegate didofflinechanale:connfd];
            });
        }
        
        NSLog(@"Stop listening.");
        [self.delegate updateNumberOfUsersTCPIds:arrTCPIDs];
        close(listenfd);
    });
}
-(void)sentMessageToClient:(int)tcpID withMessage:(NSString *)strMessage {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self writeDataTo:tcpID withMessage:strMessage];
    });
}
-(void)writeDataTo:(int)tcpID withMessage:(NSString *)strMessage {
    @synchronized(self) {
        NSString * strMessageD = [NSString stringWithFormat:@"%@\n",strMessage];
        char* charMessage = (char*)[strMessageD UTF8String];
        write(tcpID, charMessage, strlen(charMessage));
    }
}
//-(void)broadCast:(int)connfd{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        char* answer = [[NSString stringWithFormat:@"broadCast Message %d",connfd] UTF8String];
//        write(connfd, answer, strlen(answer));
//        [self broadCast:connfd];
//    });
//}
//-(void)lisnerWorking{
//    int listenfd = 0;
//    struct sockaddr_in serv_addr;
//    
//    listenfd = socket(AF_INET, SOCK_STREAM, 0);
//    memset(&serv_addr, '0', sizeof(serv_addr));
//    
//    serv_addr.sin_family = AF_INET;
//    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
//    serv_addr.sin_port = htons(port);
//    
//    bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
//    
//    listen(listenfd, 10);
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"Waiting for connections...");
//        while (isLisning)
//        {
//            __block int connfd = accept(listenfd, (struct sockaddr*)NULL, NULL);
//            NSLog(@"Connection accepted");
//            
//            char buffer[1024];
//            bzero(buffer, 1024);
//            NSString *message = @"";
//            bool continueReading = true;
//            
//            do
//            {
//                recv(connfd , buffer , 1024 , 0);
//                int size = (int)strlen(buffer);
//                if (buffer[size-1] == '\n')// && buffer[size-2] == '\\'))
//                {
//                    continueReading = false;
//                    buffer[size-1] = '\0';
//                }
//                message = [NSString stringWithFormat: @"%@%s", message, buffer];
//            }while (continueReading);
//            
//            NSString * strClintMessage = [NSString stringWithFormat:@"Got message from client %@",message];
//            [self.delegate didReceiveMessage:strClintMessage];
//            char* answer = "Hello World";
//            write(connfd, answer, strlen(answer));
//        }
//        
//        NSLog(@"Stop listening.");
//        close(listenfd);
//    });
//}
@end
