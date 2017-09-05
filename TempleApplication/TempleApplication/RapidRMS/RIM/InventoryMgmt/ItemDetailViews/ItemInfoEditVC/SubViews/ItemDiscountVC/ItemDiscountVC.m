//
//  ItemDiscountVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 16/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemDiscountVC.h"
#import "MMDDiscountInfoPopupVC.h"
#import "RimPopOverVC.h"
#import "RmsDbController.h"
#import "UITableView+AddBorder.h"


// Core Data
#import "UpdateManager.h"
#import "ItemTax+Dictionary.h"
#import "Item+Discount.h"
#import "TaxMaster+Dictionary.h"
#import "DepartmentTax+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"

//Cell

#import "ButtonAndSwitchCell.h"
#import "DiscountDetailCell.h"
#import "ItemDiscountMMDListCell.h"
#import "RIMNumberPadPopupVC.h"
#import "DatewiseDisplayCell.h"
#import "DaywiseDisplayCell.h"

@interface ItemDiscountVC ()<ItemDiscountPriceDetailDelegate>{
    NSArray * discountSelection;
    NSArray * discountSection;
    NSArray * arrMMDiscountItems;
}
@property (nonatomic ,strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) NSString * quantityDiscount;

@property (nonatomic, strong) RapidWebServiceConnection * removeItemFromMMDWSC;
@end

