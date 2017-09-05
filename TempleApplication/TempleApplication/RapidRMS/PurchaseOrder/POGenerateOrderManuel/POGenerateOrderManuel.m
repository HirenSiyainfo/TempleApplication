//
//  POGenerateOrderManuel.m
//  RapidRMS
//
//  Created by Siya10 on 10/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POGenerateOrderManuel.h"
#import "RmsDbController.h"
#import "POOrderDetailCell.h"
#import "ItemInfoEditVC.h"
#import "ItemDetailEditVC.h"
#import "POItemReceiveDetail.h"
#import "RimLoginVC.h"
#import "InventoryItemSelectionListVC.h"
#import "CameraScanVC.h"
#import "EmailFromViewController.h"
#import "POOrderInfo.h"


@interface POGenerateOrderManuel ()<POItemReceiveDetailDelegate,InventoryItemSelectionListVCDelegate,CameraScanVCDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,UpdateDelegate>
{
    NSIndexPath *selectedItemIndPath;
    POOrderInfo *poOrderInfo;
    
}
@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;
@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RapidWebServiceConnection *searchItemWC;
@property (nonatomic, strong) RapidWebServiceConnection *createOrderDetailWC;

@property (nonatomic, strong) CameraScanVC *cameraScanVC ;
@property (nonatomic, weak) IBOutlet UITextField *universalSearch;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

@property(nonatomic,strong)NSString *searchText;
@property (nonatomic, strong) NSString *emaiItemHtml;

@property(nonatomic,weak)IBOutlet UITextField *txtWorkDetail;
@property(nonatomic,weak)IBOutlet UIView *workDetail;
@property(nonatomic,weak)IBOutlet UILabel *lblDate;

@property(nonatomic,weak) IBOutlet UITableView *tblNewOrder;
@property(nonatomic,strong) NSMutableArray *createOrderData;
@end

