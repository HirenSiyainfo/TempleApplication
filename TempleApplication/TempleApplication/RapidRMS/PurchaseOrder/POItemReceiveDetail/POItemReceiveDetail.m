//
//  POItemReceiveDetail.m
//  RapidRMS
//
//  Created by Siya10 on 15/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POItemReceiveDetail.h"
#import "RmsDbController.h"
#import "RimLoginVC.h"
#import "ItemInfoImageCell.h"
#import "ItemInfoDisplayCell.h"
#import "ItemInfoPricingCell.h"
#import "Item+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "PODeliveryPendingDetail.h"

@interface POItemReceiveDetail ()<PriceChangeDelegate,UpdateDelegate>

{
    UITextField * currentEditing;
    NSArray * itemPriceLocalArray;
    UIColor * colorSingle,* colorCase,* colorPack,* colorChanged;
    
    NSString *freeSingleValue;
    NSString *freeCaseValue;
    NSString *freePackValue;
    
    NSString *freeSingleCost;
    NSString *freeCaseCost;
    NSString *freePackCost;
    
    BOOL isReceivedSel;
    BOOL isReturn;

    NSIndexPath *selectedItemIndPath;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RapidWebServiceConnection * itemUpdateWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *itemUpdateConnnection;
@property (nonatomic, strong) RapidWebServiceConnection *poReceiveitemUpdateConnnection;

@property (nonatomic,weak) IBOutlet UITableView *tblItemInfo;
@property (nonatomic,weak) IBOutlet UIButton *receivedBtn;
@property (nonatomic,weak) IBOutlet UIButton *freegoodsBtn;
@property (nonatomic,weak) IBOutlet UIButton *returnBtn;

@property(nonatomic,strong)NSMutableArray *itemInfoSectionArray;

@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;

@end

@implementation POItemReceiveDetail
@synthesize receiveItemDetail,receivePoDetail;

- (void)viewDidLoad {
    [super viewDidLoad];
    isReceivedSel = YES;
    isReturn = NO;
    self.lblTitle.text = self.headeTitle;
    self.itemInfoSectionArray = [[NSMutableArray alloc] initWithObjects:@(ItemImageSection),@(ItemInfoSection),@(ItemPricingSection), nil];
    [self initializeObjects];
    self.itemUpdateWebServiceConnection = [[RapidWebServiceConnection alloc]init];
    self.poReceiveitemUpdateConnnection = [[RapidWebServiceConnection alloc]init];

}
-(void)initializeObjects{
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.manageObjectContext = self.rmsDbController.managedObjectContext;
    
    colorSingle = [UIColor colorWithRed:0.137 green:0.439 blue:0.973 alpha:1.000];
    colorCase = [UIColor colorWithRed:0.945 green:0.000 blue:0.094 alpha:1.000];
    colorPack = [UIColor colorWithRed:0.933 green:0.561 blue:0.176 alpha:1.000];
    
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value: self.itemInfoDataObject.ItemId shouldCreate:NO moc:self.manageObjectContext];
    [self getPricingData:anItem];
    itemPriceLocalArray = self.itemInfoDataObject.itemPricingArray;
    
    if(!self.isDelivery){
        
        freeSingleValue = [NSString stringWithFormat:@"%d",[receiveItemDetail[@"FreeGoodsQty"] intValue]];
        freeCaseValue = @"0";
        freePackValue = @"0";
        
        freeSingleCost = receiveItemDetail[@"CostPrice"];
        freeCaseCost = receiveItemDetail[@"CaseCost"];
        freePackCost = receiveItemDetail[@"PackCost"];
    }
    else{
        
        freeSingleValue = [NSString stringWithFormat:@"%d",[receiveItemDetail[@"FreeGoodsQty"] intValue]];
        freeCaseValue = [NSString stringWithFormat:@"%d",[receiveItemDetail[@"FreeGoodsQtyCase"] intValue]];
        freePackValue = [NSString stringWithFormat:@"%d",[receiveItemDetail[@"FreeGoodsQtyPack"] intValue]];
        
        freeSingleCost = receiveItemDetail[@"CostPrice"];
        freeCaseCost = receiveItemDetail[@"CaseCost"];
        freePackCost = receiveItemDetail[@"PackCost"];

    }
   