@implementation ItemDiscountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    discountSelection = @[@"There is no discount scheme for this Item.",
                          @"Use a quantity discount pricing table."];
    [self getDiscountDataFromTable];
    if (self.itemInfoDataObject.discountDetailsArray==nil) {
        self.itemInfoDataObject.discountDetailsArray = [[NSMutableArray alloc]init];
        [self AddBlankInfoInToDiscountDetail];
    }
    else if(self.itemInfoDataObject.discountDetailsArray.count>0){
        self.quantityDiscount=@"1";
    }
    [self getMMDiscountDetail];
    [self resetDiscountSection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    [self.view endEditing:YES];
    return discountSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && IsPhone()) {
        return 0.01f;
    }
    return RIMHeaderHeight();
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float fltRowHeight = 55;
    
    DiscountSection rcrEditItem = [discountSection[indexPath.section] integerValue];
    switch (rcrEditItem) {
        case DiscountSectionNoPOS:
        case DiscountSectionDescountscheme:
        case DiscountSectionQTYDescount:
            fltRowHeight = 55;
            break;
        case DiscountSectionMMDescount:{
            if (indexPath.row == 0) {
                if (IsPhone()) {
                    fltRowHeight = 25;
                }
                else {
                    fltRowHeight = 34;
                }
            }
            else {
                if (IsPhone()) {
                    fltRowHeight = 80;
                }
                else {
                    fltRowHeight = 70;
                }
            }
        }
        break;
    }
    return fltRowHeight;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        if ([discountSection[indexPath.section] integerValue] == DiscountSectionMMDescount && indexPath.row == 0) {
            [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1 bottomBorderSpace:0];
        }
        else{
            [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath];
        }
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString * headerTitle = @"";
    DiscountSection rcrEditItem = [discountSection[section] integerValue];
    switch (rcrEditItem) {
        case DiscountSectionNoPOS:
//`            return nil;
            break;
        case DiscountSectionDescountscheme:
            headerTitle = @"Discount Scheme";
            break;
        case DiscountSectionQTYDescount:
            headerTitle = @"Discount Details";
            break;
        case DiscountSectionMMDescount:
            headerTitle = @"Buy X Get Y Descount";
            break;
    }
    return [tableView defaultTableHeaderView:headerTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int rowCount;
    DiscountSection rcrEditItem = [discountSection[section] integerValue];
    switch (rcrEditItem) {
        case DiscountSectionNoPOS:
            rowCount = 1;
            break;
        case DiscountSectionDescountscheme:
            rowCount = 2;
            break;
        case DiscountSectionQTYDescount:
            rowCount = (int)self.itemInfoDataObject.discountDetailsArray.count+1;
            break;
        case DiscountSectionMMDescount:
            rowCount = (int)arrMMDiscountItems.count+1;
            break;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    
    DiscountSection rcrEditItem = [discountSection[indexPath.section] integerValue];
    switch (rcrEditItem) {
        case DiscountSectionNoPOS:
            cell = [self noPOSdiscountTableView:tableView cellForRowAtIndexPath:indexPath];
            break;
        case DiscountSectionDescountscheme:
            cell = [self discountingTableView:tableView cellForRowAtIndexPath:indexPath];
            break;
        case DiscountSectionQTYDescount:
            cell = [self discountDetailTableView:tableView cellForRowAtIndexPath:indexPath];
            break;
        case DiscountSectionMMDescount:
            cell = [self mmdiscountDetailTableView:tableView cellForRowAtIndexPath:indexPath];
            break;
    }
    if (!self.itemInfoDataObject.oldActive) {
        cell.contentView.userInteractionEnabled = FALSE;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1 && self.itemInfoDataObject.oldActive) {
        [self quantityDiscount:(int)indexPath.row];
    }
    [tableView reloadData];
}
#pragma mark - Tableview Cell -
- (UITableViewCell *)noPOSdiscountTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *ident=@"NoPOSDiscount";
    ButtonAndSwitchCell *cell=(ButtonAndSwitchCell *)[tableView dequeueReusableCellWithIdentifier:ident];
    if (cell==nil) {
        cell=[[ButtonAndSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    cell.cellTitle.text=@"NO POS DISCOUNT";
    if (self.itemInfoDataObject.POSDISCOUNT) {
        [cell.selectedswitch setOn:YES];
    }
    else{
        [cell.selectedswitch setOn:NO];
    }
    [cell.selectedswitch addTarget:self action:@selector(changePOSDiscount:) forControlEvents:UIControlEventValueChanged];
    return cell;
}
- (UITableViewCell *)discountingTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *ident=@"DiscountingCell";
    ButtonAndSwitchCell *cell=(ButtonAndSwitchCell *)[tableView dequeueReusableCellWithIdentifier:ident];
    if (cell==nil) {
        cell=[[ButtonAndSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    cell.cellTitle.text=discountSelection[indexPath.row];
    if (indexPath.row ==self.quantityDiscount.integerValue) {
        [cell.selectedButton setImage:[UIImage imageNamed:@"radioselected.png"] forState:UIControlStateNormal];
    }
    else{
        [cell.selectedButton setImage:[UIImage imageNamed:@"radiobtn.png"] forState:UIControlStateNormal];
    }
    return cell;
}
- (UITableViewCell *)discountDetailTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ident=@"DiscountDetailCell";
    if (self.itemInfoDataObject.discountDetailsArray.count-1 < indexPath.row || self.itemInfoDataObject.discountDetailsArray.count == 0) {
        ButtonAndSwitchCell *cell=(ButtonAndSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"AddNewDiscountCell"];
        return cell;
    }
    DiscountDetailCell *cell=(DiscountDetailCell *)[tableView dequeueReusableCellWithIdentifier:ident];
    if (cell==nil) {
        cell=[[DiscountDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    cell.indexPath=indexPath;
    cell.ItemDiscountPriceDetailDelegate=self;
    if (self.itemInfoDataObject.discountDetailsArray.count>indexPath.row) {
        NSMutableDictionary *dictDiscountData=self.itemInfoDataObject.discountDetailsArray [indexPath.row];
        //        NSDictionary *dictDiscountData = discountDetail[0];
        [self settaxDetailIntoDictionry:dictDiscountData atIndexPath:indexPath];
        cell.currencyFormatter=self.rmsDbController.currencyFormatter;
        [cell configureItemDetailWithDictionary:dictDiscountData];
    }
    return cell;
}

- (UITableViewCell *)mmdiscountDetailTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell=(ButtonAndSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"mmDiscountTitleCell"];
    }
    else {
        ItemDiscountMMDListCell * mmdcell = [tableView dequeueReusableCellWithIdentifier:@"mmDiscountListCell" forIndexPath:indexPath];
        int index = (int)indexPath.row - 1;
        NSDictionary * dictMMDInfo = [arrMMDiscountItems objectAtIndex:index];
        mmdcell.lblDiscountName.text = dictMMDInfo[@"name"];
        NSDate * endDate = dictMMDInfo[@"endDate"];
        NSString * strDate;
        if (endDate) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd/yyyy";
            strDate = [formatter stringFromDate:endDate];
        }
        else{
            strDate = @"Never Expires";
        }
        mmdcell.lblDiscountEndDate.text = strDate;
        mmdcell.btnDiscountRemove.tag = index;
        mmdcell.btnDiscountInfo.tag = index;
        cell = mmdcell;
    }
    return cell;
}
-(IBAction)btnRemoveItemFromDiscount:(UIButton *)sender {
    [self confirmremoveItemFromDiscountAtIndex:sender.tag];
}
-(IBAction)btnInfoMMDDiscount:(UIButton *)sender {
    MMDDiscountInfoPopupVC * objMMDDiscountInfoPopupVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDDiscountInfoPopupVC_sid"];
    objMMDDiscountInfoPopupVC.dictMMDInfo = arrMMDiscountItems[sender.tag];
    [objMMDDiscountInfoPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionDown];
    objMMDDiscountInfoPopupVC.index = sender.tag;
    objMMDDiscountInfoPopupVC.removeDiscountAt=^(NSInteger index){
        [self confirmremoveItemFromDiscountAtIndex:index];
    };
}
-(void)confirmremoveItemFromDiscountAtIndex:(NSInteger )index{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self removeItemFromDiscountAtIndex:index];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"Are you sure? You want to remove item from discount." buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}
-(void)removeItemFromDiscountAtIndex:(NSInteger )index {

    self.activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    NSDictionary * dictDiscount = arrMMDiscountItems[index];
    NSMutableDictionary * dictServer = [NSMutableDictionary dictionary];
    dictServer[@"DiscountId"] = dictDiscount[@"discountId"];
    dictServer[@"ItemCode"] = self.itemInfoDataObject.ItemId;
    
    dictServer[@"BranchId"] = self.rmsDbController.globalDict[@"BranchID"];
    NSString *userID = self.rmsDbController.globalDict[@"UserInfo"][@"UserId"];
    dictServer[@"UserId"] = userID;

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeItemFromDiscountResponse:response error:error atIndex:index];
        });
    };
    self.removeItemFromMMDWSC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_ITEM_REMOVE_FROM_MMD params:dictServer completionHandler:completionHandler];

}
-(void)removeItemFromDiscountResponse:(id)response error:(NSError *)error atIndex:(NSInteger)index{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]){
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    NSMutableArray * arrDiscountList = [arrMMDiscountItems mutableCopy];
                    [arrDiscountList removeObjectAtIndex:index];
                    if (arrDiscountList.count == 0) {
                        [self resetDiscountSection];
                    }
                    else{
                        arrMMDiscountItems = [[NSArray alloc]initWithArray:arrDiscountList];
                    }
                    [self.tblDiscountDetails reloadData];
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else{
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    [self.activityIndicator hideActivityIndicator];
}
#pragma mark - Day Name , Data And Time  -
-(NSString *)ConvertDateAndGetTime:(NSString *)dateString
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    dateFormater.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *date = [dateFormater dateFromString:dateString];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    timeFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSString *convertedTime = [timeFormatter stringFromDate:date];
    
    if (convertedTime == nil) {
        convertedTime = dateString;
    }
    return convertedTime;
}
-(NSString *)ConvertDateAndGetOnlyDate:(NSString *)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    dateFormat.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *date = [dateFormat dateFromString:dateString];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"MM/dd/yyyy";
    timeFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSString *convertedDate = [timeFormatter stringFromDate:date];
    
    if (convertedDate == nil) {
        convertedDate = dateString;
    }
    return convertedDate;
}
- (NSString *)selectedDay:(NSInteger)dayId
{
    NSString *selectedDay = @"";
    switch (dayId) {
        case 1:
            selectedDay = @"Sunday";
            break;
        case 2:
            selectedDay = @"Monday";
            break;
        case 3:
            selectedDay = @"Tuesday";
            break;
        case 4:
            selectedDay = @"Wednesday";
            break;
        case 5:
            selectedDay = @"Thursday";
            break;
        case 6:
            selectedDay = @"Friday";
            break;
        case 7:
            selectedDay = @"Saturday";
            break;
        default:
            break;
    }
    return selectedDay;
}

