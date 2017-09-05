//
//  HReceiveOrderItemInfo.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HReceiveOrderItemInfo.h"
#import "HReceiveItemInfoCell.h"
#import "RimsController.h"
#import "RmsDbController.h"
#import "VPurchaseOrderItem.h"
#import "VPurchaseOrderItem+Dictionary.h"
#import "UpdateManager.h"
#import "HReceiveOrderItemListVC.h"
#import "Vendor_Item+Dictionary.h"
#import "VPurchaseOrder+Dictionary.h"

typedef NS_ENUM(NSUInteger, RECEIVE_PRODUCT_INFO) {
    QTY_ORDERED_SINGLE,
    QTY_ORDERED_CASE,
    PO_COST,
    PO_MSRP,
    PO_MARGIN,
    PO_FREE_QTY,
    TOTAL_COST,
    UPDATE_INFO_BTN
};



@interface HReceiveOrderItemInfo ()

@property (nonatomic, weak) IBOutlet UILabel *lblItemName;
@property (nonatomic, weak) IBOutlet UILabel *lblUpc;

@property (nonatomic, weak) IBOutlet UIButton *btnBackOrder;
@property (nonatomic, weak) IBOutlet UIButton *btnCheck;

@property (nonatomic, weak) IBOutlet UISegmentedControl *sagmentControll;

@property (nonatomic, weak) IBOutlet UITableView *tblItemOrderInfo;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection *pobackorder;
@property (nonatomic, strong) RapidWebServiceConnection *poitemUpdateInfo;

@property (nonatomic, strong) NSString *webServiceName;
@property (nonatomic, strong) NSString *webServiceNameResponse;

@property (nonatomic, strong) NSMutableDictionary *dictitemOrderInfoGlobal;
@property (nonatomic, strong) NSMutableDictionary *dictitemOrderInfoReceive;
@property (nonatomic, strong) NSMutableDictionary *dictOrderInfo;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HReceiveOrderItemInfo
@synthesize dictitemOrderInfoReceive,dictitemOrderInfo;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize strPOID,strItemId,vpurchaseOrderitem;


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
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    //self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    self.pobackorder = [[RapidWebServiceConnection alloc]init];
    self.poitemUpdateInfo = [[RapidWebServiceConnection alloc]init];
    
    self.btnBackOrder.layer.cornerRadius=self.btnBackOrder.frame.size.height/2;
    self.btnBackOrder.layer.masksToBounds=YES;
    self.btnBackOrder.layer.borderColor=[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0].CGColor ;
    self.btnBackOrder.layer.borderWidth= 1.0f;

    self.lblItemName.text=[self.dictitemOrderInfo valueForKey:@"ItemDescriptions"];
    self.lblUpc.text= [NSString stringWithFormat:@"%@", [self.dictitemOrderInfo valueForKey:@"Carton_UPC"]];
    
    vpurchaseOrderitem = [self fetchPurchaseOrderItem:self.strPOID withItemID:strItemId];
    
  
    
    if(vpurchaseOrderitem.poItemId.integerValue==0){
        
        _webServiceName = @"AddHackneyPOItem";
        _webServiceNameResponse = @"AddHackneyPOItemResult";
        
        
    }
    else{
        
        _webServiceName = @"UpdateHackneyPOItem";
        _webServiceNameResponse = @"UpdateHackneyPOItemResult";
    
    }
    
    _dictOrderInfo = (NSMutableDictionary *)self.vpurchaseOrderitem.vendorPoItemDictionary;
    [self updateCheckBox];
    
    // Do any additional setup after loading the view.
}

- (VPurchaseOrderItem *)fetchPurchaseOrderItem :(NSString *)poid withItemID:(NSString *)stritemId
{
    VPurchaseOrderItem *purchaseorder=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"VPurchaseOrderItem" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"poId==%d && poItemId = %d", poid.integerValue,stritemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        purchaseorder=resultSet.firstObject;
    }
    return purchaseorder;
}


