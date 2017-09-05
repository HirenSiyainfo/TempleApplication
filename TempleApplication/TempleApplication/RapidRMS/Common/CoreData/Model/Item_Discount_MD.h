//
//  Item_Discount_MD.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Item_Discount_MD2;

@interface Item_Discount_MD : NSManagedObject

@property (nonatomic, retain) NSNumber * dis_Qty;
@property (nonatomic, retain) NSNumber * dis_UnitPrice;
@property (nonatomic, retain) NSNumber * iDisNo;
@property (nonatomic, retain) NSNumber * isDiscounted;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) Item *mdToItem;
@property (nonatomic, retain) NSSet *mdTomd2;
@end

@interface Item_Discount_MD (CoreDataGeneratedAccessors)

- (void)addMdTomd2Object:(Item_Discount_MD2 *)value;
- (void)removeMdTomd2Object:(Item_Discount_MD2 *)value;
- (void)addMdTomd2:(NSSet *)values;
- (void)removeMdTomd2:(NSSet *)values;

@end
