//
//  VPurchaseOrderItem.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VPurchaseOrder, Vendor_Item;

@interface VPurchaseOrderItem : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * casePOQty;
@property (nonatomic, retain) NSNumber * caseReceivedQty;
@property (nonatomic, retain) NSNumber * isReturn;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSNumber * oldQty;
@property (nonatomic, retain) NSNumber * packPOQty;
@property (nonatomic, retain) NSNumber * packReceivedQty;
@property (nonatomic, retain) NSNumber * poId;
@property (nonatomic, retain) NSNumber * poItemId;
@property (nonatomic, retain) NSString * remarks;
@property (nonatomic, retain) NSNumber * singlePOQty;
@property (nonatomic, retain) NSNumber * singleReceivedQty;
@property (nonatomic, retain) NSDate * createdDate;

@property (nonatomic, retain) Vendor_Item *vitems;
@property (nonatomic, retain) VPurchaseOrder *vpoId;

@end
