//
//  PODeliveryPendingDetail.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PODeliveryPendingDetail.h"
#import "RmsDbController.h"
#import "POOrderDetailCell.h"
#import "RimLoginVC.h"
#import "CameraScanVC.h"
#import "ItemDetailEditVC.h"
#import "ItemInfoEditVC.h"
#import "POItemReceiveDetail.h"
#import "PODeliveryListScan.h"
#import "EmailFromViewController.h"
#import "InventoryItemSelectionListVC.h"
#import "Item+Dictionary.h"

#import "ItemDetailEditVC.h"
#import "Department+Dictionary.h"
#import "SubDepartment+Dictionary.h"
#import "GroupMaster+Dictionary.h"
#import "GroupMaster.h"
#import "Mix_MatchDetail.h"


@interface PODeliveryPendingDetail ()<UpdateDelegate,CameraScanVCDelegate,ItemInfoEditVCDelegate,ItemInfoEditRedirectionVCDelegate,PODeliveryListScanDelegate,UIDocumentInteractionControllerDelegate,NDHTMLtoPDFDelegate,POItemReceiveDetailDelegate,InventoryItemSelectionListVCDelegate , EmailFromViewControllerDelegate>
{
    NSIndexPath *selectedItemIndPath;
    NSIndexPath *deleteOrderIndPath;
    NSMutableDictionary *dictItemOrderInfo;

}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *searchItemWC;
@property (nonatomic, strong) RapidWebServiceConnection *pendingOrderDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *updatePendingOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *saveclosePendingOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *moveItemToBackOrder;
@property (nonatomic, strong) RapidWebServiceConnection *deleteReceiveItem;

@property (nonatomic, strong) EmailFromViewController *emailFromViewController;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;
@property (nonatomic, strong) NSMutableArray *deliveryDetailData;
@property(nonatomic,weak)IBOutlet UITableView *tblDeliveryDetail;
@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) UpdateManager *updateManager;
@property(nonatomic,weak)IBOutlet UILabel *poNumber;
@property(nonatomic,weak)IBOutlet UITextField *universalSearch;
@property(nonatomic,strong)NSString *searchText;
@property (nonatomic, strong) NSIndexPath *indPath;

@property (nonatomic, strong) CameraScanVC *cameraScanVC;

@end

