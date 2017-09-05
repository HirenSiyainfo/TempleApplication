//
//  HOrderHistoryVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HOrderHistoryVC.h"
#import "HOrderHistoryCell.h"
#import "RmsDbController.h"
#import "VPurchaseOrder+Dictionary.h"
#import "HOrderHistroyItemVC.h"
#import "Vendor_Item+Dictionary.h"
#import "VPurchaseOrderItem+Dictionary.h"

@interface HOrderHistoryVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblOrderHistory;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) VPurchaseOrder *vendorPoSession;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection *poOrderHistroy;
@property (nonatomic, strong) RapidWebServiceConnection *poOrderHistroyItems;

@property (nonatomic, strong) NSMutableArray *arrayOrderHistory;
@property (nonatomic, strong) NSMutableArray *arrayOrderHistoryitems;

@property (nonatomic, strong) NSString *updateDate;
@property (nonatomic, strong) NSString *strPOID;

@property (nonatomic, strong) NSIndexPath *selectedPath;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HOrderHistoryVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];

    [self.updateManager deleteAllPurchaseOrdersItems:privateContextObject];
     [self callWebServiceForOrderHistory];;
    
}

// Duplicate - Available in UpdateManager
//-(void)deleteAllPurchaseOrders:(NSManagedObjectContext *)moc{
//    
//    NSArray *purchaseOrder=[self fetchAllPurchaseOrderDetails:moc];
//    for (NSManagedObject *podetail in purchaseOrder)
//    {
//        [UpdateManager deleteFromContext:moc object:podetail];
//    }
//    [UpdateManager saveContext:moc];
//}

// Duplicate - Available in UpdateManager
//-(void)deleteAllPurchaseOrdersItems:(NSManagedObjectContext *)moc{
//    
//    NSArray *purchaseOrderitem=[self fetchAllPOItems:moc];
//    for (NSManagedObject *poItem in purchaseOrderitem)
//    {
//        [UpdateManager deleteFromContext:moc object:poItem];
//    }
//    
//    [UpdateManager saveContext:moc];
//}

- (NSArray*)fetchAllPurchaseOrderDetails:(NSManagedObjectContext *)moc
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VPurchaseOrder" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}
- (NSArray*)fetchAllPOItems:(NSManagedObjectContext *)moc
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VPurchaseOrderItem" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    NSString  *historyCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        historyCell = @"HOrderHistoryCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:historyCell bundle:nil];
    [self.tblOrderHistory registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HOrderHistoryCell"];
    self.selectedPath = [NSIndexPath indexPathForRow:-1 inSection:-1];

    self.poOrderHistroy = [[RapidWebServiceConnection alloc]init];
    self.poOrderHistroyItems = [[RapidWebServiceConnection alloc]init];
   
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    // Do any additional setup after loading the view.
}

- (void)callWebServiceForOrderHistory
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    param[@"Status"] = @"3";
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self orderHistoryResponse:response error:error];
        });
    };
    
    self.poOrderHistroy = [self.poOrderHistroy initWithRequest:KURL actionName:WSM_LIST_HACKNEY_PO params:param completionHandler:completionHandler];
    
}

- (void)orderHistoryResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _arrayOrderHistory = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblOrderHistory reloadData];
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
-(void)selectedCell{
    
    if(self.selectedPath.row>=0){
        [self.tblOrderHistory selectRowAtIndexPath:self.selectedPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrayOrderHistory.count;
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
    NSString *cellIdentifier = @"HOrderHistoryCell";
    
    HOrderHistoryCell *orderhistoryCell = (HOrderHistoryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    orderhistoryCell.selectionStyle=UITableViewCellSelectionStyleGray;
    orderhistoryCell.backgroundColor=[UIColor clearColor];
    
    NSMutableDictionary *dicthistroy = (self.arrayOrderHistory)[indexPath.row];
    
    orderhistoryCell.lblOrderName.text= [dicthistroy valueForKey:@"OrderName"];
    orderhistoryCell.lblOrderItemcount.text =  [NSString stringWithFormat:@"%@ Items", [dicthistroy valueForKey:@"ItemCount"]];
    return orderhistoryCell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedPath = indexPath;
    NSMutableDictionary *dictP = (self.arrayOrderHistory)[indexPath.row];
    [self deletePurchaseOrderfromTable:[dictP valueForKey:@"POId"]];
    
    _strPOID = [NSString stringWithFormat:@"%@", [dictP valueForKey:@"POId"]];
    _vendorPoSession = [self.updateManager insertVendorPoDictionary:dictP];
    
    [self getOrderHistroyItem];
    
}
-(void)deletePurchaseOrderfromTable:(NSString *)poid{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    VPurchaseOrder *vendorPo = [self.updateManager fetchVendorPurchaseOrder:poid.integerValue withManageObjectContext:privateContextObject];
    if(vendorPo){
        
        [UpdateManager deleteFromContext:privateContextObject object:vendorPo];
        
        [UpdateManager saveContext:privateContextObject];
    }
}

- (void)getOrderHistroyItem
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
    
    self.poOrderHistroyItems = [self.poOrderHistroyItems initWithRequest:KURL actionName:WSM_GET_HACKNEY_PO_ITEM params:param completionHandler:completionHandler];
    
}
- (void)getPurchaseOpenOrderItemResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _arrayOrderHistoryitems = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self strorePurchaseOrderItemList:_arrayOrderHistoryitems];
            }
            else
            {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                HOrderHistroyItemVC *hopenHistroylist = [storyBoard instantiateViewControllerWithIdentifier:@"HOrderHistroyItemVC"];
                hopenHistroylist.strPoID=[NSString stringWithFormat:@"%@", _strPOID];
                hopenHistroylist.UpdateDate =self.updateDate;
                hopenHistroylist.vPurchaseOrder=_vendorPoSession;
                [self.navigationController pushViewController:hopenHistroylist animated:YES];
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
    HOrderHistroyItemVC *hopenHistroylist = [storyBoard instantiateViewControllerWithIdentifier:@"HOrderHistroyItemVC"];
    hopenHistroylist.strPoID=[NSString stringWithFormat:@"%@", _strPOID];
    hopenHistroylist.UpdateDate =self.updateDate;
    hopenHistroylist.vPurchaseOrder=_vendorPoSession;
    [self.navigationController pushViewController:hopenHistroylist animated:YES];
    
    
}

-(IBAction)gotoHome:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
