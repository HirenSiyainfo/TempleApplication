//
//  GroupMaster.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface GroupMaster : NSManagedObject

@property (nonatomic, retain) NSNumber * costPrice;
@property (nonatomic, retain) NSNumber * disc_Id;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSNumber * sellingPrice;
@property (nonatomic, retain) NSSet *groupMasterItems;
@end

@interface GroupMaster (CoreDataGeneratedAccessors)

- (void)addGroupMasterItemsObject:(Item *)value;
- (void)removeGroupMasterItemsObject:(Item *)value;
- (void)addGroupMasterItems:(NSSet *)values;
- (void)removeGroupMasterItems:(NSSet *)values;

@end