#pragma mark - Discount IBAction -
-(void)AddBlankInfoInToDiscountDetail{
    [self.itemInfoDataObject.discountDetailsArray addObject:[@{
                                                                    @"DayId": @"-1",
                                                                    @"EndDate": @"",
                                                                    @"StartDate": @"",
                                                                    @"applyTax": @"0",
                                                                    @"UnitPriceWithTax": @""
                                                                    } mutableCopy]];
}
- (IBAction)addNewDiscountSection:(UIButton *)sender
{
    [self AddBlankInfoInToDiscountDetail];
    [self.tblDiscountDetails reloadData];
}
-(IBAction)changePOSDiscount:(UISwitch *)sender{
    [self.rmsDbController playButtonSound];
    
    NSDictionary *noPosDiscountDict = @{kRIMItemNoPosDiscountKey : @(sender.isOn)};
    [Appsee addEvent:kRIMItemNoPosDiscount withProperties:noPosDiscountDict];
    
    if(sender.isOn)
    {
        if([self.quantityDiscount isEqualToString:@"1"])
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [sender setOn:NO];
                [self resetDiscountSection];
                [self.tblDiscountDetails reloadData];
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [self.itemInfoDataObject.discountDetailsArray removeAllObjects];
                [sender setOn:YES];
                self.itemInfoDataObject.POSDISCOUNT = TRUE;
                self.quantityDiscount = @"0";
                [self resetDiscountSection];
                [self.tblDiscountDetails reloadData];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Unable to set No POS discount for the item though discount is already applied, Applying No POS discount will remove discount. Are you sure?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        }
        else
        {
            self.itemInfoDataObject.POSDISCOUNT = TRUE;
            self.quantityDiscount = @"0";
        }
    }
    else
    {
        self.itemInfoDataObject.POSDISCOUNT = FALSE;
    }
    
}

