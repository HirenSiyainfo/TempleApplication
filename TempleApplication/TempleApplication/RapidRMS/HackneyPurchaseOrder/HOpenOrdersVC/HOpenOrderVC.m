//
//  HOpenOrderVC.m
//  RapidRMS
//
//  Created by Siya on 13/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HOpenOrderVC.h"
#import "RmsDbController.h"
#import "HReceiveOrderCell.h"
#import "VPurchaseOrderItem+Dictionary.h"
#import "VPurchaseOrder+Dictionary.h"
#import "HPOItemListVC.h"
#import "HPurchaseOrderVC.h"
#import "Vendor_Item+Dictionary.h"

@interface HOpenOrderVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblOpenOrder;

@property (nonatomic, weak) IBOutlet UIButton *createNew;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) VPurchaseOrder *vendorPoSession;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection *poOpenOrderList;
@property (nonatomic, strong) RapidWebServiceConnection *poOpenOrderListItems;
@property (nonatomic, strong) RapidWebServiceConnection *deletePoWebservice;

@property (nonatomic, strong) NSMutableArray *arrayOpenOrder;
@property (nonatomic, strong) NSMutableArray *arrayOpenOrderItems;

@property (nonatomic, strong) NSString *updateDate;
@property (nonatomic, strong) NSString *strPOID;

@property (nonatomic, strong) NSIndexPath *deleteOrderIndPath;
@property (nonatomic, strong) NSIndexPath *selectedPath;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HOpenOrderVC

@synthesize updateManager;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize deleteOrderIndPath,isselection;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    //[self.updateManager deleteAllPurchaseOrders:self.managedObjectContext];
    [self.updateManager deleteAllPurchaseOrdersItems:privateContextObject];
      [self callWebServiceForOpenOrder];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString  *itemListCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        itemListCell = @"HReceiveOrderCell_iPhone";
    }
    self.selectedPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    UINib *mixGenerateirderNib = [UINib nibWithNibName:itemListCell bundle:nil];
    [self.tblOpenOrder registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HReceiveOrderCell"];
    
    self.poOpenOrderList = [[RapidWebServiceConnection alloc]init];
    self.poOpenOrderListItems = [[RapidWebServiceConnection alloc]init];
    self.deletePoWebservice = [[RapidWebServiceConnection alloc]init];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
   if(!self.fromHome){
       self.createNew.hidden=NO;
   }
   else{
       self.createNew.hidden=YES;
   }
    // Do any additional setup after loading the view.
}

- (void)callWebServiceForOpenOrder
{
   _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    param[@"Status"] = @"1";
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self receiveOrderListResponse:response error:error];
        });
    };
    
    self.poOpenOrderList = [self.poOpenOrderList initWithRequest:KURL actionName:WSM_LIST_HACKNEY_PO params:param completionHandler:completionHandler];

}

- (void)receiveOrderListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _arrayOpenOrder = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblOpenOrder reloadData];
                [self selectedCell];
                
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _arrayOpenOrder.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 85.0;
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"HReceiveOrderCell";
    
    HReceiveOrderCell *receiveOrderCell = (HReceiveOrderCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    receiveOrderCell.selectionStyle=UITableViewCellSelectionStyleGray;
    receiveOrderCell.backgroundColor=[UIColor clearColor];

    NSMutableDictionary *dictReceorder = _arrayOpenOrder[indexPath.row];
    receiveOrderCell.lblOrderName.text= [dictReceorder valueForKey:@"OrderName"];
    receiveOrderCell.lblOrderItemcount.text =  [NSString stringWithFormat:@"%@ Items", [dictReceorder valueForKey:@"ItemCount"]];
    return receiveOrderCell;
    
}
-(void)selectedCell{
    
    if(self.selectedPath.row>=0){
        [self.tblOpenOrder selectRowAtIndexPath:self.selectedPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedPath = indexPath;
    NSMutableDictionary *dictP = _arrayOpenOrder[indexPath.row];
    [self deletePurchaseOrderfromTable:[dictP valueForKey:@"POId"]];
    
    _strPOID = [NSString stringWithFormat:@"%@", [dictP valueForKey:@"POId"]];
    _vendorPoSession = [self.updateManager insertVendorPoDictionary:dictP];

    [[NSUserDefaults standardUserDefaults]setObject:_strPOID forKey:@"PoId"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if(self.isselection){
     
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        
        self.updateDate = [NSString stringWithFormat:@"%@", [dictP valueForKey:@"UpdateDate"]];
     
        [self getHackneyOpenOrderItem];

    }
}


-(void)deletePurchaseOrderfromTable:(NSString *)poid{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    VPurchaseOrder *vendorPo = [self.updateManager fetchVendorPurchaseOrder:poid.integerValue withManageObjectContext:privateContextObject];
    if(vendorPo){
        
        [UpdateManager deleteFromContext:privateContextObject object:vendorPo];
        
        [UpdateManager saveContext:privateContextObject];
    }

}


- (void)getHackneyOpenOrderItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    param[@"POId"] = _strPOID;
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self getPurchaseOpenOrderItemResponse:response error:error];
        });
    };
    
    self.poOpenOrderListItems = [self.poOpenOrderListItems initWithRequest:KURL actionName:WSM_GET_HACKNEY_PO_ITEM params:param completionHandler:completionHandler];

    
}
- (void)getPurchaseOpenOrderItemResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                _arrayOpenOrderItems = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self strorePurchaseOrderItemList:_arrayOpenOrderItems];
                
            }
            else
            {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                HPOItemListVC *hpoitemlist = [storyBoard instantiateViewControllerWithIdentifier:@"HPOItemListVC"];
                hpoitemlist.strPoID=[NSString stringWithFormat:@"%@", _strPOID];
                hpoitemlist.UpdateDate =self.updateDate;
                hpoitemlist.vPurchaseOrder=_vendorPoSession;
                [self.navigationController pushViewController:hpoitemlist animated:YES];
            }
        }
    }
}

