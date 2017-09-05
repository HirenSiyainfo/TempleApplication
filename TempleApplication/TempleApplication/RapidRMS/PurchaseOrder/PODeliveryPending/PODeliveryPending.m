//
//  PODeliveryPending.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PODeliveryPending.h"
#import "RmsDbController.h"
#import "RmsDashboardVC.h"
#import "POOrderListCell.h"
#import "PODeliveryPendingDetail.h"

@interface PODeliveryPending ()<PODeliveryPendingDetailDelegate>
{
     NSIndexPath *deliverIndPath;
     NSIndexPath *deleteOrderIndPath;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *getDeliveryOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteDeliveryOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *moveToCloseWC;

@property(nonatomic,weak)IBOutlet UITableView *tblDeliveryList;
@property(nonatomic,strong)NSMutableArray *deliveryOrderData;


@end

@implementation PODeliveryPending

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getDeliveryOrderWC = [[RapidWebServiceConnection alloc]init];
    self.moveToCloseWC  = [[RapidWebServiceConnection alloc]init];
    self.deleteDeliveryOrderWC = [[RapidWebServiceConnection alloc]init];
    [self loadDeliveryOrderData];
    // Do any additional setup after loading the view.
}
-(void)loadDeliveryOrderData{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getOpenDeliveryListResponse:response error:error];
        });
    };
    
    self.getDeliveryOrderWC = [self.getDeliveryOrderWC initWithRequest:KURL actionName:WSM_GET_DELIVERY_ORDER_DATA_NEW params:itemparam completionHandler:completionHandler];
    
}

- (void)getOpenDeliveryListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            // Barcode wise search result dat
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                self.deliveryOrderData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblDeliveryList reloadData];
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
    return [self.deliveryOrderData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderListCell *poOrderListCell = (POOrderListCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderListCell"];
    poOrderListCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    poOrderListCell.poNumber.text = [NSString stringWithFormat:@"%@",[(self.deliveryOrderData)[indexPath.row] valueForKey:@"OpenOrderNo"]];
    
    poOrderListCell.invoiceNumber.text = [NSString stringWithFormat:@"%@",[(self.deliveryOrderData)[indexPath.row] valueForKey:@"InvoiceNo"]];
    
    NSString  *datetimeUpdate = [NSString stringWithFormat:@"%@",[(self.deliveryOrderData)[indexPath.row] valueForKey:@"UpdatedDate"]];
    
    NSString *deliveryDate = [self getStringFormate:datetimeUpdate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy hh:mm a"];
    
    poOrderListCell.dateTime.text = deliveryDate;
    
    [poOrderListCell.buttonAction addTarget:self action:@selector(btnCloseDelivery:) forControlEvents:UIControlEventTouchUpInside];
    
    return poOrderListCell;
}


-(void)btnCloseDelivery:(id)sender
{
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
    
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:[(self.deliveryOrderData)[deliverIndPath.row] valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
        
        [itemparam setValue:[(self.deliveryOrderData)[deliverIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *strDateTime = [formatter stringFromDate:date];
        
        [itemparam setValue:strDateTime forKey:@"LocalDateTime"];
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doUpdateStatusToClosePOResponse:response error:error];
            });
        };
        
        self.moveToCloseWC = [self.moveToCloseWC initWithRequest:KURL actionName:WSM_UPDATE_STATUS_TO_CLOSE_PO_NEW params:itemparam completionHandler:completionHandler];
        
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Are you sure want to close order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblDeliveryList];
    deliverIndPath = [self.tblDeliveryList indexPathForRowAtPoint:buttonPosition];
}

- (void)doUpdateStatusToClosePOResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [self.deliveryOrderData removeObjectAtIndex:deliverIndPath.row];
                [self.tblDeliveryList reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Order" message:@"Order has been closed successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    PODeliveryPendingDetail *poDeliveryDetail = [storyBoard instantiateViewControllerWithIdentifier:@"PODeliveryPendingDetail"];
    poDeliveryDetail.deliveryOrderDict = self.deliveryOrderData[indexPath.row];
    poDeliveryDetail.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
    poDeliveryDetail.poDeliveryPendingDetailDelegate = self;
    [self.navigationController pushViewController:poDeliveryDetail animated:YES];
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        deleteOrderIndPath = [indexPath copy];
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self.tblDeliveryList setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            
            NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
            [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            [itemparam setValue:[(self.deliveryOrderData)[deleteOrderIndPath.row] valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
            
            [itemparam setValue:[(self.deliveryOrderData)[deleteOrderIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self deleteDeliveryPoDataResponse:response error:error];
                });
            };
            
            self.deleteDeliveryOrderWC = [self.deleteDeliveryOrderWC initWithRequest:KURL actionName:WSM_DELETE_OPEN_PO_NEW params:itemparam completionHandler:completionHandler];
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Are you sure want to delete this order details?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        
    }
}

- (void)deleteDeliveryPoDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [self.deliveryOrderData removeObjectAtIndex:deleteOrderIndPath.row];
                [self.tblDeliveryList reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Delivery pending details has been deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Delivery Pending" message:@"Error occur while deleting Order details, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


#pragma mark PODeliveryPendingDetail Delegate Method
-(void)didUpdateDeliveryList{
    
    [self.deliveryOrderData removeAllObjects];
    [self loadDeliveryOrderData];
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
