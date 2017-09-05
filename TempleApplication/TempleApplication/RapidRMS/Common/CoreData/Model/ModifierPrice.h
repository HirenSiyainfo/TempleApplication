//
//  ModifierPrice.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, ModifireList_M, Modifire_M;

@interface ModifierPrice : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * brnModifierItemId;
@property (nonatomic, retain) NSNumber * calcInPOS;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * itemCode;
@property (nonatomic, retain) NSNumber * modifierId;
@property (nonatomic, retain) NSNumber * modifierListId;
@property (nonatomic, retain) NSNumber * modifierPriceId;
@property (nonatomic, retain) NSString * modifireItem;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) Modifire_M *modifierPriceGroup;
@property (nonatomic, retain) Item *modifierPriceItem;
@property (nonatomic, retain) ModifireList_M *modifierPriceList;

@end
