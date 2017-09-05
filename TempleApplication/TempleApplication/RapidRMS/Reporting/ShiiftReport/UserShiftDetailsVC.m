//
//  UserShiftDetailsVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 19/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "UserShiftDetailsVC.h"
#import "RmsDbController.h"
#import "OflineShiftReportCalculation.h"
#import "EmailFromViewController.h"
#import "ShiftInOutPopOverVC.h"
#import "ShiftHistoryDetailsVC.h"
#import "SelectUserOptionVC.h"
#import "ShiftReport.h"
#import "ReportWebVC.h"
#import "ReportsGraphCustomeCell.h"
#import "XReportBarChart.h"
#import <MessageUI/MessageUI.h>

typedef NS_ENUM (NSUInteger, ShiftDetails)
{
    ShiftDetailsForAllUsers = 101,
    ShiftDetailsForCurrentUser,
    ShiftDetailsForLastClose,
    ShiftDetailsForHistory,
};

@interface UserShiftDetailsVC () <MFMailComposeViewControllerDelegate,UpdateDelegate,ShiftInOutPopOverDelegate,UITableViewDataSource , EmailFromViewControllerDelegate> {
    NSNumber *currentUserId;
    NSNumber *openShiftUserId;
    NSNumber *serverShiftId;
    NSMutableArray *shiftReportArray;
    NSMutableArray *shiftHistoryDetailsArray;
    NSString *shiftHtml;
    NSString *shiftHtmlForEmail;
    NSMutableString *strHtmlReportForEmail;
    ShiftDetails _shiftDetails;
    XReportBarChart *xReportBarChart;
}

@property (nonatomic, weak) IBOutlet UIButton *btnUserSelection;
@property (nonatomic, weak) IBOutlet UIButton *btnOpenShift;
@property (nonatomic, weak) IBOutlet UIButton *btnCloseShift;
@property (nonatomic, weak) IBOutlet UIButton *btnLastShiftCloseReport;

@property (nonatomic, weak) IBOutlet UILabel *lblShiftNo;
@property (nonatomic, weak) IBOutlet UILabel *lblShiftStatus;
@property (nonatomic, weak) IBOutlet UILabel *lblOpenDateAndTimeValue;
@property (nonatomic, weak) IBOutlet UILabel *lblCloseDateAndTimeValue;
@property (nonatomic, weak) IBOutlet UILabel *lblShiftOpenAmountValue;
@property (nonatomic, weak) IBOutlet UILabel *lblShiftCloseAmountValue;
@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UILabel *lblShiftUserName;
@property (nonatomic, weak) IBOutlet UILabel *lblRegisterName;
@property (nonatomic, weak) IBOutlet UILabel *lblStoreName;

@property (nonatomic, weak) IBOutlet UITableView *tblGraph;

@property (nonatomic, strong) NSString *shiftType;
@property (nonatomic, strong) NSString *sourcePath;

@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;

@property (nonatomic) NSInteger nextIndex;

@property (nonatomic, strong) NSNumber *tipSetting;

@property (nonatomic, strong) NSArray *offlineInvoice;
@property (nonatomic, strong) NSMutableArray *userShiftDetailArray;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) EmailFromViewController *emailFromViewController;
@property (nonatomic, strong) ShiftInOutPopOverVC *shiftInOutPopOverVC;
@property (nonatomic, strong) ShiftReport *shiftReport;
@property (nonatomic, strong) ReportWebVC *reportWebVC;

@property (nonatomic, strong) RapidWebServiceConnection *invoiceInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection *userShiftDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *shiftHistoryDetailWC;

@property (nonatomic, strong) UpdateManager *updateShiftManager;
@end

@implementation UserShiftDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.userShiftDetailArray = [[NSMutableArray alloc] init];
    self.currencyFormatter = [[NSNumberFormatter alloc] init];
    (self.currencyFormatter).numberStyle = NSNumberFormatterCurrencyStyle;
    (self.currencyFormatter).maximumFractionDigits = 2;
    self.tipSetting = [self checkTipsSetting];
    currentUserId = @([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] integerValue]);
    self.updateShiftManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    Configuration *configuration = [self.updateShiftManager insertConfigurationMoc:self.rmsDbController.managedObjectContext];
    openShiftUserId = configuration.userId;
    serverShiftId = configuration.serverShiftId;
    self.lblRegisterName.text = (self.rmsDbController.globalDict)[@"RegisterName"];
    self.lblStoreName.text = [self.rmsDbController.appsActvDeactvSettingarray.firstObject valueForKey:@"STORENAME"];
    [self.btnUserSelection setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnUserSelection setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.btnUserSelection setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

    // Do any additional setup after loading the view.
}

#pragma mark - GetCurrentShiftDetails

- (void)getCurrentShiftDetails {
    self.btnUserSelection.selected = NO;
    [self.btnUserSelection setTitle:@"SELECT OPTIONS" forState:UIControlStateNormal];
    self.btnLastShiftCloseReport.selected = NO;
    [self sendShiftOfflineDataToServer];
}

#pragma mark - SendShiftOfflineDataToServer

- (NSNumber *)checkTipsSetting
{
    NSNumber *tipSetting;
    Configuration *configuration = [UpdateManager getConfigurationMoc:self.rmsDbController.managedObjectContext];
    tipSetting = configuration.localTipsSetting;
    return tipSetting;
}

-(NSPredicate *)predicateForShiftUser
{
    NSPredicate *predicate;
    if ([openShiftUserId isEqualToNumber:currentUserId])
    {
        predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND serverShiftId==%@ AND isUpload==%@",(self.rmsDbController.globalDict)[@"ZId"],serverShiftId,@(FALSE)];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"zId==%@ AND serverShiftId==%@ AND isUpload==%@ AND userId = %@ ",(self.rmsDbController.globalDict)[@"ZId"],serverShiftId,@(FALSE),currentUserId];
    }
    return predicate;
}

-(void)sendShiftOfflineDataToServer
{
    self.nextIndex = 0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.rmsDbController.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate= [self predicateForShiftUser];
    fetchRequest.predicate = predicate;
    self.offlineInvoice = [UpdateManager executeForContext:self.rmsDbController.managedObjectContext FetchRequest:fetchRequest];
    if(self.offlineInvoice.count > 0)
    {
#define UPLOAD_OFFLINE_INVOICES
#ifdef UPLOAD_OFFLINE_INVOICES
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self uploadNextInvoiceData];
        });
#else
        [self shiftOpenCurrentDetail];
        [self conFigureShiftStatus];
#endif
    }
    else
    {
        [self shiftOpenCurrentDetail];
        [self conFigureShiftStatus];
    }
}

-(void)conFigureShiftStatus
{
    if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"CashInOutFlg"] boolValue] == TRUE)
    {
        self.btnCloseShift.enabled = YES;
        self.btnOpenShift.enabled = NO;
    }
    else
    {
        self.btnCloseShift.enabled = NO;
        self.btnOpenShift.enabled = YES;
    }
}

- (void)uploadNextInvoiceData
{
    if(self.nextIndex >= self.offlineInvoice.count)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shiftOpenCurrentDetail];
            [self conFigureShiftStatus];
        });
        return;
    }
    InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceMstData] firstObject];
    invoiceDetailDict[@"InvoiceItemDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceItemData] firstObject];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoicePaymentData] firstObject];
    [invoiceDetail addObject:invoiceDetailDict];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init ];
    param[@"InvoiceDetail"] = invoiceDetail;
    
    AsyncCompletionHandler asyncCompletionHandler = ^(id response, NSError *error) {
        [self doAsynchOfflineShiftReportProcessResponse:response error:error];
    };
    
    self.invoiceInsertWC = [[RapidWebServiceConnection alloc] initWithAsyncRequest:KURL_INVOICE actionName:WSM_INVOICE_INSERT_LIST params:param asyncCompletionHandler:asyncCompletionHandler];
}