#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStockInfo = @"HReceiveItemInfoCell";
    
    HReceiveItemInfoCell *itemInfoCell  = (HReceiveItemInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellStockInfo];
    
    itemInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row==QTY_ORDERED_SINGLE){
        
        itemInfoCell.lblTitle.text=@"Qty Ordered Single:";
        if(_sagmentControll.selectedSegmentIndex==0){
            
           itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@",[self.dictOrderInfo valueForKey:@"SinglePOQty"]];
        }
        else{
            itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@",[self.dictOrderInfo valueForKey:@"SingleReceivedQty"]];
        }
        
        itemInfoCell.txtValue.tag=1;
        [self changeTextFieldStyle:itemInfoCell.txtValue];
        itemInfoCell.txtValue.delegate=self;
        
        
    }
    if(indexPath.row==QTY_ORDERED_CASE){
        
        itemInfoCell.lblTitle.text=@"Qty Ordered Case:";
         if(_sagmentControll.selectedSegmentIndex==0){
             
             itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@",[self.dictOrderInfo valueForKey:@"CasePOQty"]];
         }
         else{
             itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@",[self.dictOrderInfo valueForKey:@"CaseReceivedQty"]];
         }
        itemInfoCell.txtValue.tag=2;
        [self changeTextFieldStyle:itemInfoCell.txtValue];
        itemInfoCell.txtValue.delegate=self;
        
        
    }
    if(indexPath.row==PO_COST){
        
        itemInfoCell.lblTitle.text=@"PO Cost:";
        
        float pocost = [[self.dictitemOrderInfo valueForKey:@"Unit_Cost"]floatValue];
        
        NSNumber *totalcostnum = @(pocost);
    
       itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:totalcostnum]];
        itemInfoCell.txtValue.delegate=self;
        itemInfoCell.txtValue.tag=3;
         [self changeTextFieldStyle:itemInfoCell.txtValue];
        
        
    }
    if(indexPath.row==PO_MSRP){
        
        float casePrice = [[self.dictitemOrderInfo valueForKey:@"Unit_Retail"]floatValue]*[[self.dictitemOrderInfo valueForKey:@"CaseUnits"]floatValue];
        
        NSString *strcaseprice = [NSString stringWithFormat:@"%.2f",casePrice];
        
        itemInfoCell.lblTitle.text=@"PO MSRP:";
        itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@",strcaseprice];
        itemInfoCell.txtValue.tag=4;
        itemInfoCell.txtValue.delegate=self;
        [self changeTextFieldStyle:itemInfoCell.txtValue];

    }
    if(indexPath.row==PO_MARGIN){
        
        NSString *strUnitCost = [NSString stringWithFormat:@"%@",[self.dictitemOrderInfo valueForKey:@"Unit_Cost"]];
        
        NSString *strUnitprice = [NSString stringWithFormat:@"%@",[self.dictitemOrderInfo valueForKey:@"Unit_Retail"]];
        
        NSString *strProfite;
        
        NSString *strMargin = [self calculateMarginCost:strUnitCost profit:strProfite sales:strUnitprice];
        
        itemInfoCell.lblTitle.text=@"PO MARGIN:";
        itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@%%",strMargin];
        itemInfoCell.txtValue.tag=5;
        itemInfoCell.txtValue.delegate=self;
        [self changeTextFieldStyle:itemInfoCell.txtValue];
        itemInfoCell.txtValue.enabled=NO;

    }
    if(indexPath.row==PO_FREE_QTY){
        
        itemInfoCell.lblTitle.text=@"PO FREE QTY:";
        itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@", [self.dictitemOrderInfo valueForKey:@"FreeGoods"]];
        itemInfoCell.txtValue.delegate=self;
        itemInfoCell.txtValue.tag=6;
        [self changeTextFieldStyle:itemInfoCell.txtValue];
    }
    if(indexPath.row==TOTAL_COST){
        
        float totalCost = [[self.dictitemOrderInfo valueForKey:@"Unit_Cost"]floatValue]*[[self.dictitemOrderInfo valueForKey:@"OrderdQty"]integerValue];
        
        NSNumber *totalcostnum = @(totalCost);
        itemInfoCell.lblTitle.text=@"TOTAL COST:";
        itemInfoCell.txtValue.text=[NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:totalcostnum]];
        itemInfoCell.txtValue.tag=7;
        itemInfoCell.txtValue.delegate=self;
        [self changeTextFieldStyle:itemInfoCell.txtValue];
        itemInfoCell.txtValue.enabled=NO;
        
    }
    if(indexPath.row==UPDATE_INFO_BTN){
        
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        
        UIButton *btnReceive = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnReceive setTitle:@"SAVE" forState:UIControlStateNormal];
        btnReceive.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0];
        btnReceive.frame = CGRectMake(20.0, 9.0, 250.0, 26.0);
        btnReceive.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:169.0/255.0 blue:79.0/255.0 alpha:1.0];
        [btnReceive addTarget:self action:@selector(saveOrderInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        btnReceive.layer.cornerRadius=btnReceive.frame.size.height/2;
        btnReceive.layer.masksToBounds=YES;
        btnReceive.layer.borderColor=[UIColor clearColor].CGColor;
        btnReceive.layer.borderWidth= 3.0f;
        
        [cell addSubview:btnReceive];
        
    
        return cell;
        
        
    }
    return itemInfoCell;
}

