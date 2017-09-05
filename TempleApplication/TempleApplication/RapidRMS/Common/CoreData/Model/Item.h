//
//  Item.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Department, Discount_Primary_MD, Discount_Secondary_MD, GroupMaster, ItemBarCode_Md, ItemInventoryCount, ItemTag, ItemTicket_MD, ItemVariation_M, Item_Discount_MD, Item_Price_MD, ManualReceivedItem, Mix_MatchDetail, ModifierPrice, RestaurantItem, SubDepartment, SupplierCompany,ItemList;

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"
