//
//  RootViewController.m
//  tableStracture
//
//  Created by Triforce consultancy on 26/03/12.
//  Copyright 2012 Triforce consultancy . All rights reserved.
//

#import "ClockInDetailsView.h"
#import "RmsDbController.h"
#import "ClockInCustomCell.h"
#import "CashinOutViewController.h"
#import "CKOCalendarViewController.h"
#import "CL_CustomerSearchVC.h"
#import "ExportPopupVC.h"
#import "EmailFromViewController.h"
#import "ClockInOutPrint.h"
#import "SelectUserOptionVC.h"
#import "CLIOTimePickerVC.h"

@interface ClockInDetailsView () <UIPopoverControllerDelegate,ExportPopupVCDelegate,CL_CustomerSearchVCDelegate,EmailFromViewControllerDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,CLIOTimePickerVCDelegate>
{
    NSString *type;
    NSString *selectedUserForClockInOut;
    NSString *selectedUserForClockInOutHistory;
    NSNumber *selectedUserIdForClockInOut;
    NSNumber *selectedUserIdForClockInOutHistory;
    NSDictionary *selectedClockInOutDictionary;
    NSDictionary *selectedClockInOutHistoryDictionary;
    NSArray *array_port;
    NSDate *startDateFromFilter;
    NSDate *endDateFromFilter;
    NSString *customTypeFromFilter;
    EmailFromViewController *emailFromViewController;
    CLIOTimePickerVC * cLIOTimePickerVC;
    TabOption selectedTabOption;
    UIView *pickerBgView;
    BOOL isClockInOutActionAllowed;
    BOOL isClockInOutDetailsUpdated;
    BOOL isClockInOutHistoryDetailsUpdated;
    BOOL needToReloadClockInOutDetails;
    BOOL needToReloadClockInOutHistoryDetails;
    BOOL isNewClockInEntry;
    BOOL isVoid;
}

@property (nonatomic, weak) IBOutlet UIView *clockInOutView;
@property (nonatomic, weak) IBOutlet UIView *historyView;

@property (nonatomic, weak) IBOutlet UILabel *lblTotalHoursCount;
@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UILabel *lblFilterDate;
@property (nonatomic, weak) IBOutlet UILabel *lblClockInOutStatus;

@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnClockIn;
@property (nonatomic, weak) IBOutlet UIButton *btnClockOut;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnClockInOutTab;
@property (nonatomic, weak) IBOutlet UIButton *btnHistoryTab;
@property (nonatomic, weak) IBOutlet UIButton *btnReset;
@property (nonatomic, weak) IBOutlet UIButton *btnDateFilter;
@property (nonatomic, weak) IBOutlet UIButton *btnPdfAndEmail;
@property (nonatomic, weak) IBOutlet UIButton *btnUserSelection;

@property (nonatomic, weak) IBOutlet UITableView *tblClockInOut;
@property (nonatomic, weak) IBOutlet UITableView *tblHistory;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *clockInOutDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *clockInOutWC;
@property (nonatomic, strong) RapidWebServiceConnection *clockInOutResetWC;
@property (nonatomic, strong) RapidWebServiceConnection *clockInOutHistoryWC;
@property (nonatomic, strong) RapidWebServiceConnection *updateClockInOutDetailWC;

@property (nonatomic, strong) IntercomHandler *intercomHandler;
@property (nonatomic, strong) CL_CustomerSearchVC *cL_CustomerSearchVC;
@property (nonatomic, strong) CL_CustomerSearchData *cl_CustomerSearchData;
@property (nonatomic, strong) NDHTMLtoPDF *pdfCreator;

@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, strong) NSString *strStartDateForCLIO;
@property (nonatomic, strong) NSString *strEndDateForCLIO;
@property (nonatomic, strong) NSString *strStartDateForCLIOHistory;
@property (nonatomic, strong) NSString *strEndDateForCLIOHistory;
@property (nonatomic, strong) NSString *strClockInOutReceiptHtml;

@property (nonatomic, strong) NSMutableArray *clockInOutHistoryArray;
@property (nonatomic, strong) NSMutableArray *clockInResponseArray;
@property (nonatomic, strong) NSMutableArray *clockInOutHistoryDisplayArray;
@property (nonatomic, strong) NSMutableArray *clockInOutDisplayArray;
@property (nonatomic, strong) NSMutableArray *userDetailArray;

@property (nonatomic, strong) NSIndexPath *indPathForCurrentCLIO;
@property (nonatomic, strong) NSIndexPath *indPathForCLIOHistory;

@property (nonatomic, strong) UIPopoverController *calendarPopOverController;
@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (assign)  BOOL isClockInOut;

@end

@implementation ClockInDetailsView


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.clockInOutDetailWC = [[RapidWebServiceConnection alloc] init];
    self.clockInOutWC = [[RapidWebServiceConnection alloc] init];
    self.clockInOutResetWC = [[RapidWebServiceConnection alloc] init];
    self.clockInOutHistoryWC = [[RapidWebServiceConnection alloc] init];
    self.cl_CustomerSearchData = [[CL_CustomerSearchData alloc] init];
    self.clockInResponseArray = [[NSMutableArray alloc]init];
    self.clockInOutHistoryArray = [[NSMutableArray alloc]init];
    self.indPathForCurrentCLIO = [NSIndexPath indexPathForRow:-1 inSection:-1];
    self.indPathForCLIOHistory = [NSIndexPath indexPathForRow:-1 inSection:-1];
    self.btnDateFilter.selected = NO;
    self.isClockInOut = FALSE;
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedUserForClockInOut = @"SELECT OPTIONS";
    selectedUserForClockInOutHistory = @"SELECT OPTIONS";
    isClockInOutActionAllowed = [UserRights hasRights:UserRightClockInOutAction];
    if (isClockInOutActionAllowed) {
        self.btnUserSelection.hidden = false;
    }
    else {
        self.btnUserSelection.hidden = true;
    }
    isClockInOutDetailsUpdated = false;
    isClockInOutHistoryDetailsUpdated = false;
    needToReloadClockInOutDetails = false;
    needToReloadClockInOutHistoryDetails = false;
    isNewClockInEntry =false;
    
    [self getColckInData];
    [self setClockInDisplay];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
   
    _lblUserName.text = [self.rmsDbController userNameOfApp];
    
    self.intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"dr_helpbtn.png" selectedImage:@"dr_helpbtnselected.png" withViewController:self];
    [self clockInOutTabClicked:nil];
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

#pragma mark - Tabs

