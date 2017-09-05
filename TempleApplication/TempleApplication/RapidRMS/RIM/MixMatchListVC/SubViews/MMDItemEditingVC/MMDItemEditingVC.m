//
//  MMDItemEditingVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDItemEditingVC.h"
#import "MMDItemSelectionCell.h"
#import "Item+Dictionary.h"
#import "MMDSelectedItemListVC.h"
#import "Discount_Secondary_MD.h"
#import "Discount_Primary_MD.h"

@interface MMDItemEditingVC ()<MMDItemSelectionCellDelegate> {
    NSArray * arrFilterList;
    NSMutableArray * arrSelectedList;
    
    NSMutableDictionary * dictItemList;
    NSArray * arrItemTypeList;
    
    UIColor * lightB;
    UIColor * orangeB;
}

@property (nonatomic, weak) IBOutlet UITableView * tblSelectedItemList;

@property (nonatomic, weak) IBOutlet UIView * viewHeaderBG;
@property (nonatomic, weak) IBOutlet UIView * viewSearchBG;
@property (nonatomic, weak) IBOutlet UIView * viewCellTitleBG;

@property (nonatomic, weak) IBOutlet UITextField * txtSearchText;
@property (nonatomic, weak) IBOutlet UIButton * btnSelAllItem;
@property (nonatomic, weak) IBOutlet UILabel * lblItemType;

@end

@implementation MMDItemEditingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    arrSelectedList = [[NSMutableArray alloc]init];
    lightB = [UIColor lightGrayColor];
    orangeB = [UIColor colorWithRed:0.957 green:0.553 blue:0.004 alpha:1.000];
    self.tblSelectedItemList.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!arrFilterList) {
        arrFilterList = [[NSArray alloc]initWithArray:self.arrItemList];
    }
    if (!self.isXitemList) {
        _lblItemType.text = @"Y SELECTION";
        _viewHeaderBG.backgroundColor = [UIColor colorWithWhite:0.827 alpha:1.000];
        _viewSearchBG.backgroundColor = [UIColor whiteColor];
        _viewCellTitleBG.backgroundColor = [UIColor colorWithRed:0.075 green:0.102 blue:0.149 alpha:1.000];
        self.tblSelectedItemList.backgroundColor = [UIColor colorWithWhite:0.929 alpha:1.000];
    }
    [self createTableViewSectionDictionary];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self searchTextInList];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{               
    arrFilterList = [[NSArray alloc] initWithArray:self.arrItemList];
    [self searchContainText:nil];
    arrFilterList = [[NSArray alloc]initWithArray:self.arrItemList];
    [self createTableViewSectionDictionary];
    [self.tblSelectedItemList reloadData];
    return YES;
}

#pragma mark - IBActions -

- (void)searchTextInList {
    if (_txtSearchText.text.length > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(self.itemDetail.item_Desc contains[cd] %@)", _txtSearchText.text];
        arrFilterList = [self.arrItemList filteredArrayUsingPredicate:filterPredicate];
    }
    else {
        arrFilterList = [[NSArray alloc] initWithArray:self.arrItemList];
    }
    [self createTableViewSectionDictionary];
    [arrSelectedList removeAllObjects];
    [self changeStatusOfSelectAllBTN];
    [self.tblSelectedItemList reloadData];
}

-(IBAction)searchContainText:(id)sender {
    if (_txtSearchText.text.length > 0) {
        [self searchTextInList];
    }
    else {
        [_txtSearchText becomeFirstResponder];
    }
}
-(IBAction)btnSelectDeselectAllItem:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
         arrSelectedList = [[NSMutableArray alloc] initWithArray:arrFilterList];
    }
    else {
        [arrSelectedList removeAllObjects];
    }
    [self changeStatusOfSelectAllBTN];
