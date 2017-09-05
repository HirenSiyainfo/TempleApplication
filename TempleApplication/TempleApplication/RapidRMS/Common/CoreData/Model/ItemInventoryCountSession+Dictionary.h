//
//  ItemInventoryCountSession+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 1/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemInventoryCountSession.h"

@interface ItemInventoryCountSession (Dictionary)

@property (NS_NONATOMIC_IOSONLY, getter=getItemInventoryCountDictionary, readonly, copy) NSDictionary *itemInventoryCountDictionary;
-(void)updateItemInventoryCountDictionary :(NSDictionary *)itemInventoryCountDictionary;

@end