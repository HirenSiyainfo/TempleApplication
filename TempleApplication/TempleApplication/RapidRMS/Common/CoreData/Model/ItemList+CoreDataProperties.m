//
//  ItemList+CoreDataProperties.m
//  RapidRMS
//
//  Created by siya8 on 18/07/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "ItemList+CoreDataProperties.h"

@implementation ItemList (CoreDataProperties)

+ (NSFetchRequest<ItemList *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ItemList"];
}

@dynamic endDate;
@dynamic isOpen;
@dynamic itemName;
@dynamic startDate;
@dynamic isLabelPrintItem;
@dynamic itemListToitems;

@end
