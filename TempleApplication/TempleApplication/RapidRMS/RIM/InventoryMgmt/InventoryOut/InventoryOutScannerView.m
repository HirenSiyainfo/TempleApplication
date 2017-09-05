//
//  NewOrderScannerView.m
//  I-RMS
//
//  Created by Siya Infotech on 16/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "CameraScanVC.h"
#import "EmailFromViewController.h"
#import "ExportPopupVC.h"
#import "InventoryItemSelectionListVC.h"
#import "InventoryOutScannerView.h"
#import "InvnetoryInCustomCell.h"
#import "Item+Dictionary.h"
#import "ItemInfoPopupVC.h"
#import "RimIphonePresentMenu.h"
#import "RIMNumberPadPopupVC.h"
#import "RimsController.h"
#import "RmsDbController.h"
#import "UserInputTextVC.h"


#import "InvnetoryInCustomCell.h"

@interface InventoryOutScannerView ()<CameraScanVCDelegate,InventoryItemSelectionListVCDelegate , EmailFromViewControllerDelegate , ExportPopupVCDelegate> {
    
    EmailFromViewController *emailFromViewController;
    IntercomHandler *intercomHandler;
    RimIphonePresentMenu *objMenubar;
    Configuration *configuration;

    NSMutableString *status;
    NSMutableString *debug;
    
    UITextField *activeField;
    
    NSIndexPath *deleteIndPath;
    NSString * strUserInputMsg;
    NSString * strDate,* strTime;
}

@property (nonatomic, strong) UpdateManager * itemOutUpdateManager;
@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) UIDocumentInteractionController *controller;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

@property (nonatomic) BOOL suspendDisplayInfo;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, weak) IBOutlet UITableView *tblScannedItemList;

@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;

@property (nonatomic, weak) IBOutlet UIButton *btnTotalItemInfo;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnOk;
@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@property (nonatomic, weak) IBOutlet UIButton *pdfEmailBtn;

//@property (nonatomic, weak) IBOutlet UITextView *displayText;
@property (nonatomic, weak) IBOutlet UITextField *txtEnterOrderNo;
@property (nonatomic, weak) IBOutlet UITextField *txtMainBarcode;
@property (nonatomic, weak) IBOutlet UIImageView *statusImage;

@property (nonatomic, strong) NSString *strTypeOfOperation;
@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) NSIndexPath *indPath;
@property (nonatomic, strong) NSIndexPath *clickedTextIndPath;

@property (nonatomic, strong) NSMutableArray *arrScanBarDetails;

@property (nonatomic, strong) NSMutableDictionary *dictOutInventoryMain;

@property (nonatomic, strong) RapidWebServiceConnection * mgmtItemInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection * invenOutAddInventoryOutWC;
@property (nonatomic, strong) RapidWebServiceConnection * updateInventoryOutWC;

@end

@implementation InventoryOutScannerView

- (void)viewDidLoad {
    
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.mgmtItemInsertWC = [[RapidWebServiceConnection alloc]init];
    self.invenOutAddInventoryOutWC = [[RapidWebServiceConnection alloc]init];
    self.updateInventoryOutWC = [[RapidWebServiceConnection alloc]init];
    
    self.itemOutUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    configuration = [UpdateManager getConfigurationMoc:self.rmsDbController.managedObjectContext];

    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
    self.suspendDisplayInfo=false;
    status=[[NSMutableString alloc] init];
    debug=[[NSMutableString alloc] init];
    
    
    self.arrScanBarDetails=[[NSMutableArray alloc] init];
    
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    
    if([self.rimsController.scannerButtonCalled isEqualToString:@""]) {
        self.rimsController.scannerButtonCalled=@"InvnetoryOut";
    }
    
    [_txtMainBarcode becomeFirstResponder];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    [super viewDidLoad];
}

-(void)viewInventoryItemOut:(NSArray *) dictInventoryItem
{
    self.arrScanBarDetails = [dictInventoryItem mutableCopy];
}