@implementation PODeliveryPendingDetail


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeObject];
        // Do any additional setup after loading the view.
}
-(void)initializeObject{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.pendingOrderDetailWC = [[RapidWebServiceConnection alloc]init];
    self.searchItemWC = [[RapidWebServiceConnection alloc]init];
    self.updatePendingOrderWC = [[RapidWebServiceConnection alloc]init];
    self.saveclosePendingOrderWC = [[RapidWebServiceConnection alloc]init];
    self.moveItemToBackOrder = [[RapidWebServiceConnection alloc]init];
    self.deleteReceiveItem = [[RapidWebServiceConnection alloc]init];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.manageObjectContext = self.rmsDbController.managedObjectContext;
    self.poNumber.text = self.deliveryOrderDict[@"PO_No"];
    [self getPendingOrderItemList];
     self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];

}
-(void)getPendingOrderItemList{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[self.deliveryOrderDict valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
    [itemparam setValue:@"Deliverd" forKey:@"DeliveryStatus"];
    [itemparam setValue:[self.deliveryOrderDict valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getDeliveryDetailDataResponse:response error:error];
        });
    };
    
    self.pendingOrderDetailWC = [self.pendingOrderDetailWC initWithRequest:KURL actionName:WSM_GET_PENDING_DELIVERY_DATA_NEW_IPHONE params:itemparam completionHandler:completionHandler];
}
- (void)getDeliveryDetailDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray *arrtempPoDataTempG = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            self.deliveryDetailData = [arrtempPoDataTempG.firstObject valueForKey:@"lstPendingItems"];
            [self.tblDeliveryDetail reloadData];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  150.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.deliveryDetailData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderDetailCell *poOrderDetailcell = (POOrderDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderDetailCell"];
    poOrderDetailcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *orderItemDict = self.deliveryDetailData[indexPath.row];

    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    if(anItem){
        [poOrderDetailcell configureItemDetail:orderItemDict withItem:anItem];
    }
    poOrderDetailcell.backgroundColor  = [UIColor whiteColor];
    poOrderDetailcell.buttonAction.selected = NO;
    if([(self.deliveryDetailData)[indexPath.row]valueForKey:@"Gvalue"]){
        
        //Light Green
        poOrderDetailcell.buttonAction.selected = YES;
        poOrderDetailcell.backgroundColor=[UIColor colorWithRed:149.0/225.0 green:223.0/255.0 blue:198.0/255.0 alpha:1.0];
    }
    else if([(self.deliveryDetailData)[indexPath.row]valueForKey:@"Rvalue"]){
        
        poOrderDetailcell.buttonAction.selected = YES;

        poOrderDetailcell.backgroundColor=[UIColor colorWithRed:228.0/225.0 green:171.0/255.0 blue:163.0/255.0 alpha:1.0];
    }
    
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didOpenOrderSwipeRight:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [poOrderDetailcell.contentView addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didOpenOrderSwipeLeft:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [poOrderDetailcell.contentView addGestureRecognizer:gestureLeft];
    
    if(indexPath.row==self.indPath.row)
    {
        poOrderDetailcell.viewOperation.frame=CGRectMake(0, poOrderDetailcell.viewOperation.frame.origin.y, poOrderDetailcell.viewOperation.frame.size.width, poOrderDetailcell.viewOperation.frame.size.height);
        poOrderDetailcell.viewOperation.hidden=NO;
    }
    else
    {
        poOrderDetailcell.viewOperation.frame=CGRectMake(320.0, poOrderDetailcell.viewOperation.frame.origin.y, poOrderDetailcell.viewOperation.frame.size.width, poOrderDetailcell.viewOperation.frame.size.height);
        poOrderDetailcell.viewOperation.hidden=YES;
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
    [self addMethodforOperationView:poOrderDetailcell withIndexPath:indexPath];
    poOrderDetailcell.buttonAction.tag = indexPath.row;
    [poOrderDetailcell.buttonAction addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];

    return poOrderDetailcell;
}

-(void)addMethodforOperationView:(POOrderDetailCell *)cell withIndexPath:(NSIndexPath *)indPath{
    
    cell.editItem.tag = indPath.row;
    cell.deleteItem.tag = indPath.row;
    cell.backOrder.tag = indPath.row;
    cell.btncopyItem.tag = indPath.row;
    
    [cell.editItem addTarget:self action:@selector(editItem:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btncopyItem addTarget:self action:@selector(copyItem:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteItem addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [cell.backOrder addTarget:self action:@selector(backOrderItem:) forControlEvents:UIControlEventTouchUpInside];

}
-(void)editItem:(id)sender{
    
    NSDictionary *orderItemDict = self.deliveryDetailData[[sender tag]];
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    [self launchItemDetailViewForIndexPath:anItem isItemCopy:NO];
}
-(void)copyItem:(id)sender{
    
    NSDictionary *orderItemDict = self.deliveryDetailData[[sender tag]];
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    [self launchItemDetailViewForIndexPath:anItem isItemCopy:YES];
}

-(void)deleteItem:(id)sender{
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
       
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        deleteOrderIndPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        [self deleteItemFromOrder];
    
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Are you sure want to delete this item in this order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)deleteItemFromOrder{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *dictPODetail = [[NSMutableDictionary alloc]init];
    
    [dictPODetail setValue:self.deliveryOrderDict[@"PurchaseOrderId"] forKey:@"PurchaseOrderId"];
    
    [dictPODetail setValue:self.deliveryDetailData[deleteOrderIndPath.row][@"receiveitemid"] forKey:@"PO_RecieveItemID"];
    
    [dictPODetail setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteReceiveItemResponse:response error:error];
        });
    };
    
    self.deleteReceiveItem = [self.deleteReceiveItem initWithRequest:KURL actionName:WSM_ADD_DELETE_RECEIVE_ITEM params:dictPODetail completionHandler:completionHandler];
    
}

- (void)deleteReceiveItemResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [self.deliveryDetailData removeObjectAtIndex:deleteOrderIndPath.row];
                self.indPath = [NSIndexPath indexPathForRow:-1 inSection:0];
                [self.tblDeliveryDetail reloadData];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Back to open moved." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Error occur while moving order details, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


-(void)backOrderItem:(id)sender{
    
    dictItemOrderInfo =(self.deliveryDetailData)[[sender tag]];
    
    NSIndexPath *indpath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    deleteOrderIndPath=indpath;
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {

    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self AddItembacktoOrder];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Are you sure you want back to order" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}


-(void)AddItembacktoOrder{
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strcurrentDateTime = [formatter stringFromDate:date];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *dictPODetail = [[NSMutableDictionary alloc]init];
    
    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    dictPODetail[@"ItemCode"] = [dictItemOrderInfo valueForKey:@"ItemId"];
    dictPODetail[@"AvailQty"] = [dictItemOrderInfo valueForKey:@"avaibleQty"];
    dictPODetail[@"ReOrder"] = [dictItemOrderInfo valueForKey:@"ReOrder"];
    dictPODetail[@"FreeGoodsQty"] = [dictItemOrderInfo valueForKey:@"FreeGoodsQty"];

    dictPODetail[@"ReOrderCase"] = [dictItemOrderInfo valueForKey:@"ReOrderCase"];
    dictPODetail[@"FreeGoodsQtyCase"] = [dictItemOrderInfo valueForKey:@"FreeGoodsQtyCase"];

    dictPODetail[@"ReOrderPack"] = [dictItemOrderInfo valueForKey:@"ReOrderPack"];
    dictPODetail[@"FreeGoodsQtyPack"] = [dictItemOrderInfo valueForKey:@"FreeGoodsQtyPack"];

    dictPODetail[@"LocalDateTime"] = strcurrentDateTime;
    
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictPODetail[@"UserId"] = userID;
    
    [dictPODetail setValue:[self.deliveryDetailData.firstObject valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
    
    [dictPODetail setValue:[self.deliveryDetailData.firstObject valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addBacktoOpenResultResponse:response error:error];
        });
    };
    
    self.moveItemToBackOrder = [self.moveItemToBackOrder initWithRequest:KURL actionName:WSM_ADD_PURCHASE_BACK_ORDER params:dictPODetail completionHandler:completionHandler];
}

- (void)addBacktoOpenResultResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [self.deliveryDetailData removeObjectAtIndex:deleteOrderIndPath.row];
                self.indPath = [NSIndexPath indexPathForRow:-1 inSection:0];
                [self.tblDeliveryDetail reloadData];
            
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Back to open moved." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Error occur while moving order details, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


- (void)launchItemDetailViewForIndexPath:(Item *)anItem isItemCopy:(BOOL)isItemCopy {
    
    [self.rmsDbController playButtonSound];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    if(anItem.itemSubDepartment.subDeptName) {
        dictItemClicked[@"SubDepartmentName"] = anItem.itemSubDepartment.subDeptName;
    }
    else {
        dictItemClicked[@"SubDepartmentName"] = @"";
    }
    //GET DEPARTMENT NAME
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.manageObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[dictItemClicked[@"DepartId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
    if (departmentList.count>0) {
        Department *department=departmentList.firstObject;
        dictItemClicked[@"DepartmentName"] = department.deptName;
    }
    else {
        dictItemClicked[@"DepartmentName"] = @"";
    }
    // GET GROUPNAME
    if([dictItemClicked[@"CateId"] integerValue] != 0)
    {
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"GroupMaster" inManagedObjectContext:self.manageObjectContext];
        fetchRequest.entity = entity;
        predicate = [NSPredicate predicateWithFormat:@"groupId==%d",[dictItemClicked[@"CateId"] integerValue]];
        fetchRequest.predicate = predicate;
        NSArray *groupList = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
        if (groupList.count > 0) {
            GroupMaster *groupMst=groupList.firstObject;
            dictItemClicked[@"GroupName"] = groupMst.groupName;
        }
        else {
            dictItemClicked[@"GroupName"] = @"";
        }
    }
    else {
        dictItemClicked[@"GroupName"] = @"";
    }
    // GET MixMatchName From ID
    if([dictItemClicked[@"mixMatchId"] integerValue] != 0)
    {
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"Mix_MatchDetail" inManagedObjectContext:self.manageObjectContext];
        fetchRequest.entity = entity;
        predicate = [NSPredicate predicateWithFormat:@"mixMatchId==%d",[dictItemClicked[@"mixMatchId"] integerValue]];
        fetchRequest.predicate = predicate;
        NSArray *groupList = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
        if (groupList.count > 0) {
            Mix_MatchDetail *groupMst = groupList.firstObject;
            dictItemClicked[@"mixMatchDiscription"] = groupMst.item_Description;
        }
        else {
            dictItemClicked[@"mixMatchDiscription"] = @"";
        }
    }
    else {
        dictItemClicked[@"mixMatchDiscription"] = @"";
    }
    // GET MixMatchName From GroupID
    if([dictItemClicked[@"cate_MixMatchId"] integerValue] != 0) {
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"Mix_MatchDetail" inManagedObjectContext:self.manageObjectContext];
        fetchRequest.entity = entity;
        predicate = [NSPredicate predicateWithFormat:@"mixMatchId==%d",[dictItemClicked[@"cate_MixMatchId"] integerValue]];
        fetchRequest.predicate = predicate;
        NSArray *groupList = [UpdateManager executeForContext:self.manageObjectContext FetchRequest:fetchRequest];
        if (groupList.count > 0) {
            Mix_MatchDetail *groupMst = groupList.firstObject;
            dictItemClicked[@"cate_MixMatchDiscription"] = groupMst.item_Description;
        }
        else {
            dictItemClicked[@"cate_MixMatchDiscription"] = @"";
        }
    }
    else
    {
        dictItemClicked[@"cate_MixMatchDiscription"] = @"";
    }
    [self itemDetailViewShow:dictItemClicked isItemCopy:isItemCopy];
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
        itemInfoEditVC.itemInfoEditVCDelegate = self;
        
        itemInfoEditVC.isWaitForLiveUpdate = true;
        [self.navigationController pushViewController:itemInfoEditVC animated:YES];
        [_activityIndicator hideActivityIndicator];
    }
    else {
        ItemDetailEditVC * itemDetailEditVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        itemDetailEditVC.selectedItemInfoDict = ItemInfo;
        itemDetailEditVC.isItemCopy = isItemCopy;
        itemDetailEditVC.itemInfoEditRedirectionVCDelegate = self;
        itemDetailEditVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:itemDetailEditVC animated:YES completion:^{
            [_activityIndicator hideActivityIndicator];
        }];
    }
}
-(void)showMessage:(NSString *)strMessage {
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

- (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo
{
    
}
-(void)didOpenOrderSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblDeliveryDetail];
    NSIndexPath *swipedIndexPath = [self.tblDeliveryDetail indexPathForRowAtPoint:location];
    self.indPath=swipedIndexPath;
    [self.tblDeliveryDetail reloadData];
}