    self.receivedBtn.selected = YES;
    if(!self.isDelivery){
        self.freegoodsBtn.enabled = NO;
        self.returnBtn.enabled = NO;
    }
    isReturn = [receiveItemDetail[@"IsReturn"]boolValue];
    if(isReturn){
        [self returnClick:nil];
    }
}

#pragma mark - utility -

-(void)getPricingData:(Item *)anItem{
    
    self.itemInfoDataObject.itemPricingArray = [[NSMutableArray alloc]init];
    for (Item_Price_MD *pricing in anItem.itemToPriceMd) {
        
        if([pricing.priceqtytype.lowercaseString isEqualToString:@"single item"]) {
            
            NSMutableDictionary * singleDict = [self addPrincingdataWithUnitCost:receiveItemDetail[@"CostPrice"] UnitMarkup:receiveItemDetail[@"Margin"] UnitQtyonHand:@(1) UnitQuantityReceived:receiveItemDetail[@"ReOrder"] UnitPrice:receiveItemDetail[@"SalesPrice"]];
            
            singleDict[@"PriceQtyType"] = @"Single Item";
            [self.itemInfoDataObject.itemPricingArray addObject:singleDict];
        }
        else if([pricing.priceqtytype.lowercaseString isEqualToString:@"case"]) {
            
            NSMutableDictionary * caseDict = [self addPrincingdataWithUnitCost:receiveItemDetail[@"CaseCost"] UnitMarkup:receiveItemDetail[@"CaseProfitAmt"] UnitQtyonHand:pricing.qty UnitQuantityReceived:receiveItemDetail[@"ReOrderCase"] UnitPrice:receiveItemDetail[@"CasePrice"]];
            
            caseDict[@"PriceQtyType"] = @"Case";
            [self.itemInfoDataObject.itemPricingArray addObject:caseDict];
        }
        else if([pricing.priceqtytype.lowercaseString isEqualToString:@"pack"]) {
            
            NSMutableDictionary * packDict = [self addPrincingdataWithUnitCost:receiveItemDetail[@"PackCost"] UnitMarkup:receiveItemDetail[@"PackProfitAmt"] UnitQtyonHand:pricing.qty UnitQuantityReceived:receiveItemDetail[@"ReOrderPack"] UnitPrice:receiveItemDetail[@"PackPrice"]];
            
            packDict[@"PriceQtyType"] = @"Pack";
            [self.itemInfoDataObject.itemPricingArray addObject:packDict];
            
        }
    }
    [self addPricingData];
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
#pragma mark Received Click

-(IBAction)receivedClick:(id)sender{
    
     isReceivedSel = YES;
    self.receivedBtn.selected = YES;
    self.returnBtn.selected = NO;
    self.freegoodsBtn.selected = NO;
    [self.tblItemInfo reloadData];

}
#pragma mark Free Goods Click

-(IBAction)freeGoodsClick:(id)sender{
    
    isReceivedSel = NO;
    self.freegoodsBtn.selected = YES;
    self.receivedBtn.selected = NO;
    self.returnBtn.selected = NO;
    
    [self.tblItemInfo reloadData];
}

#pragma mark Return Click

-(IBAction)returnClick:(id)sender{
    isReceivedSel = YES;
    isReturn  = YES;
    self.returnBtn.selected = YES;
    self.receivedBtn.selected = NO;
    self.freegoodsBtn.selected = NO;
    [self.tblItemInfo reloadData];


}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.itemInfoSectionArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self configureItemInfoNoOfRows:section];
}
- (NSInteger)configureItemInfoNoOfRows:(NSInteger)section{
    NSInteger rows = 0;
    InfoSection InfoSection = [self.itemInfoSectionArray[section] integerValue];
    switch (InfoSection) {
        case ItemImageSection:
            return 1;
            break;
            
        case ItemInfoSection:
            return 3;
            break;
        case ItemPricingSection:
            self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
            return self.itemPricingSelection.count;
            break;

        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
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
        
        default:
            break;
    
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
    cell.cashPackQtyChaange = YES;
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
        case PricingSectionItemQty: // Quantity Received Text Field
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
        default:
            break;
    }
    return cell;
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
    
    cell.lblCellName.text = @"Qty Received".uppercaseString;
    cell.txtInputSingle.text = [NSString stringWithFormat:@"%@",self.itemInfoDataObject.avaibleQty];
    
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
    cell.lblCellName.text = @"Cost".uppercaseString;
    [self SetValueItemInfoPricingCell:cell withCellKey:@"Cost"];
    [self SetDesableTextFieldsOfCasePack:cell];
    if(!self.isDelivery || !isReceivedSel){
        [self disableEditingForRow:cell];
    }
}
-(void)disableEditingForRow:(ItemInfoPricingCell *)cell{
    cell.txtInputSingle.userInteractionEnabled = FALSE;
    cell.txtInputCase.userInteractionEnabled = FALSE;
    cell.txtInputPack.userInteractionEnabled = FALSE;
}

