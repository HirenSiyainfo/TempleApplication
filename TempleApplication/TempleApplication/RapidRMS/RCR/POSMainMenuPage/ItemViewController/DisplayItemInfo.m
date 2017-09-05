//
//  ItemInfoViewController.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DisplayItemInfo.h"
#import "Item+Dictionary.h"
#import "SizeMaster+Dictionary.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "ItemTax+Dictionary.h"
#import "TaxMaster+Dictionary.h"
#import "ItemTag+Dictionary.h"
#import "ItemSupplier+Dictionary.h"
#import "RmsDbController.h"
#import "Department+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "InvoiceDetailsCell.h"

typedef enum __SECTION_NAMES__
{
    IMAGE_SECTION,
    PRICE_SECTION,
    MARGIN_SECTION,
    MIN_MAX_SECTION,
    VENDER_SECTION,
    TAG_SECTION,
    CASHIER_NOTE_SECTION,
    ITEM_INVOICE_DETAIL_SECTION,
} SECTION_NAMES;


@interface DisplayItemInfo () <NSFetchedResultsControllerDelegate>
{
}

@property (nonatomic, weak) IBOutlet UITableView *tblItemInfo;
@property (nonatomic, weak) IBOutlet UITableView *tblSupllierItemList;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *itemSupplieArray;
@property (nonatomic, strong) NSMutableArray *tagArray;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *itemDisplayResultController;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) RapidWebServiceConnection * itemHistoryListWC;
@property (nonatomic) BOOL isDataFound;

@end

@implementation DisplayItemInfo
@synthesize itemInfoDictionary;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize itemDisplayResultController = __itemDisplayResultController;

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
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemSupplieArray = [[NSMutableArray alloc]init];
    self.tagArray= [[NSMutableArray alloc]init];

    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    [self getSupplierDataFromTable];
    [self getTagDataFromTable];
    [self getInvoiceHistoryData];
    _isDataFound = false;
    _arrData = [[NSMutableArray alloc]init];
  
    [_tblItemInfo registerNib:[UINib nibWithNibName:@"InvoiceDetailsCell" bundle:nil] forCellReuseIdentifier:@"invoiceDetail"];
    [_tblItemInfo reloadData];

    [self itemDisplayResultController];
    // Do any additional setup after loading the view from its nib.
}

- (void)getInvoiceHistoryData
{

    NSMutableDictionary *invHistoryDict = [[NSMutableDictionary alloc] init];
    invHistoryDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString * itemId = (self.itemInfoDictionary)[@"ItemId"];
    if (itemId.length>0) {
        invHistoryDict[@"ItemCode"] = itemId;
    }
    else{
        invHistoryDict[@"ItemCode"] = @"";
    }
//     New field added - LocalDate
   
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *LocalDate = [formatter stringFromDate:date];
    invHistoryDict[@"LocalDate"] = LocalDate;
    
    if (self.itemHistoryListWC) {
        [self.itemHistoryListWC.downloadTask cancel];
    }
    _isDataFound = FALSE;

    AsyncCompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseInvoiceHistoryData2Response:response error:error];
            self.itemHistoryListWC = nil;
        });
    };
    self.itemHistoryListWC = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL actionName:WSM_INVOICE_ITEM_HISTORY_LIST params:invHistoryDict asyncCompletionHandler:completionHandler];
}
- (void)responseInvoiceHistoryData2Response:(id)response error:(NSError *)error {
        if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _arrData = [[[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject] valueForKey:@"InvoiceHistory"];
                _isDataFound = TRUE;
            }
            else{
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"please check the internet connection or contact to rapidrms" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
    }
    [self.tblItemInfo reloadData];
}

