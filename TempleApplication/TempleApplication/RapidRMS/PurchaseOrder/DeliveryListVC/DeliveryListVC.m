//
//  DeliveryListView.m
//  I-RMS
//
//  Created by Siya Infotech on 06/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DeliveryListVC.h"
#import "OpenListVC.h"
#import "POmenuListVC.h"
#import "PendingDeliveryPOCell_iPhone.h"

#import "RmsDbController.h"

@interface DeliveryListVC ()<UIPopoverPresentationControllerDelegate>
{
    UIViewController *tempviewController;
    UIPopoverPresentationController *infoDelivetyOption;
    
    NSIndexPath *deliverIndPath;
    NSIndexPath *deleteOrderIndPath;
    NSIndexPath *clickedIndexPath;
    
    CGPoint delivetyButtonPosition;
}

@property (nonatomic, weak) IBOutlet UIView *viewDeliveryOption;
@property (nonatomic, weak) IBOutlet UITableView *tblDeliveryList;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) OpenListVC *objOpenList;
@property (nonatomic, strong) OpenListVC *objOpenListIpad;

@property (nonatomic, strong) NSMutableArray *arrDeliveryList;

@property (nonatomic, strong) NSString *strPassPurOrdId;
@property (nonatomic, strong) NSString *strPassInvoiceNo;
@property (nonatomic, strong) NSString *strPassPO_No;
@property (nonatomic, strong) NSString *strPassRecieveId;
@property (nonatomic, strong) NSString *strDeliveryTitle;
@property (nonatomic, strong) NSString *strDeliveryDate;

@property (nonatomic, strong) RapidWebServiceConnection *getDeliveryOrderDataWC;
@property (nonatomic, strong) RapidWebServiceConnection *getpendingdeliverydataWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteOpenPoWC;
@property (nonatomic, strong) RapidWebServiceConnection *updateStatusToCloseWC;
@end

@implementation DeliveryListVC

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getDeliveryOrderDataWC = [[RapidWebServiceConnection alloc] init];
    self.getpendingdeliverydataWC = [[RapidWebServiceConnection alloc] init];
    self.deleteOpenPoWC = [[RapidWebServiceConnection alloc] init];
    self.updateStatusToCloseWC = [[RapidWebServiceConnection alloc] init];
    tempviewController = [[UIViewController alloc] init];
    self.arrDeliveryList = [[NSMutableArray alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.arrDeliveryList removeAllObjects];
    [self.tblDeliveryList reloadData];
    [self getDeliveryList];
}

-(void)getDeliveryList
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    }
    else{
        UINavigationController * objNav = self.pOmenuListVCDelegate.POmenuListNavigationController;
        UIViewController * topVC = objNav.topViewController;
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:topVC.view];
 
    }

    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self getOpenDeliveryListResponse:response error:error];
            });
    };
    
    self.getDeliveryOrderDataWC = [self.getDeliveryOrderDataWC initWithRequest:KURL actionName:WSM_GET_DELIVERY_ORDER_DATA_NEW params:itemparam completionHandler:completionHandler];
    
}

- (void)getOpenDeliveryListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
	{
        // Barcode wise search result data
		if ([response isKindOfClass:[NSDictionary class]]) {
            
			if ([[response  valueForKey:@"IsError"] intValue] == 0)
        
                self.arrDeliveryList = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblDeliveryList reloadData];
                [self.tblDeliveryList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No record found for open delivery order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
    }
}

-(void)ItemLabel:(UILabel *)sender
{
    sender.numberOfLines = 0;
    sender.textAlignment = NSTextAlignmentLeft;
    sender.backgroundColor = [UIColor clearColor];
    sender.textColor = [UIColor blackColor];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
}

