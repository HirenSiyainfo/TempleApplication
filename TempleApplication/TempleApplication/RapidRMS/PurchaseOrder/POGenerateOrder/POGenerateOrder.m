//
//  POGenerateOrder.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POGenerateOrder.h"
#import "RmsDbController.h"
#import "PODateSelectionCell.h"
#import "POMaximumQtyCell.h"
#import "POMinimumStockCell.h"
#import "PODateSelection.h"
#import "RmsDashboardVC.h"
#import "RIMNumberPadPopupVC.h"
#import "POFilterOption.h"
#import "POBackOrderList.h"
#import "POOpenOrderDetail.h"
#import "POGenerateOrderManuel.h"
#import "PODateWiseCell.h"
#import "POVendorSelectionCell.h"
#import "RimSupplierPage.h"


@interface POGenerateOrder ()<PODateSelectionDelegate,PORapidItemFilterVCDeledate,POBackOrderDelegate,RimSupplierChangeDelegate>
{
    PODateSelection *dateFilter;
    POFilterOption *poFilterOption;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *getOpenOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *generatePurchaseOrderDetailWC;

@property(nonatomic,weak)IBOutlet UITableView *tblGenerateOrder;
@property(nonatomic,weak)IBOutlet UIButton *btnFilter;
@property (nonatomic, weak) IBOutlet UIView *viewFilterBG;

@property (nonatomic, strong) NSString *tagString;
@property (nonatomic, strong) NSString *strFromDate;
@property (nonatomic, strong) NSString *strToDate;
@property (nonatomic, strong) NSString *strGroupIds;
@property (nonatomic, strong) NSMutableDictionary *selectedVendor;
@property (nonatomic, strong) NSString *supplierString;
@property (nonatomic, strong) NSString *departmentString;
@property(nonatomic,strong) NSString *minimumQty;
@property(nonatomic,strong) NSString *orderType;
@property (nonatomic, strong) NSMutableArray *arrBackorderSelected;
@property (nonatomic, strong) NSMutableArray *generateOrderArray;
@property(nonatomic,assign)BOOL isMinimumQty;



@end

@implementation POGenerateOrder

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addFilterView];
    [self setDefaultValue];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.generatePurchaseOrderDetailWC = [[RapidWebServiceConnection alloc]init];
    self.generateOrderArray = [[NSMutableArray alloc] initWithObjects:@(VEDNOR),@(ORDERTYPE),@(ISMINIMUMQTY),@(MINIMUMQTY), nil];
    [self.tblGenerateOrder setDelaysContentTouches:NO];
}

-(void)setDefaultValue{
    
    self.orderType = @"None";
    self.departmentString = @"";
    self.supplierString = @"";
    self.strGroupIds = @"";
    self.tagString = @"";
    self.isMinimumQty = false;
    self.minimumQty = @"0";
    [poFilterOption filterViewSlideIn:false];
    self.btnFilter.selected = false;
}

