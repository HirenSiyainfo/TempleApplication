//
//  POOpenOrderDetail.m
//  RapidRMS
//
//  Created by Siya10 on 14/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POOpenOrderDetail.h"
#import "RmsDbController.h"
#import "POOrderDetailCell.h"
#import "RimLoginVC.h"
#import "CameraScanVC.h"
#import "ItemDetailEditVC.h"
#import "POOrderItemInfo.h"
#import "ItemInfoEditVC.h"
#import "POOpenOrderFilter.h"
#import "POItemReceiveDetail.h"
#import "Department+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "POManualFilterItems.h"
#import "EmailFromViewController.h"
#import "InventoryItemSelectionListVC.h"

@interface POOpenOrderDetail ()<UpdateDelegate,CameraScanVCDelegate,ItemInfoEditVCDelegate,ItemInfoEditRedirectionVCDelegate,POItemReceiveDetailDelegate,POOpenOrderFilteDelegate,POManualFilterItemsDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,InventoryItemSelectionListVCDelegate>
{
    POOrderItemInfo *poOrderItemInfo;
    POOpenOrderFilter *poOpenOrderFilter;
    NSIndexPath *selectedItemIndPath;

}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *createOrderDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *openOrderDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *searchItemWC;
@property (nonatomic, strong) RapidWebServiceConnection *itemInfoWC;
@property (nonatomic, strong) RapidWebServiceConnection *updateOpenOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *createOpenOrderWC;

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;

@property(nonatomic,weak)IBOutlet UITableView *tblOpenOrderDetail;
@property(nonatomic,strong)NSMutableArray *departmentArray;
@property(nonatomic,strong)NSMutableArray *supplierArray;

@property (nonatomic, strong) UpdateManager *updateManager;

@property(nonatomic,weak)IBOutlet UILabel *poNumber;
@property(nonatomic,weak)IBOutlet UILabel *poDate;
@property (nonatomic, strong) NSString *emaiItemHtml;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property(nonatomic,weak)UIButton *source;
@property(nonatomic,weak)IBOutlet UIButton *btnFilter;

@property(nonatomic,weak)IBOutlet UITextField *universalSearch;
@property(nonatomic,strong)NSString *searchText;
@property (nonatomic, weak) IBOutlet UIView *viewFilterBG;


@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@end