//    [self createTableViewSectionDictionary];
    [self.tblSelectedItemList reloadData];
}
-(IBAction)btnSelectedAllItemDelete:(UIButton *)sender {

    NSArray * arrSeldetedIndex = self.tblSelectedItemList.indexPathsForSelectedRows;
    [self deleteItemAtList:arrSeldetedIndex];

}
-(void)changeStatusOfSelectAllBTN{
    if (arrFilterList.count > 0) {
        if (arrFilterList.count == arrSelectedList.count) {
            _btnSelAllItem.selected = TRUE;
        }
        else {
            _btnSelAllItem.selected = FALSE;
        }
        _btnSelAllItem.enabled = TRUE;
    }
    else {
        _btnSelAllItem.enabled = FALSE;
    }
}
-(IBAction)deleteSelectedItem:(UIButton *)sender {
//    [self deleteItemAtList:@[@(sender.tag)]];
}
-(void)didDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteItemAtList:@[indexPath]];
}
- (void)deleteItemAtList:(NSArray *)arrDeleteIndexs {
    
    NSSortDescriptor * rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:NO];
    NSSortDescriptor * sectionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:NO];
    arrDeleteIndexs = [arrDeleteIndexs sortedArrayUsingDescriptors:@[rowDescriptor,sectionDescriptor]];
    
    [self.tblSelectedItemList beginUpdates];
    
    NSMutableArray * arrRemoveObject = [[NSMutableArray alloc]initWithArray:arrFilterList];
    NSMutableArray * arrAddedType = [[NSMutableArray alloc]initWithArray:arrItemTypeList];
    NSMutableArray * arrSectionList = [[NSMutableArray alloc]init];
    for (int i = 0; i < arrDeleteIndexs.count; i++) {
        NSIndexPath * indexPath = arrDeleteIndexs[i];
        NSString * strKey = arrItemTypeList[indexPath.section];
        NSMutableArray * arrSectionItems = [[NSMutableArray alloc]initWithArray:dictItemList[strKey]];
        id MMDitem = arrSectionItems[indexPath.row];
        [arrSectionItems removeObject:MMDitem];
        if (arrSectionItems.count > 0) {
            dictItemList[strKey] = arrSectionItems;
        }
        else {
            [dictItemList removeObjectForKey:strKey];
            [arrAddedType removeObject:strKey];
            [arrSectionList addObject:@(indexPath.section)];
        }
        
        [arrRemoveObject removeObject:MMDitem];
        [self.arrItemList removeObject:MMDitem];
        if ([arrSelectedList containsObject:MMDitem]) {
            [arrSelectedList removeObject:MMDitem];
        }
    }
    arrItemTypeList = [[NSArray alloc]initWithArray:arrAddedType];
    arrFilterList = [[NSArray alloc]initWithArray:arrRemoveObject];
    
    if (arrDeleteIndexs.count > 0) {
        [self.tblSelectedItemList deleteRowsAtIndexPaths:arrDeleteIndexs withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    for (NSNumber * num in arrSectionList) {
        [self.tblSelectedItemList deleteSections:[NSIndexSet indexSetWithIndex:num.integerValue] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tblSelectedItemList endUpdates];
    [self changeStatusOfSelectAllBTN];
}
#pragma mark - Table view data source
-(void)createTableViewSectionDictionary {
    if (dictItemList) {
        [dictItemList removeAllObjects];
    }
    else {
        dictItemList = [[NSMutableDictionary alloc]init];
    }
    NSMutableArray * arrAddedType = [[NSMutableArray alloc]init];
    NSArray * arrFilterType = @[@(MMDItemSelectTypeItem),@(MMDItemSelectTypeGroup),@(MMDItemSelectTypeTag),@(MMDItemSelectTypeDepartment)];
//    NSArray * arrFilterType = [[NSArray alloc]initWithObjects:@(1),@(2),@(3), nil];

    for (NSNumber * itemType in arrFilterType) {
        NSPredicate * filterItem = [NSPredicate predicateWithFormat:@"itemType == %@",itemType];
        NSMutableArray * arrFilteredList = [[NSMutableArray alloc] initWithArray:[arrFilterList filteredArrayUsingPredicate:filterItem]];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self.itemDetail.item_Desc" ascending:YES];;
        NSArray *sortDescriptors = @[sortDescriptor];
        
        if (arrFilteredList.count > 0) {
            [arrFilteredList sortUsingDescriptors:sortDescriptors];
            dictItemList[itemType.stringValue] = arrFilteredList;
            [arrAddedType addObject:itemType.stringValue];
        }
    }
    
    arrItemTypeList = [[NSArray alloc]initWithArray:arrAddedType];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return arrItemTypeList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 23)];
    
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, view.frame.size.width-20, view.frame.size.height)];
    [label setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0]];
    label.backgroundColor = [UIColor clearColor];
    
    MMDItemSelectType itemType = (MMDItemSelectType)[arrItemTypeList[section] intValue];
    NSString *sectionTitle = [self getItemTypeStringFromType:itemType];
    [label setText:sectionTitle];
    [view addSubview:label];
    if (self.isXitemList) {
        [view setBackgroundColor:[UIColor colorWithWhite:0.933 alpha:1.000]];
    }
    else {
        [view setBackgroundColor:[UIColor whiteColor]];
    }
    return view;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString * strKey = arrItemTypeList[section];
    NSArray * arrItemList = dictItemList[strKey];
    return arrItemList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMDItemSelectionCell *cell = (MMDItemSelectionCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString * strKey = arrItemTypeList[indexPath.section];
    NSArray * arrItemList = dictItemList[strKey];
    id objDiscount;
    if (self.isXitemList) {
        Discount_Secondary_MD * MMDItem = arrItemList[indexPath.row];
        objDiscount = MMDItem;
        cell.lblName.text = MMDItem.itemDetail.item_Desc;
        cell.lblUPC.text = MMDItem.itemDetail.barcode;
        cell.lblPrice.text = [NSString stringWithFormat:@"$ %.2f",MMDItem.itemDetail.salesPrice.floatValue];
    }
    else {
        Discount_Primary_MD * MMDItem = arrItemList[indexPath.row];
        objDiscount = MMDItem;
        cell.lblName.text = MMDItem.itemDetail.item_Desc;
        cell.lblUPC.text = MMDItem.itemDetail.barcode;
        cell.lblPrice.text = [NSString stringWithFormat:@"$ %.2f",MMDItem.itemDetail.salesPrice.floatValue];
    }
    cell.tableView = tableView;
    cell.Delegate = self;
    UIView * selBG = [[UIView alloc]init];
    selBG.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = selBG;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([arrSelectedList containsObject:objDiscount]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            if (self.isXitemList) {
                cell.backgroundColor = lightB;
                cell.contentView.backgroundColor = lightB;
            }
            else {
                cell.backgroundColor = orangeB;
                cell.contentView.backgroundColor = orangeB;
            }
        }
        else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
    });
    return cell;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * strKey = arrItemTypeList[indexPath.section];
    NSMutableArray * arrSectionItems = [[NSMutableArray alloc]initWithArray:dictItemList[strKey]];
    id MMDitem = arrSectionItems[indexPath.row];
    
    [arrSelectedList addObject:MMDitem];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self changeStatusOfSelectAllBTN];

}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * strKey = arrItemTypeList[indexPath.section];
    NSMutableArray * arrSectionItems = [[NSMutableArray alloc]initWithArray:dictItemList[strKey]];
    id MMDitem = arrSectionItems[indexPath.row];
    
    [arrSelectedList removeObject:MMDitem];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self changeStatusOfSelectAllBTN];
}
-(NSString *)getItemTypeStringFromType:(MMDItemSelectType) itemType{
    NSString * strType = @"";
    switch (itemType) {
        case MMDItemSelectTypeItem: {
            strType = @"ITEM";
            break;
        }
        case MMDItemSelectTypeGroup: {
            strType = @"GROUP";
            break;
        }
        case MMDItemSelectTypeTag: {
            strType = @"TAG";
            break;
        }
        case MMDItemSelectTypeDepartment:
            strType = @"DEPARTMENT";
            break;
            
}
    return strType;
}
@end
