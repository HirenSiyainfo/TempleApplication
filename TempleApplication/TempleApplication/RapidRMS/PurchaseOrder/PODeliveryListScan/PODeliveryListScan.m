//
//  PODeliveryListScan.m
//  RapidRMS
//
//  Created by Siya10 on 21/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PODeliveryListScan.h"
#import "RmsDbController.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "ItemSupplier+Dictionary.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "ItemDetailEditVC.h"
#import "ItemInfoEditVC.h"
#import "POOrderDetailCell.h"
#import "RimLoginVC.h"
#import "POItemReceiveDetail.h"
#import "POMultipleItemSelectionVC.h"


@interface PODeliveryListScan ()<UpdateDelegate,ItemInfoEditRedirectionVCDelegate,POItemReceiveDetailDelegate,POMultipleItemSelectionVCDelegate,ItemInfoEditVCDelegate>
{
    NSIndexPath *selectedItemIndPath;
    POMultipleItemSelectionVC *itemMultipleVC;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *rimsController;

@property (nonatomic, strong) RapidWebServiceConnection *deliveryListWC;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;

@property (nonatomic, strong) NSMutableArray *arrayScanData;
@property (nonatomic,weak) IBOutlet UITableView *tbldeliveryScan;

@property(nonatomic,weak)IBOutlet UITextField *universalSearch;
@property(nonatomic,strong)NSString *searchText;
@end

@implementation PODeliveryListScan

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rimsController = [RimsController sharedrimController];
     self.rmsDbController = [RmsDbController sharedRmsDbController];
     self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.arrayScanData = [[NSMutableArray alloc]init];
    self.deliveryListWC = [[RapidWebServiceConnection alloc]init];
    self.manageObjectContext = self.rmsDbController.managedObjectContext;
}
#pragma mark Barcode Search Items

-(void)barcodeSearchItem{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Barcode == %@", self.universalSearch.text];
    NSArray *resultSet = [self.arrayScanData filteredArrayUsingPredicate:predicate];
    
    if(resultSet.count==0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Barcode == %@", self.universalSearch.text];
        NSArray *resultSet = [self.deliveryDetailData filteredArrayUsingPredicate:predicate];
        if(resultSet.count>0)
        {
            [self.arrayScanData addObject:resultSet.firstObject];
            [self.tbldeliveryScan reloadData];
            self.universalSearch.text=@"";
        }
        else
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemBarCode_Md" inManagedObjectContext:self.manageObjectContext];
            fetchRequest.entity = entity;
            NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barCode == %@ AND isBarcodeDeleted == 0", self.universalSearch.text];
            fetchRequest.predicate = barcodePredicate;
            NSArray *resultSettemp = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
            
            NSMutableString *strSupp = [NSMutableString string];
            NSString *strsuppID=@"";
            if(resultSettemp.count > 0)
            {
                for (ItemBarCode_Md *anBarcode in resultSettemp)
                {
                    
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemSupplier" inManagedObjectContext:self.manageObjectContext];
                    fetchRequest.entity = entity;
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d",anBarcode.itemCode.stringValue];
                    fetchRequest.predicate = predicate;
                    NSArray *supllierListArray = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
                    
                    for (int i=0; i<supllierListArray.count; i++)
                    {
                        ItemSupplier *supplier=supllierListArray[i];
                        
                        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.manageObjectContext];
                        fetchRequest.entity = entity;
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId==%d",supplier.supId.integerValue];
                        fetchRequest.predicate = predicate;
                        NSArray *itemSizeName = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
                        if (itemSizeName.count>0)
                        {
                            SupplierCompany *supplier = itemSizeName.firstObject;
                            [strSupp appendFormat:@"%@,", supplier.companyId];
                            
                            
                        }
                    }
                    if(strSupp.length>0)
                    {
                        strsuppID = [strSupp substringToIndex:strSupp.length-1];
                        
                    }
                    
                    Item *anItem = [self fetchAllItems:anBarcode.itemCode.stringValue];
                    NSMutableDictionary *dict = [[NSMutableDictionary dictionaryWithDictionary:anItem.itemRMSDictionary] mutableCopy ];
                    
                    if(strsuppID)
                    {
                        dict[@"Suppliers"] = strsuppID;
                    }
                    else{
                        dict[@"Suppliers"] = @"";
                    }
                    
                    
                    NSString *strDeptID = [self fetchDeptName:anItem.deptId.stringValue];
                    dict[@"Department"] = strDeptID;
                    dict[@"ReOrder"] = @"0";
                    dict[@"FreeGoodsQty"] = @"0";
                    dict[@"NewAdded"] = @"0";
                    dict[@"Gvalue"] = @"Green";
                    
                    [self.arrayScanData addObject:dict];
                    
                    [self.tbldeliveryScan reloadData];
                    self.universalSearch.text=@"";
                }
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                });
                
                NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
                [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                [itemparam setValue:self.universalSearch.text forKey:@"Code"];
                [itemparam setValue:@"Barcode" forKey:@"Type"];
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self responseDelivertyListResponse:response error:error];
                    });
                };
                
                self.deliveryListWC = [self.deliveryListWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
                
            }
        }
        
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Item already exist." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    
    
}