-(void)strorePurchaseOrderItemList:(NSMutableArray *)arrayTemp{
    
    for(int i=0;i<arrayTemp.count;i++){
        
        NSMutableDictionary *dictTemp = arrayTemp[i];
        
        NSString *itemCode = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"ItemCode"]];
        
        Vendor_Item *vanItem =  [self.updateManager fetchVendorItem:itemCode.integerValue manageObjectContext:self.managedObjectContext];
        
        VPurchaseOrderItem *vmanualItem;
        
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        [self.updateManager updatePurchaseOrderItemListwithDetail:dictTemp withVendorItem:(Vendor_Item *)OBJECT_COPY(vanItem, privateContextObject) withpurchaseOrderItem:(VPurchaseOrderItem *)OBJECT_COPY(vmanualItem, privateContextObject) withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(_vendorPoSession, privateContextObject) withManageObjectContext:privateContextObject];
        vmanualItem=nil;
        _vendorPoSession = (VPurchaseOrder *)OBJECT_COPY(_vendorPoSession, self.managedObjectContext);
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HPOItemListVC *hpoitemlist = [storyBoard instantiateViewControllerWithIdentifier:@"HPOItemListVC"];
    hpoitemlist.strPoID=[NSString stringWithFormat:@"%@", _strPOID];
    hpoitemlist.UpdateDate =self.updateDate;
    hpoitemlist.vPurchaseOrder=_vendorPoSession;
    [self.navigationController pushViewController:hpoitemlist animated:YES];
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES; // Return YES, if enable delete on swipe.
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        deleteOrderIndPath = [indexPath copy];
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self deletePurchaseOrderItem:deleteOrderIndPath];
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Are you sure want to delete this po?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        
    }
}

-(void)deletePurchaseOrderItem:(NSIndexPath *)indPath{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *dictP = _arrayOpenOrder[indPath.row];
    _strPOID = [NSString stringWithFormat:@"%@", [dictP valueForKey:@"POId"]];
    
    NSMutableDictionary *poparam=[[NSMutableDictionary alloc]init];
    [poparam setValue:_strPOID forKey:@"POId"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self deleteOpenPurchaseOrderResponse:response error:error];
        });
    };
    
    self.deletePoWebservice = [self.deletePoWebservice initWithRequest:KURL actionName:WSM_DELETE_HACKNEY_PO params:poparam completionHandler:completionHandler];
    
}

- (void)deleteOpenPurchaseOrderResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]]) {

            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                     NSString *strPO = [[NSUserDefaults standardUserDefaults]valueForKey:@"PoId"];
                    
                    if([strPO isEqualToString:_strPOID]){
        
                        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"PoId"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    [self deletePurchaseOrderfromTable:_strPOID];
                     [self callWebServiceForOpenOrder];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Purchase order deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Error occur while deleting purchase order, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


-(IBAction)openPurchaseOrderScreen:(id)sender{
    
    if(!self.fromHome){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        HPurchaseOrderVC *hpurchase = [storyBoard instantiateViewControllerWithIdentifier:@"HPurchaseOrderVC"];
        hpurchase.fromHome = NO;
        [self.navigationController pushViewController:hpurchase animated:YES];

    }
}

-(IBAction)gotoHome:(id)sender{
    self.tblOpenOrder.editing = NO;
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
