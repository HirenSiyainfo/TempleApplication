//
//  ShiiftReportDetailsVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 19/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ShiftReportDetailsVC.h"
#import "CKOCalendarViewController.h"
#import "UserShiftDetailsVC.h"
#import "ShiftHistoryDetailsVC.h"
#import "RmsDbController.h"
#import "ShiftReport.h"
#import "ExportPopupVC.h"
#import "EmailFromViewController.h"

@interface ShiftReportDetailsVC () <UIPopoverControllerDelegate,UserShiftDetailsVCDelegate,ShiftHistoryDetailsVCDelegate,ExportPopupVCDelegate,EmailFromViewControllerDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>
{
    NSArray *array_port;
    NSMutableArray *shiftReportPrintingArray;
    
    EmailFromViewController *emailFromViewController;
}

@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnBack;

@property (nonatomic, weak) IBOutlet UIView *shiftDetailsView;
@property (nonatomic, weak) IBOutlet UIView *shiftHistoryView;

@property (nonatomic, weak) IBOutlet UILabel *lblPageTitle;

@property (nonatomic, weak) IBOutlet UIButton *btnPdfAndEmail;

@property (nonatomic, strong) UIPopoverController *calendarPopOverController;
@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) IntercomHandler *intercomHandler;
@property (nonatomic, strong) UserShiftDetailsVC *userShiftDetailsVC;
@property (nonatomic, strong) ShiftHistoryDetailsVC *shiftHistoryDetailsVC;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) Configuration *configuration;
@property (nonatomic, strong) NDHTMLtoPDF *pdfCreator;

@property (nonatomic, strong) NSNumber *tipSetting;

@property (nonatomic, strong) NSString *sourcePath;

@end

@implementation ShiftReportDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"dr_helpbtn.png" selectedImage:@"dr_helpbtnselected.png" withViewController:self];
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    self.configuration = [UpdateManager getConfigurationMoc:self.rmsDbController.managedObjectContext];
    self.tipSetting = self.configuration.localTipsSetting;
    [self setPageTitle:@"Shift Report"];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
    [self configureUIForView:self.shiftDetailsView];
    [self.userShiftDetailsVC getCurrentShiftDetails];
    [self hideBackButton];
    
    // Do any additional setup after loading the view.
}

- (IBAction)backButtonClicked:(id)sender {
    [self hideBackButton];
    [self setPageTitle:@"Shift Report"];
    [self configureUIForView:self.shiftDetailsView];
}

- (void)showBackButton {
    self.btnBack.hidden = NO;
}

- (void)hideBackButton {
    self.btnBack.hidden = YES;
}

- (void)setPageTitle:(NSString *)title {
    self.lblPageTitle.text = title;
}

#pragma mark - Configure UI

- (void)configureUIForView:(UIView *)view {
    self.shiftDetailsView.hidden = YES;
    self.shiftHistoryView.hidden = YES;
    view.hidden = NO;
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [self.calendarPopOverController dismissPopoverAnimated:YES];
    self.calendarPopOverController = [[UIPopoverController alloc] initWithContentViewController:ckOCalendarViewController];
    self.calendarPopOverController.delegate = self;
    ckOCalendarViewController.calendarPopover = self.calendarPopOverController;
    CGRect popoverRect = [self.view convertRect:(self.showCalendar).frame fromView:self.view];
    [self.calendarPopOverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(IBAction)closeButtonClicked:(id)sender {
    if(self.isfromDashBoard) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.rmsDbController playButtonSound];
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

#pragma mark - UserShiftDetailsVCDelegate

- (void)didHistoryButtonTapped {
    [self setPageTitle:@"Shift History"];
    [self loadHistory];
}

- (void)loadHistory {
    [self showBackButton];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self.shiftHistoryDetailsVC loadShiftHistoryWithAllTabOptions:NO];
}

- (void)didShiftCloseSuccessfully {
    self.isfromDashBoard = false;
}

- (void)didGenerateHtml:(NSString *)html andPrintArray:(NSArray *)printArray forHistory:(BOOL)isForHistory emailHtmlPath:(NSString *)sourcePath {
    self.sourcePath = [sourcePath copy];
    if (printArray) {
        shiftReportPrintingArray = [printArray mutableCopy];
        if (isForHistory) {
            [self.shiftHistoryDetailsVC loadHtmlForShiftHistoryUsing:html];
        }
        else {
            [self.userShiftDetailsVC loadHtmlForUserShiftUsing:html];
        }
    }
    [_activityIndicator hideActivityIndicator];
}

- (void)didUserShiftServiceCall {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
}

- (void)didGetResponseOfUserShiftServiceCall {
    [_activityIndicator hideActivityIndicator];
}

#pragma mark - ShiftHistoryDetailsVCDelegate

- (void)accessShiftReport:(ReportName)reportName usingDictionary:(NSMutableDictionary *)shiftDetailsDict {
    if (reportName == ReportNameShift) {
        if (shiftDetailsDict) {
            [_activityIndicator hideActivityIndicator];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            });
            [self configureUIForView:self.shiftHistoryView];
            [self.userShiftDetailsVC accessShiftHistoryDetailsUsing:shiftDetailsDict];
            return;
        }
        [_activityIndicator hideActivityIndicator];
    }
}

