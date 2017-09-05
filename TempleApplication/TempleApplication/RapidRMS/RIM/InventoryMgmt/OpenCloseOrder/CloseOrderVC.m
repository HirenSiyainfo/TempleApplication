//
//  OutRecallViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 27/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "CloseOrderVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "UITableViewCell+NIB.h"
#import "OpenOrderCustomCell.h"
#import "RimMenuVC.h"
#import "InvnetoryInCustomCell.h"
#import "EmailFromViewController.h"
#import "RimIphonePresentMenu.h"
#import "ColseOrderDetailVC.h"
#import "ExportPopupVC.h"
#import "MMDDateTimePickerVC.h"

@interface CloseOrderVC ()<ExportPopupVCDelegate,MMDDateTimePickerVCDelegate,EmailFromViewControllerDelegate>
{
    EmailFromViewController *emailFromViewController;
    RimIphonePresentMenu *objMenubar;
    ColseOrderDetailVC * objColseOrderDetailVC;
    
    BOOL isStartDateClicked;
    BOOL boolPreview;

    NSString * strFromDate;
    NSString * strToDate;
    NSDate * fromDate;
    NSDate * toDate;
    NSString * strType;

    IntercomHandler *intercomHandler;
    UIView * viewPopupView;
    NSInteger deleteItemId;
    NSIndexPath *deleteIndPath;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) UIDocumentInteractionController *controller;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

@property (nonatomic, weak) IBOutlet UITableView *tblCloseOrderData;
//@property (nonatomic, weak) IBOutlet UITableView *closeOrderTypeTbl;
//@property (nonatomic, weak) IBOutlet UITableView *closeOrderItemDetailstbl;

@property (nonatomic, weak) IBOutlet UIButton *btnWeekly;
@property (nonatomic, weak) IBOutlet UIButton *btnCustomDate;
@property (nonatomic, weak) IBOutlet UIView * viewCustomDate;
@property (nonatomic, weak) IBOutlet UIView * viewTableList;

@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;
@property (nonatomic, weak) IBOutlet UILabel *lblCloseOrderTitle;

@property (nonatomic, weak) IBOutlet UILabel *closerOrderType;

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnFromDate;
@property (nonatomic, weak) IBOutlet UIButton *btnToDate;

@property (nonatomic, strong) NSMutableArray *arrScanBarDetails;
@property (nonatomic, strong) NSMutableArray *closeOrderTypeArray;
@property (nonatomic, strong) NSMutableArray *closeDataArray;
@property (nonatomic, strong) NSMutableArray *arrCloseOrderData;

@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) RapidWebServiceConnection * inventoryCloseListWC;
@property (nonatomic, strong) RapidWebServiceConnection * deleteInventoryInWC;
@property (nonatomic, strong) RapidWebServiceConnection * deleteInventoryOutWC;
@property (nonatomic, strong) RapidWebServiceConnection * inventoryInOutDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection * inventoryInOutDetailWC2;

@end

@implementation CloseOrderVC
@synthesize tblCloseOrderData,arrCloseOrderData;

@synthesize arrScanBarDetails;
@synthesize closerOrderType;

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
    [super viewDidLoad];
    
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.arrScanBarDetails = [[NSMutableArray alloc] init];
    
    self.inventoryCloseListWC = [[RapidWebServiceConnection alloc] init];
    self.deleteInventoryInWC = [[RapidWebServiceConnection alloc] init];
    self.deleteInventoryOutWC = [[RapidWebServiceConnection alloc] init];
    self.inventoryInOutDetailWC = [[RapidWebServiceConnection alloc] init];
    self.inventoryInOutDetailWC2 = [[RapidWebServiceConnection alloc] init];
    
    // Do any additional setup after loading the view from its nib.
    
    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    [self btnSwitchTab:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self gettingCloseOrderData];
}

-(IBAction)btnMenuSliderOut:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.rimsController.scannerButtonCalled=@"";
    [self presentViewController:objMenubar animated:YES completion:nil];
}

-(void)gettingCloseOrderData
{
    self.closeDataArray = [[NSMutableArray alloc] init];
    [self.arrCloseOrderData removeAllObjects];

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [Appsee addEvent:kRIMItemCloseOrderListWebServiceCall];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getCloseOrderDataResponse:response error:error];
        });
    };
    
    self.inventoryCloseListWC = [self.inventoryCloseListWC initWithRequest:KURL actionName:WSM_INVENTORY_CLOSE_LIST params:param completionHandler:completionHandler];
}