@implementation POOpenOrderDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeObject];
    

    // Do any additional setup after loading the view.
}
-(void)initializeObject{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.openOrderDetailWC = [[RapidWebServiceConnection alloc]init];
    self.searchItemWC = [[RapidWebServiceConnection alloc]init];
    self.updateOpenOrderWC = [[RapidWebServiceConnection alloc]init];
    self.createOpenOrderWC = [[RapidWebServiceConnection alloc]init];
    self.createOrderDetailWC = [[RapidWebServiceConnection alloc]init];
    self.itemInfoWC = [[RapidWebServiceConnection alloc]init];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.manageObjectContext = self.rmsDbController.managedObjectContext;
    self.poNumber.text = self.openOrderDict[@"PO_No"];
   
    NSString  *datetimeUpdate = [NSString stringWithFormat:@"%@",self.openOrderDict[@"CreatedDate"]];
    NSString *orderDate = [self getStringFormate:datetimeUpdate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
    self.poDate.text = orderDate;

    if(self.openOrderDetailData.count == 0){
        [self getOpenOrderItemList];
    }
    else{
        [self addFilter:self.openOrderDetailData];
    }
}

#pragma mark - RapidFilters -
-(void)addFilterView:(NSMutableArray *)openOrderList{
    if (!poOpenOrderFilter) {
        poOpenOrderFilter = [[UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"POOpenOrderFilter"];
        poOpenOrderFilter.view.frame = CGRectMake(self.viewFilterBG.bounds.size.width, 0, self.viewFilterBG.bounds.size.width, self.viewFilterBG.bounds.size.height);
           poOpenOrderFilter.suppArray = self.supplierArray;
        poOpenOrderFilter.deptArray = self.departmentArray;
        poOpenOrderFilter.poOpenOrderFilterDelegate = self;
        [self addChildViewController:poOpenOrderFilter];
        [self.viewFilterBG addSubview:poOpenOrderFilter.view];
        [poOpenOrderFilter didMoveToParentViewController:self];
    }
}
#pragma mark POOpenOrderFilteDelegate Method

-(void)didapplyFilterToItems:(NSMutableArray *)deptArray withSup:(NSMutableArray *)supArray{
    
    self.departmentArray = deptArray;
    self.supplierArray = supArray;
    [poOpenOrderFilter filterViewSlideIn:false];
    self.btnFilter.selected = false;
    [self filterDepartmentamdSupplierforFilterList:[self departmentListQuery:deptArray] andSuppPredicate:[self supplierListQuery:supArray]];
}

-(NSString *)departmentListQuery:(NSMutableArray *)arrayDepartment{
    
    NSString *strPredicateDept;
    NSString *strDeptIdList;

    NSMutableString *strResult = [NSMutableString string];
    NSMutableString *strdeptResult = [NSMutableString string];
    if(arrayDepartment.count>0)
    {
        for(int i=0;i < arrayDepartment.count;i++){
            
            NSMutableDictionary *dict = (arrayDepartment)[i];
            if([[dict valueForKey:@"selection"] isEqualToString:@"1"]){
                
                NSString *ch = [dict valueForKey:@"DeptId"];
                [strResult appendFormat:@"DeptId == %@ OR ", ch];
                [strdeptResult appendFormat:@"%@,", ch];
            }
        }
        if(strResult.length>0)
        {
            strPredicateDept = [strResult substringToIndex:strResult.length-4];
            strDeptIdList = [strdeptResult substringToIndex:strdeptResult.length-1];
            
        }
        else{
            strPredicateDept =@"";
            strDeptIdList=@"";
        }
    }
    return strPredicateDept;
}

-(NSString *)supplierListQuery:(NSMutableArray *)arraySupplier{
    
    NSString *strPredicateSupp;
    NSString *strSuppIdList;
    
    NSMutableString *strResult = [NSMutableString string];
    NSMutableString *strsuppResult = [NSMutableString string];
    if(arraySupplier.count>0)
    {
        for(int i=0;i < arraySupplier.count;i++){
            
            NSMutableDictionary *dict = (arraySupplier)[i];
            if([[dict valueForKey:@"selection"] isEqualToString:@"1"]){
                
                NSString *ch = [dict valueForKey:@"Suppid"];
                [strResult appendFormat:@"SupplierIds contains[cd] \"%@\" OR ", ch];
                [strsuppResult appendFormat:@"%@,", ch];
            }
            
        }
        if(strResult.length>0)
        {
            strPredicateSupp = [strResult substringToIndex:strResult.length-4];
            strSuppIdList = [strsuppResult substringToIndex:strsuppResult.length-1];
        }
        else{
            strPredicateSupp = @"";
            strSuppIdList = @"";
        }
    }
    return strPredicateSupp;
}

-(void)filterDepartmentamdSupplierforFilterList:(NSString *)deptPredicate andSuppPredicate:(NSString *)suppPredicate{
    
    if(deptPredicate.length > 0 && suppPredicate.length == 0)
    {
        [self.openOrderDetailData removeAllObjects];
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@",deptPredicate]];
        
        self.openOrderDetailData = [[self.globalopenOrderDetailData filteredArrayUsingPredicate:datePredicate] mutableCopy];
        [self.tblOpenOrderDetail reloadData];
    }
    else if(deptPredicate.length > 0 && suppPredicate.length == 0){
        
        [self.openOrderDetailData removeAllObjects];
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:suppPredicate];
        self.openOrderDetailData = [[self.globalopenOrderDetailData filteredArrayUsingPredicate:datePredicate] mutableCopy];
        [self.tblOpenOrderDetail reloadData];
    }
    else if(deptPredicate.length > 0 && suppPredicate.length > 0){
        
        [self.openOrderDetailData removeAllObjects];
        NSString *strPredicate=[NSString stringWithFormat:@"%@ AND %@",deptPredicate,suppPredicate];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:strPredicate];
        self.openOrderDetailData = [[self.globalopenOrderDetailData filteredArrayUsingPredicate:datePredicate] mutableCopy ];
        [self.tblOpenOrderDetail reloadData];
    }
    else if(deptPredicate.length == 0 && suppPredicate.length == 0){
        
        [self.openOrderDetailData removeAllObjects];
        self.openOrderDetailData = [self.globalopenOrderDetailData mutableCopy];
        [self.tblOpenOrderDetail reloadData];
    }

}