- (void) doAsynchOfflineShiftReportProcessResponse:(id)response error:(NSError *)error
{
    dispatch_async(dispatch_queue_create("doAsynchOfflinePaymentProcess", NULL), ^{
        [self doAsynchOfflineProcessResponse:response error:error];
    });
}

- (void)doAsynchOfflineProcessResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
                
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                [UpdateManager saveContext:privateManagedObjectContext];
            }
            else  if ([[response valueForKey:@"IsError"] intValue] == -2)
            {
                InvoiceData_T *invoiceDataT = (self.offlineInvoice)[self.nextIndex];
                
                NSManagedObjectID *objectIdForInvoiceData = invoiceDataT.objectID;
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
                invoiceDataT = (InvoiceData_T *)[privateManagedObjectContext objectWithID:objectIdForInvoiceData];
                [UpdateManager deleteFromContext:privateManagedObjectContext object:invoiceDataT];
                [UpdateManager saveContext:privateManagedObjectContext];
            }
            else
            {
            }
        }
    }
    
    self.nextIndex++;
    [self uploadNextInvoiceData];
}

#pragma mark - User Shift Details

-(void)shiftOpenCurrentDetail
{
    [self accessUserShiftDetails:ShiftDetailsForAllUsers withUserDetails:nil];
}

- (IBAction)lastShiftCloseReportClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    [self setSelectionFor:self.btnLastShiftCloseReport];
    self.emailFromViewController = nil;
    [self accessUserShiftDetails:ShiftDetailsForLastClose withUserDetails:nil];
}

#pragma mark - Access User Shift Details

- (void)accessUserShiftDetails:(ShiftDetails)shiftDetails withUserDetails:(NSDictionary *)userDictionary {
    [self.userShiftDetailsVCDelegate didUserShiftServiceCall];
    _shiftDetails = shiftDetails;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    NSString *serviceName;
    switch (shiftDetails) {
        case ShiftDetailsForAllUsers:
            serviceName = WSM_SHIFT_OPEN_CURRENT_DETAIL;
            dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
            dict[@"ReportUserId"] = @"0";
            dict[@"CurrentUserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
            break;
        case ShiftDetailsForCurrentUser:
            serviceName = WSM_SHIFT_OPEN_CURRENT_DETAIL;
            if (userDictionary) {
                dict[@"ReportUserId"] = userDictionary [@"UserId"];
                dict[@"ZId"] = userDictionary [@"ZId"];
            }
            else {
                dict[@"ReportUserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
                dict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
            }
            dict[@"CurrentUserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
            break;
        case ShiftDetailsForLastClose:
            serviceName = WSM_SHIFT_CLOSE_DETAIL;
            dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
            break;

        default:
            break;
    }
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shiftDetailsResponse:response error:error];
        });
    };
    self.userShiftDetailWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:serviceName params:dict completionHandler:completionHandler];
}

- (void)shiftDetailsResponse:(id)response error:(NSError *)error
{
    [self.userShiftDetailsVCDelegate didGetResponseOfUserShiftServiceCall];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                shiftReportArray = [responseArray mutableCopy];
                //Add Offline Calculation
                OflineShiftReportCalculation *oflineShiftReportCalculation = [[OflineShiftReportCalculation alloc] initWithArray:responseArray withZid:(self.rmsDbController.globalDict)[@"ZId"]];
                [oflineShiftReportCalculation updateReportWithOfflineDetail];
                NSMutableDictionary *shiftDetailDict = [[responseArray.firstObject valueForKey:@"objShiftDetail"] firstObject];
                if (_shiftDetails == ShiftDetailsForLastClose) {
                    serverShiftId  = @([[shiftDetailDict valueForKey:@"CashInOutId"] integerValue]);
                    if ([[shiftDetailDict valueForKey:@"ShiftStatus"] isEqualToString:@"None"])
                    {
                        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                        {
                        };
                        [self.rmsDbController popupAlertFromVC:self title:@"Shift Open | Close" message:@"No shift report found in last shift close report" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                        return;
                    }
                    else
                    {
                        [self generateAndLoadHtmlFromResponse:responseArray withShiftDetailDict:shiftDetailDict forHistory:NO];
                    }
                }
                else {
                    if (self.userShiftDetailArray.count==0)
                    {
                        self.userShiftDetailArray = [responseArray.firstObject valueForKey:@"objShiftUser"];
                        NSMutableDictionary *dictNone = [self addExtraUser:@"Current User"];
                        [self.userShiftDetailArray insertObject:dictNone atIndex:(self.userShiftDetailArray).count];
                        NSMutableDictionary *dictAllUsers = [self addExtraUser:@"All Users"];
                        [self.userShiftDetailArray insertObject:dictAllUsers atIndex:0];
                    }
                    //Generate and Load Html
                    [self generateAndLoadHtmlFromResponse:responseArray withShiftDetailDict:shiftDetailDict forHistory:NO];
                }
                //Configure Shift Summary
                [self configureShiftSummaryAccordingToShiftStatus:[shiftDetailDict valueForKey:@"ShiftStatus"] withShiftDetailDict:shiftDetailDict];
            }
        }
    }
}

- (NSMutableDictionary *)addExtraUser:(NSString *)extraUser {
    NSMutableDictionary *dictNone = [[NSMutableDictionary alloc] init];
    dictNone[@"UserName"] = extraUser;
    return dictNone;
}

- (void)generateAndLoadHtmlFromResponse:(NSMutableArray *)responseArray withShiftDetailDict:(NSMutableDictionary *)shiftDetailDict forHistory:(BOOL)isForHistory {
    [self htmlAndPrintingProcessWithResponse:responseArray withPrintArray:shiftReportArray forHistory:isForHistory];
    [self.tblGraph reloadData];
}

- (void)htmlAndPrintingProcessWithResponse:(NSMutableArray *)responseArray withPrintArray:(NSMutableArray *)printArray forHistory:(BOOL)isForHistory {
    NSString *htmldata = [self generateHTMLForShiftReportFromDictionary:responseArray.firstObject];
    strHtmlReportForEmail = [[self createHTMLFormateForEmail:htmldata] mutableCopy];
    /// Write Data On Document Directory.......
    NSData *data = [strHtmlReportForEmail dataUsingEncoding:NSUTF8StringEncoding];
    [self writeHtmlDataOnCacheDirectory:data];
    htmldata = [self createHTMLFormateForDisplayReportInWebView:htmldata];
    [self.userShiftDetailsVCDelegate didGenerateHtml:htmldata andPrintArray:printArray forHistory:isForHistory emailHtmlPath:self.sourcePath];
}

- (void)loadHtmlForUserShiftUsing:(NSString *)html {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.reportWebVC loadHtmlReportInWebView:html];
    });
}

#pragma mark - Write Html File

-(void)writeHtmlDataOnCacheDirectory:(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.sourcePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.sourcePath error:nil];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.sourcePath = [documentsDirectory stringByAppendingPathComponent:@"ReportDetail.html"];
    [data writeToFile:self.sourcePath atomically:YES];
}

#pragma mark - Access Shift History Details

- (void)accessShiftHistoryDetailsUsing:(NSDictionary *)shiftDetailsDictionary {
    _shiftDetails = ShiftDetailsForHistory;
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = [shiftDetailsDictionary valueForKey:@"BranchId"];
    dict[@"RegisterId"] = [shiftDetailsDictionary valueForKey:@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"ZId"] = [shiftDetailsDictionary valueForKey:@"ZId"];
    dict[@"BrnCashInOutId"] = [shiftDetailsDictionary valueForKey:@"BrnCashInOutId"];
    dict[@"ClosingDate"] = [shiftDetailsDictionary valueForKey:@"ClsDate"];
    dict[@"OpeningDate"] = [shiftDetailsDictionary valueForKey:@"OpnDate"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shiftHistoryDetailsResponse:response error:error];
        });
    };
    
    self.shiftHistoryDetailWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_SHIFT_HISTORY_DETAIL params:dict completionHandler:completionHandler];
}