-(void)getCloseOrderDataResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [Appsee addEvent:kRIMItemCloseOrderListWebServiceResponse withProperties:@{kRIMItemCloseOrderListWebServiceResponseKey : @"Response Successful"}];
                
                NSArray * arrOrders = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                for (NSDictionary * dictOrderInfo in arrOrders) {
                    NSMutableDictionary * dictMOrder = [[NSMutableDictionary alloc]initWithDictionary:dictOrderInfo];
                    NSString * strDate = dictMOrder[@"CreatedDate"];
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";

                    dictMOrder[@"CreatedDate"] = [dateFormatter dateFromString:strDate];
                    [self.closeDataArray addObject:dictMOrder];
                }
            }
            else
            {
                [Appsee addEvent:kRIMItemCloseOrderListWebServiceResponse withProperties:@{kRIMItemCloseOrderListWebServiceResponseKey : @"No record found."}];
                self.closeDataArray = [[NSMutableArray alloc] init];
                [tblCloseOrderData reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"No record found for close order data." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
    if (self.viewCustomDate.frame.size.height < 10) {
        [self setWeeklyDataInList];
    }
    else{
        [self searchDatewiseRecordClicked:nil];
    }
}

// tableview data start

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return NO; // Return YES, if enable delete on swipe.
}

- (void)deleteCloseOrder {
    NSString *deleteId = [NSString stringWithFormat:@"%ld", (long)deleteItemId];
    if([strType isEqualToString:@"Item In"])
    {
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:deleteId forKey:@"ItemInId"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self DeleteInventoryInDataResponse:response error:error];
            });
        };
        
        self.deleteInventoryInWC = [self.deleteInventoryInWC initWithRequest:KURL actionName:WSM_DELETE_INVENTORY_IN params:param completionHandler:completionHandler];
    }
    else if ([strType isEqualToString:@"Item Out"])
    {
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:deleteId forKey:@"ItemOutId"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self DeleteInventoryOutDataResponse:response error:error];
            });
        };
        
        self.deleteInventoryOutWC = [self.deleteInventoryOutWC initWithRequest:KURL actionName:WSM_DELETE_INVENTORY_OUT params:param completionHandler:completionHandler];
    }
}
// Delete Item in record