-(void)quantityDiscount:(int)sender
{
    [Appsee addEvent:kRIMItemQtyDiscount];
    [self.rmsDbController playButtonSound];
    if (sender==0) {
        self.quantityDiscount=@"0";
        [self.itemInfoDataObject.discountDetailsArray removeAllObjects];
    }
    else{
        if(self.itemInfoDataObject.POSDISCOUNT)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [self resetDiscountSection];
                [self.tblDiscountDetails reloadData];
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                // UNCHECKED NO POS DISCOUNT
                self.itemInfoDataObject.POSDISCOUNT = FALSE;
                
                self.quantityDiscount=@"1";
                if(self.itemInfoDataObject.discountDetailsArray.count == 0)
                {
                    [self AddBlankInfoInToDiscountDetail];
                }
                [self resetDiscountSection];
                [self.tblDiscountDetails reloadData];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Unable to set discount for the item thought no POS discount is already applied, Applying discount will no POS discount. Are you sure?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        }
        else
        {
            
            if(self.itemInfoDataObject.discountDetailsArray.count == 0)
            {
                [self AddBlankInfoInToDiscountDetail];
            }
            self.itemInfoDataObject.POSDISCOUNT = FALSE;
            self.quantityDiscount=@"1";
        }
    }
    
    [self resetDiscountSection];
    [self.tblDiscountDetails reloadData];
}
#pragma mark - Tax -

