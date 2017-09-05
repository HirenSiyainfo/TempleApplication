//
//  HProductInfoVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HProductInfoVC.h"
#import "HItemHistoryInfoCell.h"
#import "HItemNameAndNumber.h"
#import "HItemStockInfo.h"
#import "HIItemAddOrderCell.h"
#import "RmsDbController.h"
#import "VPurchaseOrderItem+Dictionary.h"
#import "HPOItemListVC.h"
#import "HOpenOrderVC.h"
#import "Vendor_Item+Dictionary.h"

typedef NS_ENUM(NSUInteger, PRODUCT_INFO) {
    ITEM_NAME_BARCODE,
    ITEM_STOCK_INFO,
    ITEM_ADD_ORDER,
    ITEM_HISTORY
};

typedef NS_ENUM(NSUInteger, ITEM_INFO)
{
    ITEM_NUMBER,
    QTY_IN_STOCK,
    CASE_COST,
    CASE_MRSP,
    UNIT_PER_CASE,
    MARGIN,
};


@interface HProductInfoVC ()

@property (nonatomic, weak) IBOutlet UILabel *lblItemName;
@property (nonatomic, weak) IBOutlet UILabel *lblUPc;
@property (nonatomic, weak) IBOutlet UILabel *lblItemNumber;
@property (nonatomic, weak) IBOutlet UILabel *lblqtyinstock;
@property (nonatomic, weak) IBOutlet UILabel *lblunitcasemsrp;
@property (nonatomic, weak) IBOutlet UILabel *lblunitpercase;
@property (nonatomic, weak) IBOutlet UILabel *lblmargin;

@property (nonatomic, weak) IBOutlet UITableView *tblHistory;

@property (nonatomic, weak) IBOutlet UIButton *btnaddtoPo;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) VPurchaseOrder *vpurchaseOrder;

@property (nonatomic, strong) RapidWebServiceConnection *poItemAddWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *poItemInfoWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *poList;

@property (nonatomic, strong) NSString *webServiceName;
@property (nonatomic, strong) NSString *webServiceNameResponse;
@property (nonatomic, strong) NSString *strSingle;
@property (nonatomic, strong) NSString *strCase;

@property (nonatomic, strong) NSMutableArray *itemInfo;
@property (nonatomic, strong) NSMutableArray *arrayItemInfo;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HProductInfoVC
@synthesize isfromItem,itemInfo;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize strPoId,vpurchaseOrderItem,isUpdate;

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
   
    [self attachKeyboardHelper];
    self.poItemAddWebservice=[[RapidWebServiceConnection alloc]init];
    self.poItemInfoWebservice =[[RapidWebServiceConnection alloc]init];
    self.poList =[[RapidWebServiceConnection alloc]init];
    if(isfromItem)
    {
        self.itemInfo = [[NSMutableArray alloc] initWithObjects:@(ITEM_NAME_BARCODE),@(ITEM_STOCK_INFO),@(ITEM_ADD_ORDER),@(ITEM_HISTORY), nil];
    }
    else{
        self.itemInfo = [[NSMutableArray alloc] initWithObjects:@(ITEM_NAME_BARCODE),@(ITEM_STOCK_INFO),@(ITEM_HISTORY), nil];
    }
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    //self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.lblItemNumber.text = [NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"SupplierItemCode"]];
    self.lblqtyinstock.text = [NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"Line_For"]];
    NSString *stringCase = [NSString stringWithFormat:@"%@/%@",[self.dictProductInfo valueForKey:@"Unit_Retail"],[self.dictProductInfo valueForKey:@"Price"]];
    
    self.lblItemName.text = [NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"ItemDescriptions"]];
    self.lblUPc.text =[NSString stringWithFormat:@"%@", [self.dictProductInfo valueForKey:@"Pack_UPC"]];
    
    self.lblqtyinstock.text = @"0";
    
    self.lblunitcasemsrp.text=stringCase;
    self.lblunitpercase.text=stringCase;
    self.lblunitpercase.text =[NSString stringWithFormat:@"%@", [self.dictProductInfo valueForKey:@"Unit_Retail"]];
     self.lblmargin.text = [NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"Line_Retail"]];
    
    NSString  *catalogCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        catalogCell = @"HItemHistoryInfoCell_iPhone";
    }
    
    
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:catalogCell bundle:nil];
    [self.tblHistory registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HItemHistoryInfoCell"];
    
    
    if(vpurchaseOrderItem.poItemId.integerValue==0){
        
        _webServiceName = @"AddHackneyPOItem";
        _webServiceNameResponse = @"AddHackneyPOItemResult";

    
    }
    else{
        
        _webServiceName = @"UpdateHackneyPOItem";
        _webServiceNameResponse = @"UpdateHackneyPOItemResult";
    
    }

    [self.tblHistory reloadData];
    if(isfromItem){
        [self calculateTotalCost];
    }

    [self callWebServiceForItemInfo];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *strPO = [[NSUserDefaults standardUserDefaults]valueForKey:@"PoId"];
    self.strPoId=strPO;
    _vpurchaseOrder = [self fetchPurchaseOrder:self.strPoId];
}

