//
//  ModifireList_M.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModifierPrice;

@interface ModifireList_M : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * brnModifierItemId;
@property (nonatomic, retain) NSNumber * calcInPOS;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * modifierId;
@property (nonatomic, retain) NSString * modifireItem;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSSet *modifierItem_MModifierPrices;
@end

@interface ModifireList_M (CoreDataGeneratedAccessors)

- (void)addModifierItem_MModifierPricesObject:(ModifierPrice *)value;
- (void)removeModifierItem_MModifierPricesObject:(ModifierPrice *)value;
- (void)addModifierItem_MModifierPrices:(NSSet *)values;
- (void)removeModifierItem_MModifierPrices:(NSSet *)values;

@end
