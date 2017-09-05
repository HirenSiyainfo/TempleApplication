//
//  ManualItemReceiveVC.m
//  RapidRMS
//
//  Created by Siya on 12/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ManualItemReceiveVC.h"
#import "DisplayItemInfoSideVC.h"
#import "ItemInfoVC.h"
#import "RmsDbController.h"
#import "MultipleBarcodePopUpVC.h"

#import "ItemInfoDisplayCell.h"
#import "ItemInfoPricingCell.h"
#import "ItemInfoImageCell.h"
#import "ItemImageSelectionVC.h"
#import "ItemInfoDescriptionCell.h"
#import "UITableView+AddBorder.h"


// CoreData
#import "ManualReceivedItem+Dictionary.h"
#import "Item+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "ItemTicket_MD+Dictionary.h"
#import "ManualPOSession+Dictionary.h"
#import "NSString+Validation.h"

typedef NS_ENUM(NSUInteger, InfoManualSection) // itemInfoSectionArray
{
    ItemInfoManualSection,
    ItemPricingManualSection,
};
typedef enum __SECTION_NAMES__
{
    IMAGE_SECTION,
    ITEM_QTY_ON_HAND,
    ITEM_CASE_PACK,
    ITEM_COST_SECTION,
    ITEM_AVG_SECTION,
    ITEM_PRICE_SECTION,
    ITEM_MARGIN_MARKUP,
    ITEM_LAST_INVOICE,
    ITEM_LAST_RECEIVED_DATE,
    ITEM_SUPPLIERS
} SECTION_NAMES;


@interface ManualItemReceiveVC () <PriceChangeDelegate,UIPopoverPresentationControllerDelegate,MultipleBarcodePopUpVCDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DisplayItemInfoSideVCDeledate,ItemSelctionImageChangedVCDelegate,UpdateDelegate> {
    UITextField *currentEditing;
    
    UIPopoverPresentationController *presentationController;
    UIImagePickerController *pickerCamera;
    UIButton *btnCameraClick;
    
    NSString *freeSingleValue;
    NSString *freeCaseValue;
    NSString *freePackValue;
    
    NSString *freeSingleCost;
    NSString *freeCaseCost;
    NSString *freePackCost;
    
    NSMutableArray *itemInfoSectionArray;
    NSMutableArray *itemPricingSelection;
    NSMutableArray *itemPriceLocalArray;
    
    NSString *strReceiveItemMethod;
    NSString *strReceiveItemMethodResult;
    
    BOOL isImageSet;
    BOOL IsImageDeleted;
    BOOL isReceivedSel;
    
    IntercomHandler *intercomHandler;
    ItemImageSelectionVC * itemImageSelectionVC;
    UIImagePickerController *imagePicker;
    
    UIColor * colorSingle,* colorCase,* colorPack,* colorChanged;
}

@property (nonatomic, weak) IBOutlet UIView *viewItemSideInfo;

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnReceived;
@property (nonatomic, weak) IBOutlet UIButton *btnFreeGoods;
@property (nonatomic, weak) IBOutlet UIButton *btnReturn;

@property (nonatomic, weak) IBOutlet UITableView *tblItemInfo;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) DisplayItemInfoSideVC *itemInfoSideVC;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *itemUpdateManager;

@property (nonatomic, strong) RapidWebServiceConnection *itemUpdateWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *addManualItemServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *itemUpdateConnnection;

@property (nonatomic, strong) UIPopoverPresentationController *barcodePresentationController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ManualItemReceiveVC



- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    
    self.itemUpdateWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.addManualItemServiceConnection = [[RapidWebServiceConnection alloc]init];
    self.itemUpdateConnnection= [[RapidWebServiceConnection alloc]init];
    
    if(self.itemInfoDataObject.arrItemAllBarcode == nil) {
        self.itemInfoDataObject.arrItemAllBarcode = [[NSMutableArray alloc] init ];
    }
    self.itemUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    isReceivedSel = TRUE;
    isImageSet = IsImageDeleted = FALSE;
    [self setArrayForDisplay];
    [self getPricingData];
    [self getItemMultipleBarcode];
    
    if(self.manualItemReceive.receivedItemId.integerValue==0){
        strReceiveItemMethod = @"AddManualEntryItem";
        strReceiveItemMethodResult = @"AddManualEntryItemResult";
    }
    else{
        strReceiveItemMethod = @"UpdateManualEntryItem";
        strReceiveItemMethodResult = @"UpdateManualEntryItemResult";
    }
    
    _btnReturn.selected = self.manualItemReceive.isReturn.boolValue;

    freeSingleValue = self.manualItemReceive.singleReceivedFreeGoodQty.stringValue;
    freeCaseValue =self.manualItemReceive.caseReceivedFreeGoodQty.stringValue;
    freePackValue = self.manualItemReceive.packReceivedFreeGoodQty.stringValue;
    
    freeSingleCost = self.manualItemReceive.freeGoodCost.stringValue;
    freeCaseCost = self.manualItemReceive.freeGoodCaseCost.stringValue;
    freePackCost = self.manualItemReceive.freeGoodPackCost.stringValue;
    
    itemPriceLocalArray = self.itemInfoDataObject.itemPricingArray;
    _btnReceived.selected = YES;
    
    colorSingle = [UIColor colorWithRed:0.137 green:0.439 blue:0.973 alpha:1.000];
    colorCase = [UIColor colorWithRed:0.945 green:0.000 blue:0.094 alpha:1.000];
    colorPack = [UIColor colorWithRed:0.933 green:0.561 blue:0.176 alpha:1.000];
    colorChanged = [UIColor colorWithRed:0.588 green:0.341 blue:0.533 alpha:1.000];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showItemSummary];
}

-(void)setArrayForDisplay{
    itemInfoSectionArray = [[NSMutableArray alloc] initWithObjects:@(ItemInfoSection),@(ItemPricingSection),@(DescriptionSection), nil];
    itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
}

#pragma mark - ibaction -

-(IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)isReturnClick:(id)sender{
    _btnReturn.selected = !_btnReturn.selected;
}
-(IBAction)changeTabView:(UIButton *)sender {
    _btnReceived.selected = NO;
    _btnFreeGoods.selected = NO;
    if ([sender isEqual:_btnReceived]) {
        isReceivedSel = TRUE;
        _btnReceived.selected = YES;
    }
    else {
        isReceivedSel = FALSE;
        _btnFreeGoods.selected = YES;
    }
    [_tblItemInfo reloadData];
}
#pragma mark - item Side info view -
-(void)showItemSummary {
    if(self.itemInfoSideVC == nil)
    {
        
        self.itemInfoSideVC = (DisplayItemInfoSideVC *)[[UIStoryboard storyboardWithName:@"RimStoryboard"
                                                                                  bundle:NULL] instantiateViewControllerWithIdentifier:@"DisplayItemInfoSideVC_sid"];
        NSMutableDictionary * dictChangeKey = self.itemInfoDataObject.itemMainInsertData;
        dictChangeKey[@"avaibleQty"] = dictChangeKey[@"availableQty"];
        self.itemInfoSideVC.itemInfoDictionary = dictChangeKey;
        self.itemInfoSideVC.view.frame = _viewItemSideInfo.bounds;
        self.itemInfoSideVC.displayItemInfoSideVCDeledate = self;
        [self addChildViewController:self.itemInfoSideVC];
        [_viewItemSideInfo addSubview:self.itemInfoSideVC.view];
    }
}

#pragma mark - UITextFieldDelegate -

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

#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return itemInfoSectionArray.count;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        if (tableView == self.tblItemInfo) {
            [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:0];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 44.0;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = @"";
    InfoSection InfoSection = [itemInfoSectionArray[section] integerValue];
    switch (InfoSection) {
            
        case ItemInfoSection:
            sectionTitle = @"ITEM INFORMATION";
            break;
            
        case ItemPricingSection:
            sectionTitle = @"VIEW PRICING INFORMATION";
            break;
            
        case DescriptionSection:
            sectionTitle = @"DESCRIPTION";
            break;
            
        default:
            break;
    }
    return [tableView defaultTableHeaderView:sectionTitle];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    InfoSection InfoSection = [itemInfoSectionArray[section] integerValue];
    switch (InfoSection) {
        case ItemInfoSection:
            return 3;
            break;
        case ItemPricingSection:
            return 6;
            break;
        
        case DescriptionSection:
            return 1;
            break;
        default:
            return 0;
            break;
    }
    return 1;
}


