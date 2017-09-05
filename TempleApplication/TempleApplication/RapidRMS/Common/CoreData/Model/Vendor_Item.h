//
//  Vendor_Item.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VPurchaseOrderItem;

@interface Vendor_Item : NSManagedObject

@property (nonatomic, retain) NSNumber * cartonUpc;
@property (nonatomic, retain) NSString * categoryDesc;
@property (nonatomic, retain) NSString * categoryDescription;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSNumber * globalSub;
@property (nonatomic, retain) NSNumber * invoiceCategory;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSNumber * itemCategory;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSNumber * itemPrice;
@property (nonatomic, retain) NSNumber * lineFor;
@property (nonatomic, retain) NSNumber * linePerPrice;
@property (nonatomic, retain) NSNumber * packUpc;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * srpFactor;
@property (nonatomic, retain) NSNumber * unitCost;
@property (nonatomic, retain) NSNumber * unitRetail;
@property (nonatomic, retain) NSNumber * vendor_Id;
@property (nonatomic, retain) NSNumber * vendor_Item_Id;
@property (nonatomic, retain) NSNumber * vin;
@property (nonatomic, retain) NSNumber * zoneId;
@property (nonatomic, retain) NSSet *vpoitems;
@end

@interface Vendor_Item (CoreDataGeneratedAccessors)

- (void)addVpoitemsObject:(VPurchaseOrderItem *)value;
- (void)removeVpoitemsObject:(VPurchaseOrderItem *)value;
- (void)addVpoitems:(NSSet *)values;
- (void)removeVpoitems:(NSSet *)values;

@end
