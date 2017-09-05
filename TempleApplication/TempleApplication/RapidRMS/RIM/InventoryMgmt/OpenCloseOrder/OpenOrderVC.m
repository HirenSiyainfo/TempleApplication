//
//  InRecallViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 27/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "OpenOrderVC.h"
#import "UITableViewCell+NIB.h"
#import "NewOrderScannerView.h"
#import "InventoryOutScannerView.h"
#import "RimMenuVC.h"
#import "RmsDbController.h"
#import "UITableViewCell+NIB.h"
#import "OpenOrderCustomCell.h"
#import "EmailFromViewController.h"
#import "RimIphonePresentMenu.h"
#import "ExportPopupVC.h"

@interface OpenOrderVC () <EmailFromViewControllerDelegate>
{
    RimIphonePresentMenu *objMenubar;
    IntercomHandler *intercomHandler;
    EmailFromViewController *emailFromViewController;
    UIPopoverController *infoDelivetyOption;
    UIViewController *tempviewController;

    BOOL boolPreview;

    NSString *strType;
    NSInteger deleteItemId;
    NSIndexPath *deleteIndPath;
}

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UITableView *tblOpenOrderData;

@property (nonatomic, strong) NSMutableArray *arrOpenOrderData;
@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) RapidWebServiceConnection *inventoryOpenListWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteInventoryInWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteInventoryOutWC;
@property (nonatomic, strong) RapidWebServiceConnection *inventoryInOutDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *inventoryInOutWC;

@end

@implementation OpenOrderVC

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
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.inventoryOpenListWC = [[RapidWebServiceConnection alloc] init];
    self.deleteInventoryInWC = [[RapidWebServiceConnection alloc] init];
    self.deleteInventoryOutWC = [[RapidWebServiceConnection alloc] init];
    self.inventoryInOutDetailWC = [[RapidWebServiceConnection alloc] init];
    self.inventoryInOutWC = [[RapidWebServiceConnection alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self gettingOpenOrderData];
}


-(IBAction)btnMenuSliderIn:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.rimsController.scannerButtonCalled=@"";
    [self presentViewController:objMenubar animated:YES completion:nil];
}

-(void)gettingOpenOrderData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [Appsee addEvent:kRIMItemOpenOrderListWebServiceCall];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getOpenOrderDataResponse:response error:error];
        });
    };
    
    self.inventoryOpenListWC = [self.inventoryOpenListWC initWithRequest:KURL actionName:WSM_INVENTORY_OPEN_LIST params:param completionHandler:completionHandler];
}