-(void)saveOrderInfo:(id)sender
{
    
    [self callWebServiceForPurchaseOrderAddItem];
    
}
-(NSMutableDictionary *)getParamDictionary{
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    if(vpurchaseOrderitem.poItemId.integerValue==0){
        
        [param setValue:@"0" forKey:@"Id"];
        [param setValue:self.strPOID forKey:@"POId"];
        [param setValue:@"0" forKey:@"POItemId"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:[self.dictitemOrderInfo valueForKey:@"SupplierItemCode"] forKey:@"ItemCode"];
        [param setValue:[self.dictOrderInfo valueForKey:@"SinglePOQty"] forKey:@"SinglePOQty"];
        [param setValue:[self.dictOrderInfo valueForKey:@"CasePOQty"] forKey:@"CasePOQty"];
        [param setValue:@"0" forKey:@"PackPOQty"];
        [param setValue:[self.dictOrderInfo valueForKey:@"SingleReceivedQty"] forKey:@"SingleReceivedQty"];
        [param setValue:[self.dictOrderInfo valueForKey:@"CaseReceivedQty"] forKey:@"CaseReceivedQty"];
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
        [param setValue:vpurchaseOrderitem.poId forKey:@"POId"];
        [param setValue:vpurchaseOrderitem.poItemId forKey:@"POItemId"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:[self.dictitemOrderInfo valueForKey:@"SupplierItemCode"] forKey:@"ItemCode"];
        [param setValue:[self.dictOrderInfo valueForKey:@"SinglePOQty"] forKey:@"SinglePOQty"];
        [param setValue:[self.dictOrderInfo valueForKey:@"CasePOQty"] forKey:@"CasePOQty"];
        [param setValue:@"0" forKey:@"PackPOQty"];
        [param setValue:[self.dictOrderInfo valueForKey:@"SingleReceivedQty"] forKey:@"SingleReceivedQty"];
        [param setValue:[self.dictOrderInfo valueForKey:@"CaseReceivedQty"] forKey:@"CaseReceivedQty"];
        [param setValue:@"0" forKey:@"PackReceivedQty"];
        [param setValue:@"0" forKey:@"IsReturn"];
        [param setValue:@"0" forKey:@"OldQty"];
        [param setValue:@"" forKey:@"Remarks"];
        
    }
    return param;
    
}


- (void)callWebServiceForPurchaseOrderAddItem
{
   _activityIndicator =  [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [self getParamDictionary];
    
    NSMutableDictionary *poparam = [[NSMutableDictionary alloc] init ];
    [poparam setValue:param forKey:@"ItemData"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self vendoritemReceiveInfoResponse:response error:error];
        });
    };
    
    self.poitemUpdateInfo = [self.poitemUpdateInfo initWithRequest:KURL actionName:_webServiceName params:poparam completionHandler:completionHandler];

}

- (void)vendoritemReceiveInfoResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                
                if(vpurchaseOrderitem.poItemId.integerValue==0){
                    
                    NSString *strItemID = response[@"Data"];
                    
                    if(vpurchaseOrderitem.poItemId.integerValue==0){
                        [self insertVendorPOItemWithDictionary:strItemID moc:privateContextObject];
                    }
                    
                }
                else{
                    NSMutableDictionary * param = [self getParamDictionary];
                    VPurchaseOrderItem *poItem = (VPurchaseOrderItem*)[privateContextObject objectWithID:vpurchaseOrderitem.objectID];
                    [poItem updateVendorPoItemDictionary:param];
                    [UpdateManager saveContext:privateContextObject];
                    [self.navigationController popViewControllerAnimated:YES];
                    
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


-(void)insertVendorPOItemWithDictionary:(NSString *)strItemID moc:(NSManagedObjectContext*)moc {
    
     NSMutableDictionary * dict = [self getParamDictionary];

    Vendor_Item *vanItem = [self fetchVendorItem:[[self.dictitemOrderInfo valueForKey:@"SupplierItemCode"]integerValue]];
    
    VPurchaseOrder *vpurchaseOrder = [self fetchPurchaseOrder:self.strPOID];

//    [self.updateManager updatePurchaseOrderItemListwithDetail:dict withVendorItem:vanItem withpurchaseOrderItem:vpurchaseOrderitem withPurchaseOrder:vpurchaseOrder withManageObjectContext:moc];
    
    [self.updateManager updatePurchaseOrderItemListwithDetail:dict withVendorItem:(Vendor_Item *)OBJECT_COPY(vanItem, moc) withpurchaseOrderItem:(VPurchaseOrderItem *)OBJECT_COPY(vpurchaseOrderitem, moc) withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(vpurchaseOrder, moc) withManageObjectContext:moc];
    
    vpurchaseOrderitem = (VPurchaseOrderItem *)OBJECT_COPY(vpurchaseOrderitem, self.managedObjectContext);
    
    NSArray *arrayView = self.navigationController.viewControllers;
    for(UIViewController *viewcon in arrayView){
        if([viewcon isKindOfClass:[HReceiveOrderItemListVC class]]){
            [self.navigationController popToViewController:viewcon animated:YES];
        }
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

-(void)changeTextFieldStyle:(UITextField *)txtFld{
    
    
    txtFld.keyboardType = UIKeyboardTypeNamePhonePad;
    if(_sagmentControll.selectedSegmentIndex==0)
    {
        txtFld.enabled=NO;
        txtFld.layer.borderWidth=0.5;
        txtFld.layer.borderColor=[UIColor clearColor].CGColor;

    }
    else{
        if(txtFld.tag==1 || txtFld.tag==2 || txtFld.tag ==5 || txtFld.tag==3){
            
            txtFld.enabled=YES;
            txtFld.layer.borderWidth=0.5;
            txtFld.layer.borderColor=[UIColor blackColor].CGColor;
        }

    }
}

-(IBAction)switchToggleMethod:(id)sender{
    
    UISegmentedControl *sagment = sender;
    if(sagment.selectedSegmentIndex==0)
    {
        self.dictitemOrderInfoReceive=[self.dictitemOrderInfo mutableCopy];
        if(self.dictitemOrderInfoGlobal){
            self.dictitemOrderInfo = [self.dictitemOrderInfoGlobal mutableCopy];
        }
        
        [self.tblItemOrderInfo reloadData];
        
    }
    else{
        
        
        self.dictitemOrderInfoGlobal = [self.dictitemOrderInfo mutableCopy];
        if(self.dictitemOrderInfoReceive){
            self.dictitemOrderInfo = [self.dictitemOrderInfoReceive mutableCopy];
        }
        [self.tblItemOrderInfo reloadData];
        
        
    }
}

-(IBAction)addItemToBackOrder:(id)sender{
    
    [self addPurchaseOrderItemtoBackorder];
}

-(NSMutableDictionary *)getItemParamDictionary{
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:@"0" forKey:@"Id"];
    [param setValue:vpurchaseOrderitem.poId forKey:@"POId"];
    [param setValue:vpurchaseOrderitem.poItemId forKey:@"POItemId"];
    
    NSString *strDate = [self getStringFormate:vpurchaseOrderitem.createdDate fromFormate:@"yyyy/mm/dd hh:mm:ss" toFormate:@"MM/dd/yyyy hh:mm a"];
    
    [param setValue:strDate forKey:@"CreatedDate"];
    
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:[self.dictitemOrderInfo valueForKey:@"SupplierItemCode"] forKey:@"ItemCode"];
    [param setValue:vpurchaseOrderitem.singlePOQty forKey:@"SinglePOQty"];
    [param setValue:vpurchaseOrderitem.casePOQty forKey:@"CasePOQty"];
    [param setValue:@"0" forKey:@"PackPOQty"];
    [param setValue:@"0" forKey:@"SingleReceivedQty"];
    [param setValue:@"0" forKey:@"CaseReceivedQty"];
    [param setValue:@"0" forKey:@"PackReceivedQty"];
    [param setValue:@"0" forKey:@"IsReturn"];
    [param setValue:@"0" forKey:@"OldQty"];
    [param setValue:@"" forKey:@"Remarks"];
    param[@"IsBackOrder"] = @"1";
    
    return param;
    
}

-(NSString *)getStringFormate:(NSDate *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDate *dateFromString =pstrDate;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
    
}

- (void)addPurchaseOrderItemtoBackorder
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [self getItemParamDictionary];
    NSMutableDictionary *poparam = [[NSMutableDictionary alloc] init ];
    [poparam setValue:param forKey:@"ItemData"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self backorderItemResultResponse:response error:error];
        });
    };
    
    self.pobackorder = [self.pobackorder initWithRequest:KURL actionName:WSM_UPDATE_HACKNEY_PO_ITEM params:poparam completionHandler:completionHandler];
}

