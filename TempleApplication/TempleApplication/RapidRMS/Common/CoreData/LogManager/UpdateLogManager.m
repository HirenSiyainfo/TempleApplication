//
//  UpdateLogManager.m
//  DebugLog
//
//  Created by Siya9 on 19/01/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import "UpdateLogManager.h"
#import "RmsDbController.h"
@implementation UpdateLogManager

#pragma mark - Petro log methods -

//NSString *registerId; no need set
//NSDate *timeStamp; no need set
//NSNumber *userId; no need set
//NSNumber *index; no need set
//NSString *buildDetaild; no need set
//NSNumber *uploadStatus; no need set

//NSString *cartID;
//NSNumber *cartStatus;
//NSString *command;
//NSString *data;
//NSNumber *direction;
//NSString *invoiceNumber;
//NSNumber *isPad;
//NSString *parameters;
//NSNumber *pumpIndex;
//NSString *regInvNumber;

//NSNumber *transactionType;
//NSNumber *type;

+(void)logPetroBroadCastMessageWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"parameters"] = @"Broadcast";
    mDictLogInfo[@"transactionType"] = @(TransactionTypeNotAvailable);
    mDictLogInfo[@"type"] = @(TypeBroadcast);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);
    
    NSArray * arrRequiredKeys = @[@"cartID",@"cartStatus",@"command",@"pumpIndex",@"direction"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroBroadCastMessageWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroAdHocCountRequestWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeAdhoc);
    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdHocCountRequestWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroAdHocCountResponseWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeAdhoc);
    
    NSArray * arrRequiredKeys = @[@"command",@"data",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdHocCountResponseWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}



+(void)logPetroAdHocPumpStatusRequestWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeAdhoc);
    mDictLogInfo[@"transactionType"] = @(TransactionTypeNotAvailable);
    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"type",@"transactionType"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdHocPumpStatusRequestWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroAdHocPumpStatusResponseWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeAdhoc);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);
    mDictLogInfo[@"transactionType"] = @(TransactionTypeNotAvailable);
    
    NSArray * arrRequiredKeys = @[@"command",@"cartID",@"cartStatus",@"data",@"pumpIndex",@"direction",@"type",@"transactionType"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdHocPumpStatusResponseWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroFuelTypeRequestWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeCommands);
    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroFuelTypeRequestWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroFuelTypeResponseWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeCommands);
    
    NSArray * arrRequiredKeys = @[@"command",@"data",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroFuelTypeResponseWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroTankRequestWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeCommands);
    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroTankRequestWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroTankResponseWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeCommands);
    
    NSArray * arrRequiredKeys = @[@"command",@"data",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroTankResponseWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroPumpCommandRequestWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeCommands);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);
    
    NSArray * arrRequiredKeys = @[@"command",@"cartStatus",@"pumpIndex",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroPumpCommandRequestWithDetail ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroPumpCommandResponseWithDetail:(NSDictionary *)dictLogInfo{
    
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeCommands);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);
    
    NSArray * arrRequiredKeys = @[@"command",@"cartStatus",@"pumpIndex",@"transactionType",@"direction",@"type"];
    
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroPumpCommandResponseWithDetail ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroCartCommandRequestWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeCommands);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);
    
    NSArray * arrRequiredKeys = @[@"command",@"cartStatus",@"pumpIndex",@"transactionType",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroCartCommandRequestWithDetail ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroCartCommandResponseWithDetail:(NSDictionary *)dictLogInfo{
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeCommands);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);
    
    NSArray * arrRequiredKeys = @[@"command",@"cartID",@"cartStatus",@"pumpIndex",@"transactionType",@"direction",@"type"];
    
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroCartCommandResponseWithDetail ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroPumpCartStatusWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary *mDictLogInfo = [dictLogInfo mutableCopy];

    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);
    mDictLogInfo[@"transactionType"] = @([UpdateLogManager getTransactionTypeFromString:mDictLogInfo[@"transactionType"]]);
    
    NSArray * arrRequiredKeys = @[@"command",@"parameters",@"cartID",@"pumpIndex",@"transactionType",@"direction",@"type",@"isPad",@"regInvNumber",@"invoiceNumber"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroPumpCartStatusWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroInvoiceAdhocRequestWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeAdhoc);
    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdHocCountRequestWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroInvoiceAdhocResponseWithDetail:(NSDictionary *)dictLogInfo{
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeAdhoc);
    
    NSArray * arrRequiredKeys = @[@"command",@"data",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdHocCountResponseWithDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroAdjustInvoiceDetail:(NSDictionary *)dictLogInfo{
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeRapidServer);
    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"type",@"parameters",@"cartID"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdjustInvoiceDetail ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];

}
+(void)logPetroAdjustResponse:(NSDictionary *)dictLogInfo{
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeRapidServer);
    
    NSArray * arrRequiredKeys = @[@"command",@"data",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdjustResponse ....");
    
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];

}
+(void)logPetroDonePumpCart:(NSDictionary *)dictLogInfo{
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeRapidServer);
    mDictLogInfo[@"transactionType"] = @([UpdateLogManager getTransactionTypeFromString:mDictLogInfo[@"transactionType"]]);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);

    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"parameters",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdjustResponse ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroDeletePumpCart:(NSDictionary *)dictLogInfo{
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeRapidServer);
    mDictLogInfo[@"transactionType"] = @([UpdateLogManager getTransactionTypeFromString:mDictLogInfo[@"transactionType"]]);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);

    NSArray * arrRequiredKeys = @[@"command",@"direction",@"parameters",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdjustResponse ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}