#pragma mark - RapidFilters -
-(void)addFilterView {
    if (!poFilterOption) {
        poFilterOption = [[UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"POFilterOption"];
        
        poFilterOption.view.frame = CGRectMake(self.viewFilterBG.bounds.size.width, 0, self.viewFilterBG.bounds.size.width, self.viewFilterBG.bounds.size.height);
        [self addChildViewController:poFilterOption];
        [self.viewFilterBG addSubview:poFilterOption.view];
        [poFilterOption didMoveToParentViewController:self];
        poFilterOption.deledate = self;
    }
}

-(void)willSetRapidItemFilterPredicate:(NSPredicate *) predicate withFilterDictionary:(NSDictionary *)dictFilterInfo{
    
    self.departmentString = [self createDepartmentstring:dictFilterInfo];
    self.supplierString = [self createVendorstring:dictFilterInfo];
    self.strGroupIds = [self createGroupstring:dictFilterInfo];
    self.tagString = [self createTagstring:dictFilterInfo];

    [poFilterOption filterViewSlideIn:FALSE];
    self.btnFilter.selected = FALSE;

}
-(NSString *)createDepartmentstring:(NSDictionary *)dictFilterInfo{
   
    NSString *deptId = @"";
    if(dictFilterInfo[@(0)]){
        NSArray *department = dictFilterInfo[@(0)];
       
        NSMutableString *strResult = [NSMutableString string];
        for (NSDictionary *dict in department) {
            [strResult appendFormat:@"%@,", dict[@"object"]];
        }
        deptId = [strResult substringToIndex:strResult.length - 1];
    }
    else{
       deptId = @"";
    }
    

    return deptId;
}
-(NSString *)createVendorstring:(NSDictionary *)dictFilterInfo{
    NSString *vendorId = @"";
    if(dictFilterInfo[@(2)]){
        NSArray *vendors = dictFilterInfo[@(2)];
        NSMutableString *strResult = [NSMutableString string];
        for (NSDictionary *dict in vendors) {
            [strResult appendFormat:@"%@,", dict[@"object"]];
        }
        vendorId = [strResult substringToIndex:strResult.length - 1];
    
    }else{
         vendorId = @"";
    }
   
    return vendorId;
    
}
-(NSString *)createGroupstring:(NSDictionary *)dictFilterInfo{
 
    NSString *groupId = @"";
    if(dictFilterInfo[@(3)]){
        
        NSArray *groups = dictFilterInfo[@(3)];
        NSMutableString *strResult = [NSMutableString string];
        for (NSDictionary *dict in groups) {
            [strResult appendFormat:@"%@,", dict[@"object"]];
        }
        groupId = [strResult substringToIndex:strResult.length - 1];
    }
    else{
        groupId = @"";
    }
    return groupId;

    
}
-(NSString *)createTagstring:(NSDictionary *)dictFilterInfo{
    
    NSString *tagId = @"";
    if(dictFilterInfo[@(4)]){
    
        NSArray *tags = dictFilterInfo[@(4)];
        NSString *tagId = @"";
        NSMutableString *strResult = [NSMutableString string];
        for (NSDictionary *dict in tags) {
            [strResult appendFormat:@"%@,", dict[@"name"]];
        }
        tagId = [strResult substringToIndex:strResult.length - 1];
    }
    else{
        tagId = @"";
    }

    return tagId;
}

-(void)willChangeRapidFilterIsSlidein:(BOOL)isSlidein{
    
}
-(IBAction)filterClick:(id)sender{
    if(self.btnFilter.selected){
        [poFilterOption filterViewSlideIn:false];
        self.btnFilter.selected = false;
    }
    else{
        [poFilterOption filterViewSlideIn:true];
        self.btnFilter.selected = true;

    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.generateOrderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    GenerateOrder InfoSection = [self.generateOrderArray[indexPath.row] integerValue];
    switch (InfoSection) {
            case VEDNOR:
            {
                cell = [self loadVendorSelectionCell:cell inTableView:tableView];
                
            }
                break;
        case ORDERTYPE:
            {
                cell = [self loadPODateSelectionCell:cell inTableView:tableView];
                
            }
            break;
            case FROMDATE:
            {
                cell = [self loadDateWiseCell:cell inTableView:tableView withType:1];
                
            }
            break;
            case TODATE:
            {
                cell = [self loadDateWiseCell:cell inTableView:tableView withType:2];
                
            }
            break;
        case ISMINIMUMQTY:
            {
                cell = [self loadPOMinimumStockCell:cell inTableView:tableView];
                
            }
            break;
        case MINIMUMQTY:
            {
                cell = [self loadPOMaximumQtyCell:cell inTableView:tableView];

            }
            
            break;
        default:
            break;
    }

    return cell;
}

-(UITableViewCell *)loadVendorSelectionCell:(UITableViewCell *)cell inTableView:(UITableView *)tblView{
    
    POVendorSelectionCell *vendorSelectionCell = (POVendorSelectionCell *)[tblView dequeueReusableCellWithIdentifier:@"SelectVendor"];
    vendorSelectionCell.viewBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    vendorSelectionCell.viewBorder.layer.borderWidth = 0.5;
    vendorSelectionCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(self.selectedVendor){
        vendorSelectionCell.vendorName.text = self.selectedVendor[@"CompanyName"];
    }
    [vendorSelectionCell.selectVendor addTarget:self action:@selector(selectVendor:) forControlEvents:UIControlEventTouchUpInside];
    cell = vendorSelectionCell;
    return cell;
    
}
-(void)selectVendor:(id)sender{
    
    RimSupplierPage *supplierNew = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimSupplierPageMenu_sid"];
    supplierNew.rimSupplierChangeDelegate = self;
    supplierNew.strItemcode = @"1";
    supplierNew.callingFunction = @"POSearchSupp";
    [self.navigationController pushViewController:supplierNew animated:YES];
    
}
- (void)didChangeSupplier:(NSMutableArray *)SupplierListArray{
    
    self.selectedVendor = SupplierListArray[0];
     [self.tblGenerateOrder reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];}

-(UITableViewCell *)loadPODateSelectionCell:(UITableViewCell *)cell inTableView:(UITableView *)tblView{
    
    PODateSelectionCell *dateSelectionCell = (PODateSelectionCell *)[tblView dequeueReusableCellWithIdentifier:@"SelectDate"];
    dateSelectionCell.viewBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    dateSelectionCell.viewBorder.layer.borderWidth = 0.5;
    dateSelectionCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(self.orderType){
        dateSelectionCell.selectedDate.text = self.orderType;
    }
    [dateSelectionCell.btnSelectDate setSelected:NO];
    if(dateFilter){
        [dateSelectionCell.btnSelectDate setSelected:YES];
    }
    cell = dateSelectionCell;

    return cell;
    
}
-(UITableViewCell *)loadDateWiseCell:(UITableViewCell *)cell inTableView:(UITableView *)tblView withType:(NSInteger)type{
    
    PODateWiseCell *podateWiseCell = (PODateWiseCell *)[tblView dequeueReusableCellWithIdentifier:@"PODateWiseCell"];
    podateWiseCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(type == 1){
        podateWiseCell.dateType.text = @"FROM DATE";
        podateWiseCell.selectedDate.text = self.strFromDate;
        
    }
    else{
          podateWiseCell.dateType.text = @"TODATE";
          podateWiseCell.selectedDate.text = self.strToDate;
    }
    cell = podateWiseCell;
    return cell;
}

-(UITableViewCell *)loadPOMinimumStockCell:(UITableViewCell *)cell inTableView:(UITableView *)tblView{
    
    POMinimumStockCell *minimumStockCell = (POMinimumStockCell *)[tblView dequeueReusableCellWithIdentifier:@"MinimumStock"];
    minimumStockCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(self.isMinimumQty){
        [minimumStockCell.mimimumStockSwitch setOn:YES];
    }
    else{
        [minimumStockCell.mimimumStockSwitch setOn:NO];
        
    }
    [minimumStockCell.mimimumStockSwitch addTarget:self action:@selector(isMininumStock:) forControlEvents:UIControlEventValueChanged];
    cell = minimumStockCell;
    return cell;
}

-(void)isMininumStock:(id)sender{
    if(self.isMinimumQty){
        self.isMinimumQty = false;
    }
    else{
        self.isMinimumQty = true;
    }
}

-(UITableViewCell *)loadPOMaximumQtyCell:(UITableViewCell *)cell inTableView:(UITableView *)tblView{
    POMaximumQtyCell *maximumQtyCell = (POMaximumQtyCell *)[tblView dequeueReusableCellWithIdentifier:@"MaximumQty"];
    maximumQtyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    maximumQtyCell.viewBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    maximumQtyCell.viewBorder.layer.borderWidth = 0.5;
    maximumQtyCell.maximumQty.text = self.minimumQty;
    cell = maximumQtyCell;
    
    return cell;
    
}

-(IBAction)openDateFilterOption:(id)sender{

    UIButton *btn = (UIButton *)sender;
    [btn setSelected:YES];
    if(!dateFilter){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
        dateFilter = [storyBoard instantiateViewControllerWithIdentifier:@"PODateSelection"];
        dateFilter.pODateSelectionDelegate = self;
        [self.view addSubview:dateFilter.view];
        [self addChildViewController:dateFilter];
    }
}

#pragma mark PODateSelectionDelegate Method

-(void)didSubmitwithDate:(NSString *)fromDate toDate:(NSString *)toDate{
    
    self.orderType = @"Datewise";
    self.strFromDate = fromDate;
    self.strToDate = toDate;
    [dateFilter.view removeFromSuperview];
    dateFilter = nil;
    
    self.generateOrderArray = [[NSMutableArray alloc] initWithObjects:@(VEDNOR),@(ORDERTYPE),@(FROMDATE),@(TODATE),@(ISMINIMUMQTY),@(MINIMUMQTY), nil];
    [self.tblGenerateOrder reloadData];
    self.tblGenerateOrder.frame = CGRectMake(self.tblGenerateOrder.frame.origin.x, self.tblGenerateOrder.frame.origin.y, self.tblGenerateOrder.frame.size.width, 260);
    [self.tblGenerateOrder reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)didSubmitwithTimeRange:(NSString *)timeRange{
    
    if(![timeRange isEqualToString:@"Datewise"]){
       
        self.generateOrderArray = [[NSMutableArray alloc] initWithObjects:@(VEDNOR),@(ORDERTYPE),@(ISMINIMUMQTY),@(MINIMUMQTY), nil];
        [self.tblGenerateOrder reloadData];
    }
    self.strFromDate = @"";
    self.strToDate = @"";
    self.orderType = timeRange;
    [dateFilter.view removeFromSuperview];
    dateFilter = nil;
    self.tblGenerateOrder.frame = CGRectMake(self.tblGenerateOrder.frame.origin.x, self.tblGenerateOrder.frame.origin.y, self.tblGenerateOrder.frame.size.width, 177);
    [self.tblGenerateOrder reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)didCancelDateRange{
    [dateFilter.view removeFromSuperview];
    dateFilter = nil;
     [self.tblGenerateOrder reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - Method Generate Order Clicked

-(IBAction)btnGenerateOrderClick:(id)sender
{
    
//    if(!self.selectedVendor){
//        
//        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
//        {
//            
//        };
//        [self.rmsDbController popupAlertFromVC:self title:@"Generate Order" message:@"Please select Vendor" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
//        
//        return;
//        
//    }
    
    if ([self.orderType isEqualToString:@"DateWise"])
    {
        if(self.strFromDate.length == 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Generate Order" message:@"Please select From date for generating order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
        else if(self.strToDate.length == 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Generate Order" message:@"Please select To date for generating order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
        else if((self.strFromDate.length == 0) && (self.strToDate.length == 0))
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Generate Order" message:@"Please select from date and to date for generating order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
    }

    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    if(self.strFromDate.length == 0)
        [param setValue:@"" forKey:@"FromDate"];
    else
        [param setValue:self.strFromDate forKey:@"FromDate"];
    
    if(self.strToDate.length == 0)
        [param setValue:@"" forKey:@"ToDate"];
    else
        [param setValue:self.strToDate forKey:@"ToDate"];
    
    [param setValue:self.departmentString forKey:@"DeptIds"];
    [param setValue:self.supplierString forKey:@"SupIds"];
    [param setValue:self.strGroupIds forKey:@"GroupIds"];
    [param setValue:self.tagString forKey:@"Tags"];
    
    if([self.minimumQty integerValue] == 0)
        [param setValue:@"0" forKey:@"MinStock"];
    else
        [param setValue:self.minimumQty forKey:@"MinStock"];
    
    [param setValue:self.orderType forKey:@"TimeDuration"];
    [param setValue:@"undefined" forKey:@"ProfitType"];
    if(self.isMinimumQty){
        [param setValue:@"YES" forKey:@"IsMinStock"];

    }
    else{
        [param setValue:@"NO" forKey:@"IsMinStock"];
    }
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    [param setValue:strDateTime forKey:@"LocalDate"];
    
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    param[@"UserId"] = userID;
    param[@"VendorId"] = self.selectedVendor[@"VendorId"];
    param[@"PoDetailxml"] = [self PoDetailxmlBackOrder];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    if([self checkpvalueForGenerateOrder:param])
    {
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self displayGeneratedOrderResponse:response error:error];
            });
        };
        self.generatePurchaseOrderDetailWC = [self.generatePurchaseOrderDetailWC initWithRequest:KURL actionName:WSM_GENERATE_PURCHASE_ORDER_DEATIL_NEW_IPHONE params:param completionHandler:completionHandler];
    }
    else{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self openGenerateOrderview];
        });
    }
}

-(void)openGenerateOrderview{
    
    [_activityIndicator hideActivityIndicator];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POGenerateOrderManuel *poPendingDetail = [storyBoard instantiateViewControllerWithIdentifier:@"POGenerateOrderManuel"];
    poPendingDetail.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
    poPendingDetail.selectedVendor = self.selectedVendor;
    [self.navigationController pushViewController:poPendingDetail animated:YES];
}

-(BOOL)checkpvalueForGenerateOrder:(NSMutableDictionary *)param{
    
    if([param[@"DeptIds"] length] > 0){
        return YES;
    }
    if([param[@"FromDate"] length] > 0){
        return YES;
    }
    if([param[@"IsMinStock"] isEqualToString:@"Yes"]){
        return YES;
    }
    if([param[@"MinStock"] integerValue] > 0){
        return YES;
    }
    if([param[@"PoDetailxml"] count] > 0){
        return YES;
    }
    if([param[@"SupIds"] length] > 0){
        return YES;
    }
    if([param[@"Tags"] length] > 0){
        return YES;
    }
    if(![param[@"TimeDuration"] isEqualToString:@"None"]){
        return YES;
    }
    if([param[@"ToDate"] length] > 0){
        return YES;
    }
    return NO;
}

- (NSMutableArray *)PoDetailxmlBackOrder
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.arrBackorderSelected.count>0)
    {
        for (int isup=0; isup<self.arrBackorderSelected.count; isup++)
        {

            NSMutableDictionary *tmpOdrDict=(self.arrBackorderSelected)[isup];
            [tmpOdrDict removeObjectForKey:@"Barcode"];
            [tmpOdrDict removeObjectForKey:@"DepartmentName"];
            [tmpOdrDict removeObjectForKey:@"ITEM_No"];
            [tmpOdrDict removeObjectForKey:@"ItemName"];
            [tmpOdrDict removeObjectForKey:@"Margin"];
            [tmpOdrDict removeObjectForKey:@"MarkUp"];
            [tmpOdrDict removeObjectForKey:@"MaxStockLevel"];
            [tmpOdrDict removeObjectForKey:@"MinStockLevel"];
            [tmpOdrDict removeObjectForKey:@"Suppliers"];
            
            [tmpOdrDict removeObjectForKey:@"ColumnNames"];
            [tmpOdrDict removeObjectForKey:@"Image"];
            [tmpOdrDict removeObjectForKey:@"ItemInfo"];
            [tmpOdrDict removeObjectForKey:@"Profit"];
            
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"Sold" ] forKey:@"SoldQty"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"AvailableQty" ] forKey:@"AvailQty"];
            [tmpOdrDict removeObjectForKey:@"Sold"];
            [tmpOdrDict removeObjectForKey:@"AvailableQty"];
            
            [itemSupplierData addObject:tmpOdrDict];
        }
    }
    return itemSupplierData;
}


