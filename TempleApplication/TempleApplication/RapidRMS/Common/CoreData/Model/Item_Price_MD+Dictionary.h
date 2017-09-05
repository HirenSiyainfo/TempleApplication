//
//  Item_Price_MD+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Item_Price_MD.h"

@interface Item_Price_MD (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *item_Price_Md_Dictionary;
-(void)updateItem_Price_Md_Dictionary :(NSDictionary *)item_Price_Md_Dictionary;
-(void)linkToBarcodePrice :(NSArray *)itemBarcode_Mds;

@end