-(void)shiftHistoryDetailsResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                shiftHistoryDetailsArray = [responseArray mutableCopy];
                if (self.userShiftDetailArray.count==0)
                {
                    self.userShiftDetailArray = [responseArray.firstObject valueForKey:@"objShiftUser"];
                    NSMutableDictionary *dictNone = [self addExtraUser:@"Current User"];
                    [self.userShiftDetailArray insertObject:dictNone atIndex:(self.userShiftDetailArray).count];
                    NSMutableDictionary *dictAllUsers = [self addExtraUser:@"All Users"];
                    [self.userShiftDetailArray insertObject:dictAllUsers atIndex:0];
                }
                //Generate and Load Html
                [self htmlAndPrintingProcessWithResponse:responseArray withPrintArray:shiftHistoryDetailsArray forHistory:YES];
                return;
            }
        }
    }
    [self.userShiftDetailsVCDelegate didGenerateHtml:nil andPrintArray:nil forHistory:YES emailHtmlPath:nil];
}

#pragma mark - Shift Summary

- (void)configureShiftSummaryAccordingToShiftStatus:(NSString *)shiftStatus withShiftDetailDict:(NSMutableDictionary *)shiftDetailDict {
    if ([shiftStatus isEqualToString:@"ShiftOpen"])
    {
        self.lblShiftNo.text = [NSString stringWithFormat:@"SHIFT #%ld",(long)[[shiftDetailDict valueForKey:@"ShiftNo"] integerValue]];
        self.lblShiftStatus.text = [[shiftDetailDict valueForKey:@"ShiftStatus"] uppercaseString];
        self.lblOpenDateAndTimeValue.text = [NSString stringWithFormat:@"%@ %@",[shiftDetailDict valueForKey:@"Startdate"],[shiftDetailDict valueForKey:@"StartTime"]];
        self.lblShiftOpenAmountValue.text = [NSString stringWithFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",[[shiftDetailDict valueForKey:@"OpeningAmount"] floatValue]]]];
        self.lblUserName.text = [NSString stringWithFormat:@"%@",[shiftDetailDict valueForKey:@"ShiftOpenByUser"]];
        self.lblShiftUserName.text = [NSString stringWithFormat:@"%@",[shiftDetailDict valueForKey:@"UserName"]];
        self.lblCloseDateAndTimeValue.text = @"-";
        self.lblShiftCloseAmountValue.text = @"-";
    }
    else if (([shiftStatus isEqualToString:@"ShiftNotOpen"]) || ([shiftStatus isEqualToString:@"None"])) {
        self.lblShiftNo.text = @"SHIFT #";
        self.lblShiftStatus.text = @"SHIFTNOTOPEN";
        self.lblOpenDateAndTimeValue.text = @"-";
        self.lblCloseDateAndTimeValue.text = @"-";
        self.lblShiftOpenAmountValue.text = @"-";
        self.lblShiftCloseAmountValue.text = @"-";
        self.lblUserName.text = @"-";
        self.lblShiftUserName.text = @"-";
    }
    else if ([shiftStatus isEqualToString:@"ShiftClose"])
    {
        self.lblShiftNo.text = [NSString stringWithFormat:@"SHIFT #%ld",(long)[[shiftDetailDict valueForKey:@"ShiftNo"] integerValue]];
        self.lblShiftStatus.text = [[shiftDetailDict valueForKey:@"ShiftStatus"] uppercaseString];
        self.lblOpenDateAndTimeValue.text = [NSString stringWithFormat:@"%@ %@",[shiftDetailDict valueForKey:@"Startdate"],[shiftDetailDict valueForKey:@"StartTime"]];
        self.lblCloseDateAndTimeValue.text = [NSString stringWithFormat:@"%@ %@",[shiftDetailDict valueForKey:@"CloseDate"],[shiftDetailDict valueForKey:@"CloseTime"]];
        self.lblShiftOpenAmountValue.text = [NSString stringWithFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",[[shiftDetailDict valueForKey:@"OpeningAmount"] floatValue]]]];
        self.lblShiftCloseAmountValue.text = [NSString stringWithFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",[[shiftDetailDict valueForKey:@"ClosingAmount"] floatValue]]]];
        self.lblUserName.text = [NSString stringWithFormat:@"%@",[shiftDetailDict valueForKey:@"ShiftOpenByUser"]];
        self.lblShiftUserName.text = [NSString stringWithFormat:@"%@",[shiftDetailDict valueForKey:@"UserName"]];
    }
}

#pragma mark - Shift Html

- (void)generateShiftHtml:(NSMutableArray *)responseArray :(NSMutableDictionary *)shiftDetailDict {
    NSMutableArray *shiftTenderArray = [[NSMutableArray alloc] init ];
    if (_shiftDetails == ShiftDetailsForCurrentUser) {
        if (![[shiftDetailDict valueForKey:@"ShiftStatus"] isEqualToString:@"None"])
        {
            shiftTenderArray = [responseArray.firstObject valueForKey:@"objShiftTender"];
        }
    }
    else {
        shiftTenderArray = [responseArray.firstObject valueForKey:@"objShiftTender"];
    }
    NSString *baseUrlPath = [[NSBundle mainBundle] pathForResource:@"ShiftReport" ofType:@"html"];
    shiftHtml = [NSString stringWithContentsOfFile:baseUrlPath encoding:NSUTF8StringEncoding error:nil];
    shiftHtml = [self htmlForShiftReport:shiftHtml replaceWithData:shiftDetailDict replaceWithTenderData:shiftTenderArray discountArray:[responseArray.firstObject valueForKey:@"objShiftDiscount"]];
    if ([self isShiftHasInvoiceInOffline] == FALSE)
    {
        shiftHtml = [shiftHtml stringByReplacingOccurrencesOfString:@"OFFLINE" withString:@""];
    }
    NSData *data = [shiftHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    NSString *sourcePath = [documentsDirectory stringByAppendingPathComponent:@"shiftDetail.html"];
    shiftHtml =[shiftHtml stringByReplacingOccurrencesOfString:@"$$SHIFT_STAR_END_DATE$$" withString:@""];
    [data writeToFile:sourcePath atomically:YES];
}

-(BOOL)isShiftHasInvoiceInOffline
{
    BOOL isShiftHasInvoiceInOffline = FALSE;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.rmsDbController.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate= [self predicateForShiftUser];
    fetchRequest.predicate = predicate;
    
    NSArray *object = [UpdateManager executeForContext:self.rmsDbController.managedObjectContext FetchRequest:fetchRequest];
    if (object.count > 0)
    {
        isShiftHasInvoiceInOffline = TRUE;
    }
    return isShiftHasInvoiceInOffline;
}

-(NSString *)htmlForShiftReport :(NSString *)html replaceWithData :(NSMutableDictionary *)dataDict replaceWithTenderData :(NSMutableArray *)shiftTenderArray discountArray:(NSArray *)discountArray
{

    html = [html stringByReplacingOccurrencesOfString:@"$$GROSS_SALES$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber: dataDict [@"DailySales"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TAXES$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber: dataDict [@"CollectTax"]]]];
    
    float netSales = [dataDict [@"TotalSales"] doubleValue] - [dataDict [@"CollectTax"]doubleValue];
    NSNumber *netSale = @(netSales);
    html = [html stringByReplacingOccurrencesOfString:@"$$NET_SALES$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:netSale]]];
    
    html = [self getFuelSummery:dataDict withHtml:html];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$OPENING_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"OpeningAmount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$SALE$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"Sales"]]]];
    
    double returnAmount = [dataDict[@"Return"] doubleValue];
    NSNumber *returnAmountNumber = @(fabs(returnAmount));
    html =  [html stringByReplacingOccurrencesOfString:@"$$RETURN$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:returnAmountNumber]]];
    
    double sum1 = [dataDict [@"Sales"] doubleValue] + [dataDict [@"Return"] doubleValue];
    NSNumber *sum1number = @(sum1);
    html =  [html stringByReplacingOccurrencesOfString:@"$$NET_TOTAL$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:sum1number]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$TAXES$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"CollectTax"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$DEBIT_SURCHARGE$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"Surcharge"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$GIFT_CARD$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"LoadAmount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$MONEY_ORDER$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"MoneyOrder"]]]];
    
    NSString *tips = [self htmlForTips:dataDict];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIPS$$" withString:tips];
    
    double totalopenAmount=[[dataDict valueForKey:@"OpeningAmount"]doubleValue]+[[dataDict valueForKey:@"Sales"]doubleValue]+[[dataDict valueForKey:@"Return"]doubleValue]+[[dataDict valueForKey:@"CollectTax"]doubleValue]+[[dataDict valueForKey:@"Surcharge"]doubleValue] + [[dataDict valueForKey:@"LoadAmount"]doubleValue] + [[dataDict valueForKey:@"MoneyOrder"]doubleValue];
    if (self.tipSetting.boolValue)
    {
        totalopenAmount = totalopenAmount + [dataDict [@"TotalTips"] doubleValue];
    }
    NSNumber *doubleTotal1number = @(totalopenAmount);
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_1$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:doubleTotal1number]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DROPS$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"DropAmount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$CLOSING_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"ClosingAmount"]]]];
    // set Item Detail with only 1 qty....
    float fcardAmt=0;
    NSString *htmlTender = @"";
    for (int i=0; i < shiftTenderArray.count; i++)
    {
        NSMutableDictionary *TenderRptCard = shiftTenderArray[i];
        NSString *strCashType = [NSString stringWithFormat:@"%@",[TenderRptCard valueForKey:@"CashInType"]];
        if(![strCashType isEqualToString:@"Cash"])
        {
            NSString *strHTML = [self htmlBillTextGenericForItemwithDictionaryMain:TenderRptCard];
            htmlTender = [htmlTender stringByAppendingString:strHTML];
            NSString *scardamount=[NSString stringWithFormat:@"%.2f",[[TenderRptCard valueForKey:@"Amount"] floatValue]];
            fcardAmt+=scardamount.floatValue;
        }
    }
    html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TRANSACTION$$" withString:[NSString stringWithFormat:@"%@",htmlTender]];
    
    double payOutAmount = [dataDict[@"PayOut"] doubleValue];
    NSNumber *payOutAmountNumber = @(fabs(payOutAmount));
    
    double doubleTotal2 = [[dataDict valueForKey:@"ClosingAmount"]floatValue] + fcardAmt + payOutAmountNumber.floatValue + [[dataDict valueForKey:@"DropAmount"]floatValue];
    NSNumber *doubleTotal2number = @(doubleTotal2);
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_2$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:doubleTotal2number]]];
    
    double overShortValue = doubleTotal2 - totalopenAmount;
    
    // hiten for Payment Detail
    
    // set Item Detail with only 1 qty....
    double fcardAmttemp = 0.00;
    NSInteger fcardCount = 0;
    
    NSString *htmlTendertemp = @"";
    for (int i=0; i <=shiftTenderArray.count; i++)
    {
        if(i==0)
        {
            NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:nil];
            htmlTendertemp = [htmlTendertemp stringByAppendingString:strHTML];
            
        }
        else{
            NSMutableDictionary *TenderRptCard = shiftTenderArray[i-1];
            NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:TenderRptCard];
            htmlTendertemp = [htmlTendertemp stringByAppendingString:strHTML];
            fcardAmttemp += [[TenderRptCard valueForKey:@"Amount"] doubleValue];
            if (self.tipSetting.boolValue)
            {
                fcardAmttemp += [[TenderRptCard valueForKey:@"TipsAmount"] doubleValue];
            }
            fcardCount += [[TenderRptCard valueForKey:@"Count"] integerValue];
        }
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TRANSACTION_DETAIL$$" withString:[NSString stringWithFormat:@"%@",htmlTendertemp]];
    NSNumber *doubleTotal3number = @(fcardAmttemp);
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_3$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:doubleTotal3number]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_COUNT$$" withString:[NSString stringWithFormat:@"%ld",(long)fcardCount]];
    
    if (self.tipSetting.boolValue) {
        double tenderAmount = 0.00;
        double tenderTipsAmount = 0.00;
        double tenderTipsAmountTotal = 0.00;
        
        NSString *htmlTenderTips = @"";
        for (int i=0; i <=shiftTenderArray.count; i++)
        {
            if(i==0)
            {
                NSString *strHTML = [self htmlForTenderTips:nil];
                htmlTenderTips = [htmlTenderTips stringByAppendingString:strHTML];
            }
            else{
                NSMutableDictionary *TenderRptCard = shiftTenderArray[i-1];
                NSString *strHTML = [self htmlForTenderTips:TenderRptCard];
                htmlTenderTips = [htmlTenderTips stringByAppendingString:strHTML];
                tenderAmount += [[TenderRptCard valueForKey:@"Amount"] doubleValue];
                tenderTipsAmount += [[TenderRptCard valueForKey:@"TipsAmount"] doubleValue];
                if (self.tipSetting.boolValue)
                {
                    tenderTipsAmountTotal += [[TenderRptCard valueForKey:@"Amount"] doubleValue] + [[TenderRptCard valueForKey:@"TipsAmount"] doubleValue];
                }
            }
        }
        html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TIPS_DETAIL$$" withString:[NSString stringWithFormat:@"%@",htmlTenderTips]];
        NSNumber *doubleTotalTenderAmount = @(tenderAmount);
        NSNumber *doubleTotalTenderTipsAmount = @(tenderTipsAmount);
        NSNumber *doubleTenderTipsAmountTotal = @(tenderTipsAmountTotal);
        
        NSString *htmlTipsTenderFooter = @"";
        if(self.emailFromViewController)
        {
            htmlTipsTenderFooter = [htmlTipsTenderFooter stringByAppendingFormat:@"<tr style=\"font-weight:bold\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
            
            htmlTipsTenderFooter = [htmlTipsTenderFooter stringByAppendingFormat:@"<tr style=\"font-weight:bold\"><td style=\"border-bottom:1px solid #90BCC3;\">Total</td><td style=\"border-bottom:1px solid #90BCC3;\">%@</td><td style=\"border-bottom:1px solid #90BCC3;\">%@</td><td style=\"border-bottom:1px solid #90BCC3;\">%@</td></tr>",[self.currencyFormatter stringFromNumber:doubleTotalTenderAmount],[self.currencyFormatter stringFromNumber:doubleTotalTenderTipsAmount],[self.currencyFormatter stringFromNumber:doubleTenderTipsAmountTotal]];
        }
        else
        {
            htmlTipsTenderFooter = [htmlTipsTenderFooter stringByAppendingFormat:@"<tr style=\"font-weight:bold\"><td width=\"162\">%@:</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td></tr>",@"Total",[self.currencyFormatter stringFromNumber:doubleTotalTenderAmount],[self.currencyFormatter stringFromNumber:doubleTotalTenderTipsAmount],[self.currencyFormatter stringFromNumber:doubleTenderTipsAmountTotal]];
        }
        html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TIPS_DETAIL_FOOTER$$" withString:htmlTipsTenderFooter];
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TIPS_DETAIL$$" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"$$TENDER_TIPS_DETAIL_FOOTER$$" withString:@""];
    }
    
    NSString *discountHtml = [self htmlDiscountDetail:discountArray];
    html = [html stringByReplacingOccurrencesOfString:@"$$DISCOUNT_DETAIL$$" withString:[NSString stringWithFormat:@"%@",discountHtml]];
    
    CGFloat totalSalesAmount = 0.00;
    CGFloat totalDiscountAmount = 0.00;
    NSInteger totalDiscountCount = 0;
    for (NSDictionary *discountDict in discountArray) {
        totalSalesAmount += [discountDict[@"Sales"] floatValue];
        totalDiscountAmount += [discountDict[@"Amount"] floatValue];
        totalDiscountCount += [discountDict[@"Count"] integerValue];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_DISCOUNT_SALES$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:@(totalSalesAmount)]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_DISCOUNT_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:@(totalDiscountAmount)]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_DISCOUNT_COUNT$$" withString:[NSString stringWithFormat:@"%ld",(long)totalDiscountCount]];
    
    NSString *strHTML = [self htmlGiftCardDetail:dataDict];
    html = [html stringByReplacingOccurrencesOfString:@"$$GIFT_CARD_TRANSACTION_DETAIL$$" withString:[NSString stringWithFormat:@"%@",strHTML]];
    
    NSInteger totalcount = [dataDict [@"LoadCount"]integerValue] + [dataDict [@"RedeemCount"]integerValue];
    float totalAmount = [dataDict [@"TotalGCADY"]floatValue] + [dataDict [@"TotalLoadAmount"]floatValue] + [dataDict [@"TotalRedeemAmount"]floatValue];
    NSNumber *numtotAmount = @(totalAmount);
    
    html = [html stringByReplacingOccurrencesOfString:@"$$GC_TOTAL$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numtotAmount]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$GC_COUNT$$" withString:[NSString stringWithFormat:@"%ld",(long)totalcount]];
    
    NSNumber *overShortnumber = @(overShortValue);
    html = [html stringByReplacingOccurrencesOfString:@"$$OVER / SHORT$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:overShortnumber]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$GC_LIABIALITY$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"GCLiablity"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$CHECK_CASH$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"CheckCash"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$NON_TAX_SALES$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"NonTaxSales"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$LINE_ITEM_VOID$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dataDict valueForKey:@"LineItemVoid"] integerValue]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$AVG_TICKET$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"AvgTicket"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$CSC$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dataDict valueForKey:@"CustomerCount"] integerValue]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ABT$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dataDict valueForKey:@"AbortedTrans"] integerValue]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$NSC$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dataDict valueForKey:@"NoSales"] integerValue]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TTD$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"Discount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$PAYOUT$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:payOutAmountNumber]]];
    html = [html stringByReplacingOccurrencesOfString:@"[Register Name]" withString:[NSString stringWithFormat:@"%@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"]]];
    html = [html stringByReplacingOccurrencesOfString:@"[User Name]" withString:[NSString stringWithFormat:@"%@",[dataDict valueForKey:@"UserName"]]];
    
    NSString *strShiftStatus = [NSString stringWithFormat:@"%@",[dataDict valueForKey:@"ShiftStatus"]];
    
    if ([strShiftStatus isEqualToString:@"ShiftOpen"] )
    {
        NSString *shiftNo = [NSString stringWithFormat:@"Shift #%ld - Open",(long)[[dataDict valueForKey:@"ShiftNo"] integerValue]];
        html = [html stringByReplacingOccurrencesOfString:@"$$Shift$$" withString:shiftNo];
    }
    else if (([strShiftStatus isEqualToString:@"ShiftNotOpen"]) || ([strShiftStatus isEqualToString:@"None"]))
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$Shift$$" withString:@"Shift NOT Open"];
    }
    else if ([strShiftStatus isEqualToString:@"ShiftClose"])
    {
        NSString *shiftNo = [NSString stringWithFormat:@"Shift #%ld - Close",(long)[[dataDict valueForKey:@"ShiftNo"] integerValue]];
        html = [html stringByReplacingOccurrencesOfString:@"$$Shift$$" withString:shiftNo];
    }
    html = [html stringByReplacingOccurrencesOfString:@"$$Shift$$" withString:[NSString stringWithFormat:@"%@",[dataDict valueForKey:@"UserName"]]];
    return html;
}