- (UILabel *)resizeLabel:(UILabel *)label
{
    CGSize constraintSize = label.frame.size;
    constraintSize.height = 200;
    CGRect textRect = [label.text boundingRectWithSize:constraintSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:label.font}
                                               context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = label.frame;
    lblNameFrame.size.height = size.height;
    label.frame = lblNameFrame;
    
    return label;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblDeliveryList)
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            return 90;
        }
        else{
        return 73;
        }
    else
        return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblDeliveryList)
        return 1;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblDeliveryList)
        return self.arrDeliveryList.count;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(tableView == self.tblDeliveryList)
    {
        if(self.arrDeliveryList.count > 0)
        {

        //if ([[UIDevice currentDevice]  userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

                static NSString *CellIdentifier = @"PendingDeliveryPOCell_iPhone";
                PendingDeliveryPOCell_iPhone *cell = (PendingDeliveryPOCell_iPhone *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

                    if (cell == nil)
                    {
                        NSArray *nib;
                        
                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                            nib = [[NSBundle mainBundle] loadNibNamed:@"PendingDeliveryPOCell_iPhone" owner:self options:nil];
                        }
                        else{
                            nib = [[NSBundle mainBundle] loadNibNamed:@"PendingDeliveryPOCell_iPad" owner:self options:nil];
                        }
                        cell = nib.firstObject;
                    }

                    cell.btnClose.layer.cornerRadius = 5;
                    cell.btnClose.layer.borderWidth = 1.0f;
                    cell.btnClose.layer.borderColor = [UIColor clearColor].CGColor;
                    [cell.btnClose.layer setMasksToBounds:YES];

                    cell.lblTitle.text = [NSString stringWithFormat:@"%@",[(self.arrDeliveryList)[indexPath.row] valueForKey:@"OrderNo"]];
                    cell.lblPONumber.text = [NSString stringWithFormat:@"%@",[(self.arrDeliveryList)[indexPath.row] valueForKey:@"OpenOrderNo"]];
            
                    cell.lblOrderNumber.text = [NSString stringWithFormat:@"%@",[(self.arrDeliveryList)[indexPath.row] valueForKey:@"InvoiceNo"]];
                    
                    
                    NSString  *DatetimeUpdate = [NSString stringWithFormat:@"%@",[(self.arrDeliveryList)[indexPath.row] valueForKey:@"UpdatedDate"]];
                    
                    NSString *strNewDate = [self getStringFormate:DatetimeUpdate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
                    
                    
                    NSArray *arraydate = [strNewDate componentsSeparatedByString:@" "];
                    
                    cell.lblDeliveryDate.text = [NSString stringWithFormat:@"%@ %@ %@",arraydate.firstObject,arraydate[1],arraydate[2]];
                    
                    cell.lblDeliveryTime.text = [NSString stringWithFormat:@"%@ %@",arraydate[3],arraydate[4]];

                    
                    [cell.btnClose addTarget:self action:@selector(btnCloseDelivery:) forControlEvents:UIControlEventTouchUpInside];
                    
                    
                    [cell.btnPrint addTarget:self action:@selector(openMenuDeliveryOption:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return cell;
                    
                }

    }
    return cell;
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

-(IBAction)openMenuDeliveryOption:(id)sender{
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Export"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Print", @"Email", nil];
        
        [actionSheet showInView:self.view];
        
    }
    else{
        
        delivetyButtonPosition = [sender convertPoint:CGPointZero toView:self.tblDeliveryList];
        NSIndexPath *indpath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        
        UITableViewCell *cell = [self.tblDeliveryList cellForRowAtIndexPath:indpath];
        for(UIView *temp in cell.subviews){
            if([temp isKindOfClass:[UIButton class]]){
                delivetyButtonPosition=temp.frame.origin;
                
            }
        }
        if (infoDelivetyOption)
        {
            [tempviewController dismissViewControllerAnimated:YES completion:nil];
        }
        tempviewController.view = _viewDeliveryOption;
        
        // Present the view controller using the popover style.
        tempviewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:tempviewController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        infoDelivetyOption = [tempviewController popoverPresentationController];
        infoDelivetyOption.delegate = self;
        tempviewController.preferredContentSize = CGSizeMake(tempviewController.view.frame.size.width, tempviewController.view.frame.size.height);
        infoDelivetyOption.permittedArrowDirections = UIPopoverArrowDirectionRight;
        infoDelivetyOption.sourceView = self.tblDeliveryList;
        infoDelivetyOption.sourceRect = CGRectMake( delivetyButtonPosition.x, delivetyButtonPosition.y-95,340,264);
    }
    
}

-(IBAction)btnMenuClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetDeliveryOrderDataResult" object:nil];
    
    if(tableView == self.tblDeliveryList)
    {

        self.strPassPurOrdId = [(self.arrDeliveryList)[indexPath.row] valueForKey:@"PurchaseOrderId"];
        self.strPassInvoiceNo = [(self.arrDeliveryList)[indexPath.row] valueForKey:@"InvoiceNo"];
        self.strPassPO_No = [(self.arrDeliveryList)[indexPath.row] valueForKey:@"PO_No"];
        self.strPassRecieveId = [(self.arrDeliveryList)[indexPath.row] valueForKey:@"RecieveId"];
        self.strDeliveryTitle = [(self.arrDeliveryList)[indexPath.row] valueForKey:@"POTitle"];
        self.strDeliveryDate = [(self.arrDeliveryList)[indexPath.row] valueForKey:@"UpdatedDate"];
        
        clickedIndexPath = [indexPath copy];
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:[(self.arrDeliveryList)[indexPath.row] valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
        [itemparam setValue:@"Deliverd" forKey:@"DeliveryStatus"];
        
         [itemparam setValue:[(self.arrDeliveryList)[indexPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getDeliveredDeliveryDataResponse:response error:error];
                });
        };
        
        self.getpendingdeliverydataWC = [self.getpendingdeliverydataWC initWithRequest:KURL actionName:WSM_GET_PENDING_DELIVERY_DATA_NEW params:itemparam completionHandler:completionHandler];
    }
}