- (void)callWebServiceForItemInfo
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    param[@"ItemCode"] = [self.dictProductInfo valueForKey:@"SupplierItemCode"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    param[@"LocalDate"] = strDateTime;

    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self vendorItemInfoResponse:response error:error];
        });
    };
    
    self.poItemInfoWebservice = [self.poItemInfoWebservice initWithRequest:KURL actionName:WSM_GET_HACKNEY_PO_ITEM_HISTORY_LIST params:param completionHandler:completionHandler];

    
}

- (void)vendorItemInfoResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _arrayItemInfo = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblHistory reloadData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}




-(void)calculateTotalCost{
    
    NSIndexPath *indpath = [NSIndexPath indexPathForRow:0 inSection:2];
    HIItemAddOrderCell *addorderCell  = (HIItemAddOrderCell *)[self.tblHistory cellForRowAtIndexPath:indpath];
    
    UITextField *txtCase = (UITextField *)[addorderCell viewWithTag:500];
    
    UITextField *txtUnit = (UITextField *)[addorderCell viewWithTag:600];
    
    float caseCost = [[self.dictProductInfo valueForKey:@"Unit_Cost"]floatValue]*[[self.dictProductInfo valueForKey:@"CaseUnits"]floatValue];
    
    float unitTotalCaseCost =   txtCase.text.integerValue*caseCost;
    
    float unitTotalUnitCost =   txtUnit.text.integerValue*[[self.dictProductInfo valueForKey:@"Unit_Cost"]floatValue];
    
    float totalCost = unitTotalCaseCost+unitTotalUnitCost;
    
    NSNumber *totalCostnum = @(totalCost);
    
   addorderCell.lblTotalCost.text  =[NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:totalCostnum]];
    
    _strSingle =txtUnit.text;
    _strCase =txtCase.text;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    PRODUCT_INFO InfoSection = [self.itemInfo[section] integerValue];
    
    switch (InfoSection) {
        case ITEM_NAME_BARCODE:
             return 1;
            break;
        case ITEM_STOCK_INFO:
            return 1;
            break;
        case ITEM_ADD_ORDER:
            return 1;
            break;
        case ITEM_HISTORY:
            return 38.0;
            break;
            
        default:
            break;
    }
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    PRODUCT_INFO InfoSection = [self.itemInfo[section] integerValue];
    switch (InfoSection) {
        case ITEM_NAME_BARCODE:
        case ITEM_STOCK_INFO:
        case ITEM_ADD_ORDER:
             return nil;
            break;
        case ITEM_HISTORY:
        {
            
            UIView *viewTemp = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 35.0)];
            UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20.0, 8.0, 320.0, 23.0)];
            lblTitle.text=@"History";
            lblTitle.textColor =[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0];
            
            viewTemp.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
            
            UIView *viewBorder = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 3.0)];
            viewBorder.backgroundColor = [UIColor whiteColor];
            [viewTemp addSubview:viewBorder];
            
            UIView *viewBorderwhite = [[UIView alloc]initWithFrame:CGRectMake(0.0, 2.0, 320.0, 2.0)];
            viewBorderwhite.backgroundColor = [UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0];
            [viewTemp addSubview:viewBorderwhite];
            
            [viewTemp addSubview:lblTitle];
            
            return viewTemp;
        }
            break;
            
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PRODUCT_INFO InfoSection = [self.itemInfo[indexPath.section] integerValue];
    
    switch (InfoSection) {
        case ITEM_NAME_BARCODE:
            return 67;
            break;
        case ITEM_STOCK_INFO:
            return 35;
            break;
        case ITEM_ADD_ORDER:
            return 214;
            break;
        case ITEM_HISTORY:
            return 150.0;
            break;
        default:
            break;
    }
    return 50.0;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.itemInfo.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PRODUCT_INFO InfoSection = [self.itemInfo[section] integerValue];
    switch (InfoSection) {
        case ITEM_NAME_BARCODE:
            return 1;
            break;
        case ITEM_STOCK_INFO:
            return 6;
            break;
        case ITEM_ADD_ORDER:
            return 1;
            break;
        case ITEM_HISTORY:
            {
    
                return 2;
                break;
            }
        default:
            break;

    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PRODUCT_INFO InfoSection = [self.itemInfo[indexPath.section] integerValue];

    switch (InfoSection) {
        case ITEM_NAME_BARCODE:
            {
                static NSString *cellNumberandName = @"HItemNameAndNumber";
                
                HItemNameAndNumber *itemNumberNameCell = (HItemNameAndNumber *)[tableView dequeueReusableCellWithIdentifier:cellNumberandName];
                
                itemNumberNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
                if(indexPath.row==0)
                {
                    itemNumberNameCell.lblProductName.text = [NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"ItemDescriptions"]];
                    itemNumberNameCell.lblProductUpc.text = [NSString stringWithFormat:@"%@", [self.dictProductInfo valueForKey:@"Pack_UPC"]];
                }
                
                cell =  itemNumberNameCell;
                return cell;
            }
            break;
        case ITEM_STOCK_INFO:
            {
                static NSString *cellStockInfo = @"HItemStockInfo";
                
                HItemStockInfo *itemstockInfo  = (HItemStockInfo *)[tableView dequeueReusableCellWithIdentifier:cellStockInfo];
                
                itemstockInfo.selectionStyle = UITableViewCellSelectionStyleNone;
                
                if(indexPath.row==ITEM_NUMBER){
                    
                    itemstockInfo.lblTitle.text=@"Item Number:";
                    itemstockInfo.lblValue.text=[NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"SupplierItemCode"]];
                    
                }
                else if(indexPath.row==QTY_IN_STOCK){
                    
                    itemstockInfo.lblTitle.text=@"Qty in Stock:";
                    itemstockInfo.lblValue.text=@"0";
                }
                else if(indexPath.row==CASE_COST){
                    
                    itemstockInfo.lblTitle.text=@"Unit/Case Cost:";
                    NSString *strUnitCost = [self.rmsDbController applyCurrencyFomatter:[self.dictProductInfo valueForKey:@"Unit_Cost"]];
                    
                    float caseCost = [[self.dictProductInfo valueForKey:@"Unit_Cost"]floatValue]*[[self.dictProductInfo valueForKey:@"CaseUnits"]floatValue];
                    
                    NSString *strcaseCost = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",caseCost]];
                    
                    itemstockInfo.lblValue.text=[NSString stringWithFormat:@"%@/%@",strUnitCost,strcaseCost];
                }
                else if(indexPath.row==CASE_MRSP){
                    
                    itemstockInfo.lblTitle.text=@"Unit/Case MSRP:";
                    
                    NSString *strUnitprice = [self.rmsDbController applyCurrencyFomatter:[self.dictProductInfo valueForKey:@"Unit_Retail"]];
                    
                    float casePrice = [[self.dictProductInfo valueForKey:@"Unit_Retail"]floatValue]*[[self.dictProductInfo valueForKey:@"CaseUnits"]floatValue];
                    
                    NSString *strcaseprice = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",casePrice]];
                    
                    itemstockInfo.lblValue.text=[NSString stringWithFormat:@"%@/%@",strUnitprice,strcaseprice];
                    
                }
                
                else if(indexPath.row==UNIT_PER_CASE){
                    
                    itemstockInfo.lblTitle.text=@"Unit per Case:";
                    itemstockInfo.lblValue.text=[NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"CaseUnits"]];
                }
                else if(indexPath.row==MARGIN){
                    
                    itemstockInfo.lblTitle.text=@"Margin:";
                    
                    NSString *strUnitCost = [NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"unitCost"]];
                    
                    NSString *strUnitprice = [NSString stringWithFormat:@"%@",[self.dictProductInfo valueForKey:@"Unit_Retail"]];
                    
                    NSString *strProfite;
                    
                    NSString *strMargin = [self calculateMarginCost:strUnitCost profit:strProfite sales:strUnitprice];
                    
                    itemstockInfo.lblValue.text=[NSString stringWithFormat:@"%@%%",strMargin];
                    
                }
                
                cell =  itemstockInfo;
                return cell;

            }
            break;
        case ITEM_ADD_ORDER:
            {
                NSString *cellHistory= @"HIItemAddOrderCell";
                
                HIItemAddOrderCell *addorderCell = (HIItemAddOrderCell *)[tableView dequeueReusableCellWithIdentifier:cellHistory];
                
                addorderCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                addorderCell.txtCase.layer.cornerRadius=5.0;
                addorderCell.txtCase.layer.masksToBounds=YES;
                addorderCell.txtCase.layer.borderColor=[UIColor colorWithRed:0.0/255.0 green:160.0/255.0 blue:79.0/255.0 alpha:1.0].CGColor ;
                addorderCell.txtCase.layer.borderWidth= 3.0f;
        
                if(isUpdate){
                    
                    addorderCell.txtCase.text=[NSString stringWithFormat:@"%@",  vpurchaseOrderItem.casePOQty];
                    addorderCell.txtUnit.text=[NSString stringWithFormat:@"%@",  vpurchaseOrderItem.singlePOQty];
                    addorderCell.txtCase.delegate=self;
                    addorderCell.txtUnit.delegate=self;

                    [self calculateTotalCost];
                }
                else{
                    addorderCell.txtCase.text=@"0";
                    addorderCell.txtUnit.text=@"0";
                }
                
                addorderCell.txtUnit.layer.cornerRadius=5.0;
                addorderCell.txtUnit.layer.masksToBounds=YES;
                addorderCell.txtUnit.layer.borderColor=[UIColor colorWithRed:0.0/255.0 green:160.0/255.0 blue:79.0/255.0 alpha:1.0].CGColor ;
                addorderCell.txtUnit.layer.borderWidth= 3.0f;
                
                [addorderCell.btnCaseMinus addTarget:self action:@selector(txtCashQtyminus:) forControlEvents:UIControlEventTouchUpInside];
                addorderCell.btnCaseMinus.tag = indexPath.row;
                
                [addorderCell.btnCasePlus addTarget:self action:@selector(txtCashQtyAdd:) forControlEvents:UIControlEventTouchUpInside];
                addorderCell.btnCasePlus.tag = indexPath.row;
                
                [addorderCell.btnUnitPlus addTarget:self action:@selector(txtUnitQtyAdd:) forControlEvents:UIControlEventTouchUpInside];
                addorderCell.btnUnitPlus.tag = indexPath.row;
                
                [addorderCell.btnUnitMinus addTarget:self action:@selector(txtUnitQtyminus:) forControlEvents:UIControlEventTouchUpInside];
                addorderCell.btnUnitMinus.tag = indexPath.row;
                
                addorderCell.btnAddtoOrder.layer.cornerRadius=addorderCell.btnAddtoOrder.frame.size.height/2;
                addorderCell.btnAddtoOrder.layer.masksToBounds=YES;
                addorderCell.btnAddtoOrder.layer.borderColor=[UIColor clearColor].CGColor;
                addorderCell.btnAddtoOrder.layer.borderWidth= 3.0f;
                
                addorderCell.btnAddtoOrder.layer.borderWidth= 3.0f;
                [addorderCell.btnAddtoOrder addTarget:self action:@selector(btnAddOrderItem:) forControlEvents:UIControlEventTouchUpInside];
                
                cell =  addorderCell;
                
                return cell;
            }
            break;
        case ITEM_HISTORY:
            {
                NSString *cellHistory= @"HItemHistoryInfoCell";
                
                HItemHistoryInfoCell *historyCell = (HItemHistoryInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellHistory];
                
                historyCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                NSMutableDictionary *dictSub = _arrayItemInfo.firstObject;
                NSMutableDictionary *histroyInfo;
                if(indexPath.row==0){
                    histroyInfo=[[dictSub valueForKey:@"HackneyPOItemHistoryArray"]firstObject];
                    historyCell.lblhistryType.text=@"Qty Ordered";
            
                }
                else if(indexPath.row==1){
                    histroyInfo=[[dictSub valueForKey:@"PurchaseBackOrderHistoryArray"]firstObject];
                    historyCell.lblhistryType.text=@"Qty Back Ordered";

                }
                
                historyCell.lblthisweek.text= [NSString stringWithFormat:@"This Week : %@", [histroyInfo valueForKey:@"thisWeek"]];
                historyCell.lbllastweek.text= [NSString stringWithFormat:@"Last Week : %@",[histroyInfo valueForKey:@"LastWeek"]];
                historyCell.lblthismonth.text= [NSString stringWithFormat:@"This Month : %@",[histroyInfo valueForKey:@"thismonth"]];
                historyCell.lbllastmonth.text= [NSString stringWithFormat:@"Last Month : %@",[histroyInfo valueForKey:@"Lastmonth"]];
                historyCell.lblthisyear.text= [NSString stringWithFormat:@"This Year : %@",[histroyInfo valueForKey:@"Lastyear"]];
                
                cell =  historyCell;
                
                return cell;
            }
            break;
        default:
            break;
            
    }
    return cell;
}