-(NSString *)htmlDiscountDetail:(NSArray *)discountArray
{
    NSString *htmldata = @"";
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold; border-top:1px solid #90BCC3; border-bottom:1px solid #90BCC3;\" ><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Discount Type",@"Sales",@"Discount",@"Count"];
    if(self.emailFromViewController)
    {
        htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
    }
    
    if ([discountArray isKindOfClass:[NSArray class]] && discountArray != nil) {
        NSDictionary *customizedDiscountDict = [self customizedDiscountFromArray:discountArray];
        NSDictionary *manualDiscountDict = [self manualDiscountFromArray:discountArray];
        NSDictionary *preDefinedDiscountDict = [self preDefinedDiscountFromArray:discountArray];
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Customized",[self.currencyFormatter stringFromNumber: customizedDiscountDict [@"Sales"]],[self.currencyFormatter stringFromNumber: customizedDiscountDict [@"Amount"]],customizedDiscountDict [@"Count"]];
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Manual",[self.currencyFormatter stringFromNumber: manualDiscountDict [@"Sales"]],[self.currencyFormatter stringFromNumber: manualDiscountDict [@"Amount"]],manualDiscountDict [@"Count"]];
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"PreDefined",[self.currencyFormatter stringFromNumber: preDefinedDiscountDict [@"Sales"]],[self.currencyFormatter stringFromNumber: preDefinedDiscountDict [@"Amount"]],preDefinedDiscountDict [@"Count"]];
    }
    
    return htmldata;
}