-(void)numberOfCellIsOnlyOne:(NSArray <UIView *> *)cellSubViews CellRect:(CGRect)bounds{
    for (UIView * subView in cellSubViews) {
        CGRect frame = subView.frame;
        frame.origin.y = 1;
        frame.size.height = bounds.size.height - 1;
        subView.frame = frame;
    }
}
-(void)numberOfCellIsFirst:(NSArray <UIView *> *)cellSubViews CellRect:(CGRect)bounds{
    for (UIView * subView in cellSubViews) {
        CGRect frame = subView.frame;
        frame.origin.y = 1;
        frame.size.height = bounds.size.height - 2;
        subView.frame = frame;
    }
}
-(void)numberOfCellIsLast:(NSArray <UIView *> *)cellSubViews CellRect:(CGRect)bounds{
    for (UIView * subView in cellSubViews) {
        CGRect frame = subView.frame;
        frame.origin.y = 0;
        frame.size.height = bounds.size.height - 1;
        subView.frame = frame;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    InfoSection InfoSection = [itemInfoSectionArray[indexPath.section] integerValue];
    switch (InfoSection) {
        case ItemInfoSection: // ItemInfo
            height = 55.0;
            break;
            
        case ItemPricingSection: // Pricing
            height = 55.0;
            break;
            
        case DescriptionSection: // Description
            height = 155.0;
            break;
            
        default:
            break;
    }
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    InfoSection InfoSection = [itemInfoSectionArray[indexPath.section] integerValue];
    switch (InfoSection) {
        case ItemInfoSection: // ItemInfo
            cell=[self configureItemInfoTableView:tableView indexPath:indexPath];
            break;
            
        case ItemPricingSection: // Pricing
            cell=[self configurePricingTableView:tableView indexPath:indexPath];
            break;
         
        case DescriptionSection: // Description
            cell=[self configureDescriptionTableView:tableView indexPath:indexPath];
            break;
            
        default:
            break;
    }

    return cell;
}

#pragma mark - custom cells -

- (UITableViewCell *)configureItemInfoTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell = nil;
    
    if(indexPath.row == 0){ // item name text field
        //        ItemInfoDisplayCell
        NSString * identifier=@"ItemInfoDisplayCell";
        ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.txtInputValue.placeholder = @"Item Name";
        cell.lblCellName.text = @"Item Name";

        cell.txtInputValue.text=[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemName];
        cell.txtInputValue.tag=ItemtextFieldsTagName;
        cell.btnValue.hidden=TRUE;
        return cell;
    }
    
    if(indexPath.row == 1) // item barcode text field
    {
        NSString * identifier=@"ItemInfoDisplaySwitchCell";
        ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.lblCellName.text = @"UPC / Barcode";
        cell.txtInputValue.tag=ItemtextFieldsTagBarCode;
        cell.txtInputValue.clearButtonMode = UITextFieldViewModeNever;
        cell.swiIsDuplicate.on = self.itemInfoDataObject.IsduplicateUPC;
        [cell.swiIsDuplicate addTarget: self action: @selector(allowDuplicateBarcodeClicked:) forControlEvents:UIControlEventValueChanged];
        cell.txtInputValue.text=@"";
        cell.btnValue.hidden=FALSE;
        [cell.btnValue removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [cell.btnValue addTarget:self action:@selector(moreBarcodeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnValue setTitle:self.itemInfoDataObject.Barcode forState:UIControlStateNormal];
        return cell;
    }
    if(indexPath.row == 2) // item number
    {
        NSString * identifier=@"ItemInfoDisplayCell";
        ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[ItemInfoDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.txtInputValue.placeholder = @"";
        cell.lblCellName.text = @"Item #";
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
        return cell;
    }
    return cell;
}

- (UITableViewCell *)configurePricingTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    //    ItemInfoPricingCell
    NSString * identifier=@"ItemInfoPricingCell";
    PricingSectionItem pricingSectionNo = [itemPricingSelection [indexPath.row] integerValue ];
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
    if (!isReceivedSel) {
        cell.contentView.userInteractionEnabled = FALSE;
    }
    else {
        cell.contentView.userInteractionEnabled = TRUE;
    }
    switch (pricingSectionNo) {
        case PricingSectionItemTitle: // Title
            [self configurePricingTitleCell:cell];
            break;
        case PricingSectionItemQty: // Quantity text field
            [self configurePricingQtyCell:cell];
            cell.contentView.userInteractionEnabled = TRUE;
            break;
        case PricingSectionItemCost: // cost text field
            [self configurePricingCostCell:cell];
            cell.contentView.userInteractionEnabled = TRUE;
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

- (UITableViewCell *)configureDescriptionTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
        NSString * identifier=@"ItemInfoDescriptionCell";
        ItemInfoDescriptionCell *cell=(ItemInfoDescriptionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil)
        {
            cell=[[ItemInfoDescriptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.lblCellName.text=@"REMARK";
        cell.txtVInputValue.tag=ItemDescSectionTagRemark;
        cell.txtVInputValue.text = self.itemInfoDataObject.Remark;
   
        return cell;
    
}

- (void)configurePricingTitleCell:(ItemInfoPricingCell *)cell
{
       if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        cell.imageBackGround.frame = CGRectMake(174, 0, 511, 44);
        cell.imageBackGround.image = [UIImage imageNamed:@"FormRowheaderBg.png"];
    }
}

- (void)configurePricingQtyCell:(ItemInfoPricingCell *)cell {
    cell.lblCellName.text = @"QTY OH";
    if (isReceivedSel) {
        cell.txtInputSingle.text = [NSString stringWithFormat:@"%@",(self.itemInfoDataObject.itemPricingArray[0])[@"ReceivedQty"]];
        cell.txtInputCase.text = [NSString stringWithFormat:@"%@",(self.itemInfoDataObject.itemPricingArray[1])[@"ReceivedQty"]];
        cell.txtInputPack.text = [NSString stringWithFormat:@"%@",(self.itemInfoDataObject.itemPricingArray[2])[@"ReceivedQty"]];
    }
    else {
        cell.txtInputSingle.text = freeSingleValue;
        cell.txtInputCase.text = freeCaseValue;
        cell.txtInputPack.text = freePackValue;
    }
    [self changeTaxtColorForQTYCellWithOldQTY:[(self.itemInfoDataObject.itemPricingArray[0])[@"ReceivedQty"] floatValue] withNewQTY:[(self.itemInfoDataObject.olditemPricingArray[0])[@"ReceivedQty"] floatValue] withFreeGodsQTY:freeSingleValue textField:cell.txtInputSingle];
    
    [self changeTaxtColorForQTYCellWithOldQTY:[(self.itemInfoDataObject.itemPricingArray[1])[@"ReceivedQty"] floatValue] withNewQTY:[(self.itemInfoDataObject.olditemPricingArray[1])[@"ReceivedQty"] floatValue] withFreeGodsQTY:freeCaseValue textField:cell.txtInputCase];
    
    [self changeTaxtColorForQTYCellWithOldQTY:[(self.itemInfoDataObject.itemPricingArray[2])[@"ReceivedQty"] floatValue] withNewQTY:[(self.itemInfoDataObject.olditemPricingArray[2])[@"ReceivedQty"] floatValue] withFreeGodsQTY:freePackValue textField:cell.txtInputPack];
    
}
- (void)changeTaxtColorForQTYCellWithOldQTY:(float)oldqty withNewQTY:(float)newqty withFreeGodsQTY:(NSString *)freeqty textField:(UITextField *)textField {
    if ((isReceivedSel && oldqty != newqty) || (!isReceivedSel && ![freeqty isEqualToString:@"0"])) {
        textField.textColor = [UIColor blueColor];
    }
    else{
        textField.textColor = [UIColor blackColor];
    }
}

- (void)configurePricingCostCell:(ItemInfoPricingCell *)cell{
    cell.lblCellName.text = @"COST";
    
    if (isReceivedSel) {
        
        cell.txtInputSingle.text = [self.rmsDbController getStringPriceFromFloat:[self.itemInfoDataObject.itemPricingArray[0][@"Cost"] floatValue]];
        cell.txtInputCase.text = [self.rmsDbController getStringPriceFromFloat:[self.itemInfoDataObject.itemPricingArray[1][@"Cost"] floatValue]];
        cell.txtInputPack.text = [self.rmsDbController getStringPriceFromFloat:[self.itemInfoDataObject.itemPricingArray[2][@"Cost"] floatValue]];
    }
    else {
        
        cell.txtInputSingle.text = [self.rmsDbController getStringPriceFromFloat:freeSingleCost.floatValue];
        cell.txtInputCase.text = [self.rmsDbController getStringPriceFromFloat:freeCaseCost.floatValue];
        cell.txtInputPack.text = [self.rmsDbController getStringPriceFromFloat:freePackCost.floatValue];
    }
    [self changeTaxtColorForQTYCellWithOldQTY:[(self.itemInfoDataObject.itemPricingArray[0])[@"Cost"] floatValue] withNewQTY:[(self.itemInfoDataObject.olditemPricingArray[0])[@"Cost"] floatValue] withFreeGodsQTY:freeSingleCost textField:cell.txtInputSingle];
    
    [self changeTaxtColorForQTYCellWithOldQTY:[(self.itemInfoDataObject.itemPricingArray[1])[@"Cost"] floatValue] withNewQTY:[(self.itemInfoDataObject.olditemPricingArray[1])[@"Cost"] floatValue] withFreeGodsQTY:freeCaseCost textField:cell.txtInputCase];
    
    [self changeTaxtColorForQTYCellWithOldQTY:[(self.itemInfoDataObject.itemPricingArray[2])[@"Cost"] floatValue] withNewQTY:[(self.itemInfoDataObject.olditemPricingArray[2])[@"Cost"] floatValue] withFreeGodsQTY:freePackCost textField:cell.txtInputPack];
    
}

- (void)configurePricingProfitCell:(ItemInfoPricingCell *)cell{
    
    cell.imageMarginMarkUp.hidden = NO;
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMarginMarkUp)];
    [cell addGestureRecognizer:gestureRight];
    if (self.itemInfoDataObject.rowSwitch) {
        cell.lblCellName.text=@"MARGIN";
        self.itemInfoDataObject.ProfitType = @"Margin";
        
        
        cell.txtInputSingle.text=[self calculateMarginCost:[[itemPriceLocalArray[0] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[0] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputSingle.text.floatValue != [(self.itemInfoDataObject.olditemPricingArray[0])[@"Profit"] floatValue]) {
            cell.txtInputSingle.textColor = [UIColor blueColor];
        }
        else{
            cell.txtInputSingle.textColor = [UIColor blackColor];
        }
        
        cell.txtInputCase.text=[self calculateMarginCost:[[itemPriceLocalArray[1] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[1] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputCase.text.floatValue != [(self.itemInfoDataObject.olditemPricingArray[1])[@"Profit"] floatValue]) {
            cell.txtInputCase.textColor = [UIColor blueColor];
        }
        else{
            cell.txtInputCase.textColor = [UIColor blackColor];
        }
        
        cell.txtInputPack.text=[self calculateMarginCost:[[itemPriceLocalArray[2] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[2] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputPack.text.floatValue != [(self.itemInfoDataObject.olditemPricingArray[2])[@"Profit"] floatValue]) {
            cell.txtInputPack.textColor = [UIColor blueColor];
        }
        else{
            cell.txtInputPack.textColor = [UIColor blackColor];
        }
        
        gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        
        cell.imageMarginMarkUp.image = [UIImage imageNamed:@"markupMarginArrowRight.png"];
    } else {
        gestureRight.direction = UISwipeGestureRecognizerDirectionLeft;
        self.itemInfoDataObject.ProfitType = @"MarkUp";
        cell.lblCellName.text=@"MARKUP";
        cell.imageMarginMarkUp.image = [UIImage imageNamed:@"markupMarginArrowLeft.png"];
        
        cell.txtInputSingle.text=[self calculateMarkUpCost:[[itemPriceLocalArray[0] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[0] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputSingle.text.floatValue != [(self.itemInfoDataObject.olditemPricingArray[0])[@"Profit"] floatValue]) {
            cell.txtInputSingle.textColor = [UIColor blueColor];
        }
        else{
            cell.txtInputSingle.textColor = [UIColor blackColor];
        }
        cell.txtInputCase.text=[self calculateMarkUpCost:[[itemPriceLocalArray[1] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[1] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputCase.text.floatValue != [(self.itemInfoDataObject.olditemPricingArray[1])[@"Profit"] floatValue]) {
            cell.txtInputCase.textColor = [UIColor blueColor];
        }
        else{
            cell.txtInputCase.textColor = [UIColor blackColor];
        }
        
        cell.txtInputPack.text=[self calculateMarkUpCost:[[itemPriceLocalArray[2] valueForKey:@"Cost"] floatValue] Sales:[[itemPriceLocalArray[2] valueForKey:@"UnitPrice"] floatValue]];
        if (cell.txtInputPack.text.floatValue != [(self.itemInfoDataObject.olditemPricingArray[2])[@"Profit"] floatValue]) {
            cell.txtInputPack.textColor = [UIColor blueColor];
        }
        else{
            cell.txtInputPack.textColor = [UIColor blackColor];
        }
    }
}

- (void)configurePricingSalesCell:(ItemInfoPricingCell *)cell{
    
    cell.lblCellName.text=@"PRICE";
    [self SetValueItemInfoPricingCell:cell withCellKey:@"UnitPrice"];
}
-(void)SetValueItemInfoPricingCell:(ItemInfoPricingCell *)cell withCellKey:(NSString *)key{

    cell.txtInputSingle.text = [self.rmsDbController getStringPriceFromFloat:[[itemPriceLocalArray[0] valueForKey:key] floatValue]];
    if ([[itemPriceLocalArray[0] valueForKey:key] floatValue ] != [[self.itemInfoDataObject.olditemPricingArray[0] valueForKey:key] floatValue ]) {
        cell.txtInputSingle.textColor = [UIColor blueColor];
    }
    else{
        cell.txtInputSingle.textColor = [UIColor blackColor];
    }
    
    cell.txtInputCase.text = [self.rmsDbController getStringPriceFromFloat:[[itemPriceLocalArray[1] valueForKey:key] floatValue]];
    if ([[itemPriceLocalArray[1] valueForKey:key] floatValue ] != [[self.itemInfoDataObject.olditemPricingArray[1] valueForKey:key] floatValue ]) {
        cell.txtInputCase.textColor = [UIColor blueColor];
    }
    else{
        cell.txtInputCase.textColor = [UIColor blackColor];
    }
    
    cell.txtInputPack.text = [self.rmsDbController getStringPriceFromFloat:[[itemPriceLocalArray[2] valueForKey:key] floatValue]];
    if ([[itemPriceLocalArray[2] valueForKey:key] floatValue ] != [[self.itemInfoDataObject.olditemPricingArray[2] valueForKey:key] floatValue ]) {
        cell.txtInputPack.textColor = [UIColor blueColor];
    }
    else{
        cell.txtInputPack.textColor = [UIColor blackColor];
    }
}
- (void)configurePricingNoOfItemCell:(ItemInfoPricingCell *)cell{
    cell.lblCellName.text=@"# OF QTY";
    NSString * key = @"Qty";
    NSNumber *dCost = @([[itemPriceLocalArray[0] valueForKey:key] floatValue ]);
    cell.txtInputSingle.text = [NSString stringWithFormat:@"%@",dCost];
    cell.txtInputSingle.userInteractionEnabled=FALSE;
    
    dCost = @([[itemPriceLocalArray[1] valueForKey:key] floatValue ]);
    cell.txtInputCase.text = [NSString stringWithFormat:@"%@",dCost];
    
    dCost = @([[itemPriceLocalArray[2] valueForKey:key] floatValue ]);
    cell.txtInputPack.text = [NSString stringWithFormat:@"%@",dCost];
}

- (void)configureItemUnitQty_Unit:(ItemInfoPricingCell *)cell{
    cell.lblCellName.text=@"Unit Qty & Unit";
    
    NSString * key = @"UnitQty";
    cell.txtInputSingle.text = [NSString stringWithFormat:@"%@",[itemPriceLocalArray[0] valueForKey:key]];
    
    cell.txtInputCase.text = [NSString stringWithFormat:@"%@",[itemPriceLocalArray[1] valueForKey:key]];
    
    cell.txtInputPack.text = [NSString stringWithFormat:@"%@",[itemPriceLocalArray[2] valueForKey:key]];
    
    key = @"UnitType";
    
    cell.lblInputSingle.text = [NSString stringWithFormat:@"%@",[itemPriceLocalArray[0] valueForKey:key]];
    
    cell.lblInputCase.text = [NSString stringWithFormat:@"%@",[itemPriceLocalArray[1] valueForKey:key]];
    
    cell.lblInputPack.text = [NSString stringWithFormat:@"%@",[itemPriceLocalArray[2] valueForKey:key]];
}
#pragma mark - BarCode -
-(void)getItemMultipleBarcode{
    NSManagedObjectContext *context = self.managedObjectContext;
    Item *anItem = [self fetchAllItems:[NSString stringWithFormat:@"%@",(self.itemInfoDataObject.ItemId).stringValue] moc:context];
    self.itemInfoDataObject.arrItemAllBarcode = [[NSMutableArray alloc]init];
    for (ItemBarCode_Md *barcode in anItem.itemBarcodes) {
        if([barcode.isBarcodeDeleted  isEqual: @(0)]) {
            NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
            barcodeDict[@"Barcode"] = barcode.barCode;
            barcodeDict[@"PackageType"] = barcode.packageType;
            barcodeDict[@"IsDefault"] = barcode.isDefault;
            barcodeDict[@"isExist"] = @"";
            barcodeDict[@"notAllowItemCode"] = @"";
            if([barcode.isDefault  isEqual: @(1)]) {
                self.itemInfoDataObject.Barcode = barcode.barCode;
            }
            [self.itemInfoDataObject.arrItemAllBarcode addObject:barcodeDict];
        }
    }
    [self.itemInfoDataObject createDuplicateItemBarcodeArray];
}
- (IBAction)allowDuplicateBarcodeClicked:(UISwitch * )sender{
    [self.rmsDbController playButtonSound];
    if(sender.isOn){
        self.itemInfoDataObject.IsduplicateUPC = YES;
    }
    else{
        self.itemInfoDataObject.IsduplicateUPC = NO;
    }
    NSDictionary *allowDuplicateBarcodeDict = @{kRIMItemAllowDuplicateBarcodeKey : @(self.itemInfoDataObject.IsduplicateUPC)};
    [Appsee addEvent:kRIMItemAllowDuplicateBarcode withProperties:allowDuplicateBarcodeDict];
}

-(IBAction)moreBarcodeClicked:(id)sender{
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
}
-(void)checkBarcodeArrayIsAlloc{
    if(self.itemInfoDataObject.arrItemAllBarcode == nil) {
        self.itemInfoDataObject.arrItemAllBarcode = [[NSMutableArray alloc] init ];
    }
}
- (void)didUpdateMultipleBarcode:(NSMutableArray *)itemBarcodes allowToItems:(NSString *)allowToItems {
    self.itemInfoDataObject.arrItemAllBarcode = itemBarcodes;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"IsDefault == %@",@"1"];
    NSMutableDictionary * dictDefault = [[itemBarcodes filteredArrayUsingPredicate:predicate] firstObject];
    
    self.itemInfoDataObject.Barcode = dictDefault[@"Barcode"];
    
    self.itemInfoDataObject.duplicateUPCItemCodes = allowToItems;
    [self.tblItemInfo reloadData];
}
#pragma mark UIImagePickerController Delegate Method

-(void)takePhoto{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerCamera = [[UIImagePickerController alloc] init];
        pickerCamera.delegate = self;
        pickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerCamera animated:YES completion:nil];
    }
    else{
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Camera not available" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    self.itemInfoDataObject.selectedImage = info[UIImagePickerControllerOriginalImage];
    NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
    
    NSData *selectedImageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0);
    if(selectedImageData) {
        itemData[@"ItemImage"] = [selectedImageData base64EncodedStringWithOptions:0];
    }
    else{
        itemData[@"ItemImage"] = @"";
    }
//    self.itemInfoDataObject.ItemImage = [itemData valueForKey:@"ItemImage"];
    
    [self setItemImageReloadSideInfoView:(UIImage *)self.itemInfoDataObject.selectedImage withImageUrl:@""];
    
    isImageSet = TRUE;
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    pickerCamera = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Item Image Selection -
-(void)willChangeItemSelectedImage:(UIButton *)sender{
    [self selectImageCapture:sender];
}
-(void)selectImageCapture:(UIButton *)sender{
    [Appsee addEvent:kRIMItemImage];
    UIButton *button;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        button = sender;
    }
    UIAlertController *popup = [UIAlertController alertControllerWithTitle:@"Select option:" message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* takephoto = [UIAlertAction actionWithTitle:@"Take A Photo" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [Appsee addEvent:kRIMItemTakeAPhoto];
                                                          [self takePhoto];
                                                          [popup dismissViewControllerAnimated:YES completion:nil];
                                                      }];
    
    UIAlertAction *chooseExisting = [UIAlertAction actionWithTitle:@"Choose Existing" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [Appsee addEvent:kRIMItemChooseExisting];
                                                               btnCameraClick = [[UIButton alloc] initWithFrame:CGRectMake(840, 120, 64, 64)];
                                                               imagePicker = [[UIImagePickerController alloc] init];
                                                               imagePicker.delegate = self;
                                                               imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                               
                                                               // Present the view controller using the popover style.
                                                               imagePicker.modalPresentationStyle = UIModalPresentationPopover;
                                                               [self presentViewController:imagePicker animated: YES completion: nil];
                                                               
                                                               // Get the popover presentation controller and configure it.
                                                               presentationController = [imagePicker popoverPresentationController];
                                                               presentationController.delegate = self;
                                                               presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                                                               presentationController.sourceView = self.view;
                                                               presentationController.sourceRect = btnCameraClick.frame;
                                                               
                                                               [popup dismissViewControllerAnimated:YES completion:nil];
                                                           }];
    
    UIAlertAction *internet = [UIAlertAction actionWithTitle:@"Internet" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [Appsee addEvent:kRIMItemInternet];
                                                        
                                                         itemImageSelectionVC =
                                                         [[UIStoryboard storyboardWithName:@"Main"
                                                                                    bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemImageSelectionVC_sid"];
                                                         
                                                         itemImageSelectionVC.itemSelctionImageChangedVCDelegate = self;
                                                         itemImageSelectionVC.strSearchText = self.itemInfoDataObject.ItemName;
                                                         btnCameraClick = [[UIButton alloc] initWithFrame:CGRectMake(840, 120, 64, 64)];
                                                         
                                                         // Present the view controller using the popover style.
                                                         itemImageSelectionVC.modalPresentationStyle = UIModalPresentationPopover;
                                                         [self presentViewController:itemImageSelectionVC animated: YES completion: nil];
                                                         
                                                         // Get the popover presentation controller and configure it.
                                                         presentationController = [itemImageSelectionVC popoverPresentationController];
                                                         presentationController.delegate = self;
                                                         presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                                                         presentationController.sourceView = self.view;
                                                         presentationController.sourceRect = btnCameraClick.frame;
                                                         
                                                         [popup dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    UIAlertAction* removeImage = [UIAlertAction actionWithTitle:@"Remove Image" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            [Appsee addEvent:kRIMItemRemoveImage];
                                                            
                                                            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action) {
                                                                [Appsee addEvent:kRIMItemRemoveImageCancel];
                                                            };
                                                            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                                                                [Appsee addEvent:kRIMItemRemoveImageDone];
                                                                self.itemInfoDataObject.selectedImage = nil;
                                                                [self setItemImageReloadSideInfoView:nil withImageUrl:@""];
                                                                self.itemInfoDataObject.imageNameURL = @"";
                                                                IsImageDeleted = TRUE;
                                                            };
                                                            [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Are you sure you want to remove item image ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                                                            [popup dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    
    [popup addAction:takephoto];
    [popup addAction:chooseExisting];
    [popup addAction:internet];
    [popup addAction:removeImage];
    
    UIPopoverPresentationController *popPresenter = popup.popoverPresentationController;
    popPresenter.sourceView = button;
    popPresenter.sourceRect = button.bounds;
    popPresenter.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self presentViewController:popup animated:YES completion:nil];
}
-(void)itemImageChangeNewImage:(UIImage *)image withImageUrl:(NSString *)imageUrl {
    isImageSet = TRUE;
    [self setItemImageReloadSideInfoView:image withImageUrl:imageUrl];
    [itemImageSelectionVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)setItemImageReloadSideInfoView:(UIImage *)image withImageUrl:(NSString *)strImageUrl{
    NSMutableDictionary *dictItemInfo = [[NSMutableDictionary alloc]initWithDictionary:self.itemInfoSideVC.itemInfoDictionary];
    if (image) {
        dictItemInfo[@"ItemImage"] = image;
    }
    else{
        dictItemInfo[@"ItemImage"] = @"";
    }
    [self.itemInfoSideVC didUpdateItemInfo:dictItemInfo];
     self.itemInfoDataObject.selectedImage = image;
    
}
#pragma mark - price calcula -
-(UITextField *)currentEditingView{
    return currentEditing;
}
-(void)setCurrentEdintingViewWithTextField:(UITextField *)textField{
    currentEditing=textField;
}
-(int)willGetOfQtyValueForQtyOH:(int)IndexNumber;{
    int Qty=[[itemPriceLocalArray[IndexNumber] valueForKey:@"Qty"] intValue];
    return Qty;
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
-(void)didPriceChangeOfInputWeight:(NSNumber *)inputValue InputWeightUnit:(NSString *)weightUnit  ValueIndex:(int)IndexNumber{
    
}
-(void)didPriceChangeOfMarkUPValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber{
    NSMutableArray * arrCalculation;
//    if(self.itemInfoDataObject.isPricingLevelSelected) {
        arrCalculation=self.itemInfoDataObject.itemPricingArray;
//    }
//    else{
//        arrCalculation=self.itemInfoDataObject.itemWeightScaleArray;
//    }
    float cost = [[arrCalculation[IndexNumber] valueForKey:@"Cost"] floatValue];
    float Pirce=(cost*inputValue.floatValue)/100;
    Pirce=Pirce+cost;
    [self didPriceChangeForMargin:PricingSectionItemSales inputValue:@(Pirce) ValueIndex:IndexNumber];
}

-(void)didPriceChangeOf:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber{
    if (PriceValueType==PricingSectionItemProfit && !self.itemInfoDataObject.rowSwitch) {
        [self didPriceChangeOfMarkUPValue:inputValue ValueIndex:IndexNumber];
    }
    else{
        [self didPriceChangeForMargin:PriceValueType inputValue:inputValue ValueIndex:IndexNumber];
    }

}
-(void)didPriceChangeForMargin:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber{
    NSMutableArray * arrCalculation = self.itemInfoDataObject.itemPricingArray;
    //  NSMutableArray * indexArray;
    NSString * strKey=@"";
    switch (PriceValueType) {
        case PricingSectionItemQty:{
            if (isReceivedSel) {
                (self.itemInfoDataObject.itemPricingArray[IndexNumber])[@"ReceivedQty"] = [NSString stringWithFormat:@"%d",inputValue.intValue];
            }
            else {
                switch (IndexNumber) {
                    case 0:
                        freeSingleValue = [NSString stringWithFormat:@"%d",inputValue.intValue];
                        break;
                    case 1:
                        freeCaseValue = [NSString stringWithFormat:@"%d",inputValue.intValue];
                        break;
                    case 2:
                        freePackValue = [NSString stringWithFormat:@"%d",inputValue.intValue];
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case PricingSectionItemCost:{
            //   strKey=@"Cost";
            
            if (isReceivedSel) {
                (self.itemInfoDataObject.itemPricingArray[IndexNumber])[@"Cost"] = [NSString stringWithFormat:@"%d",inputValue.intValue];
                [self ChangeCostInCasePackNewCost:inputValue ValueIndex:IndexNumber priceList:arrCalculation];
                
            }
            else {
                switch (IndexNumber) {
                    case 0:{
                        [self setFreeGoodCostValueChangeWithSingleCost:inputValue];
                        break;
                    }
                    case 1:{
                        float freeGoodCase = [self.itemInfoDataObject.itemPricingArray[1][@"Qty"] integerValue];
                        if (freeGoodCase > 0)
                        {
                            [self setFreeGoodCostValueChangeWithSingleCost:@(inputValue.floatValue/freeGoodCase)];
                        }
                        break;
                    }
                    case 2:{
                        float freeGoodPack = [self.itemInfoDataObject.itemPricingArray[2][@"Qty"] integerValue];
                        if (freeGoodPack > 0)
                        {
                            [self setFreeGoodCostValueChangeWithSingleCost:@(inputValue.floatValue/freeGoodPack)];
                        }
                        break;
                    }
                }
            }
            //
            //            NSUInteger reloadedRow=[itemPricingSelection indexOfObject:@(PricingSectionItemProfit)];
            //            [indexArray addObject:[NSIndexPath indexPathForRow:reloadedRow inSection:2]];
            break;
        }
        case PricingSectionItemProfit:
            strKey=@"";
            [self ChangeItemMarginNewMargin:inputValue ValueIndex:IndexNumber priceList:arrCalculation];
            break;
        case PricingSectionItemSales:
            strKey=@"UnitPrice";
            [self ChangeItemPriceNewPrice:inputValue ValueIndex:IndexNumber priceList:arrCalculation];
            if (IndexNumber==0) {
                self.itemInfoDataObject.SalesPrice = inputValue;
            }
            break;
        case PricingSectionItemNoOfQty:
            strKey=@"Qty";
            int packNoOfQTY = [arrCalculation[2][@"Qty"] intValue];
            int caseNoOfQTY = [arrCalculation[1][@"Qty"] intValue];
            if(IndexNumber == 1 && packNoOfQTY != 0){
                if (packNoOfQTY == inputValue.intValue) {
                    //                    strKey=@"";
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"# of Qty of Cash,Pack could not be same." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    return;
                }
            }
            else if(IndexNumber == 2 && caseNoOfQTY != 0){
                if (caseNoOfQTY == inputValue.intValue) {
                    //                    strKey=@"";
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"# of Qty of Cash,Pack could not be same." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    return;
                }
            }
            [self ChangeItemQtyNewQty:inputValue ValueIndex:IndexNumber priceList:arrCalculation];
            break;
        case PricingSectionItemUnitQty_Unit:
            strKey=@"";
            break;
        default:
            break;
    }
    if (![strKey isEqualToString:@""]) {
        if (PriceValueType == PricingSectionItemNoOfQty) {
            (arrCalculation[IndexNumber])[strKey] = [NSString stringWithFormat:@
                                                     "%d",inputValue.intValue];
        }
        else{
            (arrCalculation[IndexNumber])[strKey] = [NSString stringWithFormat:@
                                                     "%.2f",inputValue.floatValue];
        }
    }
    [_tblItemInfo reloadData];
}
-(void)setFreeGoodCostValueChangeWithSingleCost:(NSNumber *)inputValue {
    freeSingleCost = [NSString stringWithFormat:@"%.2f",inputValue.floatValue];
    
    float oneQtyCost = [self.itemInfoDataObject.itemPricingArray[1][@"Qty"] integerValue];
    freeCaseCost = [NSString stringWithFormat:@"%.2f",(float)inputValue.floatValue*oneQtyCost];
    
    float oneQtyPack = [self.itemInfoDataObject.itemPricingArray[2][@"Qty"] integerValue];
    freePackCost = [NSString stringWithFormat:@"%.2f",(float)inputValue.floatValue*oneQtyPack];

}
//-(void)didPriceChangeOfMarkUPValue:(CGFloat)inputValue ValueIndex:(int)IndexNumber{
//    NSMutableArray * arrCalculation;
//    if(self.itemInfoDataObject.isPricingLevelSelected) {
//        arrCalculation=self.itemInfoDataObject.itemPricingArray;
//    }
//    else{
//        arrCalculation=self.itemInfoDataObject.itemWeightScaleArray;
//    }
//    float cost = [[arrCalculation[IndexNumber] valueForKey:@"Cost"] floatValue];
//    float Pirce=(cost*inputValue)/100;
//    Pirce=Pirce+cost;
//    [self didPriceChangeOf:PricingSectionItemSales inputValue:Pirce ValueIndex:IndexNumber];
//}
-(void)ChangeCostInCasePackNewCost:(NSNumber *)newCost ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    
    float oneQtyCost=newCost.floatValue/[arrPriceList[IndexNumber][@"Qty"] floatValue];
    if (isnan(oneQtyCost) || isinf(oneQtyCost)) {
        oneQtyCost = 0;
    }
    (arrPriceList[0])[@"Cost"] = @(oneQtyCost);
    
    self.itemInfoDataObject.CostPrice = @(oneQtyCost);
    [self ChangeItemCostNewCost:oneQtyCost ValueIndex:0 priceList:arrPriceList];
    float caseCost=oneQtyCost*[arrPriceList[1][@"Qty"] floatValue];
    (arrPriceList[1])[@"Cost"] = @(caseCost);
    [self ChangeItemCostNewCost:caseCost ValueIndex:1 priceList:arrPriceList];
    
    float packCost=oneQtyCost*[arrPriceList[2][@"Qty"] floatValue];
    (arrPriceList[2])[@"Cost"] = @(packCost);
    
    [self ChangeItemCostNewCost:packCost ValueIndex:2 priceList:arrPriceList];
}
-(void)ChangeItemCostNewCost:(float)newCost ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    float margin;
    float Profit = [[arrPriceList[IndexNumber] valueForKey:@"UnitPrice"] floatValue]-newCost;
    float price = [[arrPriceList[IndexNumber] valueForKey:@"UnitPrice"] floatValue];
    margin=Profit/price;
    margin = margin*100;
    if (isnan(margin) || isinf(margin)) {
        margin = 0;
    }

    (arrPriceList[IndexNumber])[@"Profit"] = @(margin);
    if (IndexNumber==0) {
        self.itemInfoDataObject.ProfitAmt = @(margin);
    }
}
-(void)ChangeItemMarginNewMargin:(NSNumber *)newMargin ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    float price;
    float cost= [[arrPriceList[IndexNumber] valueForKey:@"Cost"] floatValue];
    price=cost/((100-newMargin.floatValue)/100);
    (arrPriceList[IndexNumber])[@"UnitPrice"] = @(price);
    if (IndexNumber==0) {
        self.itemInfoDataObject.SalesPrice = @(price);
    }
}
-(void)ChangeItemPriceNewPrice:(NSNumber *)newPrice ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    float margin;
    float Profit = newPrice.floatValue-[[arrPriceList[IndexNumber] valueForKey:@"Cost"] floatValue];
    
    margin=Profit/newPrice.floatValue;
    margin=margin*100;

    if (isnan(margin) || isinf(margin)) {
        margin = 0;
    }
    (arrPriceList[IndexNumber])[@"Profit"] = @(margin);
    if (IndexNumber == 0) {
        self.itemInfoDataObject.ProfitAmt = @(margin);
    }
}
-(void)ChangeItemQtyNewQty:(NSNumber *)newQty ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    
    float cost = [[arrPriceList[0] valueForKey:@"Cost"] floatValue];
    cost=cost*newQty.intValue;
    
    float profit=[[arrPriceList[IndexNumber] valueForKey:@"Profit"] floatValue];
    if (profit == 0 && IndexNumber>0) {
        float margin;
        float Profit = [[arrPriceList[0] valueForKey:@"UnitPrice"] floatValue]-[[arrPriceList[0] valueForKey:@"Cost"] floatValue];
        float price = [[arrPriceList[0] valueForKey:@"UnitPrice"] floatValue];
        margin=Profit/price;

        if (isnan(margin) || isinf(margin)) {
            margin = 0;
        }
        if(newQty.intValue == 0) {
            (arrPriceList[IndexNumber])[@"Profit"] = @0;
            (self.itemInfoDataObject.itemPricingArray[IndexNumber])[@"ReceivedQty"] = @0.0f;
        }
        else{
            (arrPriceList[IndexNumber])[@"Profit"] = @(margin*100);
        }
        price=cost/((100-margin*100)/100);
        if (isnan(price) || isinf(price)) {
            price = 0;
        }
        (arrPriceList[IndexNumber])[@"UnitPrice"] = @(price);
        (arrPriceList[IndexNumber])[@"Cost"] = @(cost);
    }
    else {
        float Markgin=(100-profit)/100;
        if (isnan(Markgin) || isinf(Markgin)) {
            Markgin = 0;
        }
        float price=cost/Markgin;
        if (isnan(price) || isinf(price)) {
            price = 0;
        }
        
        (arrPriceList[IndexNumber])[@"Cost"] = @(cost);
        (arrPriceList[IndexNumber])[@"UnitPrice"] = @(price);
        if(newQty.intValue == 0) {
            (arrPriceList[IndexNumber])[@"Profit"] = @0;
            (self.itemInfoDataObject.itemPricingArray[IndexNumber])[@"ReceivedQty"] = @0.0f;
        }
    }
}
#pragma mark - save in Inventory item -
-(IBAction)btnSaveClick:(id)sender{
    [self.view endEditing:YES];
    if([NSString trimSpacesFromStartAndEnd:self.itemInfoDataObject.ItemName].length == 0) {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Please enter item name" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];

        return;
    }

    if (self.itemInfoDataObject.changeInfoInManualItem || isImageSet || IsImageDeleted) {
        [self itemDetailUpdate];
    }
    else {
        [self insertItemInManualEntery];
    }
}

-(void)itemDetailUpdate{
     _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictItePara = [self getItemUpdateData];
    NSLog(@"%@",[self.rmsDbController jsonStringFromObject:dictItePara]);

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self itemUpdateProcessVCResponse:response error:error];
    };
    
    self.itemUpdateWebServiceConnection = [self.itemUpdateWebServiceConnection initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItePara completionHandler:completionHandler];
}
- (void) itemUpdateProcessVCResponse:(id)response error:(NSError *)error{
    
    if (response != nil) {
       
         if ([response isKindOfClass:[NSDictionary class]]) {
        
             if ([[response valueForKey:@"IsError"] intValue] == 0) {
                 [self doUpdateForItemUpdate];
             }
             else if ([[response  valueForKey:@"IsError"] intValue] == -2) {
                 NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n UPC is already exists"};
                 [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                 
                 [_activityIndicator hideActivityIndicator];
                 UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                 };
                 [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Error code : 104 \n UPC is already exists" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                 self.itemInfoDataObject.Barcode = @"";
             }
             else{
                 NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                 [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                 
                 [_activityIndicator hideActivityIndicator];
                 UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                 };
                 [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Error code : 104 \n Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
             }
         }
         else{
             
             UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
             {
                 
             };
             UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
             {
                 [self itemDetailUpdate];
             };
             [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Your request is not processed successfully, Plz try again." buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
         }
    }

}
-(void)updateDataInDataBase_RIM{
    
    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
    [itemLiveUpdate setValue:@"Update" forKeyPath:@"Action"];
    [itemLiveUpdate setValue:self.itemInfoDataObject.ItemId forKey:@"Code"];
    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
    [itemLiveUpdate setValue:@"Item" forKey:@"Type"];
    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
}
-(NSMutableDictionary *)getItemUpdateData{
    NSMutableDictionary * addItemDataDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * itemDetails = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    NSMutableArray * arrItemMain = [self itemMain];
    itemDetailDict[@"ItemMain"] = arrItemMain;
    
    [self addAndDeleteBarcodeDetail:itemDetailDict];
    
    [self itemPriceingAndItemVariationsData:itemDetailDict];
    
    [self setItemTaxData:itemDetailDict];
    
    [self setItemSupplierData:itemDetailDict];
    
    [self setItemTagData:itemDetailDict];
    
    
    [self setitemDiscountData:itemDetailDict];
    
    itemDetailDict[@"ItemTicketArray"] = [[NSArray alloc]init];
    
    [itemDetails addObject:itemDetailDict];
    addItemDataDic[@"ItemData"] = itemDetails;
    
    return addItemDataDic;
}
-(NSMutableArray *)itemMain{
    NSMutableArray *itemMain = [[NSMutableArray alloc] init];
    NSMutableDictionary * itemDataDict;
    itemDataDict = self.itemInfoDataObject.itemInfoDataForManual;
    
    itemDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    itemDataDict[@"UserId"] = userID;
    
    
    if(isImageSet) {
        NSData * imageData = UIImageJPEGRepresentation(self.itemInfoDataObject.selectedImage, 0);
        if(imageData) {
            itemDataDict[@"ItemImage"] = [imageData base64EncodedStringWithOptions:0];
        }
    }
    if (IsImageDeleted) {
        itemDataDict[@"IsImageDeleted"] = @(IsImageDeleted);
    }
    NSArray * arrKeys = itemDataDict.allKeys;
    for (NSString * strKey in arrKeys) {
        [itemMain addObject:@{@"Key":strKey,@"Value":[itemDataDict valueForKey:strKey]}];
    }
    return itemMain;
}
-(void)addAndDeleteBarcodeDetail:(NSMutableDictionary *)itemDetailDict{
    itemDetailDict[@"AddedBarcodesArray"] = self.itemInfoDataObject.arrAddedBarcodeList;
    itemDetailDict[@"DeletedBarcodesArray"] = self.itemInfoDataObject.arrDeletedBarcodeList;
}
-(void)itemPriceingAndItemVariationsData:(NSMutableDictionary *)itemDetailDict{
    
    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString * staDate = [formatter stringFromDate:date];
    itemDetailDict[@"Updatedate"] = staDate;
    
    //        ItemPriceSingle
    itemDetailDict[@"ItemPriceSingle"] = [self.itemInfoDataObject getManualPricingDataAt:0];
    //        ItemPriceCase
    itemDetailDict[@"ItemPriceCase"] = [self.itemInfoDataObject getManualPricingDataAt:1];
    //        ItemPricePack
    itemDetailDict[@"ItemPricePack"] = [self.itemInfoDataObject getManualPricingDataAt:2];
    
    itemDetailDict[@"VariationArray"] = [[NSArray alloc]init];
    itemDetailDict[@"VariationItemArray"] = [[NSArray alloc]init];

}
- (void)setItemTaxData :(NSMutableDictionary *) itemDetailDict {
//        addedItemTaxData
    itemDetailDict[@"addedItemTaxData"] = [[NSArray alloc]init];
//        DeletedItemTaxData
    itemDetailDict[@"DeletedItemTaxIds"] = @"";
}
- (void)setItemSupplierData :(NSMutableDictionary *)itemDetailDict{
    //        addedItemSupplierData
    itemDetailDict[@"addedItemSupplierData"] = [[NSArray alloc]init];
    //        DeletedItemSupplierData
    itemDetailDict[@"DeletedItemSupplierData"] = @"";
}
- (void)setItemTagData:(NSMutableDictionary *) itemDetailDict{
    //        addedItemTag
    itemDetailDict[@"addedItemTag"] = [[NSArray alloc]init];
    //        DeletedItemTag
    itemDetailDict[@"DeletedItemTagIds"] = @"";
}

- (void)setitemDiscountData:(NSMutableDictionary *)itemDetailDict {
    //        addedItemDiscount
    itemDetailDict[@"addedItemDiscount"] = [[NSArray alloc]init];
    //        DeletedItemDiscount
    itemDetailDict[@"DeletedItemDiscountIds"] = @"";

}
-(void)doUpdateForItemUpdate{
    
    //_activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    self.itemUpdateConnnection = [[RapidWebServiceConnection alloc]init];
    
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:[self.rmsDbController.globalDict valueForKey:@"BranchID"] forKey:@"BranchId"];
    NSString *strDate = [self.rmsDbController ludForTimeInterval:0];
    [itemparam setValue:strDate forKey:@"datetime"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self ManualItemLiveUpdateResponse:response error:error];
    };
    
    self.itemUpdateConnnection = [self.itemUpdateConnnection initWithRequest:KURL actionName:WSM_ITEM_UPDATE_LIST params:itemparam completionHandler:completionHandler];
    
}

- (void)ManualItemLiveUpdateResponse:(id)response error:(NSError *)error
{
   // [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if(responseData.count > 0)
                {
                    NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                    
                    [self.itemUpdateManager liveUpdateFromResponseDictionary:responseDictionary];
                    [self insertItemInManualEntery];
                }
            }
            else if([[response valueForKey:@"IsError"] intValue] == -1)
            {
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            
        }
    }
}

#pragma mark - save in Inventory item -
-(void)insertItemInManualEntery {
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:self.manualPoID forKey:@"ManualEntryId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"CreatedBy"];
    
    if(self.manualItemReceive.receivedItemId.integerValue == 0){
        
        NSDate *currentDate = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
        NSString *currentDateValue = [formatter stringFromDate:currentDate];
        [param setValue:currentDateValue forKey:@"LocalDate"];
        
    }
    
    [param setValue:self.itemInfoDataObject.ItemId forKey:@"ItemCode"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[0] [@"ReceivedQty"] forKey:@"SingleReceivedQty"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[1] [@"ReceivedQty"] forKey:@"CaseReceivedQty"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[2] [@"ReceivedQty"] forKey:@"PackReceivedQty"];
    
    [param setValue:self.itemInfoDataObject.itemPricingArray[0] [@"Cost"] forKey:@"Cost"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[0] [@"UnitPrice"] forKey:@"Price"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[0] [@"Profit"] forKey:@"MarkUp"];
    
    [param setValue:self.itemInfoDataObject.itemPricingArray[1] [@"Cost"] forKey:@"CaseCost"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[1] [@"UnitPrice"] forKey:@"CasePrice"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[2] [@"Cost"] forKey:@"PackCost"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[2] [@"UnitPrice"] forKey:@"PackPrice"];
    
    [param setValue:self.itemInfoDataObject.itemPricingArray[0] [@"Qty"] forKey:@"SingleOnHandQty"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[1] [@"Qty"] forKey:@"CaseOnHandQty"];
    [param setValue:self.itemInfoDataObject.itemPricingArray[2] [@"Qty"] forKey:@"PackOnHandQty"];
    
    if(_btnReturn.selected)
    {
        [param setValue:@"1" forKey:@"IsReturn"];
    }
    else{
        [param setValue:@"0" forKey:@"IsReturn"];
    }
    
    if(freeSingleValue.integerValue>0 || freeCaseValue.integerValue>0 || freePackValue.integerValue>0)
    {
        [param setValue:freeSingleValue forKey:@"SingleReceivedFreeGoodQty"];
        [param setValue:freeCaseValue forKey:@"CaseReceivedFreeGoodQty"];
        [param setValue:freePackValue forKey:@"PackReceivedFreeGoodQty"];
    
        [param setValue:freeSingleCost forKey:@"FreeGoodCost"];
        [param setValue:freeCaseCost forKey:@"FreeGoodCaseCost"];
        [param setValue:freePackCost forKey:@"FreeGoodPackCost"];
    }
    
//    if(freeSingleCost.integerValue>0 || freeCaseCost.integerValue>0 || freePackCost.integerValue>0)
//    {
    
  //  }
    
    if(!(self.manualItemReceive.receivedItemId.integerValue==0)){
        [param setValue:self.manualItemReceive.receivedItemId forKey:@"Id"];
    }
    
    NSMutableDictionary *manualEntry = [[NSMutableDictionary alloc] init ];
    [manualEntry setValue:param forKey:@"objManualEntryItem"];
    NSLog(@"Manual Req \n %@",[self.rmsDbController jsonStringFromObject:manualEntry]);
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self addManualEntryItemResponse:response error:error];
          });

    };
    
    self.addManualItemServiceConnection = [self.addManualItemServiceConnection initWithRequest:KURL actionName:strReceiveItemMethod params:manualEntry completionHandler:completionHandler];
    
}
- (void)addManualEntryItemResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *strID = response[@"Data"];
                if(!(self.manualItemReceive.receivedItemId.integerValue==0)){
                    strID=[NSString stringWithFormat:@"%@", self.manualItemReceive.receivedItemId];
                }
                [self insertPOItemWithDictionary:strID];
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            else{
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self insertItemInManualEntery];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[response valueForKey:@"Data"] buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
            }
        }
        else{
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [self insertItemInManualEntery];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Your request is not processed successfully, Plz try again." buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
        }
    }
    
}
-(void)insertPOItemWithDictionary:(NSString *)strItemID{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    dict[@"caseCost"] = self.itemInfoDataObject.itemPricingArray[1] [@"Cost"];
    dict[@"caseMarkup"] = self.itemInfoDataObject.itemPricingArray[1] [@"Profit"];
    dict[@"casePrice"] = self.itemInfoDataObject.itemPricingArray[1] [@"UnitPrice"];
    
    if (self.itemInfoDataObject.itemPricingArray[1] [@"ReceivedQty"] == nil) {
        [self.itemInfoDataObject.itemPricingArray[1] setValue:@"0" forKey:@"ReceivedQty"];
    }
    
    dict[@"caseQuantityReceived"] = self.itemInfoDataObject.itemPricingArray[1] [@"ReceivedQty"];
    dict[@"cashQtyonHand"] = self.itemInfoDataObject.itemPricingArray[1] [@"Qty"];
    
    dict[@"packCost"] = self.itemInfoDataObject.itemPricingArray[2] [@"Cost"];
    dict[@"packMarkup"] = self.itemInfoDataObject.itemPricingArray[2] [@"Profit"];
    dict[@"packPrice"] = self.itemInfoDataObject.itemPricingArray[2] [@"UnitPrice"];
    
    if (self.itemInfoDataObject.itemPricingArray[2] [@"ReceivedQty"] == nil) {
        [self.itemInfoDataObject.itemPricingArray[2] setValue:@"0" forKey:@"ReceivedQty"];
    }
    
    dict[@"packQuantityReceived"] = self.itemInfoDataObject.itemPricingArray[2] [@"ReceivedQty"];
    dict[@"packQtyonHand"] = self.itemInfoDataObject.itemPricingArray[2] [@"Qty"];
    
    dict[@"unitCost"] = self.itemInfoDataObject.itemPricingArray[0] [@"Cost"];
    dict[@"unitMarkup"] = self.itemInfoDataObject.itemPricingArray[0] [@"Profit"];
    dict[@"unitPrice"] = self.itemInfoDataObject.itemPricingArray[0] [@"UnitPrice"];
    dict[@"unitQuantityReceived"] = self.itemInfoDataObject.itemPricingArray[0] [@"ReceivedQty"];
    dict[@"unitQtyonHand"] = self.itemInfoDataObject.itemPricingArray[0] [@"Qty"];
    
    dict[@"createDate"] = [NSDate date];
    
    dict[@"receivedItemId"] = strItemID;
    
    dict[@"singleReceivedFreeGoodQty"] = freeSingleValue;
    dict[@"caseReceivedFreeGoodQty"] = freeCaseValue;
    dict[@"packReceivedFreeGoodQty"] = freePackValue;
    
    dict[@"freeGoodCost"] = freeSingleCost;
    dict[@"freeGoodCaseCost"] = freeCaseCost;
    dict[@"freeGoodPackCost"] = freePackCost;
    
    if(_btnReturn.selected){
        
        dict[@"isReturn"] = @"1";
    }
    else{
        dict[@"isReturn"] = @"0";
    }
    
    [self.manualItemReceive updateManualPoitemDictionary:dict];
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualReceivedItem" inManagedObjectContext:privateContextObject];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"supplierIDitems.manualPoId = %d AND item.itemCode = %d",self.manualItemReceive.supplierIDitems.manualPoId.intValue,self.manualItemReceive.item.itemCode.intValue];
    
    fetchRequest.predicate = predicatePO;
    
    // Create the sort descriptors array.
    
    NSArray *resultSet = [UpdateManager executeForContext:privateContextObject FetchRequest:fetchRequest];
    
    if (resultSet.count>0) {
        for (ManualReceivedItem * objOldItem in resultSet) {
            [objOldItem interChangeValuefrom:self.manualItemReceive];
        }
    }
    
    [UpdateManager saveContext:privateContextObject];
    // [self.updateManager insertManualPOItemWithDictionary:dict];
    
}
#pragma mark - utility -

-(void)getPricingData{
    Item *anItem = self.manualItemReceive.item;
    self.itemInfoDataObject.itemPricingArray = [[NSMutableArray alloc]init];
    for (Item_Price_MD *pricing in anItem.itemToPriceMd) {
        
        if([pricing.priceqtytype.lowercaseString isEqualToString:@"single item"]) {
            
            NSMutableDictionary * singleDict = [self addPrincingdataWithUnitCost:self.manualItemReceive.unitCost UnitMarkup:self.manualItemReceive.unitMarkup UnitQtyonHand:self.manualItemReceive.unitQtyonHand UnitQuantityReceived:self.manualItemReceive.unitQuantityReceived UnitPrice:self.manualItemReceive.unitPrice];
            
            singleDict[@"PriceQtyType"] = @"Single Item";
            [self.itemInfoDataObject.itemPricingArray addObject:singleDict];
        }
        else if([pricing.priceqtytype.lowercaseString isEqualToString:@"case"]) {
            
            NSMutableDictionary * singleDict = [self addPrincingdataWithUnitCost:self.manualItemReceive.caseCost UnitMarkup:self.manualItemReceive.caseMarkup UnitQtyonHand:self.manualItemReceive.cashQtyonHand UnitQuantityReceived:self.manualItemReceive.caseQuantityReceived UnitPrice:self.manualItemReceive.casePrice];
            
            singleDict[@"PriceQtyType"] = @"Case";
            [self.itemInfoDataObject.itemPricingArray addObject:singleDict];
        }
        else if([pricing.priceqtytype.lowercaseString isEqualToString:@"pack"]) {
            
            NSMutableDictionary * singleDict = [self addPrincingdataWithUnitCost:self.manualItemReceive.packCost UnitMarkup:self.manualItemReceive.packMarkup UnitQtyonHand:self.manualItemReceive.packQtyonHand UnitQuantityReceived:self.manualItemReceive.packQuantityReceived UnitPrice:self.manualItemReceive.packPrice];
            
            singleDict[@"PriceQtyType"] = @"Pack";
            [self.itemInfoDataObject.itemPricingArray addObject:singleDict];
            
        }
    }
    [self addPricingData];
    if(self.itemInfoDataObject.itemPricingArray.count < 3) {
        NSArray *packageType = @[@"Single Item",@"Case",@"Pack"];
        NSMutableArray *priceQtyType = [self.itemInfoDataObject.itemPricingArray valueForKey:@"PriceQtyType"];
        NSMutableArray *remainingPriceArray = [NSMutableArray arrayWithArray:packageType];
        [remainingPriceArray removeObjectsInArray:priceQtyType];
        
        for (NSString *remPriceQtyType in remainingPriceArray) {
            
            if([remPriceQtyType.lowercaseString isEqualToString:@"single item"]) {
                
                NSMutableDictionary * singleDict = [self addPrincingdataWithUnitCost:self.manualItemReceive.unitCost UnitMarkup:self.manualItemReceive.unitMarkup UnitQtyonHand:self.manualItemReceive.unitQtyonHand UnitQuantityReceived:self.manualItemReceive.unitQuantityReceived UnitPrice:self.manualItemReceive.unitPrice];
                
                singleDict[@"PriceQtyType"] = @"Single Item";
                [self.itemInfoDataObject.itemPricingArray addObject:singleDict];
                
            }
            else if([remPriceQtyType.lowercaseString isEqualToString:@"case"]) {
                
                NSMutableDictionary * singleDict = [self addPrincingdataWithUnitCost:self.manualItemReceive.caseCost UnitMarkup:self.manualItemReceive.caseMarkup UnitQtyonHand:self.manualItemReceive.cashQtyonHand UnitQuantityReceived:self.manualItemReceive.caseQuantityReceived UnitPrice:self.manualItemReceive.casePrice];
                
                singleDict[@"PriceQtyType"] = @"Case";
                [self.itemInfoDataObject.itemPricingArray addObject:singleDict];
            }
            else if([remPriceQtyType.lowercaseString isEqualToString:@"pack"])
            {
                NSMutableDictionary * singleDict = [self addPrincingdataWithUnitCost:self.manualItemReceive.packCost UnitMarkup:self.manualItemReceive.packMarkup UnitQtyonHand:self.manualItemReceive.packQtyonHand UnitQuantityReceived:self.manualItemReceive.packQuantityReceived UnitPrice:self.manualItemReceive.packPrice];
                
                singleDict[@"PriceQtyType"] = @"Pack";
                [self.itemInfoDataObject.itemPricingArray addObject:singleDict];
            }
        }
    }
    
    [self.itemInfoDataObject.itemPricingArray sortUsingComparator:
     ^NSComparisonResult(id obj1, id obj2){
         
         NSDictionary *p1 = (NSDictionary *)obj1;
         NSDictionary *p2 = (NSDictionary *)obj2;
         
         int type1 = 10;
         int type2 = 10;
         
         type1 = [self qtyTypeForPricingDictionary:p1];
         type2 = [self qtyTypeForPricingDictionary:p2];
         
         if (type1 > type2) {
             return (NSComparisonResult)NSOrderedDescending;
         }
         if (type1 < type2) {
             return (NSComparisonResult)NSOrderedAscending;
         }
         return (NSComparisonResult)NSOrderedSame;
     }];
    [self.itemInfoDataObject createDuplicateItemPricingArray];
}
- (NSMutableDictionary *)addPrincingdataWithUnitCost:(NSNumber *)unitCost UnitMarkup:(NSNumber *)unitMarkup UnitQtyonHand:(NSNumber *)unitQtyonHand UnitQuantityReceived:(NSNumber *)unitQuantityReceived UnitPrice:(NSNumber *)unitPrice{
    NSMutableDictionary *singleDict = [[NSMutableDictionary alloc]init];
    singleDict[@"ApplyPrice"] = @"UnitPrice";
    if(unitCost)
    {
        singleDict[@"Cost"] = [NSString stringWithFormat:@"%@", unitCost];
    }
    else{
        singleDict[@"Cost"] = @"0.00";
        
    }
    singleDict[@"IsPackCaseAllow"] = @"0";
    if(unitMarkup)
    {
        singleDict[@"Profit"] = [NSString stringWithFormat:@"%@",unitMarkup];
    }
    else{
        singleDict[@"Profit"] = @"0.00";
        
    }
    if(unitQtyonHand)
    {
        singleDict[@"Qty"] = unitQtyonHand;
        
    }
    else{
        singleDict[@"Qty"] = @(0);
        
    }
    if(unitQuantityReceived)
    {
        
        singleDict[@"ReceivedQty"] = [NSString stringWithFormat:@"%@",unitQuantityReceived];
    }
    else{
        singleDict[@"ReceivedQty"] = @"0.00";
        
    }
    if(unitPrice)
    {
        singleDict[@"UnitPrice"] = [NSString stringWithFormat:@"%@",unitPrice];
    }
    else{
        singleDict[@"UnitPrice"] = @"0.00";
        
    }
    singleDict[@"UnitType"] = @"0";
    return singleDict;
}
- (Item*)fetchAllItems :(NSString *)itemId moc:(NSManagedObjectContext *)moc{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    if (resultSet.count>0) {
        item=resultSet.firstObject;
    }
    return item;
}
- (int)qtyTypeForPricingDictionary:(NSDictionary *)p1{
    int type = 10;
    if([p1[@"PriceQtyType"] isEqualToString:@"Single Item"] || [p1[@"PriceQtyType"] isEqualToString:@"SINGLE ITEM"] || [p1[@"PriceQtyType"] isEqualToString:@"Single item"]) {
        type = 1;
    }
    else if([p1[@"PriceQtyType"] isEqualToString:@"Case"] || [p1[@"PriceQtyType"] isEqualToString:@"CASE"]) {
        type = 2;
    }
    else if([p1[@"PriceQtyType"] isEqualToString:@"Pack"] || [p1[@"PriceQtyType"] isEqualToString:@"PACK"]) {
        type = 3;
    }
    return type;
}

-(void)addPricingData{
    
    if(self.itemInfoDataObject.itemPricingArray.count > 3) {
        
        NSMutableArray *itemPricingArrayTemp = [[NSMutableArray alloc]init];
        
        NSArray * arrayPricing = (NSArray *)self.itemInfoDataObject.itemPricingArray;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Qty" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        self.itemInfoDataObject.itemPricingArray = [(NSMutableArray *)[arrayPricing sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        
        // Check for Single Item Qty == 1
        
        NSPredicate *singlePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty == 1", @"Single Item"];
        NSArray *arraySingleItem = [self.itemInfoDataObject.itemPricingArray filteredArrayUsingPredicate:singlePredicate];
        if(arraySingleItem.count>0) {
            
            [itemPricingArrayTemp addObject:arraySingleItem.firstObject];
        }
        
        // Check for Single Item Qty > 1 then change to Case
        
        NSPredicate *singlePredicate1 = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Single Item"];
        NSArray *arraySingleItem2 = [self.itemInfoDataObject.itemPricingArray filteredArrayUsingPredicate:singlePredicate1];
        
        for (int i =0 ;i <arraySingleItem2.count;i++) {
            NSMutableDictionary *dictObject = arraySingleItem2[i];
            dictObject[@"PriceQtyType"] = @"Case";
        }
        
        // Predicate for Case and Qty > 1
        
        NSPredicate *casePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Case"];
        NSArray *arrayCaseItem = [self.itemInfoDataObject.itemPricingArray filteredArrayUsingPredicate:casePredicate];
        
        if(arrayCaseItem.count>0) {
            
            [itemPricingArrayTemp addObject:arrayCaseItem.firstObject];
        }
        
        // Predicate for Case and Qty > 1
        
        NSPredicate *packPredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Pack"];
        NSArray *arrayPackItem = [self.itemInfoDataObject.itemPricingArray filteredArrayUsingPredicate:packPredicate];
        
        if(arrayPackItem.count>0) {
            
            [itemPricingArrayTemp addObject:arrayPackItem.firstObject];
        }
        
        self.itemInfoDataObject.itemPricingArray = itemPricingArrayTemp;
    }
    
}
-(void)toggleMarginMarkUp {

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
    indexPath = [NSIndexPath indexPathForRow:PricingSectionItemProfit inSection:1];
    
    [_tblItemInfo beginUpdates];
    [_tblItemInfo deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    [_tblItemInfo insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation2];
    [_tblItemInfo endUpdates];
}

- (NSString *)getValueBeforeDecimal:(float)result{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}

@end