-(void)didOpenOrderSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblDeliveryDetail];
    NSIndexPath *swipedIndexPath = [self.tblDeliveryDetail indexPathForRowAtPoint:location];
    if(self.indPath.row == swipedIndexPath.row)
    {
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        [self.tblDeliveryDetail reloadData];
    }
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
    poItemReceive.receiveItemDetail = self.deliveryDetailData[indexPath.row];
    poItemReceive.receivePoDetail = self.deliveryOrderDict;
    [poItemReceive.itemInfoDataObject setItemMainDataFrom:[ItemInfo mutableCopy]];
    poItemReceive.itemDetailDelegate =  self;
    poItemReceive.isDelivery = YES;
    poItemReceive.headeTitle = @"DELIVERY PENDING";
    [self.navigationController pushViewController:poItemReceive animated:YES];
    
}
-(void)didChangeItemDetail:(NSDictionary *)itemDetail{
    
    [self.deliveryDetailData replaceObjectAtIndex:selectedItemIndPath.row withObject:itemDetail];
    [self.tblDeliveryDetail reloadRowsAtIndexPaths:@[selectedItemIndPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tblDeliveryDetail reloadData];
}

-(void)selectItem:(id)sender{
    
    NSIndexPath *indpath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    NSMutableDictionary *orderItemDict = self.deliveryDetailData[indpath.row];
    if(orderItemDict[@"Gvalue"] || orderItemDict[@"Rvalue"]){
        [orderItemDict removeObjectForKey:@"Gvalue"];
        [orderItemDict removeObjectForKey:@"Rvalue"];
    }
    else{
        orderItemDict[@"Gvalue"] = @"Green";
    }
    [self.tblDeliveryDetail reloadData];
}




#pragma mark Delivery List Scan View
-(IBAction)deliveryListScan:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    PODeliveryListScan *poDeliveryLisScan = [storyBoard instantiateViewControllerWithIdentifier:@"PODeliveryListScan"];
    poDeliveryLisScan.deliveryDetailData = self.deliveryDetailData;
    poDeliveryLisScan.pODeliveryListScanDelegate = self;
    [self.navigationController pushViewController:poDeliveryLisScan animated:YES];
}

