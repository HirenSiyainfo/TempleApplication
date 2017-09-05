//
//  ItemInfoVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AsyncImageView.h"
#import "DepartmentPopover.h"
#import "GroupMasterPopover.h"
#import "ItemInfoVC.h"
#import "ItemVariationRIM.h"
#import "MPTagList.h"
#import "MultipleBarcodePopUpVC.h"
#import "MultipleSubDepartment.h"
#import "RimSupplierPage.h"
#import "RimTaxAddRemovePage.h"
#import "RmsDbController.h"
#import "SelectUserOptionVC.h"
#import "TagSuggestionVC.h"
#import "TaxTypePopover.h"
#import "UITableView+AddBorder.h"
#import "Configuration.h"


// Cell
#import "AddProductCell.h"
#import "SupplierListCell.h"
#import "TaxListCell.h"

#import "ItemInfoDisplayCell.h"
#import "ItemInfoPricingCell.h"
#import "ItemInfoDescriptionCell.h"
#import "ItemInfoDepartmentTaxCell.h"
#import "ItemInfoTagCell.h"
#import "ItemInfoImageCell.h"

// Core Data
#import "ItemTax+Dictionary.h"
#import "TaxMaster+Dictionary.h"
#import "DepartmentTax+Dictionary.h"
#import "Item+Dictionary.h"
#import "ItemVariation_M+Dictionary.h"
#import "Variation_Master+Dictionary.h"
#import "ItemTag+Dictionary.h"
#import "SizeMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "ItemSupplier+Dictionary.h"
#import "SupplierRepresentative+Dictionary.h"
#import "ItemVariation_Md+Dictionary.h"
#import "Department+Dictionary.h"

@interface ItemInfoVC ()<MPTagListDelegate,ItemInfoTagDetailDelegate,DepartmentPopoverDelegate,MultipleSubDepartmentDelegate,ItemVariationChangedDelegate,TaxTypePopoverDelegate,RimTaxAddRemovePageDelegate,RimSupplierChangeDelegate,GroupMasterChangeDelegate,UIPopoverControllerDelegate,MultipleBarcodePopUpVCDelegate,PriceChangeDelegate,TagSuggestionDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    MPTagList *tagList;
    NSMutableArray *arrayTagListToDisplay;
    NSString * selectedTag;
    
    UIView *supplierview;
    UITableView *tblsupplierlist;
    
    UIView *taxview;
    UITableView *tbltaxlist;
    
    TaxTypePopover *objTaxPop;
    NSMutableArray *taxarraypicker;
    
    TagSuggestionVC *taglistPopupvc;
    Configuration *configuration;

    NSArray * itemPriceLocalArray;
    UITextField * currentEditing;
    UIColor * colorSingle,* colorCase,* colorPack,* colorChanged;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSString *ITM_Type;
@property (nonatomic, strong) NSString *strSearchTagText;

@property (nonatomic, strong) NSMutableArray *salesRepresentativesList;

@end

@implementation ItemInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.ITM_Type = self.itemInfoDataObject.ITM_Type.stringValue;
    if(IsPhone()){
        tagList = [[MPTagList alloc] initWithFrame:CGRectMake(0, 5, 310, 50)];
    }
    else{
        tagList = [[MPTagList alloc] initWithFrame:CGRectMake(60, 5, 660, 50)];
        tagList.horizontalPadding = 0;
    }
    if (self.itemInfoDataObject==nil) {
        self.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
    }

    if (self.itemInfoDataObject.isCopy) {//[16/11/16, 10:49:00 PM] Mitul Patel:
        arrayTagListToDisplay=[[NSMutableArray alloc]init];
        self.itemInfoDataObject.responseTagArray=[[NSMutableArray alloc]init];
        [self.itemInfoDataObject createDuplicateItemresponseTagArray];
    }
    else{
        [self getTagDataFromTable];
    }
    tagList.backgroundColor = [UIColor clearColor];
    [tagList setAutomaticResize:YES];
    [tagList setTags:arrayTagListToDisplay];
    tagList.tagDelegate = self;
    selectedTag=@"";
    [self supplierlistTableView];
    if (self.itemInfoDataObject.itemsupplierarray == nil) {
        [self getSupplierDataFromTable];
    }
    else {
        [self viewItemSupplierData:self.itemInfoDataObject.itemsupplierarray];
    }
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];

    
    taxarraypicker = [[NSMutableArray alloc] initWithObjects:@"Department wise",@"Tax wise" ,nil ];
    [self getTaxListFromTable];
    colorSingle = [UIColor colorWithRed:0.137 green:0.439 blue:0.973 alpha:1.000];
    colorCase = [UIColor colorWithRed:0.945 green:0.000 blue:0.094 alpha:1.000];
    colorPack = [UIColor colorWithRed:0.933 green:0.561 blue:0.176 alpha:1.000];
    colorChanged = [UIColor colorWithRed:0.588 green:0.341 blue:0.533 alpha:1.000];
}
-(void)supplierlistTableView {
    UIColor * bgColor = [UIColor colorWithRed:0.957 green:0.961 blue:0.965 alpha:1.000];
    supplierview = [[UIView alloc] init];
    supplierview.backgroundColor = bgColor;
    tblsupplierlist = [[UITableView alloc] init ];
    tblsupplierlist.backgroundColor = bgColor;
    taxview = [[UIView alloc] init];
    taxview.backgroundColor = bgColor;
    tbltaxlist = [[UITableView alloc] init ];
    tbltaxlist.backgroundColor = bgColor;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag==ItemtextFieldsTagItemTag) {
        NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (textField.text.length == 1 && [string isEqualToString:@""]) {
            self.strSearchTagText = @"";
        }
        else if(searchString.length > 0)
        {
            self.strSearchTagText = searchString;
        }
        if ([[self presentedViewController] isEqual:taglistPopupvc])
        {
            if([self getTagCounts]>0)
            {
                taglistPopupvc.strSearchTagText=searchString;
                [taglistPopupvc reloadTableWithSearchItem];
            }
            else{
                if ([self presentedViewController]) {
                    [taglistPopupvc dismissViewControllerAnimated:YES completion:NULL];
                }
            }
        }
        else{
            if(searchString.length>0){
                [self tagSelectView:textField withSearchString:searchString];
            }
        }
        return YES;
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{           // became first responder
    if(textField.tag==ItemtextFieldsTagItemTag && textField.text>0){
        [self tagSelectView:textField withSearchString:textField.text];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == ItemtextFieldsTagName) {
        self.itemInfoDataObject.ItemName = textField.text;
    }
    else if (textField.tag == ItemtextFieldsTagItemH) {
        self.itemInfoDataObject.ItemNo = textField.text;
    }
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{               // called when clear button pressed. return NO to ignore (no notifications)
    if (textField.tag == ItemtextFieldsTagName) {
        self.itemInfoDataObject.ItemName = @"";
    }
    else if (textField.tag == ItemtextFieldsTagItemH) {
        self.itemInfoDataObject.ItemNo = @"";
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.tag == ItemDescSectionTagRemark) {
        self.itemInfoDataObject.Remark = textView.text;
    }
    else if (textView.tag == ItemDescSectionTagCashierNote) {
        self.itemInfoDataObject.CashierNote = textView.text;
    }
}
#pragma mark - Table view data source -

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat heightForHeader = 44.0;
    if (tableView == tblsupplierlist || tableView == tbltaxlist) {
        heightForHeader=0;
    }
    else{
        InfoSection sectionNo = [self.itemInfoSectionArray[section] integerValue];
        switch (sectionNo) {
            case ItemImageSection: // DescriptionSection
                heightForHeader = 0.0;
                break;
            default:
                heightForHeader = RIMHeaderHeight();
                break;
        }
    }
    return heightForHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        if (tableView == self.tblItemInfo) {
            [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:0];
        }
//        else {
//            [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:40];
//        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = @"";
    InfoSection InfoSection = [self.itemInfoSectionArray[section] integerValue];
    switch (InfoSection) {
        case ItemImageSection:
            sectionTitle = @"";
            break;
            
        case ItemInfoSection:
            sectionTitle = @"ITEM INFORMATION";
            break;
            
        case ItemPricingSection:
            sectionTitle = @"PRICE INFORMATION";
            break;
            
        case ItemDepartmentTaxSection:
            sectionTitle = @"DEPARTMENT AND TAXES";
            break;
            
        case SupplierSection:
            sectionTitle = @"";
            break;
            
        case ProductInfoSection:
            sectionTitle = @"PRODUCT INFO";
            break;
            
        case DescriptionSection:
            sectionTitle = @"DESCRIPTION";
            break;
            
        default:
            break;
    }
    return [tableView defaultTableHeaderView:sectionTitle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==tblsupplierlist || tableView == tbltaxlist) {
        return 1;
    }
    return self.itemInfoSectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView==tblsupplierlist) {
        return self.salesRepresentativesList.count;
    }
    else if(tableView==tbltaxlist){ // SELECTED TAX TABLE
        if(self.itemInfoDataObject.itemtaxarray.count>0)
        {
            return self.itemInfoDataObject.itemtaxarray.count;
        }
        else{
            return 0;
        }
    }
    else{
        return [self configureItemInfoNoOfRows:section];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float headerHeight;
    if(tableView == tblsupplierlist || tableView == tbltaxlist){
        headerHeight = 30;
    }
    else{
        InfoSection InfoSection = [self.itemInfoSectionArray[indexPath.section] integerValue];
        switch (InfoSection) {
            case ItemImageSection:
                headerHeight = 80;
                break;
                
            case ItemInfoSection: // ItemInfo
                if (IsPhone())
                    headerHeight = 80;
                else
                    headerHeight = 55;
                break;
            case ItemPricingSection: // Pricing
                if (IsPhone()){
                    if (indexPath.row == 0) {
                        headerHeight = 25;
                    }
                    else{
                        headerHeight = 95;
                    }
                }
                else{
                    headerHeight = 55;
                }
                break;
                
            case ItemDepartmentTaxSection: // Department and Tax
                if (IsPhone()){
                    headerHeight = [self configureDepartmentSectionHeight:indexPath.row];
                }
                else{
                    headerHeight = [self configureDepartmentSectionHeight:indexPath.row];
                }
                break;
                
            case SupplierSection: // Supplier
                if(indexPath.row == 1){
                    
                    headerHeight = (self.salesRepresentativesList.count*30)+30;
                    headerHeight = (headerHeight>150)?150:headerHeight;
                }
                else{
                    if (IsPad()) {
                        headerHeight = 55;
                    }
                    else{
                        headerHeight = 80;
                    }
                }
                break;
                
            case ProductInfoSection: // Tag
                if(indexPath.row == 2){ // Add Tag
                    headerHeight = tagList.frame.size.height + 5;
                }
                else{
                    if (IsPad()) {
                        headerHeight = 55;
                    }
                    else{
                        headerHeight = 80;
                    }

                }
                break;
                
            case DescriptionSection: // Remark & Casier note
                if (IsPad()) {
                    headerHeight = 155;
                }
                else{
                    headerHeight = 125;
                }
                break;
                
            default:
                headerHeight = 55;
                break;
        }
    }
    return headerHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView ==tblsupplierlist){
        SupplierListCell  * cell = [[SupplierListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SupplierListCell"];

        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(self.itemInfoDataObject.itemsupplierarray.count > 0)
        {
            [self configureSupplierListInSupplierTable:indexPath cell:cell];
        }
        if (!self.itemInfoDataObject.oldActive) {
            cell.contentView.userInteractionEnabled = FALSE;
        }
        return cell;
    }
    else if(tableView == tbltaxlist)
    {
        UITableViewCell *cell = nil;
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        cell = [[TaxListCell alloc] initWithStyle:style reuseIdentifier:@"TaxListCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(self.itemInfoDataObject.itemtaxarray.count>0)
        {
            [self configureTaxListInTaxTable:indexPath cell:cell];
        }
        if (!self.itemInfoDataObject.oldActive) {
            cell.contentView.userInteractionEnabled = FALSE;
        }
        return cell;
    }
    else{
        UITableViewCell *cell;
        InfoSection InfoSection = [self.itemInfoSectionArray[indexPath.section] integerValue];
        switch (InfoSection) {
            case ItemImageSection: // ItemImage
                cell=[self configureItemImageCellTableView:tableView indexPath:indexPath];
                break;
                
            case ItemInfoSection: // ItemInfo
                cell=[self configureItemInfoTableView:tableView indexPath:indexPath];
                break;
                
            case ItemPricingSection: // Pricing
                cell=[self configurePricingTableView:tableView indexPath:indexPath];
                break;
                
            case ItemDepartmentTaxSection: // Department and Tax
                cell=[self configureDepartmentTableView:tableView indexPath:indexPath];
                break;
                
            case SupplierSection: // Supplier
                cell=[self configureSupplierTableView:tableView indexPath:indexPath];
                break;
                
            case ProductInfoSection: // Tag
                cell=[self configureTagAndCategoryTableView:tableView indexPath:indexPath];
                break;
                
            case DescriptionSection: // Remark & Casier note
                cell=[self configureDescriptionTableView:tableView indexPath:indexPath];
                break;
                
            default:
                break;
        }
        if (!self.itemInfoDataObject.oldActive) {
            cell.contentView.userInteractionEnabled = FALSE;
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
    }
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - Configure TableView Cell -
-(void)UpdatePriceInLocalArray{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"] isEqualToString:@"Yes"]){
        if(self.itemInfoDataObject.isPricingLevelSelected){ // for Appropreate price select
            itemPriceLocalArray=self.itemInfoDataObject.itemPricingArray;
        }
        else{ // for weight scale select
            itemPriceLocalArray=self.itemInfoDataObject.itemWeightScaleArray;
        }
    }
    else{
        itemPriceLocalArray=self.itemInfoDataObject.itemPricingArray;
    }
    
}
- (CGFloat)configureDepartmentSectionHeight:(NSInteger)row{
    CGFloat rowHeight = 0.0;
    DepartmentSectionItem seletedTab = [self.departmentSelection[row] integerValue];
    switch (seletedTab) {
        case DepartmentSection: // Department
        case SubDepartmentSection: // Sub Department
        case VariationSection: // Pricing Options
        case TaxSection: // Pricing Weightscale
            if (IsPad()) {
                rowHeight = 55.0;
            }
            else{
                rowHeight = 80;
            }
            break;
        case TaxListSection: // Pricing Appropreate
            rowHeight = (self.itemInfoDataObject.itemtaxarray.count*30)+30;
            rowHeight = (rowHeight>150)?150:rowHeight;
            break;
        default:
            break;
    }
    return rowHeight;
}

- (NSInteger)configureItemInfoNoOfRows:(NSInteger)section{
    NSInteger rows = 0;
    InfoSection InfoSection = [self.itemInfoDataObject.itemInfoSectionArray[section] integerValue];
    switch (InfoSection) {
        case ItemImageSection:
            return 1;
            break;
            
        case ItemInfoSection:
            return 3;
            break;
        case ItemPricingSection:
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"] isEqualToString:@"Yes"]){
                if(self.itemInfoDataObject.isPricingLevelSelected){ // for Appropreate price select
                    itemPriceLocalArray=self.itemInfoDataObject.itemPricingArray;
                    if(self.itemInfoDataObject.quantityManagementEnabled){
                        
                        self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
                    }
                    else{
                        self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
                    }
                }
                else{ // for weight scale select
                    itemPriceLocalArray=self.itemInfoDataObject.itemWeightScaleArray;
                    if(self.itemInfoDataObject.quantityManagementEnabled)
                    {
                        self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty),@(PricingSectionItemUnitQty_Unit), nil];
                    }
                    else{
                        self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty),@(PricingSectionItemUnitQty_Unit), nil];
                    }
                }
                return self.itemPricingSelection.count;
            }
            else{
                itemPriceLocalArray=self.itemInfoDataObject.itemPricingArray;
                if(self.itemInfoDataObject.quantityManagementEnabled){
                    
                    self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
                }
                else{
                    self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
                }
                return self.itemPricingSelection.count;
            }
            break;
        case ItemDepartmentTaxSection: // Department and Tax
            if(self.itemInfoDataObject.itemtaxarray.count > 0){
                if([self.moduleCode isEqualToString:@"RCRGAS"]){
                    self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(TaxSection),@(TaxListSection), nil];
                }
                else{
                    if([self isSubDepartmentActive]){
                        self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(SubDepartmentSection),@(VariationSection),@(TaxSection),@(TaxListSection), nil];
                    }
                    else{
                        self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(VariationSection),@(TaxSection),@(TaxListSection), nil];
                    }
                }
                return self.departmentSelection.count;
            }
            else{
                if([self.moduleCode isEqualToString:@"RCRGAS"]){
                    self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(TaxSection), nil];
                }
                else{
                    if([self isSubDepartmentActive]){
                        
                        self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(SubDepartmentSection),@(VariationSection),@(TaxSection), nil];
                        
                    }
                    else{
                        self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(VariationSection),@(TaxSection), nil];
                        
                    }
                }
                return self.departmentSelection.count;
            }
            break;
        case SupplierSection: // Supplier
            if(self.itemInfoDataObject.itemsupplierarray.count>0){
                return 2;
            }
            else{
                return 1;
            }
            break;
        case ProductInfoSection: // Tag
            if(self.itemInfoDataObject.responseTagArray.count>0){
                return 3;
            }
            else{
                return 2;
            }
            break;
        case DescriptionSection:
            return 2;
            break;
            
        default:
            break;
    }
    return rows;
}