- (NSDictionary *)customizedDiscountFromArray:(NSArray *)discountArray
{
    return [self discountDetailsForDiscountCategory:2 withDiscountArray:discountArray];
}

- (NSDictionary *)manualDiscountFromArray:(NSArray *)discountArray
{
    return [self discountDetailsForDiscountCategory:3 withDiscountArray:discountArray];
}

- (NSDictionary *)preDefinedDiscountFromArray:(NSArray *)discountArray
{
    return [self discountDetailsForDiscountCategory:1 withDiscountArray:discountArray];
}

- (NSDictionary *)discountDetailsForDiscountCategory:(NSInteger)discountCategory withDiscountArray:(NSArray *)discountArray{
    NSPredicate *discountPredicate = [NSPredicate predicateWithFormat:@"DiscountCategory == %@", @(discountCategory)];
    NSArray *discount = [discountArray filteredArrayUsingPredicate:discountPredicate];
    NSMutableDictionary *discountDetail;
    if (discount.count > 0) {
        discountDetail = [discount.firstObject mutableCopy];
    }
    else
    {
        discountDetail = [[NSMutableDictionary alloc] init];
        discountDetail[@"Amount"] = @(0.00);
        discountDetail[@"Count"] = @(0);
        discountDetail[@"Sales"] = @(0.00);
        discountDetail[@"DiscountCategory"] = @(discountCategory);
    }
    return discountDetail;
}

