//
//  ItemInventoryCount.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, ItemInventoryCountSession, ItemInventoryReconcileCount;

@interface ItemInventoryCount : NSManagedObject

@property (nonatomic, retain) NSNumber * caseCount;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * isUploadedToServer;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSNumber * itemCountId;
@property (nonatomic, retain) NSNumber * packCount;
@property (nonatomic, retain) NSNumber * registerId;
@property (nonatomic, retain) NSNumber * sessionId;
@property (nonatomic, retain) NSNumber * singleCount;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * userSessionId;
@property (nonatomic, retain) Item *itemCountItem;
@property (nonatomic, retain) ItemInventoryCountSession *itemInventoryCountSession;
@property (nonatomic, retain) ItemInventoryReconcileCount *itemInventoryReconcileCount;

@end
