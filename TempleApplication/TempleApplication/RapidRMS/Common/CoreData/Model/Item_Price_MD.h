//
//  Item_Price_MD.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, ItemBarCode_Md;

@interface Item_Price_MD : NSManagedObject

@property (nonatomic, retain) NSString * applyPrice;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSDate * createddate;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * isPackCaseAllow;
@property (nonatomic, retain) NSNumber * itemcode;
@property (nonatomic, retain) NSNumber * priceA;
@property (nonatomic, retain) NSNumber * priceB;
@property (nonatomic, retain) NSNumber * priceC;
@property (nonatomic, retain) NSString * priceqtytype;
@property (nonatomic, retain) NSNumber * profit;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSNumber * unitPrice;
@property (nonatomic, retain) NSNumber * unitQty;
@property (nonatomic, retain) NSString * unitType;
@property (nonatomic, retain) NSSet *priceBarcodes;
@property (nonatomic, retain) Item *priceToItem;
@end

@interface Item_Price_MD (CoreDataGeneratedAccessors)

- (void)addPriceBarcodesObject:(ItemBarCode_Md *)value;
- (void)removePriceBarcodesObject:(ItemBarCode_Md *)value;
- (void)addPriceBarcodes:(NSSet *)values;
- (void)removePriceBarcodes:(NSSet *)values;

@end