-(void)getOpenOrderDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *openOrderDict;
            
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                openOrderDict = @{kRIMItemOpenOrderListWebServiceResponseKey : @"Open Order List Found"};
                [Appsee addEvent:kRIMItemOpenOrderListWebServiceResponse withProperties:openOrderDict];
                self.arrOpenOrderData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [_tblOpenOrderData reloadData];
            }
            else
            {
                openOrderDict = @{kRIMItemOpenOrderListWebServiceResponseKey : @"No Record Found."};
                [Appsee addEvent:kRIMItemOpenOrderListWebServiceResponse withProperties:openOrderDict];
                self.arrOpenOrderData = [[NSMutableArray alloc] init];
                [_tblOpenOrderData reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"No Record Found for open order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

// tableview data start

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        strType = [(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Type"];
        deleteItemId = [[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Id"] integerValue ];
        deleteIndPath = [indexPath copy ];
        NSDictionary *swipeDict = @{kRIMItemOpenOrderSwipeDeleteKey : @(deleteIndPath.row)};
        [Appsee addEvent:kRIMItemOpenOrderSwipeDelete withProperties:swipeDict];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [Appsee addEvent:kRIMItemOpenOrderSwipeDeleteCancel];
            [_tblOpenOrderData setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            NSString *deleteId = [NSString stringWithFormat:@"%ld",(long) deleteItemId];
            if([strType isEqualToString:@"Item In"])
            {
                NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
                [param setValue:deleteId forKey:@"ItemInId"];
                [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                NSDictionary *itemInDict = @{kRIMOOItemInDeleteWebServiceCallKey : deleteId};
                [Appsee addEvent:kRIMOOItemInDeleteWebServiceCall withProperties:itemInDict];
                
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self DeleteInventoryInResponse:response error:error];
                    });
                };
                
                self.deleteInventoryInWC = [self.deleteInventoryInWC initWithRequest:KURL actionName:WSM_DELETE_INVENTORY_IN params:param completionHandler:completionHandler];
            }
            else if ([strType isEqualToString:@"Item Out"])
            {
                NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
                [param setValue:deleteId forKey:@"ItemOutId"];
                [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                NSDictionary *itemOutDict = @{kRIMOOItemOutDeleteWebServiceCallKey : deleteId};
                [Appsee addEvent:kRIMOOItemOutDeleteWebServiceCall withProperties:itemOutDict];
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self DeleteInventoryOutDataResponse:response error:error];
                    });
                };
                
                self.deleteInventoryOutWC = [self.deleteInventoryOutWC initWithRequest:KURL actionName:WSM_DELETE_INVENTORY_OUT params:param completionHandler:completionHandler];
            }
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this record?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString ;//= [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OpenOrderCell";
    OpenOrderCustomCell *openCell = (OpenOrderCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    openCell.OpenOrderType.text = [NSString stringWithFormat:@"%@",[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Type"]];
    
    NSString  *Datetime = [NSString stringWithFormat:@"%@",[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"CreatedDate"]];
    if(IsPad())
    {
        openCell.OpenOrderTime.text = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
        openCell.OpenOrderDate.text = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy"];
    }
    else
    {
        openCell.OpenOrderDate.text = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
    }
    
    // label text
    NSString * strTitle = [NSString stringWithFormat:@"%@",[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Description"]];
    if (strTitle.length > 0) {
        openCell.OpenOrderTitle.text = strTitle;
    }
    else {
        openCell.OpenOrderTitle.text = @"- - -";
    }
    
    // display username
    openCell.OpenOrderUser.text= [NSString stringWithFormat:@"%@",[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"UserName"]];
    
    
    openCell.btnExportEmail.tag = indexPath.row;
    openCell.btnExportPreview.tag = indexPath.row;
    openCell.contentView.backgroundColor = [UIColor clearColor];
    openCell.backgroundColor = [UIColor clearColor];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    openCell.selectedBackgroundView = selectionColor;
    return openCell;
}
-(IBAction)ExportEmail:(UIButton *)sender {
    [self exportEmailOtionClick:sender.tag];
}
-(IBAction)ExportPreview:(UIButton *)sender {
    [self previewandPrintOpenOrder:sender.tag];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrOpenOrderData.count;
}

//hiten

-(void)exportEmailOtionClick:(NSInteger)tag{
    [Appsee addEvent:kRIMItemOpenOrderListExportOptionEmail];
    boolPreview=NO;
    [self getInventoryOutSelectedDetail:tag];
}

-(void)getInventoryOutSelectedDetail:(NSInteger)ptag{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ptag inSection:0];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    // [[arrGetData objectAtIndex:indexPath.row] valueForKey:@"ItemId"]
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Id"] forKey:@"Id"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    strType = [(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Type"];
    [param setValue:[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Type"] forKey:@"Type"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getInventoryInOutDataOpenExportDetailResponse:response error:error];
        });
    };
    
    self.inventoryInOutDetailWC = [self.inventoryInOutDetailWC initWithRequest:KURL actionName:WSM_INVENTORY_IN_OUT_DETAIL params:param completionHandler:completionHandler];
}

-(void)getInventoryInOutDataOpenExportDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *tempArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(!boolPreview){
                    [self htmlBillText:tempArray];
                }
                else{
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
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
    
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
-(void)didCancelEmail
{
    [emailFromViewController.view removeFromSuperview];
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

// Modified by Hitendra
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

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OpenOrderCustomCell *openCell = (OpenOrderCustomCell *)[tableView cellForRowAtIndexPath:indexPath];
    openCell.OpenOrderBgImage.image = [UIImage imageNamed:@"ListHoverAndActive_ipad.png"];
    // to get details list of selected row
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    // [[arrGetData objectAtIndex:indexPath.row] valueForKey:@"ItemId"]
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Id"] forKey:@"Id"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    strType = [(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Type"];
    [param setValue:[(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Type"] forKey:@"Type"];
    NSDictionary *inOutDetailDict = @{kRIMItemOpenOrderSelectWebServiceCallKey : [(self.arrOpenOrderData)[indexPath.row] valueForKey:@"Id"]};
    [Appsee addEvent:kRIMItemOpenOrderSelectWebServiceCall withProperties:inOutDetailDict];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getInventoryInOutDataOpenResponse:response error:error];
        });
    };
    
    self.inventoryInOutWC = [self.inventoryInOutWC initWithRequest:KURL actionName:WSM_INVENTORY_IN_OUT_DETAIL params:param completionHandler:completionHandler];
}

-(void)getInventoryInOutDataOpenResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                NSDictionary *inOutDetailResponseDict = @{kRIMItemOpenOrderSelectWebServiceResponseKey : @"Response Successful"};
                [Appsee addEvent:kRIMItemOpenOrderSelectWebServiceResponse withProperties:inOutDetailResponseDict];
                
                if([strType isEqualToString:@"Item In"]) {
                    
                    if (IsPhone()) {
                        
                        NewOrderScannerView *objNewIn = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"NewOrderScannerView_sid"];
                        objNewIn.isItemOrderUpdate = TRUE;
                        objNewIn.sideMenuVCDelegate = self.sideMenuVCDelegate;
                        objNewIn.arrInOpenData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                        [self.navigationController pushViewController:objNewIn animated:YES];
                    }
                    else {
                        
                        UINavigationController *inNavigationController = (UINavigationController *)[self.sideMenuVCDelegate viewContorllerFor:IM_NewOrderScannerView];
                        NewOrderScannerView *objNewInIpad = inNavigationController.viewControllers[0];
                        objNewInIpad.arrInOpenData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                        objNewInIpad.sideMenuVCDelegate = self.sideMenuVCDelegate;
                        [inNavigationController popToRootViewControllerAnimated:FALSE];
                        [self.sideMenuVCDelegate showViewController:IM_NewOrderScannerView];
                    }
                }
                else if([strType isEqualToString:@"Item Out" ] ) {
                    
                    if (IsPhone()) {
                        
                        InventoryOutScannerView *objOut = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryOutScannerView_sid"];

                        objOut.isItemOrderUpdate = TRUE;
                        objOut.arrOutOpenData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                        objOut.sideMenuVCDelegate = self.sideMenuVCDelegate;
                        [self.navigationController pushViewController:objOut animated:YES];
                    }
                    else {
                        
                        UINavigationController *outNavigationController = (UINavigationController *)[self.sideMenuVCDelegate viewContorllerFor:IM_InventoryOutScannerView];
                        InventoryOutScannerView *objOutIpad = outNavigationController.viewControllers[0];
                        objOutIpad.arrOutOpenData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                        [outNavigationController popToRootViewControllerAnimated:FALSE];
                        [self.sideMenuVCDelegate showViewController:IM_InventoryOutScannerView];
                    }
                }
            }
        }
    }
}

