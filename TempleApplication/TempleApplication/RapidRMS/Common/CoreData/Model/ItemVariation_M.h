//
//  ItemVariation_M.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, ItemVariation_Md, Variation_Master;

@interface ItemVariation_M : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * colPosNo;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSNumber * varianceId;
@property (nonatomic, retain) NSNumber * variationMasterId;
@property (nonatomic, retain) NSString * variationName;
@property (nonatomic, retain) Item *variationItem;
@property (nonatomic, retain) Variation_Master *variationMMaster;
@property (nonatomic, retain) NSSet *variationMVariationMds;
@end

@interface ItemVariation_M (CoreDataGeneratedAccessors)

- (void)addVariationMVariationMdsObject:(ItemVariation_Md *)value;
- (void)removeVariationMVariationMdsObject:(ItemVariation_Md *)value;
- (void)addVariationMVariationMds:(NSSet *)values;
- (void)removeVariationMVariationMds:(NSSet *)values;

@end