#pragma mark Load Manual Filter Option

-(void)didloadManuelFilterOption{
    
    POManualFilterItems *poManualFilterItems = [[UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"POManualFilterItems"];
    poManualFilterItems.manualFilterItems = self.openOrderDetailData;
    poManualFilterItems.poManualFilterItemsDelegate = self;
    [self.navigationController pushViewController:poManualFilterItems animated:YES];

}
#pragma mark POManualFilterItemsDelegate Method

-(void)didsaveWithSelectedItems:(NSMutableArray *)selecteditems{
    
    [poOpenOrderFilter filterViewSlideIn:false];
    self.btnFilter.selected = false;
    [self setDefaultSupplierandDepartment];
    
    NSMutableArray *selectedItems = [[NSMutableArray alloc]init];
    for (NSIndexPath *indPath in selecteditems) {
        
        NSDictionary *dictitem = self.openOrderDetailData[indPath.row];
        [selectedItems addObject:dictitem];
    }
    
    if(selectedItems.count>0){
      
        self.openOrderDetailData = selectedItems;
        [self.tblOpenOrderDetail reloadData];
    }
}

-(void)setDefaultSupplierandDepartment{
    
    for (NSMutableDictionary *dept in self.departmentArray) {
        dept[@"selection"] = @"0";
    }
    for (NSMutableDictionary *supp in self.supplierArray) {
        supp[@"selection"] = @"0";
    }

}
-(IBAction)filterClick:(id)sender{
    if(self.btnFilter.selected){
        [poOpenOrderFilter filterViewSlideIn:false];
        self.btnFilter.selected = false;
    }
    else{
        [poOpenOrderFilter filterViewSlideIn:true];
        self.btnFilter.selected = true;
        
    }
}


-(void)getOpenOrderItemList{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[self.openOrderDict valueForKey:@"PoId"] forKey:@"PoId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getOpenOrderItemListResponse:response error:error];
        });
    };
    
    self.openOrderDetailWC = [self.openOrderDetailWC initWithRequest:KURL actionName:WSM_GET_PURCHASE_ORDER_LISTING_DATA_IPHONE params:itemparam completionHandler:completionHandler];
}

- (void)getOpenOrderItemListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray *arrtempPoDataTempG = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            self.openOrderDict = arrtempPoDataTempG.firstObject;
            [self supplierDepartmentArray:arrtempPoDataTempG];
            [self addFilter:arrtempPoDataTempG];
            self.openOrderDetailData = [arrtempPoDataTempG.firstObject valueForKey:@"lstItem"];
            self.globalopenOrderDetailData = [self.openOrderDetailData mutableCopy];
            [self.tblOpenOrderDetail reloadData];
            
        }
    }
}