-(void)viewInventoryMainOut:(NSArray *) dictInventoryMain
{
    self.dictOutInventoryMain = dictInventoryMain.firstObject;
    NSString  *Datetime = [NSString stringWithFormat:@"%@",[self.dictOutInventoryMain valueForKey:@"CreatedDate"]];
    strDate = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy"];
    strTime = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
    if (IsPad()) {
        _lblDate.text = strDate;
        _lblTime.text = strTime;
    }
    else{
        _lblDate.text = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *currentDateTime=[NSString stringWithFormat:@"%@",destinationDate];
    _txtEnterOrderNo.text = currentDateTime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    dateFormatter.timeZone = sourceTimeZone;
    strDate = [dateFormatter stringFromDate:destinationDate];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    timeFormatter.timeZone = sourceTimeZone;
    strTime = [timeFormatter stringFromDate:destinationDate];
    
    if(_lblDate.text.length == 0)
    {
        if (IsPad()) {
            _lblDate.text = strDate;
            _lblTime.text = strTime;
        }
        else{
            _lblDate.text = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
        }
    }
    
    if(self.arrOutOpenData.count > 0)
    {
        NSMutableDictionary *dict = self.arrOutOpenData.firstObject;
        [self viewInventoryItemOut:dict[@"InventoryItem"]];
        [self viewInventoryMainOut:dict[@"InventoryMain"]];
        [self.tblScannedItemList reloadData];
        [self.arrOutOpenData removeAllObjects];
    }
    
    [self.tblScannedItemList reloadData];

    self.suspendDisplayInfo=false;
    
    self.rimsController.scannerButtonCalled = @"InvnetoryOut";
    [self checkConnectedScanner_Out];
}

-(void)checkConnectedScanner_Out
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
    {
        _txtMainBarcode.hidden = FALSE;
        _txtMainBarcode.userInteractionEnabled = TRUE;
        [_txtMainBarcode becomeFirstResponder];
    }
    else
    {
        _txtMainBarcode.hidden = TRUE;
        _txtMainBarcode.userInteractionEnabled = FALSE;
    }
}