#pragma mark Delivery List Scan Delegate Method

-(void)didSelectScanItems:(NSMutableArray *)scannedItems{
    
    for (NSMutableDictionary *delItem in self.deliveryDetailData) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ItemId = %@",delItem[@"ItemId"]];
        NSArray *arrayCount = [scannedItems filteredArrayUsingPredicate:predicate];
        if(arrayCount.count>0){
            
            if([[delItem valueForKey:@"CostPrice"]integerValue] == [[arrayCount.firstObject valueForKey:@"CostPrice"]integerValue] && [[delItem valueForKey:@"ReOrder"]integerValue] == [[arrayCount.firstObject valueForKey:@"ReOrder"]integerValue]){
                
                delItem[@"Gvalue"] = @"Green";
            }
            else{
                delItem[@"Rvalue"] = @"Red";
            }
        }
    }
    
    for (NSMutableDictionary *scanItem in scannedItems) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ItemId = %@",scanItem[@"ItemId"]];
        NSArray *arrayCount = [self.deliveryDetailData filteredArrayUsingPredicate:predicate];
        if(arrayCount.count == 0){
            scanItem[@"Gvalue"] = @"Green";
            [self.deliveryDetailData insertObject:scanItem atIndex:0];
        }
    }
    
    [self.tblDeliveryDetail reloadData];
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

            
            [self.deliveryDetailData insertObject:dictSelected atIndex:0];
        }
    }
    [self.tblDeliveryDetail reloadData];
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

