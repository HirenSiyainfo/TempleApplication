//
//  ItemInfoViewController.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Department+Dictionary.h"
#import "DisplayItemInfoSideVC.h"
#import "ItemSupplier+Dictionary.h"
#import "ItemTag+Dictionary.h"
#import "ItemTax+Dictionary.h"
#import "RimsController.h"
#import "RmsDbController.h"
#import "SizeMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "SupplierMaster+Dictionary.h"
#import "TaxMaster+Dictionary.h"


//#import "ItemInfoEditVC.h"
#import "Item+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "SupplierRepresentative+Dictionary.h"
//cell
#import "ItemSideInfoImageCell.h"
#import "ItemSideInfoCell.h"
#import "ItemSideInfoProfitCell.h"
typedef enum __SECTION_NAMES__
{
    SECTION_NAMES_ITEM_IMAGE,
    SECTION_NAMES_ITEM_PRICE,
    SECTION_NAMES_ITEM_PROFIT,
    SECTION_NAMES_ITEM_SOLD,
    SECTION_NAMES_ITEM_INVOICE,
    SECTION_NAMES_ITEM_RECEIVED,
    SECTION_NAMES_ITEM_STATUS,
    SECTION_NAMES_ITEM_TAP_NEW_ORDER,
    SECTION_NAMES_ITEM_SUPPLIER,
    SECTION_NAMES_ITEM_TAG,
    SECTION_NAMES_ITEM_NOTE,
} SECTION_NAMES;


@interface DisplayItemInfoSideVC () {
    NSArray * arrSectionList;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RimsController * rimsController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView *tblItemInfo;

@property (nonatomic, strong) NSArray *supllierListArray;
@property (nonatomic, strong) NSMutableArray *itemSupplieArray;
@property (nonatomic, strong) NSMutableArray *itemTagArray;

@end

@implementation DisplayItemInfoSideVC

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
    if (!self.itemInfoDictionary) {
        self.itemInfoDictionary = [NSMutableDictionary dictionary];
    }
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.supllierListArray = [[NSArray alloc] init];
    self.itemSupplieArray = [[NSMutableArray alloc] init];
    
    self.managedObjectContext=self.rmsDbController.managedObjectContext;
    [self getSupplierDataFromTable];
    [self getTagDataFromTable];
    [self.itemSupplieArray removeObject:@""];
    [self createSectionArray];
    [self.tblItemInfo reloadData];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)didUpdateItemInfo:(NSDictionary *)updatedItemInfo
{
    if (!self.itemInfoDictionary) {
        self.itemInfoDictionary = [NSMutableDictionary dictionary];
    }
    [self.itemInfoDictionary addEntriesFromDictionary:updatedItemInfo];
    if ([updatedItemInfo objectForKey:@"itemsupplierarray"]) {
        self.itemSupplieArray = [updatedItemInfo[@"itemsupplierarray"] mutableCopy];
    }
    else{
        [self getSupplierDataFromTable];

    }
    if ([updatedItemInfo objectForKey:@"responseTagArray"]) {
        self.itemTagArray = updatedItemInfo[@"responseTagArray"];
    }
    else{
        [self getTagDataFromTable];

    }
    [self.itemSupplieArray removeObject:@""];
    [self createSectionArray];
    [self.tblItemInfo reloadData];
}

-(void)getSupplierDataFromTable
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemSupplier" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d",[(self.itemInfoDictionary)[@"ItemId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *supplierListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    NSArray *filteredSupplier = [supplierListArray valueForKeyPath:@"@distinctUnionOfObjects.vendorId"];
    
    self.itemSupplieArray = [[NSMutableArray alloc] init];
    
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
            [self.itemSupplieArray addObject:supplierDict];
        }
    }
    NSArray * arrSupplierAll = [self.itemSupplieArray valueForKeyPath:@"SalesRepresentatives.FirstName"];
    NSMutableArray * arrSupplierName = [NSMutableArray array];
    for (NSArray * arrSupplier in arrSupplierAll) {
        if ([arrSupplier isKindOfClass:[NSArray class]] && arrSupplier.count > 0) {
            [arrSupplierName addObjectsFromArray:arrSupplier];
        }
    }
    NSSet * supplier = [[NSSet alloc]initWithArray:arrSupplierName];
    self.itemSupplieArray = [[NSMutableArray alloc] initWithArray:[supplier allObjects]];
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

