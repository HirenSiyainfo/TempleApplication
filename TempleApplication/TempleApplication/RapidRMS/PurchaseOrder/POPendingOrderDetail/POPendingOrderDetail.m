//
//  POPendingOrderDetail.m
//  RapidRMS
//
//  Created by Siya10 on 14/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POPendingOrderDetail.h"
#import "RmsDbController.h"
#import "POOrderDetailCell.h"
#import "RimLoginVC.h"
#import "CameraScanVC.h"
#import "ItemDetailEditVC.h"
#import "ItemInfoEditVC.h"
#import "POOrderItemInfo.h"
#import "POOrderInfo.h"
#import "POItemReceiveDetail.h"
#import "EmailFromViewController.h"
#import "InventoryItemSelectionListVC.h"

@interface POPendingOrderDetail ()<UpdateDelegate,CameraScanVCDelegate,ItemInfoEditVCDelegate,ItemInfoEditRedirectionVCDelegate,POItemReceiveDetailDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,InventoryItemSelectionListVCDelegate>
{
     CGPoint infoButtonPosition;
     POOrderItemInfo *poOrderItemInfo;
     POOrderInfo *poOrderInfo;
    NSIndexPath *selectedItemIndPath;

}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *pendingOrderDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *searchItemWC;
@property (nonatomic, strong) RapidWebServiceConnection *updatePendingOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *insertDeliveryOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *itemInfoWC;

@property (nonatomic, strong) NSString *emaiItemHtml;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;
@property (nonatomic, strong) NSMutableArray *pendingOrderDetailData;
@property(nonatomic,weak)IBOutlet UITableView *tblPendingDetail;

@property (nonatomic, strong) UpdateManager *updateManager;

@property(nonatomic,weak)IBOutlet UIView *viewPoNum;
@property(nonatomic,weak)IBOutlet UIView *viewInvNum;
@property(nonatomic,weak)IBOutlet UITextField *txtInvoiceNo;
@property(nonatomic,weak)IBOutlet UIView *invoiceBG;

@property(nonatomic,weak)IBOutlet UILabel *poNumber;
@property(nonatomic,weak)IBOutlet UILabel *poDate;

@property(nonatomic,weak)IBOutlet UITextField *universalSearch;
@property(nonatomic,weak)UIButton *source;

@property(nonatomic,strong)NSString *searchText;

@property (nonatomic, strong) CameraScanVC *cameraScanVC;

@end

@implementation POPendingOrderDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeObject];
    if(self.isDelivery){
        self.viewPoNum.hidden = YES;
        self.viewInvNum.hidden = NO;
    }
    else{
        self.viewPoNum.hidden = NO;
        self.viewInvNum.hidden = YES;
    }
}
-(void)initializeObject{
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.pendingOrderDetailWC = [[RapidWebServiceConnection alloc]init];
    self.searchItemWC = [[RapidWebServiceConnection alloc]init];
    self.updatePendingOrderWC = [[RapidWebServiceConnection alloc]init];
    self.itemInfoWC = [[RapidWebServiceConnection alloc]init];
    self.insertDeliveryOrderWC = [[RapidWebServiceConnection alloc]init];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.manageObjectContext = self.rmsDbController.managedObjectContext;
    self.poNumber.text = self.pendingOrderDict[@"PO_No"];
    
    self.invoiceBG.layer.cornerRadius = 15;
    self.invoiceBG.layer.masksToBounds = YES;
    self.invoiceBG.layer.borderWidth = 0.5;
    self.invoiceBG.layer.borderColor = [[UIColor whiteColor] CGColor];

    
    NSString  *datetimeUpdate = [NSString stringWithFormat:@"%@",self.pendingOrderDict[@"CreatedDate"]];
    NSString *deliveryDate = [self getStringFormate:datetimeUpdate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
    self.poDate.text = deliveryDate;
    
    [self getPendingOrderItemList];
    
}
-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    return result;
}