-(IBAction)btn_back:(id)sender {
    
    [self.rmsDbController playButtonSound];
    self.rimsController.scannerButtonCalled=@"";
    [self presentViewController:objMenubar animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/* search button */

-(IBAction)btnSearchItem:(id)sender
{
    [Appsee addEvent:kRIMItemOutFooterSearch];
    [self.rmsDbController playButtonSound];
    if(IsPhone())
    {
        NSArray *arryView = self.navigationController.viewControllers;
        for(int i=0;i<arryView.count;i++)
        {
            UIViewController *viewCon = arryView[i];
            if([viewCon isKindOfClass:[InventoryItemSelectionListVC class]]){
                [self.navigationController popToViewController:viewCon animated:YES];
                return;
            }
        }
    }
    InventoryItemSelectionListVC * objInventoryItemSelectionListVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemSelectionListVC_sid"];
    objInventoryItemSelectionListVC.delegate = self;
    objInventoryItemSelectionListVC.arrNotSelectedItemCodes = @[@(0)];
    objInventoryItemSelectionListVC.isSingleSelection = FALSE;
    objInventoryItemSelectionListVC.isItemActive = TRUE;
    objInventoryItemSelectionListVC.isItemInSelectMode = TRUE;
    
    [self presentViewController:objInventoryItemSelectionListVC animated:YES completion:nil];
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

/* search button end */

- (void)barcodeSearchItem
{
    BOOL isNumeric;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:_txtMainBarcode.text];
    isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
        _txtMainBarcode.text = [self.rmsDbController trimmedBarcode:_txtMainBarcode.text];
    }
    
    BOOL isScanItemfound = FALSE;
    
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate;
    if ([self isSubDepartmentEnableInBackOffice]) {
        predicate = [NSPredicate predicateWithFormat:@"(barcode==%@ OR ANY itemBarcodes.barCode == %@) AND active == %d ", _txtMainBarcode.text,_txtMainBarcode.text,TRUE];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(barcode==%@ OR ANY itemBarcodes.barCode == %@) AND active == %d AND itm_Type != %@", _txtMainBarcode.text,_txtMainBarcode.text,TRUE,@(2)];
    }

    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    
    NSMutableDictionary *dictItemClicked = [item.itemRMSDictionary mutableCopy];
    
    if(dictItemClicked != nil)
    {
        dictItemClicked[@"AddedQty"] = @"1";
        
        NSString * strItemCode=[NSString stringWithFormat:@"%d",[[dictItemClicked valueForKey:@"ItemId"]intValue]];
        
        BOOL isExtisData=FALSE;
        
        if(self.arrScanBarDetails.count>0)
        {
            for (int idata=0; idata<self.arrScanBarDetails.count; idata++) {
                NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.arrScanBarDetails)[idata]valueForKey:@"ItemId"]intValue]];
                if([sItemId isEqualToString:strItemCode])
                {
                    isExtisData=TRUE;
                    break;
                }
            }
        }
        
        if(isExtisData)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"%@ item already existed.",_txtMainBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            NSString *barCode = _txtMainBarcode.text;
            NSString *itemCode = dictItemClicked[@"ItemId"];
            
            BOOL isBarcodeExist = [self.itemOutUpdateManager doesBarcodeExist:barCode forItemCode:itemCode];
            if(isBarcodeExist)
            {
                dictItemClicked[@"Barcode"] = barCode;
            }
            else
            {
                
            }
            [self.arrScanBarDetails insertObject:dictItemClicked atIndex:0];
            [self.tblScannedItemList reloadData];
        }
        [self.tblScannedItemList reloadData];
        isScanItemfound = TRUE;
        [_txtMainBarcode becomeFirstResponder];
    }
    if(!isScanItemfound)
    {
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:_txtMainBarcode.text forKey:@"Code"];
        [itemparam setValue:@"Barcode" forKey:@"Type"];
        NSDictionary *barcodeDict = @{kRIMItemOutBarcodeSearchWebServiceCallKey : _txtMainBarcode.text};
        [Appsee addEvent:kRIMItemOutBarcodeSearchWebServiceCall withProperties:barcodeDict];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responseInvnetoryOutDataResponse:response error:error];
            });
        };
        
        self.mgmtItemInsertWC = [self.mgmtItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
    }
    else
    {
        [_txtMainBarcode resignFirstResponder];
        _txtMainBarcode.text = @"";
    }
    NSInteger tmprow = self.indPath.row;
    [self.tblScannedItemList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    if(tmprow > -1)
    {
        self.indPath=[NSIndexPath indexPathForRow:tmprow + 1 inSection:0];
    }
}

-(void)responseInvnetoryOutDataResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
            if(itemResponseArray.count > 0)
            {
                NSDictionary *itemDict = itemResponseArray.firstObject;
                if ([[[itemDict valueForKey:@"isDeleted"] stringValue] isEqualToString:@"1"]) // if deleted
                {

                    [Appsee addEvent:kRIMItemOutBarcodeSearchWebServiceResponse withProperties:@{kRIMItemOutBarcodeSearchWebServiceResponseKey : @"No Record Found"}];
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [_txtMainBarcode becomeFirstResponder];
                        _txtMainBarcode.text = @"";
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"No Record Found for %@",_txtMainBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    [self checkConnectedScanner_Out];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mgmtItemInsertResult" object:nil];
                    return;
                }
                else if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"0"]) // if not active
                {

                    [Appsee addEvent:kRIMItemInBarcodeSearchWebServiceResponse withProperties:@{kRIMItemInBarcodeSearchWebServiceResponseKey : @"This Item is currently not Activated."}];
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [_txtMainBarcode becomeFirstResponder];
                        _txtMainBarcode.text = @"";
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"This Item is currently not Activated."] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    [self checkConnectedScanner_Out];
                }
                else // if item not deleted than add to coredata
                {
                    [Appsee addEvent:kRIMItemOutBarcodeSearchWebServiceResponse withProperties:@{kRIMItemOutBarcodeSearchWebServiceResponseKey : @"Record Found"}];
                    
                    [self.itemOutUpdateManager updateObjectsFromResponseDictionary:responseDictionary];
                    [self.itemOutUpdateManager linkItemToDepartmentFromResponseDictionary:responseDictionary];
                    Item *anItem=[self fetchAllItems:[[[responseDictionary valueForKey:@"ItemArray"] firstObject ]valueForKey:@"ITEMCode"]];
                    if (anItem) {
                        NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
                        dictItemClicked[@"AddedQty"] = @"1";
                        [self.arrScanBarDetails insertObject:dictItemClicked atIndex:0];
                    }
                    [self.tblScannedItemList reloadData];
                }
            }
            else
            {
                [Appsee addEvent:kRIMItemOutBarcodeSearchWebServiceResponse withProperties:@{kRIMItemOutBarcodeSearchWebServiceResponseKey : @"No Record Found"}];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [_txtMainBarcode becomeFirstResponder];
                    _txtMainBarcode.text = @"";
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[NSString stringWithFormat:@"No Record Found for %@",_txtMainBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self checkConnectedScanner_Out];
            }
        }
    }

    
}

