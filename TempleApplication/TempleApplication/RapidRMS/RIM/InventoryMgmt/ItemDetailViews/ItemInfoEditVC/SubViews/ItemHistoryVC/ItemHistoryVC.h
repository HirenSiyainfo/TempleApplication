//
//  ItemHistoryVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoDataObject.h"
#import "PopupSuperVC.h"

@protocol ItemHistoryVCDelegate <NSObject>
- (void)itemHistoryDataFromDictionary:(NSDictionary *)dictionary;
@end

@interface ItemHistoryVC : PopupSuperVC

@property (nonatomic ,weak) id<ItemHistoryVCDelegate> itemHistoryVCDelegate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) ItemInfoDataObject * itemInfoDataObject;

@property (nonatomic, weak) IBOutlet UITableView *tblHistory;

@property (nonatomic, strong) NSDictionary *itemQtyDict;
@end