-(void)getTagDataFromTable{
    self.itemTagArray=[[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTag" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%d",[(self.itemInfoDictionary)[@"ItemId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *tagListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    NSMutableArray *arrayMainTagList=[[NSMutableArray alloc]init];
    for (int i=0; i<tagListArray.count; i++){
        ItemTag *tag=tagListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SizeMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sizeId==%d",(tag.sizeId).integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemSizeName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemSizeName.count > 0){
            SizeMaster *size=itemSizeName.firstObject;
            [arrayMainTagList addObject:size.sizeName];
        }
    }
    self.itemTagArray=[[NSMutableArray alloc]initWithArray:arrayMainTagList];
}

-(void)createSectionArray{
    NSMutableArray * arrSections = [@[@(SECTION_NAMES_ITEM_IMAGE),@(SECTION_NAMES_ITEM_PRICE),@(SECTION_NAMES_ITEM_SOLD),@(SECTION_NAMES_ITEM_INVOICE),@(SECTION_NAMES_ITEM_RECEIVED),@(SECTION_NAMES_ITEM_STATUS)] mutableCopy];
    
    if (self.itemSupplieArray.count > 0) {
        [arrSections addObject:@(SECTION_NAMES_ITEM_SUPPLIER)];
        
    }
    if (self.itemTagArray.count > 0) {
        [arrSections addObject:@(SECTION_NAMES_ITEM_TAG)];
        
    }

    arrSectionList = arrSections;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSectionList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height;
    SECTION_NAMES section = (SECTION_NAMES)[arrSectionList[indexPath.section] integerValue];
    switch (section) {
        case SECTION_NAMES_ITEM_IMAGE :{
             height = 217;
            break;
        }
        case SECTION_NAMES_ITEM_PRICE : {
            height = 132;
            break;
        }
        case SECTION_NAMES_ITEM_PROFIT:{
            height = 50;
            break;
        }
        case SECTION_NAMES_ITEM_SOLD :
        case SECTION_NAMES_ITEM_INVOICE :
        case SECTION_NAMES_ITEM_RECEIVED :
        case SECTION_NAMES_ITEM_STATUS :{
            height = 50;
            break;
        }
        case SECTION_NAMES_ITEM_TAP_NEW_ORDER :{
            height = 50;
            break;
        }
        case SECTION_NAMES_ITEM_SUPPLIER:{
            
            CGSize constraintSize;
            constraintSize.width = 206;
            constraintSize.height = 990;
            
            NSString *remarkText = [self.itemSupplieArray componentsJoinedByString:@", "];
            UIFont *nameFont = [UIFont fontWithName:@"Lato-Regular" size:14.0];
            CGRect textRect = [remarkText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:nameFont} context:nil];
            CGSize size = textRect.size;
            float cellheight = size.height + 32.0f;
            cellheight = (cellheight > 55)?cellheight:55;
            height = cellheight;
            break;
        }
        case SECTION_NAMES_ITEM_TAG : {
            CGSize constraintSize;
            constraintSize.width = 206;
            constraintSize.height = 990;
            
            NSString *remarkText = [self.itemTagArray componentsJoinedByString:@", "];
            UIFont *nameFont = [UIFont fontWithName:@"Lato-Regular" size:14.0];
            CGRect textRect = [remarkText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:nameFont} context:nil];
            CGSize size = textRect.size;
            float cellheight = size.height + 32.0f;
            cellheight = (cellheight > 50)?cellheight:50;
            height = cellheight;
            
            break;
        }
        case SECTION_NAMES_ITEM_NOTE : {
            CGSize constraintSize;
            constraintSize.width = 206;
            constraintSize.height = 990;
            
            NSString *remarkText = self.itemInfoDictionary[@"CashierNote"];
            UIFont *nameFont = [UIFont fontWithName:@"Lato-Regular" size:14.0];
            CGRect textRect = [remarkText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:nameFont} context:nil];
            CGSize size = textRect.size;
            float cellheight = size.height + 32.0f;
            cellheight = (cellheight > 50)?cellheight:50;
            height = cellheight;
            
            break;
        }
        default:
            height = 44.0;
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSString *)checkLastReceivedDate:(NSString *)strlastReceivedDate_p
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMMM dd, yyyy";
    df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *dt1 = [df dateFromString:@"January 01, 2015"];
    NSDate *dt2 = [df dateFromString:strlastReceivedDate_p];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
        case NSOrderedAscending:
            break;
        case NSOrderedDescending:
            strlastReceivedDate_p = @"";
            break;
        case NSOrderedSame:
            break;
        default:
            strlastReceivedDate_p = @"";
            break;
    }
    return strlastReceivedDate_p;
}