- (NSMutableArray *)getDepartmentTaxOfItemDepartment{
    NSMutableArray *taxDetail = [[NSMutableArray alloc] init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",self.itemInfoDataObject.DepartId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *departmentTaxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (int i=0; i<departmentTaxListArray.count; i++){
        DepartmentTax *departmentTax=departmentTaxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",departmentTax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemTaxName.count>0){
            TaxMaster *taxmaster=itemTaxName.firstObject;
            NSMutableDictionary *departmentTaxDictionary=[[NSMutableDictionary alloc]init];
            departmentTaxDictionary[@"ItemTaxAmount"] = @"0";
            departmentTaxDictionary[@"TaxPercentage"] = taxmaster.percentage;
            departmentTaxDictionary[@"TaxAmount"] = taxmaster.amount;
            departmentTaxDictionary[@"TaxId"] = taxmaster.taxId;
            [taxDetail addObject:departmentTaxDictionary];
        }
    }
    return taxDetail;
}
#pragma mark - ItemDiscountPriceDetailDelegate -
-(void)getDiscountDataFromTable
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d",self.itemInfoDataObject.ItemId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *itemList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    self.itemInfoDataObject.discountDetailsArray = [[NSMutableArray alloc] init];
    NSMutableArray *discountSubArray = [[NSMutableArray alloc] init];
    
    if(itemList.count > 0)
    {
        Item *anItem = itemList.firstObject;
        for (Item_Discount_MD *discountMD in anItem.itemToDisMd)
        {
            for (Item_Discount_MD2 *discountMD2 in discountMD.mdTomd2)
            {
                NSDictionary *dictionary = discountMD2.itemDiscount_MD2DictionaryRim;
                [dictionary setValue:@"0" forKey:@"applyTax"];
                [dictionary setValue:@"" forKey:@"UnitPriceWithTax"];
                [discountSubArray addObject:dictionary ];
            }
        }
        
        for (int i = 0; ; i++) {
            NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"RowId == %@",@(i).stringValue];
            NSArray *isRecordFound = [discountSubArray filteredArrayUsingPredicate:searchPredicate];
            if(isRecordFound.count == 0)
            {
                break;
            }
            else
            {
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"DayId" ascending:YES];
                
                isRecordFound = [isRecordFound sortedArrayUsingDescriptors:@[sortDescriptor]];
//                self.itemInfoDataObject.discountDetailsArray = [[NSMutableArray alloc]initWithArray:isRecordFound];
                [self.itemInfoDataObject.discountDetailsArray addObject:isRecordFound.firstObject];
            }
        }
        [self.itemInfoDataObject createDuplicateItemDiscountDetailsArray];
    }
}
-(void)didChangeItemQty:(NSIndexPath *)indexpath fromSender:(UIView *)sender {
    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesQTY NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
        if(numInput.floatValue > 0)
        {
            if (self.itemInfoDataObject.discountDetailsArray != nil && self.itemInfoDataObject.discountDetailsArray.count > 0) {
                NSMutableDictionary *discountDictionary =self.itemInfoDataObject.discountDetailsArray[indexpath.row];
                discountDictionary[@"DIS_Qty"] = numInput;
            }
        }
        [self.tblDiscountDetails reloadData];
        
    } NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.inputView = sender;
    [objRIMNumberPadPopupVC presentVCForRightSide:self WithInputView:sender];
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionLeft];
}
-(void)didChangeItemQtyNewQTY:(NSString *)qty atIndex:(int)Index{
    
    NSMutableDictionary *discountDictionary=self.itemInfoDataObject.discountDetailsArray[Index];
//    NSMutableDictionary *discountDictionary = discountInfo[0];
    
    discountDictionary[@"DIS_Qty"] = qty;
}
-(void)didChangeItemPriceNewPrice:(NSString *)price atIndex:(int)Index{

    NSMutableDictionary *discountDictionary=self.itemInfoDataObject.discountDetailsArray[Index];
//    NSMutableDictionary *discountDictionary = discountInfo[0];
    discountDictionary[@"DIS_UnitPrice"] = @(price.floatValue);
}