-(void)getPendingOrderItemList{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[self.pendingOrderDict valueForKey:@"PoId"] forKey:@"PoId"];
    [itemparam setValue:[self.pendingOrderDict valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getPendingOrderItemDetailResponse:response error:error];
        });
    };
    
    self.pendingOrderDetailWC = [self.pendingOrderDetailWC initWithRequest:KURL actionName:WSM_GET_PURCHASE_ORDER_LISTING_DATA_IPHONE params:itemparam completionHandler:completionHandler];

}
- (void)getPendingOrderItemDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray *arrtempPoDataTempG = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            self.pendingOrderDetailData = [arrtempPoDataTempG.firstObject valueForKey:@"lstItem"];
            [self.tblPendingDetail reloadData];
            
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  150.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pendingOrderDetailData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderDetailCell *poOrderDetailcell = (POOrderDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderDetailCell"];
    poOrderDetailcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *orderItemDict = self.pendingOrderDetailData[indexPath.row];
    
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    poOrderDetailcell.RqSingle.text = [NSString stringWithFormat:@"%@", orderItemDict[@"ReOrder"]];
    if(anItem){
        [poOrderDetailcell configureItemDetail:orderItemDict withItem:anItem];
    }
    poOrderDetailcell.RqCashPack.text = [NSString stringWithFormat:@"%@/%@",orderItemDict[@"ReOrderCase"],orderItemDict[@"ReOrderPack"]];
    [poOrderDetailcell.buttonAction addTarget:self action:@selector(itemInfoTapped:) forControlEvents:UIControlEventTouchUpInside];
    return poOrderDetailcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItemIndPath = indexPath;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POItemReceiveDetail *poItemReceive = [storyBoard instantiateViewControllerWithIdentifier:@"POItemReceiveDetail"];
    NSDictionary *orderItemDict = self.pendingOrderDetailData[indexPath.row];
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    NSMutableDictionary *ItemInfo = [anItem.itemRMSDictionary mutableCopy];
    if (poItemReceive.itemInfoDataObject == nil) {
        poItemReceive.itemInfoDataObject = [[ItemInfoDataObject alloc]init];
    }
    poItemReceive.receiveItemDetail = self.pendingOrderDetailData[indexPath.row];
    [poItemReceive.itemInfoDataObject setItemMainDataFrom:[ItemInfo mutableCopy]];
    poItemReceive.itemDetailDelegate =  self;
    poItemReceive.isDelivery = self.isDelivery;
    poItemReceive.headeTitle = @"PENDING ORDER";
    [self.navigationController pushViewController:poItemReceive animated:YES];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self.tblPendingDetail setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self.pendingOrderDetailData removeObjectAtIndex:indexPath.row];
            [self.tblPendingDetail reloadData];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Are you sure you want to delete item in this order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}
#pragma mark POItemReceiveDetailDelegate Method

