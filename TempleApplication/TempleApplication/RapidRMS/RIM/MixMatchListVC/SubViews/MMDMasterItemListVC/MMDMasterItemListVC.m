//
//  MMDMasterItemListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDMasterItemListVC.h"
#import "MMDItemSelectionCell.h"
#import "MMDMasterListVC.h"

#import "RmsDbController.h"
#import "Item+Dictionary.h"

@interface MMDMasterItemListVC ()<DidSelectMasterDelegate,DidChangeItemListDelegate> {
    MMDItemListVC * itemList;
    MMDMasterListVC * masterListVC;
}

@property (nonatomic, weak) IBOutlet UIView * viewMaesterDetail;
@property (nonatomic, weak) IBOutlet UIView * viewItemDetailDetail;
@end

@implementation MMDMasterItemListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tblMMMasterItemList.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];


    [self addMasterItemVC];
    [self addMasterListViewVC];
    [itemList viewWillAppear:YES];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    
}
#pragma mark - gettter setter -
-(void)setStrItemSectionTitle:(NSString *)strItemSectionTitle {
    itemList.strItemSectionTitle = strItemSectionTitle;
    _strItemSectionTitle = strItemSectionTitle;
}
-(void)setFilterTextSearchPredicate:(NSPredicate *)filterTextSearchPredicate {
    if (filterTextSearchPredicate) {
         itemList.filterTextSearchPredicate = filterTextSearchPredicate;
    }
    _filterTextSearchPredicate = filterTextSearchPredicate;
}
-(void)setIsAllSelected:(BOOL)isAllSelected {
    itemList.isAllSelected = isAllSelected;
    _isAllSelected = isAllSelected;
}
-(NSMutableArray *)arrSelectedItem {
    return itemList.arrSelectedItem;
}
-(UITableView *)tblMMMasterItemList {
    return itemList.tblMMDiscountItemList;
}
-(void)setArrAddedItem:(NSMutableArray *)arrAddedItem {
    _arrAddedItem = arrAddedItem;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        itemList.arrAddedItem = [[NSArray alloc]initWithArray:arrAddedItem];
        [itemList.tblMMDiscountItemList reloadData];
    });
}
-(void)addMasterListViewVC {
    if (!masterListVC) {
        masterListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDMasterListVC_sid"];
        
        masterListVC.view.frame = _viewMaesterDetail.bounds;
        masterListVC.selectedMaster = self.selectedMaster;
        masterListVC.Delegate = self;
        [self addChildViewController:masterListVC];
        [_viewMaesterDetail addSubview:masterListVC.view];
        [masterListVC didMoveToParentViewController:self];
    }
}

-(void)didSelectMasterInfo:(NSPredicate *) filterMaster {
//    NSNumber * masterId = [[NSNumber alloc] initWithInt:[[dictMaster objectForKey:@"masterId"] intValue]];
//    NSPredicate * filterItem;
//    switch (self.selectedMaster) {
//        case MasterTypesTAG: {
//            filterItem = [NSPredicate predicateWithFormat:@"ANY itemTags.sizeId == %@",masterId];
//            break;
//        }
//        case MasterTypesGroup: {
//            filterItem = [NSPredicate predicateWithFormat:@"itemGroupMaster.groupId == %@",masterId];
//            break;
//        }
//    }
//    if (filterMaster) {
    if (filterMaster) {
        itemList.filterMasterPredicate = filterMaster;
    }
    itemList.filterTextSearchPredicate = nil;
//    }
    [self.Delegate searchTextChangeToNewString:@"" withReloadList:NO];
}

-(void)addMasterItemVC {
    if (!itemList) {
        itemList =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDSmallItemListVC_sid"];
       itemList.view.frame = _viewItemDetailDetail.bounds ;// viewItemDetailDetail.bounds;
        itemList.filterMasterPredicate = nil;
        itemList.Delegate = self;
        [self addChildViewController:itemList];
        [_viewItemDetailDetail addSubview:itemList.view];
        [itemList didMoveToParentViewController:self];
    }
}

-(void)didItemTitleListReloaded:(NSArray *)arrTitleList {
    NSMutableArray * arrMTitleList = [[NSMutableArray alloc] initWithArray:arrTitleList];
    if ([arrMTitleList containsObject:@"ALL"]) {
        [arrMTitleList removeObject:@"ALL"];
    }
    [self.Delegate didItemTitleListReloaded:arrMTitleList];
}

-(void)didAllItemSelected:(BOOL)isAllSelected {
    [self.Delegate didAllItemSelected:isAllSelected];
}

@end