// custom view for header. will be adjusted to default or specified header height
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *celliteminfo = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];//
    celliteminfo.selectionStyle = UITableViewCellSelectionStyleNone;
    celliteminfo.backgroundColor = [UIColor clearColor];
    SECTION_NAMES section = (SECTION_NAMES)[arrSectionList[indexPath.section] integerValue];
    switch (section) {
        case SECTION_NAMES_ITEM_IMAGE :{
            
            ItemSideInfoImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemImageCell" forIndexPath:indexPath];
            

            cell.lblName.text = [self getStringFromKey:@"ItemName"];
            UIFont * bold = [UIFont fontWithName:@"Lato-Bold" size:14.0];
            UIFont * ragular = [UIFont fontWithName:@"Lato" size:14.0];
            
            NSMutableAttributedString * itemUPC = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"UPC %@",[self getStringFromKey:@"Barcode"]]];
            [itemUPC addAttribute:NSFontAttributeName value:bold range:NSMakeRange(0,3)];
            [itemUPC addAttribute:NSFontAttributeName value:ragular range:NSMakeRange(4,itemUPC.length-4)];
            cell.lblUPC.attributedText = itemUPC;

            NSMutableAttributedString * itemDept = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"DEPT %@",[self getStringFromKey:@"DepartmentName"]]];
            [itemDept addAttribute:NSFontAttributeName value:bold range:NSMakeRange(0,4)];
            [itemDept addAttribute:NSFontAttributeName value:ragular range:NSMakeRange(5,itemDept.length-5)];
            cell.lblDept.attributedText = itemDept;
            
            NSMutableAttributedString * itemQty = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"QUANTITY %@",[self getStringFromKey:@"avaibleQty"]]];
            [itemQty addAttribute:NSFontAttributeName value:bold range:NSMakeRange(0,8)];
            [itemQty addAttribute:NSFontAttributeName value:ragular range:NSMakeRange(9,itemQty.length-9)];
            cell.lblQty.attributedText = itemQty;
            
            if ([self.itemInfoDictionary[@"ItemImage"] isKindOfClass:[UIImage class]])
            {
                UIImage *img = (self.itemInfoDictionary)[@"ItemImage"];
                cell.asyItemImage_Item.image = img;
            }
            else
            {
                NSString *imageImage=self.itemInfoDictionary[@"ItemImage"];
                if (imageImage == nil || [imageImage isEqualToString:@""] || imageImage.length == 0) {
                    cell.asyItemImage_Item.image = [UIImage imageNamed:@"noimage.png"];
                }
                else {
                    [cell.asyItemImage_Item loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
                }
            }
            cell.asyItemImage_Item.layer.borderWidth = 2.0f;
            cell.asyItemImage_Item.layer.borderColor = [UIColor colorWithRed:0.847 green:0.851 blue:0.855 alpha:1.000].CGColor;
            
            [cell.btnSelectImage addTarget:self action:@selector(clickImageCapture:) forControlEvents:UIControlEventTouchUpInside];
            
            celliteminfo = cell;
            
            break;
        }
        case SECTION_NAMES_ITEM_PRICE :{
            
            ItemSideInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemPriceCell" forIndexPath:indexPath];
            if (!self.itemInfoDictionary[@"CostPrice"]) {
                self.itemInfoDictionary[@"CostPrice"] = @"0";
            }
            if (!self.itemInfoDictionary[@"AverageCost"]) {
                self.itemInfoDictionary[@"AverageCost"] = @"0";
            }
            if (!self.itemInfoDictionary[@"SalesPrice"]) {
                self.itemInfoDictionary[@"SalesPrice"] = @"0";
            }
            cell.lblDisp1.text = [self.rmsDbController getStringPriceFromFloat:[self.itemInfoDictionary[@"CostPrice"] floatValue]];
            cell.lblDisp2.text = [self.rmsDbController getStringPriceFromFloat:[self.itemInfoDictionary[@"AverageCost"] floatValue]];
            cell.lblDisp3.text = [self.rmsDbController getStringPriceFromFloat:[self.itemInfoDictionary[@"SalesPrice"] floatValue]];
            NSString *strmargin = [self calculateMarginCost:self.itemInfoDictionary[@"CostPrice"] profit:self.itemInfoDictionary[@"ProfitAmt"] sales:self.itemInfoDictionary[@"SalesPrice"]];
            
            cell.lblDisp4.text = [NSString stringWithFormat:@"%@%%",strmargin];
            
            NSString *strmarkupn = [self calculateMarkUpCost:[self.itemInfoDictionary[@"CostPrice"] floatValue] Sales:[self.itemInfoDictionary[@"SalesPrice"] floatValue]];
                                    
            cell.lblDisp5.text = [NSString stringWithFormat:@"%@%%",strmarkupn];
            
            celliteminfo = cell;
            break;
        }
        case SECTION_NAMES_ITEM_PROFIT :{
            
            ItemSideInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemProfitCell" forIndexPath:indexPath];
            NSString *strmargin = [self calculateMarginCost:self.itemInfoDictionary[@"CostPrice"] profit:self.itemInfoDictionary[@"ProfitAmt"] sales:self.itemInfoDictionary[@"SalesPrice"]];
            
            cell.lblValue.text = [NSString stringWithFormat:@"%@%%",strmargin];
            
            celliteminfo = cell;
            break;
        }
        case SECTION_NAMES_ITEM_SOLD :{
            
            ItemSideInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemSupplierTagCell" forIndexPath:indexPath];

            cell.lblTitle.text = @"LAST SOLD";
            cell.imgImage.image = [UIImage imageNamed:@"RIM_Lastsold_Icon_17px"];
            cell.lblValue.text = @"----";
            
            NSDate *lastSDate = [self.itemInfoDictionary[@"lastSoldDate"] copy];
            NSString * strlastSoldDate =  [self getLastReceivingDate:lastSDate];
            
            strlastSoldDate = [self checkLastReceivedDate:strlastSoldDate];
            
            if (strlastSoldDate != nil && strlastSoldDate.length > 0) {
                cell.lblValue.text =[NSString stringWithFormat:@"%@",strlastSoldDate];
            }
            
            celliteminfo = cell;
            break;
        }
        case SECTION_NAMES_ITEM_INVOICE :{
            
            ItemSideInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemSupplierTagCell" forIndexPath:indexPath];
            
            cell.lblTitle.text = @"LAST INVOICE";
            cell.imgImage.image = [UIImage imageNamed:@"RIM_Invoice_Icon_17px"] ;
            cell.lblValue.text = [self getStringFromKey:@"LastInvoice"];
            
            celliteminfo = cell;
            break;
        }
        case SECTION_NAMES_ITEM_RECEIVED :{
            
            ItemSideInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemSupplierTagCell" forIndexPath:indexPath];
            
            NSDate *lastRDate = [self.itemInfoDictionary[@"LastReceivedDate"] copy];
            NSString * strlastReceivedDate =  [self getLastReceivingDate:lastRDate];
            
            strlastReceivedDate = [self checkLastReceivedDate:strlastReceivedDate];
            
            cell.lblTitle.text = @"LAST RECEIVED";
            cell.imgImage.image = [UIImage imageNamed:@"RIM_Lastreceived_Icon_17px"];
            cell.lblValue.text = @"----";
            
            if (strlastReceivedDate != nil && strlastReceivedDate.length > 0) {
                cell.lblValue.text =[NSString stringWithFormat:@"%@",strlastReceivedDate];
            }
            
            celliteminfo = cell;
            break;
        }
        case SECTION_NAMES_ITEM_STATUS :{
            
            ItemSideInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemSupplierTagCell" forIndexPath:indexPath];
            
            cell.lblTitle.text = @"ORDER STATUS";
            cell.imgImage.image = [UIImage imageNamed:@"RIM_OrderStatus_Icon_17px"];
            cell.lblValue.text = [self getStringFromKey:@"orderStatus"];
            
            celliteminfo = cell;
            break;
        }
        case SECTION_NAMES_ITEM_TAP_NEW_ORDER :{
            
            celliteminfo = [tableView dequeueReusableCellWithIdentifier:@"itemNewOrderCell" forIndexPath:indexPath];
            break;
        }
        case SECTION_NAMES_ITEM_SUPPLIER :{
            
            ItemSideInfoCell *cell= [tableView dequeueReusableCellWithIdentifier:@"itemSupplierTagCell" forIndexPath:indexPath];
            
            cell.lblTitle.text = @"SUPPLIER";
            cell.imgImage.image = [UIImage imageNamed:@"RIM_Supplier_Icon_17px"];
            cell.lblValue.text = [self.itemSupplieArray componentsJoinedByString:@", "];

            celliteminfo = cell;
            break;
        }
        case SECTION_NAMES_ITEM_TAG :{
            
            ItemSideInfoCell *cell= [tableView dequeueReusableCellWithIdentifier:@"itemSupplierTagCell" forIndexPath:indexPath];
            cell.lblTitle.text = @"TAGS";
            cell.imgImage.image = [UIImage imageNamed:@"RIM_Tag_Icon_17px"];
            cell.lblValue.text = [self.itemTagArray componentsJoinedByString:@", "];
            celliteminfo = cell;
            break;
        }
        case SECTION_NAMES_ITEM_NOTE :{
            
            ItemSideInfoCell *cell= [tableView dequeueReusableCellWithIdentifier:@"itemSupplierTagCell" forIndexPath:indexPath];
            cell.lblTitle.text = @"CASHIER NOTE";
            cell.lblValue.text = [self getStringFromKey:@"CashierNote"];
            celliteminfo = cell;
            break;
        }
        default:
            break;
    }