-(void)getSupplierDataFromTable
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemSupplier" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d",[(self.itemInfoDictionary)[@"ItemId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *supllierListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    self.itemSupplieArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<supllierListArray.count; i++)
    {
        ItemSupplier *supplier=supllierListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %d",supplier.vendorId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemSizeName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemSizeName.count>0)
        {
            SupplierCompany *supplier=itemSizeName.firstObject;
            NSMutableDictionary *tagDict=[[NSMutableDictionary alloc]init];
            tagDict[@"SupplierName"] = supplier.companyName;
            tagDict[@"ContactNo"] = supplier.phoneNo;
            tagDict[@"Id"] = supplier.companyId;
            tagDict[@"CompanyName"] = supplier.companyName;
            [self.itemSupplieArray addObject:tagDict];
        }
    }
}
-(void)getTagDataFromTable{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTag" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId==%d",[(self.itemInfoDictionary)[@"ItemId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *tagListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    self.tagArray=[[NSMutableArray alloc]init];
    for (int i=0; i<tagListArray.count; i++)
    {
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
            [self.tagArray addObject:tagDict];
        }
    }
   
}


#pragma mark - CoreData Methods
- (NSFetchedResultsController *)itemDisplayResultController
{
    if (__itemDisplayResultController != nil) {
        return __itemDisplayResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 20;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode == %d",[(self.itemInfoDictionary)[@"ItemId"] integerValue]];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item_Desc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    __itemDisplayResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    __itemDisplayResultController.delegate = self;
    [__itemDisplayResultController performFetch:nil];
    
    return __itemDisplayResultController;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==_tblItemInfo)
    {
        return 7;
    }
    else
    {
        return 1;
    }
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==_tblItemInfo)
    {
        if (section==IMAGE_SECTION)
        {
            return 1;
        }
        if (section==MARGIN_SECTION)
        {
            return 1;
        }
        if (section==MIN_MAX_SECTION)
        {
            return 1;
        }
        if (section == ITEM_INVOICE_DETAIL_SECTION)
        {
            return _arrData.count+1;
        }
        if (section==PRICE_SECTION)
        {
            return 1;
        }
        if (section==TAG_SECTION)
        {
            return self.tagArray.count;
        }
        if (section==VENDER_SECTION)
        {
            return self.itemSupplieArray.count;
        }
        if (section==CASHIER_NOTE_SECTION)
        {
            return 1;
        }
    }
    else if (tableView==_tblSupllierItemList)
    {
        return self.itemSupplieArray.count;
    }
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_tblItemInfo) {
        
        if (indexPath.section==IMAGE_SECTION)
        {
            return 125;
        }
        if (indexPath.section==MARGIN_SECTION)
        {
            return 90;
        }
        if (indexPath.section==MIN_MAX_SECTION)
        {
            return 90;
        }
        if (indexPath.section == ITEM_INVOICE_DETAIL_SECTION)
        {
            return 44;
        }

        if (indexPath.section==PRICE_SECTION)
        {
            return 110;
        }
        if (indexPath.section==TAG_SECTION)
        {
            return 30;
        }
        if (indexPath.section==VENDER_SECTION)
        {
            return 25;
        }
        if (indexPath.section==CASHIER_NOTE_SECTION)
        {
            if ([(self.itemInfoDictionary)[@"Cashier Note"] length]==0 )
            {
                return 0;
            }
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Lato" size:14.00]};
            
            NSString *cashierLable = (self.itemInfoDictionary)[@"Cashier Note"];
            CGRect calculatedRect = [cashierLable boundingRectWithSize:CGSizeMake(325, 100) options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:attributes context:[[NSStringDrawingContext alloc] init]];
            
            return calculatedRect.size.height;
            
        }
    }
    else if (tableView==_tblSupllierItemList)
    {
        return 22;
        
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headeHeight = 0;
    switch (section) {
        case TAG_SECTION:
        case VENDER_SECTION:
        case ITEM_INVOICE_DETAIL_SECTION:
        case CASHIER_NOTE_SECTION:
            headeHeight = 30;
            break;
            
        default:
            break;
    }
    return headeHeight ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 300, 18)];
    /* Create custom view to display section header... */
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 100, 25)];
    lable1.textAlignment=NSTextAlignmentLeft;
    lable1.textColor = [UIColor blackColor];
    lable1.backgroundColor=[UIColor clearColor];
    lable1.font = [UIFont fontWithName:@"Lato-Bold" size:16.00];
    
    if (section==TAG_SECTION)
    {
        lable1.text = @"Tag";
    }
   else if (section==VENDER_SECTION)
    {
        lable1.text = @"Vender";
    }
    else if (section==CASHIER_NOTE_SECTION)
    {
        if ([[self.self.itemInfoDictionary valueForKey:@"Cashier Note"] isEqualToString:@""])
        {
            lable1.text = @"";
        }
        else{
            lable1.text = @"Cashier Note";
  
        }
    }
    else if (section==ITEM_INVOICE_DETAIL_SECTION)
    {
        lable1.text = @"Invoices";
    }

    [view addSubview:lable1];
    return view;
}
// custom view for header. will be adjusted to default or specified header height


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *lblItemName;
    UILabel *lblBarcode;
    UILabel *lblPrice;
    UILabel *lblDepartmentName;

    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];//
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (tableView==_tblItemInfo)
    {
        if (indexPath.section==IMAGE_SECTION) {
            if (indexPath.row==0)
            {
                self.itemImage_Item = [[AsyncImageView alloc] initWithFrame:CGRectMake(20, 20, 90, 90)];
                self.itemImage_Item.backgroundColor = [UIColor clearColor];
                self.itemImage_Item.layer.cornerRadius = self.itemImage_Item.frame.size.width/2;
                 self.itemImage_Item.clipsToBounds = YES;
                
                if ([(self.itemInfoDictionary)[@"ItemImage"] isKindOfClass:[UIImage class]])
                {
                    UIImage *img = (self.itemInfoDictionary)[@"ItemImage"];
                    self.itemImage_Item.image = img;
                }
                else
                {
                    NSString *imageImage=(self.itemInfoDictionary)[@"ItemImage"];
                    if ([imageImage isEqualToString:@""])
                    {
                        self.itemImage_Item.image = [UIImage imageNamed:@"RCR_NoImageForRingUp.png"];
                    }
                    else
                    {
                        [self.itemImage_Item loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
                    }
                }
                [cell.contentView addSubview:self.itemImage_Item];
                
                lblItemName = [[UILabel alloc] initWithFrame:CGRectMake(120, 45, 230, 20)];
                lblItemName.text = [NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"ItemName"]];
                lblItemName.textAlignment=NSTextAlignmentLeft;
                lblItemName.backgroundColor=[UIColor clearColor];
                lblItemName.textColor = [UIColor blackColor];
                lblItemName.numberOfLines = 2;
               // lblItemName.lineBreakMode = NSLineBreakByWordWrapping;
                lblItemName.font = [UIFont fontWithName:@"Lato" size:15.00];
                [cell addSubview:lblItemName];
                
                lblBarcode = [[UILabel alloc] initWithFrame:CGRectMake(120, 70, 230, 20)];
                lblBarcode.text = [NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"Barcode"]];
                lblBarcode.textAlignment=NSTextAlignmentLeft;
                lblBarcode.backgroundColor=[UIColor clearColor];
                lblBarcode.textColor = [UIColor colorWithRed:0.988 green:0.624 blue:0.043 alpha:1.000];
                lblBarcode.font = [UIFont fontWithName:@"Lato-Regular" size:14.00];
                   [cell addSubview:lblBarcode];

            }
        }
        
        if (indexPath.section==MARGIN_SECTION) {
            if (indexPath.row==0)
            {
                UIView *viewBG = [[UIView alloc]initWithFrame:CGRectMake(20, 10, 325, 75)];
                viewBG.layer.cornerRadius = 10.0;
                viewBG.layer.borderWidth = 1.0;
                viewBG.layer.borderColor = [UIColor colorWithWhite:0.000 alpha:0.250].CGColor;
                viewBG.backgroundColor = [UIColor clearColor];
                
                UILabel *lblQTY = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 160, 40)];
                lblQTY.text = [NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"availableQty"]];
                lblQTY.textAlignment=NSTextAlignmentCenter;
                lblQTY.textColor = [UIColor colorWithRed:0.996 green:0.624 blue:0.043 alpha:1.000];
                lblQTY.font = [UIFont fontWithName:@"Lato-Bold" size:30.00];
                [viewBG addSubview:lblQTY];
                
                UILabel *margIn1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, 160, 25)];
                margIn1.text = @"Quantity";
                margIn1.textAlignment=NSTextAlignmentCenter;
                margIn1.backgroundColor=[UIColor clearColor];
                margIn1.textColor = [UIColor blackColor];
                margIn1.font = [UIFont fontWithName:@"Lato-Regular" size:15.00];
                [viewBG addSubview:margIn1];
               
                UIImageView *imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(163, 5, 1, 60) ];
                imgLine.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.250];
                [viewBG addSubview:imgLine];

                NSNumber *numerCost=@([(self.itemInfoDictionary)[@"Price"] floatValue]);
                UILabel *lblPrc = [[UILabel alloc] initWithFrame:CGRectMake(165, 10, 160, 40)];
                lblPrc.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:numerCost]];
                lblPrc.textAlignment=NSTextAlignmentCenter;
                lblPrc.textColor = [UIColor colorWithRed:0.996 green:0.624 blue:0.043 alpha:1.000];
                lblPrc.font = [UIFont fontWithName:@"Lato-Bold" size:30.00];
                [viewBG addSubview:lblPrc];
                
                UILabel *MarkUp = [[UILabel alloc] initWithFrame:CGRectMake(165, 45, 160, 25)];
                MarkUp.text = @"Price";
                MarkUp.textAlignment=NSTextAlignmentCenter;
                MarkUp.backgroundColor=[UIColor clearColor];
                MarkUp.textColor = [UIColor blackColor];
                MarkUp.font = [UIFont fontWithName:@"Lato-Regular" size:15.00];
                [viewBG addSubview:MarkUp];
                [cell addSubview:viewBG];

            }
        }
        if (indexPath.section==MIN_MAX_SECTION) {
            if (indexPath.row==0)
            {
                UIView *viewBG = [[UIView alloc]initWithFrame:CGRectMake(20, 10, 325, 75)];
                viewBG.layer.cornerRadius = 10.0;
                viewBG.layer.borderWidth = 1.0;
                viewBG.layer.borderColor = [UIColor colorWithWhite:0.000 alpha:0.250].CGColor;
                viewBG.backgroundColor = [UIColor clearColor];
                
                UILabel *minValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 160, 40)];
                minValue.text = [NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"MinStockLevel"]];
                minValue.textAlignment=NSTextAlignmentCenter;
                minValue.textColor = [UIColor colorWithRed:0.996 green:0.624 blue:0.043 alpha:1.000];
                minValue.font = [UIFont fontWithName:@"Lato-Bold" size:30.00];
                [viewBG addSubview:minValue];
                
                UILabel *minLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, 160, 25)];
                minLabel.text = @"MINIMUM";
                minLabel.textAlignment=NSTextAlignmentCenter;
                minLabel.backgroundColor=[UIColor clearColor];
                minLabel.textColor = [UIColor blackColor];
                minLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15.00];
                [viewBG addSubview:minLabel];
                
                UIImageView *imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(163, 5, 1, 60) ];
                imgLine.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.250];
                [viewBG addSubview:imgLine];
                
                UILabel *maxValue = [[UILabel alloc] initWithFrame:CGRectMake(165, 10, 160, 40)];
                maxValue.text = [NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"MaxStockLevel"]];
                maxValue.textAlignment=NSTextAlignmentCenter;
                maxValue.textColor = [UIColor colorWithRed:0.996 green:0.624 blue:0.043 alpha:1.000];
                maxValue.font = [UIFont fontWithName:@"Lato-Bold" size:30.00];
                [viewBG addSubview:maxValue];
                
                UILabel *maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 45, 160, 25)];
                maxLabel.text = @"MAXIMUM";
                maxLabel.textAlignment=NSTextAlignmentCenter;
                maxLabel.backgroundColor=[UIColor clearColor];
                maxLabel.textColor = [UIColor blackColor];
                maxLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15.00];
                [viewBG addSubview:maxLabel];
                [cell addSubview:viewBG];
                
            }
        }
        if (indexPath.section == ITEM_INVOICE_DETAIL_SECTION)
        {
            if(_isDataFound)
            {
                if(indexPath.row == 0)
                {
                    if(_arrData.count > 1)
                    {
                        InvoiceDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invoiceDetail" forIndexPath:indexPath];
                        if(cell == nil)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InvoiceDetailsCell" owner:self options:nil];
                            cell = [nib objectAtIndex:0];
                        }
                        cell.invoiceNumber.text = @"Invoice#";
                        cell.itemQty.text = @"Quantity";
                        cell.invoiceDateTime.text = @"Invoice Date";
                        return cell;
                    }
                    else
                    {
                        cell.textLabel.text = @"No record found";
                        cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15.00];
                        return cell;
                    }
                }
                else
                {
                    InvoiceDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invoiceDetail" forIndexPath:indexPath];
                    if(cell == nil)
                    {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InvoiceDetailsCell" owner:self options:nil];
                        cell = [nib objectAtIndex:0];
                    }
                    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];

                    NSDate * date = [self.rmsDbController getDateFromJSONDate:_arrData[indexPath.row-1][@"InvoiceDate"]];
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    formatter.timeZone = sourceTimeZone;
                    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
                    
                    cell.invoiceNumber.text = [NSString stringWithFormat:@"%@",_arrData[indexPath.row-1][@"RegisterInvNo"]];
                    cell.itemQty.text = [NSString stringWithFormat:@"%@",_arrData[indexPath.row-1][@"ItemQty"]];
                    cell.invoiceDateTime.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
                    return cell;
                }
            }
            else
            {
                cell.textLabel.text = @"Loading..";
                cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15.00];
                return cell;
            }
        }

        if (indexPath.section==PRICE_SECTION) {
            if (indexPath.row==0)
            {
                lblPrice.textAlignment=NSTextAlignmentRight;
                lblPrice.backgroundColor=[UIColor clearColor];
                lblPrice.textColor = [UIColor blackColor];
                    ///// Item Number
                lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 100, 20)];
                lblPrice.text = [NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"ItemNo"]];
                lblPrice.textAlignment=NSTextAlignmentRight;
                lblPrice.font = [UIFont fontWithName:@"Lato-Bold" size:15.00];
                [cell addSubview:lblPrice];
                
                UILabel *cost = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
                cost.text = @"Item Number";
                cost.textAlignment=NSTextAlignmentLeft;
                cost.backgroundColor=[UIColor clearColor];
                cost.textColor = [UIColor blackColor];
                cost.font = [UIFont fontWithName:@"Lato-Regular" size:14.00];
                [cell addSubview:cost];
                
                UILabel *dept = [[UILabel alloc] initWithFrame:CGRectMake(20, 23, 100, 20)];
                dept.text = @"Department";
                dept.textAlignment=NSTextAlignmentLeft;
                dept.backgroundColor=[UIColor clearColor];
                dept.textColor = [UIColor blackColor];
                dept.font = [UIFont fontWithName:@"Lato-Regular" size:14.00];
                [cell addSubview:dept];
                
                
                lblDepartmentName = [[UILabel alloc] initWithFrame:CGRectMake(150, 23, 200, 20)];
                lblDepartmentName.text = [NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"DepartmentName"]];
                lblDepartmentName.textAlignment=NSTextAlignmentRight
                ;
                lblDepartmentName.backgroundColor=[UIColor clearColor];
                lblDepartmentName.textColor = [UIColor blackColor];
                lblDepartmentName.font = [UIFont fontWithName:@"Lato-Bold" size:15.00];
                [cell addSubview:lblDepartmentName];

                
                NSString *lastInvc=[NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"LastInvoice"]];
                lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(150, 46, 200, 20)];
                lblPrice.text = [NSString stringWithFormat:@"%@",lastInvc];
                lblPrice.textAlignment=NSTextAlignmentRight;
                lblPrice.font = [UIFont fontWithName:@"Lato-Bold" size:15.00];
                [cell addSubview:lblPrice];

                UILabel *lastInvoice = [[UILabel alloc] initWithFrame:CGRectMake(20, 46, 100, 20)];
                lastInvoice.text = @"Last Invoice";
                lastInvoice.textAlignment=NSTextAlignmentLeft;
                lastInvoice.backgroundColor=[UIColor clearColor];
                lastInvoice.textColor = [UIColor blackColor];
                lastInvoice.font = [UIFont fontWithName:@"Lato-Regular" size:14.00];
                [cell addSubview:lastInvoice];
                
                NSString *lastRecDate=[self stringConvertTo:[NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"LastReceivedDate"]]];
                NSRange searchResult = [lastRecDate rangeOfString:@"1900"];
                if (searchResult.location != NSNotFound)
                {
                    lastRecDate = @"-";
                }
            
                lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(150, 70, 200, 20)];
                lblPrice.text = [NSString stringWithFormat:@"%@",lastRecDate];
                lblPrice.textAlignment=NSTextAlignmentRight;
                lblPrice.font = [UIFont fontWithName:@"Lato-Bold" size:15.00];
                [cell addSubview:lblPrice];
                
                UILabel *lastRec = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 100, 20)];
                lastRec.text = @"Last Received";
                lastRec.textAlignment=NSTextAlignmentLeft;
                lastRec.backgroundColor=[UIColor clearColor];
                lastRec.textColor = [UIColor blackColor];
                lastRec.font = [UIFont fontWithName:@"Lato-Regular" size:14.00];
                [cell addSubview:lastRec];


            }
        }
        
        if (indexPath.section==TAG_SECTION) {
            
            UILabel * supplierName = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, 250, 16)];
            NSString * supplierCompanyName = [NSString stringWithFormat:@"%@",(self.tagArray)[indexPath.row][@"SizeName"]];
            supplierName.text = supplierCompanyName;
            supplierName.backgroundColor = [UIColor clearColor];
            supplierName.textColor = [UIColor blackColor];
            supplierName.textAlignment=NSTextAlignmentLeft;
            supplierName.textColor = [UIColor blackColor];
            supplierName.font =  [UIFont fontWithName:@"Lato-Regular" size:14.00];
            [cell.contentView addSubview:supplierName];
            
        }
        if (indexPath.section==VENDER_SECTION)
        {
            UILabel * supplierName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250, 15)];
            NSString * supplierCompanyName = [NSString stringWithFormat:@"%@",(self.itemSupplieArray)[indexPath.row][@"CompanyName"]];
            supplierName.text = supplierCompanyName;
            supplierName.backgroundColor = [UIColor clearColor];
            supplierName.textColor = [UIColor blackColor];
            supplierName.textAlignment=NSTextAlignmentLeft;
            supplierName.textColor = [UIColor blackColor];
            supplierName.font =  [UIFont fontWithName:@"Lato-Regular" size:14.00];
            [cell.contentView addSubview:supplierName];

        }
        if (indexPath.section==CASHIER_NOTE_SECTION)
        {
            if (indexPath.row==0)
            {
//                CGRect cellFrame = cell.frame;
//                cellFrame.size.height = 0;
//                cell.frame = cellFrame;
                UILabel *cashierNoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 330, 70)];
                cashierNoteLabel.textAlignment=NSTextAlignmentLeft;
                cashierNoteLabel.backgroundColor=[UIColor clearColor];
                cashierNoteLabel.textColor = [UIColor colorWithRed:(128.0/255.f) green:(128.0/255.f) blue:(128.0/255.f) alpha:1.0];
                cashierNoteLabel.numberOfLines = 0;
                cashierNoteLabel.text = [NSString stringWithFormat:@"%@",(self.itemInfoDictionary)[@"Cashier Note"]];
                cashierNoteLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cashierNoteLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14.00];
                [cashierNoteLabel sizeToFit];
                [cell addSubview:cashierNoteLabel];
            }
        }
    }
    return cell;
}

