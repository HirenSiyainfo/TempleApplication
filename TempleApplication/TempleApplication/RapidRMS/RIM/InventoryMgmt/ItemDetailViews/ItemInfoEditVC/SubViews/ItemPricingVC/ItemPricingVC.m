//
//  ItemPricingVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 20/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AppropriatePriceLevelCell.h"
#import "ButtonAndSwitchCell.h"
#import "ItemPricingOptionCell.h"
#import "ItemPricingVC.h"
#import "RmsDbController.h"
#import "UITableView+AddBorder.h"
#import "VariationCustomCell.h"
#import "WeightScaleSetupCell.h"


// Core Data
#import "Item+Dictionary.h"
#import "ItemVariation_M+Dictionary.h"
#import "Variation_Master+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "ItemVariation_Md+Dictionary.h"

@interface ItemPricingVC ()<PriceChangeInfoPricingDelegate,PriceOptionTypeCellDelegate>
{
    UITextField * currentEditing;
    NSString *Profit_type;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation ItemPricingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source -

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section < 2) {
        return (IsPad()?10:0.01f);
    }
    return RIMHeaderHeight();
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.itemInfoDataObject.selectedPricingType.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad() && indexPath.section < 2) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section < 2) {
        return nil;
    }
    NSString *rowTitle = @"";
    PricingTab seletedTab = [self.itemInfoDataObject.selectedPricingType[section] integerValue];
    switch (seletedTab) {
        case PricingPriceAtPosRows: // Price At Pos
            rowTitle = @"Price At Pos";
            break;
        case PricingOption: // Pricing Options
            rowTitle = @"VALUES";
            break;
        case PricingWeightScaleRows: // Pricing Weightscale
            rowTitle = @"Weight Scale";
            break;
        case PricingAppropreateRows: // Pricing Appropreate
            rowTitle = @"Retail Price";
            break;
        case PricingVariationRows: // Pricing Variations
            rowTitle = @"Variations";
            break;
        case PricingVariationAppropreateRows: // Pricing Variations Appropreate
            rowTitle = @"Retail Price";//            rowTitle = @"Variations + Retail Price";

            break;
        case PricingVariation_1: // Variations custom 1
            rowTitle = [self.itemInfoDataObject.itemVariationTypes.firstObject valueForKey:@"VariationName" ];
            break;
        case PricingVariation_2: // Variations custom 2
            rowTitle = [(self.itemInfoDataObject.itemVariationTypes)[1] valueForKey:@"VariationName" ];
            break;
        case PricingVariation_3: //  Variations custom 3
            rowTitle = [(self.itemInfoDataObject.itemVariationTypes)[2] valueForKey:@"VariationName" ];
            break;
            
        default:
            break;
    }
    return [tableView defaultTableHeaderView:rowTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger noOfRows = [self configurePricingTabNoOfRows:section];
    return noOfRows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self configurePricingTabHeight:indexPath.section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *returnCell;
//    returnCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PricingTab sectionNo = [self.itemInfoDataObject.selectedPricingType[indexPath.section] integerValue ];
    
    switch (sectionNo) {
        case PricingPriceAtPosRows: // Price At Pos
            returnCell = [self configurePriceAtPosCell:self.tblItemPricing cellForRowAtIndexPath:indexPath];
            break;
        case PricingOption: // Pricing Options
            returnCell = [self configurePricingOptionCell:self.tblItemPricing cellForRowAtIndexPath:indexPath];
            break;
        case PricingWeightScale: // Pricing Weightscale
            returnCell = [self weightScaleSetupTableView:self.tblItemPricing cellForRowAtIndexPath:indexPath];
            break;
        case PricingAppropreate: // Pricing Appropreate
            returnCell = [self appropriatePriceTableView:self.tblItemPricing cellForRowAtIndexPath:indexPath];
            break;
        case PricingVariations: // Pricing Variations
            //returnCell = [self itemVariationsPriceTableView:self.tblItemPricing cellForRowAtIndexPath:indexPath];
            break;
        case PricingVariations_Appropreate: // Pricing Variations Appropreate
            returnCell = [self appropriatePriceTableView:self.tblItemPricing cellForRowAtIndexPath:indexPath];
            break;
        case PricingVariation_1: // Pricing Variations Appropreate
            returnCell = [self itemVariationsPriceTableView:self.tblItemPricing cellForRowAtIndexPath:indexPath itemVariationArray:self.itemInfoDataObject.itemVariationData1];
            break;
        case PricingVariation_2: // Pricing Variations Appropreate
            returnCell = [self itemVariationsPriceTableView:self.tblItemPricing cellForRowAtIndexPath:indexPath itemVariationArray:self.itemInfoDataObject.itemVariationData2];
            break;
        case PricingVariation_3: // Pricing Variations Appropreate
            returnCell = [self itemVariationsPriceTableView:self.tblItemPricing cellForRowAtIndexPath:indexPath itemVariationArray:self.itemInfoDataObject.itemVariationData3];
            break;

        default:
            break;
    }
    if (!self.itemInfoDataObject.oldActive) {
        returnCell.contentView.userInteractionEnabled = FALSE;
    }
    returnCell.backgroundColor = [UIColor clearColor];
    returnCell.contentView.backgroundColor = [UIColor clearColor];
    return returnCell;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - Calculation No or row , No of section -
- (NSInteger)configurePricingTabNoOfRows:(NSInteger)section
{
    NSInteger rows = 0;
    PricingTab seletedTab = [self.itemInfoDataObject.selectedPricingType[section] integerValue];
    switch (seletedTab) {
        case PricingPriceAtPosRows: // Price At Pos
            rows = 1;
            break;
        case PricingOption: // Pricing Options
//            rows = (self.itemInfoDataObject.pricingOption).count;
            rows = 1;
            break;
        case PricingWeightScaleRows: // Pricing Weightscale
            rows = 3;
            break;
        case PricingAppropreateRows: // Pricing Appropreate
            rows = 3;
            break;
        case PricingVariationRows: // Pricing Variations
            rows = 0;
            break;
        case PricingVariationAppropreateRows: // Pricing Variations Appropreate
            rows = 3;
            break;
        case PricingVariation_1: // Variations custom 1
            rows = self.itemInfoDataObject.itemVariationData1.count;
            break;
        case PricingVariation_2: // Variations custom 2
            rows = self.itemInfoDataObject.itemVariationData2.count;
            break;
        case PricingVariation_3: //  Variations custom 3
            rows = self.itemInfoDataObject.itemVariationData3.count;
            break;
            
        default:
            break;
    }
    return rows;
}
// configure height for rows for pricing section rows
- (CGFloat)configurePricingTabHeight:(NSInteger)section
{
    CGFloat rowHeight = 0.0;
    PricingTab seletedTab = [self.itemInfoDataObject.selectedPricingType[section] integerValue];
    switch (seletedTab) {
        case PricingPriceAtPosRows: // Price At Pos
            rowHeight = 55.0f;
            break;
        case PricingOption: // Pricing Options
            if(IsPhone()){
                rowHeight = 130.0f;
            }
            else{
                rowHeight = 55.0f;
            }
            break;
        case PricingWeightScaleRows: // Pricing Weightscale
            if(IsPhone()){
                rowHeight = 230.0;
            }
            else{
                rowHeight = 168.0f;
            }
            break;
        case PricingAppropreateRows: // Pricing Appropreate
        case PricingVariationRows: // Pricing Variations
        case PricingVariationAppropreateRows: // Pricing Variations Appropreate
        case PricingVariation_1: // Pricing Variations Appropreate
        case PricingVariation_2: // Pricing Variations Appropreate
        case PricingVariation_3: // Pricing Variations Appropreate
            if(IsPhone()){
                rowHeight = 239.0;
            }
            else{
                rowHeight = 174.0;
            }
            break;
        default:
            break;
    }
    return rowHeight;
}
#pragma mark - Configure Cell -
// Configure Price At Pos in Pricing Section
- (UITableViewCell *)configurePriceAtPosCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ident=@"NoPOSDiscount";
    ButtonAndSwitchCell *cell=(ButtonAndSwitchCell *)[tableView dequeueReusableCellWithIdentifier:ident];
    if (cell==nil) {
        cell=[[ButtonAndSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    cell.cellTitle.text=@"Price at POS".uppercaseString;
    if (self.itemInfoDataObject.IsPriceAtPOS) {
        [cell.selectedswitch setOn:YES];
    }
    else {
        [cell.selectedswitch setOn:NO];
    }
    [cell.selectedswitch addTarget:self action:@selector(isPriceAtPosClicked:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

// Configure Pricing Section options
- (UITableViewCell *)configurePricingOptionCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * cellIdentifier = @"pricingWithOutWeightScaleCell";
    if ([self.itemInfoDataObject.pricingOption containsObject:@(PricingWeightScale)]) {
        cellIdentifier = @"pricingWithWeightScaleCell";
    }
    
    ItemPricingOptionCell *cell=(ItemPricingOptionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[ItemPricingOptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    PricingTab optionNo = [self.itemInfoDataObject.pricingOption[indexPath.row] integerValue];
    switch (optionNo) {
        case PricingWeightScale:
        case PricingAppropreate:
        case PricingVariations:
        case PricingVariations_Appropreate:{
            PricingOptionTypes selectedOption = PricingOptionTypesAppropreate;
            if ([self.itemInfoDataObject.PriceScale isEqualToString:@"WSCALE"]) {
                selectedOption = PricingOptionTypesWeightScale;
            }
            else if ([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) {
                selectedOption = PricingOptionTypesVariations;
            }
            else if ([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATIONAPPROPRIATE"]) {
                selectedOption = PricingOptionTypesVariations_Appropreate;
            }            
            [cell configureCellWithType:selectedOption];
            break;
        }
        default:
            break;
    }
    if (!self.itemInfoDataObject.oldActive) {
        cell.userInteractionEnabled = FALSE;
    }

    return cell;
}
-(void)willChangePriceOptionTypeTo:(PricingOptionTypes)newType {
    switch (newType) {
        case PricingOptionTypesWeightScale:
            [self weightScalePricingClicked];
            self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingWeightScale), nil];
            break;
        case PricingOptionTypesAppropreate:
            [self appropriatePricingClicked];
            self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingAppropreate), nil];

            break;
        case PricingOptionTypesVariations:
            [self variationPricingClicked];
            self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingVariations), nil];

            break;
        case PricingOptionTypesVariations_Appropreate:
            [self variationAppropriatePricingClicked];
            self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingVariations_Appropreate), nil];

            break;
    }
    if(newType == 4 || newType == 5)
    {
        if (self.itemInfoDataObject.itemVariationData1.count > 0) {
            [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_1)];
        }
        if (self.itemInfoDataObject.itemVariationData2.count > 0) {
            [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_2)];
        }
        if (self.itemInfoDataObject.itemVariationData3.count > 0) {
            [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_3)];
        }
    }
    [self.tblItemPricing reloadData];
}
- (UITableViewCell *)weightScaleSetupTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"WeightScaleSetupCell";
    WeightScaleSetupCell *weightScaleCell = (WeightScaleSetupCell *)[self.tblItemPricing dequeueReusableCellWithIdentifier:cellIdentifier];
    weightScaleCell.backgroundColor = [UIColor clearColor];
    weightScaleCell.selectionStyle = UITableViewCellSelectionStyleNone;
    weightScaleCell.containerView = self.view.superview;
    weightScaleCell.isMargin=self.itemInfoDataObject.rowSwitch;
    weightScaleCell.PriceChangeInfoPricingDelegate=self;
    weightScaleCell.cellIndex=indexPath;
    if(indexPath.row == 0){
        weightScaleCell.allowPackageType.hidden = YES;
        weightScaleCell.qty.enabled = NO;
        NSString * strQTY = [NSString stringWithFormat:@"%d",[self.itemInfoDataObject.itemPricingArray[0][@"Qty"] intValue]];
        if (![strQTY isEqualToString:@"1"]) {
            self.itemInfoDataObject.itemPricingArray[0] [@"Qty"] = @1;
        }
        weightScaleCell.weightDictionary = self.itemInfoDataObject.itemWeightScaleArray[indexPath.row];
    }
    
    weightScaleCell.qty.tag = 100 + indexPath.row;
    weightScaleCell.allowPackageType.tag = indexPath.row;
    if(indexPath.row == 1){
        weightScaleCell.weightDictionary = self.itemInfoDataObject.itemWeightScaleArray[indexPath.row];
        weightScaleCell.allowPackageType.hidden = NO;
        [weightScaleCell.allowPackageType addTarget:self action:@selector(allowPackageTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    if(indexPath.row == 2){
        weightScaleCell.weightDictionary = self.itemInfoDataObject.itemWeightScaleArray[indexPath.row];
        weightScaleCell.allowPackageType.hidden = NO;
        [weightScaleCell.allowPackageType addTarget:self action:@selector(allowPackageTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    weightScaleCell.profit_type = Profit_type;
    [weightScaleCell refreshWeightPriceCell];
    return weightScaleCell;
}

- (UITableViewCell *)appropriatePriceTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"AppropriatePriceLevelCell";
    AppropriatePriceLevelCell *appPriceLevelCell = (AppropriatePriceLevelCell *)[self.tblItemPricing dequeueReusableCellWithIdentifier:cellIdentifier];
    appPriceLevelCell.backgroundColor = [UIColor clearColor];
    appPriceLevelCell.selectionStyle = UITableViewCellSelectionStyleNone;
    appPriceLevelCell.containerView = self.view.superview;
    appPriceLevelCell.isMargin=self.itemInfoDataObject.rowSwitch;
    appPriceLevelCell.PriceChangeInfoPricingDelegate=self;
    appPriceLevelCell.cellIndex=indexPath;
    
    if(indexPath.row == 0){
        appPriceLevelCell.allowPackageType.hidden = YES;
        appPriceLevelCell.qty.enabled = NO;
        NSString * strQTY = [NSString stringWithFormat:@"%d",[self.itemInfoDataObject.itemPricingArray[0][@"Qty"] intValue]];
        if (![strQTY isEqualToString:@"1"]) {
            self.itemInfoDataObject.itemPricingArray[0] [@"Qty"] = @1;
        }
        appPriceLevelCell.pricingDictionary = self.itemInfoDataObject.itemPricingArray[indexPath.row];
    }
    appPriceLevelCell.qty.tag = 100 + indexPath.row;
    appPriceLevelCell.allowPackageType.tag = indexPath.row;
    if(indexPath.row == 1){
        appPriceLevelCell.pricingDictionary = self.itemInfoDataObject.itemPricingArray[indexPath.row];
        appPriceLevelCell.allowPackageType.hidden = NO;
        [appPriceLevelCell.allowPackageType addTarget:self action:@selector(allowPackageTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    if(indexPath.row == 2){
        appPriceLevelCell.pricingDictionary = self.itemInfoDataObject.itemPricingArray[indexPath.row];
        appPriceLevelCell.allowPackageType.hidden = NO;
        [appPriceLevelCell.allowPackageType addTarget:self action:@selector(allowPackageTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [appPriceLevelCell refreshAppropriatePriceCell];
    appPriceLevelCell.profit_type = Profit_type;
    return appPriceLevelCell;
}

- (UITableViewCell *)itemVariationsPriceTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath itemVariationArray:(NSMutableArray *)itemVariationArray{
    NSString *cellIdentifier = @"VariationCustomCell";
    VariationCustomCell *variationPriceLevelCell = (VariationCustomCell *)[self.tblItemPricing dequeueReusableCellWithIdentifier:cellIdentifier];
    variationPriceLevelCell.backgroundColor = [UIColor clearColor];
    variationPriceLevelCell.selectionStyle = UITableViewCellSelectionStyleNone;
    variationPriceLevelCell.PriceChangeInfoPricingDelegate=self;
    variationPriceLevelCell.containerView = self.view.superview;
    variationPriceLevelCell.allowPackageType.hidden = YES;
    variationPriceLevelCell.isMargin=self.itemInfoDataObject.rowSwitch;
    variationPriceLevelCell.pricingDictionary = itemVariationArray[indexPath.row];
    [variationPriceLevelCell refreshAppropriatePriceCell];
    variationPriceLevelCell.profit_type = Profit_type;
    return variationPriceLevelCell;
}

#pragma mark - ChangeSelection -
-(void)weightScalePricingClicked{
    [self.rmsDbController playButtonSound];
    self.itemInfoDataObject.PriceScale = @"WSCALE";
    self.itemInfoDataObject.isPricingLevelSelected = FALSE;
    if (!self.itemInfoDataObject.itemWeightScaleArray) {
        [self.priceChangeAndCalculationDelegate getWeightScaleData];
    }
//    [self.tblItemPricing reloadData];
}

-(void)appropriatePricingClicked{
    [self.rmsDbController playButtonSound];
    self.itemInfoDataObject.PriceScale = @"APPPRICE";
    self.itemInfoDataObject.isPricingLevelSelected = TRUE;
    if (!self.itemInfoDataObject.itemPricingArray) {
        [self.priceChangeAndCalculationDelegate getPricingData];
    }
//    [self.tblItemPricing reloadData];
}

-(void)variationPricingClicked{
    [self.rmsDbController playButtonSound];
    self.itemInfoDataObject.PriceScale = @"VARIATION";
    self.itemInfoDataObject.isPricingLevelSelected = TRUE;
    [self.priceChangeAndCalculationDelegate getItemVariationData];
//    [self.tblItemPricing reloadData];
}

-(void)variationAppropriatePricingClicked{
    [self.rmsDbController playButtonSound];
    self.itemInfoDataObject.PriceScale = @"VARIATIONAPPROPRIATE";
    self.itemInfoDataObject.isPricingLevelSelected = TRUE;
    [self.priceChangeAndCalculationDelegate getItemVariationData];
//    [self.tblItemPricing reloadData];
}


#pragma mark - IBAction -
- (IBAction)isPriceAtPosClicked:(UISwitch *)sender{
    [self.rmsDbController playButtonSound];
    if(sender.isOn)
    {
        self.itemInfoDataObject.IsPriceAtPOS = TRUE;
    }
    else
    {
        self.itemInfoDataObject.IsPriceAtPOS = FALSE;
    }
    NSDictionary *priceAtPosDict = @{kRIMItemPriceAtPosKey : @(self.itemInfoDataObject.IsPriceAtPOS)};
    [Appsee addEvent:kRIMItemPriceAtPos withProperties:priceAtPosDict];
    
}


// allow packagetype for specific package
-(IBAction)allowPackageTypeClicked:(UISwitch *)sender{
    int selectedIndex = (int)sender.tag;
//    NSString *packageType = @"";
    if(selectedIndex == 1){
//        packageType = @" Case ";
        NSDictionary *packageTypeDict = @{kRIMItemIsCaseAllowKey : @(sender.isOn)};
        [Appsee addEvent:kRIMItemIsCaseAllow withProperties:packageTypeDict];
    }
    else if (selectedIndex == 2){
//        packageType = @" Pack ";
        NSDictionary *packageTypeDict = @{kRIMItemIsPackAllowKey :  @(sender.isOn)};
        [Appsee addEvent:kRIMItemIsPackAllow withProperties:packageTypeDict];
    }
    if(sender.isOn){
        if ([self.itemInfoDataObject.PriceScale isEqualToString:@"WSCALE"]){
            if(selectedIndex == 1){ // allow case package
                self.itemInfoDataObject.itemWeightScaleArray[1] [@"IsPackCaseAllow"] = @"1";
            }
            else if (selectedIndex == 2){ // allow pack package
                self.itemInfoDataObject.itemWeightScaleArray[2] [@"IsPackCaseAllow"] = @"1";
            }
        }
        else{
            if(selectedIndex == 1){ // allow case package
                self.itemInfoDataObject.itemPricingArray[1] [@"IsPackCaseAllow"] = @"1";
            }
            else if (selectedIndex == 2){ // allow pack package
                self.itemInfoDataObject.itemPricingArray[2] [@"IsPackCaseAllow"] = @"1";
            }
        }
    }
    else{
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){ // No Button Action
            if ([self.itemInfoDataObject.PriceScale isEqualToString:@"WSCALE"])
            {
                if(selectedIndex == 1){ // allow case package
                    self.itemInfoDataObject.itemWeightScaleArray[1] [@"IsPackCaseAllow"] = @"1";
                }
                else if (selectedIndex == 2){ // allow pack package
                    self.itemInfoDataObject.itemWeightScaleArray[2] [@"IsPackCaseAllow"] = @"1";
                }
            }
            else{
                if(selectedIndex == 1){ // allow case package
                    self.itemInfoDataObject.itemPricingArray[1] [@"IsPackCaseAllow"] = @"1";
                }
                else if (selectedIndex == 2){ // allow pack package
                    self.itemInfoDataObject.itemPricingArray[2] [@"IsPackCaseAllow"] = @"1";
                }
            }
            [self.tblItemPricing reloadData];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){ // Yes Button Action
            if ([self.itemInfoDataObject.PriceScale isEqualToString:@"WSCALE"]){
                if(selectedIndex == 1){ // allow case package
                    self.itemInfoDataObject.itemWeightScaleArray[1] [@"IsPackCaseAllow"] = @"0";
                }
                else if (selectedIndex == 2){ // allow pack package
                    self.itemInfoDataObject.itemWeightScaleArray[2] [@"IsPackCaseAllow"] = @"0";
                }
            }
            else{
                if(selectedIndex == 1){ // allow case package
                    self.itemInfoDataObject.itemPricingArray[1] [@"IsPackCaseAllow"] = @"0";
                }
                else if (selectedIndex == 2){ // allow pack package
                    self.itemInfoDataObject.itemPricingArray[2] [@"IsPackCaseAllow"] = @"0";
                }
            }
            [self.tblItemPricing reloadData];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Do you want to turn off product notification during check out?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}
#pragma mark - Price Change -
-(BOOL)willChangeItemQtyOHat:(int)index{
    int Qty=[[self.itemInfoDataObject.itemPricingArray[index] valueForKey:@"Qty"] intValue];
    return (Qty>0?true : false);
}
-(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:messageTitle message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}
-(UITextField *)currentEditingView{
    return currentEditing;
}
-(void)setCurrentEdintingViewWithTextField:(UITextField *)textField{
    currentEditing=textField;
}
-(void)didPriceChangeOf:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber{
    if (PriceValueType==PricingSectionItemProfit && !self.itemInfoDataObject.rowSwitch) {
        [self.priceChangeAndCalculationDelegate didPriceChangeOfMarkUPValue:inputValue ValueIndex:IndexNumber];
    }
    else{
        [self.priceChangeAndCalculationDelegate didPriceChangeOf:PriceValueType inputValue:inputValue ValueIndex:IndexNumber];
    }
}
-(void)didPriceChangeOfInputWeight:(NSNumber *)inputValue InputWeightUnit:(NSString *)weightUnit  ValueIndex:(int)IndexNumber {
    [self.priceChangeAndCalculationDelegate didPriceChangeOfInputWeight:inputValue InputWeightUnit:weightUnit ValueIndex:IndexNumber];
}
@end