-(void)addFilter:(NSMutableArray *)arrtempPoDataTempG{
    [self addFilterView:arrtempPoDataTempG];
    [poOpenOrderFilter filterViewSlideIn:false];
    self.btnFilter.selected = false;
}
-(void)supplierDepartmentArray:(NSMutableArray *)pArrayTemp{
    
    NSArray *deptIdsArray = [[NSMutableArray alloc]init];
    deptIdsArray = [[pArrayTemp valueForKey:@"lstItem"] firstObject];
    
    NSArray * arrDeptID = [pArrayTemp valueForKeyPath:@"lstItem.DeptId"];
    arrDeptID = [arrDeptID.firstObject valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    self.departmentArray = arrDeptID.mutableCopy;

    NSMutableArray *suppIdsArray = [[NSMutableArray alloc]init];
    suppIdsArray = [[pArrayTemp valueForKey:@"lstItem"] firstObject];
    
    NSArray *supplierId = [[NSMutableArray alloc]init];
    NSArray * arrSID = [pArrayTemp valueForKeyPath:@"lstItem.SupplierIds"];
    supplierId = [[arrSID.firstObject componentsJoinedByString:@","] componentsSeparatedByString:@","];
    supplierId = [supplierId valueForKeyPath:@"@distinctUnionOfObjects.self"];
    self.supplierArray = supplierId.mutableCopy;

//    self.departmentArray = [[pArrayTemp.firstObject[@"DeptIds"] componentsSeparatedByString:@","] mutableCopy];
//    self.supplierArray = [[pArrayTemp.firstObject[@"SupplierIds"] componentsSeparatedByString:@","]mutableCopy];
    
    if(self.departmentArray.count > 0 || [pArrayTemp.firstObject[@"DeptIds"] length] > 0){
        
        for(int i=0;i<self.departmentArray.count;i++){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            dict[@"DeptId"] = (self.departmentArray)[i];
            Department *department = (Department *)[self.updateManager __fetchEntityWithName:@"Department" key:@"deptId" value:dict[@"DeptId"] shouldCreate:NO moc:self.manageObjectContext];
            if(department){
                dict[@"selection"] = @"0";
                dict[@"DeptName"] = department.deptName;
                (self.departmentArray)[i] = dict;
            }
            else{
                [self.departmentArray removeObjectAtIndex:i];
                i--;
            }
            
        }
    }
    
    if(self.supplierArray.count > 0 || [pArrayTemp.firstObject[@"SupplierIds"] length] > 0){
        
        for(int i=0;i<self.supplierArray.count;i++){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            dict[@"Suppid"] = (self.supplierArray)[i];
            SupplierCompany *supplier = (SupplierCompany *)[self.updateManager __fetchEntityWithName:@"SupplierCompany" key:@"companyId" value:[NSNumber numberWithInteger:[dict[@"Suppid"] integerValue]]  shouldCreate:NO moc:self.manageObjectContext];
            if (supplier) {
                dict[@"selection"] = @"0";
                dict[@"SuppName"] = supplier.companyName;
                (self.supplierArray)[i] = dict;

            }
            else{
                [self.supplierArray removeObjectAtIndex:i];
                i--;
            }
        }
    }
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  150.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.openOrderDetailData count];
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self.tblOpenOrderDetail setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self.openOrderDetailData removeObjectAtIndex:indexPath.row];
            [self.tblOpenOrderDetail reloadData];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Are you sure you want to delete item in this order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderDetailCell *poOrderDetailcell = (POOrderDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderDetailCell"];
    poOrderDetailcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *orderItemDict = self.openOrderDetailData[indexPath.row];
    
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
    NSDictionary *orderItemDict = self.openOrderDetailData[indexPath.row];
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    NSMutableDictionary *ItemInfo = [anItem.itemRMSDictionary mutableCopy];
    if (poItemReceive.itemInfoDataObject == nil) {
        poItemReceive.itemInfoDataObject = [[ItemInfoDataObject alloc]init];
    }
    poItemReceive.receiveItemDetail = self.openOrderDetailData[indexPath.row];
    [poItemReceive.itemInfoDataObject setItemMainDataFrom:[ItemInfo mutableCopy]];
    poItemReceive.itemDetailDelegate =  self;
    poItemReceive.isDelivery  = NO;
    poItemReceive.headeTitle = @"OPEN ORDER";
    [self.navigationController pushViewController:poItemReceive animated:YES];
    
}