-(NSString*)stringConvertTo:(NSString *)strDate
{
    NSString *dateString = [NSString stringWithFormat:@"%@",strDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"dd-MM-yyyy hh:mm a"];
    NSString *stringDate = [dateFormatter1 stringFromDate:dateFromString];
    return stringDate;
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (![controller isEqual:self.itemDisplayResultController])
    {
        return;
    }
    
    UITableView *tableView = _tblItemInfo;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
//
        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
//
        case NSFetchedResultsChangeUpdate:
        {
            Item *anItem = [self.itemDisplayResultController objectAtIndexPath:indexPath];
            self.itemInfoDictionary = [self itemInfoDictionary:anItem];
            [self getSupplierDataFromTable];
            [self getTagDataFromTable];
            [tableView reloadData];
        }
            break;
            
        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (NSMutableDictionary *)itemInfoDictionary:(Item *)anItem
{
    NSMutableDictionary *dictItem = [anItem.itemDictionary mutableCopy];
    if (anItem.itemDepartment.deptName==nil)
    {
        dictItem[@"DepartmentName"] = @"";
    }
    else
    {
        dictItem[@"DepartmentName"] = anItem.itemDepartment.deptName;
    }
    
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
                NSString *sPrice =[NSString stringWithFormat:@"%@",numerPrice];
                dictItem[@"Price"] = sPrice;
            }
        }
    }
    return dictItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