-(void)didChangeItemDetail:(NSDictionary *)itemDetail{
    
    [self.pendingOrderDetailData replaceObjectAtIndex:selectedItemIndPath.row withObject:itemDetail];
    [self.tblPendingDetail reloadRowsAtIndexPaths:@[selectedItemIndPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(IBAction)searchItem:(id)sender{
    
    InventoryItemSelectionListVC * objInventoryItemSelectionListVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemSelectionListVC_sid"];
    objInventoryItemSelectionListVC.delegate = self;
    objInventoryItemSelectionListVC.arrNotSelectedItemCodes = @[@(0)];
    objInventoryItemSelectionListVC.isSingleSelection = FALSE;
    objInventoryItemSelectionListVC.isItemActive = TRUE;
    objInventoryItemSelectionListVC.isItemInSelectMode = TRUE;
    objInventoryItemSelectionListVC.strNotSelectionMsg = @"";
    [self presentViewController:objInventoryItemSelectionListVC animated:false completion:nil];
    
}
#pragma mark InventoryItemSelectionListVCDelegate Method

-(void)didSelectedItems:(NSArray *)arrLitemList{
    
    for(int i=0;i<arrLitemList.count;i++)
    {
        Item *item = arrLitemList[i];
        NSMutableDictionary *dictSelected = [item.itemRMSDictionary mutableCopy];
        if([dictSelected  valueForKey:@"selected"])
        {
            //recordCount +=1;
            
            // removed unnecessery object from array
            [dictSelected removeObjectForKey:@"AddedQty"];
            [dictSelected removeObjectForKey:@"DepartId"];
            [dictSelected removeObjectForKey:@"DepartmentName"];
            [dictSelected removeObjectForKey:@"ItemDiscount"];
            [dictSelected removeObjectForKey:@"ItemImage"];
            [dictSelected removeObjectForKey:@"ItemSupplierData"];
            [dictSelected removeObjectForKey:@"ItemTag"];
            [dictSelected removeObjectForKey:@"MaxStockLevel"];
            [dictSelected removeObjectForKey:@"MinStockLevel"];
            [dictSelected removeObjectForKey:@"selected"];
            [dictSelected removeObjectForKey:@"ItemNo"];
            
            [dictSelected removeObjectForKey:@"EBT"];
            [dictSelected removeObjectForKey:@"NoDiscountFlg"];
            [dictSelected removeObjectForKey:@"POSDISCOUNT"];
            [dictSelected removeObjectForKey:@"TaxType"];
            [dictSelected removeObjectForKey:@"isTax"];
            [dictSelected removeObjectForKey:@"Remark"];
            
            [dictSelected setValue:@"0" forKey:@"FreeGoodsQty"];
            [dictSelected setValue:@"0" forKey:@"ReOrder"];
            
            dictSelected[@"ReOrderPack"] = @"0";
            dictSelected[@"ReOrderCase"] = @"0";
            
            [self.pendingOrderDetailData insertObject:dictSelected atIndex:0];
        }
    }
    [self.tblPendingDetail reloadData];
    [[self presentedViewController] dismissViewControllerAnimated:NO completion:nil];
    
    
}
-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}

#pragma mark - Camera Scan Delegate Methods

-(void)barcodeScanned:(NSString *)strBarcode
{
    self.universalSearch.text = strBarcode;
    [self textFieldShouldReturn:self.universalSearch];
}
-(void)itemInfoTapped:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    self.source =  sender;
    infoButtonPosition = [sender convertPoint:CGPointZero toView:self.tblPendingDetail];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[(self.pendingOrderDetailData)[[sender tag]] valueForKey:@"ItemId"] forKey:@"ItemId"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    [itemparam setValue:strDateTime forKey:@"LocalDateTime"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self getItemInfoResponse:response error:error];
        });
    };
    
    self.itemInfoWC = [self.itemInfoWC initWithRequest:KURL actionName:WSM_PO_ITEM_INFO params:itemparam completionHandler:completionHandler];
}

-(void)getItemInfoResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *arrSelectedItemInfo = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
                poOrderItemInfo = [storyBoard instantiateViewControllerWithIdentifier:@"POOrderItemInfo"];
                poOrderItemInfo.orderitemInfo = arrSelectedItemInfo.firstObject;
                poOrderItemInfo.view.frame = CGRectMake(0.0, 150.0, 320.0, 259.0);
                [poOrderItemInfo presentViewControllerForviewConteroller:self sourceView:self.source ArrowDirection:UIPopoverArrowDirectionLeft];
            }
            
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response  valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

-(IBAction)orderInfoClicked:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    poOrderInfo = [storyBoard instantiateViewControllerWithIdentifier:@"POOrderInfo"];
    poOrderInfo.orderItemList = [self.pendingOrderDetailData mutableCopy];
    poOrderInfo.view.frame = CGRectMake(0.0, 150.0, 320.0, 90.0);
    [poOrderInfo presentViewControllerForviewConteroller:self sourceView:self.source ArrowDirection:UIPopoverArrowDirectionLeft];
}


-(IBAction)logoutButton:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewCon in viewControllers) {
        if([viewCon isKindOfClass:[RimLoginVC class]]){
            [self.navigationController popToViewController:viewCon animated:YES];
        }
    }
}

