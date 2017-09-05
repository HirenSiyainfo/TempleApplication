//
//  Bill.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;
@class BillItem;
@class BillAmountComponents;

@interface Bill : NSObject

-(void)addItem:(Item *)ringupItem;

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger numberOfItems;
-(BillItem *)itemAtIndex:(NSInteger)itemAtIndex;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) BillAmountComponents *billAmountComponents;

@end
