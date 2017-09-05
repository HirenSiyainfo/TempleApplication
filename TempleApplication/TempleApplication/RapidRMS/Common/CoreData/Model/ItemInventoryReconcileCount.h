//
//  ItemInventoryReconcileCount.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemInventoryCount, ItemInventoryCountSession;

@interface ItemInventoryReconcileCount : NSManagedObject

@property (nonatomic, retain) NSNumber * caseCount;
@property (nonatomic, retain) NSNumber * caseQuantity;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * expectedQuantity;
@property (nonatomic, retain) NSNumber * isMatching;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSNumber * packCount;
@property (nonatomic, retain) NSNumber * packQuantity;
@property (nonatomic, retain) NSNumber * registerId;
@property (nonatomic, retain) NSNumber * sessionId;
@property (nonatomic, retain) NSNumber * singleCount;
@property (nonatomic, retain) NSNumber * singleQuantity;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSSet *itemInventoryCounts;
@property (nonatomic, retain) ItemInventoryCountSession *itemInventoryReconcileSession;
@end

@interface ItemInventoryReconcileCount (CoreDataGeneratedAccessors)

- (void)addItemInventoryCountsObject:(ItemInventoryCount *)value;
- (void)removeItemInventoryCountsObject:(ItemInventoryCount *)value;
- (void)addItemInventoryCounts:(NSSet *)values;
- (void)removeItemInventoryCounts:(NSSet *)values;

@end