-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}

#pragma mark - Camera Scan Delegate Methods

-(void)barcodeScanned:(NSString *)strBarcode
{
    _txtMainBarcode.text = strBarcode;
    [self textFieldShouldReturn:_txtMainBarcode];
}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if((textField == _txtMainBarcode) && _txtMainBarcode.text.length > 0)
    {
        NSDictionary *searchDict = @{kRIMItemOutBarcodeSearchKey : textField.text};
        [Appsee addEvent:kRIMItemOutBarcodeSearch withProperties:searchDict];
        [self barcodeSearchItem];
        return YES;
    }
    else
    {
        [textField resignFirstResponder];
        return YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if((textField != _txtEnterOrderNo) && (textField != _txtMainBarcode))
    {
        CGPoint textboxPosition = [textField convertPoint:CGPointZero toView:self.tblScannedItemList];
        NSIndexPath * cellIndexPath = [self.tblScannedItemList indexPathForRowAtPoint:textboxPosition];
        
        RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesQTY NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
            if(numInput.floatValue == 0)
            {
                numInput = @(0);
            }
            NSMutableDictionary *dict = self.arrScanBarDetails[cellIndexPath.row];
            dict[@"AddedQty"] = numInput.stringValue;
            [self.tblScannedItemList reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        } NumberPadColseInput:^(UIViewController *popUpVC) {
            [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        }];
        objRIMNumberPadPopupVC.inputView = textField;
        [objRIMNumberPadPopupVC presentVCForRightSide:self WithInputView:textField];
//        [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:textField ArrowDirection:UIPopoverArrowDirectionRight];
        return FALSE;
    }
    return TRUE;
}