- (void)didSelectedMangerReportOption:(ManagerTabOption)managerTabOption {
    [self loadHistory];
}

#pragma mark - Printer Function Delegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp
{
    NSString *retryMessage = @"Failed to Shift Report print receipt. Would you like to retry.?";
    [self displayShiftReportPrintRetryAlert:retryMessage];
}

-(void)displayShiftReportPrintRetryAlert:(NSString *)message
{
    ShiftReportDetailsVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference printShiftReportClicked:nil];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

#pragma mark - Shift Report Print & Email

- (IBAction)printShiftReportClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    [self printReport:portName portSettings:portSettings];
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
    [ShiftReportDetailsVC setPortName:localPortName];
    [ShiftReportDetailsVC setPortSettings:array_port[0]];
}

- (void)printReport:(NSString *)portName portSettings:(NSString *)portSettings
{
    if (shiftReportPrintingArray && shiftReportPrintingArray.count > 0) {
        ShiftReport *shiftReportPrint = [[ShiftReport alloc] initWithDictionary:shiftReportPrintingArray.firstObject reportName:[NSString stringWithFormat:@"Shift #%ld",(long)[[[[shiftReportPrintingArray.firstObject valueForKey:@"objShiftDetail"] firstObject] valueForKey:@"ShiftNo"] integerValue]] isTips:self.tipSetting.boolValue];
        [shiftReportPrint printReportWithPort:portName portSettings:portSettings withDelegate:self];
    }
    [_activityIndicator hideActivityIndicator];
}

- (IBAction)emailShiftReportClicked:(id)sender {
    ExportPopupVC *exportPopupVC = [[UIStoryboard storyboardWithName:@"Reporting" bundle:NULL] instantiateViewControllerWithIdentifier:@"ExportPopupVC_sid"];
    exportPopupVC.delegate = self;
    exportPopupVC.isHideArrow = true;
    [exportPopupVC presentViewControllerForviewConteroller:self sourceView:self.btnPdfAndEmail ArrowDirection:UIPopoverArrowDirectionDown];
//    [self.userShiftDetailsVC loadShiftReportEmail];
}

#pragma mark - ExportPopupVCDelegate

-(void)didSelectExportType:(ExportType)exportType withTag:(NSInteger)tag {
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
    NSString *reportPrintName = @"Shift";
    NSString *strsubjectLine = [NSString stringWithFormat:@"%@  %@  %@ Report",[self.rmsDbController.globalDict valueForKey:@"RegisterName"],currentDateTime,reportPrintName];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"UserShiftDetailsVCSegue"]) {
        self.userShiftDetailsVC = (UserShiftDetailsVC*) segue.destinationViewController;
        self.userShiftDetailsVC.userShiftDetailsVCDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"ShiftHistoryDetailsVCSegue"]) {
        self.shiftHistoryDetailsVC = (ShiftHistoryDetailsVC*) segue.destinationViewController;
        self.shiftHistoryDetailsVC.shiftHistoryDetailsVCDelegate = self;
    }
}

@end