- (void)DeleteInventoryInDataResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [arrCloseOrderData removeObjectAtIndex:deleteIndPath.row];
                [tblCloseOrderData reloadData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item not deleted." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}
//
//// Delete Item out record
//
- (void)DeleteInventoryOutDataResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [arrCloseOrderData removeObjectAtIndex:deleteIndPath.row];
                [self.tblCloseOrderData reloadData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item not deleted." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        strType = [arrCloseOrderData[indexPath.row] valueForKey:@"Type"];
        deleteItemId = [[arrCloseOrderData[indexPath.row] valueForKey:@"Id"] integerValue ];
        deleteIndPath = [indexPath copy];
        
        CloseOrderVC * __weak myWeakReference = self;
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [tblCloseOrderData setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference deleteCloseOrder];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Close Order" message:@"Are you sure you want to delete this record?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
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
-(NSString *)getStringFormateDate:(NSDate *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:pstrDate];
    
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrCloseOrderData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"OpenOrderCell";
    OpenOrderCustomCell *closeCell = (OpenOrderCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    closeCell.selectionStyle = UITableViewCellSelectionStyleNone;

    if((self.arrCloseOrderData).count > 0) {
        
        // display item in/out type
        closeCell.OpenOrderType.text= [NSString stringWithFormat:@"%@",[(self.arrCloseOrderData)[indexPath.row] valueForKey:@"Type"]];
        
        // display created date
        
        NSDate  *Datetime = [(self.arrCloseOrderData)[indexPath.row] valueForKey:@"CreatedDate"];
        if(IsPad())
        {
            closeCell.OpenOrderTime.text = [self getStringFormateDate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
            closeCell.OpenOrderDate.text = [self getStringFormateDate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy"];
        }
        else
        {
            closeCell.OpenOrderDate.text = [self getStringFormateDate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
        }
        
        // label text
        closeCell.OpenOrderTitle.text = [NSString stringWithFormat:@"%@",[(self.arrCloseOrderData)[indexPath.row] valueForKey:@"Description"]];
        
        // display username
        closeCell.OpenOrderUser.text= [NSString stringWithFormat:@"%@",[(self.arrCloseOrderData)[indexPath.row] valueForKey:@"UserName"]];
        
        closeCell.btnExportEmail.tag = indexPath.row;
        closeCell.btnExportPreview.tag = indexPath.row;
    }
    closeCell.contentView.backgroundColor = [UIColor clearColor];
    closeCell.backgroundColor = [UIColor clearColor];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    closeCell.selectedBackgroundView = selectionColor;
    return closeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblCloseOrderData)
    {
        NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
        [param setValue:[arrCloseOrderData[indexPath.row] valueForKey:@"Id"] forKey:@"Id"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        strType = [arrCloseOrderData[indexPath.row] valueForKey:@"Type"];
        [param setValue:[arrCloseOrderData[indexPath.row] valueForKey:@"Type"] forKey:@"Type"];
        [self getOrderitemsList:param withTag:indexPath.row];
    }
}

#pragma mark - Custom date selection -
-(void)setWeeklyDataInList {
    if(self.closeDataArray.count > 0)
    {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
        components.hour = -components.hour;
        components.minute = -components.minute;
        components.second = -components.second;
        components.hour = -24;
        components.minute = 0;
        components.second = 0;
        
        components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
        
        components.day = (components.day - (components.weekday - 1));
        NSDate *thisWeekstdt = [cal dateFromComponents:components];
        
        components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
        
        components.day = (components.day - (components.weekday - 8));
        NSDate *thisWeekenddt = [cal dateFromComponents:components];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"CreatedDate >= %@ AND CreatedDate <= %@", thisWeekstdt, thisWeekenddt];
        self.arrCloseOrderData = [[self.closeDataArray filteredArrayUsingPredicate:datePredicate] mutableCopy ];
        [tblCloseOrderData reloadData];
    }
}

-(IBAction)btnFromDateClicked:(id)sender {
    if (toDate) {
        [self showDateTimePickerInputView:sender PickerType:UIDatePickerModeDate PickerTitle:@"Selecte From Date" selectedDate:fromDate minDate:nil maxDate:toDate];
    }
    else {
        [self showDateTimePickerInputView:sender PickerType:UIDatePickerModeDate PickerTitle:@"Selecte From Date" selectedDate:fromDate minDate:nil maxDate:[NSDate date]];
    }
}

-(IBAction)btnToDateClicked:(id)sender {
    if (fromDate) {
        [self showDateTimePickerInputView:sender PickerType:UIDatePickerModeDate PickerTitle:@"Selecte To Date" selectedDate:toDate minDate:fromDate maxDate:[NSDate date]];
    }
    else {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Close Order" message:@"please select from date." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

-(IBAction)searchDatewiseRecordClicked:(UIButton *)sender
{
    [Appsee addEvent:kRIMItemCloseOrderListSearchDateWiseRecord];
    if(fromDate && toDate)
    {
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"CreatedDate >= %@ AND CreatedDate <= %@", fromDate, toDate];
        NSArray * tempArray = [[NSArray alloc]initWithArray:self.arrCloseOrderData];
        [self.arrCloseOrderData removeAllObjects];
        self.arrCloseOrderData = [[self.closeDataArray filteredArrayUsingPredicate:datePredicate] mutableCopy ];
        if(self.arrCloseOrderData.count > 0)
        {
            [tblCloseOrderData reloadData];
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                self.arrCloseOrderData = [[NSMutableArray alloc]initWithArray:tempArray];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"No close order found between selected date." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
    else
    {
        self.arrCloseOrderData = [[NSMutableArray alloc]initWithArray:self.closeDataArray];
        if(self.arrCloseOrderData.count > 0)
        {
            [tblCloseOrderData reloadData];
        }
    }
}

#pragma mark - date picker delegate -

-(void)showDateTimePickerInputView:(id)inputView PickerType:(UIDatePickerMode)pickerMode PickerTitle:(NSString *) strPickerTitle selectedDate:(NSDate *)selDate minDate:(NSDate *)minDate maxDate:(NSDate *)maxDate{
    
    MMDDateTimePickerVC * mMDDateTimePickerVC = [[MMDDateTimePickerVC alloc] initWithNibName:@"MMDDateTimePickerVC" bundle:nil];
    viewPopupView = [[UIView alloc]initWithFrame:self.view.bounds];
    viewPopupView.backgroundColor =[UIColor colorWithWhite:0.000 alpha:0.500];
    mMDDateTimePickerVC.view.center = viewPopupView.center;
    [viewPopupView addSubview:mMDDateTimePickerVC.view];
    [self.view addSubview:viewPopupView];
    [self addChildViewController:mMDDateTimePickerVC];
    mMDDateTimePickerVC.view.layer.cornerRadius = 8.0f;
    mMDDateTimePickerVC.Delegate = self;
    mMDDateTimePickerVC.inputView = inputView;
    mMDDateTimePickerVC.strTitle = strPickerTitle;
    mMDDateTimePickerVC.datePicker.datePickerMode = pickerMode;
    mMDDateTimePickerVC.datePicker.timeZone = [NSTimeZone localTimeZone];
    if (selDate) {
        mMDDateTimePickerVC.datePicker.date = selDate;
    }
    mMDDateTimePickerVC.datePicker.minimumDate = minDate;
    mMDDateTimePickerVC.datePicker.maximumDate = maxDate;
}

-(void)didEnterNewDate:(NSDate *)date withInputView:(id) inputView {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSString *currentSearchDate = [dateFormatter stringFromDate:date];
    
    dateFormatter.dateFormat = @"MMMM,dd yyyy";
    NSString *currentDate = [dateFormatter stringFromDate:date];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    if ([inputView isEqual:self.btnFromDate]) {
        strFromDate = [NSString stringWithFormat:@"%@ 00:00:00",currentSearchDate];
        fromDate = [dateFormatter dateFromString:strFromDate];
        [self.btnFromDate setTitle:currentDate forState:UIControlStateNormal];
    }
    else {
        strToDate = [NSString stringWithFormat:@"%@ 23:59:59",currentSearchDate];
        toDate = [dateFormatter dateFromString:strToDate];
        [self.btnToDate setTitle:currentDate forState:UIControlStateNormal];
    }
    [self didCancelEditItemPopOver];
}

-(void)didCancelEditItemPopOver {
    [UIView animateWithDuration:0.5 animations:^{
        viewPopupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        NSArray * arrView = viewPopupView.subviews;
        for (UIView * view in arrView) {
            [view removeFromSuperview];
        }
        [viewPopupView removeFromSuperview];
        viewPopupView = nil;
    }];
}

//-(IBAction)dateChanged:(id)sender
//{
//    NSDateFormatter* dateFormatter2 = [[NSDateFormatter alloc] init];
//    dateFormatter2.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
//    dateFormatter2.dateFormat = @"MM/dd/yyyy";
//    NSString *currentSearchDate = [dateFormatter2 stringFromDate:_customDatePicker.date];
//    
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"MMMM,dd yyyy";
//    NSString *currentDate = [dateFormatter stringFromDate:_customDatePicker.date];
//    if(isStartDateClicked)
//    {
//        strStartDate = [NSString stringWithFormat:@"%@ 00:00:00",currentSearchDate];
//        _lblStartDate.text = currentDate;
//    }
//    else
//    {
//        strEndDate = [NSString stringWithFormat:@"%@ 00:00:00",currentSearchDate];
//        _lblEndDate.text = currentDate;
//    }
//}


-(IBAction)btnSwitchTab:(UIButton *)sender {
    if (sender) {
        self.btnWeekly.selected = FALSE;
        self.btnCustomDate.selected = FALSE;
        sender.selected = TRUE;
        CGRect frameDate = self.viewCustomDate.frame;
        CGRect frameList = self.viewTableList.frame;
        if (sender.tag == 2) {
            //show date selection
            frameDate.size.height = 50;
            frameList.origin.y = 100;
            frameList.size.height = 530;
            [self searchDatewiseRecordClicked:nil];
        }
        else {
            //hide date selection
            frameDate.size.height = 0;
            frameList.origin.y = 50;
            frameList.size.height = 580;
            [self setWeeklyDataInList];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.viewCustomDate.frame = frameDate;
            self.viewTableList.frame = frameList;
        }];
    }
    else{
        CGRect frameDate = self.viewCustomDate.frame;
        CGRect frameList = self.viewTableList.frame;
        //hide date selection
        frameDate.size.height = 0;
        frameList.origin.y = 50;
        frameList.size.height = 580;
        self.viewCustomDate.frame = frameDate;
        self.viewTableList.frame = frameList;
    }
}

//hiten

-(void)exportEmailOtionClick:(NSInteger)tag{
    boolPreview = NO;
    [self getInventoryCloseSelectedDetail:tag];

}
-(void)getInventoryCloseSelectedDetail:(NSInteger)ptag
{    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ptag inSection:0];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    // [[arrGetData objectAtIndex:indexPath.row] valueForKey:@"ItemId"]
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:[arrCloseOrderData[indexPath.row] valueForKey:@"Id"] forKey:@"Id"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    strType = [arrCloseOrderData[indexPath.row] valueForKey:@"Type"];
    [param setValue:[arrCloseOrderData[indexPath.row] valueForKey:@"Type"] forKey:@"Type"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getInventoryInOutDataOpenExportResponse:response error:error];
        });
    };
    
    self.inventoryInOutDetailWC2 = [self.inventoryInOutDetailWC2 initWithRequest:KURL actionName:WSM_INVENTORY_IN_OUT_DETAIL params:param completionHandler:completionHandler];
}

-(void)getInventoryInOutDataOpenExportResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *tempArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(!boolPreview)
                {
                    [self htmlBillText:tempArray];
                }
                else
                {
                    [self htmlBillTextForPreview:tempArray];
                }
            }
        }
    }
}