#pragma mark Search

-(IBAction)searchItemWithBarcode:(id)sender{
    
    if(self.universalSearch.text.length > 0)
    {
        [self barcodeSearchItem];
        self.universalSearch.text = @"";
    }
    
}

#pragma mark Item Search

-(IBAction)searchItem:(id)sender{
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionVC" bundle:nil];
        
        itemMultipleVC.checkSearchRecord = TRUE;
        itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
        itemMultipleVC.navigationController.navigationBar.hidden=NO;
        [self.navigationController pushViewController:itemMultipleVC animated:YES];
    }
    else
    {
        itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionHeaderVC" bundle:nil];
        
        itemMultipleVC.checkSearchRecord = TRUE;
        itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
        [self presentViewController:itemMultipleVC animated:false completion:nil];
    }

}
#pragma mark POMultipleItemSelection Delegate Method

-(void)didSelectionChangeInPOMultipleItemSelectionVC:(NSMutableArray *) selectedObject{
    for(int i=0;i<selectedObject.count;i++)
    {
        NSMutableDictionary *dictSelected = [selectedObject[i]mutableCopy];
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
            
            NSPredicate *isselection = [NSPredicate predicateWithFormat:@"Barcode == %@",[dictSelected valueForKey:@"Barcode"]];
            NSArray *arrayTemp = [[self.deliveryDetailData filteredArrayUsingPredicate:isselection]mutableCopy];
            if(arrayTemp.count==0)
            {
                dictSelected[@"NewAdded"] = @"0";
                dictSelected[@"Gvalue"] = @"Green";
            }
            [self.arrayScanData insertObject:dictSelected atIndex:0];
            
        }
    }
    [self.tbldeliveryScan reloadData];
}

#pragma mark New Item Add

-(IBAction)newItemAdd:(id)sender{
    
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Delivery Scan" message:@"You don't have rights to add new item. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    [self  itemDetailViewShow:nil isItemCopy:false];
}

