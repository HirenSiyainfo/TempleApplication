//
//  ItemInventoryCount+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 1/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInventoryCount.h"

@interface ItemInventoryCount (Dictionary)
-(void)updateItemInventoryCountDictionary :(NSDictionary *)itemInventoryCountDictionary;
-(void)updateItemInventoryCountDictionaryOfServer :(NSDictionary *)itemInventoryCountDictionary;

@end