-(void)didChangeItemPrice:(NSIndexPath *)indexpath  fromSender:(UIView *)sender {

    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesPrice NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
        if(numInput.floatValue > 0)
        {
            NSMutableDictionary *discountDictionary=self.itemInfoDataObject.discountDetailsArray[indexpath.row];

            discountDictionary[@"DIS_UnitPrice"] = numInput;
        }
        [self.tblDiscountDetails reloadData];
        
    } NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.inputView = sender;
    [objRIMNumberPadPopupVC presentVCForRightSide:self WithInputView:sender];
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionLeft];
}
-(void)didItemChangeApplyTax:(UISwitch *)sender forIndexPath:(NSIndexPath *)indexpath
{
    [self.rmsDbController playButtonSound];
    NSDictionary *applyTaxToDiscountDict = @{@"IsApplyTaxToDiscount" : @(sender.isOn),
                                             @"IndexOfDiscountRow" : @(indexpath.row)
                                             };
    [Appsee addEvent:kRIMItemApplyTaxToDiscount withProperties:applyTaxToDiscountDict];
    NSMutableDictionary *discountDict = (self.itemInfoDataObject.discountDetailsArray)[indexpath.row];
//    NSMutableDictionary *discountDict = discountInfo[0];
    
    if(sender.on)
    {
        if([discountDict valueForKey:@"DIS_UnitPrice"] == nil)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please enter Discount Price" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            if (self.itemInfoDataObject.DepartId.integerValue>0) {
                [discountDict setValue:@"1" forKey:@"applyTax"];
                [self settaxDetailIntoDictionry:discountDict atIndexPath:indexpath];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please select Department." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    else
    {
        [discountDict setValue:@"" forKey:@"UnitPriceWithTax"];
        [discountDict setValue:@"0" forKey:@"applyTax"];
    }
    [self.tblDiscountDetails reloadData];
}

-(void)settaxDetailIntoDictionry:(NSMutableDictionary *) discountDict atIndexPath:(NSIndexPath *)indexpath {
    if ([discountDict[@"applyTax"] integerValue] == 1) {
        float disUnitPrice = [[discountDict valueForKey:@"DIS_UnitPrice"] floatValue];
        if(self.itemInfoDataObject.itemtaxarray.count > 0)
        {
            float totPer = [[self.itemInfoDataObject.itemtaxarray valueForKeyPath:@"@sum.PERCENTAGE"] floatValue ];
            float UnitPriceWithTax = disUnitPrice * (100 + totPer) / 100;
            UnitPriceWithTax = [self.rmsDbController roundTo2Decimals:UnitPriceWithTax];
            [discountDict setValue:@(UnitPriceWithTax) forKey:@"UnitPriceWithTax"];
            [discountDict setValue:@"1" forKey:@"applyTax"];
        }
        else
        {
            [discountDict setValue:@([self.rmsDbController roundTo2Decimals:disUnitPrice]) forKey:@"UnitPriceWithTax"];
            NSMutableArray *taxDetail = [self getDepartmentTaxOfItemDepartment];
            if(taxDetail.count > 0)
            {
                float totPer = [[taxDetail valueForKeyPath:@"@sum.TaxPercentage"] floatValue ];
                float UnitPriceWithTax = disUnitPrice * (100 + totPer) / 100.0;
                UnitPriceWithTax = [self.rmsDbController roundTo2Decimals:UnitPriceWithTax];
                [discountDict setValue:@(UnitPriceWithTax) forKey:@"UnitPriceWithTax"];
            }
            else {
                [discountDict setValue:@([self.rmsDbController roundTo2Decimals:disUnitPrice]) forKey:@"UnitPriceWithTax"];
            }
        }
    }
}
-(void)didItemDelete:(NSIndexPath *)indexpath{
    [self.itemInfoDataObject.discountDetailsArray removeObjectAtIndex:indexpath.row];
    [self.tblDiscountDetails reloadData];
}

#pragma mark - MMD Discount -

-(void)getMMDiscountDetail{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Discount_M" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isDelete == %@ AND ANY primaryItems.itemId == %@ AND discountType != %@",@(0),self.itemInfoDataObject.ItemId,@(4)];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.resultType = NSDictionaryResultType;
    NSDictionary *entityProperties = [entity propertiesByName];
    
    [fetchRequest setPropertiesToFetch:@[[entityProperties objectForKey:@"discountId"],[entityProperties objectForKey:@"name"],[entityProperties objectForKey:@"descriptionText"],[entityProperties objectForKey:@"discountType"],[entityProperties objectForKey:@"validDays"],[entityProperties objectForKey:@"startTime"],[entityProperties objectForKey:@"endTime"],[entityProperties objectForKey:@"startDate"],[entityProperties objectForKey:@"endDate"]]];
    
    
    arrMMDiscountItems = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
}
-(void)resetDiscountSection{
    NSMutableArray * arrSection = [NSMutableArray array];
    [arrSection addObject:@(DiscountSectionNoPOS)];
    [arrSection addObject:@(DiscountSectionDescountscheme)];
    
    if (self.quantityDiscount.intValue == 1) {
        [arrSection addObject:@(DiscountSectionQTYDescount)];
    }
    
    if (arrMMDiscountItems && arrMMDiscountItems.count > 0) {
        [arrSection addObject:@(DiscountSectionMMDescount)];
    }
    discountSection = [[NSArray alloc]initWithArray:arrSection];
}
@end