-(NSString *)htmlGiftCardDetail:(NSMutableDictionary *)dataDict
{
    NSString *htmldata = @"";
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold; border-top:1px solid #90BCC3; border-bottom:1px solid #90BCC3;\" ><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Gift Card",@"Register",@"Total",@"Count"];
    if(self.emailFromViewController)
    {
        htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
    }
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"GC ADY",@"",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"TotalGCADY"]],@""];
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%ld</td></tr>",@"Load",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"LoadAmount"]],[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"TotalLoadAmount"]],(long)[[dataDict valueForKey:@"LoadCount"] integerValue]];
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%ld</td></tr>",@"Redeem",[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"RedeemAmount"]],[self.currencyFormatter stringFromNumber:[dataDict valueForKey:@"TotalRedeemAmount"]],(long)[[dataDict valueForKey:@"RedeemCount"] integerValue]];
    
    return htmldata;
}

-(NSString *)htmlForTenderTips:(NSMutableDictionary *)tenderRptCard
{
    NSString *htmldata = @"";
    if (self.tipSetting.boolValue)
    {
        if(tenderRptCard==nil)
        {
            if (self.emailFromViewController) {
                htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\">Tender Tips</td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
                htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold;\"><td>%@</td><td>%@</td><td>%@</td><td>%@</td></tr>",@"Type",@"Amount",@"Tips",@"Total"];
                htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
            }
            else
            {
                htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold;\" ><td width=\"162\">%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td></tr>",@"Type",@"Amount",@"Tips",@"Total"];
            }
        }
        else{
            double tenderAmount = [[tenderRptCard valueForKey:@"Amount"] doubleValue] + [[tenderRptCard valueForKey:@"TipsAmount"] doubleValue];
            NSNumber *numTenderAmount = @(tenderAmount);
            
            if(self.emailFromViewController)
            {
                htmldata = [htmldata stringByAppendingFormat:@"<tr><td>%@</td><td>%@</td><td>%@</td><td>%@</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"Amount"]]],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"TipsAmount"]]],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numTenderAmount]]];
            }
            else{
                htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"162\">%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td><td align=\"left\" width=\"162\" >%@</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"Amount"]]],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"TipsAmount"]]],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:numTenderAmount]]];
            }
        }
    }
    return htmldata;
}

-(NSString *)htmlBillTextGenericForItemwithDictionaryMain:(NSMutableDictionary *)tenderRptCard
{
    NSString *htmldata = @"";
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[tenderRptCard valueForKey:@"Amount"]]]];
    return htmldata;
}

- (NSNumber *)calculateNetFuelSales:(NSMutableDictionary *)dataDict{
    float netFuelSales = [dataDict [@"GrossFuelSales"] floatValue] - [dataDict [@"FuelRefund"] floatValue];
    NSNumber *numNetFuelSales = @(netFuelSales);
    return numNetFuelSales;
}

-(BOOL)isRcrGasActive:(NSArray *)array
{
    BOOL isRcrActive = FALSE;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@",@"RCRGAS"];
    NSArray *rcrArray = [array filteredArrayUsingPredicate:rcrActive];
    if (rcrArray.count > 0) {
        isRcrActive = TRUE;
    }
    return isRcrActive;
}

-(NSString *)getFuelSummery:(NSMutableDictionary *)dataDict withHtml:(NSString *)html{
    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND IsRelease == 0", (_rmsDbController.globalDict)[@"DeviceId"]];
    
    NSArray *activeModulesArray = [[_rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy];
    NSNumber *numNetFuelSales = [self calculateNetFuelSales:dataDict];
    NSString *fuelSummery = @"";
    if([self isRcrGasActive:activeModulesArray]){
        
        fuelSummery  = [NSString stringWithFormat:@"<tr style=\"color:rgb(0,115,170);\"><td width=\"216\">Net Fuel Sales:</td><td width=\"216\">%@</td></tr><tr><td height=\"20\"></td><td></td></tr>",[self.currencyFormatter stringFromNumber:numNetFuelSales]];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$FUELSUMMERY$$" withString:[NSString stringWithFormat:@"%@",fuelSummery]];
    
    return html;
}

-(NSString *)htmlForTips:(NSDictionary *)dict
{
    NSString *htmlForTips = @"";
    if (self.tipSetting.boolValue)
    {
        htmlForTips = [htmlForTips stringByAppendingFormat:@"<tr><td width=\"216\">Tips</td><td align=\"left\" width=\"216\" >%@</td></tr>",[self.currencyFormatter stringFromNumber:dict [@"TotalTips"]]];
    }
    return  htmlForTips;
}

-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSMutableDictionary *)tenderRptCard
{
    NSString *htmldata = @"";
    if(tenderRptCard==nil)
    {
        htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"font-weight:bold; border-top:1px solid #90BCC3; border-bottom:1px solid #90BCC3;\" ><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%@</td></tr>",@"Type",@"Amount",@"Count"];
        
        if(self.emailFromViewController)
        {
            htmldata = [htmldata stringByAppendingFormat:@"<tr style=\"color:#44546a;\"><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td><td style=\"border-bottom:1px solid #90BCC3;\"></td></tr>"];
        }
    }
    else{
        double fTenderAmount = [[tenderRptCard valueForKey:@"Amount"] doubleValue];
        if (self.tipSetting.boolValue)
        {
            fTenderAmount += [[tenderRptCard valueForKey:@"TipsAmount"] doubleValue];
        }
        NSNumber *fTenderAmountNum = @(fTenderAmount);
        if(self.emailFromViewController)
        {
            htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%ld</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:fTenderAmountNum]],(long)[[tenderRptCard valueForKey:@"Count"] integerValue]];
        }
        else{
            htmldata = [htmldata stringByAppendingFormat:@"<tr><td width=\"216\">%@</td><td align=\"left\" width=\"216\" >%@</td><td align=\"left\" width=\"216\" >%ld</td></tr>",[tenderRptCard valueForKey:@"Descriptions"],[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:fTenderAmountNum]],(long)[[tenderRptCard valueForKey:@"Count"] integerValue]];
        }
    }
    return htmldata;
}

-(NSString *)generateHTMLForShiftReportFromDictionary:(NSDictionary *)shiftReportDict
{
    self.shiftReport = [[ShiftReport alloc] initWithDictionary:shiftReportDict reportName:@"Shift Report" isTips:self.tipSetting.boolValue];
    NSString *htmlData = (self.shiftReport).generateHtml;
    
    return htmlData;
}

