//
//  InventoryItemSelectionListVC.h
//  RapidRMS
//
//  Created by Siya9 on 16/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "InventoryItemListVC.h"

@protocol InventoryItemSelectionListVCDelegate <NSObject>
    -(void)didSelectedItems:(NSArray *) arrLitemList;
@end
@interface InventoryItemSelectionListVC : InventoryItemListVC
/**
 *  which item code not allow selected
 */
@property (nonatomic, strong) NSArray<NSNumber *> * arrNotSelectedItemCodes;
@property (nonatomic, strong) NSString * strNotSelectionMsg;
@property (nonatomic) BOOL isSingleSelection;

@property (nonatomic, weak) id<InventoryItemSelectionListVCDelegate> delegate;
@end
