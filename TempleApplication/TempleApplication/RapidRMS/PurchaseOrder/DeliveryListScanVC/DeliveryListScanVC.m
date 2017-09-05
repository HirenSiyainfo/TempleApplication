//
//  DeliveryListScanViewController.m
//  RapidRMS
//
//  Created by Siya on 26/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DeliveryListScanVC.h"
#import "RimPopOverVC.h"
#import "OpenListVC.h"
#import "RmsDbController.h"
#import "Item+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "ItemSupplier+Dictionary.h"
#import  "ItemDetailEditVC.h"
#import "POMultipleItemSelectionVC.h"
#import "PendingDeliveryCustomCell.h"

@interface DeliveryListScanVC ()<POMultipleItemSelectionVCDelegate,ItemInfoEditRedirectionVCDelegate,ItemInfoEditVCDelegate,POMultipleItemSelectionVCDelegate,UIPopoverPresentationControllerDelegate>
{
    POMultipleItemSelectionVC *itemMultipleVC;

    UIPopoverPresentationController *popOverController;
    RimPopOverVC * popoverController;
    
    UITextField *currentEditedTextField;
    UITextField *activeField;
}

@property (nonatomic, weak) IBOutlet UITableView *tblPendingScanData;
@property (nonatomic, weak) IBOutlet UITextField *txtMainBarcode;
@property (nonatomic, weak) IBOutlet UIButton *btnback;

@property (nonatomic, strong) RapidWebServiceConnection *deliveryListWC;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *deliveryListUpate;

