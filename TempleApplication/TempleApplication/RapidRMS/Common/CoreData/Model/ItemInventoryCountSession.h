//
//  ItemInventoryCountSession.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemInventoryCount, ItemInventoryReconcileCount;

@interface ItemInventoryCountSession : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * remarks;
@property (nonatomic, retain) NSNumber * sessionId;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *sessionItemCount;
@property (nonatomic, retain) NSSet *sessionReconcileCounts;
@end

@interface ItemInventoryCountSession (CoreDataGeneratedAccessors)

- (void)addSessionItemCountObject:(ItemInventoryCount *)value;
- (void)removeSessionItemCountObject:(ItemInventoryCount *)value;
- (void)addSessionItemCount:(NSSet *)values;
- (void)removeSessionItemCount:(NSSet *)values;

- (void)addSessionReconcileCountsObject:(ItemInventoryReconcileCount *)value;
- (void)removeSessionReconcileCountsObject:(ItemInventoryReconcileCount *)value;
- (void)addSessionReconcileCounts:(NSSet *)values;
- (void)removeSessionReconcileCounts:(NSSet *)values;

@end
