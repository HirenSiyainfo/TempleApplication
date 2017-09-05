//
//  VPurchaseOrder.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VPurchaseOrderItem;

@interface VPurchaseOrder : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * department;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSString * keyowrd;
@property (nonatomic, retain) NSString * orderName;
@property (nonatomic, retain) NSString * orderNo;
@property (nonatomic, retain) NSNumber * poId;
@property (nonatomic, retain) NSNumber * registerId;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSSet *poIdItem;
@property (nonatomic, retain) NSDate * updateDate;
@end

@interface VPurchaseOrder (CoreDataGeneratedAccessors)

- (void)addPoIdItemObject:(VPurchaseOrderItem *)value;
- (void)removePoIdItemObject:(VPurchaseOrderItem *)value;
- (void)addPoIdItem:(NSSet *)values;
- (void)removePoIdItem:(NSSet *)values;

@end
