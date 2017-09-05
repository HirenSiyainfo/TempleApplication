//
//  POBackOrderList.m
//  RapidRMS
//
//  Created by Siya10 on 16/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POBackOrderList.h"
#import "RmsDbController.h"
#import "POBackOrderCell.h"

@interface POBackOrderList ()

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *getBackOrderWC;

@property(nonatomic,strong)IBOutlet UITableView *tblBackOrder;
@property(nonatomic,strong)NSMutableArray *selectedOrders;
@property(nonatomic,strong)NSMutableArray *backOrderlist;
@end

@implementation POBackOrderList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getBackOrderWC = [[RapidWebServiceConnection alloc]init];
    self.selectedOrders = [[NSMutableArray alloc]init];
    [self getBackOrderData];
}
-(void)getBackOrderData{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getBackOrderDetailResponse:response error:error];
        });
    };
    
    self.getBackOrderWC = [self.getBackOrderWC initWithRequest:KURL actionName:WSM_GET_PURCHASE_BACK_ORDER_LIST_IPHONE params:itemparam completionHandler:completionHandler];
}

- (void)getBackOrderDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                self.backOrderlist = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblBackOrder reloadData];
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
    return  115;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.backOrderlist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POBackOrderCell *poBackOrderCell = (POBackOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"POBackOrderCell"];
    poBackOrderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    poBackOrderCell.itemName.text=[NSString stringWithFormat:@"%@",[(self.backOrderlist)[indexPath.row] valueForKey:@"ItemName"]];
    
    poBackOrderCell.barcode.text=[NSString stringWithFormat:@"%@",[(self.backOrderlist)[indexPath.row] valueForKey:@"Barcode"]];
    
    poBackOrderCell.soldQty.text=[NSString stringWithFormat:@"%@",[(self.backOrderlist)[indexPath.row] valueForKey:@"Sold"]];

    poBackOrderCell.availabeQty.text=[NSString stringWithFormat:@"%@",[(self.backOrderlist)[indexPath.row] valueForKey:@"AvailableQty"]];
    
    poBackOrderCell.singleQty.text=[NSString stringWithFormat:@"%@",[(self.backOrderlist)[indexPath.row] valueForKey:@"ReOrder"]];
    
    poBackOrderCell.caseQty.text=[NSString stringWithFormat:@"%@",[(self.backOrderlist)[indexPath.row] valueForKey:@"ReOrderCase"]];
    
    poBackOrderCell.packQty.text=[NSString stringWithFormat:@"%@",[(self.backOrderlist)[indexPath.row] valueForKey:@"ReOrderPack"]];
    
    [poBackOrderCell.imgSelection setImage:[UIImage imageNamed:@"po_check.png"]];

    if([self.selectedOrders containsObject:indexPath]){
        [poBackOrderCell.imgSelection setImage:[UIImage imageNamed:@"po_check_selected.png"]];
    }

    
    return poBackOrderCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedOrders containsObject:indexPath]){
        [self.selectedOrders removeObject:indexPath];
    }
    else{
         [self.selectedOrders addObject:indexPath];
    }
    [self.tblBackOrder reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
-(IBAction)saveSelectedItem:(id)sender{
    NSMutableArray *backOrderItem = [[NSMutableArray alloc]init];
    for (NSIndexPath *indPath in self.selectedOrders) {
        NSDictionary *dict = [self.backOrderlist objectAtIndex:indPath.row];
        if(dict){
            [backOrderItem addObject:dict];
        }
    }
    [self.bodelegate didSelectBackorderItems:backOrderItem];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)closeBackOrder:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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
