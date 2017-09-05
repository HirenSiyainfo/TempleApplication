//
//  POOpenOrderFilter.m
//  RapidRMS
//
//  Created by Siya10 on 16/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POOpenOrderFilter.h"
#import "MPTagList.h"
#import "RapidFilterSelectedListCell.h"
#import "POFilterType.h"

@interface POOpenOrderFilter ()<POFilterTypeDelegate>
{
    NSArray * arrFilterKeys;
    POFilterType *objFilterTypeVC;
}
@property (nonatomic, weak) IBOutlet UITableView * tblFilterDataList;
@property (nonatomic, weak) IBOutlet UIView * viewFilterTable;
@property (nonatomic, weak) IBOutlet UIView * viewFilterTypeList;
@end

@implementation POOpenOrderFilter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [self addFilterTypesView];
}
#pragma mark - RapidItemFilterTypeItemVC -
-(void)addFilterTypesView{
    if (!objFilterTypeVC) {
        objFilterTypeVC =
        [[UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"POFilterType"];
        objFilterTypeVC.suppArray = self.suppArray;
        objFilterTypeVC.deptArray = self.deptArray;
        objFilterTypeVC.filterTypedelegate = self;
        objFilterTypeVC.view.frame = self.viewFilterTypeList.bounds;
        UINavigationController * objNav = [[UINavigationController alloc]initWithRootViewController:objFilterTypeVC];
        
        objNav.navigationBarHidden = TRUE;
        objNav.view.frame = self.viewFilterTypeList.bounds;
        [self addChildViewController:objNav];
        [self.viewFilterTypeList addSubview:objNav.view];
        [objNav didMoveToParentViewController:self];
       
    }
}
#pragma mark POFilterTypeDelegate method

-(void)applyFilterButton:(NSMutableArray *)deptArray withSup:(NSMutableArray *)supArray{

    [self.poOpenOrderFilterDelegate didapplyFilterToItems:self.deptArray withSup:self.suppArray];
}
-(void)didloadManualFilterOption{
    
    [self.poOpenOrderFilterDelegate didloadManuelFilterOption];
}

-(void)createKeyArrayForTableRows {
    NSMutableArray * arrmNewFliterList = [[NSMutableArray alloc]init];
    NSArray * arrFilterType = @[@(OpenOrderFilterTypeDepartment),@(OpenOrderFilterTypeVendor),@(OpenOrderFilterTypeManual)];
    
    for (NSNumber * itemType in arrFilterType) {
        
        NSMutableArray * arrFilteredList = (self.dictFilterInfo)[itemType];
        
        if (arrFilteredList.count > 0) {
            [arrmNewFliterList addObject:itemType];
        }
    }
    
    arrFilterKeys = [[NSArray alloc]initWithArray:arrmNewFliterList];
}
#pragma mark - IBAction -
-(IBAction)btnClearAllSelectionTapped:(UIButton *)sender {
    for (NSString * numKey in self.dictFilterInfo.allKeys) {
        [self.dictFilterInfo removeObjectForKey:numKey];
    }
  //  objFilterTypeVC.dictFilterInfo = self.dictFilterInfo;
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
       // objFilterTypeVC.dictFilterInfo = self.dictFilterInfo;
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
   // cell.deledate = self;
    
   // [cell configureCellToItem:arrItemList withMasterType:(RapidItemFilterType)numKey.intValue withTitle:[RapidItemFilterTypeVC getStringFromFilterType:(RapidItemFilterType)numKey.intValue]];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
