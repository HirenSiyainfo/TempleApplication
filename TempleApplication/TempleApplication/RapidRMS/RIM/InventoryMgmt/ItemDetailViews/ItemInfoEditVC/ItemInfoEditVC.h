//
//  ItemInfoEditVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 29/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ItemInfoDataObject.h"
#import "DisplayItemInfoSideVC.h"

typedef NS_ENUM(NSInteger, ItemEditTab)
{
    ItemEditTabInfo = 1111,
    ItemEditTabDiscount = 2222,
    ItemEditTabHistory = 3333,
    ItemEditTabOption = 4444,
    ItemEditTabPricing = 5555,
};


@protocol ItemInfoEditVCDelegate <NSObject>
    - (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo;
    - (void)didUpdateItemInfo:(NSDictionary*)itemInfoData;
    - (void)dismissInventoryAddNewSplitterVC;

@end

@interface ItemInfoEditVC : UIViewController <UIScrollViewDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITabBarControllerDelegate, UITabBarDelegate, UpdateDelegate,DisplayItemInfoSideVCDeledate>



@property (nonatomic, weak) id<ItemInfoEditVCDelegate> itemInfoEditVCDelegate;

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, strong) ItemInfoDataObject * itemInfoDataObject;

@property (nonatomic) BOOL NewOrderCalled;
@property (nonatomic) BOOL isCopy;
@property (nonatomic) BOOL isInvenManageCalled;
@property (nonatomic) BOOL isWaitForLiveUpdate;

@property (nonatomic, strong) NSString * strScanBarcode;
@property (nonatomic, strong) NSMutableDictionary * dictNewOrderData;

@end