- (NSMutableArray *) PoDetailxml
{
    
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.pendingOrderDetailData.count>0)
    {
        for (int isup=0; isup<self.pendingOrderDetailData.count; isup++)
        {
            NSMutableDictionary *tmpSup = [(self.pendingOrderDetailData)[isup] mutableCopy ];
            
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"ItemId",@"ReOrder",@"Sold",@"avaibleQty",@"ReOrderCase",@"ReOrderPack"];
            [speDict removeObjectsForKeys:removedKeys];
            
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];
        
            [tmpSup setValue:[tmpSup valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpSup setValue:[tmpSup valueForKey:@"Sold" ] forKey:@"SoldQty"];
            [tmpSup setValue:[tmpSup valueForKey:@"avaibleQty" ] forKey:@"AvailQty"];
            
            if(![tmpSup valueForKey:@"ReOrderPack" ]){
                [tmpSup setValue:@"0" forKey:@"ReOrderPack"];
                
            }
            else{
                [tmpSup setValue:[tmpSup valueForKey:@"ReOrderPack" ] forKey:@"ReOrderPack"];
                
            }
            if(![tmpSup valueForKey:@"ReOrderCase" ]){
                [tmpSup setValue:@"0" forKey:@"ReOrderCase"];
                
            }
            else{
                [tmpSup setValue:[tmpSup valueForKey:@"ReOrderCase" ] forKey:@"ReOrderCase"];
                
            }
            
            [tmpSup removeObjectForKey:@"ItemId"];
            [tmpSup removeObjectForKey:@"Sold"];
            [tmpSup removeObjectForKey:@"avaibleQty"];
            
            [itemSupplierData addObject:tmpSup];
        }
    }
    return itemSupplierData;
}
- (NSMutableArray *) PoReceiveDetailxml
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.pendingOrderDetailData.count>0)
    {
        for (int isup=0; isup<self.pendingOrderDetailData.count; isup++)
        {
            
            NSMutableDictionary *tmpSup = [(self.pendingOrderDetailData)[isup] mutableCopy ];
            
            [tmpSup setValue:[tmpSup valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpSup setValue:[tmpSup valueForKey:@"avaibleQty" ] forKey:@"AvailQty"];
            [tmpSup setValue:[tmpSup valueForKey:@"CostPrice" ] forKey:@"Cost"];
            [tmpSup setValue:[tmpSup valueForKey:@"SalesPrice" ] forKey:@"Price"];
            [tmpSup setValue:[tmpSup valueForKey:@"ProfitAmt" ] forKey:@"Margin"];
            
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"ItemCode",@"ReOrder",@"FreeGoodsQty",@"FreeGoodsQtyCase",@"FreeGoodsQtyPack",@"AvailQty",@"Cost",@"Price",@"Margin",@"ReOrderCase",@"ReOrderPack",@"CaseCost",@"CasePrice",@"PackCost",@"PackPrice"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];
            
            [tmpSup removeObjectForKey:@"Rvalue"];
            [tmpSup removeObjectForKey:@"Gvalue"];
            [tmpSup removeObjectForKey:@"NewAdded"];
            [tmpSup removeObjectForKey:@"ItemSelection"];
            
            [itemSupplierData addObject:tmpSup];
        }
    }
    return itemSupplierData;
}

-(BOOL)checkIsReceivedQtyZero{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ReOrder == %@ && ReOrderCase == %@ && ReOrderPack == %@",@"0",@"0",@"0"];
    NSArray *notReceiveItem = [self.pendingOrderDetailData filteredArrayUsingPredicate:predicate];
    
    if(notReceiveItem.count>0){
        return YES;
    }
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"ReOrder == %@ && ReOrderCase == %@ && ReOrderPack == %@",@(0),@(0),@(0)];
    NSArray *notReceiveItem2 = [self.pendingOrderDetailData filteredArrayUsingPredicate:predicate1];
    
    if(notReceiveItem2.count>0){
        return YES;
    }
    
    return NO;
}

