//
//  ItemTag+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 13/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "ItemTag.h"

@interface ItemTag (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemTagDictionary;
-(void)updateItemTagFromDictionary :(NSDictionary *)itemTagDictionary;
-(void)updateItemTagFromItemTable :(NSDictionary *)itemTagDictionary withItemCode:(NSString *)itemCode;

@end
