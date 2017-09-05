//
//  Item+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 11/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "Item.h"
@class Department;
@class Mix_MatchDetail;
@class GroupMaster;
@class ItemBarCode_Md;


@interface Item (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemDictionary;
-(void)updateItemFromDictionary :(NSDictionary *)itemDictionary;
-(void)updateItemFromUpdateDict :(NSDictionary *)updateDictionary;
-(void)updateItemFromRimDictionary :(NSDictionary *)itemDictionary;
-(void)linkToDepartment :(Department *)department;
-(void)linkToMixMatch :(Mix_MatchDetail *)mix_Match;
-(void)linkToGroup :(GroupMaster *)groupMaster;
-(void)linkToBarcode :(ItemBarCode_Md *)itemBarCode_Md;
-(void)linkToBarcodes :(NSArray *)itemBarCode_Mds;
-(void)linkToPrice :(NSArray *)itemPrice_Mds;

-(void)linkToSubDepartment:(SubDepartment *)subDepartment;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemRMSDictionary;
@end