-(IBAction)clockInOutTabClicked:(id)sender {
    [self setSeletedTabOption:TabOptionClockInOut];
    if (needToReloadClockInOutDetails) {
        [self proceessAfterUpdateClockInOutDetail];
        needToReloadClockInOutHistoryDetails = false;
    }
    if ([selectedUserForClockInOut isEqualToString:@"SELECT OPTIONS"]) {
        [self setDefaultTitleToUserSelection:selectedUserForClockInOut];
    }
    else {
        [self setTitleToUserSelection:selectedUserForClockInOut];
    }
    [self setHoursCountFromArray:self.clockInOutDisplayArray];
    if (self.clockInResponseArray && self.clockInResponseArray.count > 0) {
        [self setUserDetailsForClockInOutTab];
    }
    self.lblFilterDate.hidden = YES;
    self.btnDateFilter.enabled = NO;
    [self removeDateFilterView];
    [self configuareTabView:self.clockInOutView withButton:self.btnClockInOutTab];
    if (_btnClockIn.enabled) {
        if (self.clockInOutDisplayArray && self.clockInOutDisplayArray.count > 0) {
            self.btnReset.enabled = YES;
        }
        else {
            self.btnReset.enabled = NO;
        }
    }
    else {
        self.btnReset.enabled = NO;
    }
}

-(IBAction)historyTabClicked:(id)sender {
    [self setSeletedTabOption:TabOptionClockInOutHistory];
    if (needToReloadClockInOutHistoryDetails && ![selectedUserForClockInOutHistory isEqualToString:@"SELECT OPTIONS"]) {
        [self proceessAfterUpdateClockInOutDetail];
        needToReloadClockInOutDetails = false;
    }
    if ([selectedUserForClockInOutHistory isEqualToString:@"SELECT OPTIONS"]) {
        [self setDefaultTitleToUserSelection:selectedUserForClockInOutHistory];
    }
    else {
        [self setTitleToUserSelection:selectedUserForClockInOutHistory];
    }
    [self setHoursCountFromArray:self.clockInOutHistoryDisplayArray];
    if (self.clockInOutHistoryArray && self.clockInOutHistoryArray.count > 0) {
        [self setUserDetailsForHistoryTab];
    }
    self.lblFilterDate.hidden = NO;
    self.btnDateFilter.enabled = YES;
    self.btnReset.enabled = NO;
    [self configuareTabView:self.historyView withButton:self.btnHistoryTab];
}

- (void)setSeletedTabOption:(TabOption)tabOption {
    selectedTabOption = tabOption;
}

#pragma mark - Footer Options

- (IBAction)printClockInOutClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    [self printReport:portName portSettings:portSettings isHTML:false];
}

+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}

- (void)SetPortInfo
{
    NSString *localPortName;
    NSString *printerSelection = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    if(printerSelection.length > 0)
    {
        if ([printerSelection isEqualToString:@"Bluetooth"])
        {
            localPortName=@"BT:Star Micronics";
        }
        else if([printerSelection isEqualToString:@"TCP"]){
            NSString *tcp = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"];
            localPortName = tcp;
        }
    }
    else{
        localPortName=@"BT:Star Micronics";
    }
    [ClockInDetailsView setPortName:localPortName];
    [ClockInDetailsView setPortSettings:array_port[0]];
}

- (void)printReport:(NSString *)portName portSettings:(NSString *)portSettings isHTML:(BOOL)isHtml
{
    NSString *clockInOutUserName = @"";
    NSMutableArray *printingArray;
    NSString *startDate;
    NSString *endDate;
    if (self.btnClockInOutTab.isSelected) {
        printingArray = [self.clockInOutDisplayArray copy];
        startDate = [self.strStartDateForCLIO copy];
        endDate = [self.strEndDateForCLIO copy];
        clockInOutUserName = selectedUserForClockInOut;
    }
    else {
        printingArray = [self.clockInOutHistoryDisplayArray copy];
        startDate = [self.strStartDateForCLIOHistory copy];
        endDate = [self.strEndDateForCLIOHistory copy];
        clockInOutUserName = selectedUserForClockInOutHistory;
    }
    if (printingArray && printingArray.count > 0) {
        ClockInOutPrint *clockInOutPrint = [[ClockInOutPrint alloc] initWithPortName:portName portSetting:portSettings printData:printingArray startDate:startDate endDate:endDate clockInOutUser:clockInOutUserName];
        if (isHtml) {
            self.strClockInOutReceiptHtml = [self getHtmlFromFile];
            self.strClockInOutReceiptHtml = [clockInOutPrint generateHtmlForClockInOutDetails:self.strClockInOutReceiptHtml];
            NSData *data = [self.strClockInOutReceiptHtml dataUsingEncoding:NSUTF8StringEncoding];
            [self writeDataOnCacheDirectory:data];
        }
        else {
            [clockInOutPrint printClockInOutDetailsWithDelegate:self];
        }
    }

    [_activityIndicator hideActivityIndicator];
}

-(void)writeDataOnCacheDirectory:(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.sourcePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.sourcePath error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.sourcePath = [documentsDirectory stringByAppendingPathComponent:@"Clockinoutreceipt.html"];
    [data writeToFile:self.sourcePath atomically:YES];
}

#pragma mark - Printer Function Delegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    NSString *retryMessage = @"Failed to Clock-In/Out print receipt. Would you like to retry.?";
    [self displayClockInOutPrintRetryAlert:retryMessage];
}

-(void)displayClockInOutPrintRetryAlert:(NSString *)message
{
    ClockInDetailsView * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference printClockInOutClicked:nil];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (IBAction)emailClockInOutClicked:(id)sender {
    ExportPopupVC *exportPopupVC = [[UIStoryboard storyboardWithName:@"Reporting" bundle:NULL] instantiateViewControllerWithIdentifier:@"ExportPopupVC_sid"];
    exportPopupVC.delegate = self;
    exportPopupVC.isHideArrow = true;
    [exportPopupVC presentViewControllerForviewConteroller:self sourceView:self.btnPdfAndEmail ArrowDirection:UIPopoverArrowDirectionDown];
    //    [self.userShiftDetailsVC loadShiftReportEmail];
}

#pragma mark - ExportPopupVCDelegate

-(void)didSelectExportType:(ExportType)exportType withTag:(NSInteger)tag {
    if (self.btnClockInOutTab.isSelected){
        if (self.clockInOutDisplayArray && self.clockInOutDisplayArray.count > 0) {
            [self printReport:nil portSettings:nil isHTML:YES];
        }
        else {
            return;
        }
    }
    else {
        if (self.clockInOutHistoryDisplayArray && self.clockInOutHistoryDisplayArray.count > 0) {
            [self printReport:nil portSettings:nil isHTML:YES];
        }
        else {
            return;
        }
    }

    switch (exportType) {
        case ExportTypeEmail:
            [self emailButtonClicked:nil];
            break;
        case ExportTypePrieview:
            [self previewButtonClicked:nil];
            break;
            
        default:
            break;
    }
}

- (IBAction)emailButtonClicked:(id)sender {
    [self emailForReport];
}

