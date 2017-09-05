//
//  MultipleItemBarcodeRingUpVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/15/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@protocol InventoryCountItemSelectionVCDelegate<NSObject>
-(void)didSelectItemFromMultipleDuplicateBarcode :(Item *)item;
-(void)didCanceMultipleItemBarcodeCustomerVC;
@end

@interface InventoryCountItemSelectionVC : UIViewController
@property (nonatomic,retain)NSMutableArray *multipleItemArray;
@property (nonatomic, weak) id<InventoryCountItemSelectionVCDelegate> inventoryCountItemSelectionVCDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *itemBarcode;

@end