- (NSString *)createHTMLFormateForDisplayReportInWebView:(NSString *)html
{
    NSString *strReport = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD.TederType { width: 30%;padding-bottom:3px;} TD.TederTypeAmount { width: 40%;padding-bottom:3px;} TD.TederTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.TederTypeCount { width: 30%;padding-bottom:3px;} TD.CardType { width: 30%;padding-bottom:3px;} TD.CardTypeAmount { width: 40%;padding-bottom:3px;} TD.CardTypeAvgTicket { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CardTypeTypePer { width: 0%; overflow: hidden; display: none; text-indent: -9999;padding-bottom:3px;} TD.CardTypeCount { width: 30%;padding-bottom:3px;}</style>"];
    
    strReport =  [strReport stringByReplacingOccurrencesOfString:@"$$WIDTH$$" withString:@"width:286px"];
    strReport = [strReport stringByReplacingOccurrencesOfString:@"$$WIDTHCOMMONHEADER$$" withString:@"width:300px"];
    return strReport;
}

- (NSString *)createHTMLFormateForEmail:(NSString *)html
{
    NSString *strReportForEmail = [html stringByReplacingOccurrencesOfString:@"$$STYLE$$" withString:@"<style>TD{} TD{} TD.TederType { width: 20%;padding-bottom:3px;} TD.TederTypeAmount { width: 20%;padding-bottom:3px;} TD.TederTypeAvgTicket { width: 20%;padding-bottom:3px;} TD.TederTypePer { width: 20%;padding-bottom:3px;} TD.TederTypeCount { width: 20%;padding-bottom:3px;} TD.CardType { width: 20%;padding-bottom:3px;} TD.CardTypeAmount { width: 20%;padding-bottom:3px;} TD.CardTypeAvgTicket { width: 20%;padding-bottom:3px;} TD.CardTypeTypePer { width: 20%;padding-bottom:3px;} TD.CardTypeCount { width: 20%;padding-bottom:3px;} </style>"];
    strReportForEmail = [strReportForEmail stringByReplacingOccurrencesOfString:@"$$WIDTH$$" withString:@"width:450px"];
    strReportForEmail = [strReportForEmail stringByReplacingOccurrencesOfString:@"$$WIDTHCOMMONHEADER$$" withString:@"width:450px"];
    return strReportForEmail;
}

#pragma mark - User Selection

- (IBAction)selectUserClicked:(id)sender {
    SelectUserOptionVC *selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:self.userShiftDetailArray OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        [self setSelectionFor:self.btnUserSelection];
        [self.btnUserSelection setTitle:arrSelection[0] [@"UserName"] forState:UIControlStateNormal];
        if ([arrSelection[0] [@"UserName"] isEqualToString:@"All Users"])
        {
            [self shiftOpenCurrentDetail];
        }
        else if ([arrSelection[0] [@"UserName"] isEqualToString:@"Current User"]) {
            [self accessUserShiftDetails:ShiftDetailsForCurrentUser withUserDetails:nil];
        }
        else
        {
            [self accessUserShiftDetails:ShiftDetailsForCurrentUser withUserDetails:arrSelection[0]];
        }
    } SelectionColse:^(UIViewController *popUpVC) {
        [[popUpVC presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    }];
    selectUserOptionVC.strkey = @"UserName";
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

-(void)setSelectionFor:(UIButton *)button
{
    self.btnLastShiftCloseReport.selected = NO;
    self.btnUserSelection.selected = NO;
    if ([button isEqual:self.btnLastShiftCloseReport]) {
        [self.btnUserSelection setTitle:@"SELECT OPTIONS" forState:UIControlStateNormal];
    }
    button.selected = YES;
}

#pragma mark - Shift Open Close

- (IBAction)openShiftClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    self.shiftType = @"SHIFT OPEN";
    [self shiftOpenCloseProcess:@"SHIFT OPEN"];
}

- (IBAction)closeShiftClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    self.shiftType = @"SHIFT CLOSE";
    [self shiftOpenCloseProcess:@"SHIFT CLOSE"];
}

-(void)shiftOpenCloseProcess :(NSString *)shiftType
{
    self.shiftInOutPopOverVC = [[ShiftInOutPopOverVC alloc] initWithNibName:@"ShiftInOutPopOverVC" bundle:nil];
    self.shiftInOutPopOverVC.shiftInOutPopOverDelegate = self;
    self.shiftInOutPopOverVC.strType = shiftType;
    self.shiftInOutPopOverVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:self.shiftInOutPopOverVC animated:YES completion:nil];
}

#pragma mark - ShiftInOutPopOverVC delegate Methods

