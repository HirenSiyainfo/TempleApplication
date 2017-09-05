//
//  ItemOptionsVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 08/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoDataObject.h"

@protocol ItemOptionsVCDelegate <NSObject>
- (void)isActiveApply:(BOOL)isActive;
- (void)isFavoriteApply:(BOOL)isFavorite;
- (void)isdisplayInPosApply:(BOOL)isDisplayInPos;
- (void)quantityManagementEnable:(BOOL)isQtyMgtEnabled;
- (void)isItemPayoutApply:(BOOL)isItemPayout;
- (void)isMemoApplyToItem:(BOOL)isMemoApply;
- (void)isEBTApplyToItem:(BOOL)isEBTApply;
- (void)childQtyForItem:(NSNumber *)ChildQty;
- (void)minStockLevel:(NSNumber *)MinStock;
- (void)maxStockLevel:(NSNumber *)MaxStock;
- (void)parentItemSelected:(NSNumber *) CITM_Code;
- (void)didRemoveParentItem;

@end

@interface ItemOptionsVC : UIViewController

@property (nonatomic, weak) id<ItemOptionsVCDelegate> itemOptionsVCDelegate;
@property (nonatomic, strong) ItemInfoDataObject * itemInfoDataObject;

@property (nonatomic, weak) IBOutlet UITableView *tblOption;

//@property (nonatomic) BOOL boolpass;//self.itemInfoDataObject.SelectedOption
@property (nonatomic) BOOL isUpdateItem;
@end
