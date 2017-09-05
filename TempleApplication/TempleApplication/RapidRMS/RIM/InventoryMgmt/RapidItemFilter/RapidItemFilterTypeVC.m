//
//  RapidItemFilterTypeVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RapidItemFilterTypeVC.h"
#import "RapidItemFilterVC.h"
#import "RapidItemFilterTypeWebItemVC.h"
#import "RmsDbController.h"
#import "RapidFilterMasterTypeCell.h"

@interface RapidItemFilterTypeVC () <UITableViewDataSource,UITableViewDelegate,RapidItemFilterTypeItemVCDeledate> {
    RapidItemFilterTypeItemVC * objRapidItemFilterTypeItemVC;
    RapidItemFilterType selectedFilterType;
}

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) IBOutlet UITableView * tblFilterTypeList;
@end

@implementation RapidItemFilterTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    if (!self.arrFilterTypes || self.arrFilterTypes.count ==0 ) {
        if ([self isRestaurentActive]) {
            self.arrFilterTypes = @[@(RapidItemFilterTypeDepartment),@(RapidItemFilterTypeSubDepartment),@(RapidItemFilterTypeVendor),@(RapidItemFilterTypeGroup),@(RapidItemFilterTypeTag),@(RapidItemFilterTypeSearchedItem),@(RapidItemFilterTypeCategories)];
        }
        else {
            self.arrFilterTypes = @[@(RapidItemFilterTypeDepartment),@(RapidItemFilterTypeVendor),@(RapidItemFilterTypeGroup),@(RapidItemFilterTypeTag),@(RapidItemFilterTypeSearchedItem),@(RapidItemFilterTypeCategories)];
        }
        
    }
    self.managedObjectContext = [UpdateManager privateConextFromParentContext:[RmsDbController sharedRmsDbController].managedObjectContext];
    UIButton * btnsetDefault = [self.view viewWithTag:1001];
    btnsetDefault.layer.borderWidth = 2.0f;
    btnsetDefault.layer.borderColor = [UIColor colorWithRed:0.278 green:0.576 blue:0.671 alpha:1.000].CGColor;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setDictFilterInfo:(NSDictionary *)dictFilterInfo {
    _dictFilterInfo = dictFilterInfo;
    [self.tblFilterTypeList reloadData];
#ifdef IS_CLICK_TO_SEARCH
    if ([self.deledate respondsToSelector:@selector(willSetRapidItemFilterPredicate:withFilterDictionary:)]) {
        NSPredicate * predicate = [self createCurrentInfoPredicate];
        [self.deledate willSetRapidItemFilterPredicate:predicate withFilterDictionary:self.dictFilterInfo];
    }
    if (objRapidItemFilterTypeItemVC) {
        objRapidItemFilterTypeItemVC.arrFilterTypesSelectedItems = [[self.deledate getSelectedObjectForFilterType:selectedFilterType] mutableCopy];
    }
#endif
}

