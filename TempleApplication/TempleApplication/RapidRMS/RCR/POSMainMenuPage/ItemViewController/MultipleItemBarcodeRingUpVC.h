//
//  MultipleItemBarcodeRingUpVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/15/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInventoryCount.h"

@class Item;
@protocol MultipleItemBarcodeRingUpDelegate<NSObject>
-(void)didRingUpItemFormMultipleItemForDuplicateBarcode :(Item *)item withItemQty:(NSNumber *)qty withPackageType: (NSString *)packageType;

-(void)didCanceMultipleItemBarcodeCustomerVC;

@end
@interface MultipleItemBarcodeRingUpVC : UIViewController


@property (nonatomic, weak) id<MultipleItemBarcodeRingUpDelegate> multipleItemBarcodeRingUpDelegate;
@property (nonatomic,strong) NSString *itemBarcode;
@property (nonatomic,strong) NSMutableArray *multipleItemArray;
@property (nonatomic, strong) ItemInventoryCount *selectedItemInventoryCount;

@end