-(void)txtCashQtyAdd:(id)sender{

    HIItemAddOrderCell *productCell = (HIItemAddOrderCell *)[sender superview];
    UITextField *txtCase = (UITextField *)[productCell viewWithTag:500];
    txtCase.text=[NSString stringWithFormat:@"%ld",(long)txtCase.text.integerValue+1];
    [self calculateTotalCost];
}

-(void)txtCashQtyminus:(id)sender{
    
    HIItemAddOrderCell *productCell = (HIItemAddOrderCell *)[sender superview];
    UITextField *txtCase = (UITextField *)[productCell viewWithTag:500];
    txtCase.text=[NSString stringWithFormat:@"%ld",(long)txtCase.text.integerValue-1];
     [self calculateTotalCost];
}

-(void)txtUnitQtyAdd:(id)sender{
    
    HIItemAddOrderCell *productCell = (HIItemAddOrderCell *)[sender superview];
    UITextField *txtUnit = (UITextField *)[productCell viewWithTag:600];
    txtUnit.text=[NSString stringWithFormat:@"%ld",(long)txtUnit.text.integerValue+1];
     [self calculateTotalCost];
    
}

-(void)txtUnitQtyminus:(id)sender{
    
    HIItemAddOrderCell *productCell = (HIItemAddOrderCell *)[sender superview];
    UITextField *txtUnit = (UITextField *)[productCell viewWithTag:600];
    txtUnit.text=[NSString stringWithFormat:@"%ld",(long)txtUnit.text.integerValue-1];
     [self calculateTotalCost];
    
}