- (void)backorderItemResultResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self storeReceivedItemInfo:textField.tag withValue:searchString];
    //[self.tblItemOrderInfo reloadData];
    return YES;
}


-(void)storeReceivedItemInfo:(NSInteger)intTag withValue:(NSString *)strValue{
    
    if(intTag==1){
        self.dictOrderInfo[@"SingleReceivedQty"]=strValue;
        ;
    }
    else if(intTag==2){
        self.dictOrderInfo[@"CaseReceivedQty"]=strValue;
    }
    else if(intTag==3){
        
        self.dictitemOrderInfo[@"Unit_Cost"]=strValue;
    }
    else if(intTag==5){
        self.dictitemOrderInfo[@"FreeGoods"]=strValue;
    }
    [self updateCheckBox];
}

-(void)updateCheckBox{
    
    NSInteger QtyOrder = [[self.dictOrderInfo valueForKey:@"CasePOQty"] integerValue]+ [[self.dictOrderInfo valueForKey:@"SinglePOQty"] integerValue];
    
    NSInteger ReceivedOrder = [[self.dictOrderInfo valueForKey:@"CaseReceivedQty"] integerValue]+ [[self.dictOrderInfo valueForKey:@"SingleReceivedQty"] integerValue];
    
    if(QtyOrder==ReceivedOrder){
        
        [self.btnCheck setImage:[UIImage imageNamed:@"receive_order_check.png"] forState:UIControlStateNormal];
    }
    if(QtyOrder<ReceivedOrder){
        
        [self.btnCheck  setImage:[UIImage imageNamed:@"check_blue_icon.png"] forState:UIControlStateNormal];
    }
    if(QtyOrder>ReceivedOrder){
        
        [self.btnCheck  setImage:[UIImage imageNamed:@"receive_order_uncheck.png"] forState:UIControlStateNormal];
    }

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self storeReceivedItemInfo:textField.tag withValue:textField.text];

    [self.tblItemOrderInfo reloadData];
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
    if(self.view==self.tblItemOrderInfo){
        CGRect newTableFrame = CGRectMake(self.tblItemOrderInfo.frame.origin.x, self.tblItemOrderInfo.frame.origin.y, self.tblItemOrderInfo.frame.size.width, self.view.bounds.size.height-keyboardFrame.size.height);
        self.tblItemOrderInfo.frame = newTableFrame;
    }else{
        CGRect newTableFrame = CGRectMake(self.tblItemOrderInfo.frame.origin.x, self.tblItemOrderInfo.frame.origin.y, self.tblItemOrderInfo.frame.size.width, self.view.bounds.size.height-self.tblItemOrderInfo.frame.origin.y-keyboardFrame.size.height);
        self.tblItemOrderInfo.frame = newTableFrame;
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
    
    
    CGRect newTableFrame = CGRectMake(self.tblItemOrderInfo.frame.origin.x, self.tblItemOrderInfo.frame.origin.y, self.tblItemOrderInfo.frame.size.width, 302);
    self.tblItemOrderInfo.frame = newTableFrame;
    if(newTableFrame.size.height>self.tblItemOrderInfo.contentSize.height-self.tblItemOrderInfo.contentOffset.y){
        float newOffset=MAX(self.tblItemOrderInfo.contentSize.height-newTableFrame.size.height, 0);
        [self.tblItemOrderInfo setContentOffset:CGPointMake(0, newOffset) animated:YES];
    }
    
}

-(IBAction)checkClicked:(id)sender{
    
    if(_btnCheck.selected)
    {
        _btnCheck.selected=NO;
    }
    else{
        _btnCheck.selected=YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)backtoItemList:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
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
