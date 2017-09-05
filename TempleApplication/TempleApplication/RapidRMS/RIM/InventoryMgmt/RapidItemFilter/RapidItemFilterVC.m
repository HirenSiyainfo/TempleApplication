//
//  RapidItemFilterVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RapidItemFilterVC.h"
#import "RapidItemFilterTypeVC.h"
#import "RapidFilterSelectedListCell.h"

@interface RapidItemFilterVC ()<RapidItemFilterTypeVCDeledate,RapidFilterSelectedListCellDeledate> {
    NSArray * arrFilterKeys;
    RapidItemFilterTypeVC * objFilterTypeVC;
}

@property (nonatomic, weak) IBOutlet UITableView * tblFilterDataList;
@property (nonatomic, weak) IBOutlet UIView * viewFilterTable;
@property (nonatomic, weak) IBOutlet UIView * viewFilterTypeList;
@end

@implementation RapidItemFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addFilterTypesView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction -
-(IBAction)btnClearAllSelectionTapped:(UIButton *)sender {
    for (NSString * numKey in self.dictFilterInfo.allKeys) {
        [self.dictFilterInfo removeObjectForKey:numKey];
    }
    objFilterTypeVC.dictFilterInfo = self.dictFilterInfo;
    [self createKeyArrayForTableRows];
    [self.tblFilterDataList reloadData];
    
    if (self.viewFilterTable.frame.size.height > 114) {
        CGRect frame = self.viewFilterTable.frame;
        frame.size.height = 114;
        sender.selected = FALSE;
        [UIView animateWithDuration:0.5 animations:^{
            self.viewFilterTable.frame = frame;
        }];
    }
}
-(IBAction)btnCollapseExpandTapped:(UIButton *)sender {
    CGRect frame = self.viewFilterTable.frame;
    if (self.viewFilterTable.frame.size.height > 114) {
        frame.size.height = 114;
        sender.selected = FALSE;
    }
    else {
        frame.size.height = self.view.frame.size.height;
        sender.selected = TRUE;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.viewFilterTable.frame = frame;
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrFilterKeys.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RapidFilterSelectedListCell *cell = (RapidFilterSelectedListCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSNumber * numKey = arrFilterKeys[indexPath.row];
    NSArray * arrItemList = (self.dictFilterInfo)[numKey];
    
    MPTagList * tagList = [[MPTagList alloc] initWithFrame:cell.contentView.bounds];
    
    [tagList setAutomaticResize:YES];
    [tagList setTags:[arrItemList valueForKey:@"name"]];
    
    return tagList.frame.size.height + 25;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RapidFilterSelectedListCell *cell = (RapidFilterSelectedListCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RapidFilterSelectedListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    NSNumber * numKey = arrFilterKeys[indexPath.row];
    NSArray * arrItemList = (self.dictFilterInfo)[numKey];
    cell.deledate = self;
    
    [cell configureCellToItem:arrItemList withMasterType:(RapidItemFilterType)numKey.intValue withTitle:[RapidItemFilterTypeVC getStringFromFilterType:(RapidItemFilterType)numKey.intValue]];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)willCellChangeSelectedFilterTypeItemlist:(NSArray *)arrNewFilterItemList withFilterType:(RapidItemFilterType) filterType {
    [self resetMasteritemAddedOrDeletedItem:arrNewFilterItemList withFilterType:filterType isApply:NO];
}
#pragma mark - RapidItemFilterTypeItemVC -
-(void)addFilterTypesView{
    if (!objFilterTypeVC) {
        objFilterTypeVC =
        [[UIStoryboard storyboardWithName:@"RimStoryboard"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidItemFilterTypeVC_sid"];
        objFilterTypeVC.view.frame = self.viewFilterTypeList.bounds;
        objFilterTypeVC.deledate = self;
        UINavigationController * objNav = [[UINavigationController alloc]initWithRootViewController:objFilterTypeVC];
        objNav.navigationBarHidden = TRUE;
        objNav.view.frame = self.viewFilterTypeList.bounds;
        [self addChildViewController:objNav];
        [self.viewFilterTypeList addSubview:objNav.view];
        [objNav didMoveToParentViewController:self];
    }
}
-(void)willChangeSelectedFilterTypeItem:(NSArray *)arrFilterItemList withFilterType:(RapidItemFilterType) filterType isApply:(BOOL) isApply {
    [self resetMasteritemAddedOrDeletedItem:arrFilterItemList withFilterType:filterType isApply:isApply];
}
-(void)willChangeRapidFilterIsSlidein:(BOOL)isSlidein{
#ifdef IS_CLICK_TO_SEARCH
    if ([self.deledate respondsToSelector:@selector(willChangeRapidFilterIsSlidein:)]) {
        [self.deledate willChangeRapidFilterIsSlidein:NO];
    }
#endif
}
-(void)resetMasteritemAddedOrDeletedItem:(NSArray *)arrFilterItemList withFilterType:(RapidItemFilterType) filterType isApply:(BOOL) isApply {
    if (arrFilterItemList.count > 0) {
        (self.dictFilterInfo)[@(filterType)] = arrFilterItemList;
    }
    else {
        [self.dictFilterInfo removeObjectForKey:@(filterType)];
    }
    objFilterTypeVC.dictFilterInfo = self.dictFilterInfo;
    [self createKeyArrayForTableRows];
    [self.tblFilterDataList reloadData];

}
-(NSArray *)getSelectedObjectForFilterType:(RapidItemFilterType) filterType {
    NSArray * arrItemList = (self.dictFilterInfo)[@(filterType)];
    if (!arrItemList) {
        arrItemList = [[NSArray alloc]init];
    }
    return arrItemList;
}
-(void)createKeyArrayForTableRows {
    NSMutableArray * arrmNewFliterList = [[NSMutableArray alloc]init];
    NSArray * arrFilterType = @[@(RapidItemFilterTypeDepartment),@(RapidItemFilterTypeSubDepartment),@(RapidItemFilterTypeVendor),@(RapidItemFilterTypeGroup),@(RapidItemFilterTypeTag),@(RapidItemFilterTypeSearchedItem),@(RapidItemFilterTypeCategories)];
    
    for (NSNumber * itemType in arrFilterType) {
        
        NSMutableArray * arrFilteredList = (self.dictFilterInfo)[itemType];
        
        if (arrFilteredList.count > 0) {
            [arrmNewFliterList addObject:itemType];
        }
    }
    
    arrFilterKeys = [[NSArray alloc]initWithArray:arrmNewFliterList];
}

-(void)willSetRapidItemFilterPredicate:(NSPredicate *) predicate withFilterDictionary:(NSDictionary *)dictFilterInfo {
    if ([self.deledate respondsToSelector:@selector(willSetRapidItemFilterPredicate:withFilterDictionary:)]) {
        [self.deledate willSetRapidItemFilterPredicate:predicate withFilterDictionary:self.dictFilterInfo];
    }
}

#pragma mark - Slide in Out -
-(void)filterViewSlideIn:(BOOL)isSlideIn {
    UIView * viewFilterBG = self.view.superview;
    [viewFilterBG bringSubviewToFront:self.view];
    CGRect frame = viewFilterBG.bounds;
    viewFilterBG.hidden = FALSE;

    if (isSlideIn) {
        self.view.frame = CGRectMake(viewFilterBG.frame.size.width, 0, viewFilterBG.frame.size.width, viewFilterBG.frame.size.height);
        [self loadDefaultFilterValues];
        [self.tblFilterDataList reloadData];
    }
    else {
        frame.origin.x = frame.size.width + 20;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        if (isSlideIn) {
            viewFilterBG.hidden = FALSE;
        }
        else {
            viewFilterBG.hidden = TRUE;
        }
    }];
}
-(void)loadDefaultFilterValues {
    if (!self.dictFilterInfo || (self.dictFilterInfo && self.dictFilterInfo.count == 0)) {
        //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DEFAULT_FILTER_SAVED];
        
        NSDictionary * dictDefautlSetting = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_FILTER_SAVED];
        if (dictDefautlSetting != nil) {
            NSMutableDictionary * dictSaved = [NSMutableDictionary dictionary];
            for (NSString * numKey in dictDefautlSetting.allKeys) {
                dictSaved[@(numKey.intValue)] = dictDefautlSetting[numKey];
            }
            self.dictFilterInfo = [[NSMutableDictionary alloc]initWithDictionary:dictSaved];
            [self createKeyArrayForTableRows];
        }
        else if (!self.dictFilterInfo){
            self.dictFilterInfo = [[NSMutableDictionary alloc]init];
        }
        objFilterTypeVC.dictFilterInfo = self.dictFilterInfo;
    }

}
@end