//hiten

-(void)htmlBillText:(NSMutableArray *)parryInvoice
{
    NSMutableArray *arryInvoice = [parryInvoice.firstObject valueForKey:@"InventoryItem"];
    
    NSMutableArray *inventoryMain = [parryInvoice.firstObject valueForKey:@"InventoryMain"];
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:inventoryMain];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    if (IsPhone()) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController_iPhone"];
    }
    else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
    }

    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    NSString *strsubjectLine = @"";
    emailFromViewController.emailFromViewControllerDelegate = self;

    emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
    (emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
    (emailFromViewController.dictParameter)[@"postfile"] = myData;
    (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
    if (IsPhone()) {
        if (objColseOrderDetailVC) {
            [objColseOrderDetailVC.view addSubview:emailFromViewController.view];
        }
    }
    else {
        [self presentViewController:emailFromViewController animated:YES
                         completion:nil];
    }
}

-(void)didCancelEmail
{
    if (IsPhone()) {
        [emailFromViewController.view removeFromSuperview];
    }
    else {
        [emailFromViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)writeDataOnCacheDirectory :(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.emaiItemHtml])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.emaiItemHtml error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.emaiItemHtml = [documentsDirectory stringByAppendingPathComponent:@"ItemInfo.html"];
    [data writeToFile:self.emaiItemHtml atomically:YES];
}

-(NSString *)htmlBillHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"%@",strType]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]
                                                                                     ]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    NSString  *Datetime = [NSString stringWithFormat:@"%@",[arrayInvoice.firstObject valueForKey:@"CreatedDate"]];
    NSString *strTime = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
    NSString *strDate = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy"];
    
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"%@",strDate]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    
    return html;
}

