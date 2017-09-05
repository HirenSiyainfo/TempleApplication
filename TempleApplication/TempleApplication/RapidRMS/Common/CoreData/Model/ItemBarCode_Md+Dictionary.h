//
//  ItemBarCode_Md+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 21/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemBarCode_Md.h"

@interface ItemBarCode_Md (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemBarcodeDictionary;
-(void)updateItemBarcodeDictionary :(NSDictionary *)itemBarcodeDictionary;

@end
