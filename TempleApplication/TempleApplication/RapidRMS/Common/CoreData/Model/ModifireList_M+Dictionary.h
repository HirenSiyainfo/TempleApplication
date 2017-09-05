//
//  ModifireList_M+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 10/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ModifireList_M.h"

@interface ModifireList_M (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemModifireItemMDictionary;
-(void)updateitemModifireItemMDictionary :(NSDictionary *)itemModifireItemMDictionary;

@end
