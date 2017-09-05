//
//  ItemInfoViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 08/01/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemInfoCustomCell.h"
#import "ItemTotalAverageInfoVC.h"
#import "RmsDbController.h"
#import "UITableView+AddBorder.h"


@interface ItemTotalAverageInfoVC ()
{
    NSInteger totalProduct;
    double totalQTYeach;
    double totalCostPrice;
    double totalSalesPrice;
    
    double averageCost;
    double averagePrice;
    double totalMargin;
    double totalMarkup;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *_rimController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, weak) IBOutlet UITableView *tblItemInfoData;

@property (nonatomic, strong) RapidWebServiceConnection * itemUpdateWebServiceConnection;

@end

@implementation ItemTotalAverageInfoVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self._rimController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemUpdateWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    
    [self getItemToaleAverageInformation];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self._rimController.objSideMenuiPad.btnSlidingMenu.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self._rimController.objSideMenuiPad.btnSlidingMenu.hidden = NO;
}
- (void)getItemToaleAverageInformation {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.navigationController.view.superview];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responceOfItemInformationResponse:response error:error];
        });
    };
    
    self.itemUpdateWebServiceConnection = [self.itemUpdateWebServiceConnection initWithRequest:KURL actionName:WSM_ITEM_TOTAL_INFO_IOS params:param completionHandler:completionHandler];

}
-(void)responceOfItemInformationResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0) {
                
                NSArray * arr =[self.rmsDbController objectFromJsonString:[response  valueForKey:@"Data"]];
                NSDictionary * itemTotalInfo = arr.firstObject;
                NSDictionary *imageResponseDict = @{kRIMItemImageSearchWebServiceResponseKey : itemTotalInfo};
                [Appsee addEvent:kRIMItemImageSearchWebServiceResponse withProperties:imageResponseDict];
                
                totalProduct = [itemTotalInfo[@"TotalProduct"] integerValue];
                totalQTYeach = [itemTotalInfo[@"TotalItem"] doubleValue];
                totalCostPrice = [itemTotalInfo[@"TotalCost"] doubleValue];
                totalSalesPrice = [itemTotalInfo[@"TotalPrice"] doubleValue];
                
                averageCost = [itemTotalInfo[@"AverageCost"] doubleValue];
                averagePrice = [itemTotalInfo[@"AveragePrice"] doubleValue];
                totalMargin = [itemTotalInfo[@"AverageMargin"] doubleValue];
                totalMarkup = [itemTotalInfo[@"AverageMarkup"] doubleValue];
                
                [self.tblItemInfoData reloadData];
            }

        }
    }
}

-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return RIMHeaderHeight();
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
    }
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = @"";
    switch (section) {
        case 0:
            sectionTitle = @"TOTAL";
            break;
        case 1:
            sectionTitle = @"AVERAGE";
            break;
    }
    return [tableView defaultTableHeaderView:sectionTitle];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemInfoCustomCell *itemInfoCell = [self.tblItemInfoData dequeueReusableCellWithIdentifier:@"cell"];
    itemInfoCell.backgroundColor = [UIColor clearColor];
    itemInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:{
                itemInfoCell.lblDescription.text = @"Total Product";
                itemInfoCell.value.text = [NSString stringWithFormat:@"%ld",(long)totalProduct];
                break;
            }
            case 1:{
                itemInfoCell.lblDescription.text = @"Total Item";
                itemInfoCell.value.text = [NSString stringWithFormat:@"%.0f",totalQTYeach];
                break;
            }
            case 2:{
                itemInfoCell.lblDescription.text = @"Total Cost";
                NSNumber *CostVal = @(totalCostPrice);
                itemInfoCell.value.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:CostVal]];
                break;
            }
            case 3:{
                itemInfoCell.lblDescription.text = @"Total Price";
                NSNumber *PriceVal = @(totalSalesPrice);
                itemInfoCell.value.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:PriceVal]];
                break;
            }
        }
    }
    else if(indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:{
                itemInfoCell.lblDescription.text = @"Average Cost";
                NSNumber *AvgCostVal = @(averageCost);
                itemInfoCell.value.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:AvgCostVal]];
                break;
            }
            case 1:{
                itemInfoCell.lblDescription.text = @"Average Price";
                NSNumber *AvgSalesVal = @(averagePrice);
                itemInfoCell.value.text = [NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:AvgSalesVal]];
                break;
            }
            case 2:{
                itemInfoCell.lblDescription.text = @"Average Margin";
                itemInfoCell.value.text = [NSString stringWithFormat:@"%.2f%%",(totalMargin)];
                break;
            }
            case 3:{
                itemInfoCell.lblDescription.text = @"Average Markup";
                itemInfoCell.value.text = [NSString stringWithFormat:@"%.2f%%",(totalMarkup)];
                break;
            }
        }
    }
    itemInfoCell.contentView.backgroundColor = [UIColor clearColor];
    itemInfoCell.backgroundColor = [UIColor clearColor];

    return itemInfoCell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