-(void)shiftIn_OutSuccessfullyDone
{
    [self.shiftInOutPopOverVC dismissViewControllerAnimated:YES completion:nil];
    NSString *msg = [NSString stringWithFormat:@"%@ successfully",self.shiftType];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Shift Open | Close" message:msg buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    
    if ([self.shiftType isEqualToString:@"SHIFT OPEN"])
    {
        [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInOutFlg"] = [NSNumber numberWithBool:1];
        [self shiftOpenCurrentDetail];
    }
    else  if ([self.shiftType isEqualToString:@"SHIFT CLOSE"])
    {
        [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"CashInOutFlg"] = [NSNumber numberWithBool:0];
        [self lastShiftCloseReportClicked:nil];
        if (self.userShiftDetailsVCDelegate) {
            [self.userShiftDetailsVCDelegate didShiftCloseSuccessfully];
        }
    }
    [self conFigureShiftStatus];
    self.shiftType = @"";
}

-(void)ShiftIn_OutProcessFailed
{
    
}

-(void)dismissShiftIn_OutController
{
    [self.shiftInOutPopOverVC dismissViewControllerAnimated:YES completion:nil];
    if (self.isShifInOutFromReport == FALSE)
    {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

#pragma mark - Shift History

- (IBAction)shiftHistoryClicked:(id)sender {
    [self.userShiftDetailsVCDelegate didHistoryButtonTapped];
}

#pragma mark - Shift Report Email

- (void)loadShiftReportEmail
{
    NSMutableDictionary *shiftDetailDict;
    NSMutableArray *discountArray;
    if (_shiftDetails == ShiftDetailsForHistory) {
        shiftDetailDict = [[[shiftHistoryDetailsArray.firstObject valueForKey:@"objShiftDetail"] firstObject] mutableCopy];
        discountArray = [[shiftHistoryDetailsArray.firstObject valueForKey:@"objShiftDiscount"] mutableCopy];
    }
    else {
        shiftDetailDict = [[[shiftReportArray.firstObject valueForKey:@"objShiftDetail"] firstObject] mutableCopy];
        discountArray = [[shiftReportArray.firstObject valueForKey:@"objShiftDiscount"] mutableCopy];
    }
    NSMutableArray *shiftTenderArray;
    if (_shiftDetails == ShiftDetailsForCurrentUser) {
        if (![[shiftDetailDict valueForKey:@"ShiftStatus"] isEqualToString:@"None"])
        {
            shiftTenderArray = [[shiftReportArray.firstObject valueForKey:@"objShiftTender"] mutableCopy];
        }
    }
    else if (_shiftDetails == ShiftDetailsForHistory){
        shiftTenderArray = [[shiftHistoryDetailsArray.firstObject valueForKey:@"objShiftTender"] mutableCopy];
    }
    else {
        shiftTenderArray = [[shiftReportArray.firstObject valueForKey:@"objShiftTender"] mutableCopy];
    }

    NSString *strShiftStatus = [NSString stringWithFormat:@"%@",[shiftDetailDict valueForKey:@"ShiftStatus"]];
    
    if (![strShiftStatus isEqualToString:@"None"])
    {
        [self.rmsDbController playButtonSound];
        
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        self.emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
     //   self.emailFromViewController = [[EmailFromViewController alloc]initWithNibName:@"EmailFromViewController" bundle:nil];
        
        NSDate *date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM dd, yyyy";
        NSString *currentDateTime = [formatter stringFromDate:date];
        
        NSString *strShiftNo = [NSString stringWithFormat:@"Shift #%@ - %@",[shiftDetailDict valueForKey:@"ShiftNo"],[shiftDetailDict valueForKey:@"ShiftStatus"]];
        NSString *strsubjectLine = [NSString stringWithFormat:@"%@   %@   %@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"],strShiftNo,currentDateTime];

        NSString *stringHtml=[self getHtmlStringFromData:shiftDetailDict :shiftTenderArray :discountArray];
        NSData *data = [stringHtml dataUsingEncoding:NSUTF8StringEncoding];
        self.emailFromViewController.emailFromViewControllerDelegate = self;
        self.emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
        (self.emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
        (self.emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
        (self.emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
        (self.emailFromViewController.dictParameter)[@"postfile"] = data;
        (self.emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
        
        [self.view addSubview:_emailFromViewController.view];
    }
    else {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Shift Open | Close" message:@"Please open a shift for shift report email." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)didCancelEmail
{
    [_emailFromViewController.view removeFromSuperview];
}


-(NSString *)getHtmlStringFromData:(NSMutableDictionary *)dictshiftDetailTemp :(NSMutableArray *)shiftTenderArrayTemp :(NSArray *)discountArrayTemp
{
    NSString *baseUrlPath = [[NSBundle mainBundle] pathForResource:@"EmailShiftReport" ofType:@"html"];
    shiftHtmlForEmail = [NSString stringWithContentsOfFile:baseUrlPath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    shiftHtmlForEmail = [shiftHtmlForEmail stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    shiftHtmlForEmail = [self htmlForShiftReport:shiftHtmlForEmail replaceWithData:dictshiftDetailTemp replaceWithTenderData:shiftTenderArrayTemp discountArray:discountArrayTemp];
    return [self fillDataForEmail:shiftHtmlForEmail withDictionary:dictshiftDetailTemp];
}


-(NSString *)fillDataForEmail:(NSString *)html withDictionary:(NSDictionary *)dictshiftDetailTemp {
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd,yyyy  h:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    strDateTime = [strDateTime stringByReplacingOccurrencesOfString:@"  " withString:@" @ "];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$SHIFT_EMAIL_DATE$$" withString:strDateTime];
    html = [html stringByReplacingOccurrencesOfString:@"$$BATCH_NO$$" withString:@"1"];
    html = [html stringByReplacingOccurrencesOfString:@"$$OPENING_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",@""]];
    
    NSString *strStrartDate = [self getStringFormate:[dictshiftDetailTemp valueForKey:@"Startdate"] fromFormate:@"MM/dd/yyyy" toFormate:@"MMM dd,yyyy"];
    NSString *strStrartTime = [self getStringFormate:[dictshiftDetailTemp valueForKey:@"StartTime"] fromFormate:@"HH:mm:ss" toFormate:@"hh:mm a"];
    NSString *stropeningDate= [NSString stringWithFormat:@"%@ $ %@",strStrartDate,strStrartTime];
    
    stropeningDate = [stropeningDate stringByReplacingOccurrencesOfString:@"$" withString:@"@"];
    
    NSString *strCloseDate = [self getStringFormate:[dictshiftDetailTemp valueForKey:@"CloseDate"] fromFormate:@"MM/dd/yyyy" toFormate:@"MMM dd,yyyy"];
    
    NSString *strCloseTime = [self getStringFormate:[dictshiftDetailTemp valueForKey:@"CloseTime"] fromFormate:@"HH:mm:ss" toFormate:@"hh:mm a"];
    
    NSString *strclosingdate= [NSString stringWithFormat:@"%@ $ %@",strCloseDate,strCloseTime];
    
    strclosingdate = [strclosingdate stringByReplacingOccurrencesOfString:@"$" withString:@"@"];
    
    
    NSString *strShiftStatus = [NSString stringWithFormat:@"%@",[dictshiftDetailTemp valueForKey:@"ShiftStatus"]];

    if ([strShiftStatus isEqualToString:@"ShiftClose"] )
    {
        html =[html stringByReplacingOccurrencesOfString:@"$$OPEN_DATE$$" withString:stropeningDate];
        html =[html stringByReplacingOccurrencesOfString:@"$$CLOSE_DATE$$" withString:strclosingdate];
    }
    else if([strShiftStatus isEqualToString:@"ShiftOpen"]) {
        html =[html stringByReplacingOccurrencesOfString:@"$$OPEN_DATE$$" withString:stropeningDate];
        html =[html stringByReplacingOccurrencesOfString:@"$$CLOSE_DATE$$" withString:@"-"];
    }
    else{
        html =[html stringByReplacingOccurrencesOfString:@"$$OPEN_DATE$$" withString:@"-"];
        html =[html stringByReplacingOccurrencesOfString:@"$$CLOSE_DATE$$" withString:@"-"];
    }
    html = [html stringByReplacingOccurrencesOfString:@"$$GROSS_SALE$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dictshiftDetailTemp valueForKey:@"DailySales"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL_TAX$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dictshiftDetailTemp valueForKey:@"CollectTax"]]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DISCOUNT_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:[dictshiftDetailTemp valueForKey:@"Discount"]]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$VOID$$" withString:[NSString stringWithFormat:@"%ld",(long)[[dictshiftDetailTemp valueForKey:@"AbortedTrans"] integerValue]]];
    
    NSNumber *checkcashamount = @0;
    html = [html stringByReplacingOccurrencesOfString:@"$$CHECK_CASH_AMOUNT$$" withString:[NSString stringWithFormat:@"%@",[self.currencyFormatter stringFromNumber:checkcashamount]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$BUSINESS_NAME$$" withString:[NSString stringWithFormat:@"Business Name - %@",(self.rmsDbController.globalDict)[@"BranchInfo"][@"BranchName"]]];
    return html;
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

#pragma mark - Delegate Methods
// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}
// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 49)] ;
    headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    UIImageView *imageView = [[UIImageView alloc] init];
    UILabel *headerTitle = [self configuredLabel:CGRectMake(38,7,200,30) textAlignment:NSTextAlignmentLeft fontSize:15];
    UILabel *headerTitleValue = [self configuredLabel:CGRectMake(434,5,250,30) textAlignment:NSTextAlignmentRight fontSize:15];
    imageView.frame = CGRectMake(0,7,30,30);
    imageView.image = [UIImage imageNamed:@"dr_clockicon.png"];
    headerTitle.text = @"HOURLY SALES";
    headerTitleValue.text = [self.rmsDbController.currencyFormatter stringFromNumber:[xReportBarChart.arrXRepHours valueForKeyPath:@"@sum.Amount"]];
    [headerView addSubview:imageView];
    [headerView addSubview:headerTitle];
    [headerView addSubview:headerTitleValue];
    UIView *sapertorView = [[UIView alloc] initWithFrame:CGRectMake(0, 48, tableView.bounds.size.width, 1)] ;
    sapertorView.backgroundColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0];
    [headerView addSubview:sapertorView];
    return headerView;
}

- (UILabel *)configuredLabel:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment fontSize:(CGFloat)size {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = textAlignment;
    label.font = [UIFont fontWithName:@"Lato-Bold" size:size];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportsGraphCustomeCell *reportsGraphCustomeCell = (ReportsGraphCustomeCell *)[tableView dequeueReusableCellWithIdentifier:@"ReportsGraphCustomeCell"];
    [[reportsGraphCustomeCell.contentView viewWithTag:20003] removeFromSuperview];
    [self showBarChartInView:reportsGraphCustomeCell.chartContainer usingArray:[shiftReportArray.firstObject valueForKey:@"objShiftHour"]];
    reportsGraphCustomeCell.contentView.backgroundColor = [UIColor clearColor];
    reportsGraphCustomeCell.backgroundColor = [UIColor clearColor];
    return reportsGraphCustomeCell;
}

- (void)showBarChartInView:(UIView *)view usingArray:(NSMutableArray *)array {
    xReportBarChart = [[XReportBarChart alloc] initWithNibName:@"XReportBarChart" bundle:nil];
    xReportBarChart.arrXRepHours = [array mutableCopy];
    int decm = 0;
    if ((xReportBarChart.arrXRepHours).count==0) {
        [xReportBarChart.arrXRepHours addObject:@{
                                                  @"Amount":@"0.00",
                                                  @"Count":@(decm),
                                                  @"Hours":@"0.00",
                                                  }];
    }
    xReportBarChart.view.backgroundColor = [UIColor clearColor];
    [self addChart:xReportBarChart intoContainer:view tag:20003];
}

- (void)addChart:(UIViewController *)chart intoContainer:(UIView *)container tag:(int)tag {
    [[container viewWithTag:tag] removeFromSuperview];
    chart.view.tag = tag;
    chart.view.frame = container.bounds;
    chart.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [container addSubview:chart.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"UserShiftDetailsVCToWebViewSegue"]) {
        self.reportWebVC = (ReportWebVC*) segue.destinationViewController;
    }
}

@end