-(void)SetDesableTextFieldsOfCasePack:(ItemInfoPricingCell *)cell {
    if ([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) {
        cell.txtInputCase.text = @"";
        cell.txtInputPack.text = @"";
        cell.txtInputCase.userInteractionEnabled = FALSE;
        cell.txtInputPack.userInteractionEnabled = FALSE;
    }
    else {
//        cell.txtInputCase.userInteractionEnabled = TRUE;
//        cell.txtInputPack.userInteractionEnabled = TRUE;
    }
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
    if(!self.isDelivery || !isReceivedSel){
        [self disableEditingForRow:cell];
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

- (NSString *)getValueBeforeDecimal:(float)result
{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}

- (void)configurePricingSalesCell:(ItemInfoPricingCell *)cell{
    
    cell.lblCellName.text=@"Price".uppercaseString;
    [self SetValueItemInfoPricingCell:cell withCellKey:@"UnitPrice"];
    [self SetDesableTextFieldsOfCasePack:cell];
    if(!self.isDelivery || !isReceivedSel){
         [self disableEditingForRow:cell];
    }
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
     if(!self.isDelivery || !isReceivedSel){
         [self disableEditingForRow:cell];
     }

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
       // [cell.swiIsDuplicate addTarget: self action: @selector(allowDuplicateBarcodeClicked:) forControlEvents:UIControlEventValueChanged];
        cell.txtInputValue.text=@"";
        cell.btnValue.hidden=FALSE;
        [cell.btnValue removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        //[cell.btnValue addTarget:self action:@selector(moreBarcodeClicked:) forControlEvents:UIControlEventTouchUpInside];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    float headerHeight;
    
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
                        headerHeight = 85;
                    }
                    else{
                        headerHeight = 95;
                    }
                }
                else{
                    headerHeight = 55;
                }
                break;
                

            default:
                headerHeight = 55;
                break;
    }
    return headerHeight;

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
            [cell.asyncImageVDetail loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemImage]]];
        }
        
        cell.asyncImageVDetail.layer.borderWidth = 3;
        cell.asyncImageVDetail.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.btnValue.backgroundColor = [UIColor clearColor];
       // [cell.btnValue addTarget:self action:@selector(selectImageCapture:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
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
    if(self.isDelivery){
       return (Qty>0?true : false);
    }
    return true;
}
-(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:messageTitle message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

-(void)didPriceChangeOfInputWeight:(NSNumber *)inputValue InputWeightUnit:(NSString *)weightUnit  ValueIndex:(int)IndexNumber{
    
}
-(void)didPriceChangeOfMarkUPValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber{
    NSMutableArray * arrCalculation;
    //    if(self.itemInfoDataObject.isPricingLevelSelected) {
    arrCalculation=self.itemInfoDataObject.itemPricingArray;
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
        if(newQty == 0) {
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
        if(newQty == 0) {
            (arrPriceList[IndexNumber])[@"Profit"] = @0;
            (self.itemInfoDataObject.itemPricingArray[IndexNumber])[@"ReceivedQty"] = @0.0f;
        }
    }
}
-(BOOL)checkIsReceivedQtyZero{
    
    if(self.itemInfoDataObject.itemPricingArray[0][@"ReceivedQty"] > 0 || self.itemInfoDataObject.itemPricingArray[1][@"ReceivedQty"] > 0 || self.itemInfoDataObject.itemPricingArray[2][@"ReceivedQty"] > 0){

        return  NO;
    }
    else{
        return  YES;
    }
}

-(IBAction)saveReceivedItemDetail:(id)sender
{
    if([self checkIsReceivedQtyZero]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"ReOrder Qty not Zero" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
       
        if (self.itemInfoDataObject.changeInfoInManualItem) {
            
            [self itemDetailUpdate];
        }
        else{
            
            if(self.isDelivery && [self.itemDetailDelegate isKindOfClass:[PODeliveryPendingDetail class]]){
                [self callWCforPoReceiveItemUpdate];
            }
            else{
                
                [self updateItemInformation];
                [self.itemDetailDelegate didChangeItemDetail:receiveItemDetail];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

- (NSMutableDictionary *) PoReceiveDetailxml
{
    NSMutableDictionary *dictItemInfo = [[NSMutableDictionary alloc]init];
    dictItemInfo[@"ItemCode"] = self.receiveItemDetail[@"ItemId"];
    
    dictItemInfo[@"ReOrder"] = self.itemInfoDataObject.itemPricingArray[0][@"ReceivedQty"];
    dictItemInfo[@"FreeGoodsQty"] = @([freeSingleValue intValue]);
    dictItemInfo[@"AvailQty"] = self.receiveItemDetail[@"avaibleQty"];
    dictItemInfo[@"Cost"] = self.itemInfoDataObject.itemPricingArray[0][@"Cost"];
    dictItemInfo[@"Price"] = self.itemInfoDataObject.itemPricingArray[0][@"UnitPrice"];
    dictItemInfo[@"Margin"] = self.itemInfoDataObject.itemPricingArray[0][@"Profit"];
    
    dictItemInfo[@"ReOrderCase"] = self.itemInfoDataObject.itemPricingArray[1][@"ReceivedQty"];
    dictItemInfo[@"FreeGoodsQtyCase"] = @([freeCaseValue intValue]);
    dictItemInfo[@"CaseCost"] = self.itemInfoDataObject.itemPricingArray[1][@"Cost"];
    dictItemInfo[@"CasePrice"] = self.itemInfoDataObject.itemPricingArray[1][@"UnitPrice"];
    dictItemInfo[@"CaseMargin"] = self.itemInfoDataObject.itemPricingArray[1][@"Profit"];

    dictItemInfo[@"ReOrderPack"] = self.itemInfoDataObject.itemPricingArray[2][@"ReceivedQty"];
    dictItemInfo[@"FreeGoodsQtyPack"] = @([freePackValue intValue]);
    dictItemInfo[@"PackCost"] = self.itemInfoDataObject.itemPricingArray[2][@"Cost"];
    dictItemInfo[@"PackPrice"] = self.itemInfoDataObject.itemPricingArray[2][@"UnitPrice"];
    dictItemInfo[@"PackMargin"] = self.itemInfoDataObject.itemPricingArray[2][@"Profit"];
    
    dictItemInfo[@"IsReturn"] = @(isReturn);
    
    return dictItemInfo;
}


-(void)callWCforPoReceiveItemUpdate{
 
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *dictPODetail = [[NSMutableDictionary alloc] init];
    dictPODetail[@"PoRecieveDetailxml"] = [self PoReceiveDetailxml];
    
    [dictPODetail setValue:self.receivePoDetail[@"PO_No"] forKey:@"PO_No"];
    [dictPODetail setValue:self.receivePoDetail[@"PurchaseOrderId"] forKey:@"PurchaseOrderId"];
    if(self.receivePoDetail[@"receiveitemid"]){
        [dictPODetail setValue:self.receiveItemDetail[@"receiveitemid"] forKey:@"PO_RecieveItemID"];
    }
    else{
        [dictPODetail setValue:@"0" forKey:@"PO_RecieveItemID"];
    }
    dictPODetail[@"OpenOrderId"] = self.receivePoDetail[@"OpenOrderId"];
    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictPODetail[@"UserId"] = userID;
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    [dictPODetail setValue:strDateTime forKey:@"DateTime"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseUpdateRecievePoDetailResponse:response error:error];
        });
    };
    
    self.poReceiveitemUpdateConnnection = [self.poReceiveitemUpdateConnnection initWithRequest:KURL actionName:WSM_UPDATE_RECIEVE_PO_DETAIL_ITEM params:dictPODetail completionHandler:completionHandler];
    
}

#pragma mark Save PO Item Response

- (void)responseUpdateRecievePoDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self updateItemInformation];
                    [self.itemDetailDelegate didChangeItemDetail:receiveItemDetail];
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Receive Item Detail" message:@"Receive Order Item has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            else
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Receive Item Detail" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Receive Item Detail" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}