#pragma mark - IBAction -
-(IBAction)saveDefaultFilterButton:(id)sender {
    if (self.dictFilterInfo.allKeys.count > 0) {
        NSMutableDictionary * dictSaved = [NSMutableDictionary dictionary];
        for (NSNumber * numKey in self.dictFilterInfo.allKeys) {
            dictSaved[numKey.stringValue] = (self.dictFilterInfo)[numKey];
        }
        [[NSUserDefaults standardUserDefaults] setObject:dictSaved forKey:DEFAULT_FILTER_SAVED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(IBAction)applyFilterButton:(id)sender {
    if ([self.deledate respondsToSelector:@selector(willSetRapidItemFilterPredicate:withFilterDictionary:)]) {
        NSPredicate * predicate = [self createCurrentInfoPredicate];
        [self.deledate willSetRapidItemFilterPredicate:predicate withFilterDictionary:self.dictFilterInfo];
    }
}
-(IBAction)closeFilterButton:(id)sender {
#ifdef IS_CLICK_TO_SEARCH
    if ([self.deledate respondsToSelector:@selector(willChangeRapidFilterIsSlidein:)]) {
        [self.deledate willChangeRapidFilterIsSlidein:YES];
    }
#endif
}
-(NSPredicate *)createCurrentInfoPredicate {

    NSMutableArray * arrfilterParedicates = [NSMutableArray array];

    for (NSNumber * itemType in self.arrFilterTypes) {
        
        NSMutableArray * arrFilteredList = (self.dictFilterInfo)[itemType];
        if (arrFilteredList.count > 0) {
            RapidItemFilterType filterType = (RapidItemFilterType)itemType.intValue;
            switch (filterType) {
                case RapidItemFilterTypeDepartment: {
                    NSPredicate * subPredicate = [NSPredicate predicateWithFormat:@"itemDepartment.deptId IN %@",[arrFilteredList valueForKey:@"object"]];
                    [arrfilterParedicates addObject:subPredicate];
                    break;
                }
                case RapidItemFilterTypeSubDepartment: {
                    NSPredicate * subPredicate = [NSPredicate predicateWithFormat:@"itemSubDepartment.brnSubDeptID IN %@",[arrFilteredList valueForKey:@"object"]];
                    [arrfilterParedicates addObject:subPredicate];
                    break;
                }
                case RapidItemFilterTypeVendor: {
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemSupplier" inManagedObjectContext:self.managedObjectContext];
                    fetchRequest.entity = entity;
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vendorId IN %@",[arrFilteredList valueForKey:@"object"]];
                    fetchRequest.predicate = predicate;
                    NSArray *supllierListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
                    NSPredicate * subPredicate = [NSPredicate predicateWithFormat:@"itemCode IN %@",[supllierListArray valueForKey:@"itemCode"]];
                    [arrfilterParedicates addObject:subPredicate];
                    
                    break;
                }
                case RapidItemFilterTypeGroup: {
                    NSPredicate * subPredicate = [NSPredicate predicateWithFormat:@"itemGroupMaster.groupId IN %@",[arrFilteredList valueForKey:@"object"]];
                    [arrfilterParedicates addObject:subPredicate];
                    break;
                }
                case RapidItemFilterTypeTag: {
                    NSPredicate * subPredicate = [NSPredicate predicateWithFormat:@"ANY itemTags.tagToSizeMaster.sizeId IN %@",[arrFilteredList valueForKey:@"object"]];
                    [arrfilterParedicates addObject:subPredicate];
                    break;
                }
                case RapidItemFilterTypeSearchedItem: {
                    NSPredicate * subPredicate = [NSPredicate predicateWithFormat:@"itemCode IN %@",[arrFilteredList valueForKey:@"object"]];
                    [arrfilterParedicates addObject:subPredicate];
                    break;
                }
                case RapidItemFilterTypeCategories: {
                    
                    break;
                }
            }
        }
    }

    NSPredicate *compoundpred = [NSCompoundPredicate andPredicateWithSubpredicates:arrfilterParedicates];
    return compoundpred;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.arrFilterTypes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RapidFilterMasterTypeCell *cell = (RapidFilterMasterTypeCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSNumber * intType = (NSNumber *)(self.arrFilterTypes)[indexPath.row];
    RapidItemFilterType filterType = (RapidItemFilterType)intType.intValue;
    cell.lblTitle.text = [RapidItemFilterTypeVC getStringFromFilterType:filterType];
    cell.lblSubDetail.text = [self countItemForFilterType:filterType];
    UIView * viewBG = [[UIView alloc]init];
    viewBG.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];
    cell.selectedBackgroundView = viewBG;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber * intType = (NSNumber *)(self.arrFilterTypes)[indexPath.row];
    RapidItemFilterType filterType = (RapidItemFilterType)intType.intValue;

    if (RapidItemFilterTypeTag >= filterType) {
//        if (!objRapidItemFilterTypeItemVC) {
        objRapidItemFilterTypeItemVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidItemFilterTypeItemVC_sid"];
        
        objRapidItemFilterTypeItemVC.deledate = self;
//        }
        objRapidItemFilterTypeItemVC.filterType = filterType;
        selectedFilterType = filterType;
        objRapidItemFilterTypeItemVC.arrFilterTypesSelectedItems = [[self.deledate getSelectedObjectForFilterType:filterType] mutableCopy];
        
        [self.navigationController pushViewController:objRapidItemFilterTypeItemVC animated:YES];

    }
    else {
        return;
        NSMutableArray * arr = [[NSMutableArray alloc]init];
        [arr addObject:@{@"name":@"109004",@"object" : @"109004"}];
        [arr addObject:@{@"name":@"109097",@"object" : @"109097"}];
        [arr addObject:@{@"name":@"814006",@"object" : @"814006"}];
        [arr addObject:@{@"name":@"AR04",@"object" : @"AR04"}];
        [arr addObject:@{@"name":@"AR11",@"object" : @"AR11"}];
        [arr addObject:@{@"name":@"21369",@"object" : @"21369"}];
        [arr addObject:@{@"name":@"0434",@"object" : @"0434"}];
        [arr addObject:@{@"name":@"100009",@"object" : @"100009"}];
        [arr addObject:@{@"name":@"100029",@"object" : @"100029"}];
        [arr addObject:@{@"name":@"BR",@"object" : @"BR"}];
        [arr addObject:@{@"name":@"100001",@"object" : @"100001"}];
        [arr addObject:@{@"name":@"100002",@"object" : @"100002"}];
        
        NSMutableArray * arrAllItem = [[self getItemNameFromItemID:[arr valueForKey:@"object"]] mutableCopy];
        for (int i = 0; i < arrAllItem.count; i++) {
            NSDictionary * dict = arrAllItem[i];
            arrAllItem[i] = @{@"name":dict[@"item_Desc"],@"object":dict[@"itemCode"]};
        }
        [self pushRapidItemFilterTypeWebItemVC:arrAllItem forItemFilterType:filterType];
    }
}
-(NSArray *)getItemNameFromItemID:(NSArray *) arrItemId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.resultType = NSDictionaryResultType;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"any itemBarcodes.barCode IN %@",arrItemId];
    fetchRequest.propertiesToFetch = @[@"item_Desc", @"itemCode" , @"barcode"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"item_Desc" ascending:YES]];

    fetchRequest.predicate = searchPredicate;
    return [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
};
-(void)pushRapidItemFilterTypeWebItemVC:(NSArray *)arrAllItems forItemFilterType:(RapidItemFilterType) filterType {
    RapidItemFilterTypeWebItemVC * objRapidItemFilterTypeWebItemVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidItemFilterTypeWebItemVC_sid"];
    
    objRapidItemFilterTypeWebItemVC.deledate = self;
    //        }
    objRapidItemFilterTypeWebItemVC.filterType = filterType;
    objRapidItemFilterTypeWebItemVC.arrFilterTypesSelectedItems = [[self.deledate getSelectedObjectForFilterType:filterType] mutableCopy];
    objRapidItemFilterTypeWebItemVC.arrAllItem = arrAllItems;
    [self.navigationController pushViewController:objRapidItemFilterTypeWebItemVC animated:YES];

}
-(void)willChangeSelectedFilterTypeItem:(NSArray *)arrFilterItemList withFilterType:(RapidItemFilterType) filterType {
    if ([self.deledate respondsToSelector:@selector(willChangeSelectedFilterTypeItem:withFilterType:isApply:)]) {
        [self.deledate willChangeSelectedFilterTypeItem:arrFilterItemList withFilterType:filterType isApply:NO];
    }
#ifdef IS_CLICK_TO_SEARCH
    if ([self.deledate respondsToSelector:@selector(willSetRapidItemFilterPredicate:withFilterDictionary:)]) {
        NSPredicate * predicate = [self createCurrentInfoPredicate];
        [self.deledate willSetRapidItemFilterPredicate:predicate withFilterDictionary:self.dictFilterInfo];
    }
#endif
    [self.tblFilterTypeList reloadData];
}
-(void)willApplyFilter {
    if ([self.deledate respondsToSelector:@selector(willSetRapidItemFilterPredicate:withFilterDictionary:)]) {
        NSPredicate * predicate = [self createCurrentInfoPredicate];
        [self.deledate willSetRapidItemFilterPredicate:predicate withFilterDictionary:self.dictFilterInfo];
    }
}
-(NSString *)countItemForFilterType:(RapidItemFilterType )filtertype {
    NSString * strEntityName = @"";
    switch (filtertype) {
        case RapidItemFilterTypeDepartment: {
            strEntityName = @"Department";
            break;
        }
        case RapidItemFilterTypeSubDepartment: {
            strEntityName = @"SubDepartment";
            break;
        }
        case RapidItemFilterTypeVendor: {
            strEntityName = @"SupplierCompany";
            break;
        }
        case RapidItemFilterTypeGroup: {
            strEntityName = @"GroupMaster";
            break;
        }
        case RapidItemFilterTypeTag: {
            strEntityName = @"SizeMaster";
            break;
        }
        case RapidItemFilterTypeSearchedItem: {
            strEntityName = @"";
            break;
        }
        case RapidItemFilterTypeCategories: {
            strEntityName = @"";
            break;
        }
    }
    if (strEntityName.length > 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:strEntityName inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        if (filtertype == RapidItemFilterTypeTag) {
            NSPredicate * subpredicate = [NSPredicate predicateWithFormat:@"sizeName BEGINSWITH[cd] %@",@"#"];
            subpredicate = [NSCompoundPredicate notPredicateWithSubpredicate:subpredicate];
            
            fetchRequest.predicate = subpredicate;
        }
        else if (filtertype == RapidItemFilterTypeCategories) {
            NSPredicate * subpredicate = [NSPredicate predicateWithFormat:@"sizeName BEGINSWITH[cd] %@",@"#"];
            fetchRequest.predicate = subpredicate;
        }
        NSInteger countAll = [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
        NSInteger countSelected = [self.deledate getSelectedObjectForFilterType:filtertype].count;
        if (countSelected == 0) {
            return [NSString stringWithFormat:@"(%ld)",(long)countAll];
        }
        else if (countSelected == countAll) {
            return [NSString stringWithFormat:@"ALL"];
        }
        else {
            return [NSString stringWithFormat:@"(%lu/%ld)",(long)[self.deledate getSelectedObjectForFilterType:filtertype].count,(long)countAll];
        }
    }
    else {
        return @"";
    }
}
+ (NSString *)getStringFromFilterType:(RapidItemFilterType )filtertype {
    NSString * strTypeName = @"";
    switch (filtertype) {
        case RapidItemFilterTypeDepartment: {
            strTypeName = @"DEPARTMENT";
            break;
        }
        case RapidItemFilterTypeSubDepartment: {
            strTypeName = @"SUB-DEPARTMENT";
            break;
        }
        case RapidItemFilterTypeVendor: {
            strTypeName = @"VENDOR";
            break;
        }
        case RapidItemFilterTypeGroup: {
            strTypeName = @"GROUPS";
            break;
        }
        case RapidItemFilterTypeTag: {
            strTypeName = @"TAGS";
            break;
        }
        case RapidItemFilterTypeSearchedItem: {
            strTypeName = @"TOP SEARCHED ITEM";
            break;
        }
        case RapidItemFilterTypeCategories: {
            strTypeName = @"CATEGORIES";
            break;
        }
    }
    return  strTypeName;
}
-(BOOL)isRestaurentActive
{
    BOOL isRestaurentActive = FALSE;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSPredicate *restaurentActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ || ModuleCode == %@",@"RRRCR",@"RRCR"];
    NSArray *restaurentArray = [activeModulesArray filteredArrayUsingPredicate:restaurentActive];
    if (restaurentArray.count > 0)
    {
        isRestaurentActive = TRUE;
    }
    else
    {
        isRestaurentActive = FALSE;
    }
    return isRestaurentActive;
}

@end