-(void)btnAddOrderItem:(id)sender{
    
    [self callWebServiceForPurchaseOrderAddItem];
}

- (void)callWebServiceForPurchaseOrderAddItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary * param = [self getParamDictionary];

    NSMutableDictionary *poparam = [[NSMutableDictionary alloc] init ];
    [poparam setValue:param forKey:@"ItemData"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self purchaseOrderItemAddResponse:response error:error];
        });
    };
    
    self.poItemAddWebservice = [self.poItemAddWebservice initWithRequest:KURL actionName:_webServiceName params:poparam completionHandler:completionHandler];
    
}

- (void)purchaseOrderItemAddResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                NSString *strItemID = response[@"Data"];
                
                if(vpurchaseOrderItem.poItemId.integerValue==0){
                    
                    [self insertVendorPOItemWithDictionary:strItemID];
                }
                else
                {
                    [vpurchaseOrderItem updateVendorPoItemDictionary:[self getParamDictionary]];
                    
                    NSArray *arrayView = self.navigationController.viewControllers;
                    for(UIViewController *viewcon in arrayView){
                        if([viewcon isKindOfClass:[HPOItemListVC class]]){
                            [self.navigationController popToViewController:viewcon animated:YES];
                            
                        }
                    }
                    
                }
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}



