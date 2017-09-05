//
//  MMDItemListVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DidChangeItemListDelegate <NSObject>
-(void)didItemTitleListReloaded:(NSArray *)arrTitleList;
-(void)didAllItemSelected:(BOOL)isAllSelected;
@optional
-(void)searchTextChangeToNewString:(NSString *)strtext withReloadList:(BOOL)isReload;
@end

@interface MMDItemListVC : UIViewController

@property (nonatomic, weak) id<DidChangeItemListDelegate> Delegate;
@property (nonatomic, weak) IBOutlet UITableView * tblMMDiscountItemList;

@property (nonatomic, strong) NSPredicate * filterMasterPredicate;
@property (nonatomic, strong) NSArray * arrAddedItem;
@property (nonatomic, strong) NSMutableArray * arrSelectedItem;
@property (nonatomic, strong) NSString * strItemSectionTitle;
@property (nonatomic, strong) NSPredicate * filterTextSearchPredicate;
@property (nonatomic) BOOL isAllSelected;

@end
