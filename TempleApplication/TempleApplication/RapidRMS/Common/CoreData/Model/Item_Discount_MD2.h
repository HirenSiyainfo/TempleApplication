//
//  Item_Discount_MD2.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item_Discount_MD;

@interface Item_Discount_MD2 : NSManagedObject

@property (nonatomic, retain) NSNumber * dayId;
@property (nonatomic, retain) NSNumber * discountId;
@property (nonatomic, retain) NSString * endDate;
@property (nonatomic, retain) NSNumber * rowId;
@property (nonatomic, retain) NSString * startDate;
@property (nonatomic, retain) Item_Discount_MD *md2Tomd;

@end