// Delete Item in record

- (void)DeleteInventoryInResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *itemInResponseDict;
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                itemInResponseDict = @{kRIMOOItemInDeleteWebServiceResponseKey : @"Item deleted successfully."};
                [Appsee addEvent:kRIMOOItemInDeleteWebServiceResponse withProperties:itemInResponseDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrOpenOrderData removeObjectAtIndex:deleteIndPath.row];
                [_tblOpenOrderData reloadData];
            }
            else
            {
                itemInResponseDict = @{kRIMOOItemInDeleteWebServiceResponseKey : @"Item not deleted."};
                [Appsee addEvent:kRIMOOItemInDeleteWebServiceResponse withProperties:itemInResponseDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item not deleted" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

// Delete Item out record

- (void)DeleteInventoryOutDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *itemOutResponseDict;

            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                itemOutResponseDict = @{kRIMOOItemInDeleteWebServiceResponseKey : @"Item deleted successfully."};
                [Appsee addEvent:kRIMOOItemInDeleteWebServiceResponse withProperties:itemOutResponseDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrOpenOrderData removeObjectAtIndex:deleteIndPath.row];
                [self.tblOpenOrderData reloadData];
            }
            else
            {
                itemOutResponseDict = @{kRIMOOItemInDeleteWebServiceResponseKey : @"Item not deleted."};
                [Appsee addEvent:kRIMOOItemInDeleteWebServiceResponse withProperties:itemOutResponseDict];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item not deleted" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

//hiten

-(IBAction)previewandPrintOpenOrder:(NSInteger)sender{
    [Appsee addEvent:kRIMItemOpenOrderListExportOptionPreview];
    boolPreview=YES;
    [self getInventoryOutSelectedDetail:sender];
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
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceiptopenorder.pdf".stringByExpandingTildeInPath
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
