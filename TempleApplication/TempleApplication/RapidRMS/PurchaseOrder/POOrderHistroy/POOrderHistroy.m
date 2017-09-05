//
//  POOrderHistroy.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POOrderHistroy.h"
#import "RmsDashboardVC.h"
#import "POCloseOrderCell.h"
#import "POHistroyDetail.h"
#import "RmsDbController.h"

@interface POOrderHistroy ()


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *getCloseOrderDetailWC;

@property(nonatomic,weak)IBOutlet UITableView *tblOrderHistroy;
@property(nonatomic,strong)NSMutableArray *closeOrderData;

@end

@implementation POOrderHistroy

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getCloseOrderDetailWC = [[RapidWebServiceConnection alloc]init];
    [self loadCloseOrderData];
    // Do any additional setup after loading the view.
}

-(void)loadCloseOrderData{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getClosePOListResponse:response error:error];
        });
    };
    
    self.getCloseOrderDetailWC = [self.getCloseOrderDetailWC initWithRequest:KURL actionName:WSM_GET_CLOSE_ORDER_DETAIL_NEW params:itemparam completionHandler:completionHandler];
}


- (void)getClosePOListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            // Barcode wise search result dat
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                self.closeOrderData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblOrderHistroy reloadData];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  105.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.closeOrderData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POCloseOrderCell *poCloseOrderCell = (POCloseOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"POCloseOrderCell"];
    poCloseOrderCell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIView * viewBG = [[UIView alloc]init];
    viewBG.backgroundColor = [UIColor colorWithRed:238.0 green:238.0 blue:238.0 alpha:1.0];
    poCloseOrderCell.selectedBackgroundView = viewBG;
    
    poCloseOrderCell.poNo.text = [NSString stringWithFormat:@"%@",[(self.closeOrderData)[indexPath.row] valueForKey:@"OpenOrderNo"]];
    poCloseOrderCell.invoiceNo.text = [NSString stringWithFormat:@"%@",[(self.closeOrderData)[indexPath.row] valueForKey:@"InvoiceNo"]];
    
    NSString  *deliveryDate = [NSString stringWithFormat:@"%@",[(self.closeOrderData)[indexPath.row] valueForKey:@"CreatedDate"]];
    
    NSString *deliveryDateformated = [self getStringFormate:deliveryDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy hh:mm a"];
    
    poCloseOrderCell.deliveryDate.text = deliveryDateformated;
    
    NSString  *closeDate = [NSString stringWithFormat:@"%@",[(self.closeOrderData)[indexPath.row] valueForKey:@"UpdatedDate"]];
    
    NSString *closeDateFromate = [self getStringFormate:closeDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy hh:mm a"];
    
    poCloseOrderCell.closeDate.text = closeDateFromate;

    return poCloseOrderCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POHistroyDetail *histroyDetail = [storyBoard instantiateViewControllerWithIdentifier:@"POHistroyDetail"];
    histroyDetail.closeOrderDict = self.closeOrderData[indexPath.row];
    [self.navigationController pushViewController:histroyDetail animated:YES];
    
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
