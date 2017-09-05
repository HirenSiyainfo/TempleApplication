//
//  ItemInventoryReconcileCount+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 1/3/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInventoryReconcileCount.h"

@interface ItemInventoryReconcileCount (Dictionary)
-(void)resetItemInventoryCountSessionWithDictionary :(NSDictionary *)sessionDictionary withItem:(Item *)item;
-(void)resetItemInventoryCountSessionForHistoryWithDictionary :(NSDictionary *)sessionDictionary withItem:(Item *)item;

@end