- (void)doneButton // Function for Hide Iphone Numberpad
{
    if([activeField.text isEqual: @""])
    {
        NSMutableDictionary *dict = (self.arrScanBarDetails)[self.clickedTextIndPath.row];
        dict[@"AddedQty"] = @"1";
        (self.arrScanBarDetails)[self.clickedTextIndPath.row] = dict;
        activeField.text = @"1";
        [activeField resignFirstResponder];
    }
    else
    {
        NSMutableDictionary *dict = (self.arrScanBarDetails)[self.clickedTextIndPath.row];
        dict[@"AddedQty"] = activeField.text;
        (self.arrScanBarDetails)[self.clickedTextIndPath.row] = dict;
        [activeField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (IsPad())
    {
        if((textField != _txtEnterOrderNo) && (textField != _txtMainBarcode))
        {
            if([activeField.text isEqual: @""])
            {
                NSMutableDictionary *dict = (self.arrScanBarDetails)[self.clickedTextIndPath.row];
                dict[@"AddedQty"] = @"1";
                (self.arrScanBarDetails)[self.clickedTextIndPath.row] = dict;
                activeField.text = @"1";
                [activeField resignFirstResponder];
            }
            else
            {
                NSMutableDictionary *dict = (self.arrScanBarDetails)[self.clickedTextIndPath.row];
                dict[@"AddedQty"] = activeField.text;
                (self.arrScanBarDetails)[self.clickedTextIndPath.row] = dict;
                [activeField resignFirstResponder];
            }
        }
    }
    return YES;
}

/* Hold item */

-(IBAction)btnHoldItemClicked:(id)sender
{
    [Appsee addEvent:kRIMItemOutFooterHold];
    [self.rmsDbController playButtonSound];
    self.strTypeOfOperation = @"OPEN";
   
    if(self.isItemOrderUpdate) {
        strUserInputMsg = [self.dictOutInventoryMain valueForKey:@"Description"];
    }
    if(self.arrScanBarDetails.count > 0) {
        [self setUserInputViewWithMessage:[NSString stringWithFormat:@"%@",[self.dictOutInventoryMain valueForKey:@"Description"]]];
    }
    else {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Add some product." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}


-(IBAction)btnSaveItemClicked:(id)sender
{
    [Appsee addEvent:kRIMItemOutFooterSave];
    [self.rmsDbController playButtonSound];
    self.strTypeOfOperation = @"CLOSE";

    if(self.isItemOrderUpdate) {
        
        strUserInputMsg = [self.dictOutInventoryMain valueForKey:@"Description"];
    }
    if(self.arrScanBarDetails.count > 0) {
        [self setUserInputViewWithMessage:[NSString stringWithFormat:@"%@",[self.dictOutInventoryMain valueForKey:@"Description"]]];
    }
    else {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Add some product." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

-(void)setUserInputViewWithMessage:(NSString *)strMessage {
    UserInputTextVC * objUserInputTextVC = [UserInputTextVC setInputTextViewViewitem:@"" InputTitle:@"Add Item Message" InputSaved:^(NSString *strInput) {
        strUserInputMsg = strInput;
    } InputClosed:^(UIViewController *popUpVC) {
        [((UserInputTextVC *)popUpVC) popoverPresentationControllerShouldDismissPopover];
        [self.rmsDbController playButtonSound];
        if(self.isItemOrderUpdate) {
            [self updateItemOutRecord];
        }
        else {
            [self btnSaveRecordOut:nil];
        }

    }];
    objUserInputTextVC.isKeybordShow = TRUE;
    [objUserInputTextVC presentViewControllerForviewConteroller:self sourceView:nil ArrowDirection:(UIPopoverArrowDirection)nil];
    self.popoverPresentationController.delegate = objUserInputTextVC;
}

-(IBAction)btnSaveRecordOut:(id)sender
{
    
    if(self.arrScanBarDetails.count > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *addInvenIn = [self outInsertAddInventory];
        NSDictionary *addInventoryDict = @{kRIMItemOutAddInventoryWebServiceCallKey : @([[[[addInvenIn valueForKey:@"InventoryOutDetail"] firstObject] valueForKey:@"InventoryItemDetail"] count])};
        [Appsee addEvent:kRIMItemOutAddInventoryWebServiceCall withProperties:addInventoryDict];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getInvenOutInsertAddInventoryResponse:response error:error];
            });
        };
        
        self.invenOutAddInventoryOutWC = [self.invenOutAddInventoryOutWC initWithRequest:KURL actionName:WSM_ADD_INVENTORY_OUT params:addInvenIn completionHandler:completionHandler];
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Add some product to place order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) getInvenOutInsertAddInventoryResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [Appsee addEvent:kRIMItemOutAddInventoryWebServiceResponse withProperties:@{kRIMItemOutAddInventoryWebServiceResponseKey : @"Order Placed successfully."}];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Order Placed successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrScanBarDetails removeAllObjects];
                [self.tblScannedItemList reloadData];
                _txtEnterOrderNo.text = @"";
                strUserInputMsg = @"";
            }
            else
            {
                [Appsee addEvent:kRIMItemOutAddInventoryWebServiceResponse withProperties:@{kRIMItemOutAddInventoryWebServiceResponseKey : @"Order not Placed. Please try again."}];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Order not Placed. Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

- (NSMutableDictionary *) outInsertAddInventory {
    
    NSMutableDictionary * addItemInventoryOut = [[NSMutableDictionary alloc] init];
    NSMutableArray * InventoryIn = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    itemDetailDict[@"InventoryMst"] = [self InventoryMstOut];
    itemDetailDict[@"InventoryItemDetail"] = [self InventoryItemOut];
    [InventoryIn addObject:itemDetailDict];
    addItemInventoryOut[@"InventoryOutDetail"] = InventoryIn;
    return addItemInventoryOut;
}

- (NSMutableArray *) InventoryMstOut
{
    NSMutableArray *arrItemMst = [[NSMutableArray alloc] init];
    NSMutableDictionary *dictItemMstData = [[NSMutableDictionary alloc] init];
    
    dictItemMstData[@"OrderNo"] = @"";
    dictItemMstData[@"Date"] = _txtEnterOrderNo.text;
    dictItemMstData[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictItemMstData[@"UserId"] = [NSString stringWithFormat:@"%@",userID];
    
    dictItemMstData[@"Type"] = self.strTypeOfOperation;
    dictItemMstData[@"Description"] = strUserInputMsg;
    
    [arrItemMst addObject:dictItemMstData];
    return arrItemMst;
}

- (NSMutableArray *) InventoryItemOut
{
    NSMutableArray *arrItemInventory = [[NSMutableArray alloc] init];
    
    if(self.arrScanBarDetails.count>0)
    {
        for (int isup=0; isup<self.arrScanBarDetails.count; isup++)
        {
            NSMutableDictionary *tmpSup=[(self.arrScanBarDetails)[isup] mutableCopy ];
            
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"AddedQty",@"Barcode",@"CostPrice",@"ItemId",@"SalesPrice",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];
            
            [tmpSup setValue:[tmpSup valueForKey:@"AddedQty" ] forKey:@"ReturnQty"];
            [tmpSup removeObjectForKey:@"AddedQty"];
            
            [arrItemInventory addObject:tmpSup];
        }
    }
    return arrItemInventory;
}

/* */

// update inven out start //

-(void)updateItemOutRecord
{
    if(self.arrScanBarDetails.count > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *updateInvenIn = [self UpdateInventoryOut];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getUpdateInventoryOutResponse:response error:error];
            });
        };
        
        self.updateInventoryOutWC = [self.updateInventoryOutWC initWithRequest:KURL actionName:WSM_UPDATE_INVENTORY_OUT params:updateInvenIn completionHandler:completionHandler];
    }
}

- (void) getUpdateInventoryOutResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Order Placed successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrScanBarDetails removeAllObjects];
                [self.tblScannedItemList reloadData];
                _txtEnterOrderNo.text = @"";
                strUserInputMsg = @"";
                //            self._rimController.flgOutOpenOrder = FALSE;
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Order not place. Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

- (NSMutableDictionary *) UpdateInventoryOut
{
    NSMutableDictionary * addItemInventoryIn = [[NSMutableDictionary alloc] init];
    NSMutableArray * InventoryIn = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    itemDetailDict[@"InventoryMst"] = [self updateInventoryOutMst];
    itemDetailDict[@"InventoryItemDetail"] = [self updateInventoryItemDetailOut];
    [InventoryIn addObject:itemDetailDict];
    addItemInventoryIn[@"InventoryOutDetail"] = InventoryIn;
    return addItemInventoryIn;
}

- (NSMutableArray *) updateInventoryOutMst
{
    NSMutableArray *arrItemMst = [[NSMutableArray alloc] init];
    NSMutableDictionary *dictItemMstData = [[NSMutableDictionary alloc] init];
    
    dictItemMstData[@"OrderNo"] = @"";
    //[dictItemMstData setObject:_txtEnterOrderNo.text forKey:@"Date"];
    dictItemMstData[@"Date"] = [self.dictOutInventoryMain valueForKey:@"CreatedDate"];
    dictItemMstData[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictItemMstData[@"UserId"] = [NSString stringWithFormat:@"%@",userID ];
    
    dictItemMstData[@"Type"] = self.strTypeOfOperation;
    dictItemMstData[@"ItemOutId"] = [self.dictOutInventoryMain valueForKey:@"ItemInOutId" ];
    dictItemMstData[@"Description"] = strUserInputMsg;
    
    [arrItemMst addObject:dictItemMstData];
    return arrItemMst;
}

- (NSMutableArray *) updateInventoryItemDetailOut
{
    NSMutableArray *arrItemInventory = [[NSMutableArray alloc] init];
    
    if(self.arrScanBarDetails.count>0)
    {
        for (int isup=0; isup<self.arrScanBarDetails.count; isup++) {
            NSMutableDictionary *tmpSup=[(self.arrScanBarDetails)[isup] mutableCopy ];
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"AddedQty",@"Barcode",@"CostPrice",@"ItemId",@"SalesPrice",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];
            
            [tmpSup setValue:[tmpSup valueForKey:@"AddedQty" ] forKey:@"ReturnQty"];
            [tmpSup removeObjectForKey:@"AddedQty"];
            
            [arrItemInventory addObject:tmpSup];
        }
    }
    return arrItemInventory;
    
}

