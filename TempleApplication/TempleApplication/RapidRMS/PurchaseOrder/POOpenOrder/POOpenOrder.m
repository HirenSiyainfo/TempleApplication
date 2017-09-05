//
//  POOpenOrder.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POOpenOrder.h"
#import "RmsDbController.h"
#import "RmsDashboardVC.h"
#import "POOrderListCell.h"
#import "POOpenOrderDetail.h"
#import "POFilterOption.h"

@interface POOpenOrder ()<PORapidItemFilterVCDeledate,POOpenOrderDetailDelegate>
{
    NSIndexPath *deleteOrderIndPath;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *getOpenOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteOpenOrderWC;

@property(nonatomic,weak) IBOutlet UITableView *tblOpenList;
@property(nonatomic,strong) NSMutableArray *openOrderData;

@end

@implementation POOpenOrder

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getOpenOrderWC = [[RapidWebServiceConnection alloc]init];
    self.deleteOpenOrderWC = [[RapidWebServiceConnection alloc]init];
    [self loadOpenOrderData];
}

-(void)didCreateOpenOrder{
     [self loadOpenOrderData];
}

-(void)loadOpenOrderData{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:@"0" forKey:@"PoId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getOpenOrderDataResponse:response error:error];
        });
    };
    
    self.getOpenOrderWC = [self.getOpenOrderWC initWithRequest:KURL actionName:WSM_GET_PURCHASE_ORDER_LISTING_DATA_IPHONE params:itemparam completionHandler:completionHandler];
}

- (void)getOpenOrderDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                self.openOrderData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblOpenList reloadData];
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
    return [self.openOrderData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderListCell *poOrderListCell = (POOrderListCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderListCell"];
    poOrderListCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    poOrderListCell.poNumber.text = [NSString stringWithFormat:@"%@",[(self.openOrderData)[indexPath.row] valueForKey:@"PO_No"]];
    
    poOrderListCell.invoiceNumber.text = [NSString stringWithFormat:@"%@",[(self.openOrderData)[indexPath.row] valueForKey:@"OpenOrderNo"]];
    
    NSString  *datetimeUpdate = [NSString stringWithFormat:@"%@",[(self.openOrderData)[indexPath.row] valueForKey:@"CreatedDate"]];
    
    NSString *deliveryDate = [self getStringFormate:datetimeUpdate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy hh:mm a"];
    
    poOrderListCell.dateTime.text = deliveryDate;
    return poOrderListCell;
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
    POOpenOrderDetail *poPendingDetail = [storyBoard instantiateViewControllerWithIdentifier:@"POOpenOrderDetail"];
    poPendingDetail.openOrderDict = self.openOrderData[indexPath.row];
    poPendingDetail.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
    poPendingDetail.pOOpenOrderDetailDelegate = self;
    [self.navigationController pushViewController:poPendingDetail animated:YES];
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblOpenList)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            deleteOrderIndPath = [indexPath copy];
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [self.tblOpenList setEditing:NO];
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                
                NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
                [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                [itemparam setValue:[(self.openOrderData)[deleteOrderIndPath.row] valueForKey:@"PoId"] forKey:@"PoId"];
                
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self delOpenPoDataResponse:response error:error];
                    });
                };
                
                self.deleteOpenOrderWC = [self.deleteOpenOrderWC initWithRequest:KURL actionName:WSM_DELETE_OPEN_PO params:itemparam completionHandler:completionHandler];
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Are you sure want to delete this order details?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        }
    }
}
- (void)delOpenPoDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [self.openOrderData removeObjectAtIndex:deleteOrderIndPath.row];
                [self.tblOpenList reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Open order details has been deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Error occur while deleting Order details, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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