#pragma mark POItemReceiveDetailDelegate Method

-(void)didChangeItemDetail:(NSDictionary *)itemDetail{
    
    [self.openOrderDetailData replaceObjectAtIndex:selectedItemIndPath.row withObject:itemDetail];
    [self.tblOpenOrderDetail reloadRowsAtIndexPaths:@[selectedItemIndPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)itemInfoTapped:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    self.source =  sender;

    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[(self.openOrderDetailData)[[sender tag]] valueForKey:@"ItemId"] forKey:@"ItemId"];
    
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
            
            [self.openOrderDetailData insertObject:dictSelected atIndex:0];
        }
    }
    [self.tblOpenOrderDetail reloadData];
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

- (NSMutableArray *) PoDetailxml
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.openOrderDetailData.count>0)
    {
        for (int isup=0; isup<self.openOrderDetailData.count; isup++)
        {
            NSMutableDictionary *tmpSup = [(self.openOrderDetailData)[isup] mutableCopy ];
            
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

-(BOOL)checkIsReceivedQtyZero{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ReOrder == %@ && ReOrderCase == %@ && ReOrderPack == %@",@"0",@"0",@"0"];
    NSArray *notReceiveItem = [self.openOrderDetailData filteredArrayUsingPredicate:predicate];
    
    if(notReceiveItem.count>0){
        return YES;
    }
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"ReOrder == %@ && ReOrderCase == %@ && ReOrderPack == %@",@(0),@(0),@(0)];
    NSArray *notReceiveItem2 = [self.openOrderDetailData filteredArrayUsingPredicate:predicate1];
    
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
        [self callWCUpdatePurchaseOrder];
    }
}


-(void)callWCUpdatePurchaseOrder{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
    dictPODetail[@"PoDetailxml"] = [self PoDetailxml];
    dictPODetail[@"PoId"] = self.openOrderDict[@"PurchaseOrderId"];
    
    dictPODetail[@"PO_No"] = self.openOrderDict[@"PO_No"];
    dictPODetail[@"POTitle"] = self.openOrderDict[@"POTitle"];
    dictPODetail[@"OrderNo"] = @"";
    
    if([self.openOrderDict[@"FromDate"] length] == 0)
        [dictPODetail setValue:@"" forKey:@"FromDate"];
    else
        [dictPODetail setValue:self.openOrderDict[@"FromDate"] forKey:@"FromDate"];
    
    if([self.openOrderDict[@"ToDate"] length] == 0)
        [dictPODetail setValue:@"" forKey:@"ToDate"];
    else
        [dictPODetail setValue:self.openOrderDict[@"ToDate"] forKey:@"ToDate"];
    
    [dictPODetail setValue:self.openOrderDict[@"SupplierIds"] forKey:@"SupplierIds"];
    [dictPODetail setValue:self.openOrderDict[@"DeptIds"] forKey:@"DeptIds"];
    [dictPODetail setValue:self.openOrderDict[@"Tags"] forKey:@"Tags"];
    
    [dictPODetail setValue:self.openOrderDict[@"MinStock"] forKey:@"MinStock"];
    
    [dictPODetail setValue:self.openOrderDict[@"TimeDuration"] forKey:@"TimeDuration"];
    [dictPODetail setValue:@"Barcode,ITEM_Desc,SoldQty,AvailQty,ReOrder" forKey:@"ColumnsNames"];
    
    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictPODetail[@"UserId"] = userID;
    
    NSString *strDate = [self getStringFormate:self.openOrderDict[@"CreatedDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MM/dd/yyyy hh:mm a"];
    
    [dictPODetail setValue:strDate forKey:@"DateTime"];
    [Appsee addEvent:kPOUpdatePODetailWebServiceCall];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self openOrderUpdateResponse:response error:error];
        });
    };
    
    self.openOrderDetailWC = [self.openOrderDetailWC initWithRequest:KURL actionName:WSM_UPDATE_PO_DETAIL_NEW_IPHONE params:dictPODetail completionHandler:completionHandler];
}
- (void)openOrderUpdateResponse:(id)response error:(NSError *)error
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
                [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Order has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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
 
- (NSMutableArray *) PoDetailxmlforNewOrder
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.openOrderDetailData.count>0)
    {
        for (int isup=0; isup<self.openOrderDetailData.count; isup++)
        {
            NSMutableDictionary *tmpOdrDict=[(self.openOrderDetailData)[isup]mutableCopy];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"Sold" ] forKey:@"SoldQty"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"avaibleQty" ] forKey:@"AvailQty"];
            
            NSMutableDictionary *speDict = [tmpOdrDict mutableCopy];
            NSArray *removedKeys = @[@"AvailQty",@"ItemCode",@"ReOrder",@"SoldQty",@"ReOrderPack",@"ReOrderCase"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpOdrDict removeObjectsForKeys:speKeys];
            [itemSupplierData addObject:tmpOdrDict];
        }
    }
    return itemSupplierData;
}