-(IBAction)btnSaveOrderClick:(id)sender
{
    if([self checkIsReceivedQtyZero]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"ReOrder Qty not Zero" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
        
        if(self.viewInvNum.hidden == NO){
            
            if(_txtInvoiceNo.text.length == 0 && self.viewInvNum)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please enter invoice no." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
                return;
            }
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            
            NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
            dictPODetail[@"PoRecieveDetailxml"] = [self PoReceiveDetailxml];
            
            [dictPODetail setValue:[self.pendingOrderDict valueForKey:@"PO_No"] forKey:@"PO_No"];
            [dictPODetail setValue:[self.pendingOrderDict valueForKey:@"PoId"] forKey:@"PurchaseOrderId"];
            
            [dictPODetail setValue:[self.pendingOrderDict valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
            dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
            NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
            dictPODetail[@"UserId"] = userID;
            
            [dictPODetail setValue:_txtInvoiceNo.text forKey:@"InvoiceNo"];
            [dictPODetail setValue:@"Delivery" forKey:@"POstatus"];
            
            NSDate* date = [NSDate date];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
            NSString *strDateTime = [formatter stringFromDate:date];
            [dictPODetail setValue:strDateTime forKey:@"DateTime"];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self insertReceivePODetailResponse:response error:error];
                });
            };
            
            self.insertDeliveryOrderWC = [self.insertDeliveryOrderWC initWithRequest:KURL actionName:WSM_INSERT_RECIEVE_PO_DETAIL_IPHONE params:dictPODetail completionHandler:completionHandler];
            
        }
        else{
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            
            NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
            dictPODetail[@"PoDetailxml"] = [self PoDetailxml];
            dictPODetail[@"PoId"] = self.pendingOrderDict[@"PoId"];
            dictPODetail[@"POTitle"] = self.pendingOrderDict[@"POTitle"];
            dictPODetail[@"OrderNo"] = self.pendingOrderDict[@"OrderNo"];
            
            [dictPODetail setValue:@"Barcode,ITEM_Desc,SoldQty,AvailQty,ReOrder" forKey:@"ColumnsNames"];
            
            dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
            NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
            dictPODetail[@"UserId"] = userID;
            
            NSDate* date = [NSDate date];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
            NSString *strDateTime = [formatter stringFromDate:date];
            
            [dictPODetail setValue:strDateTime forKey:@"DateTime"];
            
            dictPODetail[@"OpenOrderId"] = self.pendingOrderDict[@"OpenOrderId"];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self pendingOrderDetailResponse:response error:error];
                });
            };
            
            self.updatePendingOrderWC = [self.updatePendingOrderWC initWithRequest:KURL actionName:WSM_UPDATE_OPEN_PO_DETAIL_NEW_IPHONE params:dictPODetail completionHandler:completionHandler];
        }

    }
}

- (void)insertReceivePODetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self.pOPendingOrderDetailDelegate insertDeliveryPendingOrder];
                    [self back:nil];
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:@"Order has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            else
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}


- (void)pendingOrderDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self back:nil];
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:@"Order has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            else
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if((textField == self.universalSearch) && self.universalSearch.text.length > 0)
    {
        [self searchScannedBarcode];
        self.universalSearch.text = @"";
        if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
        {
            [self.universalSearch becomeFirstResponder];
        }
        else
        {
            [self.universalSearch resignFirstResponder];
        }
    }
    return YES;
}

-(IBAction)searchItemWithBarcode:(id)sender{
    
    if(self.universalSearch.text.length > 0)
    {
        [self searchScannedBarcode];
        self.universalSearch.text = @"";
    }
}

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.manageObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