@implementation POGenerateOrderManuel

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.searchItemWC = [[RapidWebServiceConnection alloc]init];
    self.createOrderDetailWC = [[RapidWebServiceConnection alloc]init];
    self.manageObjectContext = self.rmsDbController.managedObjectContext;
    
    self.workDetail.layer.cornerRadius = 15;
    self.workDetail.layer.masksToBounds = YES;
    self.workDetail.layer.borderWidth = 0.5;
    self.workDetail.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.createOrderData = [[NSMutableArray alloc]init];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM,dd yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    _lblDate.text = strDateTime;

}
-(void)didChangeItemDetail:(NSDictionary *)itemDetail{
    
    [self.createOrderData replaceObjectAtIndex:selectedItemIndPath.row withObject:itemDetail];
    [self.tblNewOrder reloadRowsAtIndexPaths:@[selectedItemIndPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tblNewOrder reloadData];
}
-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}
-(void)barcodeScanned:(NSString *)strBarcode{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  150.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.createOrderData count];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self.tblNewOrder setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self.createOrderData removeObjectAtIndex:indexPath.row];
            [self.tblNewOrder reloadData];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Generate Order" message:@"Are you sure you want to delete item in this order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderDetailCell *poOrderDetailcell = (POOrderDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderDetailCell"];
    poOrderDetailcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *orderItemDict = self.createOrderData[indexPath.row];
    
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    poOrderDetailcell.RqSingle.text = [NSString stringWithFormat:@"%@", orderItemDict[@"ReOrder"]];
    if(anItem){
        [poOrderDetailcell configureItemDetail:orderItemDict withItem:anItem];
    }
    
    poOrderDetailcell.RqCashPack.text = [NSString stringWithFormat:@"%@/%@",orderItemDict[@"ReOrderCase"],orderItemDict[@"ReOrderPack"]];

    return poOrderDetailcell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItemIndPath = indexPath;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POItemReceiveDetail *poItemReceive = [storyBoard instantiateViewControllerWithIdentifier:@"POItemReceiveDetail"];
    NSDictionary *orderItemDict = self.createOrderData[indexPath.row];
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    NSMutableDictionary *ItemInfo = [anItem.itemRMSDictionary mutableCopy];
    if (poItemReceive.itemInfoDataObject == nil) {
        poItemReceive.itemInfoDataObject = [[ItemInfoDataObject alloc]init];
    }
    poItemReceive.receiveItemDetail = self.createOrderData[indexPath.row];
    [poItemReceive.itemInfoDataObject setItemMainDataFrom:[ItemInfo mutableCopy]];
    poItemReceive.itemDetailDelegate =  self;
    poItemReceive.isDelivery  = NO;
    [self.navigationController pushViewController:poItemReceive animated:YES];
    
}
-(void)didupdateItemInformation{
    
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
    [textField resignFirstResponder];
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
        
        if(self.createOrderData.count>0)
        {
            for (int idata=0; idata<self.createOrderData.count; idata++) {
                NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.createOrderData)[idata]valueForKey:@"ItemId"]intValue]];
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
            
            [self.createOrderData insertObject:dictTempGlobal atIndex:0];
            [self.tblNewOrder reloadData];
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
                
                [self.createOrderData insertObject:dictTempGlobal atIndex:0];
                [self.tblNewOrder reloadData];
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
- (NSMutableArray *) PoReceiveDetailxml
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    
    if(self.createOrderData.count>0)
    {
        for (int isup=0; isup<self.createOrderData.count; isup++)
        {
            NSMutableDictionary *tmpOdrDict=(self.createOrderData)[isup];
            [tmpOdrDict removeObjectForKey:@"Barcode"];
            [tmpOdrDict removeObjectForKey:@"CreatedDate"];
            [tmpOdrDict removeObjectForKey:@"ItemName"];
            [tmpOdrDict removeObjectForKey:@"ProfitType"];
            
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"avaibleQty" ] forKey:@"AvailQty"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"CostPrice" ] forKey:@"Cost"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"SalesPrice" ] forKey:@"Price"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"ProfitAmt" ] forKey:@"Margin"];
            
            [tmpOdrDict removeObjectForKey:@"ItemId"];
            [tmpOdrDict removeObjectForKey:@"avaibleQty"];
            [tmpOdrDict removeObjectForKey:@"CostPrice"];
            [tmpOdrDict removeObjectForKey:@"SalesPrice"];
            [tmpOdrDict removeObjectForKey:@"ProfitAmt"];
            [tmpOdrDict removeObjectForKey:@"Rvalue"];
            [tmpOdrDict removeObjectForKey:@"Gvalue"];
            [tmpOdrDict removeObjectForKey:@"LastReceivedDate"];
            [tmpOdrDict removeObjectForKey:@"NewAdded"];
            
            [itemSupplierData addObject:tmpOdrDict];
        }
    }
    return itemSupplierData;
}
-(IBAction)orderInfoClicked:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    poOrderInfo = [storyBoard instantiateViewControllerWithIdentifier:@"POOrderInfo"];
    poOrderInfo.orderItemList = [self.createOrderData mutableCopy];
    poOrderInfo.view.frame = CGRectMake(0.0, 150.0, 320.0, 90.0);
    [poOrderInfo presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionLeft];
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

#pragma mark InventoryItemSelectionListVCDeleagate Method

-(void)didSelectedItems:(NSArray *)arrLitemList{
    
    for(int i=0;i<arrLitemList.count;i++)
    {
        Item *item = arrLitemList[i];
        NSMutableDictionary *dictSelected = [item.itemRMSDictionary mutableCopy];
        if([dictSelected  valueForKey:@"selected"])
        {
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
            
            [self.createOrderData insertObject:dictSelected atIndex:0];
        }
    }
    [self.tblNewOrder reloadData];
    [[self presentedViewController] dismissViewControllerAnimated:NO completion:nil];
    
}

#pragma mark Open More Option