- (void)emailForReport
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSString *currentDateTime = [formatter stringFromDate:date];
    NSString *reportPrintName = @"Clock-In/Out";
    NSString *strsubjectLine = [NSString stringWithFormat:@"%@  %@  %@",[self.rmsDbController.globalDict valueForKey:@"RegisterName"],currentDateTime,reportPrintName];
    NSData *htmlData = [NSData dataWithContentsOfFile:self.sourcePath];
    NSString *stringHtml = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    emailFromViewController.emailFromViewControllerDelegate = self;
    emailFromViewController.dictParameter = [[NSMutableDictionary alloc]init];
    (emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
    (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (emailFromViewController.dictParameter)[@"postfile"] = htmlData;
    (emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
    
    [self.view addSubview:emailFromViewController.view];
}

-(void)didCancelEmail
{
    [emailFromViewController.view removeFromSuperview];
}

- (NSString *)getHtmlFromFile {
    NSString *htmlString = [[NSBundle mainBundle] pathForResource:@"Clockinoutreceipt" ofType:@"html"];
    htmlString = [NSString stringWithContentsOfFile:htmlString encoding:NSUTF8StringEncoding error:nil];
    return htmlString;
}

- (IBAction)previewButtonClicked:(id)sender
{
    self.pdfCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.sourcePath]
                                         pathForPDF:(@"~/Documents/previewreceiptreport.pdf").stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}

#pragma mark - NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
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

#pragma mark - UIDocumentInteractionControllerDelegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}

- (IBAction)addButtonClicked:(id)sender {
    NSDictionary *clockInOutTimeDictionary = [self clockInOutTimeDictionaryForAddNewClockInOutEntry];
    [self openEditClockInOutTimePopUp:clockInOutTimeDictionary isNewEntry:true];
}

#pragma mark - User Selection

- (IBAction)selectUserClicked:(id)sender {
    if (selectedTabOption == TabOptionClockInOutHistory) {
        if (!self.clockInOutHistoryArray || self.clockInOutHistoryArray.count == 0) {
            return;
        }
    }
    SelectUserOptionVC *selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:self.userDetailArray OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        if ([arrSelection[0] [@"UserName"] isEqualToString:@"All Users"])
        {
            [self displayClockInOutDetailsAsPerUserSelection:ClockInOutDetailsForAllUsers userDetails:nil];
        }
        else if ([arrSelection[0] [@"UserName"] isEqualToString:@"Current User"]) {
            [self displayClockInOutDetailsAsPerUserSelection:ClockInOutDetailsForCurrentUser userDetails:nil];
        }
        else
        {
            if (selectedTabOption == TabOptionClockInOut) {
                selectedUserIdForClockInOut = [[arrSelection firstObject] [@"UserId"] copy];
            }
            else {
                selectedUserIdForClockInOutHistory = [[arrSelection firstObject] [@"UserId"] copy];
            }
            [self displayClockInOutDetailsAsPerUserSelection:ClockInOutDetailsForOtherUser userDetails:arrSelection[0]];
        }
    } SelectionColse:^(UIViewController *popUpVC) {
        [[popUpVC presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    }];
    selectUserOptionVC.strkey = @"UserName";
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

- (void)setTitleToUserSelection:(NSString *)title {
    [self setUserSelectionSelected];
    [self.btnUserSelection setTitle:title forState:UIControlStateNormal];
}

- (void)setDefaultTitleToUserSelection:(NSString *)title {
    [self setUserSelectionDeselected];
    [self.btnUserSelection setTitle:title forState:UIControlStateNormal];
}

-(void)setUserSelectionSelected
{
    self.btnUserSelection.selected = YES;
}

-(void)setUserSelectionDeselected
{
    self.btnUserSelection.selected = NO;
}

- (void)displayClockInOutDetailsAsPerUserSelection:(ClockInOutDetails)clockInOutDetails userDetails:(NSDictionary *)userDetailsDicationary {
    
    switch (clockInOutDetails) {
        case ClockInOutDetailsForAllUsers:
            [self displayClockInOutDataForAllUser];
            break;
        case ClockInOutDetailsForCurrentUser:
        {
            [self displayCurrentUserData];
        }
            break;
        case ClockInOutDetailsForOtherUser:
        {
            [self dispalyDataForUser:[userDetailsDicationary valueForKey:@"UserId"] clockInOutDetailsFor:ClockInOutDetailsForOtherUser];
        }
            break;

        default:
            break;
    }
}

- (NSPredicate *)userPredicate:(NSNumber *)userId {
    return [NSPredicate predicateWithFormat:@"UserId == %@",userId];
}

- (void)displayClockInOutDataForAllUser {
    if (selectedTabOption == TabOptionClockInOut) {
        selectedUserForClockInOut = @"All Users";
        [self setTitleToUserSelection:selectedUserForClockInOut];
        self.clockInOutDisplayArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in self.clockInResponseArray) {
            NSArray *clockInRecords = dictionary[@"lstClockInRecords"];
            for (NSDictionary *clockInRecordsDictionary in clockInRecords) {
                [self.clockInOutDisplayArray addObject:clockInRecordsDictionary];
            }
        }
        [self setStartAndEndDate:self.clockInOutDisplayArray];
        [self updateUIForClockInOutTab];
    }
    else {
        selectedUserForClockInOutHistory = @"All Users";
        [self setTitleToUserSelection:selectedUserForClockInOutHistory];
        self.clockInOutHistoryDisplayArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in self.clockInOutHistoryArray) {
            NSArray *clockInRecords = dictionary[@"lstClockInRecords"];
            for (NSDictionary *clockInRecordsDictionary in clockInRecords) {
                [self.clockInOutHistoryDisplayArray addObject:clockInRecordsDictionary];
            }
        }
        [self updateUIForClockInOutHistoryTab];
    }
}

- (void)displayClockInOutDataUsingPredicate:(NSPredicate *)predicate clockInOutDetailsFor:(ClockInOutDetails)clockInOutDetails {
    if (selectedTabOption == TabOptionClockInOut) {
        NSArray *clockInDataArray = [self.clockInResponseArray filteredArrayUsingPredicate:predicate];
        if (!self.clockInResponseArray || self.clockInResponseArray.count == 0) {
            selectedUserForClockInOut = @"SELECT OPTIONS";
            [self setDefaultTitleToUserSelection:selectedUserForClockInOutHistory];
        }
        else {
            if (clockInOutDetails == ClockInOutDetailsForCurrentUser) {
                selectedUserForClockInOut = @"Current User";
            }
            else {
                selectedUserForClockInOut = [[clockInDataArray firstObject] valueForKey:@"UserName"];
            }
            [self setTitleToUserSelection:selectedUserForClockInOut];
        }
        self.clockInOutDisplayArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in clockInDataArray) {
            NSArray *clockInRecords = dictionary[@"lstClockInRecords"];
            for (NSDictionary *clockInRecordsDictionary in clockInRecords) {
                [self.clockInOutDisplayArray addObject:clockInRecordsDictionary];
            }
        }
        [self setStartAndEndDate:self.clockInOutDisplayArray];
        [self updateUIForClockInOutTab];
    }
    else {
        NSArray *clockInDataArray = [self.clockInOutHistoryArray filteredArrayUsingPredicate:predicate];
        if (!self.clockInOutHistoryArray || self.clockInOutHistoryArray.count == 0) {
            selectedUserForClockInOutHistory = @"SELECT OPTIONS";
            [self setDefaultTitleToUserSelection:selectedUserForClockInOutHistory];
        }
        else {
            if (clockInOutDetails == ClockInOutDetailsForCurrentUser) {
                selectedUserForClockInOutHistory = @"Current User";
            }
            else {
                selectedUserForClockInOutHistory = [[clockInDataArray firstObject] valueForKey:@"UserName"];
            }
            [self setTitleToUserSelection:selectedUserForClockInOutHistory];
        }
        self.clockInOutHistoryDisplayArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in clockInDataArray) {
            NSArray *clockInRecords = dictionary[@"lstClockInRecords"];
            for (NSDictionary *clockInRecordsDictionary in clockInRecords) {
                [self.clockInOutHistoryDisplayArray addObject:clockInRecordsDictionary];
            }
        }
        [self updateUIForClockInOutHistoryTab];
    }
}

