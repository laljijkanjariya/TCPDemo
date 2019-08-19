//
//  TCPMessageUpdateManager.m
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPMessageUpdateManager.h"

@implementation TCPMessageUpdateManager

+ (NSManagedObjectContext *)privateConextFromParentContext:(NSManagedObjectContext*)parentContext {
    NSManagedObjectContext *privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateManagedObjectContext.parentContext = parentContext;
    [privateManagedObjectContext setUndoManager:nil];
    return privateManagedObjectContext;
}

+ (NSArray *)fetchEntitysWithName:(NSString*)entityName predicate:(NSPredicate *)predicate moc:(NSManagedObjectContext*)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    return [TCPMessageUpdateManager executeForContext:moc FetchRequest:fetchRequest];
}
+ (NSManagedObject *)fetchEntitysWithName:(NSString*)entityName predicate:(NSPredicate *)predicate isCreate:(BOOL)isCreate moc:(NSManagedObjectContext*)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    NSManagedObject * obj = [[TCPMessageUpdateManager executeForContext:moc FetchRequest:fetchRequest] firstObject];
    if (obj == nil && isCreate) {
        obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    }
    return obj;
}
+ (nullable NSArray *)executeForContext:(NSManagedObjectContext*)theContext FetchRequest:(NSFetchRequest*)fetchRequest {
    NSArray * result = nil;
    NSError *error = nil;
    @try
    {
        result = [theContext executeFetchRequest:fetchRequest error:&error];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error while executing fetch request occured. %@", exception);
        result = nil;
    }
    @finally {
    }
    
    return result;
}

+ (void)saveContext:(NSManagedObjectContext*)theContext {
    if (theContext == nil) {
        return;
    }
    
    if (theContext.parentContext == nil) {
        [theContext performBlock:^{
            [self __save:theContext];
        }];
    } else {
        [theContext performBlockAndWait:^{
            [self __save:theContext];
        }];
    }
}
+ (void)__save:(NSManagedObjectContext *)theContext {
    // Save context
    @try {
        NSError *error = nil;
        if (![theContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", error.localizedDescription);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Save: Non recoverable error occured. %@", exception);
    }
    @finally {
        
    }
    // push to parent
    // save parent to disk asynchronously
    [self saveContext:theContext.parentContext];
}
+ (void)deleteFromContext:(NSManagedObjectContext*)theContext object:(NSManagedObject*)anObject {
    if (anObject != nil) {
        @try {
            [theContext deleteObject:anObject];
        }
        @catch (NSException *exception) {
            NSLog(@"Non recoverable error occured while deleting. %@", exception);
        }
        @finally {
            
        }
    }
}
+ (void)deleteFromContext:(NSManagedObjectContext*)theContext objectId:(NSManagedObjectID*)anObjectId {
    @try {
        NSManagedObject * anObject = [theContext objectWithID:anObjectId];
        [TCPMessageUpdateManager deleteFromContext:theContext object:anObject];
    }
    @catch (NSException *exception) {
        NSLog(@"Non recoverable error occured while deleting. %@", exception);
    }
    @finally {
        
    }
    
}

+(NSDate *)getDateFrom:(NSString *)strDate {
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    return [formatter dateFromString:strDate];
}
+(NSString *)getStringDateFrom:(NSDate *)date {
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    return [formatter stringFromDate:date];
}
+(User *)getUserFromUserID:(NSString *)userID fromMOC:(NSManagedObjectContext *)moc{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID == %@",userID];
    NSArray * arrResult = [TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate moc:moc];
    return (User *)arrResult.firstObject;
}
@end