-(IBAction)createOpenOrder:(id)sender{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
    dictPODetail[@"PoDetailxml"] = [self PoDetailxmlforNewOrder];
    dictPODetail[@"PurchaseOrderId"] = self.openOrderDict[@"PurchaseOrderId"];
    
    dictPODetail[@"PO_No"] = self.openOrderDict[@"PO_No"];
    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictPODetail[@"UserId"] = userID;
    
    [dictPODetail setValue:self.openOrderDict[@"SupplierIds"] forKey:@"SupplierIds"];
    [dictPODetail setValue:self.openOrderDict[@"DeptIds"] forKey:@"DeptIds"];
    
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    [dictPODetail setValue:strDateTime forKey:@"DateTime"];
    
    [Appsee addEvent:kPOInsertOpenPODetailWebServiceCall];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createOpenPODetailResponse:response error:error];
        });
    };
    
    self.createOpenOrderWC = [self.createOpenOrderWC initWithRequest:KURL actionName:WSM_INSERT_OPEN_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
}

- (void)createOpenPODetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self.pOOpenOrderDetailDelegate didCreateOpenOrder];
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
        
        if(self.openOrderDetailData.count>0)
        {
            for (int idata=0; idata<self.openOrderDetailData.count; idata++) {
                NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.openOrderDetailData)[idata]valueForKey:@"ItemId"]intValue]];
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
            
            [self.openOrderDetailData insertObject:dictTempGlobal atIndex:0];
            [self.tblOpenOrderDetail reloadData];
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
                
                [self.openOrderDetailData insertObject:dictTempGlobal atIndex:0];
                [self.tblOpenOrderDetail reloadData];
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
    //    NSArray *arrayKeys = [NSArray arrayWithObjects:@"avaibleQty",@"Barcode",@"CostPrice",@"Department",@"FreeGoodsQty",@"ITEM_Desc",@"ITEM_InStock",@"Image",@"ItemId",@"ProfitAmt",@"SalesPrice",@"ReOrder",@"Suppliers", nil];
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    
    if(self.openOrderDetailData.count>0)
    {
        for (int isup=0; isup<self.openOrderDetailData.count; isup++)
        {
            NSMutableDictionary *tmpOdrDict=(self.openOrderDetailData)[isup];
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


#pragma mark Open More Option

-(IBAction)openMoreOption:(id)sender{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"MORE" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.openOrderDetailData.count>0)
        {
            [self htmlBillText:self.openOrderDetailData];
            
            
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.openOrderDetailData.count>0)
        {
            [self htmlBillTextForPreview:self.openOrderDetailData];
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


// Modified by Hitendra
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
                                         pathForPDF:@"~/Documents/purchaseorderitem.pdf".stringByExpandingTildeInPath
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