#pragma mark - Filter

-(IBAction)dateFilterClicked:(id)sender {
    self.btnDateFilter.selected = YES;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomerLoyalty" bundle:nil];
    self.cL_CustomerSearchVC = [storyBoard instantiateViewControllerWithIdentifier:@"CL_CustomerSearchVC"];
    self.cL_CustomerSearchVC.cl_CustomerSearchVCDelegate = self;
    self.cL_CustomerSearchVC.view.frame = CGRectMake(642 , 124 ,365, 380) ;
    self.cL_CustomerSearchVC.view.layer.borderWidth = 1;
    self.cL_CustomerSearchVC.view.layer.cornerRadius = 10.0;
    self.cL_CustomerSearchVC.view.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.3].CGColor;
    self.cL_CustomerSearchVC.cl_CustomerSearchData = self.cl_CustomerSearchData;
    [self addChildViewController:self.cL_CustomerSearchVC];
    [self.view addSubview:self.cL_CustomerSearchVC.view];
}

#pragma mark - CL_CustomerSearchVCDelegate

-(void)didUpdateCustomerWithStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate withSearchCustomType:(NSString *)customType {
    startDateFromFilter = [startDate copy];
    endDateFromFilter = [endDate copy];
    customTypeFromFilter = [customType copy];
    [self clockInHistoryForStartDate:startDate withEndDate:endDate withSearchCustomType:customType];
}

- (void)clockInHistoryForStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate withSearchCustomType:(NSString *)customType {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:customType forKey:@"TimeDuration"];
    [param setValue:[self stringFromDate:startDate] forKey:@"FromDate"];
    [param setValue:[self stringFromDate:endDate] forKey:@"ToDate"];
    [param setValue:strDateTime forKey:@"LocalDateTime"];
    [param setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    if (isClockInOutActionAllowed) {
        param[@"IsAllRight"] = @"1";
    }
    else {
        param[@"IsAllRight"] = @"0";
    }
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self clockInOutHistoryResponse:response error:error];
        });
    };
    self.clockInOutHistoryWC = [self.clockInOutHistoryWC initWithRequest:KURL actionName:WSM_CLOCK_IN_OUT_DATE_WISE params:param completionHandler:completionHandler];
}

- (void)clockInOutHistoryResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self removeDateFilterView];
                response = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.clockInOutHistoryArray = [response mutableCopy];
                if (needToReloadClockInOutHistoryDetails) {
                    needToReloadClockInOutHistoryDetails = false;
                }
                [self displayClockInOutDetails];
                if (self.clockInOutHistoryArray && self.clockInOutHistoryArray.count > 0) {
                    [self setUserDetailsForHistoryTab];
                }
                NSString *filterDate = [self.cl_CustomerSearchData fromDateToStartdateStringFor:self.cl_CustomerSearchData.cl_SelectedSerachType];
                self.lblFilterDate.text = [[NSString stringWithFormat:@"RESULT FOR %@",filterDate] uppercaseString];
                NSArray *datesArray = [filterDate componentsSeparatedByString:@"-"];
                if (datesArray && datesArray > 0) {
                    self.strStartDateForCLIOHistory = [self getCovertedTime:[[datesArray firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] currentFormate:@"dd MMMM yyyy" convertInto:@"MMMM dd, yyyy"];
                    self.strEndDateForCLIOHistory = [self getCovertedTime:[[datesArray lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] currentFormate:@"dd MMMM yyyy" convertInto:@"MMMM dd, yyyy"];
                }
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

- (NSString *)getCovertedTime:(NSString *)time currentFormate:(NSString *)currentFormate convertInto:(NSString *)convertedFormate {
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = currentFormate;
    NSDate *printDate = [timeFormatter dateFromString:time];
    timeFormatter.dateFormat = convertedFormate;
    NSString *printTime = [timeFormatter stringFromDate:printDate];
    return printTime;
}

-(NSString *)stringFromDate:(NSDate*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDate = [formatter stringFromDate:date];
    
    return strDate;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view!=self.cL_CustomerSearchVC.view) {
        [self removeDateFilterView];
    }
}

-(void)removeDateFilterView {
    if (self.cL_CustomerSearchVC.view) {
        self.btnDateFilter.selected = NO;
        [self.cL_CustomerSearchVC.view removeFromSuperview];
        [self.cL_CustomerSearchVC removeFromParentViewController];
        self.cL_CustomerSearchVC.view = nil;
    }
}

-(void)configuareTabView:(UIView *)view withButton:(UIButton *)button{
    self.btnClockInOutTab.selected = NO;
    self.btnHistoryTab.selected = NO;
    self.clockInOutView.hidden = YES;
    self.historyView.hidden = YES;
    view.hidden = NO;
    button.selected = YES;
}

-(void)setClockInDisplay
{
    if ([[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"ClockInRequire"] boolValue] == TRUE)
    {
        self.lblClockInOutStatus.text = @"You are Clocked out";
        _btnClockIn.enabled = YES;
        _btnClockOut.enabled = NO;
        [_btnClockOut setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnClockIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        self.lblClockInOutStatus.text = @"You are Clocked in";
        _btnClockIn.enabled = NO;
        _btnClockOut.enabled = YES;
        [_btnClockOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnClockIn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void) getColckInData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
	NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
	param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];

    param[@"DateTime"] = [self getLocaleDate];

    if (isClockInOutActionAllowed) {
        param[@"IsAllRight"] = @"1";
    }
    else {
        param[@"IsAllRight"] = @"0";
    }
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self clockInOutDetailResponse:response error:error];
        });
    };
    
    self.clockInOutDetailWC = [self.clockInOutDetailWC initWithRequest:KURL actionName:WSM_CLOCK_IN_OUT_DETAIL params:param completionHandler:completionHandler];
}

- (void)clockInOutDetailResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if([[response valueForKey:@"IsError"] intValue] == 0)
            {
                response = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.clockInResponseArray = [response mutableCopy];
                [self displayClockInOutDetails];
                if (self.clockInResponseArray && self.clockInResponseArray.count > 0) {
                    [self setUserDetailsForClockInOutTab];
                }
                [self setStartAndEndDate:self.clockInOutDisplayArray];
                [self setClockInDisplay];
                [self clockInOutTabClicked:nil];
                return;
            }
        }
    }
    [self updateUIForClockInOutTab];
}