- (void)searchScannedBarcode
{
    BOOL isScanItemfound = FALSE;
    
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.rmsDbController.managedObjectContext];
    fetchRequest.entity = entity;
    
    self.searchText = self.universalSearch.text;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:self.searchText];
    BOOL isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
        self.searchText = [self.rmsDbController trimmedBarcode:self.searchText];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcode==%@", self.searchText];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.rmsDbController.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    
    NSMutableDictionary *dictTempGlobal = [item.itemRMSDictionary mutableCopy];
    
    if(dictTempGlobal != nil)
    {
        dictTempGlobal[@"AddedQty"] = @"1";
        
        NSString * strItemCode=[NSString stringWithFormat:@"%d",[[dictTempGlobal valueForKey:@"ItemId"]intValue]];
        
        BOOL isExtisData=FALSE;
        
        if(self.pendingOrderDetailData.count>0)
        {
            for (int idata=0; idata<self.pendingOrderDetailData.count; idata++) {
                NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.pendingOrderDetailData)[idata]valueForKey:@"ItemId"]intValue]];
                if([sItemId isEqualToString:strItemCode])
                {
                    isExtisData=TRUE;
                    break;
                }
            }
        }
        if(isExtisData)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Item already existed." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            [dictTempGlobal removeObjectForKey:@"DepartId"];
            [dictTempGlobal removeObjectForKey:@"ItemDiscount"];
            [dictTempGlobal removeObjectForKey:@"ItemImage"];
            [dictTempGlobal removeObjectForKey:@"ItemSupplierData"];
            [dictTempGlobal removeObjectForKey:@"ItemTag"];
            [dictTempGlobal removeObjectForKey:@"ProfitAmt"];
            [dictTempGlobal removeObjectForKey:@"ProfitType"];
            [dictTempGlobal removeObjectForKey:@"Remark"];
            [dictTempGlobal removeObjectForKey:@"SalesPrice"];
            [dictTempGlobal removeObjectForKey:@"selected"];
            [dictTempGlobal removeObjectForKey:@"ItemNo"];
            
            [dictTempGlobal removeObjectForKey:@"EBT"];
            [dictTempGlobal removeObjectForKey:@"NoDiscountFlg"];
            [dictTempGlobal removeObjectForKey:@"POSDISCOUNT"];
            [dictTempGlobal removeObjectForKey:@"TaxType"];
            [dictTempGlobal removeObjectForKey:@"isTax"];
            
            
            [dictTempGlobal setValue:@"0" forKey:@"FreeGoodsQty"];
            [dictTempGlobal setValue:@"0" forKey:@"ReOrder"];
            
            [self.pendingOrderDetailData insertObject:dictTempGlobal atIndex:0];
            [self.tblPendingDetail reloadData];
        }
        isScanItemfound = TRUE;
        [self.universalSearch becomeFirstResponder];
    }
    if(!isScanItemfound)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:self.searchText forKey:@"Code"];
        [itemparam setValue:@"Barcode" forKey:@"Type"];
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responsePendingDeliveryDataResponse:response error:error];
            });
        };
        
        self.searchItemWC = [self.searchItemWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
        
    }
}