-(void)updateItemInformation{
    
    if(self.isDelivery){
        
        receiveItemDetail[@"IsReturn"] = @(isReturn);
        receiveItemDetail[@"ReOrder"] = self.itemInfoDataObject.itemPricingArray[0][@"ReceivedQty"];
        receiveItemDetail[@"FreeGoodsQty"] = @([freeSingleValue intValue]);
        receiveItemDetail[@"FreeGoodsQtyCase"] = @([freeCaseValue intValue]);
        receiveItemDetail[@"FreeGoodsQtyPack"] = @([freePackValue intValue]);

        receiveItemDetail[@"ProfitAmt"] = self.itemInfoDataObject.itemPricingArray[0][@"Profit"];
        receiveItemDetail[@"SalesPrice"] = self.itemInfoDataObject.itemPricingArray[0][@"UnitPrice"];
        receiveItemDetail[@"CostPrice"] = self.itemInfoDataObject.itemPricingArray[0][@"Cost"];
        
        receiveItemDetail[@"ReOrderCase"] = self.itemInfoDataObject.itemPricingArray[1][@"ReceivedQty"];
        receiveItemDetail[@"ReOrderPack"] = self.itemInfoDataObject.itemPricingArray[2][@"ReceivedQty"];
        
        receiveItemDetail[@"CaseCost"] = self.itemInfoDataObject.itemPricingArray[1][@"Cost"];
        receiveItemDetail[@"CasePrice"] = self.itemInfoDataObject.itemPricingArray[1][@"UnitPrice"];
        
        receiveItemDetail[@"PackCost"] = self.itemInfoDataObject.itemPricingArray[2][@"Cost"];
        receiveItemDetail[@"PackPrice"] = self.itemInfoDataObject.itemPricingArray[2][@"UnitPrice"];
    }
    
    else{
        
        receiveItemDetail[@"IsReturn"] = @(isReturn);
        receiveItemDetail[@"ReOrder"] = self.itemInfoDataObject.itemPricingArray[0][@"ReceivedQty"];
        receiveItemDetail[@"FreeGoodsQty"] = @([freeSingleValue intValue]);
        receiveItemDetail[@"ProfitAmt"] = self.itemInfoDataObject.itemPricingArray[0][@"Profit"];
        receiveItemDetail[@"SalesPrice"] = self.itemInfoDataObject.itemPricingArray[0][@"UnitPrice"];
        receiveItemDetail[@"CostPrice"] = self.itemInfoDataObject.itemPricingArray[0][@"Cost"];
        receiveItemDetail[@"ReOrderCase"] = self.itemInfoDataObject.itemPricingArray[1][@"ReceivedQty"];
        receiveItemDetail[@"ReOrderPack"] = self.itemInfoDataObject.itemPricingArray[2][@"ReceivedQty"];
    }
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
    
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                    [self updateItemInformation];
                    [self doUpdateForItemUpdate];

            }
            else if ([[response  valueForKey:@"IsError"] intValue] == -2) {
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n UPC is already exists"};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Item Update" message:@"Error code : 104 \n UPC is already exists" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                self.itemInfoDataObject.Barcode = @"";
            }
            else{
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Item Update" message:@"Error code : 104 \n Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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
            [self.rmsDbController popupAlertFromVC:self title:@"Item Update" message:@"Your request is not processed successfully, Plz try again." buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
        }
    }
    
}

-(void)doUpdateForItemUpdate{
    
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    });
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
     [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if(responseData.count > 0)
                {
                    NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if(self.isDelivery){
                            [self callWCforPoReceiveItemUpdate];
                        }
                        else{
                            
                            [self updateItemInformation];
                            [self.itemDetailDelegate didChangeItemDetail:receiveItemDetail];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        
                        [self.updateManager liveUpdateFromResponseDictionary:responseDictionary];
                        [self.itemDetailDelegate didChangeItemDetail:receiveItemDetail];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }
            else if([[response valueForKey:@"IsError"] intValue] == -1)
            {
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Item Update" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            
        }
    }
}


-(IBAction)logoutButton:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewCon in viewControllers) {
        if([viewCon isKindOfClass:[RimLoginVC class]]){
            [self.navigationController popToViewController:viewCon animated:YES];
        }
    }
}
-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
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