-(IBAction)openMoreOption:(id)sender{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"MORE" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.createOrderData.count>0)
        {
            [self htmlBillText:self.createOrderData];
            
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.createOrderData.count>0)
        {
            [self htmlBillTextForPreview:self.createOrderData];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(IBAction)btnSaveOrderClick:(id)sender
{
    [self callWCNewPurchaseOrder];
}


-(void)callWCNewPurchaseOrder{
    
    if(self.txtWorkDetail.text.length  == 0){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Enter Work Detail" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    
    if(self.createOrderData.count > 0){
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSArray *arrOrder = [self.createOrderData valueForKey:@"ReOrder"];
        BOOL isWebService = FALSE;
        for(NSString * strOrderValue in arrOrder)
        {
            if (strOrderValue.intValue > 0) {
                isWebService = TRUE;
                break;
            }
        }
        if(isWebService)
        {
            
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            
            NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
            dictPODetail[@"PoDetailxml"] = [self PoDetailxml];
            
            dictPODetail[@"PoId"] = @"0";
            
            dictPODetail[@"PO_No"] = @"";
            dictPODetail[@"POTitle"] = self.txtWorkDetail.text;
            dictPODetail[@"OrderNo"] = @"";
            
            [dictPODetail setValue:@"" forKey:@"FromDate"];
            [dictPODetail setValue:@"" forKey:@"ToDate"];
            
            [dictPODetail setValue:@"" forKey:@"SupplierIds"];
            [dictPODetail setValue:@"" forKey:@"DeptIds"];
            [dictPODetail setValue:@"" forKey:@"Tags"];
            
            [dictPODetail setValue:@"-1" forKey:@"MinStock"];
            
            
            [dictPODetail setValue:self.selectedVendor[@"VendorId"] forKey:@"VendorId"];
            [dictPODetail setValue:@"" forKey:@"TimeDuration"];
            [dictPODetail setValue:@"Barcode,ITEM_Desc,SoldQty,AvailQty,ReOrder" forKey:@"ColumnsNames"];
            
            dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
            NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
            dictPODetail[@"UserId"] = userID;
            
            //hiten
            
            NSString *strDate =   [self getStringFormate:self.lblDate.text fromFormate:@"MMMM,dd yyyy hh:mm a" toFormate:@"MM/dd/yyyy hh:mm a"];
            
            [dictPODetail setValue:strDate forKey:@"DateTime"];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self responseInsertOpenPoResponse:response error:error];
                });
            };
            
            self.createOrderDetailWC = [self.createOrderDetailWC initWithRequest:KURL actionName:WSM_UPDATE_PO_DETAIL_NEW_IPHONE params:dictPODetail completionHandler:completionHandler];
            
        }
        
        else{
            [_activityIndicator hideActivityIndicator];
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Add Reoder quantity." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
    else
    {
        [_activityIndicator hideActivityIndicator];
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Add Item to Placed Order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    
    
}
- (NSMutableArray *)PoDetailxml
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.createOrderData.count>0)
    {
        for (int isup=0; isup<self.createOrderData.count; isup++)
        {
            NSMutableDictionary *tmpSup = [(self.createOrderData)[isup] mutableCopy ];
            
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

- (void)responseInsertOpenPoResponse:(id)response error:(NSError *)error{
    
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
                [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Order has been created successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
    
    
}
-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"deliverypanding" ofType:@"html"];
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
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"Open Order"]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]
                                                                                     ]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    //    NSString  *Datetime = [NSString stringWithFormat:@"%@",[[arrayInvoice firstObject] valueForKey:@"CreatedDate"]];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString  *currentDateTime = [formatter stringFromDate:date];
    NSString *strTime = [self getStringFormate:currentDateTime fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"hh:mm a"];
    NSString *strDate = [self getStringFormate:currentDateTime fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"MMM dd, yyyy"];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"%@",strDate]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    
    return html;
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
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"left\" valign=\"top\"style=\"width:50%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"AddedQty"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"avaibleQty"]];
    return htmldata;
}

-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"deliverypanding" ofType:@"html"];
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
-(IBAction)logoutButton:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewCon in viewControllers) {
        if([viewCon isKindOfClass:[RimLoginVC class]]){
            [self.navigationController popToViewController:viewCon animated:YES];
        }
    }
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