@property (nonatomic, strong) NSMutableArray *arrayScanData;
@property (nonatomic, strong) NSIndexPath *clickedTextIndPath;
@property (nonatomic, strong) NSString *strNotificationName;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation DeliveryListScanVC

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
    
    self.arrayScanData=[[NSMutableArray alloc]init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.rimsController = [RimsController sharedrimController];
    self.deliveryListWC = [[RapidWebServiceConnection alloc] init];
    self.deliveryListUpate = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    //self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.txtMainBarcode.text=@"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblPendingScanData)
    {
        
        return self.arrayScanData.count;
    }
    return 1;
}
#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblPendingScanData){
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            return 134;
        }
        else
        {
            return 73;
        }
    }
    return 73;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if(tableView == self.tblPendingScanData) // pending delivery list
    {
        if(self.arrayScanData.count > 0)
        {
            static NSString *CellIdentifier = @"PendingDeliveryCustomCell";
            PendingDeliveryCustomCell *cell = (PendingDeliveryCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                NSArray *nib;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    nib = [[NSBundle mainBundle] loadNibNamed:@"PendingDeliveryCustomCell" owner:self options:nil];
                }
                else
                {
                    nib = [[NSBundle mainBundle] loadNibNamed:@"PendingDeliveryCustomCell_iPad" owner:self options:nil];
                }
                cell = nib.firstObject;
            }
        
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
           
            cell.viewOperation.frame=CGRectMake(984, cell.viewOperation.frame.origin.y, cell.viewOperation.frame.size.width, cell.viewOperation.frame.size.height);
            cell.viewOperation.hidden=YES;
            
    
            if([[(self.arrayScanData)[indexPath.row] valueForKey:@"Barcode"] isKindOfClass:[NSString class]])
            {
                if([[(self.arrayScanData)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@""] || [[(self.arrayScanData)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@"<null>"])
                {
                    cell.lblBarcode.text = @"";
                }
                else
                {
                    cell.lblBarcode.text = [NSString stringWithFormat:@"%@",[(self.arrayScanData)[indexPath.row] valueForKey:@"Barcode"]];
                }
            }
            else
            {
                cell.lblBarcode.text = @"";
            }
            
            
            NSString* strItemName = [[(self.arrayScanData)[indexPath.row] valueForKey:@"ItemName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            cell.lblItemName.text = strItemName;
            cell.lblQTY.text = [NSString stringWithFormat:@"%@",[(self.arrayScanData)[indexPath.row] valueForKey:@"avaibleQty"]];
            
            // Reorder
            cell.txtReOrder.text = [NSString stringWithFormat:@"%@",[(self.arrayScanData)[indexPath.row] valueForKey:@"ReOrder"]];
            cell.txtReOrder.delegate = self;
            //            cell.txtReOrder.tag = indexPath.row;
            cell.txtReOrder.keyboardType = UIKeyboardTypeNumberPad;
            
            // Cost
            //hiten
            NSNumber *scostPrice = @([[(self.arrayScanData)[indexPath.row] valueForKey:@"CostPrice"] floatValue ]);
            cell.txtCostPrice.text = [self.rmsDbController.currencyFormatter stringFromNumber:scostPrice];
            cell.txtCostPrice.text = [cell.txtCostPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            cell.txtCostPrice.delegate = self;
            // cell.txtCostPrice.tag = indexPath.row;
            cell.txtCostPrice.keyboardType = UIKeyboardTypeNumberPad;
            
            
            // cell.txtCostPrice.text = [NSString stringWithFormat:@"%.2f",[[[self.arrPendingDeliveryData objectAtIndex:indexPath.row] valueForKey:@"CostPrice"] floatValue ]];
            
            
            // Price
            //hiten
            NSNumber *sPrice = @([[(self.arrayScanData)[indexPath.row] valueForKey:@"SalesPrice"] floatValue]);
            cell.txtSalesPrice.text = [self.rmsDbController.currencyFormatter stringFromNumber:sPrice];
            cell.txtSalesPrice.text = [cell.txtSalesPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            cell.txtSalesPrice.delegate = self;
            //   cell.txtSalesPrice.tag = indexPath.row;
            cell.txtSalesPrice.keyboardType = UIKeyboardTypeNumberPad;
            cell.txtSalesPrice.enabled=NO;
            // cell.txtSalesPrice.text = [NSString stringWithFormat:@"%.2f",[[[self.arrPendingDeliveryData objectAtIndex:indexPath.row] valueForKey:@"SalesPrice"] floatValue] ];
            
            // Profit
            cell.txtProfit.text = [NSString stringWithFormat:@"%.2f%%",[[(self.arrayScanData)[indexPath.row] valueForKey:@"ProfitAmt"] floatValue ]];
            cell.txtProfit.delegate = self;
             cell.txtProfit.enabled=NO;
            //  cell.txtProfit.tag = indexPath.row;
            cell.txtProfit.keyboardType = UIKeyboardTypeNumberPad;
            cell.txtSalesPrice.enabled=NO;
            // Remark FreeGoodsQty
            cell.txtRemarks.text = [NSString stringWithFormat:@"%@",[(self.arrayScanData)[indexPath.row] valueForKey:@"FreeGoodsQty"]];
            cell.txtRemarks.delegate = self;
            cell.txtRemarks.enabled=NO;
            //    cell.txtRemarks.tag = indexPath.row;
            cell.txtRemarks.keyboardType = UIKeyboardTypeNumberPad;
            
            [cell.btnSelection setHidden:YES];

            return cell;
        }
    }
    return nil;
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if((textField == self.txtMainBarcode) && self.txtMainBarcode.text.length > 0)
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

-(void)barcodeSearchItem{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Barcode == %@", self.txtMainBarcode.text];
    NSArray *resultSet = [self.arrayScanData filteredArrayUsingPredicate:predicate];
   
    if(resultSet.count==0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Barcode == %@", self.txtMainBarcode.text];
        NSArray *resultSet = [self.arrayDeliveryItemList filteredArrayUsingPredicate:predicate];
        if(resultSet.count>0)
        {
            [self.arrayScanData addObject:resultSet.firstObject];
            [self.tblPendingScanData reloadData];
            self.txtMainBarcode.text=@"";
        }
        else
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemBarCode_Md" inManagedObjectContext:self.managedObjectContext];
            fetchRequest.entity = entity;
            NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barCode == %@ AND isBarcodeDeleted == 0", self.txtMainBarcode.text];
            fetchRequest.predicate = barcodePredicate;
            NSArray *resultSettemp = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
            
            NSMutableString *strSupp = [NSMutableString string];
            NSString *strsuppID=@"";
            if(resultSettemp.count > 0)
            {
                for (ItemBarCode_Md *anBarcode in resultSettemp)
                {
                    
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemSupplier" inManagedObjectContext:self.managedObjectContext];
                    fetchRequest.entity = entity;
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d",anBarcode.itemCode.stringValue];
                    fetchRequest.predicate = predicate;
                    NSArray *supllierListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
                    
                    for (int i=0; i<supllierListArray.count; i++)
                    {
                        ItemSupplier *supplier=supllierListArray[i];
                        
                        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
                        fetchRequest.entity = entity;
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId==%d",supplier.supId.integerValue];
                        fetchRequest.predicate = predicate;
                        NSArray *itemSizeName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
                        if (itemSizeName.count>0)
                        {
                            SupplierCompany *supplier=itemSizeName.firstObject;
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
                    
                    [self.tblPendingScanData reloadData];
                     self.txtMainBarcode.text=@"";
                }
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                });
               
                NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
                [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                [itemparam setValue:self.txtMainBarcode.text forKey:@"Code"];
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

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

-(NSString *)fetchDeptName:(NSString *)strID{
    
    //GET DEPARTMENT NAME
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%@",strID];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
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
                [self.deliveryListUpate updateObjectsFromResponseDictionary:responseDictionary];
                [self.deliveryListUpate linkItemToDepartmentFromResponseDictionary:responseDictionary];
                
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
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
                fetchRequest.entity = entity;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[dict[@"DeptId"] integerValue]];
                fetchRequest.predicate = predicate;
                NSArray *departmentList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
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
                
                self.txtMainBarcode.text=@"";
                
                [self.tblPendingScanData reloadData];
                
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
                        objInventoryAdd.strScanBarcode = self.txtMainBarcode.text;
                        [self.navigationController pushViewController:objInventoryAdd animated:YES];
                    }
                    else
                    {
                        self.rimsController.scannerButtonCalled = @"InvAdd";
                        //                    addNewSplitterVC = [[InventoryAddNewSplitterVC alloc] initWithNibName:@"InventoryAddNewSplitterVC-ipad" bundle:nil];
                        //                    addNewSplitterVC.searchedBarcode = self.txtMainBarcode.text;
                        //                    NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
                        //                    [navigationInfo setObject:@(TRUE) forKey:@"NewOrderCalled"];
                        //                    [navigationInfo setObject:self forKey:@"objDeliveryListScan"];
                        //                    addNewSplitterVC.navigationInfo = navigationInfo;
                        //                    addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        //                    [self presentViewController:addNewSplitterVC animated:YES completion:nil];

                        ItemDetailEditVC *addNewSplitterVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
                        addNewSplitterVC.selectedItemInfoDict = nil;
                        addNewSplitterVC.isItemCopy = FALSE;
                        addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        addNewSplitterVC.itemInfoEditRedirectionVCDelegate = self;
                        [self.objOpenList.pOmenuListVCDelegate willPresentViewController:addNewSplitterVC animated:YES completion:nil];
                    }
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No item found, are you sure you want to add item with new UPC?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                [self.txtMainBarcode resignFirstResponder];
            }
        }
    }
    
}
- (void)didUpdateItemInfo:(NSDictionary*)itemInfoData{
    
}
- (void)dismissInventoryAddNewSplitterVC{
    
}
- (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo; {

    NSMutableDictionary * dictInsertNewOrder =[newItemInfo mutableCopy];
    [dictInsertNewOrder removeObjectForKey:@"AddedQty"];
    dictInsertNewOrder[@"ReOrder"] = @"0";
    dictInsertNewOrder[@"FreeGoodsQty"] = @"0";
    dictInsertNewOrder[@"NewAdded"] = @"0";
    dictInsertNewOrder[@"Gvalue"] = @"Green";
    
    [self.arrayScanData insertObject:dictInsertNewOrder atIndex:0];
    [self.tblPendingScanData reloadData];

}
#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag == 2)
    {
        BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"You don't have rights to change item information. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return NO;
        }
    }

    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.tblPendingScanData];
    self.clickedTextIndPath = [self.tblPendingScanData indexPathForRowAtPoint:buttonPosition];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        
            currentEditedTextField = textField;
        
        
            if((currentEditedTextField.tag == 2) || (currentEditedTextField.tag == 3) ||
               (currentEditedTextField.tag == 4))
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangePricePopover:) name:@"openListPrice" object:nil];
                self.strNotificationName = @"openListPrice";
            }
            else
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangeQTYPopover:) name:@"ItemQTY" object:nil];
                self.strNotificationName = @"ItemQTY";
            }
    }
    else
    {
        if((textField != self.txtMainBarcode))
        {
            activeField = textField;
            [currentEditedTextField resignFirstResponder];
            [textField resignFirstResponder];
            
            currentEditedTextField = textField;
            popoverController = [[RimPopOverVC alloc] initWithNibName:@"RimPopOverVC" bundle:nil];
            
            // popover number pad view controller
            
            if((currentEditedTextField.tag == 2) || (currentEditedTextField.tag == 3) ||
               (currentEditedTextField.tag == 4))
            {
                UITextField *__weak weakcurrentEditedTextField = currentEditedTextField;
                __weak typeof(self) weakSelf = self;
                RimPopOverVC *__weak weakpopOverController = popoverController;


                popoverController.didEnterAmountBlock = ^(NSString * strPrice, NSDictionary * userInfo){
                    if(strPrice.length>0 && strPrice.integerValue != 0){

                        PendingDeliveryCustomCell *cell = (PendingDeliveryCustomCell *) weakcurrentEditedTextField.superview.superview;
                        
                        weakcurrentEditedTextField.text = [strPrice stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                        
                        if(weakcurrentEditedTextField.tag == 2) // cost Textfield
                        {
                            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
                            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            
                            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
                            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            if(tempSales.text.length > 0)
                            {
                                NSString *tmpProfitType = [(weakSelf.arrayScanData)[weakSelf.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                                
                                float dProfitAmt=0;
                                float dsellingAmt = tempSales.text.floatValue;
                                float dcostAmt = tempCost.text.floatValue;
                                
                                UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                                if(dcostAmt == 0.00)
                                {
                                    dProfitAmt = 100;
                                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                    NSMutableDictionary *dict = [(weakSelf.arrayScanData)[weakSelf.clickedTextIndPath.row]mutableCopy];
                                    dict[@"ProfitAmt"] = tempProfit.text;
                                    weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] = dict;
                                }
                                else
                                {
                                    if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                                    {
                                        dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
                                        tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                        tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                                    }
                                    else // Margin Profit
                                    {
                                        dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
                                        tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                        tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                                    }
                                    NSMutableDictionary *dict = [weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row]mutableCopy];
                                    NSString *strTempProfit = [tempProfit.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
                                    dict[@"ProfitAmt"] = strTempProfit;
                                    weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] = dict;
                                }
                            }
                            NSMutableDictionary *dict = [weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row]mutableCopy];
                            dict[@"CostPrice"] = tempCost.text;
                            
                            //hiten
                            NSNumber *sPrice = @(tempSales.text.floatValue);
                            tempSales.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sPrice];
                            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            NSNumber *sCost = @(tempCost.text.floatValue);
                            tempCost.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sCost];
                            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        else if(weakcurrentEditedTextField.tag == 3) // price Textfield
                        {
                            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
                            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
                            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            if(tempCost.text.length > 0)
                            {
                                NSString *tmpProfitType = [weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                                
                                float dProfitAmt = 0;
                                float dsellingAmt = tempSales.text.floatValue;
                                float dcostAmt = tempCost.text.floatValue;
                                UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                                if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                                {
                                    dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
                                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                    tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                                }
                                else // Margin Profit
                                {
                                    dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
                                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                    tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                                }
                                NSMutableDictionary *dict = weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row];
                                NSString *strTempProfit = [tempProfit.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
                                dict[@"ProfitAmt"] = strTempProfit;
                                weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] = dict;
                            }
                            NSMutableDictionary *dict = [weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row]mutableCopy];
                            dict[@"SalesPrice"] = tempSales.text;
                            
                            //hiten
                            NSNumber *sPrice = @(tempSales.text.floatValue);
                            tempSales.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sPrice];
                            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            NSNumber *sCost = @(tempCost.text.floatValue);
                            tempCost.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sCost];
                            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            //
                            weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        else if(weakcurrentEditedTextField.tag == 4) // Profit Textfield
                        {
                            UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                            tempProfit.text = [tempProfit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
                            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            
                            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
                            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            
                            if((![tempCost.text isEqualToString:@""]) && (![tempSales.text isEqualToString:@""]))
                            {
                                NSString *tmpProfitType = [weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                                float dcostAmt = tempCost.text.floatValue;
                                float dprofitper = tempProfit.text.floatValue;
                                float dsellingamt = 0;
                                
                                if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                                {
                                    if(dcostAmt>0 && dprofitper>0)
                                    {
                                        float dProfitAmt=0;
                                        dProfitAmt=(dprofitper * dcostAmt)/100;
                                        dsellingamt=dProfitAmt+dcostAmt;
                                        tempSales.text=[NSString stringWithFormat:@"%.2f",dsellingamt];
                                    }
                                }
                                else // Margin Profit
                                {
                                    dsellingamt= dcostAmt/((100-dprofitper)/100);
                                    tempSales.text=[NSString stringWithFormat:@"%.2f",dsellingamt];
                                }
                                NSMutableDictionary *dict = [weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row]mutableCopy];
                                dict[@"SalesPrice"] = tempSales.text;
                                weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] = dict;
                            }
                            NSMutableDictionary *dict = [weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row]mutableCopy];
                            NSString *strTempProfit = [tempProfit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            dict[@"ProfitAmt"] = strTempProfit;
                            
                            //hiten
                            NSNumber *sPrice = @(tempSales.text.floatValue);
                            tempSales.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sPrice];
                            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            NSNumber *sCost = @(tempCost.text.floatValue);
                            tempCost.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sCost];
                            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"%"];
                            NSRange range = [tempProfit.text rangeOfCharacterFromSet:cset];
                            if (range.location == NSNotFound) {
                                tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                            } else {
                                
                            }
                            weakSelf.arrayScanData[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                    }
                    else if ([strPrice isEqualToString:@""])
                    {
                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                        
                    }

                };
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangePricePopover:) name:@"openListPrice" object:nil];
//                popoverController.notificationName = @"openListPrice";
            }
            else
            {
                UITextField *__weak weakcurrentEditedTextField = currentEditedTextField;
                __weak typeof(self) weakSelf = self;
                RimPopOverVC *__weak weakpopOverController = popoverController;


                popoverController.didEnterAmountBlock = ^(NSString * strPrice, NSDictionary * userInfo){
                    if(strPrice.length>0 && strPrice.integerValue != 0){
                        weakcurrentEditedTextField.text = [strPrice stringByReplacingOccurrencesOfString:@"" withString:@""];
                        
                        if(currentEditedTextField.tag == 1) // ReOrder Textfield
                        {
                            NSMutableDictionary *dict = [(weakSelf.arrayScanData)[weakSelf.clickedTextIndPath.row]mutableCopy];
                            dict[@"ReOrder"] = weakcurrentEditedTextField.text;
                            (weakSelf.arrayScanData)[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        else if(currentEditedTextField.tag == 5) // Remark Textfield
                        {
                            NSMutableDictionary *dict = [(weakSelf.arrayScanData)[weakSelf.clickedTextIndPath.row]mutableCopy];
                            dict[@"FreeGoodsQty"] = weakcurrentEditedTextField.text;
                            (weakSelf.arrayScanData)[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                    }

                };
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangeQTYPopover:) name:@"ItemQTY" object:nil];
//                popoverController.notificationName = @"ItemQTY";
            }

            // Present the view controller using the popover style.
            popoverController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:popoverController animated:YES completion:nil];
            
            // Get the popover presentation controller and configure it.
            popOverController = [popoverController popoverPresentationController];
            popOverController.delegate = self;
            popoverController.preferredContentSize = CGSizeMake(324, 456);
            popOverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popOverController.sourceView = self.view;
            popOverController.sourceRect = [self.view convertRect:textField.frame fromView:textField.superview];
            return NO;
        }
    }
    return YES;
}