-(NSString *)htmlBillTextForItem:(NSMutableArray *)arrayInvoice
{
    NSString *itemHtml = @"";
    for (int i=0; i<arrayInvoice.count; i++)
    {
        // set Item Detail with only 1 qty....
        NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:arrayInvoice[i]];
        itemHtml = [itemHtml stringByAppendingFormat:@"%@",strHTML];
    }
    return itemHtml;
}
-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td>&nbsp;</td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td>&nbsp;</td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"avaibleQty"],[itemDictionary[@"CostPrice"]floatValue],[itemDictionary[@"SalesPrice"]floatValue],itemDictionary[@"AddedQty"]];
    
    return htmldata;
}

#pragma mark - Get Order Items List -
-(void)getOrderitemsList:(NSDictionary *)dictParam withTag:(NSInteger)tag {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getInventoryInOutDataCloseResponse:response error:error withTag:tag];
            [_activityIndicator hideActivityIndicator];
        });
    };
    
    self.inventoryInOutDetailWC = [self.inventoryInOutDetailWC initWithRequest:KURL actionName:WSM_INVENTORY_IN_OUT_DETAIL params:dictParam completionHandler:completionHandler];
}

-(void)getInventoryInOutDataCloseResponse:(id)response error:(NSError *)error withTag:(NSInteger)tag{
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                self.arrScanBarDetails = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                objColseOrderDetailVC =
                [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ColseOrderDetailVC_sid"];
                objColseOrderDetailVC.arrItemOrderList = self.arrScanBarDetails.firstObject [@"InventoryItem"];
                NSArray * arrItemMain = self.arrScanBarDetails.firstObject [@"InventoryMain"];
                objColseOrderDetailVC.dictInventoryMain = arrItemMain.firstObject;
                objColseOrderDetailVC.tag = tag;
                objColseOrderDetailVC.popupVCdelegate = self;
                [self.navigationController pushViewController:objColseOrderDetailVC animated:YES];
            }
        }
    }
}