-(NSMutableDictionary *)getParamDictionary{
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    if(vpurchaseOrderItem.poItemId.integerValue==0){
        
        [param setValue:@"0" forKey:@"Id"];
        [param setValue:self.strPoId forKey:@"POId"];
        [param setValue:@"0" forKey:@"POItemId"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:[self.dictProductInfo valueForKey:@"SupplierItemCode"] forKey:@"ItemCode"];
        [param setValue:_strSingle forKey:@"SinglePOQty"];
        [param setValue:_strCase forKey:@"CasePOQty"];
        [param setValue:@"0" forKey:@"PackPOQty"];
        [param setValue:@"0" forKey:@"SingleReceivedQty"];
        [param setValue:@"0" forKey:@"CaseReceivedQty"];
        [param setValue:@"0" forKey:@"PackReceivedQty"];
        [param setValue:@"0" forKey:@"IsReturn"];
        [param setValue:@"0" forKey:@"OldQty"];
        [param setValue:@"" forKey:@"Remarks"];
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *strDateTime = [formatter stringFromDate:date];
        param[@"CreatedDate"] = strDateTime;

        
    }
    else{
        
        [param setValue:@"0" forKey:@"Id"];
        [param setValue:vpurchaseOrderItem.poId forKey:@"POId"];
        [param setValue:vpurchaseOrderItem.poItemId forKey:@"POItemId"];
        
        NSString *strDate = [self getStringFormate:vpurchaseOrderItem.createdDate fromFormate:@"yyyy/mm/dd hh:mm:ss" toFormate:@"MM/dd/yyyy hh:mm a"];
        
        [param setValue:strDate forKey:@"CreatedDate"];
        
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:[self.dictProductInfo valueForKey:@"SupplierItemCode"] forKey:@"ItemCode"];
        [param setValue:_strSingle forKey:@"SinglePOQty"];
        [param setValue:_strCase forKey:@"CasePOQty"];
        [param setValue:@"0" forKey:@"PackPOQty"];
        [param setValue:@"0" forKey:@"SingleReceivedQty"];
        [param setValue:@"0" forKey:@"CaseReceivedQty"];
        [param setValue:@"0" forKey:@"PackReceivedQty"];
        [param setValue:@"0" forKey:@"IsReturn"];
        [param setValue:@"0" forKey:@"OldQty"];
        [param setValue:@"" forKey:@"Remarks"];
        
        
    }
    
    return param;
    
    
}

