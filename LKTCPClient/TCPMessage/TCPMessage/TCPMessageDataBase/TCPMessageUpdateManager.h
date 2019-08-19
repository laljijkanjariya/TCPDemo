//
//  TCPMessageUpdateManager.h
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPMessageDBManager.h"
@class User;

@interface TCPMessageUpdateManager : NSObject
+ (NSManagedObjectContext *)privateConextFromParentContext:(NSManagedObjectContext*)parentContext;
+ (NSArray *)fetchEntitysWithName:(NSString*)entityName predicate:(NSPredicate *)predicate moc:(NSManagedObjectContext*)moc;
+ (NSManagedObject *)fetchEntitysWithName:(NSString*)entityName predicate:(NSPredicate *)predicate isCreate:(BOOL)isCreate moc:(NSManagedObjectContext*)moc;
+ (void)saveContext:(NSManagedObjectContext*)theContext;
+ (void)deleteFromContext:(NSManagedObjectContext*)theContext object:(NSManagedObject*)anObject;
+ (void)deleteFromContext:(NSManagedObjectContext*)theContext objectId:(NSManagedObjectID*)anObjectId;

+(NSDate *)getDateFrom:(NSString *)strDate;
+(NSString *)getStringDateFrom:(NSDate *)date;
+(User *)getUserFromUserID:(NSString *)userID fromMOC:(NSManagedObjectContext *)moc;
@end