#pragma mark -
#pragma mark Create Pdf


-(IBAction)btnExportEmailTapped:(UIButton *)sender {
    [self didSelectExportType:ExportTypeEmail withTag:sender.tag];
}
-(IBAction)btnExportPreviewTapped:(UIButton *)sender {
    [self didSelectExportType:ExportTypePrieview withTag:sender.tag];
}

-(void)didSelectExportType:(ExportType)exportType withTag:(NSInteger)tag {

    if (self.arrScanBarDetails.count > 0) {
        switch (exportType) {
            case  ExportTypeEmail :
                [self htmlBillText:self.arrScanBarDetails];
                break;
            case ExportTypePrieview:
                [self htmlBillTextForPreview:self.arrScanBarDetails];
                break;
            default:
                break;
        }
    }
    else {
        switch (exportType) {
            case  ExportTypeEmail :
                [self exportEmailOtionClick:tag];
                break;
            case ExportTypePrieview:
                [self previewandPrintCloseOrder:tag];
                break;
            default:
                break;
        }

    }
}
//-(void)sendEmail{
//    [Appsee addEvent:kRIMItemCloseOrderListExportOptionEmail];
//    if(self.arrScanBarDetails.count > 0)
//    {
//        [self htmlBillDetailText:self.arrScanBarDetails];
//    }
//}

// Modified By Himanshu
-(void)htmlBillDetailText:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    
    self.emaiItemHtml = [self htmlBillDetailHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    if(IsPad()){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];

    }
    else{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController_iPhone"];

    }
    
    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    NSString *strsubjectLine = @"";
    emailFromViewController.emailFromViewControllerDelegate = self;
    emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
    (emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
    (emailFromViewController.dictParameter)[@"postfile"] = myData;
    (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
    
    [self.view addSubview:emailFromViewController.view];
}



-(NSString *)htmlBillDetailHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"%@",@"Close Order"]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"%@",_lblDate.text]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:_lblTime.text];
//
    return html;
}

//hiten

-(void)previewandPrintCloseOrder:(NSInteger)tag{
    [Appsee addEvent:kRIMItemCloseOrderListExportOptionPreview];
    boolPreview = YES;
    [self getInventoryCloseSelectedDetail:tag];
}

-(void)previewandPrintCloseOrderDetail{
    
    if(self.arrScanBarDetails.count > 0)
    {
        [self htmlBillDetailTextForPreviewAndPrint:self.arrScanBarDetails];
    }
}

-(void)htmlBillDetailTextForPreviewAndPrint:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    
    self.emaiItemHtml = [self htmlBillDetailHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
    
    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];

    [self writeDataOnCacheDirectory:myData];
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceiptcloseorder.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}


-(void)htmlBillTextForPreview:(NSMutableArray *)parryInvoice
{
    NSMutableArray *arryInvoice = [parryInvoice.firstObject valueForKey:@"InventoryItem"];
    
    NSMutableArray *inventoryMain = [parryInvoice.firstObject valueForKey:@"InventoryMain"];
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:inventoryMain];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceiptcloseorder.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    
    
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl{
    
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    
    // present the preview
    [self.controller presentPreviewAnimated:YES];
    
}


- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}



#pragma mark - Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}

// tableview data end

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
