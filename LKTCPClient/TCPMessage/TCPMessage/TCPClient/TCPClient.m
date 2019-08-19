//
//  TCPClint.m
//  TCPServerClint
//
//  Created by Siya9 on 22/12/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import "TCPClient.h"
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
@interface TCPClient ()<NSStreamDelegate> {
    int port;
    NSString *host;
    NSString* messageDelimiter;
    BOOL isInputConnected;
    BOOL isOutPutConnected;
}
@property (nonatomic, strong, readwrite) NSMutableData *inputBuffer;
@property (atomic, strong, readwrite) NSMutableData *outputBuffer;
@property (nonatomic, strong, readwrite) NSInputStream *inputStream;
@property (nonatomic, strong, readwrite) NSOutputStream *outputStream;

@end

@implementation TCPClient

- (instancetype)initWithIp:(NSString *)ip withPort:(int)portNumber {
    self = [super init];
    if (self) {
        [self configureHostName:ip withPort:portNumber];
    }
    return self;
}

- (void)configureHostName:(NSString *)hostName withPort:(int)portNumber  {
    // This might come from some configuration store or Bonjour.
    host = hostName;
    port = portNumber;
    messageDelimiter = @"\n";
    [self openConnection];
}
- (BOOL)openConnection {
    // Nothing is open at the moment.
    
    // Setup socket connection
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(nil,
                                       (__bridge CFStringRef)host, port,
                                       &readStream, &writeStream);
    
    if (readStream == nil || writeStream == nil)
        return NO;
    
    // Indicate that we want socket to be closed whenever streams are closed.
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket,
                            kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket,
                             kCFBooleanTrue);
    
    // Setup input stream.
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    
    // Setup output stream.
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    self.outputStream.delegate = self;
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
    
    // Setup buffers.
    self.inputBuffer = [[NSMutableData alloc] init];
    self.outputBuffer = [[NSMutableData alloc] init];
    
    return YES;
}
//-(void)isLiveMessage{
//    return;
//    if (isOutPutConnected && isInputConnected) {
//        [self sendMessage:@"Clint Is Live"];
//        [self performSelector:@selector(isLiveMessage) withObject:nil afterDelay:25];
//    }
//}
- (void)sendMessage:(NSString*)message {
    [self.outputBuffer appendBytes:[message cStringUsingEncoding:NSASCIIStringEncoding]
                            length:[message length]];
    [self.outputBuffer appendBytes:[messageDelimiter cStringUsingEncoding:NSASCIIStringEncoding]
                            length:[message length]];
    [self writeOutputBufferToStream];
}

- (void)writeOutputBufferToStream {
    // Do we have anything to write?
    if ([self.outputBuffer length] == 0)
        return;
    
    // Can stream take any data in?
    if (![self.outputStream hasSpaceAvailable])
        return;
    
    // Write as much data as we can.
    NSInteger bytesWritten = [self.outputStream write:[self.outputBuffer bytes]
                                            maxLength:[self.outputBuffer length]];
    
    // Check for errors.
    if (bytesWritten == -1)  {
        return;
    }
    
    // Remove it from the buffer.
    [self.outputBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten)
                                 withBytes:NULL
                                    length:0];
//    [self startOutput];
}
- (void)startOutput
{
    
    // Write to stream
    NSInteger actuallyWritten = [self.outputStream write:self.outputBuffer.bytes maxLength:self.outputBuffer.length];
    //    NSLog(@"%ld byte written,", actuallyWritten);
    
    if (actuallyWritten > 0) {
        [self.outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) actuallyWritten) withBytes:NULL length:0];
    } else {
        // A non-positive result from -write:maxLength: indicates a failure of some form; in this
        // simple app we respond by simply closing down our connection.
        //        [self closeStreams];
        
        // Flush the buffer
        [self.outputBuffer setData:[NSData data]];
    }
    
}

#pragma mark - NSStreamDelegate methods

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
    
    if (stream == self.inputStream) {
        switch (streamEvent) {
                
            case NSStreamEventNone:
                break;
                
            case NSStreamEventOpenCompleted:
                NSLog(@"InputStream Completed");
                isInputConnected = TRUE;
//                [self performSelector:@selector(isLiveMessage) withObject:nil afterDelay:5];
                break;
                
            case NSStreamEventHasBytesAvailable:
                //                [self readFromStreamToInputBuffer];
            {
                uint8_t buffer[1024];
                bzero(buffer, 1024);
                NSInteger actuallyRead = [self.inputStream read:(uint8_t *)buffer maxLength:sizeof(buffer)];
                //                NSLog(@"Actually Read = %ld", (long)actuallyRead);
                
                if (actuallyRead > 0) {
                    // Write it to display
                    NSData *dataPacket = [NSData dataWithBytes:buffer length:actuallyRead];
                    
                    NSString * strMessage = [NSString stringWithFormat:@"%@",[[NSString alloc]initWithData:dataPacket encoding:NSUTF8StringEncoding]];
                    NSArray * arrResponse = [strMessage componentsSeparatedByString:@"\n"];
                    for (NSString * strM in arrResponse) {
                        [self.delegate didReceiveMessage:strM];
                    }
                }
                
            }
                break;
                
            case NSStreamEventHasSpaceAvailable:
                // Should not happen for input stream!
                break;
                
            case NSStreamEventErrorOccurred:
                // Treat as "connection should be closed"
                isInputConnected = FALSE;
                NSLog(@"\n\n InputStream streamError ==>> %@",stream.streamError);
                break;
            case NSStreamEventEndEncountered:
                NSLog(@"InputStream closed");
                isInputConnected = FALSE;
                break;
        }
    }
    
    if (stream == self.outputStream) {
        switch (streamEvent) {
            case NSStreamEventNone:
                break;
                
            case NSStreamEventOpenCompleted:
                NSLog(@"OutputStream Completed");

            {
                isOutPutConnected = TRUE;
                NSString *inputStreamOpen = [NSString stringWithFormat:@"OutputStreamOpen"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OutputStreamOpen" object:inputStreamOpen];
//                [self performSelector:@selector(isLiveMessage) withObject:nil afterDelay:5];
            }
                break;
                
            case NSStreamEventHasBytesAvailable:
                NSLog(@"\n\n NSStreamEventHasBytesAvailable");
                // Should not happen for output stream!
                break;
                
            case NSStreamEventHasSpaceAvailable:
                NSLog(@"\n\n NSStreamEventHasSpaceAvailable");
                break;
                
            case NSStreamEventErrorOccurred:
                // Treat as "connection should be closed"
                NSLog(@"\n\n OutputStream streamError ==>> %@",stream.streamError);
                isOutPutConnected = FALSE;
                break;
            case NSStreamEventEndEncountered:
                NSLog(@"OutputStream closed");
                isOutPutConnected = FALSE;
                break;
        }
    }
}
@end