// update inven out over //

bool outScanActive=false;

// Inventory In functionality (functions)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddItemCustomCell";
    InvnetoryInCustomCell *cell = (InvnetoryInCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSMutableDictionary *dict = self.arrScanBarDetails[indexPath.row];
    NSString * imageImage = @"";
    imageImage = dict[@"ItemImage"];
    
    if(([imageImage isKindOfClass:[NSNull class]]) || ([imageImage isEqualToString:@"<null>"])  )
    {
        imageImage = @"";
    }
    
    if ([[imageImage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        cell.imgItem.image = [UIImage imageNamed:@"noimage.png"];
    }
    else
    {
        [cell.imgItem loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
    }

    cell.lblInventoryName.text = dict[@"ItemName"];
    cell.lblBarcode.text = dict[@"Barcode"];
    
    cell.txtCostPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:[dict[@"CostPrice"] floatValue ]]];
    
    cell.txtSellingPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:[dict[@"SalesPrice"] floatValue]]];
    
    cell.txtAvaQTY.text = [NSString stringWithFormat:@"%@",dict[@"avaibleQty"] ];
    cell.txtAddQTY.text = [NSString stringWithFormat:@"%@",dict[@"AddedQty"] ];

    cell.txtAddQTY.delegate=self;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.arrScanBarDetails.count > 0) {
        _statusImage.hidden = TRUE;
    }
    else {
        _statusImage.hidden = FALSE;
    }
    return self.arrScanBarDetails.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IsPhone()) {
        return 95;
    }
    else{
        return 73;
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
        deleteIndPath = [indexPath copy];
        NSDictionary *swipeDict = @{kRIMItemOutSwipeDeleteKey : @(deleteIndPath.row)};
        [Appsee addEvent:kRIMItemOutSwipeDelete withProperties:swipeDict];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [Appsee addEvent:kRIMItemOutSwipeDeleteCancel];
            [self.tblScannedItemList setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [Appsee addEvent:kRIMItemOutSwipeDeleteDone];
            [self.arrScanBarDetails removeObjectAtIndex:deleteIndPath.row];
            [self.tblScannedItemList reloadData];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this record?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

-(IBAction)btn_ClearAll:(id)sender
{
    [Appsee addEvent:kRIMItemOutFooterClearAll];
    [self.rmsDbController playButtonSound];
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [Appsee addEvent:kRIMItemOutFooterClearAllCancel];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [Appsee addEvent:kRIMItemOutFooterClearAllDone];
        [self.arrScanBarDetails removeAllObjects];
        [self.tblScannedItemList reloadData];
        
        [_txtMainBarcode becomeFirstResponder];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to clear all transaction?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

#ifdef LINEAPRO_SUPPORTED

-(void)connectionState:(int)state
{
    switch (state) {
        case CONN_DISCONNECTED:
        case CONN_CONNECTING:
            _statusImage.image = [UIImage imageNamed:@"img_ScannerNotConnected.png"];
            break;
        case CONN_CONNECTED:
            outScanActive=false;
            _statusImage.image = [UIImage imageNamed:@"img_scannerConnected.png"];
            break;
    }
}

#endif

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

- (void)insertDidFinish {
}

#ifdef LINEAPRO_SUPPORTED

-(void)deviceButtonPressed:(int)which
{
    [status setString:@""];
    
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"InvnetoryOut"])
        {
            [debug setString:@""];
            _statusImage.image = [UIImage imageNamed:@"scanning.png"];
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"InvnetoryOut"])
        {
            if(![status isEqualToString:@""])
            {
                [self barcodeSearchItem];
            }
            else
            {
                
            }
            _statusImage.image = [UIImage imageNamed:@"img_scannerConnected.png"];
        }
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please set scanner type as scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }

}