- (void)displayGeneratedOrderResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSDictionary *responseDict = @{kPOGenerateOrderWebServiceResponseKey : @"Response is successful"};
                [Appsee addEvent:kPOGenerateOrderWebServiceResponse withProperties:responseDict];
                
                NSMutableArray *arrtempPoData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                if(arrtempPoData.count > 0)
                {
                    [self openOrderDetail:arrtempPoData];
                }
            }
            else if([[response valueForKey:@"IsError"] intValue] == -1)
            {
                NSDictionary *responseDict = @{kPOGenerateOrderWebServiceResponseKey : @"Error -1"};
                [Appsee addEvent:kPOGenerateOrderWebServiceResponse withProperties:responseDict];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                NSDictionary *responseDict = @{kPOGenerateOrderWebServiceResponseKey : @"Search criteria is not match with item records."};
                [Appsee addEvent:kPOGenerateOrderWebServiceResponse withProperties:responseDict];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Search criteria is not match with item records." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Match Record not found." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

-(void)openOrderDetail:(NSMutableArray *)arrtempPoData{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POOpenOrderDetail *poPendingDetail = [storyBoard instantiateViewControllerWithIdentifier:@"POOpenOrderDetail"];
    poPendingDetail.openOrderDict = arrtempPoData.firstObject;
    poPendingDetail.openOrderDetailData = arrtempPoData.firstObject[@"lstItem"];
    poPendingDetail.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
    [self.navigationController pushViewController:poPendingDetail animated:YES];

}

-(IBAction)backOrderListView:(id)sender{
 
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POBackOrderList *backOrderList = [storyBoard instantiateViewControllerWithIdentifier:@"POBackOrderList"];
    backOrderList.bodelegate = self;
    [self presentViewController:backOrderList animated:YES completion:nil];
}
#pragma mark POBackOrderDelegate Method

-(void)didSelectBackorderItems:(NSMutableArray *)items
{
    self.arrBackorderSelected = items;
}
-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:NO];
}

-(IBAction)logoutButton:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewCon in viewControllers) {
        if([viewCon isKindOfClass:[RmsDashboardVC class]]){
            [self.navigationController popToViewController:viewCon animated:YES];
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.minimumQty = textField.text;
    [textField resignFirstResponder];
    
    return YES;
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