- (void)displayClockInOutDetails {
    if (selectedTabOption == TabOptionClockInOut) {
        if (isClockInOutDetailsUpdated) {
            isClockInOutDetailsUpdated = false;
            if ([selectedUserForClockInOut isEqualToString:@"SELECT OPTIONS"] || [selectedUserForClockInOut isEqualToString:@"Current User"]) {
                [self displayCurrentUserData];
            }
            else if([selectedUserForClockInOut isEqualToString:@"All Users"]) {
                [self displayClockInOutDetailsAsPerUserSelection:ClockInOutDetailsForAllUsers userDetails:nil];
            }
            else {
                [self dispalyDataForUser:selectedUserIdForClockInOut clockInOutDetailsFor:ClockInOutDetailsForOtherUser];
            }
        }
        else {
            [self displayCurrentUserData];
        }
    }
    else {
        if (isClockInOutHistoryDetailsUpdated) {
            isClockInOutHistoryDetailsUpdated = false;
            if ([selectedUserForClockInOutHistory isEqualToString:@"SELECT OPTIONS"] || [selectedUserForClockInOutHistory isEqualToString:@"Current User"]) {
                [self displayCurrentUserData];
            }
            else if([selectedUserForClockInOutHistory isEqualToString:@"All Users"]) {
                [self displayClockInOutDetailsAsPerUserSelection:ClockInOutDetailsForAllUsers userDetails:nil];
            }
            else {
                [self dispalyDataForUser:selectedUserIdForClockInOutHistory clockInOutDetailsFor:ClockInOutDetailsForOtherUser];
            }
        }
        else {
            [self displayCurrentUserData];
        }
    }
}

- (void)displayCurrentUserData {
    NSNumber *userId = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    [self dispalyDataForUser:userId clockInOutDetailsFor:ClockInOutDetailsForCurrentUser];
}

- (void)dispalyDataForUser:(NSNumber *)userId clockInOutDetailsFor:(ClockInOutDetails)clockInOutDetails {
    NSPredicate *currentUserPredicate = [self userPredicate:userId];
    [self displayClockInOutDataUsingPredicate:currentUserPredicate clockInOutDetailsFor:clockInOutDetails];
}

- (void)updateUIForClockInOutTab {
    [self setHoursCountFromArray:self.clockInOutDisplayArray];
    self.indPathForCurrentCLIO = [NSIndexPath indexPathForRow:-1 inSection:-1];
    [self.tblClockInOut reloadData];
}

- (void)updateUIForClockInOutHistoryTab {
    [self setHoursCountFromArray:self.clockInOutHistoryDisplayArray];
    self.indPathForCLIOHistory = [NSIndexPath indexPathForRow:-1 inSection:-1];
    [self.tblHistory reloadData];
}

- (void)setUserDetailsForClockInOutTab {
    self.userDetailArray = [[self getUserDetails:self.clockInResponseArray] mutableCopy];
}

- (void)setUserDetailsForHistoryTab {
    self.userDetailArray = [[self getUserDetails:self.clockInOutHistoryArray] mutableCopy];
}

- (NSMutableArray *)getUserDetails:(NSArray *)array {
    NSMutableArray *userDetails = [[NSMutableArray alloc] init];
    for (NSDictionary *dicationary in array) {
        NSMutableDictionary *userDetailsDictionary = [[NSMutableDictionary alloc] init];
        userDetailsDictionary [@"UserName"] = dicationary [@"UserName"];
        userDetailsDictionary [@"UserId"] = dicationary [@"UserId"];
        [userDetails addObject:userDetailsDictionary];
    }
    NSMutableDictionary *dictNone = [self addExtraUser:@"Current User"];
    [userDetails insertObject:dictNone atIndex:(userDetails).count];
    NSMutableDictionary *dictAllUsers = [self addExtraUser:@"All Users"];
    [userDetails insertObject:dictAllUsers atIndex:0];
    return userDetails;
}

- (NSMutableDictionary *)addExtraUser:(NSString *)extraUser {
    NSMutableDictionary *dictNone = [[NSMutableDictionary alloc] init];
    dictNone[@"UserName"] = extraUser;
    return dictNone;
}


- (void)setStartAndEndDate:(NSArray *)array {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSArray *sortedData = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *dateString1 = obj1[@"Date"];
        NSString *dateString2 = obj2[@"Date"];
        
        NSDate *date1 = [dateFormatter dateFromString:dateString1];
        NSDate *date2 = [dateFormatter dateFromString:dateString2];
        
        return [date1 compare:date2];
        
    }];
    self.strStartDateForCLIO = [sortedData firstObject][@"Date"];
    self.strEndDateForCLIO = [sortedData lastObject][@"Date"];
}

- (void)setHoursCountFromArray:(NSMutableArray *)dataArray
{
    if (dataArray && dataArray.count > 0) {
        NSInteger totalSeconds = [[dataArray valueForKeyPath:@"@sum.WorkingTime"] integerValue];
        NSString *totalTime = [self stringFromTimeInterval:totalSeconds];
        _lblTotalHoursCount.text = totalTime;
    }
    else {
        _lblTotalHoursCount.text = @"00:00:00";
    }
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblClockInOut) {
        return self.clockInOutDisplayArray.count;
    }
    return self.clockInOutHistoryDisplayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if(tableView == self.tblClockInOut)
    {
        cell = [self configureCell:self.tblClockInOut forRowAtIndexPath:indexPath usingArray:self.clockInOutDisplayArray usingIdentifier:@"ClockInCustomCell"];
    }
    else if (tableView == self.tblHistory)
    {
        cell = [self configureCell:self.tblHistory forRowAtIndexPath:indexPath usingArray:self.clockInOutHistoryDisplayArray usingIdentifier:@"ClockInOutHistoryCustomCell"];
    }
    return cell;
}