-(IBAction)addNewItem:(id)sender{
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"You don't have rights to add new item. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    [self itemDetailViewShow:nil isItemCopy:false];
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
        
        if(self.deliveryDetailData.count>0)
        {
            for (int idata=0; idata<self.deliveryDetailData.count; idata++) {
                NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.deliveryDetailData)[idata]valueForKey:@"ItemId"]intValue]];
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
            
            [self.deliveryDetailData insertObject:dictTempGlobal atIndex:0];
            [self.tblDeliveryDetail reloadData];
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
                
                [self.deliveryDetailData insertObject:dictTempGlobal atIndex:0];
                [self.tblDeliveryDetail reloadData];
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
    
    if(self.deliveryDetailData.count>0)
    {
        for (int isup=0; isup<self.deliveryDetailData.count; isup++)
        {
            NSMutableDictionary *tmpOdrDict=(self.deliveryDetailData)[isup];
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

-(BOOL)checkIsReceivedQtyZero{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ReOrder == %@ && ReOrderCase == %@ && ReOrderPack == %@",@"0",@"0",@"0"];
    NSArray *notReceiveItem = [self.deliveryDetailData filteredArrayUsingPredicate:predicate];
    
    if(notReceiveItem.count>0){
        return YES;
    }

    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"ReOrder == %@ && ReOrderCase == %@ && ReOrderPack == %@",@(0),@(0),@(0)];
    NSArray *notReceiveItem2 = [self.deliveryDetailData filteredArrayUsingPredicate:predicate1];
    
    if(notReceiveItem2.count>0){
        return YES;
    }
    
    return NO;
}

#pragma mark Save Order Click

-(IBAction)btnCloseOrderClick:(id)sender
{

    [self funSaveandClose];
}

-(void)didUpdateDeliveryList{
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.poDeliveryPendingDetailDelegate didUpdateDeliveryList];
    
}
#pragma mark Open More Option

-(IBAction)openMoreOption:(id)sender{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"MORE" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
            [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Save & Close" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
             [self funSaveandClose];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
           
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Are you sure want to update any changes in order ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];

            [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.deliveryDetailData.count>0)
        {
            [self htmlBillText:self.deliveryDetailData];
        }
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.deliveryDetailData.count>0)
        {
            [self htmlBillTextForPreview:self.deliveryDetailData];
        }
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"deliverypanding" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    _emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
  //  EmailFromViewController *objEmail = [[EmailFromViewController alloc]initWithNibName:@"EmailFromViewController" bundle:nil];

    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    NSString *strsubjectLine = @"";
  
    _emailFromViewController.emailFromViewControllerDelegate = self;
    _emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
    (_emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (_emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
    (_emailFromViewController.dictParameter)[@"postfile"] = myData;
    (_emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (_emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view addSubview:_emailFromViewController.view];
    });
}

-(void)didCancelEmail
{
    [_emailFromViewController.view removeFromSuperview];
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
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"Vendor List"]];
    
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


- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}

#pragma mark funSaveandClose

-(void)funSaveandClose{
    
    if([self checkIsReceivedQtyZero]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"ReOrder Qty not Zero" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    else{
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:self.deliveryOrderDict[@"PurchaseOrderId"] forKey:@"PoId"];
        
        [itemparam setValue:self.deliveryOrderDict[@"OpenOrderId"] forKey:@"OpenOrderId"];
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *strDateTime = [formatter stringFromDate:date];
        
        [itemparam setValue:strDateTime forKey:@"LocalDateTime"];
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self saveClosePendingOrderResponse:response error:error];
            });
        };
        
        self.saveclosePendingOrderWC = [self.saveclosePendingOrderWC initWithRequest:KURL actionName:WSM_UPDATE_STATUS_TO_CLOSE_PO_NEW params:itemparam completionHandler:completionHandler];
    }
   
}

#pragma mark funSaveandClose Response
- (void)saveClosePendingOrderResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self.poDeliveryPendingDetailDelegate didUpdateDeliveryList];
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Order has been closed successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}
- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.rmsDbController.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d AND active == %d", itemId.integerValue,TRUE];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.rmsDbController.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
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
