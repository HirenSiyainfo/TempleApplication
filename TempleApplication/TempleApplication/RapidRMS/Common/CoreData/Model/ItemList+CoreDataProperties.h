//
//  ItemList+CoreDataProperties.h
//  RapidRMS
//
//  Created by siya8 on 18/07/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "ItemList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ItemList (CoreDataProperties)

+ (NSFetchRequest<ItemList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *endDate;
@property (nullable, nonatomic, copy) NSNumber *isOpen;
@property (nullable, nonatomic, copy) NSString *itemName;
@property (nullable, nonatomic, copy) NSDate *startDate;
@property (nullable, nonatomic, copy) NSNumber *isLabelPrintItem;
@property (nullable, nonatomic, retain) NSSet<Item *> *itemListToitems;

@end

@interface ItemList (CoreDataGeneratedAccessors)

- (void)addItemListToitemsObject:(Item *)value;
- (void)removeItemListToitemsObject:(Item *)value;
- (void)addItemListToitems:(NSSet<Item *> *)values;
- (void)removeItemListToitems:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END