-(NSString *)getStringFormate:(NSDate *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDate *dateFromString =pstrDate;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
    
}


-(void)insertVendorPOItemWithDictionary:(NSString *)strItemID{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:strItemID forKey:@"Id"];
    [dict setValue:self.strPoId forKey:@"POId"];
    [dict setValue:strItemID forKey:@"POItemId"];
    [dict setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [dict setValue:[self.dictProductInfo valueForKey:@"SupplierItemCode"] forKey:@"ItemCode"];
    [dict setValue:_strSingle forKey:@"SinglePOQty"];
    [dict setValue:_strCase forKey:@"CasePOQty"];
    [dict setValue:@"0" forKey:@"PackPOQty"];
    [dict setValue:@"0" forKey:@"SingleReceivedQty"];
    [dict setValue:@"0" forKey:@"CaseReceivedQty"];
    [dict setValue:@"0" forKey:@"PackReceivedQty"];
    [dict setValue:@"0" forKey:@"IsReturn"];
    [dict setValue:@"0" forKey:@"OldQty"];
    [dict setValue:@"" forKey:@"Remarks"];
    
    
    Vendor_Item *vanItem = [self fetchVendorItem:[[self.dictProductInfo valueForKey:@"SupplierItemCode"]integerValue]];
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    [self.updateManager updatePurchaseOrderItemListwithDetail:dict withVendorItem:(Vendor_Item *)OBJECT_COPY(vanItem, privateContextObject) withpurchaseOrderItem:(VPurchaseOrderItem *)OBJECT_COPY(vpurchaseOrderItem, privateContextObject) withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(_vpurchaseOrder, privateContextObject) withManageObjectContext:privateContextObject];
    
    vpurchaseOrderItem = (VPurchaseOrderItem *)OBJECT_COPY(vpurchaseOrderItem, self.managedObjectContext);
    _vpurchaseOrder = (VPurchaseOrder *)OBJECT_COPY(_vpurchaseOrder, self.managedObjectContext);

    if(self.isfromItem){
        
        NSArray *arrayView = self.navigationController.viewControllers;
        for(UIViewController *viewcon in arrayView){
            if([viewcon isKindOfClass:[HPOItemListVC class]] || [viewcon isKindOfClass:[HReceiveOrderItemListVC class]]){
                [self.navigationController popToViewController:viewcon animated:YES];
            }
        }
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (Vendor_Item *)fetchVendorItem :(NSInteger)itemId
{
    Vendor_Item *vitem=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vin==%d", itemId];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        vitem=resultSet.firstObject;
    }
    return vitem;
}
     
- (VPurchaseOrder *)fetchPurchaseOrder :(NSString *)poid
{
    VPurchaseOrder *purchaseorder=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"VPurchaseOrder" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"poId==%d", poid.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        purchaseorder=resultSet.firstObject;
    }
    return purchaseorder;
}
     
     
- (NSString *)calculateMarginCost:(NSString *)costPrice profit:(NSString *)profitAmount sales:(NSString *)salesPrice
{
    NSString *tempCost = [costPrice stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    tempCost = [tempCost stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    NSString *tempSales = [salesPrice stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    tempSales = [tempSales stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    if((![salesPrice isEqualToString:@""])||(![costPrice isEqualToString:@""]))
    {
        float dProfitAmt = 0;
        float dsellingAmt = tempSales.floatValue;
        float dcostAmt = tempCost.floatValue;
        dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
        profitAmount = [NSString stringWithFormat:@"%.2f",dProfitAmt];
    }
    if([profitAmount isEqualToString:@"nan"] || [profitAmount isEqualToString:@"-inf"] || [profitAmount isEqualToString:@"inf"] || [profitAmount isEqualToString:@"-100.00"])
    {
        profitAmount = @"0.00";
    }

    return profitAmount;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self calculateTotalCost];
    [textField resignFirstResponder];
    return YES;
}


- (void)attachKeyboardHelper{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self detachKeyboardHelper];
}

- (void)detachKeyboardHelper{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillAppear:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    if(self.view==self.tblHistory){
        CGRect newTableFrame = CGRectMake(self.tblHistory.frame.origin.x, self.tblHistory.frame.origin.y, self.tblHistory.frame.size.width, self.view.bounds.size.height-keyboardFrame.size.height);
        self.tblHistory.frame = newTableFrame;
    }else{
        CGRect newTableFrame = CGRectMake(self.tblHistory.frame.origin.x, self.tblHistory.frame.origin.y, self.tblHistory.frame.size.width, self.view.bounds.size.height-self.tblHistory.frame.origin.y-keyboardFrame.size.height);
        self.tblHistory.frame = newTableFrame;
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    
    CGRect newTableFrame = CGRectMake(self.tblHistory.frame.origin.x, self.tblHistory.frame.origin.y, self.tblHistory.frame.size.width, self.view.superview.bounds.size.height-self.tblHistory.frame.origin.y);
    self.tblHistory.frame = newTableFrame;
    if(newTableFrame.size.height>self.tblHistory.contentSize.height-self.tblHistory.contentOffset.y){
        float newOffset=MAX(self.tblHistory.contentSize.height-newTableFrame.size.height, 0);
        [self.tblHistory setContentOffset:CGPointMake(0, newOffset) animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)gotoProctList:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)addtoPOClick:(id)sender{
    
    if(self.strPoId.length>0 && _vpurchaseOrder!=nil){
        
        [self callWebServiceForPurchaseOrderAddItem];
    }
    else{
        [self ListofPO];
    }
}

- (void)ListofPO
{    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    param[@"Status"] = @"1";
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self poListResponse:response error:error];
        });
    };
    
    self.poList = [self.poList initWithRequest:KURL actionName:WSM_LIST_HACKNEY_PO params:param completionHandler:completionHandler];
    
}

- (void)poListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]){
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *arrPOList = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(arrPOList.count>0){
                    
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                    HOpenOrderVC *hOpenOrder = [storyBoard instantiateViewControllerWithIdentifier:@"HOpenOrderVC"];
                    hOpenOrder.isselection=YES;
                    [self.navigationController pushViewController:hOpenOrder animated:YES];
                }
                else{
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"NO PO Generated." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
            else{
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
    }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