- (UITableViewCell *)configureCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath usingArray:(NSMutableArray *)array usingIdentifier:(NSString *)identifier
{
    ClockInCustomCell *clockInCustomCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(array.count > 0)
    {
        clockInCustomCell.clockInDay.text = [(array)[indexPath.row] valueForKey:@"Day"];
        clockInCustomCell.clockInDate.text = [NSString stringWithFormat:@"%@",[(array)[indexPath.row] valueForKey:@"Date"]];
        clockInCustomCell.clockInTime.text = [NSString stringWithFormat:@"%@",[(array)[indexPath.row] valueForKey:@"ClockInTime"]];
        clockInCustomCell.clockOutTime.text = [NSString stringWithFormat:@"%@",[(array)[indexPath.row] valueForKey:@"ClockOutTime"]];
        NSString *hours = [self stringFromTimeInterval:[[(array)[indexPath.row] valueForKey:@"WorkingTime"] integerValue]];
        clockInCustomCell.totalHours.text = hours;
        if ([tableView isEqual:_tblClockInOut]) {
            (clockInCustomCell.btnEdit).tag = indexPath.row;
            [clockInCustomCell.btnEdit addTarget:self action:@selector(editClockInOutTime:) forControlEvents:UIControlEventTouchUpInside];
            (clockInCustomCell.btnVoidUnvoid).tag = indexPath.section;
            if ([[(array)[indexPath.row] valueForKey:@"IsVoid"] boolValue]) {
                [self setImagesToVoidUnvoidButton:clockInCustomCell.btnVoidUnvoid normalImage:@"unvoid.png" selectedImage:@"unvoid_selected.png"];
                clockInCustomCell.voidEntry.hidden = false;
                clockInCustomCell.btnEdit.enabled = false;
            }
            else {
                [self setImagesToVoidUnvoidButton:clockInCustomCell.btnVoidUnvoid normalImage:@"void.png" selectedImage:@"void_selected.png"];
                clockInCustomCell.voidEntry.hidden = true;
                clockInCustomCell.btnEdit.enabled = true;
            }
            [clockInCustomCell.btnVoidUnvoid addTarget:self action:@selector(voidUnvoidClockInOutTime:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            (clockInCustomCell.btnEdit).tag = indexPath.row;
            [clockInCustomCell.btnEdit addTarget:self action:@selector(editClockInOutHistoryTime:) forControlEvents:UIControlEventTouchUpInside];
            (clockInCustomCell.btnVoidUnvoid).tag = indexPath.section;
            if ([[(array)[indexPath.row] valueForKey:@"IsVoid"] boolValue]) {
                [self setImagesToVoidUnvoidButton:clockInCustomCell.btnVoidUnvoid normalImage:@"unvoid.png" selectedImage:@"unvoid_selected.png"];
                clockInCustomCell.voidEntry.hidden = false;
                clockInCustomCell.btnEdit.enabled = false;
            }
            else {
                [self setImagesToVoidUnvoidButton:clockInCustomCell.btnVoidUnvoid normalImage:@"void.png" selectedImage:@"void_selected.png"];
                clockInCustomCell.voidEntry.hidden = true;
                clockInCustomCell.btnEdit.enabled = true;
            }
            [clockInCustomCell.btnVoidUnvoid addTarget:self action:@selector(voidUnvoidClockInOutHistoryTime:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self customerSwipeMethod:clockInCustomCell indexPath:indexPath tableView:tableView];
    }
    return clockInCustomCell;
}

- (void)setImagesToVoidUnvoidButton:(UIButton *)button normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage {
    [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
}

- (void)customerSwipeMethod:(ClockInCustomCell *)cell_p indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    UISwipeGestureRecognizer *gestureRight;
    UISwipeGestureRecognizer *gestureLeft;

    if ([tableView isEqual:_tblClockInOut]) {
        gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRightForCurrentClockInTab:)];
        gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeftForCurrentClockInTab:)];
        if(indexPath.section == self.indPathForCurrentCLIO.section && indexPath.row == self.indPathForCurrentCLIO.row)
        {
            cell_p.viewOperation.frame = CGRectMake(0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
            cell_p.viewOperation.hidden = NO;
        }
        else
        {
            cell_p.viewOperation.frame = CGRectMake(647.0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
            cell_p.viewOperation.hidden = YES;
        }
    }
    else {
        gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRightForClockInHistoryTab:)];
        gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeftForClockInHistoryTab:)];
        if(indexPath.section == self.indPathForCLIOHistory.section && indexPath.row == self.indPathForCLIOHistory.row)
        {
            cell_p.viewOperation.frame = CGRectMake(0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
            cell_p.viewOperation.hidden = NO;
        }
        else
        {
            cell_p.viewOperation.frame = CGRectMake(647.0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
            cell_p.viewOperation.hidden = YES;
        }
    }
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell_p addGestureRecognizer:gestureRight];
    [cell_p addGestureRecognizer:gestureLeft];
}

#pragma mark - Left / Right / Edit / Delete swipe Method

-(void)didSwipeRightForCurrentClockInTab:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:_tblClockInOut];
    NSIndexPath *swipedIndexPath = [_tblClockInOut indexPathForRowAtPoint:location];
    self.indPathForCurrentCLIO = swipedIndexPath;
    [_tblClockInOut reloadData];
}

-(void)didSwipeLeftForCurrentClockInTab:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:_tblClockInOut];
    NSIndexPath *swipedIndexPath = [_tblClockInOut indexPathForRowAtPoint:location];
    if(self.indPathForCurrentCLIO.row == swipedIndexPath.row)
    {
        self.indPathForCurrentCLIO = [NSIndexPath indexPathForRow:-1 inSection:-1];
        [_tblClockInOut reloadData];
    }
}

-(void)didSwipeRightForClockInHistoryTab:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:_tblHistory];
    NSIndexPath *swipedIndexPath = [_tblHistory indexPathForRowAtPoint:location];
    self.indPathForCLIOHistory = swipedIndexPath;
    [_tblHistory reloadData];
}