-(void)itemChangePricePopover:(NSNotification *)notification
{
    if (notification.object == nil)
    {
		[popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
	}
    else
    {
        PendingDeliveryCustomCell *cell = (PendingDeliveryCustomCell *) currentEditedTextField.superview.superview;
        
        currentEditedTextField.text = [notification.object stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        if(currentEditedTextField.tag == 2) // cost Textfield
        {
            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            
            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            if(tempSales.text.length > 0)
            {
                NSString *tmpProfitType = [(self.arrayScanData)[self.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                
                float dProfitAmt=0;
                float dsellingAmt = tempSales.text.floatValue;
                float dcostAmt = tempCost.text.floatValue;
                
                UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                if(dcostAmt == 0.00)
                {
                    dProfitAmt = 100;
                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                    NSMutableDictionary *dict = [(self.arrayScanData)[self.clickedTextIndPath.row]mutableCopy];
                    dict[@"ProfitAmt"] = tempProfit.text;
                    (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
                }
                else
                {
                    if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                    {
                        dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
                        tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                        tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                    }
                    else // Margin Profit
                    {
                        dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
                        tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                        tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                    }
                    NSMutableDictionary *dict = [(self.arrayScanData)[self.clickedTextIndPath.row]mutableCopy];
                    NSString *strTempProfit = [tempProfit.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
                    dict[@"ProfitAmt"] = strTempProfit;
                    (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
                }
            }
            NSMutableDictionary *dict = [(self.arrayScanData)[self.clickedTextIndPath.row]mutableCopy];
            dict[@"CostPrice"] = tempCost.text;
            
            //hiten
            NSNumber *sPrice = @(tempSales.text.floatValue);
            tempSales.text = [self.rmsDbController.currencyFormatter stringFromNumber:sPrice];
            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            NSNumber *sCost = @(tempCost.text.floatValue);
            tempCost.text = [self.rmsDbController.currencyFormatter stringFromNumber:sCost];
            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
        }
        else if(currentEditedTextField.tag == 3) // price Textfield
        {
            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            if(tempCost.text.length > 0)
            {
                NSString *tmpProfitType = [(self.arrayScanData)[self.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                
                float dProfitAmt = 0;
                float dsellingAmt = tempSales.text.floatValue;
                float dcostAmt = tempCost.text.floatValue;
                UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                {
                    dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                    tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                }
                else // Margin Profit
                {
                    dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                    tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                }
                NSMutableDictionary *dict = (self.arrayScanData)[self.clickedTextIndPath.row];
                NSString *strTempProfit = [tempProfit.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
                dict[@"ProfitAmt"] = strTempProfit;
                (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
            }
            NSMutableDictionary *dict = [(self.arrayScanData)[self.clickedTextIndPath.row]mutableCopy];
            dict[@"SalesPrice"] = tempSales.text;
            
            //hiten
            NSNumber *sPrice = @(tempSales.text.floatValue);
            tempSales.text = [self.rmsDbController.currencyFormatter stringFromNumber:sPrice];
            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            NSNumber *sCost = @(tempCost.text.floatValue);
            tempCost.text = [self.rmsDbController.currencyFormatter stringFromNumber:sCost];
            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            //
            (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
        }
        else if(currentEditedTextField.tag == 4) // Profit Textfield
        {
            UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
            tempProfit.text = [tempProfit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            
            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            
            if((![tempCost.text isEqualToString:@""]) && (![tempSales.text isEqualToString:@""]))
            {
                NSString *tmpProfitType = [(self.arrayScanData)[self.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                float dcostAmt = tempCost.text.floatValue;
                float dprofitper = tempProfit.text.floatValue;
                float dsellingamt = 0;
                
                if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                {
                    if(dcostAmt>0 && dprofitper>0)
                    {
                        float dProfitAmt=0;
                        dProfitAmt=(dprofitper * dcostAmt)/100;
                        dsellingamt=dProfitAmt+dcostAmt;
                        tempSales.text=[NSString stringWithFormat:@"%.2f",dsellingamt];
                    }
                }
                else // Margin Profit
                {
                    dsellingamt= dcostAmt/((100-dprofitper)/100);
                    tempSales.text=[NSString stringWithFormat:@"%.2f",dsellingamt];
                }
                NSMutableDictionary *dict = [(self.arrayScanData)[self.clickedTextIndPath.row]mutableCopy];
                dict[@"SalesPrice"] = tempSales.text;
                (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
            }
            NSMutableDictionary *dict = [(self.arrayScanData)[self.clickedTextIndPath.row]mutableCopy];
            NSString *strTempProfit = [tempProfit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            dict[@"ProfitAmt"] = strTempProfit;
            
            //hiten
            NSNumber *sPrice = @(tempSales.text.floatValue);
            tempSales.text = [self.rmsDbController.currencyFormatter stringFromNumber:sPrice];
            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            NSNumber *sCost = @(tempCost.text.floatValue);
            tempCost.text = [self.rmsDbController.currencyFormatter stringFromNumber:sCost];
            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"%"];
            NSRange range = [tempProfit.text rangeOfCharacterFromSet:cset];
            if (range.location == NSNotFound) {
                tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
            } else {
                
            }
            (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
        }
        [popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
	}
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openListPrice" object:nil];
}

-(void)itemChangeQTYPopover:(NSNotification *)notification
{
    if (notification.object == nil)
    {
        [popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
	}
    else
    {
        currentEditedTextField.text = [notification.object stringByReplacingOccurrencesOfString:@"" withString:@""];
        
        if(currentEditedTextField.tag == 1) // ReOrder Textfield
        {
            NSMutableDictionary *dict = [(self.arrayScanData)[self.clickedTextIndPath.row]mutableCopy];
            dict[@"ReOrder"] = currentEditedTextField.text;
            (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
        }
        else if(currentEditedTextField.tag == 5) // Remark Textfield
        {
            NSMutableDictionary *dict = [(self.arrayScanData)[self.clickedTextIndPath.row]mutableCopy];
            dict[@"FreeGoodsQty"] = currentEditedTextField.text;
            (self.arrayScanData)[self.clickedTextIndPath.row] = dict;
        }
        [popoverController dismissViewControllerAnimated:YES completion:nil];
        popOverController = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ItemQTY" object:nil];
}
-(IBAction)searchBarcode:(id)sender{
    
    if(self.txtMainBarcode.text.length>0)
    {
        [self barcodeSearchItem];
    }
}

-(void)insertDidFinish{
    
    
}
-(IBAction)cancelDeliveryScan:(id)sender{
    
    self.objOpenList.arrTempSelectedData=self.arrayScanData;
    
    for(int i=0;i<self.arrayScanData.count;i++){
        
        NSMutableDictionary *dict = [(self.arrayScanData)[i]mutableCopy];
        
         for(int j=0;j<self.objOpenList.arrPendingDeliveryData.count;j++){
             
             NSMutableDictionary *dict2 = [(self.objOpenList.arrPendingDeliveryData)[j]mutableCopy];

             if([[dict valueForKey:@"Barcode"] isEqualToString:[dict2 valueForKey:@"Barcode"]])
             {
                 
               if([[dict valueForKey:@"CostPrice"]integerValue] == [[dict2 valueForKey:@"CostPrice"]integerValue] && [[dict valueForKey:@"ReOrder"]integerValue] == [[dict2 valueForKey:@"ReOrder"]integerValue]){
                   
                   dict[@"Gvalue"] = @"Green";
                   (self.objOpenList.arrPendingDeliveryData)[j] = dict;
               }
               else{
                   dict[@"Rvalue"] = @"Red";
                   (self.objOpenList.arrPendingDeliveryData)[j] = dict;
               }
             }
             else{
                
                    if([dict valueForKey:@"NewAdded"])
                    {
                        [self.objOpenList.arrPendingDeliveryData insertObject:dict atIndex:0];
                        break;
                    
                    }
                     
             }
             
         }
    }
    
    
    
   /* NSMutableArray *result = [objOpenList.arrPendingDeliveryData mutableCopy];
    for (id object in self.arrayScanData)
    {
        [result removeObject:object];  // make sure you don't add it if it's already there.
        [result addObject:object];
    }
    
    objOpenList.arrPendingDeliveryData=result;*/

    [self.objOpenList.tblPendingDeliveryData reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)toolbarSearchClick:(id)sender{
    
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
        self.btnback.hidden=YES;
        itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionHeaderVC" bundle:nil];
        
        itemMultipleVC.checkSearchRecord = TRUE;
        itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
//        itemMultipleVC.view.frame=CGRectMake(0.0, 64.0, itemMultipleVC.view.frame.size.width, 704);
        [self presentViewController:itemMultipleVC animated:false completion:nil];
//        [self.view addSubview:itemMultipleVC.view];
    }

}

-(IBAction)toolbarAddItemClick:(id)sender{
    
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"You don't have rights to add new item. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
//        self.rimsController.scannerButtonCalled=@"InvAdd";
        ItemInfoEditVC *objInventoryAdd = [[ItemInfoEditVC alloc] initWithNibName:@"ItemInfoEditVC" bundle:nil];
        objInventoryAdd.isInvenManageCalled = TRUE;
        objInventoryAdd.NewOrderCalled=YES;
        objInventoryAdd.itemInfoEditVCDelegate=self;
        objInventoryAdd.strScanBarcode = self.txtMainBarcode.text;
        [self.navigationController pushViewController:objInventoryAdd animated:YES];
        
    }
    else
    {
        self.rimsController.scannerButtonCalled=@"InvAdd";
        
//        addNewSplitterVC = [[InventoryAddNewSplitterVC alloc] initWithNibName:@"InventoryAddNewSplitterVC-ipad" bundle:nil];
//        addNewSplitterVC.searchedBarcode = self.txtMainBarcode.text;
//        
//        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
//        [navigationInfo setObject:@(TRUE) forKey:@"NewOrderCalled"];
//        [navigationInfo setObject:self forKey:@"objDeliveryListScan"];
//        
//        addNewSplitterVC.navigationInfo=navigationInfo;
//        addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentViewController:addNewSplitterVC animated:YES completion:nil];
        ItemDetailEditVC *addNewSplitterVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        addNewSplitterVC.selectedItemInfoDict = nil;
        addNewSplitterVC.isItemCopy = FALSE;
        addNewSplitterVC.itemInfoEditRedirectionVCDelegate = self;
        addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.objOpenList.pOmenuListVCDelegate willPresentViewController:addNewSplitterVC animated:YES completion:nil];
        
    }
}

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
               NSArray *arrayTemp = [[self.objOpenList.arrPendingDeliveryData filteredArrayUsingPredicate:isselection]mutableCopy];
            if(arrayTemp.count==0)
            {
                dictSelected[@"NewAdded"] = @"0";
                dictSelected[@"Gvalue"] = @"Green";
            }
            [self.arrayScanData insertObject:dictSelected atIndex:0];

        }
    }
    self.btnback.hidden=NO;
    
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && itemMultipleVC.navigationController == nil) {
////            [itemMultipleVC.view removeFromSuperview];
//    }
    [self.tblPendingScanData reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