-(void)showMessage:(NSString *)strMessage {
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

-(void)itemDetailViewShow:(NSMutableDictionary *)ItemInfo isItemCopy:(BOOL)isItemCopy {
    if (isItemCopy) {
        if (![[ItemInfo valueForKey:@"ITM_Type"] isEqualToString:@"0"]) {
            [self showMessage:@"You can't copy this item."];
            return;
        }
        ItemInfo[@"Barcode"] = @"";
        ItemInfo[@"avaibleQty"] = @"";
        ItemInfo[@"ItemNo"] = @"";
    }
    if (IsPhone()) {
        ItemInfoEditVC * itemInfoEditVC = (ItemInfoEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
        
        if (itemInfoEditVC.itemInfoDataObject==nil) {
            itemInfoEditVC.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
        [itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:[ItemInfo mutableCopy]];
        itemInfoEditVC.isCopy = isItemCopy;
        [self.navigationController pushViewController:itemInfoEditVC animated:YES];
        [_activityIndicator hideActivityIndicator];
    }
    else {
        ItemDetailEditVC * itemDetailEditVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        itemDetailEditVC.selectedItemInfoDict = ItemInfo;
        itemDetailEditVC.isItemCopy = isItemCopy;
        itemDetailEditVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:itemDetailEditVC animated:YES completion:^{
            [_activityIndicator hideActivityIndicator];
        }];
    }
}

-(NSString *)fetchDeptName:(NSString *)strID{
    
    //GET DEPARTMENT NAME
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.manageObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%@",strID];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
    if (departmentList.count>0)
    {
        Department *department=departmentList.firstObject;
        return  department.deptName;
        
    }
    else
    {
        return @"";
    }
    
}

-(void)responseDelivertyListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if(response!=nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            
            NSMutableArray *arraySupCode = [responseDictionary valueForKey:@"Item_SupplierArray"];
            
            NSMutableString *strSupp = [NSMutableString string];
            for(int i=0;i<arraySupCode.count;i++){
                
                NSMutableDictionary *dict = arraySupCode[i];
                NSString *ch = [dict valueForKey:@"SUPId"];
                [strSupp appendFormat:@"%@,", ch];
            }
            NSString *strsuppID;
            if(strSupp.length>0)
            {
                strsuppID = [strSupp substringToIndex:strSupp.length-1];
                
            }
            
            NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
            if(itemResponseArray.count > 0)
            {
                [self.updateManager updateObjectsFromResponseDictionary:responseDictionary];
                [self.updateManager linkItemToDepartmentFromResponseDictionary:responseDictionary];
                
                NSMutableDictionary *dict = [itemResponseArray.firstObject mutableCopy];
              
                [dict removeObjectForKey:@"Active"];
                [dict removeObjectForKey:@"BranchId"];
                [dict removeObjectForKey:@"CITM_Code"];
                
                [dict removeObjectForKey:@"CatId"];
                [dict removeObjectForKey:@"Cate_MixMatchFlg"];
                [dict removeObjectForKey:@"Cate_MixMatchId"];
                [dict removeObjectForKey:@"Child_Qty"];
                
                [dict removeObjectForKey:@"Description"];
                
                [dict removeObjectForKey:@"Dis_CalcItm"];
                [dict removeObjectForKey:@"EBT"];
                
                [dict removeObjectForKey:@"Dis_CalcItm"];
                [dict removeObjectForKey:@"EBT"];
                
                dict[@"avaibleQty"] = [dict valueForKey:@"ITEM_InStock"];
                [dict removeObjectForKey:@"ITEM_InStock"];
                
                dict[@"ItemId"] = [dict valueForKey:@"ITEMCode"];
                [dict removeObjectForKey:@"ITEMCode"];
                
                [dict removeObjectForKey:@"ITEM_Discount"];
                [dict removeObjectForKey:@"ITEM_MaxStockLevel"];
                [dict removeObjectForKey:@"ITEM_MinStockLevel"];
                
                [dict removeObjectForKey:@"ITEM_No"];
                [dict removeObjectForKey:@"ITEM_Remarks"];
                [dict removeObjectForKey:@"ITM_Type"];
                
                
                [dict removeObjectForKey:@"IsFavourite"];
                [dict removeObjectForKey:@"IsPriceAtPOS"];
                [dict removeObjectForKey:@"Is_ItemSupplier"];
                
                
                dict[@"Image"] = [dict valueForKey:@"Item_ImagePath"];
                [dict removeObjectForKey:@"Item_ImagePath"];
                
                
                [dict removeObjectForKey:@"MixMatchFlg"];
                [dict removeObjectForKey:@"MixMatchId"];
                
                
                [dict removeObjectForKey:@"NoDiscountFlg"];
                [dict removeObjectForKey:@"PERBOX_Qty"];
                [dict removeObjectForKey:@"POS_DISCOUNT"];
                
                
                [dict removeObjectForKey:@"Profit_Type"];
                [dict removeObjectForKey:@"Qty_Discount"];
                
                [dict removeObjectForKey:@"SizeId"];
                [dict removeObjectForKey:@"TaxApply"];
                [dict removeObjectForKey:@"TaxType"];
                
                [dict removeObjectForKey:@"isDeleted"];
                
                dict[@"ReOrder"] = @"0";
                dict[@"FreeGoodsQty"] = @"0";
                
                if (strsuppID) {
                    dict[@"Suppliers"] = strsuppID;
                }
                
                //GET DEPARTMENT NAME
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.manageObjectContext];
                fetchRequest.entity = entity;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[dict[@"DeptId"] integerValue]];
                fetchRequest.predicate = predicate;
                NSArray *departmentList = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
                if (departmentList.count>0)
                {
                    Department *department=departmentList.firstObject;
                    dict[@"Department"] = department.deptName;
                    
                }
                else
                {
                    dict[@"Department"] = @"";
                }
                [dict removeObjectForKey:@"DeptId"];
                dict[@"Margin"] = [dict valueForKey:@"Profit_Amt"];
                [dict removeObjectForKey:@"Profit_Amt"];
                
                dict[@"ItemName"] = [dict valueForKey:@"ITEM_Desc"];
                [dict removeObjectForKey:@"ITEM_Desc"];
                
                dict[@"NewAdded"] = @"0";
                dict[@"Gvalue"] = @"Green";
                
                [self.arrayScanData addObject:dict];
                
                self.universalSearch.text=@"";
                
                [self.tbldeliveryScan reloadData];
                
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        self.rimsController.scannerButtonCalled = @"InvAdd";
                        ItemInfoEditVC *objInventoryAdd = [[ItemInfoEditVC alloc] initWithNibName:@"ItemInfoEditVC" bundle:nil];
                        objInventoryAdd.isInvenManageCalled = TRUE;
                        objInventoryAdd.strScanBarcode = self.universalSearch.text;
                        [self.navigationController pushViewController:objInventoryAdd animated:YES];
                    }
                    else
                    {
//                        self.rimsController.scannerButtonCalled = @"InvAdd";
//                        ItemDetailEditVC *addNewSplitterVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
//                        addNewSplitterVC.selectedItemInfoDict = nil;
//                        addNewSplitterVC.isItemCopy = FALSE;
//                        addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//                        addNewSplitterVC.itemInfoEditRedirectionVCDelegate = self;
//                        [self.objOpenList.pOmenuListVCDelegate willPresentViewController:addNewSplitterVC animated:YES completion:nil];
                    }
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No item found, are you sure you want to add item with new UPC?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                [self.universalSearch resignFirstResponder];
            }
        }
    }
}