// Barcode Result display via this function
-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status setString:@""];
        [status appendFormat:@"%@",barcode];
        _txtMainBarcode.text = barcode;
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please set scanner type as scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

#endif

#pragma mark - MULTIPLE ITEM SELECTION ITEMS -

-(void)didSelectedItems:(NSArray *) arrListOfitems {
    
    if (arrListOfitems.count > 0) {
        for (Item * anItem in arrListOfitems) {
            NSMutableDictionary *dictSelected = [anItem.itemRMSDictionary mutableCopy];
            if([dictSelected  valueForKey:@"selected"])
            {
                dictSelected[@"AddedQty"] = @"1";
                [self.arrScanBarDetails insertObject:dictSelected atIndex:0];
            }

        }
    }
    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    [self.tblScannedItemList reloadData];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    InvnetoryInCustomCell *cell = (InvnetoryInCustomCell *) activeField.superview.superview;
    UITextField *addQtyTF = (UITextField *)[cell viewWithTag:111];
    [self textFieldShouldEndEditing:addQtyTF];
    [popoverController dismissPopoverAnimated:YES];
}

#pragma mark - Export List -
-(IBAction)btn_ExportClick:(id)sender{
    [Appsee addEvent:kRIMItemOutFooterExport];
    ExportPopupVC * exportPopupVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"ExportPopupVC_sid"];
    exportPopupVC.delegate = self;
    [exportPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionDown];
}

-(void)didSelectExportType:(ExportType)exportType withTag:(NSInteger)tag {
    switch (exportType) {
        case  ExportTypeEmail :
            [self sendEmail];
            break;
        case ExportTypePrieview:
            [self previewandPrint];
            break;
        default:
            break;
    }
}


-(void)sendEmail {
    [Appsee addEvent:kRIMItemOutEmail];
    if(self.arrScanBarDetails.count>0)
    {
        [self htmlBillText:self.arrScanBarDetails];
    }
}

-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
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
    (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (emailFromViewController.dictParameter)[@"postfile"] = myData;
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
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"%@",@"Item Out"]];
    
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]
                                                                                     ]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    
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
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td>&nbsp</td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"avaibleQty"],[itemDictionary[@"CostPrice"]floatValue],[itemDictionary[@"SalesPrice"]floatValue],itemDictionary[@"AddedQty"]];
    
    return htmldata;
}

-(IBAction)btnItemInfoClick:(id)sender
{
    [Appsee addEvent:kRIMItemOutFooterItemInfo];

    float totalQTYeach = 0.0;
    float totalCostPrice = 0.0;
    for( int iArr = 0 ; iArr < self.arrScanBarDetails.count; iArr++)
    {
        // Calculate Total CostPrice
        int iQty = [(self.arrScanBarDetails)[iArr][@"AddedQty"] intValue ];
        totalQTYeach = totalQTYeach + iQty;
        
        float iCost = [(self.arrScanBarDetails)[iArr][@"CostPrice"] floatValue ];
        totalCostPrice = totalCostPrice + (iQty * iCost);
    }
    ItemInfoPopupVC * objItemInfoPopupVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoPopupVC_sid"];
    
    NSMutableDictionary * dictItemInfo = [NSMutableDictionary dictionary];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%lu",(unsigned long)(self.arrScanBarDetails).count] forKey:ItemInfoPopupVCNumOfProduct];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%.0f",totalQTYeach] forKey:ItemInfoPopupVCAddedQTY];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%.2f",totalCostPrice] forKey:ItemInfoPopupVCTotalCost];
    objItemInfoPopupVC.dictItemInfo = dictItemInfo;
    
    [objItemInfoPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionDown];
}

-(void)previewandPrint {
    [Appsee addEvent:kRIMItemOutPreview];
    if(self.arrScanBarDetails.count>0)
    {
        [self htmlBillTextForPreview:self.arrScanBarDetails];
    }
}

-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];

    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceipt.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    
    //[self presentViewController:objPreviewandPrint animated:YES completion:nil];
    
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
    // objPreviewandPrint.strPdfFilePath=result;
    
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


@end