- (void)getDeliveredDeliveryDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
	{
		 if ([response isKindOfClass:[NSDictionary class]]) {
             
             NSMutableArray *arrtempPoDataTempG = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                    
                NSMutableArray *arrtempPoData = [arrtempPoDataTempG.firstObject valueForKey:@"lstPendingItems"];

                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        _objOpenList = [[OpenListVC alloc] initWithNibName:@"OpenListVC" bundle:nil];
                        _objOpenList.strSelectedPO_No = self.strPassPO_No;
                        _objOpenList.strSelectedInvoiceNo = self.strPassInvoiceNo;
                        _objOpenList.strSelectedPurOrdId = self.strPassPurOrdId;
                        _objOpenList.strSelectedRecieveId = self.strPassRecieveId;
                        _objOpenList.strSelectedDLTitle = self.strDeliveryTitle;
                        _objOpenList.strSelectedDLDate = self.strDeliveryDate;
                          _objOpenList.arrayGlobalPandingList=arrtempPoDataTempG;
                       
                         _objOpenList.strPopUpTimeDuration = [arrtempPoDataTempG.firstObject valueForKey:@"TimeDuration"];
                        
                        if([_objOpenList.strPopUpTimeDuration isEqualToString:@"DateWise"])
                        {
                        
                        // from
                        
                        _objOpenList.strPopUpFromDate =[arrtempPoDataTempG.firstObject valueForKey:@"FromDate"] ;
                        
                        
                        // to Date
                        
                        _objOpenList.strPopUpToDate =[arrtempPoDataTempG.firstObject valueForKey:@"ToDate"] ;
                        
                        }
                        
                        
                        _objOpenList.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
                        _objOpenList.strPopUpDepartment = [(self.arrDeliveryList)[clickedIndexPath.row] valueForKey:@"Departments"];
                        _objOpenList.strPopUpSupplier = [(self.arrDeliveryList)[clickedIndexPath.row] valueForKey:@"Suppliers"];
                        _objOpenList.strPopUpTags = [(self.arrDeliveryList)[clickedIndexPath.row] valueForKey:@"Tags"];
                        
                        _objOpenList.managedObjectContext = self.rmsDbController.managedObjectContext;
                        _objOpenList.tblPendingDeliveryData.hidden = FALSE;
                        _objOpenList.arrPendingDeliveryData = [arrtempPoData mutableCopy];
                        [_objOpenList.tblPendingDeliveryData reloadData];
                        [_objOpenList.tblPendingDeliveryData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    
                        [self.navigationController pushViewController:_objOpenList animated:YES];
                    }
                    else
                    {
                        _objOpenListIpad = [[OpenListVC alloc] initWithNibName:@"OpenListVC" bundle:nil];
                        _objOpenListIpad.strSelectedPO_No = self.strPassPO_No;
                        _objOpenListIpad.strSelectedInvoiceNo = self.strPassInvoiceNo;
                        _objOpenListIpad.strSelectedPurOrdId = self.strPassPurOrdId;
                        _objOpenListIpad.strSelectedRecieveId = self.strPassRecieveId;
                        _objOpenListIpad.strSelectedDLTitle = self.strDeliveryTitle;
                        _objOpenListIpad.strSelectedDLDate = self.strDeliveryDate;
                        _objOpenListIpad.arrayGlobalPandingList=arrtempPoDataTempG;
                        
                        _objOpenListIpad.strPopUpTimeDuration = [arrtempPoDataTempG.firstObject valueForKey:@"TimeDuration"];
                        
                        if([_objOpenListIpad.strPopUpTimeDuration isEqualToString:@"DateWise"])
                        {
                        // from
                        
                        _objOpenListIpad.strPopUpFromDate =[arrtempPoDataTempG.firstObject valueForKey:@"FromDate"] ;
                        
                        
                        // to Date
                        
                        _objOpenListIpad.strPopUpToDate =[arrtempPoDataTempG.firstObject valueForKey:@"ToDate"] ;
                    
                        
                        }
                        
                        _objOpenListIpad.strPopUpDepartment = [(self.arrDeliveryList)[clickedIndexPath.row] valueForKey:@"Departments"];
                        _objOpenListIpad.strPopUpSupplier = [(self.arrDeliveryList)[clickedIndexPath.row] valueForKey:@"Suppliers"];
                        _objOpenListIpad.strPopUpTags = [(self.arrDeliveryList)[clickedIndexPath.row] valueForKey:@"Tags"];
                        
                        _objOpenListIpad.managedObjectContext = self.rmsDbController.managedObjectContext;
                        _objOpenListIpad.tblPendingDeliveryData.hidden = FALSE;
                        _objOpenListIpad.arrPendingDeliveryData = [arrtempPoData mutableCopy];
                        [_objOpenListIpad.tblPendingDeliveryData reloadData];
                        [_objOpenListIpad.tblPendingDeliveryData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                        _objOpenListIpad.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
                        [self.navigationController pushViewController:_objOpenListIpad animated:NO];
//                        self._RimsController.objPOMenuList.btnBackButtonClick.hidden=NO;
//                        [self._RimsController.objPOMenuList showViewFromViewController:_objOpenListIpad];
                    }
                }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No item found in delivery pending order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
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
            [itemparam setValue:[(self.arrDeliveryList)[deleteOrderIndPath.row] valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
            
            [itemparam setValue:[(self.arrDeliveryList)[deleteOrderIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
            
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self deleteDeliveryPoDataResponse:response error:error];
                      });
            };
            
            self.deleteOpenPoWC = [self.deleteOpenPoWC initWithRequest:KURL actionName:WSM_DELETE_OPEN_PO_NEW params:itemparam completionHandler:completionHandler];
            
        
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Are you sure want to delete this order details?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
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
                [self.arrDeliveryList removeObjectAtIndex:deleteOrderIndPath.row];
                [self.tblDeliveryList reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Delivery pending details has been deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Error occur while deleting Order details, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(void)btnCloseDelivery:(id)sender
{
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        
        deleteOrderIndPath = [deliverIndPath copy];
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:[(self.arrDeliveryList)[deliverIndPath.row] valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];

        [itemparam setValue:[(self.arrDeliveryList)[deliverIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
        
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
        
        self.updateStatusToCloseWC = [self.updateStatusToCloseWC initWithRequest:KURL actionName:WSM_UPDATE_STATUS_TO_CLOSE_PO_NEW params:itemparam completionHandler:completionHandler];
        
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
                [self.arrDeliveryList removeObjectAtIndex:deleteOrderIndPath.row];
                [self.tblDeliveryList reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Order has been closed successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