-(void)responsePendingDeliveryDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if(response!=nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            
            NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
            if(itemResponseArray.count > 0)
            {
                [self.updateManager updateObjectsFromResponseDictionary:responseDictionary];
                [self.updateManager linkItemToDepartmentFromResponseDictionary:responseDictionary];
                Item *anItem=[self fetchAllItems:[[[responseDictionary valueForKey:@"ItemArray"] firstObject ]valueForKey:@"ITEMCode"]];
                NSMutableDictionary *dictTempGlobal = [NSMutableDictionary dictionaryWithDictionary:anItem.itemRMSDictionary];
                
                [dictTempGlobal removeObjectForKey:@"DepartId"];
                [dictTempGlobal removeObjectForKey:@"ItemDiscount"];
                [dictTempGlobal removeObjectForKey:@"ItemImage"];
                [dictTempGlobal removeObjectForKey:@"ItemSupplierData"];
                [dictTempGlobal removeObjectForKey:@"ItemTag"];
                [dictTempGlobal removeObjectForKey:@"ProfitAmt"];
                [dictTempGlobal removeObjectForKey:@"ProfitType"];
                [dictTempGlobal removeObjectForKey:@"Remark"];
                [dictTempGlobal removeObjectForKey:@"SalesPrice"];
                [dictTempGlobal removeObjectForKey:@"selected"];
                [dictTempGlobal removeObjectForKey:@"ItemNo"];
                
                [dictTempGlobal removeObjectForKey:@"EBT"];
                [dictTempGlobal removeObjectForKey:@"NoDiscountFlg"];
                [dictTempGlobal removeObjectForKey:@"POSDISCOUNT"];
                [dictTempGlobal removeObjectForKey:@"TaxType"];
                [dictTempGlobal removeObjectForKey:@"isTax"];
                
                [dictTempGlobal setValue:@"0" forKey:@"ReOrder"];
                [dictTempGlobal setValue:@"0" forKey:@"FreeGoodsQty"];
                
                [self.pendingOrderDetailData insertObject:dictTempGlobal atIndex:0];
                [self.tblPendingDetail reloadData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No record found open pending delivery order" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}
#pragma mark Open More Option

-(IBAction)openMoreOption:(id)sender{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"MORE" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.pendingOrderDetailData.count>0)
        {
            [self htmlBillText:self.pendingOrderDetailData];
            
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.pendingOrderDetailData.count>0)
        {
            [self htmlBillTextForPreview:self.pendingOrderDetailData];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"purchaseorderitem" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    EmailFromViewController *objEmail = [[EmailFromViewController alloc]initWithNibName:@"EmailFromViewController" bundle:nil];
    
    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    NSString *strsubjectLine = @"";
    
    objEmail.dictParameter =[[NSMutableDictionary alloc]init];
    (objEmail.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (objEmail.dictParameter)[@"Subject"] = strsubjectLine;
    (objEmail.dictParameter)[@"postfile"] = myData;
    (objEmail.dictParameter)[@"InvoiceNo"] = @"";
    (objEmail.dictParameter)[@"HtmlString"] = stringHtml;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:objEmail animated:YES
                         completion:nil];
    });
}

-(void)writeDataOnCacheDirectory :(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.emaiItemHtml])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.emaiItemHtml error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.emaiItemHtml = [documentsDirectory stringByAppendingPathComponent:@"ReconcileItemList.html"];
    [data writeToFile:self.emaiItemHtml atomically:YES];
}

-(NSString *)htmlBillHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"%@",@"Open Order"]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    if([arrayInvoice.firstObject valueForKey:@"lstItem"]){
        
        NSString *CreatedDate = [arrayInvoice.firstObject valueForKey:@"CreatedDate"];
        
        NSString *strDate = [self getStringFormate:CreatedDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MM/dd/yyyy"];
        
        NSString *strTime = [self getStringFormate:CreatedDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
        
        html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    }
    else{
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy";
        NSString* strDate = [formatter stringFromDate:date];
        NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init];
        formatter2.dateFormat = @"hh:mm a";
        NSString* strTime = [formatter2 stringFromDate:date];
        
        html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    }
    
    return html;
}

-(NSString *)htmlBillTextForItem:(NSMutableArray *)arrayInvoice
{
    NSString *itemHtml = @"";
    for (int i=0; i<arrayInvoice.count; i++)
    {
        
        // set Item Detail with only 1 qty....
        NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:arrayInvoice[i]];
        itemHtml = [itemHtml stringByAppendingFormat:@"%@",strHTML];
        
        
    }
    
    return itemHtml;
}
-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td>&nbsp</td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></td><td align=\"center\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"Sold"],[itemDictionary[@"avaibleQty"]floatValue],[itemDictionary[@"ReOrder"]floatValue],itemDictionary[@"MaxStockLevel"],itemDictionary[@"MinStockLevel"]];
    
    return htmldata;
    
}


-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"purchaseorderitem" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceipt.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    
    
    
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    // objPreviewandPrint.strPdfFilePath=htmlToPDF.PDFpath;
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
    // objPreviewandPrint.strPdfFilePath=result;
    
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    // present the preview
    [self.controller presentPreviewAnimated:YES];
    
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}
- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
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
