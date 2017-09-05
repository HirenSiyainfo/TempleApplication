//
//  MultipleBarcodePopUpVCViewController.h
//  RapidRMS
//
//  Created by Siya Infotech on 21/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopupSuperVC.h"

#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif

typedef NS_ENUM(NSInteger, ItemBarcodeType) {
    ItemBarcodeTypeAll,
    ItemBarcodeTypeSingleItem,
    ItemBarcodeTypeCase,
    ItemBarcodeTypePack,
};
@protocol MultipleBarcodePopUpVCDelegate <NSObject>
    - (void)didUpdateMultipleBarcode:(NSMutableArray *)itemBarcodes allowToItems:(NSString *)allowToItems;
@end

@interface MultipleBarcodePopUpVC : PopupSuperVC

@property (nonatomic, weak) id<MultipleBarcodePopUpVCDelegate> multipleBarcodePopUpVCDelegate;
@property (nonatomic) ItemBarcodeType editingPackageType;

@property (nonatomic) BOOL isDuplicateBarcodeAllowed;

@property (nonatomic, strong) NSString *itemCode;
@property (nonatomic, strong) Item *anItem;
@property (nonatomic, strong) NSMutableArray * arrItemBarcodeList;

@end
