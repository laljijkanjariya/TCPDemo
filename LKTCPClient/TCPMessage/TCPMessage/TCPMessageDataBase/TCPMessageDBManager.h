//
//  TCPMessageDBManager.h
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TCPMessageDBManager : NSObject
@property (readonly, strong) NSPersistentContainer *persistentContainer;
- (void)saveContext;
+ (TCPMessageDBManager*)sharedTCPMessageDBManager;
@end