-(void)didSwipeLeftForClockInHistoryTab:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:_tblHistory];
    NSIndexPath *swipedIndexPath = [_tblHistory indexPathForRowAtPoint:location];
    if(self.indPathForCLIOHistory.row == swipedIndexPath.row)
    {
        self.indPathForCLIOHistory = [NSIndexPath indexPathForRow:-1 inSection:-1];
        [_tblHistory reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Edit / Remove CLIO Time

-(void)editClockInOutTime:(id)sender
{
    if (!isClockInOutActionAllowed) {
        [self displayRightsAlert:@"You don't have rights to edit clock-in/out time. Please contact to Admin."];
        return;
    }
    NSIndexPath *indexPath = [self indexPathForButton:sender fromTableView:_tblClockInOut];
    selectedClockInOutDictionary = [[self selectedClockInRecordDictionary:indexPath] copy];
    NSDictionary *clockInOutTimeDictionary = [self clockInOutTimeDictionaryFromSelectedDictionary:selectedClockInOutDictionary];
    [self openEditClockInOutTimePopUp:clockInOutTimeDictionary isNewEntry:false];
}

- (void)displayRightsAlert:(NSString *)message {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (NSDictionary *)clockInOutTimeDictionaryFromSelectedDictionary:(NSDictionary *)selectedDictionary {
    NSString *clockInTime = [NSString stringWithFormat:@"%@",[self getConvertedTimeString:[selectedDictionary valueForKey:@"ClockInTime"]]];
    NSString *clockOutTime = [NSString stringWithFormat:@"%@",[self getConvertedTimeString:[selectedDictionary valueForKey:@"ClockOutTime"]]];
    NSString *clockInOutDate = [NSString stringWithFormat:@"%@",[selectedDictionary valueForKey:@"Date"]];
    return @{
             @"ClockInTime":clockInTime,
             @"ClockOutTime":clockOutTime,
             @"Date":clockInOutDate
             };
}

- (NSDictionary *)clockInOutTimeDictionaryForAddNewClockInOutEntry {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString *strCurrentDate = [formatter stringFromDate:[NSDate date]];
    [formatter setDateFormat:@"hh:mm a"];
    NSString *strCurrentTime = [formatter stringFromDate:[NSDate date]];
    return @{
             @"ClockInTime":strCurrentTime,
             @"ClockOutTime":strCurrentTime,
             @"Date":strCurrentDate
             };
}

- (NSDictionary *)selectedClockInRecordDictionary:(NSIndexPath *)indexPath {
    NSDictionary *selecteDictionary;
    if (selectedTabOption == TabOptionClockInOut) {
        selecteDictionary = [[self.clockInOutDisplayArray objectAtIndex:indexPath.row] copy];
    }
    else {
        selecteDictionary = [[self.clockInOutHistoryDisplayArray objectAtIndex:indexPath.row] copy];
    }
    return selecteDictionary;
}

- (NSString *)getConvertedTimeString:(NSString *)stringDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([stringDate isEqualToString:@"---:---:---"]) {
        [formatter setDateFormat:@"hh:mm a"];
        return [formatter stringFromDate:[NSDate date]];
    }
    else {
        [formatter setDateFormat:@"hh:mm:ss a"];
        NSDate *date = [formatter dateFromString:stringDate];
        [formatter setDateFormat:@"hh:mm a"];
        return [formatter stringFromDate:date];
    }
}

-(void)voidUnvoidClockInOutTime:(id)sender
{
    NSIndexPath *indexPath = [self indexPathForButton:sender fromTableView:_tblClockInOut];
    NSDictionary *clockInOutDictionary = [[self selectedClockInRecordDictionary:indexPath] copy];
    if (!isClockInOutActionAllowed) {
        [self displyRightsAlertForVoidUnvoid:clockInOutDictionary];
        return;
    }
    [self voidUnvoidClockInOutEntry:clockInOutDictionary];
}

-(void)editClockInOutHistoryTime:(id)sender
{
    if (!isClockInOutActionAllowed) {
        [self displayRightsAlert:@"You don't have rights to edit clock-in/out time. Please contact to Admin."];
        return;
    }
    NSIndexPath *indexPath = [self indexPathForButton:sender fromTableView:_tblHistory];
    selectedClockInOutHistoryDictionary = [[self selectedClockInRecordDictionary:indexPath] copy];
    NSDictionary *clockInOutTimeDictionary = [self clockInOutTimeDictionaryFromSelectedDictionary:selectedClockInOutHistoryDictionary];
    [self openEditClockInOutTimePopUp:clockInOutTimeDictionary isNewEntry:false];
}

-(void)voidUnvoidClockInOutHistoryTime:(id)sender
{
    NSIndexPath *indexPath = [self indexPathForButton:sender fromTableView:_tblHistory];
    NSDictionary *clockInOutDictionary = [[self selectedClockInRecordDictionary:indexPath] copy];
    if (!isClockInOutActionAllowed) {
        [self displyRightsAlertForVoidUnvoid:clockInOutDictionary];
        return;
    }
    [self voidUnvoidClockInOutEntry:clockInOutDictionary];
}

- (void)displyRightsAlertForVoidUnvoid:(NSDictionary *)clockInOutDictionary {
    if ([clockInOutDictionary [@"IsVoid"] boolValue]) {
        [self displayRightsAlert:@"You don't have rights to unvoid clock-in/out detail. Please contact to Admin."];
    }
    else {
        [self displayRightsAlert:@"You don't have rights to void clock-in/out detail. Please contact to Admin."];
    }
}

- (NSIndexPath *)indexPathForButton:(id)sender fromTableView:(UITableView *)tableView {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    return indexPath;
}

- (void)voidUnvoidClockInOutEntry:(NSDictionary *)clockInOutDictionary {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    param[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    param[@"ClockId"] = clockInOutDictionary [@"ClockId"];
    if ([clockInOutDictionary [@"IsVoid"] boolValue]) {
        param[@"IsVoid"] = @"0";
        isVoid = false;
    }
    else {
        param[@"IsVoid"] = @"1";
        isVoid = true;
    }
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self voidUnvoidClockInOutDetailResponse:response error:error];
        });
    };
    
    self.updateClockInOutDetailWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_VOID_UNVOID_CLOCK_IN_OUT_DETAIL params:param completionHandler:completionHandler];
}

- (void)voidUnvoidClockInOutDetailResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if([[response valueForKey:@"IsError"] intValue] == 0)
            {
                if (isVoid) {
                    [self displayVoidUnvoidAlertWithMessage:@"Successfully voided"];
                }
                else {
                    [self displayVoidUnvoidAlertWithMessage:@"Successfully unvoided"];
                }
            }
            else {
                if (isVoid) {
                    [self displayVoidUnvoidFailerAlertWithMessage:@"Error occured in void process."];
                }
                else {
                    [self displayVoidUnvoidFailerAlertWithMessage:@"Error occured in unvoid process."];
                }
            }
        }
    }
}

- (void)displayVoidUnvoidAlertWithMessage:(NSString *)message {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [self proceessAfterUpdateClockInOutDetail];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)displayVoidUnvoidFailerAlertWithMessage:(NSString *)message {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}


- (void)openEditClockInOutTimePopUp:(NSDictionary *)clockInOutTimeDictionary isNewEntry:(BOOL)isNewEntry {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
    cLIOTimePickerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CLIOTimePickerVC_sid"];
    pickerBgView = [[UIView alloc] initWithFrame:self.view.superview.bounds];
    pickerBgView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    cLIOTimePickerVC.view.center = pickerBgView.center;
    cLIOTimePickerVC.view.frame = CGRectMake(311, 146, 402, 475);
    [pickerBgView addSubview:cLIOTimePickerVC.view];
    [self.view addSubview:pickerBgView];
    [self addChildViewController:cLIOTimePickerVC];
    cLIOTimePickerVC.view.layer.cornerRadius = 8.0f;
    cLIOTimePickerVC.cLIOTimePickerVCDelegate = self;
    cLIOTimePickerVC.isNewEntry = isNewEntry;
    isNewClockInEntry = isNewEntry;
    cLIOTimePickerVC.clockInOutTimeDictionary = [clockInOutTimeDictionary copy];
}

- (void)removePickerView {
    [UIView animateWithDuration:0.5 animations:^{
        pickerBgView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        NSArray * arrView = pickerBgView.subviews;
        for (UIView * view in arrView) {
            [view removeFromSuperview];
        }
        [pickerBgView removeFromSuperview];
        pickerBgView = nil;
    }];
}

#pragma mark - CLIOTimePickerVCDelegate

-(void)didUpdateClockInOutTime:(NSDictionary *)clockInOutTime {
    [self removePickerView];
    [self updateClockInOutTime:clockInOutTime];
}

-(void)didCancelUpdateClockInOutTime {
    [self resetNewClockInEntryFlag];
    [self removePickerView];
}