- (UITableViewCell * )configureItemImageCellTableView:(UITableView *)tableview indexPath:(NSIndexPath *)indexPath{
    NSString * identifier=@"ItemInfoImageCell";
    ItemInfoImageCell * cell=(ItemInfoImageCell *)[self.tblItemInfo dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[ItemInfoImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.asyncImageVDetail.backgroundColor = [UIColor clearColor];
    if(indexPath.row == 0){ // item name text field
        if (self.itemInfoDataObject.selectedImage!=nil){
            cell.asyncImageVDetail.image = self.itemInfoDataObject.selectedImage;
        }
        else if ([[self.itemInfoDataObject.imageNameURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
            cell.asyncImageVDetail.image = [UIImage imageNamed:@"noimage.png"];
        }
        else if ([[self.itemInfoDataObject.imageNameURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"dontmakeblank"]){
            cell.asyncImageVDetail.image = self.itemInfoDataObject.selectedImage;
        }
        else{
            [cell.asyncImageVDetail loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.imageNameURL]]];
        }
        
        cell.asyncImageVDetail.layer.borderWidth = 3;
        cell.asyncImageVDetail.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.btnValue.backgroundColor = [UIColor clearColor];
        [cell.btnValue addTarget:self action:@selector(selectImageCapture:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (UITableViewCell *)configureItemInfoTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell = nil;
    
    if(indexPath.row == 0){ // item name text field
        NSString * identifier=@"ItemInfoDisplayCell";
        cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.txtInputValue.placeholder = @"Item Name";
        cell.lblCellName.text = @"Item Name".uppercaseString;
        cell.txtInputValue.text=[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemName];
        cell.txtInputValue.tag=ItemtextFieldsTagName;
        cell.txtInputValue.keyboardType = UIKeyboardTypeDefault;
        cell.btnValue.hidden=TRUE;
    }
    
    if(indexPath.row == 1) // item barcode text field
    {
        NSString * identifier=@"ItemInfoDisplaySwitchCell";
        cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.lblCellName.text = @"UPC / Barcode".uppercaseString;
        cell.txtInputValue.tag=ItemtextFieldsTagBarCode;
        cell.txtInputValue.clearButtonMode = UITextFieldViewModeNever;
        cell.swiIsDuplicate.on = self.itemInfoDataObject.IsduplicateUPC;
        [cell.swiIsDuplicate addTarget: self action: @selector(allowDuplicateBarcodeClicked:) forControlEvents:UIControlEventValueChanged];
        cell.txtInputValue.text=@"";
        cell.btnValue.hidden=FALSE;
        //[cell.btnValue removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [cell.btnValue addTarget:self action:@selector(moreBarcodeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnValue setTitle:self.itemInfoDataObject.Barcode forState:UIControlStateNormal];
    }
    if(indexPath.row == 2) // item number
    {
        NSString * identifier=@"ItemInfoDisplayCell";
        cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }

        cell.txtInputValue.placeholder = @"Item #";
        cell.lblCellName.text = @"Item #".uppercaseString;
        cell.btnValue.hidden=TRUE;
        cell.txtInputValue.tag=ItemtextFieldsTagItemH;
        cell.txtInputValue.keyboardType = UIKeyboardTypeNumberPad;
        if([self.itemInfoDataObject.ItemNo isKindOfClass:[NSString class]]){
            if([self.itemInfoDataObject.ItemNo isEqualToString:@""] || [self.itemInfoDataObject.ItemNo isEqualToString:@"<null>"]){
                cell.txtInputValue.text = @"";
            }
            else{
                cell.txtInputValue.text = [NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemNo];
            }
        }
        else{
            cell.txtInputValue.text = @"";
        }
    }
    return cell;
}

- (UITableViewCell *)configurePricingTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
//    ItemInfoPricingCell
    NSString * identifier=@"ItemInfoPricingCell";
    PricingSectionItem pricingSectionNo = [self.itemPricingSelection [indexPath.row] integerValue ];
    if (pricingSectionNo == PricingSectionItemTitle) {
        identifier=@"ItemInfoPricingTitleCell";
    }
    else if (pricingSectionNo == PricingSectionItemUnitQty_Unit) {
        identifier=@"ItemInfoPricingUnitQtyUnitCell";
    }
    ItemInfoPricingCell *cell=(ItemInfoPricingCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[ItemInfoPricingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.containerView = self.view.superview;
    cell.cellType=pricingSectionNo;
    cell.priceChangeDelegate=self;
    cell.txtInputSingle.userInteractionEnabled=YES;
//    cell.currencyFormatter=self.rmsDbController.currencyFormatter;
    cell.imageMarginMarkUp.image=nil;
    switch (pricingSectionNo) {
        case PricingSectionItemTitle: // Title
            [self configurePricingTitleCell:cell];
            break;
        case PricingSectionItemQty: // Quantity text field
            [self configurePricingQtyCell:cell];
            break;
        case PricingSectionItemCost: // cost text field
            [self configurePricingCostCell:cell];
            break;
        case PricingSectionItemProfit: // profit text field
            [self configurePricingProfitCell:cell];
            break;
        case PricingSectionItemSales: // sales price text field
            [self configurePricingSalesCell:cell];
            break;
        case PricingSectionItemNoOfQty: // Number of Items
            [self configurePricingNoOfItemCell:cell];
            break;
        case PricingSectionItemUnitQty_Unit: // Unit Qty
            [self configureItemUnitQty_Unit:cell];
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)configureDepartmentTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"ItemInfoDepartmentTaxCell";
    ItemInfoDepartmentTaxCell *cell = (ItemInfoDepartmentTaxCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    DepartmentSectionItem cellNo = [self.departmentSelection[indexPath.row] integerValue ];
    cell.btnValue.userInteractionEnabled = TRUE;
    switch (cellNo) {
        case DepartmentSection:{ // item department
            cell.lblCellName.text=@"Department".uppercaseString;
            NSString * strDeptName = self.itemInfoDataObject.DepartmentName;
            if (strDeptName.length>0) {
                [cell.btnValue setTitle:[NSString stringWithFormat:@"%@",strDeptName] forState:UIControlStateNormal];
            }
            else{
                self.itemInfoDataObject.DepartmentName = @"";
                [cell.btnValue setTitle:@"None" forState:UIControlStateNormal];
            }
            cell.btnValue.tag = 1;
            if([self.ITM_Type isEqualToString:@"0"] || (![self.itemInfoDataObject.oldSubDepartId isEqualToNumber:@0] && [self.ITM_Type isEqualToString:@"2"])){
                cell.btnValue.userInteractionEnabled = TRUE;
                [cell.btnValue setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            else{
                cell.btnValue.userInteractionEnabled = FALSE;
                [cell.btnValue setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
        }
            break;
            
        case SubDepartmentSection:{ // item sub department
            cell.lblCellName.text = @"Sub Department".uppercaseString;

            NSString * strDeptName = self.itemInfoDataObject.SubDepartmentName;
            if (strDeptName.length>0) {
                [cell.btnValue setTitle:[NSString stringWithFormat:@"%@",strDeptName] forState:UIControlStateNormal];
            }
            else{
                self.itemInfoDataObject.SubDepartmentName = @"";
                [cell.btnValue setTitle:@"None" forState:UIControlStateNormal];
            }
            cell.btnValue.tag = 2;
            if(![self.ITM_Type isEqualToString:@"2"]){
                cell.btnValue.userInteractionEnabled = TRUE;
                [cell.btnValue setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            else{
                cell.btnValue.userInteractionEnabled = FALSE;
                [cell.btnValue setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
        }
            break;
            
        case VariationSection:{ // item variation
            cell.lblCellName.text = @"Variations".uppercaseString;
            if(self.itemInfoDataObject.arrayVariation == nil) {
                self.itemInfoDataObject.arrayVariation = [[self getItemVariationArrayforDispay]mutableCopy];
            }
            NSString *strSelected = [self getSelectedVariationString:self.itemInfoDataObject.arrayVariation];
            if(!(strSelected.length>0) && self.itemInfoDataObject.arrayVariation.count>0){
                strSelected= [self getSelectedVariationStringFromItem];
            }
            cell.btnValue.tag = 3;
            [cell.btnValue setTitle:strSelected forState:UIControlStateNormal];
        }
            break;
        case TaxSection:{ // item tax
            cell.lblCellName.text = @"Tax Type".uppercaseString;
            if (self.itemInfoDataObject.TaxType ==nil || [self.itemInfoDataObject.TaxType isEqualToString:@""]) {
                self.itemInfoDataObject.TaxType = @"Department wise";
            }
            [cell.btnValue setTitle:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.TaxType] forState:UIControlStateNormal];

            cell.btnValue.tag = 4;
        }
            break;
        case TaxListSection:{ // item selected tax list
            UITableViewCell *celltax = nil;
            UITableViewCellStyle style =  UITableViewCellStyleDefault;
            celltax = [[TaxListCell alloc] initWithStyle:style reuseIdentifier:@"TaxListCell"];
            celltax.backgroundColor = [UIColor clearColor];
            celltax.selectionStyle = UITableViewCellSelectionStyleNone;
            [celltax addSubview:taxview];
            [celltax bringSubviewToFront:taxview];
            cell=(ItemInfoDepartmentTaxCell *)celltax;
        }
            break;
        default:
            break;
    }
    return cell;
}
-(IBAction)btnDepartmentSectionItemClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [self btnItemDeptClicked:sender];
            break;
        case 2:
            [self btnItemSubDeptClicked:sender];
            break;
        case 3:
            [self btnItemVariationClicked:sender];
            break;
        case 4:
            [self btnItemTaxClick:sender];
            break;
        case 5:
            [self btnItemGroupClicked:sender];
            break;
        default:
            break;
    }
}

- (void)configurePricingTitleCell:(ItemInfoPricingCell *)cell{
//    cell.backgroundColor=[UIColor clearColor];
//    cell.backgroundView.backgroundColor=[UIColor clearColor];
//    cell.contentView.backgroundColor=[UIColor clearColor];
    if (IsPad()){
        cell.imageBackGround.frame = CGRectMake(174, 0, 511, 44);
        cell.imageBackGround.image = [UIImage imageNamed:@"FormRowheaderBg.png"];
    }
//    cell.lblCellName.text = @"";
//    cell.txtInputSingle.text = @"Single";
//    cell.txtInputCase.text = @"Case";
//    cell.txtInputPack.text = @"Pack";
//    cell.txtInputSingle.userInteractionEnabled=cell.txtInputCase.userInteractionEnabled=cell.txtInputPack.userInteractionEnabled=FALSE;
//    cell.txtInputSingle.textAlignment=cell.txtInputCase.textAlignment=cell.txtInputPack.textAlignment=NSTextAlignmentCenter;
//    cell.txtInputSingle.clearButtonMode=cell.txtInputCase.clearButtonMode=cell.txtInputPack.clearButtonMode=UITextFieldViewModeNever;
    
}

- (void)configurePricingQtyCell:(ItemInfoPricingCell *)cell{
    
    cell.lblCellName.text = @"Qty OH".uppercaseString;
//    if ([self.itemInfoDataObject.dictGetItemData objectForKey:@"avaibleQty"]==nil) {
//        [self.itemInfoDataObject.dictGetItemData setObject:@"0" forKey:@"avaibleQty"];
//    }
    cell.txtInputSingle.text = [NSString stringWithFormat:@"%@",self.itemInfoDataObject.avaibleQty];
    
    if(!([[itemPriceLocalArray[1] valueForKey:@"Qty"] integerValue ] == 0)){
        NSInteger fltQty=[[itemPriceLocalArray[1] valueForKey:@"Qty"] integerValue];
        float result = cell.txtInputSingle.text.floatValue/fltQty;
        NSString *cq = [self getValueBeforeDecimal:result];
        NSInteger y = cell.txtInputSingle.text.integerValue % fltQty;
        y = labs(y);
        cell.txtInputCase.text = [NSString stringWithFormat:@"%@.%ld",cq,(long)y];
    }
    else{
        cell.txtInputCase.text = @"0.0";
    }
    
    if(!([[itemPriceLocalArray[2] valueForKey:@"Qty"] integerValue ] == 0)){
        NSInteger fltQty=[[itemPriceLocalArray[2] valueForKey:@"Qty"] integerValue];
        float result = cell.txtInputSingle.text.floatValue/fltQty;
        NSString *pq = [self getValueBeforeDecimal:result];
        NSInteger x = cell.txtInputSingle.text.integerValue % fltQty;
        x = labs(x);
        cell.txtInputPack.text = [NSString stringWithFormat:@"%@.%ld",pq ,(long)x];
    }
    else{
        cell.txtInputPack.text = @"0.0";
    }
    if (cell.txtInputSingle.text.floatValue !=self.itemInfoDataObject.oldavaibleQty.floatValue) {
        cell.txtInputSingle.textColor = colorChanged;
        cell.txtInputCase.textColor = colorChanged;
        cell.txtInputPack.textColor = colorChanged;
    }
    else{
        
        cell.txtInputSingle.textColor = colorSingle;
        cell.txtInputCase.textColor = colorCase;
        cell.txtInputPack.textColor = colorPack;
    }
    [self SetDesableTextFieldsOfCasePack:cell];
}
- (void)configurePricingCostCell:(ItemInfoPricingCell *)cell{
    cell.lblCellName.text = @"Cost".uppercaseString;
    [self SetValueItemInfoPricingCell:cell withCellKey:@"Cost"];
    [self SetDesableTextFieldsOfCasePack:cell];
}

- (void)configurePricingProfitCell:(ItemInfoPricingCell *)cell{
    
    cell.imageMarginMarkUp.hidden = NO;
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMarginMarkUp)];
    [cell addGestureRecognizer:gestureRight];
    if (self.itemInfoDataObject.rowSwitch) {
        cell.lblCellName.text=@"Margin".uppercaseString;
        self.itemInfoDataObject.ProfitType = @"Margin";
        
        
        cell.txtInputSingle.text=[self calculateMarginCost:[[itemPriceLocalArray[0] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[0] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputSingle.text.floatValue != [self.itemInfoDataObject.olditemPricingArray[0][@"Profit"] floatValue]) {
            cell.txtInputSingle.textColor = colorChanged;
        }
        else{
            cell.txtInputSingle.textColor = colorSingle;
        }
        
        cell.txtInputCase.text=[self calculateMarginCost:[[itemPriceLocalArray[1] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[1] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputCase.text.floatValue != [self.itemInfoDataObject.olditemPricingArray[1][@"Profit"] floatValue]) {
            cell.txtInputCase.textColor = colorChanged;
        }
        else{
            cell.txtInputCase.textColor = colorCase;
        }
        
        cell.txtInputPack.text=[self calculateMarginCost:[[itemPriceLocalArray[2] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[2] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputPack.text.floatValue != [self.itemInfoDataObject.olditemPricingArray[2][@"Profit"] floatValue]) {
            cell.txtInputPack.textColor = colorChanged;
        }
        else{
            cell.txtInputPack.textColor = colorPack;
        }
        
        gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        
        cell.imageMarginMarkUp.image = [UIImage imageNamed:@"markupMarginArrowRight.png"];
    } else {
        gestureRight.direction = UISwipeGestureRecognizerDirectionLeft;
        self.itemInfoDataObject.ProfitType = @"MarkUp";
        cell.lblCellName.text=@"MarkUp".uppercaseString;
        cell.imageMarginMarkUp.image = [UIImage imageNamed:@"markupMarginArrowLeft.png"];
        
        cell.txtInputSingle.text=[self calculateMarkUpCost:[[itemPriceLocalArray[0] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[0] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputSingle.text.floatValue != [self.itemInfoDataObject.olditemPricingArray[0][@"Profit"] floatValue]) {
            cell.txtInputSingle.textColor = colorChanged;
        }
        else{
            cell.txtInputSingle.textColor = colorSingle;
        }
        cell.txtInputCase.text=[self calculateMarkUpCost:[[itemPriceLocalArray[1] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[1] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputCase.text.floatValue != [self.itemInfoDataObject.olditemPricingArray[1][@"Profit"] floatValue]) {
            cell.txtInputCase.textColor = colorChanged;
        }
        else{
            cell.txtInputCase.textColor = colorCase;
        }
        
        cell.txtInputPack.text=[self calculateMarkUpCost:[[itemPriceLocalArray[2] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[2] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputPack.text.floatValue != [self.itemInfoDataObject.olditemPricingArray[2][@"Profit"] floatValue]) {
            cell.txtInputPack.textColor = colorChanged;
        }
        else{
            cell.txtInputPack.textColor = colorPack;
        }
    }
    [self SetDesableTextFieldsOfCasePack:cell];
}

- (void)configurePricingSalesCell:(ItemInfoPricingCell *)cell{

    cell.lblCellName.text=@"Price".uppercaseString;
    [self SetValueItemInfoPricingCell:cell withCellKey:@"UnitPrice"];
    [self SetDesableTextFieldsOfCasePack:cell];
}
- (void)configurePricingNoOfItemCell:(ItemInfoPricingCell *)cell{
    cell.lblCellName.text=@"# of Qty".uppercaseString;
    NSString * key = @"Qty";
    NSNumber *dCost = @([[itemPriceLocalArray[0] valueForKey:key] floatValue ]);
    cell.txtInputSingle.text = [NSString stringWithFormat:@"%@",dCost];
    cell.txtInputSingle.userInteractionEnabled=FALSE;
    
    dCost = @([[itemPriceLocalArray[1] valueForKey:key] floatValue ]);
    cell.txtInputCase.text = [NSString stringWithFormat:@"%@",dCost];
    
    dCost = @([[itemPriceLocalArray[2] valueForKey:key] floatValue ]);
    cell.txtInputPack.text = [NSString stringWithFormat:@"%@",dCost];
    [self SetDesableTextFieldsOfCasePack:cell];
}

- (void)configureItemUnitQty_Unit:(ItemInfoPricingCell *)cell{
    cell.lblCellName.text=@"Unit Qty & Unit";

    NSString * key = @"UnitQty";
    NSString * keyType = @"UnitType";
    cell.txtInputSingle.text = @"0";
    cell.txtInputCase.text = @"0";
    cell.txtInputPack.text = @"0";
    
    if ([[itemPriceLocalArray[0] valueForKey:key] intValue] > 0) {
        cell.txtInputSingle.text = [NSString stringWithFormat:@"%@/%@",[itemPriceLocalArray[0] valueForKey:key],[itemPriceLocalArray[0] valueForKey:keyType]];
    }
    if ([[itemPriceLocalArray[1] valueForKey:key] intValue] > 0) {
        cell.txtInputCase.text = [NSString stringWithFormat:@"%@/%@",[itemPriceLocalArray[1] valueForKey:key],[itemPriceLocalArray[1] valueForKey:keyType]];
    }
    if ([[itemPriceLocalArray[2] valueForKey:key] intValue] > 0) {
        cell.txtInputPack.text = [NSString stringWithFormat:@"%@/%@",[itemPriceLocalArray[2] valueForKey:key],[itemPriceLocalArray[2] valueForKey:keyType]];
    }
    [self SetDesableTextFieldsOfCasePack:cell];
}
- (UITableViewCell *)configureSupplierTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    UITableViewCell * returnCell;
    if(indexPath.row == 0){ // supplier button
        NSString * identifier=@"ItemInfoSupplierCell";
        ItemInfoTagCell *cell=(ItemInfoTagCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.lblCellName.text = @"Vendor".uppercaseString;
        //[cell.btnAddTag removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [cell.btnAddTag addTarget:self action:@selector(btnItemSuppClick:) forControlEvents:UIControlEventTouchUpInside];
        returnCell=cell;
    }
    if(self.itemInfoDataObject.itemsupplierarray.count > 0 && indexPath.row == 1){
        UITableViewCell *cell = nil;
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        cell = [[AddProductCell alloc] initWithStyle:style reuseIdentifier:@"AddProductCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:supplierview];
        [cell bringSubviewToFront:supplierview];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.957 green:0.961 blue:0.965 alpha:1.000];
        cell.backgroundColor = [UIColor colorWithRed:0.957 green:0.961 blue:0.965 alpha:1.000];
        returnCell=cell;
    }
    return returnCell;
}

- (UITableViewCell *)configureTagAndCategoryTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * returnCell;
    if(indexPath.row == 0){ // Category Drop down text field
        NSString * identifier=@"ItemInfoDepartmentTaxCell";
        ItemInfoDepartmentTaxCell *cell=(ItemInfoDepartmentTaxCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoDepartmentTaxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.lblCellName.text = @"Group".uppercaseString;
//        if ([self.itemInfoDataObject.dictGetItemData objectForKey:@"GroupName"]==nil) {
//            [self.itemInfoDataObject.dictGetItemData setObject:@"" forKey:@"GroupName"];
//        }
        cell.btnValue.userInteractionEnabled = TRUE;
        [cell.btnValue setTitle:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.GroupName] forState:UIControlStateNormal];
        //[cell.btnValue removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        cell.btnValue.tag = 5;
//        [cell.btnValue addTarget:self action:@selector(btnItemGroupClicked:) forControlEvents:UIControlEventTouchUpInside];
        returnCell=cell;
    }
    if(indexPath.row == 1){ // Add Tag
        NSString * identifier=@"ItemInfoTagCell";
        ItemInfoTagCell *cell=(ItemInfoTagCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.lblCellName.text = @"Tag".uppercaseString;
        cell.txtTagName.placeholder = @"Enter new Tag name";
        cell.txtTagName.text=selectedTag;
        cell.txtTagName.tag = ItemtextFieldsTagItemTag;
        cell.ItemInfoTagDetailDelegate=self;

        returnCell=cell;
    }
    if(self.itemInfoDataObject.responseTagArray.count > 0){
        if(indexPath.row == 2){ // Display Tag
            AddProductCell * cell = [[AddProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddProductCell"];
            cell.backgroundColor = [UIColor colorWithRed:0.957 green:0.961 blue:0.965 alpha:1.000];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell addSubview:tagList];
            [cell bringSubviewToFront:tagList];
            if (!self.itemInfoDataObject.oldActive) {
                tagList.userInteractionEnabled = FALSE;
            }
            returnCell=cell;
        }
    }
    return returnCell;
}

- (UITableViewCell *)configureDescriptionTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    NSString * identifier=@"ItemInfoDescriptionCell";
    ItemInfoDescriptionCell *cell=(ItemInfoDescriptionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[ItemInfoDescriptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if(indexPath.row == 0){
        cell.lblCellName.text=@"Remark".uppercaseString;
        cell.txtVInputValue.tag=ItemDescSectionTagRemark;
        cell.txtVInputValue.text = self.itemInfoDataObject.Remark;
    }
    else if(indexPath.row == 1){
        cell.lblCellName.text=@"Cashier Note".uppercaseString;
        cell.txtVInputValue.tag=ItemDescSectionTagCashierNote;
        cell.txtVInputValue.text = self.itemInfoDataObject.CashierNote;
    }
    return cell;
}

- (void)configureSupplierListInSupplierTable:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell{
    NSMutableArray *itemarray = [self.salesRepresentativesList mutableCopy];
    CGRect vendarNameFrame = CGRectMake(60, 0, 150, 30);
    CGRect suppNameFrame =  CGRectMake(262, 0, 300, 30);
    CGRect suppContFrame = CGRectMake(480, 0, 220, 30);
    CGRect viewBorderFrame = CGRectMake(60, 29, 660, 1);
    
    if (IsPhone()) {
        vendarNameFrame = CGRectMake(30,0, 150, 30);
        suppNameFrame = CGRectMake(0, 0, 0, 0);
        suppContFrame = CGRectMake(190, 0, 100, 30);
        viewBorderFrame = CGRectMake(30, 29, 290, 1);
    }
    
    UILabel *vendarName = [[UILabel alloc] initWithFrame:vendarNameFrame];
    vendarName.text = itemarray[indexPath.row][@"CompanyName"];
    [self setPropertyToSuppliersLabel:vendarName];
    [cell.contentView addSubview:vendarName];
    
    UILabel *suppname = [[UILabel alloc] initWithFrame:suppNameFrame];
    suppname.text = itemarray[indexPath.row][@"FirstName"];
    [self setPropertyToSuppliersLabel:suppname];
    [cell.contentView addSubview:suppname];
    
    UILabel *suppcontact = [[UILabel alloc] initWithFrame:suppContFrame];
    suppcontact.text = itemarray[indexPath.row][@"ContactNo"];
    [self setPropertyToSuppliersLabel:suppcontact];
    suppcontact.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:suppcontact];
    
    UIView *viewBorder = [[UIView alloc] initWithFrame:viewBorderFrame];
    viewBorder.backgroundColor = [UIColor colorWithWhite:0.667 alpha:1.000];
    [cell.contentView addSubview:viewBorder];
}
- (void)configureTaxListInTaxTable:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell{
    CGRect taxNameFrame;
    CGRect taxPercentageFrame;
    CGRect viewBorderFrame;
    if(IsPhone()){
        taxNameFrame = CGRectMake(30, 0, 100, 30);
        taxPercentageFrame = CGRectMake(190, 0, 100, 30);
        viewBorderFrame = CGRectMake(30, 29, 290, 1);
    }
    else{
        taxNameFrame = CGRectMake(60, 5, 250, 20);
        taxPercentageFrame = CGRectMake(262, 5, 250, 20);
        viewBorderFrame = CGRectMake(60, 29, 660, 1);
    }
    
    tbltaxlist.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    NSMutableArray *itemarray=[self.itemInfoDataObject.itemtaxarray mutableCopy];
    UILabel *taxname = [[UILabel alloc] initWithFrame:taxNameFrame];
    taxname.text = itemarray[indexPath.row][@"TAXNAME"];
    [self setPropertyToSuppliersLabel:taxname ];
    [cell.contentView addSubview:taxname];
    
    UILabel *tax = [[UILabel alloc] initWithFrame:taxPercentageFrame];
    tax.text = [NSString stringWithFormat:@"%.2f %%",[itemarray[indexPath.row][@"PERCENTAGE"] floatValue]];
    [self setPropertyToSuppliersLabel:tax];
    if (IsPhone()) {
        tax.textAlignment = CPTTextAlignmentRight;
    }
    [cell.contentView addSubview:tax];
    
    UIView *viewBorder = [[UIView alloc] initWithFrame:viewBorderFrame];
    viewBorder.backgroundColor = [UIColor colorWithWhite:0.667 alpha:1.000];
    [cell.contentView addSubview:viewBorder];
}

-(void)SetDesableTextFieldsOfCasePack:(ItemInfoPricingCell *)cell {
    if ([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) {
        cell.txtInputCase.text = @"";
        cell.txtInputPack.text = @"";
        cell.txtInputCase.userInteractionEnabled = FALSE;
        cell.txtInputPack.userInteractionEnabled = FALSE;
    }
    else {
        cell.txtInputCase.userInteractionEnabled = TRUE;
        cell.txtInputPack.userInteractionEnabled = TRUE;
    }
}
-(void)SetValueItemInfoPricingCell:(ItemInfoPricingCell *)cell withCellKey:(NSString *)key{

    cell.txtInputSingle.text = [self.rmsDbController getStringPriceFromFloat:[[itemPriceLocalArray[0] valueForKey:key] floatValue]];
    if ([[itemPriceLocalArray[0] valueForKey:key] floatValue ] != [[self.itemInfoDataObject.olditemPricingArray[0] valueForKey:key] floatValue ]) {
        cell.txtInputSingle.textColor = colorChanged;
    }
    else{
        cell.txtInputSingle.textColor = colorSingle;
    }
    
    cell.txtInputCase.text = [self.rmsDbController getStringPriceFromFloat:[[itemPriceLocalArray[1] valueForKey:key] floatValue]];
    if ([[itemPriceLocalArray[1] valueForKey:key] floatValue ] != [[self.itemInfoDataObject.olditemPricingArray[1] valueForKey:key] floatValue ]) {
        cell.txtInputCase.textColor = colorChanged;
    }
    else{
        cell.txtInputCase.textColor = colorCase;
    }
    
    cell.txtInputPack.text = [self.rmsDbController getStringPriceFromFloat:[[itemPriceLocalArray[2] valueForKey:key] floatValue]];
    if ([[itemPriceLocalArray[2] valueForKey:key] floatValue ] != [[self.itemInfoDataObject.olditemPricingArray[2] valueForKey:key] floatValue ]) {
        cell.txtInputPack.textColor = colorChanged;
    }
    else{
        cell.txtInputPack.textColor = colorPack;
    }
}
- (NSString *)getValueBeforeDecimal:(float)result{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}
- (void)calculateMarginCost:(UITextField *)costPrice profit:(UITextField *)profitAmount sales:(UITextField *)salesPrice{
    NSString *tempCost = [costPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    tempCost = [tempCost stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    NSString *tempSales = [salesPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    tempSales = [tempSales stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    if((![salesPrice.text isEqualToString:@""])||(![costPrice.text isEqualToString:@""])){
        float dProfitAmt = 0;
        float dsellingAmt = tempSales.floatValue;
        float dcostAmt = tempCost.floatValue;
        dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
        profitAmount.text = [NSString stringWithFormat:@"%.2f",dProfitAmt];
    }
    if([profitAmount.text isEqualToString:@"nan"] || [profitAmount.text isEqualToString:@"-inf"] || [profitAmount.text isEqualToString:@"inf"] || [profitAmount.text isEqualToString:@"-100.00"]){
        profitAmount.text = @"0.00";
    }
}

- (NSString *)calculateMarginCost:(float)costPrice Sales:(float)salesPrice{
    float dProfitAmt=0;
    dProfitAmt=(1 - (costPrice/salesPrice)) * 100;
    NSString * marging=[NSString stringWithFormat:@"%.2f",dProfitAmt];
    if([marging isEqualToString:@"nan"] || [marging isEqualToString:@"-inf"] || [marging isEqualToString:@"inf"] || [marging isEqualToString:@"-100.00"]){
        marging = @"0.00";
    }
    return marging;
}
- (NSString *)calculateMarkUpCost:(float)costPrice Sales:(float)salesPrice{
        float dProfitAmt=0;

        if(costPrice == 0){
            dProfitAmt=((salesPrice-costPrice)*100);
            return [NSString stringWithFormat:@"%.2f",dProfitAmt];
        }
        else{
            dProfitAmt=((salesPrice-costPrice)*100)/costPrice;
            return [NSString stringWithFormat:@"%.2f",dProfitAmt];
        }
}

-(NSString *)getSelectedVariationString:(NSMutableArray *)pArray{
    NSArray *arrayVariations = [pArray valueForKey:@"variationName"];
    NSString *strResult = [NSString string];
    if(arrayVariations.count>0){
        for (int isup=0; isup<arrayVariations.count; isup++){
            NSString *ch = arrayVariations[isup];
            strResult = [strResult stringByAppendingString:[NSString stringWithFormat:@"%@,", ch]];
        }
    }
    else{
        strResult=@"";
    }
    if(strResult.length>0){
        strResult = [strResult substringToIndex:strResult.length-1];
    }
    return strResult;
}
-(NSString *)getSelectedVariationStringFromItem{
    NSString *strResult = [NSString string];
    NSManagedObjectContext *context = self.managedObjectContext;
    Item *anItem = [self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemId.stringValue] moc:context];
    
    NSArray *itemVariations = anItem.itemVariations.allObjects ;
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"colPosNo" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    NSArray *sortedArray = [itemVariations sortedArrayUsingDescriptors:sortDescriptors];
    
    if(sortedArray.count>0){
        for (ItemVariation_M *vari in sortedArray){
            NSString *ch = vari.variationMMaster.name;
            strResult = [strResult stringByAppendingString:[NSString stringWithFormat:@"%@,", ch]];
        }
    }
    else{
        strResult=@"";
    }
    if(strResult.length>0){
        strResult = [strResult substringToIndex:strResult.length-1];
    }
    return strResult;
}
- (void)setPropertyToSuppliersLabel:(UILabel *)vendarName{
    vendarName.numberOfLines = 2;
    vendarName.backgroundColor = [UIColor clearColor];
    vendarName.textColor = [UIColor blackColor];
    vendarName.font = [UIFont fontWithName:@"Lato-Regular" size:14];
}
#pragma mark - Change Image -
-(void)selectImageCapture:(UIButton *)sender{
    [self.priceChangeAndCalculationDelegate selectImageCapture:sender];
}
#pragma mark - BarCode -
- (IBAction)allowDuplicateBarcodeClicked:(UISwitch * )sender{
    [self.rmsDbController playButtonSound];
    if(sender.isOn){
        self.itemInfoDataObject.IsduplicateUPC = YES;
    }
    else{
        self.itemInfoDataObject.IsduplicateUPC = NO;
    }
    
//    [self.itemInfoDataObject.dictGetItemData setValue:@(self.itemInfoDataObject.isDuplicateBarcodeAllowed) forKey:@"IsduplicateUPC"];
    NSDictionary *allowDuplicateBarcodeDict = @{kRIMItemAllowDuplicateBarcodeKey : @(self.itemInfoDataObject.IsduplicateUPC)};
    [Appsee addEvent:kRIMItemAllowDuplicateBarcode withProperties:allowDuplicateBarcodeDict];
}
-(IBAction)moreBarcodeClicked:(UIButton *)sender {
//    if(IsPad()){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
        MultipleBarcodePopUpVC *barcodePopUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"MultipleBarcodePopUpVC_sid"];
        barcodePopUpVC.editingPackageType = ItemBarcodeTypeAll;
        barcodePopUpVC.multipleBarcodePopUpVCDelegate = self;
        barcodePopUpVC.arrItemBarcodeList = [self.itemInfoDataObject.arrItemAllBarcode mutableCopy];
        [self checkBarcodeArrayIsAlloc]; // check singleitem, case & pack barcode is allocated or not
        
        if(![self.itemInfoDataObject.Barcode isEqualToString:@""]){
            barcodePopUpVC.itemCode = self.itemInfoDataObject.ItemId.stringValue;
        }
        else{
            barcodePopUpVC.itemCode = @"";
        }
        barcodePopUpVC.isDuplicateBarcodeAllowed = self.itemInfoDataObject.IsduplicateUPC;
        [barcodePopUpVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionLeft];
//    }
//    else{
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
//        MultipleBarcodePopUpVC *barcodePopUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"MultipleBarcodePopUpVC_sid"];
//        barcodePopUpVC.editingPackageType = PackageTypeAll;
//        barcodePopUpVC.multipleBarcodePopUpVCDelegate = self;
//        [self checkBarcodeArrayIsAlloc]; // check singleitem, case & pack barcode is allocated or not
//        // save basic core data barecode
//        self.itemInfoDataObject.backUpSingleItemBarcodes = [self.itemInfoDataObject.singleItemBarcodesList mutableCopy ];
//        self.itemInfoDataObject.backUpCaseBarcodes = [self.itemInfoDataObject.caseBarcodesList mutableCopy ];
//        self.itemInfoDataObject.backUpPackBarcodes = [self.itemInfoDataObject.packBarcodesList mutableCopy ];
//        // save done
//        barcodePopUpVC.singleItemBarcodes = self.itemInfoDataObject.singleItemBarcodesList;
//        barcodePopUpVC.caseBarcodes = self.itemInfoDataObject.caseBarcodesList;
//        barcodePopUpVC.packBarcodes = self.itemInfoDataObject.packBarcodesList;
//        if(![self.itemInfoDataObject.Barcode isEqualToString:@""]){
//            barcodePopUpVC.itemCode = self.itemInfoDataObject.Barcode;
//        }
//        else{
//            barcodePopUpVC.itemCode = @"";
//        }
//        barcodePopUpVC.isDuplicateBarcodeAllowed = self.itemInfoDataObject.IsduplicateUPC;
//        [self.navigationController pushViewController:barcodePopUpVC animated:YES];
//    }
}
-(void)checkBarcodeArrayIsAlloc{
    if(self.itemInfoDataObject.arrItemAllBarcode == nil){
        self.itemInfoDataObject.arrItemAllBarcode = [[NSMutableArray alloc] init ];
    }
}

# pragma mark - Multiplebarcode Delegate
- (void)didUpdateMultipleBarcode:(NSMutableArray *)itemBarcodes allowToItems:(NSString *)allowToItems {
    self.itemInfoDataObject.arrItemAllBarcode = itemBarcodes;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"IsDefault == %@",@"1"];
    NSMutableDictionary * dictDefault = [[itemBarcodes filteredArrayUsingPredicate:predicate] firstObject];
    
    self.itemInfoDataObject.Barcode = dictDefault[@"Barcode"];

    self.itemInfoDataObject.duplicateUPCItemCodes = allowToItems;
    [self.tblItemInfo reloadData];
}

#pragma mark - Dipartment Changed -
- (IBAction)btnItemDeptClicked:(UIButton *)sender{
    [Appsee addEvent:kRIMItemDepartment];
    [self.rmsDbController playButtonSound];
    DepartmentPopover *deptIpad =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"DepartmentPopover_sid"];
    
    deptIpad.departmentPopoverDelegate = self;
    NSArray *stringArray = [self.itemInfoDataObject.DepartmentName componentsSeparatedByString:@"," ];
    NSString *mainDept;
    if(stringArray.count > 0){
        mainDept = stringArray.firstObject;
        deptIpad.getDeptName = mainDept;
        deptIpad.getDeptId = self.itemInfoDataObject.DepartId.stringValue;
        deptIpad.checkItemType = self.ITM_Type;
    }
    else{
        deptIpad.getDeptName = self.itemInfoDataObject.DepartmentName;
        deptIpad.getDeptId = self.itemInfoDataObject.DepartId.stringValue;
        deptIpad.checkItemType = self.ITM_Type;
    }
    [self.navigationController pushViewController:deptIpad animated:YES];
}
-(void)newDepartmentSelected:(NSDictionary *)addedDepatmentDict{
    
    if (self.itemInfoDataObject.EBT.boolValue && [self isDepartmentAllowToEBT:[addedDepatmentDict valueForKey:@"DeptId"]]) {
        [self showMessageOfChangePriceTitle:@"Item Management" withMessage:@"Please remove EBT for this Department"];
    }
    else {
        self.itemInfoDataObject.DepartmentName = [addedDepatmentDict valueForKey:@"DeptName"];
        self.itemInfoDataObject.DepartId = @([[addedDepatmentDict valueForKey:@"DeptId"] intValue]);
        [self.tblItemInfo reloadData];
    }
}
-(void)didChangeSelectedDepartment:(NSDictionary *)changeDepatmentDict{
    if (self.itemInfoDataObject.EBT.boolValue && [self isDepartmentAllowToEBT:[changeDepatmentDict valueForKey:@"DeptId"]]) {
        [self showMessageOfChangePriceTitle:@"Item Management" withMessage:@"Please remove EBT for this Department"];
    }
    else {
        self.itemInfoDataObject.DepartmentName = [changeDepatmentDict valueForKey:@"DeptName"];
        self.itemInfoDataObject.DepartId = @([[changeDepatmentDict valueForKey:@"DeptId"] intValue]);
        if ([self.itemInfoDataObject.TaxType isEqualToString:@"Department wise"] && [self getDepartmentTaxOfItemDepartment].count >0) {
            self.itemInfoDataObject.isItemPayout = FALSE;
        }
        [self.tblItemInfo reloadData];
    }
}
-(BOOL)isDepartmentAllowToEBT:(NSString *)strDeptId{
    BOOL isAllow = FALSE;
    Department * dept = [self fetchDepartmentWithDepartmentID:strDeptId];
    if (dept) {
        if (dept.deductChk.boolValue || dept.chkCheckCash.boolValue || dept.chargeAmt.floatValue > 0) {
            isAllow = TRUE;
        }
    }
    return isAllow;
}
- (Department *)fetchDepartmentWithDepartmentID :(NSString *)DepartmentId{
    Department *department=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d", DepartmentId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0){
        department=resultSet.firstObject;
    }
    return department;
}

#pragma mark - Sub Dipartment Changed -
- (IBAction)btnItemSubDeptClicked:(UIButton *)sender{
    
    [Appsee addEvent:kRIMItemSubDepartment];
    [self.rmsDbController playButtonSound];
    MultipleSubDepartment *multipleSubDept =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"MultipleSubDepartment_sid"];

    multipleSubDept.selectedDeptId = (self.itemInfoDataObject.DepartId).stringValue;
    multipleSubDept.strSubDeptName = [NSString stringWithFormat:@"%@",self.itemInfoDataObject.SubDepartmentName];
    multipleSubDept.strSubDeptId = [NSString stringWithFormat:@"%@",self.itemInfoDataObject.SubDepartId];
    multipleSubDept.multipleSubDepartmentDelegate = self;
    [self.navigationController pushViewController:multipleSubDept animated:YES];
}

-(void)newSubDepartmentSelected:(NSDictionary *)addedSubDepatmentDict{
    self.itemInfoDataObject.SubDepartmentName = [addedSubDepatmentDict valueForKey:@"SubDeptName"];
    self.itemInfoDataObject.SubDepartId = @([[addedSubDepatmentDict valueForKey:@"BrnSubDeptID"]intValue]);
//    self.itemInfoDataObject.SubDepartId = [NSString stringWithFormat:@"%@",[addedSubDepatmentDict valueForKey:@"BrnSubDeptID"]];
    [self.tblItemInfo reloadData];
}

-(void)didChangeSubSelectedDepartment:(NSDictionary *)changeSubDepatmentDict{
    self.itemInfoDataObject.SubDepartmentName = [changeSubDepatmentDict valueForKey:@"SubDepartmentName"];
    self.itemInfoDataObject.SubDepartId = @([[changeSubDepatmentDict valueForKey:@"SubDeptId"] intValue]);
//    self.itemInfoDataObject.SubDepartId = [NSString stringWithFormat:@"%@",[changeSubDepatmentDict valueForKey:@"SubDeptId"]];
    [self.tblItemInfo reloadData];
}

#pragma mark - Variation Changed -
- (IBAction)btnItemVariationClicked:(UIButton *)sender{
    [self.rmsDbController playButtonSound];
    
    ItemVariationRIM *variation =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemVariationRIM_sid"];
    
//    ItemVariationRIM *variation = [[ItemVariationRIM alloc] initWithNibName:@"ItemVariationRIM" bundle:nil];
    variation.ItemVariationChangedDelegate = self;
    
    if(self.itemInfoDataObject.arrayVariation){
        variation.arraySelectionVeriation=self.itemInfoDataObject.arrayVariation;
    }
    else{
        variation.arraySelectionVeriation=[[self getItemVariationArrayforDispay]mutableCopy];
    }
    
    [self.navigationController pushViewController:variation animated:YES];
}
-(void)didChangeItemVariationAdded:(NSMutableArray *)addedItemVariation ItemVariationDeleted:(NSMutableArray *)deletedItemVariation ItemVariationDisplay:(NSMutableArray *)displayItemVariation {
    self.itemInfoDataObject.arrayVariation=addedItemVariation;
    self.itemInfoDataObject.arrayDeletedVariation=deletedItemVariation;
    self.itemInfoDataObject.arrayDisplayVariation=displayItemVariation;
    [self.priceChangeAndCalculationDelegate setItemVariationsValue];
    if ([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"] || [self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATIONAPPROPRIATE"]) {
        [self.priceChangeAndCalculationDelegate getItemVariationData];
    }
    [self.tblItemInfo reloadData];
}
-(NSMutableArray *)getItemVariationArrayforDispay{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    Item *anItem = [self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemId.stringValue] moc:context];
    
    NSArray *itemVariations = anItem.itemVariations.allObjects ;
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"colPosNo" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    NSArray *sortedArray = [itemVariations sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrayVariationMD;
    NSMutableArray *arrayVariationM = [[NSMutableArray alloc]init];
    for (ItemVariation_M *vari in sortedArray){
        NSMutableDictionary *dictM = [[NSMutableDictionary alloc]init];
        dictM[@"ColPosNo"] = vari.colPosNo;
        dictM[@"varianceId"] = vari.variationMMaster.vid;
        dictM[@"variationName"] = vari.variationMMaster.name;
        if (vari.variationMVariationMds.allObjects .count == 0) {
            continue ;
        }
        
        NSArray *variationList = vari.variationMVariationMds.allObjects ;
        NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowPosNo" ascending:YES];
        NSArray *sortDescriptors = @[aSortDescriptor];
        NSArray *sortedVarArray = [variationList sortedArrayUsingDescriptors:sortDescriptors];
        
        if(sortedVarArray.count>0){
            arrayVariationMD = [[NSMutableArray alloc]init];
            for (ItemVariation_Md *varimd in sortedVarArray){
                NSMutableDictionary *dictM = [[NSMutableDictionary alloc]init];
                dictM[@"Value"] = varimd.name;
                dictM[@"RowPosNo"] = varimd.rowPosNo;
                dictM[@"Cost"] = varimd.cost;
                dictM[@"Profit"] = varimd.profit;
                dictM[@"UnitPrice"] = varimd.unitPrice;
                dictM[@"PriceA"] = varimd.priceA;
                dictM[@"PriceB"] = varimd.priceB;
                dictM[@"PriceC"] = varimd.priceC;
                dictM[@"ApplyPrice"] = varimd.applyPrice;
                
                [arrayVariationMD addObject:[dictM mutableCopy]];
            }
//            NSMutableDictionary *dictM = [[NSMutableDictionary alloc]init];
//            dictM[@"AddMore"] = @"";
//            [arrayVariationMD addObject:[dictM mutableCopy]];
        }
        if (arrayVariationMD != nil || arrayVariationMD.count > 0) {
            dictM[@"variationsubArray"] = arrayVariationMD;
        }
        [arrayVariationM addObject:dictM];
    }
    return arrayVariationM;
}

#pragma mark - SupplierData -
- (IBAction)btnItemSuppClick:(UIButton *)sender{
    [Appsee addEvent:kRIMItemSupplier];
    
    RimSupplierPage *supplierNew =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimSupplierPage_sid"];

    if(!self.itemInfoDataObject.itemsupplierarray){
        self.itemInfoDataObject.itemsupplierarray = [[NSMutableArray alloc] init];
    }
    supplierNew.checkedSupplier = self.itemInfoDataObject.itemsupplierarray;
    supplierNew.rimSupplierChangeDelegate=self;
    supplierNew.strItemcode=@"1";
    supplierNew.callingFunction=@"add";
    [self.navigationController pushViewController:supplierNew animated:YES];
}
- (void)didChangeSupplier:(NSMutableArray *)SupplierListArray{
    self.itemInfoDataObject.itemsupplierarray=SupplierListArray;
    [self viewItemSupplierData:SupplierListArray];
}
- (void)configureSelectedSuppliersTableHeading{
    [self.tblItemInfo reloadData];
    [self createSalesRepresentativeArrayForDisplay];
    [tblsupplierlist reloadData];
    float rowHeight = (self.salesRepresentativesList.count*30)+30;
    tblsupplierlist.userInteractionEnabled = (rowHeight>150)?TRUE:FALSE;
    rowHeight = (rowHeight>150)?150:rowHeight;
    if (IsPhone()){
        supplierview.frame = CGRectMake(0, 0, 320,rowHeight);
        tblsupplierlist.frame = CGRectMake(0, 30, 320,rowHeight-30);
    }
    else{
        supplierview.frame = CGRectMake(0, 0, 715,rowHeight);
        tblsupplierlist.frame = CGRectMake(0, 30, 720,rowHeight-30);
    }
    tblsupplierlist.separatorStyle = UITableViewCellSeparatorStyleNone;
    supplierview.backgroundColor = [UIColor clearColor];
    
    tblsupplierlist.scrollEnabled = YES;
    tblsupplierlist.bounces = YES;
    tblsupplierlist.delegate = self;
    tblsupplierlist.dataSource = self;
    tblsupplierlist.backgroundColor = [UIColor clearColor];
    CGRect frameVenderName = CGRectMake(60, 5, 150, 20);
    CGRect frameSupplierName = CGRectMake(262, 5, 300, 20);
    CGRect frameContactNo = CGRectMake(480, 5, 220, 20);
    if (IsPhone()){
        frameVenderName = CGRectMake(30, 0, 150, 30);
        frameSupplierName = CGRectZero;
        frameContactNo = CGRectMake(190, 0, 100, 30);
    }

    UILabel *venderName = [[UILabel alloc] initWithFrame:frameVenderName];
    [self setTableViewHeadingLabel:venderName];
    venderName.text = @"Vendor Name".uppercaseString;
    
    UILabel *supplierName = [[UILabel alloc] initWithFrame:frameSupplierName];
    [self setTableViewHeadingLabel:supplierName];
    supplierName.text = @"Sales Representative".uppercaseString;
    
    UILabel *contactNo = [[UILabel alloc] initWithFrame:frameContactNo];
    [self setTableViewHeadingLabel:contactNo];
    contactNo.textAlignment = NSTextAlignmentRight;
    contactNo.text = @"Contact".uppercaseString;
    
    [supplierview addSubview:venderName];
    [supplierview addSubview:supplierName];
    [supplierview addSubview:contactNo];
    
    [supplierview addSubview:tblsupplierlist];
}
- (void)setTableViewHeadingLabel:(UILabel *)venderName{
    venderName.backgroundColor = [UIColor clearColor];
    venderName.textAlignment = NSTextAlignmentLeft;
    venderName.font = [UIFont fontWithName:@"Lato-Regular" size:14];
    venderName.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
    venderName.numberOfLines = 0;
}
- (void)createSalesRepresentativeArrayForDisplay{
    self.salesRepresentativesList = [[NSMutableArray alloc] init];
    for (int isup = 0; isup < self.itemInfoDataObject.itemsupplierarray.count; isup++){
        NSMutableArray *SalesRepresentatives = self.itemInfoDataObject.itemsupplierarray[isup][@"SalesRepresentatives"];
        if(SalesRepresentatives.count > 0){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Id == %d",0];
            NSMutableArray * defaultObject = [[SalesRepresentatives filteredArrayUsingPredicate:predicate] mutableCopy];
            if (defaultObject && defaultObject.count > 0 && SalesRepresentatives.count > 1) {
                [SalesRepresentatives removeObject:defaultObject.firstObject];
            }
            [self.salesRepresentativesList addObjectsFromArray:[[NSArray alloc] initWithArray:SalesRepresentatives]];
        }
        else{
            NSMutableArray *SalesRepresentative = [[NSMutableArray alloc] init];
            NSString *companyName = [(self.itemInfoDataObject.itemsupplierarray)[isup] valueForKey:@"CompanyName"];
            NSString *companyNo = [(self.itemInfoDataObject.itemsupplierarray)[isup] valueForKey:@"ContactNo"];
            NSInteger vendorId = [[(self.itemInfoDataObject.itemsupplierarray)[isup] valueForKey:@"VendorId"] integerValue ];
            NSString *venId = [NSString stringWithFormat:@"%ld",(long)vendorId];
            NSMutableDictionary *repDict = [[NSMutableDictionary alloc] init];
            repDict[@"Id"] = @(0);
            repDict[@"FirstName"] = @"";
            if (companyNo) {
                repDict[@"ContactNo"] = companyNo;
            }
            else{
                repDict[@"ContactNo"] = @"";
            }
            repDict[@"CompanyName"] = companyName;
            repDict[@"Position"] = @"";
            repDict[@"Email"] = @"";
            repDict[@"VendorId"] = venId;
            [SalesRepresentative addObject:repDict ];
            self.itemInfoDataObject.itemsupplierarray[isup][@"SalesRepresentatives"] = SalesRepresentative;
            [self.salesRepresentativesList addObjectsFromArray:SalesRepresentative];
        }
    }
}
-(void)viewItemSupplierData:(NSArray *) dictItemSupplier{
    for(UIView *subview in supplierview.subviews){
        [subview removeFromSuperview];
    }
    if(self.itemInfoDataObject.itemsupplierarray.count > 0){
        [self configureSelectedSuppliersTableHeading];
    }
    else{
        [self.tblItemInfo reloadData];
    }
}

-(void)getSupplierDataFromTable{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemSupplier" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d",self.itemInfoDataObject.ItemId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *supplierListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    NSArray *filteredSupplier = [supplierListArray valueForKeyPath:@"@distinctUnionOfObjects.vendorId"];
    
    self.itemInfoDataObject.itemsupplierarray = [[NSMutableArray alloc] init];
    
    for (int i=0; i < filteredSupplier.count; i++){
        NSNumber *vendorId = filteredSupplier[i];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %@",vendorId];
        fetchRequest.predicate = predicate;
        NSArray *itemSizeName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemSizeName.count > 0){
            SupplierCompany *supplierComp = itemSizeName.firstObject;
            NSMutableDictionary *supplierDict = [[NSMutableDictionary alloc]init];
            supplierDict[@"CompanyName"] = supplierComp.companyName;
            supplierDict[@"Email"] = supplierComp.email;
            supplierDict[@"ContactNo"] = supplierComp.phoneNo;
            supplierDict[@"VendorId"] = supplierComp.companyId;
            
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"vendorId == %@",vendorId];
            NSArray *supIdArray = [supplierListArray filteredArrayUsingPredicate:predicate2];
            if(supIdArray.count > 0){
                NSMutableArray *salesRepArray = [[NSMutableArray alloc] init];
                for (ItemSupplier *supplier in supIdArray){
                    NSMutableDictionary *repDict = [[NSMutableDictionary alloc] init];
                    
                    repDict[@"Id"] = supplier.supId;
                    // START SupplierRepresentative Details
                    [self getSalesRepresentativeList:supplier repDict:repDict supplierComp:supplierComp];
                    // STOP SupplierRepresentative Details
                    
                    repDict[@"VendorId"] = supplier.vendorId;
                    [salesRepArray addObject:repDict];
                }
                supplierDict[@"SalesRepresentatives"] = salesRepArray;
            }
            else{
                NSMutableArray *salesRepArray = [[NSMutableArray alloc] init];
                supplierDict[@"SalesRepresentatives"] = salesRepArray;
            }
            [self.itemInfoDataObject.itemsupplierarray addObject:supplierDict];
        }
    }
    [self.itemInfoDataObject createDuplicateItemSupplierarray];
    [self viewItemSupplierData:self.itemInfoDataObject.itemsupplierarray];
}
- (void)getSalesRepresentativeList:(ItemSupplier *)supplier repDict:(NSMutableDictionary *)repDict supplierComp:(SupplierCompany *)supplierComp{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierRepresentative" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brnSupplierId == %@",supplier.supId];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0){
        for (SupplierRepresentative *supplier in resultSet) {
            repDict[@"FirstName"] = supplier.firstName;
            repDict[@"ContactNo"] = supplier.contactNo;
            repDict[@"CompanyName"] = supplier.companyName;
            repDict[@"Position"] = supplier.position;
            repDict[@"Email"] = supplier.email;
        }
    }
    else{
        repDict[@"FirstName"] = @"";
        repDict[@"ContactNo"] = @"";
        repDict[@"CompanyName"] = supplierComp.companyName;
        repDict[@"Position"] = @"";
        repDict[@"Email"] = @"";
    }
}
#pragma mark - Tax -
- (void)didSelectTaxType:(TaxType)taxType{
    self.itemInfoDataObject.TaxType = objTaxPop.selectedTaxType;
    NSDictionary *taxTypeDict = @{kRIMItemTaxTypeSelectedKey : objTaxPop.selectedTaxType};
    [Appsee addEvent:kRIMItemTaxTypeSelected withProperties:taxTypeDict];
    [self CallTaxwise];
    [objTaxPop.view removeFromSuperview];
}
- (void)didCancelTaxType {
    [Appsee addEvent:kRIMItemTaxTypeCancel];
    [objTaxPop.view removeFromSuperview];
}

- (IBAction)btnItemTaxClick:(UIButton *)sender{
    [Appsee addEvent:kRIMItemTaxType];
    
    [self.rmsDbController playButtonSound];

    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"Department wise",@"Tax wise"] SelectedObject:self.itemInfoDataObject.TaxType SelectionComplete:^(NSArray *arrSelection) {
        self.itemInfoDataObject.TaxType = arrSelection[0];
        [self CallTaxwise];
    } SelectionColse:^(UIViewController *popUpVC) {
        if (self.itemInfoDataObject.itemtaxarray.count == 0) {
            self.itemInfoDataObject.TaxType = @"Department wise";
            self.itemInfoDataObject.itemtaxarray = nil;
            [self.tblItemInfo reloadData];
        }
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    if (sender) {
        [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionAny];
    }
    else{
        [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:nil ArrowDirection:(UIPopoverArrowDirection)nil];
    }
}
-(void)CallTaxwise{
    if([[NSString stringWithFormat:@"%@",self.itemInfoDataObject.TaxType] isEqualToString:@"Tax wise"]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self taxprocess];
        });
    }
    else{
        if ([self getDepartmentTaxOfItemDepartment].count >0) {
            self.itemInfoDataObject.isItemPayout = FALSE;
        }
        self.itemInfoDataObject.itemtaxarray = nil;
        [self.tblItemInfo reloadData];
    }
}
- (void)didSelectTax:(NSMutableArray *)taxListArray{
    if (self.navigationController){
        if(taxListArray.count > 0){
            self.itemInfoDataObject.TaxType = @"Tax wise";
            self.itemInfoDataObject.itemtaxarray = [taxListArray mutableCopy];
            self.itemInfoDataObject.isItemPayout = FALSE;
        }
        else{
            self.itemInfoDataObject.itemtaxarray = [taxListArray mutableCopy];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createtaxList];
        });
        [self.navigationController popViewControllerAnimated:YES];
        NSDictionary *taxDict = @{kRIMItemTaxSelectedKey : @((self.itemInfoDataObject.itemtaxarray).count)};
        [Appsee addEvent:kRIMItemTaxSelected withProperties:taxDict];
    }
    else{
        [self.view removeFromSuperview];
    }
}
-(void) taxprocess{
    RimTaxAddRemovePage *taxAddRemoveiPad =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimTaxAddRemovePage_sid"];
    
    taxAddRemoveiPad.checkedTaxItem = self.itemInfoDataObject.itemtaxarray;
    taxAddRemoveiPad.rimTaxAddRemovePageDelegate = self;
    taxAddRemoveiPad.strItemcode=@"1";
    [self.navigationController pushViewController:taxAddRemoveiPad animated:YES];
}

-(void)getTaxListFromTable{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%d",self.itemInfoDataObject.ItemId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *taxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    self.itemInfoDataObject.itemtaxarray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<taxListArray.count; i++){
        ItemTax *objTax=taxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",objTax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemSizeName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemSizeName.count>0){
            TaxMaster *txMaster=itemSizeName.firstObject;
            NSMutableDictionary *tagDict=[[NSMutableDictionary alloc]init];
            tagDict[@"TAXNAME"] = txMaster.taxNAME;
            tagDict[@"PERCENTAGE"] = txMaster.percentage;
            tagDict[@"TaxId"] = txMaster.taxId;
            tagDict[@"Amount"] = txMaster.amount;
            [self.itemInfoDataObject.itemtaxarray addObject:tagDict];
        }
    }
    [self.itemInfoDataObject createDuplicateItemTaxArray];
    [self viewItemTaxData:self.itemInfoDataObject.itemtaxarray];
}
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
-(void)createtaxList{
    for(UIView *subview in taxview.subviews) {
        [subview removeFromSuperview];
    }
    
    if(self.itemInfoDataObject.itemtaxarray.count>0){
        [self.tblItemInfo reloadData];
        [tbltaxlist reloadData];
        [self setTaxListTableViewHeading];
        [taxview addSubview:tbltaxlist];
    }
    else{
        self.itemInfoDataObject.TaxType = @"Tax wise";
        [self btnItemTaxClick:nil];
        [self.tblItemInfo reloadData];
    }
}
-(void)viewItemTaxData:(NSArray *) dictArrItemTax{
    for(UIView *subview in taxview.subviews) {
        [subview removeFromSuperview];
    }
    if(self.itemInfoDataObject.itemtaxarray.count>0){
        [self setTaxListTableViewHeading];
        [taxview addSubview:tbltaxlist];
        [self.tblItemInfo reloadData];
        [tbltaxlist reloadData];
    }
    else{
        [self.tblItemInfo reloadData];
    }
}
- (void)setTaxListTableViewHeading{
    float rowHeight = (self.itemInfoDataObject.itemtaxarray.count*30)+30;
    tbltaxlist.userInteractionEnabled = (rowHeight>150)?TRUE:FALSE;
    rowHeight = (rowHeight>150)?150:rowHeight;
    if (IsPhone()){
        taxview.frame = CGRectMake(0, 0, 320,rowHeight);
        tbltaxlist.frame = CGRectMake(0, 30, 320,rowHeight-30);
        tbltaxlist.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else{
        taxview.frame = CGRectMake(0, 0, 648,rowHeight);
        tbltaxlist.frame = CGRectMake(0, 30, 720,rowHeight-30);
        tbltaxlist.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    taxview.backgroundColor = [UIColor clearColor];
    
    tbltaxlist.scrollEnabled = YES;
    tbltaxlist.bounces = YES;
    tbltaxlist.delegate = self;
    tbltaxlist.dataSource = self;
    tbltaxlist.backgroundColor = [UIColor clearColor];
    
    CGRect framLabelTax = CGRectMake(60, 5, 250, 20);
    CGRect framLabelTaxPercentage = CGRectMake(262, 5, 250, 20);
    if (IsPhone()){
        framLabelTax = CGRectMake(30, 5, 100, 20);
        framLabelTaxPercentage = CGRectMake(190, 5, 100, 20);
    }
    UILabel *labelTax = [[UILabel alloc] initWithFrame:framLabelTax];
    [self setTableViewHeadingLabel:labelTax];
    labelTax.text = @"Tax Name(s)".uppercaseString;
    
    UILabel *labelTaxPercentage = [[UILabel alloc] initWithFrame:framLabelTaxPercentage];
    [self setTableViewHeadingLabel:labelTaxPercentage];
    labelTaxPercentage.text = @"Tax %".uppercaseString;
    if (IsPhone()) {
        labelTaxPercentage.textAlignment = CPTTextAlignmentRight;
    }
    [taxview addSubview:labelTax];
    [taxview addSubview:labelTaxPercentage];
}
-(BOOL)isRestaurentActive{
    BOOL isRestaurentActive = FALSE;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSPredicate *restaurentActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ || ModuleCode == %@",@"RRRCR",@"RRCR"];
    NSArray *restaurentArray = [activeModulesArray filteredArrayUsingPredicate:restaurentActive];
    if (restaurentArray.count > 0){
        isRestaurentActive = TRUE;
    }
    else{
        isRestaurentActive = FALSE;
    }
    return isRestaurentActive;
}
-(BOOL)isSubDepartmentActive
{
    BOOL isSubdepart = FALSE;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSPredicate *restaurentActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@", @"RCR",@"RCRGAS",@"RRRCR",@"RRCR"];
    NSArray *restaurentArray = [activeModulesArray filteredArrayUsingPredicate:restaurentActive];
    if (restaurentArray.count > 0)
    {
        NSString * moduleCode = [[restaurentArray valueForKey:@"ModuleCode"]firstObject];
        if ([moduleCode isEqualToString:@"RCR"] && [configuration.subDepartment isEqual:@(1)]) {
            isSubdepart = TRUE;
        }
        else if ([moduleCode isEqualToString:@"RRRCR"] && [configuration.subDepartment isEqual:@(1)]) {
            isSubdepart = TRUE;
        }
        else if([moduleCode isEqualToString:@"RCRGAS"])
        {
            isSubdepart= FALSE;
        }
        else if([moduleCode isEqualToString:@"RRCR"])
        {
            isSubdepart = TRUE;
        }
        
    }
    else if([configuration.subDepartment isEqual:@(1)]){
        isSubdepart = TRUE;
    }
    else{
        isSubdepart = FALSE;
    }
    return isSubdepart;
    
}

#pragma mark - Group And Tag Delegate -
- (IBAction)btnItemGroupClicked:(UIButton *)sender{
    [Appsee addEvent:kRIMItemGroup];
    
    [self.rmsDbController playButtonSound];
    
    GroupMasterPopover *objGroupMasterIpad =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"GroupMasterPopover_sid"];
    
    objGroupMasterIpad.GroupMasterChangeDelegate = self;
    objGroupMasterIpad.strGroupName = [NSString stringWithFormat:@"%@",self.itemInfoDataObject.CateId];
    objGroupMasterIpad.strGroupID = [NSString stringWithFormat:@"%@",self.itemInfoDataObject.CateId];
    [self.navigationController pushViewController:objGroupMasterIpad animated:YES];
}
-(void)didChangeGroupMaster:(NSString *)selectedGroupName GroupId:(NSString *)selectedGroupId{
    self.itemInfoDataObject.GroupName = selectedGroupName;
    self.itemInfoDataObject.CateId = @(selectedGroupId.intValue);
    [self.tblItemInfo reloadData];
}
-(void)checkMixMatchGroupDiscount:(NSString *)groupDiscId{
    if(![groupDiscId isEqualToString:@"0"]){
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mix_MatchDetail" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mixMatchId==%d",groupDiscId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *mixMatchList = [UpdateManager executeForContext:managedObjectContext FetchRequest:fetchRequest];
        if (mixMatchList.count > 0){
//            Mix_MatchDetail *mixMst = [mixMatchList firstObject];
//            self.selectedGroupSchemeName = mixMst.item_Description;
//            self.isGroupSchemeApply = TRUE;
//            
//            uvDiscountDetails.hidden = YES;
//            selectedDiscount = 1;
//            self.isDiscountSecondOptionClicked = TRUE;
//            [discountDetailsArray removeAllObjects];
//            self.noDiscount = @"0";
//            self.yesDiscount = @"0";
//            self.mixMatchFlg = @"0";
//            self.mixMatchId = @"0";
//            
//            self.cate_MixMatchFlg = @"1";
//            self.cate_MixMatchId = groupDiscId;
//            [self.tblDiscountSelection reloadData];
        }
        if(groupDiscId != nil){
//            NSDictionary *groupDict = @{@"GroupId" : groupDiscId,
//                                        @"GroupName" : lblItemGroup.text};
//            [Appsee addEvent:kRIMItemGroupSelected withProperties:groupDict];
        }
    }
}
-(NSInteger )getTagCounts{
    // Create and configure a fetch request with the GroupMaster entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SizeMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    if (self.strSearchTagText != nil && ![self.strSearchTagText isEqualToString:@""]) {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"sizeName CONTAINS[cd] %@", self.strSearchTagText];
        fetchRequest.predicate = predicate;
    }
    
    NSInteger resultSet = [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    return resultSet;
}
-(void)didAddNewTag:(NSString *)newTag{
    self.strSearchTagText=@"";
    selectedTag=@"";
    newTag = [newTag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(newTag.length > 0){
        if (![arrayTagListToDisplay containsObject:newTag]){
            [arrayTagListToDisplay addObject:[NSString stringWithFormat:@"%@",newTag]];
            NSDictionary *tagDict = @{kRIMItemTagKey : @(arrayTagListToDisplay.count)};
            [Appsee addEvent:kRIMItemTag withProperties:tagDict];
            [tagList setTags:arrayTagListToDisplay];
            NSMutableArray *arrCurrentTagLisr = [self getTagListRim];
            NSPredicate *tagTredicate = [NSPredicate predicateWithFormat:@"SizeName == [c]%@",newTag];
            NSArray *matchedTags = [arrCurrentTagLisr filteredArrayUsingPredicate:tagTredicate];
            if (matchedTags != nil && matchedTags.count > 0) {
                [self.itemInfoDataObject.responseTagArray addObject:matchedTags.firstObject];
            }
            else {
                NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                dict[@"SizeName"] = newTag;
                dict[@"SizeId"] = @"-1";
                [self.itemInfoDataObject.responseTagArray addObject:dict];
            }
        }
    }
    [self.tblItemInfo reloadData];
}
- (NSMutableArray *) getTagListRim {
    
    NSMutableArray * arrTagList =[[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SizeMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count > 0)
    {
        for (SizeMaster *size in resultSet)
        {
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"SizeName"] = size.sizeName;
            supplierDict[@"SizeId"] = size.sizeId;
            [arrTagList addObject:supplierDict];
        }
    }
    return arrTagList;
}
- (void)selectedTag:(NSString*)tagName withTabView:(id) tagView{
    [arrayTagListToDisplay removeObjectAtIndex:((MPTagView *)tagView).tag];
    NSInteger tag = ((MPTagView *)tagView).tag;
    [self.itemInfoDataObject.responseTagArray removeObjectAtIndex:tag];
    [tagList setTags:arrayTagListToDisplay];
    [self.tblItemInfo reloadData];
    selectedTag=@"";
}
-(void)tagSelectView:(UITextField *)textField withSearchString:(NSString *)strSearchText{
    if([self getTagCounts]>0 && IsPad()){
        if (!taglistPopupvc) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
            taglistPopupvc = [storyBoard instantiateViewControllerWithIdentifier:@"TagSuggestionVC"];
            taglistPopupvc.tagSuggestionDelegate=self;
        }
        taglistPopupvc.strSearchTagText=strSearchText;
        [taglistPopupvc reloadTableWithSearchItem];
        if (![self presentedViewController]) {
            [taglistPopupvc presentViewControllerForviewConteroller:self sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft InputViews:@[textField]];
        }
    }
}
-(void)didSelectTagfromList:(NSString *)strSelectedTag{
    selectedTag=strSelectedTag;
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.tblItemInfo reloadData];
}
-(void)getTagDataFromTable{
    arrayTagListToDisplay=[[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTag" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%d",self.itemInfoDataObject.ItemId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *tagListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    NSMutableArray *arrayMainTagList=[[NSMutableArray alloc]init];
    for (int i=0; i<tagListArray.count; i++){
        ItemTag *tag=tagListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SizeMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sizeId==%d",tag.sizeId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemSizeName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemSizeName.count > 0){
            SizeMaster *size=itemSizeName.firstObject;
            NSMutableDictionary *tagDict=[[NSMutableDictionary alloc]init];
            tagDict[@"SizeName"] = size.sizeName;
            tagDict[@"SizeId"] = tag.sizeId;
            [arrayMainTagList addObject:tagDict];
        }
    }
    self.itemInfoDataObject.responseTagArray=[[NSMutableArray alloc]initWithArray:arrayMainTagList];
    for (int i=0; i<self.itemInfoDataObject.responseTagArray.count; i++){
        NSMutableDictionary *dict=(self.itemInfoDataObject.responseTagArray)[i];
        NSString *str=dict[@"SizeName"];
        [arrayTagListToDisplay addObject:str];
    }
    [self.itemInfoDataObject createDuplicateItemresponseTagArray];
}
-(void)toggleMarginMarkUp{
    self.itemInfoDataObject.rowSwitch = !self.itemInfoDataObject.rowSwitch;
    UITableViewRowAnimation animation;
    UITableViewRowAnimation animation2;
    if (self.itemInfoDataObject.rowSwitch) {
        animation = UITableViewRowAnimationLeft;
        animation2 = UITableViewRowAnimationRight;
        [Appsee addEvent:kRIMItemProfitMargin];
    }
    else {
        animation2 = UITableViewRowAnimationLeft;
        animation = UITableViewRowAnimationRight;
        [Appsee addEvent:kRIMItemProfitMarkUp];
    }
    NSIndexPath *indexPath;
    if(self.itemInfoDataObject.quantityManagementEnabled){
        if(IsPad()){
            indexPath = [NSIndexPath indexPathForRow:PricingSectionItemProfit-1 inSection:1];
        }
        else{
            indexPath = [NSIndexPath indexPathForRow:PricingSectionItemProfit-1 inSection:ItemPricingSection];
        }
    }
    else{
        if(IsPad()){
            indexPath = [NSIndexPath indexPathForRow:PricingSectionItemProfit inSection:1];
        }
        else{
            indexPath = [NSIndexPath indexPathForRow:PricingSectionItemProfit inSection:ItemPricingSection];
        }
    }
    
    [self.tblItemInfo beginUpdates];
    [self.tblItemInfo deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    [self.tblItemInfo insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation2];
    [self.tblItemInfo endUpdates];
}

#pragma mark - WeightScaleData -

- (Item*)fetchAllItems :(NSString *)itemId moc:(NSManagedObjectContext *)moc{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}
- (int)qtyTypeForPricingDictionary:(NSDictionary *)p1{
    int type = 10;
    if([p1[@"PriceQtyType"] isEqualToString:@"Single Item"] || [p1[@"PriceQtyType"] isEqualToString:@"SINGLE ITEM"] || [p1[@"PriceQtyType"] isEqualToString:@"Single item"]){
        type = 1;
    }
    else if([p1[@"PriceQtyType"] isEqualToString:@"Case"] || [p1[@"PriceQtyType"] isEqualToString:@"CASE"]){
        type = 2;
    }
    else if([p1[@"PriceQtyType"] isEqualToString:@"Pack"] || [p1[@"PriceQtyType"] isEqualToString:@"PACK"]){
        type = 3;
    }
    return type;
}

#pragma mark - Price Change -
-(UITextField *)currentEditingView{
    return currentEditing;
}
-(void)setCurrentEdintingViewWithTextField:(UITextField *)textField{
    currentEditing=textField;
}
-(BOOL)willChangeItemQtyOHat:(int)index{
    int Qty=[[itemPriceLocalArray[index] valueForKey:@"Qty"] intValue];
    return (Qty>0?true : false);
}
-(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:messageTitle message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}
-(void)didPriceChangeOf:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber{
    if (PriceValueType==PricingSectionItemProfit && !self.itemInfoDataObject.rowSwitch) {
        [self.priceChangeAndCalculationDelegate didPriceChangeOfMarkUPValue:inputValue ValueIndex:IndexNumber];
    }
    else
    {
        [self.priceChangeAndCalculationDelegate didPriceChangeOf:PriceValueType inputValue:inputValue ValueIndex:IndexNumber];
    }
}
-(void)didPriceChangeOfInputWeight:(NSNumber *)inputValue InputWeightUnit:(NSString *)weightUnit  ValueIndex:(int)IndexNumber{
    [self.priceChangeAndCalculationDelegate didPriceChangeOfInputWeight:inputValue InputWeightUnit:weightUnit ValueIndex:IndexNumber];
}
-(int)willGetOfQtyValueForQtyOH:(int)IndexNumber{
    int Qty=[[itemPriceLocalArray[IndexNumber] valueForKey:@"Qty"] intValue];
    return Qty;
}
@end
