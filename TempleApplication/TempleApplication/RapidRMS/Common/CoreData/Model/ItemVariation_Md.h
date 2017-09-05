//
//  ItemVariation_Md.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemVariation_M;

@interface ItemVariation_Md : NSManagedObject

@property (nonatomic, retain) NSString * applyPrice;
@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSNumber * measurementQuantity;
@property (nonatomic, retain) NSString * measurementUnit;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priceA;
@property (nonatomic, retain) NSNumber * priceB;
@property (nonatomic, retain) NSNumber * priceC;
@property (nonatomic, retain) NSNumber * profit;
@property (nonatomic, retain) NSNumber * rowPosNo;
@property (nonatomic, retain) NSNumber * unitPrice;
@property (nonatomic, retain) NSNumber * varianceId;
@property (nonatomic, retain) ItemVariation_M *variationMdVariationM;

@end