+(void)logPetroPumpCartAction:(NSDictionary *)dictLogInfo{
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeRapidServer);
    mDictLogInfo[@"transactionType"] = @([UpdateLogManager getTransactionTypeFromString:mDictLogInfo[@"transactionType"]]);
    mDictLogInfo[@"cartStatus"] = @([UpdateLogManager getCardStatusFromString:mDictLogInfo[@"cartStatus"]]);
    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"parameters",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdjustResponse ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroFusionSendRequest:(NSDictionary *)dictLogInfo{
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionSent);
    mDictLogInfo[@"type"] = @(TypeFusion);
    
    NSArray * arrRequiredKeys = @[@"command",@"direction",@"parameters",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdjustResponse ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}

+(void)logPetroFusionReceivedResponse:(NSDictionary *)dictLogInfo{
    
    NSMutableDictionary * mDictLogInfo = [dictLogInfo mutableCopy];
    
    mDictLogInfo[@"direction"] = @(DirectionReceive);
    mDictLogInfo[@"type"] = @(TypeFusion);
    
    NSArray * arrRequiredKeys = @[@"command",@"data",@"direction",@"type"];
    NSAssert([UpdateLogManager isValidDictionary:mDictLogInfo forKeys:arrRequiredKeys], @"logPetroAdjustResponse ....");
    [UpdateLogManager insertUpdateLogFrom:mDictLogInfo];
}


+(TransactionType)getTransactionTypeFromString:(NSString *)strTrnxType {
    if ([strTrnxType isEqualToString:@"PRE-PAY"]) {
        return TransactionTypePrePay;
    }
    else if ([strTrnxType isEqualToString:@"POST-PAY"]) {
        return TransactionTypePostPay;
    }
    else if ([strTrnxType isEqualToString:@"OUTSIDE-PAY"]) {
        return TransactionTypeOutSide;
    }
    else {
        return TransactionTypeNotAvailable;
    }
}


+(CartStatus)getCardStatusFromString:(NSString *)strCardStatus {
    if ([strCardStatus.lowercaseString isEqualToString:@"new"]) {
        return CartStatusNew;
    }
    else if ([strCardStatus.lowercaseString isEqualToString:@"shop"]) {
        return CartStatusShop;
    }
    else if ([strCardStatus.lowercaseString isEqualToString:@"full"]) {
        return CartStatusFull;
    }
    else if ([strCardStatus.lowercaseString isEqualToString:@"done"]) {
        return CartStatusDone;
    }
    else {
        return CartStatusNone;
    }
}

#pragma mark - Insert New Log -

+(void)insertUpdateLogFrom:(NSDictionary *)dictLogInfo {

    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext * privareContect = [UpdateLogManager privateConextFromParentContext:[DebugLogManager sharedDebugLogManager].managedObjectContext];
        PetroLog * objLog = [[DebugLogManager sharedDebugLogManager] insertNewObjectInManagedObjectContext:privareContect];
        [objLog updateLogObjectFrom:dictLogInfo];
        [UpdateLogManager saveContext:privareContect];
    }];
    [op setQueuePriority:NSOperationQueuePriorityHigh];
    [op setQualityOfService:NSQualityOfServiceUserInitiated];
    [[DebugLogManager sharedDebugLogManager].operationQueue addOperation:op];
}
+(BOOL)isValidDictionary:(NSDictionary*)dictionary forKeys:(NSArray*)keys {

    for (NSString * strKey in keys) {
        if (![dictionary objectForKey:strKey]) {
            return FALSE;
        }
    }
    return YES;
}

#pragma mark - CoreData Wrappers -

+ (NSManagedObjectContext *)privateConextFromParentContext:(NSManagedObjectContext*)parentContext {
    // Create Provate context for this queue
    NSManagedObjectContext *privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateManagedObjectContext.parentContext = parentContext;
    [privateManagedObjectContext setUndoManager:nil];
    return privateManagedObjectContext;
}

+ (void)deleteFromContext:(NSManagedObjectContext *)theContext object:(NSManagedObject*)anObject {
    @try {
        [theContext deleteObject:anObject];
    }
    @catch (NSException *exception) {
        NSLog(@"Non recoverable error occured while deleting. %@", exception);
    }
    @finally {
        
    }
    
}
+ (void)deleteFromContext:(NSManagedObjectContext *)theContext objectId:(NSManagedObjectID*)anObjectId {
    @try {
        NSManagedObject * anObject = [theContext objectWithID:anObjectId];
        [UpdateManager deleteFromContext:theContext object:anObject];
    }
    @catch (NSException *exception) {
        NSLog(@"Non recoverable error occured while deleting. %@", exception);
    }
    @finally {
        
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
    [self saveContext:theContext.parentContext];
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
@end
