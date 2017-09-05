//
//  BillItem.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BillAmountComponents;

@interface BillItem : NSObject

@property (nonatomic) float itemQuantity;

- (instancetype)initWithItem:(Item *)ringupItem NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *name;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *barcode;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *imagePath;
@property (NS_NONATOMIC_IOSONLY, readonly) float salesPrice;


@property (NS_NONATOMIC_IOSONLY, readonly, strong) BillAmountComponents *billAmountComponents;

@end
