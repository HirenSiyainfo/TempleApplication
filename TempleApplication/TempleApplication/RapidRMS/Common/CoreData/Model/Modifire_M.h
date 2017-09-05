//
//  Modifire_M.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModifierPrice;

@interface Modifire_M : NSManagedObject

@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSNumber * brnModifierId;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSString * modifireName;
@property (nonatomic, retain) NSSet *modifier_MModifierPrices;
@end

@interface Modifire_M (CoreDataGeneratedAccessors)

- (void)addModifier_MModifierPricesObject:(ModifierPrice *)value;
- (void)removeModifier_MModifierPricesObject:(ModifierPrice *)value;
- (void)addModifier_MModifierPrices:(NSSet *)values;
- (void)removeModifier_MModifierPrices:(NSSet *)values;

@end
