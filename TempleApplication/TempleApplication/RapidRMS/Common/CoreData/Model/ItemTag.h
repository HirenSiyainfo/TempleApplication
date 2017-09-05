//
//  ItemTag.h
//  RapidRMS
//
//  Created by Siya on 22/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, SizeMaster;

@interface ItemTag : NSManagedObject

@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSNumber * sizeId;
@property (nonatomic, retain) NSSet *tagToItem;
@property (nonatomic, retain) SizeMaster *tagToSizeMaster;
@end

@interface ItemTag (CoreDataGeneratedAccessors)

- (void)addTagToItemObject:(Item *)value;
- (void)removeTagToItemObject:(Item *)value;
- (void)addTagToItem:(NSSet *)values;
- (void)removeTagToItem:(NSSet *)values;

@end
