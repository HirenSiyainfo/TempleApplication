//
//  MMDMasterItemListVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDMasterListVC.h"
#import "MMDItemListVC.h"
@interface MMDMasterItemListVC : UIViewController

@property (nonatomic, weak) id<DidChangeItemListDelegate> Delegate;
@property (nonatomic, weak) UITableView * tblMMMasterItemList;

@property (nonatomic) MasterTypes selectedMaster;
@property (nonatomic) BOOL isAllSelected;

@property (nonatomic, strong) NSMutableArray * arrSelectedItem;
@property (nonatomic, strong) NSMutableArray * arrAddedItem;

@property (nonatomic, strong) NSPredicate * filterTextSearchPredicate;
@property (nonatomic, strong) NSString * strItemSectionTitle;

@end
