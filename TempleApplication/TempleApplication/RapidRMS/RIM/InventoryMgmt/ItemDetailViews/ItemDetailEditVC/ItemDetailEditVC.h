//
//  InventoryAddNewSplitterVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item+Dictionary.h"

@protocol ItemInfoEditRedirectionVCDelegate <NSObject>
    - (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo;
@end

@interface ItemDetailEditVC : UIViewController <UITextViewDelegate>

@property (nonatomic, weak) id<ItemInfoEditRedirectionVCDelegate> itemInfoEditRedirectionVCDelegate;

@property (nonatomic) BOOL isItemCopy;
@property (nonatomic) BOOL isItemFavourite;

@property (nonatomic, strong) NSString *searchedBarcode;

@property (nonatomic, strong) NSMutableDictionary *navigationInfo;
@property (nonatomic, strong) NSMutableDictionary *selectedItemInfoDict;
@property (nonatomic, strong) NSMutableDictionary *predefineInfoItemInfoDict;

@end
