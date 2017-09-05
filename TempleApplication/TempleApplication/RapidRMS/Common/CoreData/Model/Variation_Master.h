//
//  Variation_Master.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemVariation_M;

@interface Variation_Master : NSManagedObject

@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * vid;
@property (nonatomic, retain) NSSet *masterVariationMs;
@end

@interface Variation_Master (CoreDataGeneratedAccessors)

- (void)addMasterVariationMsObject:(ItemVariation_M *)value;
- (void)removeMasterVariationMsObject:(ItemVariation_M *)value;
- (void)addMasterVariationMs:(NSSet *)values;
- (void)removeMasterVariationMs:(NSSet *)values;

@end
