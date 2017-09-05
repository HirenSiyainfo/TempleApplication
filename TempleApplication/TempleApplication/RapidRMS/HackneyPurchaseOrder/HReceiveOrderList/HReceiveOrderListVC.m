//
//  HReceiveOrderListVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HReceiveOrderListVC.h"
#import "HReceiveOrderCell.h"
#import "HReceiveOrderItemListVC.h"
#import "RmsDbController.h"
#import "VPurchaseOrderItem+Dictionary.h"
#import "VPurchaseOrder+Dictionary.h"
#import "Vendor_Item+Dictionary.h"

@interface HReceiveOrderListVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblReceiveOrder;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) VPurchaseOrder *vendorPoSession;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection *poReceiveOrderList;

@property (nonatomic, strong) NSMutableArray *arrayReceiveOrder;
@property (nonatomic, strong) NSMutableArray *arrayReceiveOrderItems;

@property (nonatomic, strong) NSString *strPOID;
@property (nonatomic, strong) NSIndexPath *selectedPath;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HReceiveOrderListVC
@synthesize updateManager;
@synthesize managedObjectContext = __managedObjectContext;

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
    [self.updateManager deleteAllPurchaseOrders:privateContextObject];
    [self.updateManager deleteAllPurchaseOrdersItems:privateContextObject];
     [self callWebServiceForReceiveOrder];
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
    [self.tblReceiveOrder registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HReceiveOrderCell"];
    
    self.poReceiveOrderList = [[RapidWebServiceConnection alloc]init];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
   
    // Do any additional setup after loading the view.
}



- (void)callWebServiceForReceiveOrder
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    param[@"Status"] = @"2";
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self receiveOrderListResponse:response error:error];
        });
    };
    
    self.poReceiveOrderList = [self.poReceiveOrderList initWithRequest:KURL actionName:WSM_LIST_HACKNEY_PO params:param completionHandler:completionHandler];
}

- (void)receiveOrderListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]){
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _arrayReceiveOrder = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblReceiveOrder reloadData];
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
        [self.tblReceiveOrder selectRowAtIndexPath:self.selectedPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrayReceiveOrder.count;
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
    
    NSMutableDictionary *dictReceorder = (self.arrayReceiveOrder)[indexPath.row];
    receiveOrderCell.lblOrderName.text= [dictReceorder valueForKey:@"OrderName"];
    receiveOrderCell.lblOrderItemcount.text =  [NSString stringWithFormat:@"%@ Items", [dictReceorder valueForKey:@"ItemCount"]];
    return receiveOrderCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     self.selectedPath = indexPath;
    NSMutableDictionary *dictP = (self.arrayReceiveOrder)[indexPath.row];
    _strPOID = [NSString stringWithFormat:@"%@", [dictP valueForKey:@"POId"]];
    _vendorPoSession = [self.updateManager insertVendorPoDictionary:dictP];
    [self getHackneyPOItem];
}


- (void)getHackneyPOItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    param[@"POId"] = _strPOID;
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self getPurchaseOrderItemResponse:response error:error];
        });
    };
    
    self.poReceiveOrderList = [self.poReceiveOrderList initWithRequest:KURL actionName:WSM_GET_HACKNEY_PO_ITEM params:param completionHandler:completionHandler];
    
}

- (void)getPurchaseOrderItemResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                _arrayReceiveOrderItems = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self strorePurchaseOrderItemList:_arrayReceiveOrderItems];
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

-(void)strorePurchaseOrderItemList:(NSMutableArray *)arrayTemp{
    
    for(int i=0;i<arrayTemp.count;i++){
        
        NSMutableDictionary *dictTemp = arrayTemp[i];
        
        NSString *itemCode = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"ItemCode"]];
        Vendor_Item *vanItem = [self fetchVendorItem:itemCode.integerValue];
        
        VPurchaseOrderItem *vmanualItem=nil;

        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        [self.updateManager updatePurchaseOrderItemListwithDetail:dictTemp withVendorItem:(Vendor_Item *)OBJECT_COPY(vanItem, privateContextObject) withpurchaseOrderItem:(VPurchaseOrderItem *)OBJECT_COPY(vmanualItem, privateContextObject) withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(_vendorPoSession, privateContextObject) withManageObjectContext:privateContextObject];
        
        _vendorPoSession = (VPurchaseOrder *)OBJECT_COPY(_vendorPoSession, self.managedObjectContext);
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HReceiveOrderItemListVC *hreceiveItemList = [storyBoard instantiateViewControllerWithIdentifier:@"HReceiveOrderItemListVC"];
    hreceiveItemList.strPoid=_strPOID;
    [self.navigationController pushViewController:hreceiveItemList animated:YES];
    

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