- (void)updateClockInOutTime:(NSDictionary *)updatedTimeDictionary
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    param[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    param[@"LocalDateTime"] = [self getLocaleDate];
    if (isNewClockInEntry) {
        param[@"ClockId"] = @(0);
        param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    }
    else {
        if (selectedTabOption == TabOptionClockInOut) {
            param[@"ClockId"] = selectedClockInOutDictionary [@"ClockId"];
            param[@"UserId"] = selectedClockInOutDictionary [@"UserId"];
        }
        else {
            param[@"ClockId"] = selectedClockInOutHistoryDictionary [@"ClockId"];
            param[@"UserId"] = selectedClockInOutHistoryDictionary [@"UserId"];
        }
    }
    param[@"ClockInDateTime"] = updatedTimeDictionary [@"ClockInTime"];
    param[@"ClockOutDateTime"] = updatedTimeDictionary [@"ClockOutTime"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateClockInOutDetailResponse:response error:error];
        });
    };
    
    self.updateClockInOutDetailWC = [[RapidWebServiceConnection alloc] initWithRequest:KURL actionName:WSM_UPDATE_CLOCK_IN_OUT_DETAIL params:param completionHandler:completionHandler];
}

- (void)updateClockInOutDetailResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [self proceessAfterUpdateClockInOutDetail];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else if([[response valueForKey:@"IsError"] intValue] == -1) {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {

                };
                [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:@"Error occured" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    [self resetNewClockInEntryFlag];
}

- (void)resetNewClockInEntryFlag {
    if (isNewClockInEntry) {
        isNewClockInEntry = false;
    }
}

- (void)proceessAfterUpdateClockInOutDetail {
    if (selectedTabOption == TabOptionClockInOut) {
        isClockInOutDetailsUpdated = true;
        needToReloadClockInOutDetails = false;
        needToReloadClockInOutHistoryDetails = true;
        [self getColckInData];
    }
    else {
        isClockInOutHistoryDetailsUpdated = true;
        needToReloadClockInOutHistoryDetails = false;
        needToReloadClockInOutDetails = true;
        [self clockInHistoryForStartDate:startDateFromFilter withEndDate:endDateFromFilter withSearchCustomType:customTypeFromFilter];
    }
}

-(IBAction)clockInOutClick:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self removeDateFilterView];
    [self clockInOutAction:sender];
}

-(void)clockInOutAction :(id)sender
{
    type = @"";
    NSString *msg = @"";
    if ([sender tag] == 601)
    {
        type = @"ClockIn";
        msg = @"Are you sure want to clock in process?";
    }
    else
    {
        type = @"ClockOut";
        msg = @"Are you sure want to clock out process?";

    }
    ClockInDetailsView * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference clockInOutProcess];
    };
    
    
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:msg buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];

    
}

-(void)clockInOutProcess
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:type forKey:@"sType"];

    param[@"DateTime"] = [self getLocaleDate];
    
    [param setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self clockInOutResponse:response error:error];
        });
    };
    
    self.clockInOutWC = [self.clockInOutWC initWithRequest:KURL actionName:WSM_CLOCK_IN_OUT params:param completionHandler:completionHandler];
}

- (void)clockInOutResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];;
    self.isClockInOut = FALSE;
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                if ([type isEqualToString:@"ClockIn"]) {
                    [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"ClockInRequire"] = [NSNumber numberWithBool:0];
                }
                else if ([type isEqualToString:@"ClockOut"])
                {
                    [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"ClockInRequire"] = [NSNumber numberWithBool:1];
                }
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    needToReloadClockInOutHistoryDetails = true;
                    [self getColckInData];
                    [self clockInOutTabClicked:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [_btnCancel setTitle:@"Done" forState:UIControlStateNormal];
                self.isClockInOut = TRUE;
                if ([type isEqualToString:@"ClockIn"]) {
                    
                    [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"ClockInRequire"] = [NSNumber numberWithBool:0];
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:@"You have successfully clock in." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else if ([type isEqualToString:@"ClockOut"])
                {
                    [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"ClockInRequire"] = [NSNumber numberWithBool:1];
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:@"You have successfully clock out." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else
                {
                    
                }
                needToReloadClockInOutHistoryDetails = true;
                [self setClockInDisplay];
                [self getColckInData];
                [self clockInOutTabClicked:nil];
                self.indPathForCurrentCLIO = [NSIndexPath indexPathForRow:-1 inSection:-1];
                [self.tblClockInOut reloadData];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                
            }
        }
    }
    else
    {
        
    }
}

-(IBAction)clockInOutExit:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self checkCashInRequired];
}

-(void)checkCashInRequired
{
    if ([ self.rmsDbController.selectedModule isEqualToString:@"RCR"])
    {
        if ([type isEqualToString:@"ClockIn"]) {
            if (self.isClockInOut==TRUE)
            {
          //      [self gotoMainPoswithShiftin:@""];
                [self.navigationController popViewControllerAnimated:TRUE];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:TRUE];
            }
            
        }
        else
        {
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }
    else if ([ self.rmsDbController.selectedModule isEqualToString:@"Cash In-Out"])
    {
        if ([type isEqualToString:@"ClockIn"]) {
            if (self.isClockInOut==TRUE)
            {
                CashinOutViewController  *cashInOutView =[[CashinOutViewController alloc]initWithNibName:@"CashinOutViewController" bundle:nil];
                [self.navigationController pushViewController:cashInOutView animated:YES];
            }
            else
            {
                NSArray *viewControllerArray = self.navigationController.viewControllers;
                for (UIViewController *viewController in viewControllerArray)
                {
                    if ([viewController isKindOfClass:[DashBoardSettingVC class]])
                    {
                        [self.navigationController popToViewController:viewController animated:TRUE];
                        
                    }
                }
            }
        }
        else
        {
            NSArray *viewControllerArray = self.navigationController.viewControllers;
            for (UIViewController *viewController in viewControllerArray)
            {
                if ([viewController isKindOfClass:[DashBoardSettingVC class]])
                {
                    [self.navigationController popToViewController:viewController animated:TRUE];
                    
                }
            }        }
        
    }
    else
    {
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        for (UIViewController *viewController in viewControllerArray)
        {
            if ([viewController isKindOfClass:[DashBoardSettingVC class]])
            {
                [self.navigationController popToViewController:viewController animated:TRUE];
                
            }
        }
    }
    
}

-(void)gotoMainPoswithShiftin:(NSString *)require
{
    
    if([[[self.rmsDbController.globalDict valueForKeyPath:@"UserInfo"] valueForKey:@"CashInRequire"]boolValue]== TRUE)
    {
        //require =@"Require";
    }
}

- (NSString *)getLocaleDate {
    NSDate* sourceDate = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    formatter.timeZone = TimeZone;
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    
    NSString *strDate = [formatter stringFromDate:destinationDate];
    return strDate;
}

-(IBAction)closePayPeriod:(id)sender
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    param[@"DateTime"] = [self getLocaleDate];
    
    [param setValue:[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"] forKey:@"UserId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ClockInOutResetResponse:response error:error];
        });
    };
    
    self.clockInOutResetWC = [self.clockInOutResetWC initWithRequest:KURL actionName:WSM_CLOCK_IN_OUT_RESET params:param completionHandler:completionHandler];
}

- (void)ClockInOutResetResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:@"Clock In | Out has been reset sucessfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
                
                [self.rmsDbController.globalDict valueForKey:@"UserInfo"][@"ClockInRequire"] = [NSNumber numberWithBool:1];
                
                [self setClockInDisplay];
                
                [self getColckInData];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Clock In | Out" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


@end

