//
//  UpdateLogManager.h
//  DebugLog
//
//  Created by Siya9 on 19/01/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DebugLogManager.h"

@interface UpdateLogManager : NSObject


+(void)logPetroBroadCastMessageWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroAdHocCountRequestWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroAdHocCountResponseWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroAdHocPumpStatusRequestWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroAdHocPumpStatusResponseWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroFuelTypeRequestWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroFuelTypeResponseWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroTankRequestWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroTankResponseWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroPumpCommandRequestWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroPumpCommandResponseWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroCartCommandRequestWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroCartCommandResponseWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroPumpCartStatusWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroInvoiceAdhocRequestWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroInvoiceAdhocResponseWithDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroAdjustInvoiceDetail:(NSDictionary *)dictLogInfo;
+(void)logPetroAdjustResponse:(NSDictionary *)dictLogInfo;

+(void)logPetroDonePumpCart:(NSDictionary *)dictLogInfo;
+(void)logPetroDeletePumpCart:(NSDictionary *)dictLogInfo;
+(void)logPetroPumpCartAction:(NSDictionary *)dictLogInfo;

+(void)logPetroFusionSendRequest:(NSDictionary *)dictLogInfo;
+(void)logPetroFusionReceivedResponse:(NSDictionary *)dictLogInfo;

+(CartStatus)getCardStatusFromString:(NSString *)strCardStatus;

+ (void)saveContext:(NSManagedObjectContext*)theContext;
+ (NSManagedObjectContext *)privateConextFromParentContext:(NSManagedObjectContext*)parentContext;
+ (void)deleteFromContext:(NSManagedObjectContext *)theContext objectId:(NSManagedObjectID*)anObjectId;
@end
