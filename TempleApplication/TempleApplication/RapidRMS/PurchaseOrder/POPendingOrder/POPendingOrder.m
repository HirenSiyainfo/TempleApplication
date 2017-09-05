//
//  POPendingOrder.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POPendingOrder.h"
#import "RmsDbController.h"
#import "RmsDashboardVC.h"
#import "POOrderListCell.h"
#import "POPendingOrderDetail.h"

@interface POPendingOrder ()<POPendingOrderDetailDelegate>
{
    NSIndexPath *deleteOrderIndPath;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *getPendingOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *deletePendingOrderWC;

@property(nonatomic,weak)IBOutlet UITableView *tblPendingList;
@property(nonatomic,strong)NSMutableArray *pendingOrderData;
@end

@implementation POPendingOrder

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getPendingOrderWC = [[RapidWebServiceConnection alloc]init];
    self.deletePendingOrderWC = [[RapidWebServiceConnection alloc]init];
    [self loadPendingOrderData];
    // Do any additional setup after loading the view.
}

-(void)loadPendingOrderData{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:@"0" forKey:@"PoId"];
    [itemparam setValue:@"0" forKey:@"OpenOrderId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getPendingOrderDataResponse:response error:error];
        });
    };
    
    self.getPendingOrderWC = [self.getPendingOrderWC initWithRequest:KURL actionName:WSM_GET_OPEN_PURCHASE_OREDR_DATA_NEW_IPHONE params:itemparam completionHandler:completionHandler];

}


- (void)getPendingOrderDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            // Barcode wise search result dat
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                self.pendingOrderData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblPendingList reloadData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No record found for close order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  70.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pendingOrderData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderListCell *poOrderListCell = (POOrderListCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderListCell"];
    poOrderListCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    poOrderListCell.poNumber.text = [NSString stringWithFormat:@"%@",[(self.pendingOrderData)[indexPath.row] valueForKey:@"OpenOrderNo"]];

    NSString  *datetimeUpdate = [NSString stringWithFormat:@"%@",[(self.pendingOrderData)[indexPath.row] valueForKey:@"CreatedDate"]];
    
    NSString *deliveryDate = [self getStringFormate:datetimeUpdate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy hh:mm a"];
    
    poOrderListCell.dateTime.text = deliveryDate;
    poOrderListCell.buttonAction.tag = indexPath.row;
    [poOrderListCell.buttonAction addTarget:self action:@selector(deliveryPoItemDetail:) forControlEvents:UIControlEventTouchUpInside];
    return poOrderListCell;
}

-(void)insertDeliveryPendingOrder{
    [self loadPendingOrderData];
}

-(void)deliveryPoItemDetail:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POPendingOrderDetail *poPendingDetail = [storyBoard instantiateViewControllerWithIdentifier:@"POPendingOrderDetail"];
    poPendingDetail.pendingOrderDict = [self.pendingOrderData objectAtIndex:[sender tag]];
    poPendingDetail.isDelivery = YES;
    poPendingDetail.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
    poPendingDetail.pOPendingOrderDetailDelegate = self;
    [self.navigationController pushViewController:poPendingDetail animated:YES];

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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POPendingOrderDetail *poPendingDetail = [storyBoard instantiateViewControllerWithIdentifier:@"POPendingOrderDetail"];
    poPendingDetail.pendingOrderDict = self.pendingOrderData[indexPath.row];
    poPendingDetail.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
    [self.navigationController pushViewController:poPendingDetail animated:YES];
    
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblPendingList)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            deleteOrderIndPath = [indexPath copy];
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [self.tblPendingList setEditing:NO];
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                
                NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
                [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                [itemparam setValue:[(self.pendingOrderData)[deleteOrderIndPath.row] valueForKey:@"PoId"] forKey:@"PoId"];
                
                [itemparam setValue:[(self.pendingOrderData)[deleteOrderIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
                
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self deletePendingOrderDataResponse:response error:error];
                    });
                };
                
                self.deletePendingOrderWC = [self.deletePendingOrderWC initWithRequest:KURL actionName:WSM_DELETE_OPEN_PO_NEW params:itemparam completionHandler:completionHandler];
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:@"Are you sure want to delete this order details?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
            
        }
    }
}
- (void)deletePendingOrderDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [self.pendingOrderData removeObjectAtIndex:deleteOrderIndPath.row];
                [self.tblPendingList reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:@"Open order details has been deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Pending Order" message:@"Error occur while deleting Order details, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(IBAction)logoutButton:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewCon in viewControllers) {
        if([viewCon isKindOfClass:[RmsDashboardVC class]]){
            [self.navigationController popToViewController:viewCon animated:YES];
        }
    }
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:NO];
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
