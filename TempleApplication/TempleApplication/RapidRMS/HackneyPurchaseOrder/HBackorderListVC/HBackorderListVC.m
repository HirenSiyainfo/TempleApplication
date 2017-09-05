//
//  HBackorderListVC.m
//  RapidRMS
//
//  Created by Siya on 16/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//


#import "HBackorderListVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "HBackorderCell.h"

@interface HBackorderListVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblbackorderList;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *backorderWSConnection;

@property (nonatomic, strong) NSMutableArray *arraybackorderList;

@end

@implementation HBackorderListVC
@synthesize purchaseOrder;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.backorderWSConnection =[[RapidWebServiceConnection alloc]init];
    [self getOpenBackListData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getOpenBackListData{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self getPurchaseOrderBackOrderItemsResponse:response error:error];
            });
    };
    
    self.backorderWSConnection = [self.backorderWSConnection initWithRequest:KURL actionName:WSM_GET_HACKNEY_BACK_ORDER_PO_ITEM params:itemparam completionHandler:completionHandler];

}

- (void)getPurchaseOrderBackOrderItemsResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                
                _arraybackorderList = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblbackorderList reloadData];
                
            }
            else if([[response  valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Generate Order" message:[response  valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arraybackorderList.count;
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
    NSString *cellIdentifier = @"HBackorderCell";
    
    HBackorderCell *backorderCell = (HBackorderCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    backorderCell.selectionStyle=UITableViewCellSelectionStyleNone;
    backorderCell.backgroundColor=[UIColor clearColor];
    
    backorderCell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    NSMutableDictionary *dictorderList = _arraybackorderList[indexPath.row];
    backorderCell.lblItemName.text =  [dictorderList valueForKey:@"ItemName"];
    //backorderCell.lblBarcode.text=[dictorderList valueForKey:@"Barcode"];

    if([dictorderList valueForKey:@"Checked"])
    {
        backorderCell.imgChecked.image = [UIImage imageNamed:@"soundCheckMark.png"];
    }
    else{
        
        [backorderCell.imgChecked setImage:nil];
    }
    return backorderCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSMutableDictionary *dictorderList = _arraybackorderList[indexPath.row];
    if([dictorderList valueForKey:@"Checked"])
    {
        [_arraybackorderList removeObject:@"Checked"];
    }
    else{
        
        dictorderList[@"Checked"] = @"1";
        _arraybackorderList[indexPath.row] = dictorderList;
    }
    [self.tblbackorderList reloadData];
}

-(IBAction)hideBackorder:(id)sender{
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"Checked = 1"];
    NSArray *array = [_arraybackorderList filteredArrayUsingPredicate:predicate];
    for(int i=0;i<_arraybackorderList.count;i++){
        
        NSMutableDictionary *dict = _arraybackorderList[i];
        if([dict valueForKey:@"Checked"]){
            [dict removeObjectForKey:@"Checked"];
        }
        dict[@"OldQty"] = @"0";
        _arraybackorderList[i] = dict;
    }
    purchaseOrder.arrayBackorderArray=_arraybackorderList;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