-(NSMutableDictionary *)createDictionaryFromBaseDictionary:(NSDictionary *)keysDictionary withAllItems:(NSMutableArray *)poItems {
    
    NSMutableDictionary *dictSub = [[NSMutableDictionary alloc]init];
    for (NSDictionary *itemdict in poItems) {
       
        NSArray *keys = keysDictionary.allKeys;
        for (NSString *key in keys) {
            dictSub[key] = itemdict[key];
        }
    }

    return dictSub;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  150.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayScanData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderDetailCell *poOrderDetailcell = (POOrderDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderDetailCell"];
    poOrderDetailcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *orderItemDict = self.arrayScanData[indexPath.row];
    
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    poOrderDetailcell.RqSingle.text = [NSString stringWithFormat:@"%@", orderItemDict[@"ReOrder"]];
    if(anItem){
        [poOrderDetailcell configureItemDetail:orderItemDict withItem:anItem];
    }
    if([orderItemDict[@"IsReturn"]boolValue]){
        
        int singleValue = [orderItemDict[@"ReOrder"] intValue];
        int packValue = [orderItemDict[@"ReOrderCase"] intValue];
        int caseValue = [orderItemDict[@"ReOrderPack"] intValue];
        
        int freesingleValue = [orderItemDict[@"FreeGoodsQty"] intValue];
        int freepackValue = [orderItemDict[@"FreeGoodsQtyCase"] intValue];
        int frecaseValue = [orderItemDict[@"FreeGoodsQtyPack"] intValue];
        
        int singleMain = singleValue + freesingleValue;
        int caseMain = packValue + freepackValue;
        int packMain = caseValue + frecaseValue;
        
        singleMain  = singleMain * -1;
        caseMain  = caseMain * -1;
        packMain  = packMain * -1;
        
        poOrderDetailcell.RqSingle.text = [NSString stringWithFormat:@"%d", singleValue];
        poOrderDetailcell.RqCashPack.text = [NSString stringWithFormat:@"%d/%d",caseValue,packValue];
    }
    else{
        
        int singleValue = [orderItemDict[@"ReOrder"] intValue];
        int packValue = [orderItemDict[@"ReOrderCase"] intValue];
        int caseValue = [orderItemDict[@"ReOrderPack"] intValue];
        
        int freesingleValue = [orderItemDict[@"FreeGoodsQty"] intValue];
        int freepackValue = [orderItemDict[@"FreeGoodsQtyCase"] intValue];
        int frecaseValue = [orderItemDict[@"FreeGoodsQtyPack"] intValue];
        
        int singleMain = singleValue + freesingleValue;
        int caseMain = packValue + freepackValue;
        int packMain = caseValue + frecaseValue;
        
        poOrderDetailcell.RqSingle.text = [NSString stringWithFormat:@"%d",singleMain];
        poOrderDetailcell.RqCashPack.text = [NSString stringWithFormat:@"%d/%d",caseMain,packMain];
    }

    return poOrderDetailcell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItemIndPath = indexPath;
     UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
     POItemReceiveDetail *poItemReceive = [storyBoard instantiateViewControllerWithIdentifier:@"POItemReceiveDetail"];
     NSDictionary *orderItemDict = self.deliveryDetailData[indexPath.row];
     Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
     NSMutableDictionary *ItemInfo = [anItem.itemRMSDictionary mutableCopy];
     if (poItemReceive.itemInfoDataObject == nil) {
     poItemReceive.itemInfoDataObject = [[ItemInfoDataObject alloc]init];
     }
     poItemReceive.receiveItemDetail = self.arrayScanData[indexPath.row];
     [poItemReceive.itemInfoDataObject setItemMainDataFrom:[ItemInfo mutableCopy]];
     poItemReceive.itemDetailDelegate =  self;
     [self.navigationController pushViewController:poItemReceive animated:YES];
    
}

-(void)didChangeItemDetail:(NSDictionary *)itemDetail{
    
    [self.arrayScanData replaceObjectAtIndex:selectedItemIndPath.row withObject:itemDetail];
    [self.tbldeliveryScan reloadRowsAtIndexPaths:@[selectedItemIndPath] withRowAnimation:UITableViewRowAnimationNone];
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
    [self.pODeliveryListScanDelegate didSelectScanItems:self.arrayScanData];
    [self.navigationController popViewControllerAnimated:YES];
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if((textField == self.universalSearch) && self.universalSearch.text.length > 0)
    {
        [self barcodeSearchItem];
        return YES;
    }
    else
    {
        [textField resignFirstResponder];
        return YES;
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