//    if (indexPath.section == REMARKS_SECTION)
//    {
//        ItemSideInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemInfoCell" forIndexPath:indexPath];
//        if (indexPath.row == 0) {
//            
//            if((self.itemInfoDictionary)[@"CashierNote"] == nil) {
//                cell.lblValue.text = @"";
//            }
//            else {
//                cell.lblValue.text = [NSString stringWithFormat:@"%@",self.itemInfoDictionary[@"CashierNote"]];
//            }
//            cell.lblTitle.text = @"Cashier Note";
//        }
//        celliteminfo = cell;
//    }
    celliteminfo.contentView.backgroundColor = [UIColor clearColor];
    celliteminfo.backgroundColor = [UIColor clearColor];
    return celliteminfo;
}
-(NSString *)getStringFromKey:(NSString *)strKey{
    NSString * strValue = self.itemInfoDictionary[strKey];
    if (strValue && strValue.length > 0) {
        return strValue;
    }
    else{
        return @"----";
    }
}
- (Item*)fetchAllItems:(NSString *)itemId moc:(NSManagedObjectContext *)moc
{
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

-(NSString *)getDicountedPrice{
    
    NSString *sPrice;
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.maximumFractionDigits = 2;
    
    NSManagedObjectContext *context = self.managedObjectContext;
    Item *anItem = [self fetchAllItems:(self.itemInfoDictionary)[@"ItemId"] moc:context];
    
    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    for (Item_Discount_MD *idiscMd in anItem.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    
    Item_Discount_MD2 *idiscMd2=nil;
    
    if(itemDiscArray.count>0)
    {
        for (int idisc=0; idisc<itemDiscArray.count; idisc++)
        {
            idiscMd2=itemDiscArray[idisc];
            NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;
            if(idiscMd2.dayId.integerValue==-1 && iDiscqty==1)
            {
                NSNumber *numerPrice=@(idiscMd2.md2Tomd.dis_UnitPrice.floatValue);
                sPrice =[NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:numerPrice]];
            }
        }
    }
    
    return sPrice;
}
-(NSString *)getLastReceivingDate:(NSDate *)pdate{
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"MMMM dd, yyyy";
    df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSString *result = [df stringFromDate:pdate];
    return result;
}


- (NSString *)calculateMarkUpCost:(NSString *)costPrice profit:(NSString *)profitAmount sales:(NSString *)salesPrice
{
    NSString *strMarkup=@"";
    
    NSString *tempCost = [costPrice stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    tempCost = [tempCost stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *tempSales = [salesPrice stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    tempSales = [tempSales stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    if((![salesPrice isEqualToString:@""])||(![costPrice isEqualToString:@""]))
    {
        float dProfitAmt=0;
        float dsellingAmt=tempSales.floatValue;
        float dcostAmt=tempCost.floatValue;
        if(dcostAmt == 0)
        {
            dProfitAmt=((dsellingAmt-dcostAmt)*100);
            strMarkup=[NSString stringWithFormat:@"%.2f",dProfitAmt];
        }
        else
        {
            dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
            strMarkup=[NSString stringWithFormat:@"%.2f",dProfitAmt];
        }
        if([strMarkup isEqualToString:@"nan"] || [strMarkup isEqualToString:@"-inf"] || [strMarkup isEqualToString:@"inf"] || [strMarkup isEqualToString:@"-100.00"] || [strMarkup isEqualToString:@"NaN"])
        {
            strMarkup=@"0.00";
        }
    }
    return strMarkup;
}

- (NSString *)calculateMarginCost:(NSString *)costPrice profit:(NSString *)profitAmount sales:(NSString *)salesPrice
{
    NSString *strMarginCost=@"";
    
    NSString *tempCost = [costPrice stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    tempCost = [tempCost stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    NSString *tempSales = [salesPrice stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    tempSales = [tempSales stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    if((![salesPrice isEqualToString:@""])||(![costPrice isEqualToString:@""]))
    {
        float dProfitAmt = 0;
        float dsellingAmt = tempSales.floatValue;
        float dcostAmt = tempCost.floatValue;
        dProfitAmt = (1 - (dcostAmt/dsellingAmt)) * 100;
        strMarginCost = [NSString stringWithFormat:@"%.2f",dProfitAmt];
        
        if([strMarginCost isEqualToString:@"nan"] || [strMarginCost isEqualToString:@"-inf"] || [strMarginCost isEqualToString:@"inf"] || [strMarginCost isEqualToString:@"-100.00"] || [strMarginCost isEqualToString:@"NaN"])
        {
            strMarginCost = @"0.00";
        }
        
    }
    
    
    return strMarginCost;
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

-(void)clickImageCapture:(UIButton *)sender
{
//    self.objAddItem.objItemInfo = self;
//    [self.objAddItem selectImageCapture:sender];
    [self.displayItemInfoSideVCDeledate willChangeItemSelectedImage:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
