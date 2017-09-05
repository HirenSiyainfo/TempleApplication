    //
//  OpenListViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 06/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "OpenListVC.h"
#import "GenerateOrderView.h"
#import "AppDelegate.h"
#import "InventoryManagement.h"
#import "DeliveryListVC.h"
#import "RimPopOverVC.h"
//#import "POmenuListVC_iPhone.h"
#import "ItemInfoEditVC.h"

#import "PendingDeliveryCustomCell.h"
#import "UITableViewCell+NIB.h"

#import "RmsDbController.h"
#import "Item+Dictionary.h"
//#import "ItemMultipleSelectionVC.h"

#import "POmenuListVC.h"
#import "OpenOrder_iPhone.h"
#import "EmailFromViewController.h"
#import "POMultipleItemSelectionVC.h"
#import "DeliveryListScanVC.h"
#import "SideMenuPOViewController.h"
#import "POmenuListVC.h"
#import "CameraScanVC.h"
#import "ItemDetailEditVC.h"

@interface OpenListVC()<CameraScanVCDelegate,ItemInfoEditVCDelegate,EmailFromViewControllerDelegate ,POMultipleItemSelectionVCDelegate,UIPopoverPresentationControllerDelegate,ItemInfoEditRedirectionVCDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>
{
    // Barcode Variable
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
    RimPopOverVC * popoverController;
    
    BOOL flgCopyButtonClicked;
    BOOL flgCopyScanITem;
    BOOL isDeliveryUpdate;

    UITextField *currentEditedTextField;
    
    UIPopoverPresentationController *popOverController;
    UIPopoverPresentationController *infopopoverController;
    UIViewController *tempviewController;
    UIViewController *generateOrderInfoViewController;
    UIViewController *itemInformationViewController;
    UIPopoverPresentationController *infoDelivetyOption;
    UIViewController *emailPdfViewController;
    UIPopoverPresentationController *emailPdfPopOverController;
    
    NSIndexPath *deleteOrderIndPath;
    NSIndexPath *insertDelPOIndPath;
    
    NSInteger swipedRecordID;
    
    UITextField *activeField;
    
    NSIndexPath *clickedIndexPath;
    
    CGPoint delivetyButtonPosition;
    
    NSMutableString *status;
    NSString *strDeliveryTitle;
    
    
    NSMutableDictionary *dictItemOrderInfo;
    EmailFromViewController *emailFromViewController;
}

@property (nonatomic, weak) IBOutlet UIView *uvItemInformation;
@property (nonatomic, weak) IBOutlet UIView *uvGenerateOrderInfo;
@property (nonatomic, weak) IBOutlet UIView *viewFooter;
@property (nonatomic, weak) IBOutlet UIView *viewDeliveryOption;
@property (nonatomic, weak) IBOutlet UIView *emailPdfView;

@property (nonatomic, weak) IBOutlet UILabel *lblDeliveryTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDeliveryDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalItem;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalReOrderQTY;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalCost;

@property (nonatomic, weak) IBOutlet UIButton *btnTotalItemInfo;
@property (nonatomic, weak) IBOutlet UIButton *btnGenereteOdrinfo;
@property (nonatomic, weak) IBOutlet UIButton *pdfEmailBtn;

@property (nonatomic, weak) IBOutlet UITextField *txtMainBarcode;
@property (nonatomic, weak) IBOutlet UITextField *txtInvoiceNo;

@property (nonatomic, weak) IBOutlet UITableView *tblOpenListData;

@property (nonatomic, weak) IBOutlet UILabel *lblPopUpDepartment;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpSupplier;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpTags;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpFromDate;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpToDate;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpTimeDuration;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) DeliveryListVC *objDeliveryListIpad;
@property (nonatomic, strong) GenerateOrderView *objGenerate;
@property (nonatomic, strong) GenerateOrderView *objGenerateIpad;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;

@property (nonatomic, strong) UpdateManager *updateManagerOpenList;

@property (nonatomic, strong) RapidWebServiceConnection *getOpenPurchaseOrderDataWC;
@property (nonatomic, strong) RapidWebServiceConnection *editOpenPurchaseOrderWC;
@property (nonatomic, strong) RapidWebServiceConnection *deleteOpenPoWC;
@property (nonatomic, strong) RapidWebServiceConnection *getpendingdeliverydataWC;
@property (nonatomic, strong) RapidWebServiceConnection *updateRecievePoDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *insertReceivePODetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *updateRecievePoDetailWC2;
@property (nonatomic, strong) RapidWebServiceConnection *insertReceivePODetailWC2;
@property (nonatomic, strong) RapidWebServiceConnection *mgmtItemInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection *addBacktoOpenOrderWC;

@property (nonatomic, strong) NSString *poStatus;
@property (nonatomic, strong) NSString *emaiItemHtml;
@property (nonatomic, strong) NSString *strNotificationName;

@property (nonatomic, strong) NSIndexPath *indPath;
@property (nonatomic, strong) NSIndexPath *clickedTextIndPath;

@property (nonatomic, strong) NSMutableArray *arrOpenListData;

@property (nonatomic, strong) UIDocumentInteractionController *controller;

@end

@implementation OpenListVC


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
    emailPdfViewController = [[UIViewController alloc]init];
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getOpenPurchaseOrderDataWC = [[RapidWebServiceConnection alloc]init];
    self.editOpenPurchaseOrderWC = [[RapidWebServiceConnection alloc]init];
    self.getpendingdeliverydataWC = [[RapidWebServiceConnection alloc]init];
    self.updateRecievePoDetailWC = [[RapidWebServiceConnection alloc]init];
    self.insertReceivePODetailWC = [[RapidWebServiceConnection alloc]init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.deleteOpenPoWC = [[RapidWebServiceConnection alloc]init];
    self.insertReceivePODetailWC2 = [[RapidWebServiceConnection alloc]init];
    self.updateRecievePoDetailWC2 = [[RapidWebServiceConnection alloc]init];
    self.mgmtItemInsertWC = [[RapidWebServiceConnection alloc]init];
    self.addBacktoOpenOrderWC = [[RapidWebServiceConnection alloc]init];
    self.updateManagerOpenList = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.arrOpenListData = [[NSMutableArray alloc] init];
    
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    
    if(self.arrPendingDeliveryData.count > 0)
    {

        if(self.strSelectedInvoiceNo)
        {
            _txtInvoiceNo.text = self.strSelectedInvoiceNo;
            self.btnDeliveryIn.hidden=NO;
            isDeliveryUpdate = TRUE;

        }
        else{
            self.btnDeliveryIn.hidden=YES;
            isDeliveryUpdate = NO;

        }
       
        _lblDeliveryTitle.text = self.strSelectedDLTitle;
        
        //
        
        if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
        {
            [self.txtMainBarcode becomeFirstResponder];
        }
        else
        {
            [self.txtMainBarcode resignFirstResponder];
        }
        //

    }
    else
    {
        [self getOpenPOData];
        self.uvPendingDeliveryList.hidden = TRUE;
    }

    if([self.rimsController.scannerButtonCalled isEqualToString:@""])
    {
        self.rimsController.scannerButtonCalled=@"OpenList";
    }

    status=[[NSMutableString alloc] init];
    
    tempviewController = [[UIViewController alloc] init];
    itemInformationViewController = [[UIViewController alloc] init];
    generateOrderInfoViewController = [[UIViewController alloc] init];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        if(screenBounds.size.height == 568)
        {
            
        }
        else
        {
            self.tblPendingDeliveryData.frame=CGRectMake(self.tblPendingDeliveryData.frame.origin.x, self.tblPendingDeliveryData.frame.origin.y, self.tblPendingDeliveryData.frame.size.width, self.tblPendingDeliveryData.frame.size.height-90);
            
            _viewFooter.frame=CGRectMake(_viewFooter.frame.origin.x, _viewFooter.frame.origin.y-90, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
        }
    }
    self.tblOpenListData.separatorInset = UIEdgeInsetsZero;
    self.tblPendingDeliveryData.separatorInset = UIEdgeInsetsZero;
#ifdef LINEAPRO_SUPPORTED
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
#endif
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.navigationController.navigationBarHidden = YES;
    }
//    [self.rimsController.objPOMenuList.btnBackButtonClick removeTarget:nil
//                                                                action:NULL
//                                                      forControlEvents:UIControlEventAllEvents];
//    
//     [self._rimController.objPOMenuList.btnBackButtonClick addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
    self.rimsController.scannerButtonCalled=@"OpenList";


    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};

    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    [self.tblPendingDeliveryData reloadData];
}


-(void)getOpenPOData
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    }
    else{
        UINavigationController * objNav = self.pOmenuListVCDelegate.POmenuListNavigationController;
        UIViewController * topVC = objNav.topViewController;
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:topVC.view];
//        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self._rimController.objPOMenuList.view];

    }
    
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:@"0" forKey:@"PoId"];
    [itemparam setValue:@"0" forKey:@"OpenOrderId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [self getOpenPurchaseOrderDataResponse:response error:error];
            });
    };
    
    self.getOpenPurchaseOrderDataWC = [self.getOpenPurchaseOrderDataWC initWithRequest:KURL actionName:WSM_GET_OPEN_PURCHASE_OREDR_DATA_NEW params:itemparam completionHandler:completionHandler];

}

- (void)getOpenPurchaseOrderDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
	{
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]]) {

		if ([response count] > 0)
		{
			if ([[response  valueForKey:@"IsError"] intValue] == 0)
			{
                self.arrOpenListData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                    [self.tblOpenListData reloadData];
                    [self.tblOpenListData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                }
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

-(IBAction)btnBackClicked:(id)sender
{
    [self.txtMainBarcode resignFirstResponder];
    [self.rmsDbController playButtonSound];
    if(isDeliveryUpdate)
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            DeliveryListVC *objDeliveryList = [[DeliveryListVC alloc] initWithNibName:@"DeliveryListVC" bundle:nil];
            [self.navigationController pushViewController:objDeliveryList animated:YES];
        }
        else
        {
            self.objDeliveryListIpad = [[DeliveryListVC alloc] initWithNibName:@"DeliveryListVC" bundle:nil];
//            self._rimController.objPOMenuList.btnBackButtonClick.hidden=YES;
//            [self._rimController.objPOMenuList showViewFromViewController:self.objDeliveryListIpad];
        }
    }
    else
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            [self.arrPendingDeliveryData removeAllObjects];
            self.uvPendingDeliveryList.hidden = YES;
//             self._rimController.objPOMenuList.btnBackButtonClick.hidden=YES;
//            
//            self._rimController.objPOMenuList.objSideMenuMainPO.indPath=[NSIndexPath indexPathForRow:3 inSection:0];
//            [self._rimController.objPOMenuList menuButtonOperationCell:self._rimController.objPOMenuList.objSideMenuMainPO.indPath.row];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
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

-(void)ItemText:(UITextField *)sender
{
    sender.delegate = self;
    sender.keyboardType = UIKeyboardTypeNumberPad;
    sender.borderStyle = UITextBorderStyleLine;
    sender.tintColor = [UIColor blackColor];
    sender.textAlignment = NSTextAlignmentCenter;
    sender.backgroundColor = [UIColor clearColor];
    sender.textColor = [UIColor colorWithRed:(74/255.f) green:(75/255.f) blue:(77/255.f) alpha:1.0f];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
}

#pragma - UITextField Delegate


#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_txtInvoiceNo resignFirstResponder];

    if((textField.tag == 2) || (textField.tag == 3) ||
       (textField.tag == 4))
    {
        BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"You don't have rights to change item information. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return NO;
        }
    }
    
    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.tblPendingDeliveryData];
    self.clickedTextIndPath = [self.tblPendingDeliveryData indexPathForRowAtPoint:buttonPosition];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        if((textField != self.txtMainBarcode) && (textField != _txtInvoiceNo))
        {
            activeField = textField;
             currentEditedTextField = textField;
            //[currentEditedTextField resignFirstResponder];


            UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            numberToolbar.barStyle = UIBarStyleBlackTranslucent;
            numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton)]];
            textField.inputAccessoryView = numberToolbar;


            if((currentEditedTextField.tag == 2) || (currentEditedTextField.tag == 3) ||
               (currentEditedTextField.tag == 4))
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangePricePopover:) name:@"openListPrice" object:nil];
                self.strNotificationName = @"openListPrice";
            }
            else
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangeQTYPopover:) name:@"ItemQTY" object:nil];
                self.strNotificationName = @"ItemQTY";
            }
        }
    }
    else
    {
        if((textField != self.txtMainBarcode) && (textField != _txtInvoiceNo))
        {
            activeField = textField;
            [currentEditedTextField resignFirstResponder];
            [textField resignFirstResponder];
            
            currentEditedTextField = textField;
            popoverController = [[RimPopOverVC alloc] initWithNibName:@"RimPopOverVC" bundle:nil];
            
            // popover number pad view controller
            
            if((currentEditedTextField.tag == 2) || (currentEditedTextField.tag == 3) ||
               (currentEditedTextField.tag == 4))
            {
                UITextField *__weak weakcurrentEditedTextField = currentEditedTextField;
                __weak typeof(self) weakSelf = self;
                RimPopOverVC *__weak weakpopOverController = popoverController;


                popoverController.didEnterAmountBlock = ^(NSString * strPrice, NSDictionary * userInfo){
                    if(strPrice.length>0 && strPrice.integerValue != 0){
                        PendingDeliveryCustomCell *cell = (PendingDeliveryCustomCell *) weakcurrentEditedTextField.superview.superview;
                        
                        weakcurrentEditedTextField.text = [strPrice stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                        
                        if(weakcurrentEditedTextField.tag == 2) // cost Textfield
                        {
                            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
                            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            
                            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
                            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            if(tempSales.text.length > 0)
                            {
                                NSString *tmpProfitType = [weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                                
                                float dProfitAmt=0;
                                float dsellingAmt=tempSales.text.floatValue;
                                float dcostAmt=tempCost.text.floatValue;
                                
                                UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                                if(dcostAmt == 0.00)
                                {
                                    dProfitAmt = 100;
                                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                    NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                                    dict[@"ProfitAmt"] = tempProfit.text;
                                    weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                                }
                                else
                                {
                                    if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                                    {
                                        dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
                                        tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                        tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                                    }
                                    else // Margin Profit
                                    {
                                        dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
                                        tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                        tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                                    }
                                    NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                                    NSString *strTempProfit = [tempProfit.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
                                    dict[@"ProfitAmt"] = strTempProfit;
                                    weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                                }
                            }
                            NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                            dict[@"CostPrice"] = tempCost.text;
                            
                            //hiten
                            NSNumber *sPrice = @(tempSales.text.floatValue);
                            tempSales.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sPrice];
                            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            NSNumber *sCost = @(tempCost.text.floatValue);
                            tempCost.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sCost];
                            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        else if(weakcurrentEditedTextField.tag == 3) // price Textfield
                        {
                            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
                            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
                            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            if(tempCost.text.length > 0)
                            {
                                NSString *tmpProfitType = [weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                                
                                float dProfitAmt=0;
                                float dsellingAmt = tempSales.text.floatValue;
                                float dcostAmt = tempCost.text.floatValue;
                                UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                                if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                                {
                                    dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
                                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                    tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                                }
                                else // Margin Profit
                                {
                                    dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
                                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                                    tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                                }
                                NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                                NSString *strTempProfit = [tempProfit.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
                                dict[@"ProfitAmt"] = strTempProfit;
                                weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                            }
                            NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                            dict[@"SalesPrice"] = tempSales.text;
                            
                            //hiten
                            NSNumber *sPrice = @(tempSales.text.floatValue);
                            tempSales.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sPrice];
                            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            NSNumber *sCost = @(tempCost.text.floatValue);
                            tempCost.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sCost];
                            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            //
                            weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        else if(weakcurrentEditedTextField.tag == 4) // Profit Textfield
                        {
                            UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                            tempProfit.text = [tempProfit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
                            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            
                            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
                            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            
                            
                            if((![tempCost.text isEqualToString:@""]) && (![tempSales.text isEqualToString:@""]))
                            {
                                NSString *tmpProfitType = [weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                                float dcostAmt=tempCost.text.floatValue;
                                float dprofitper=tempProfit.text.floatValue;
                                float dsellingamt=0;
                                
                                if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                                {
                                    if(dcostAmt>0 && dprofitper>0)
                                    {
                                        float dProfitAmt=0;
                                        dProfitAmt=(dprofitper * dcostAmt)/100;
                                        dsellingamt=dProfitAmt+dcostAmt;
                                        tempSales.text=[NSString stringWithFormat:@"%.2f",dsellingamt];
                                    }
                                }
                                else // Margin Profit
                                {
                                    dsellingamt= dcostAmt/((100-dprofitper)/100);
                                    tempSales.text=[NSString stringWithFormat:@"%.2f",dsellingamt];
                                }
                                NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                                dict[@"SalesPrice"] = tempSales.text;
                                weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                            }
                            NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                            NSString *strTempProfit = [tempProfit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                            dict[@"ProfitAmt"] = strTempProfit;
                            
                            //hiten
                            NSNumber *sPrice = @(tempSales.text.floatValue);
                            tempSales.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sPrice];
                            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            NSNumber *sCost = @(tempCost.text.floatValue);
                            tempCost.text = [weakSelf.rmsDbController.currencyFormatter stringFromNumber:sCost];
                            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                            
                            NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"%"];
                            NSRange range = [tempProfit.text rangeOfCharacterFromSet:cset];
                            if (range.location == NSNotFound) {
                                tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                            } else {
                                
                            }
                            weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                    }
                    else if ([strPrice isEqualToString:@""])
                    {
                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                        
                    }
                };
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangePricePopover:) name:@"openListPrice" object:nil];
//                popoverController.notificationName = @"openListPrice";
            }
            else
            {
                UITextField *__weak weakcurrentEditedTextField = currentEditedTextField;
                __weak typeof(self) weakSelf = self;
                RimPopOverVC *__weak weakpopOverController = popoverController;


                popoverController.didEnterAmountBlock = ^(NSString * strPrice, NSDictionary * userInfo){
                    if(strPrice.length>0 && strPrice.integerValue != 0){

                        weakcurrentEditedTextField.text = [strPrice stringByReplacingOccurrencesOfString:@"" withString:@""];
                        
                        if(weakcurrentEditedTextField.tag == 1) // ReOrder Textfield
                        {
                            NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                            dict[@"ReOrder"] = weakcurrentEditedTextField.text;
                            weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        else if(weakcurrentEditedTextField.tag == 5) // Remark Textfield
                        {
                            NSMutableDictionary *dict = weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row];
                            dict[@"FreeGoodsQty"] = weakcurrentEditedTextField.text;
                            weakSelf.arrPendingDeliveryData[weakSelf.clickedTextIndPath.row] = dict;
                        }
                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                    }
                    else if ([strPrice isEqualToString:@""])
                    {
                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                        
                    }

                };
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangeQTYPopover:) name:@"ItemQTY" object:nil];
//                popoverController.notificationName = @"ItemQTY";
            }
            
            // Present the view controller using the popover style.
            popoverController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:popoverController animated:YES completion:nil];
            
            // Get the popover presentation controller and configure it.
            popOverController = [popoverController popoverPresentationController];
            popOverController.delegate = self;
            popoverController.preferredContentSize = CGSizeMake(300, 456);
            popOverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popOverController.sourceView = self.view;
            popOverController.sourceRect = [self.view convertRect:textField.frame fromView:textField.superview];
            return NO;
        }
    }
    return YES;
}


- (void)doneButton
{

    if ([self.strNotificationName isEqual:@"ItemQTY"])
    {
        if (currentEditedTextField.text.length > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:self.strNotificationName object:currentEditedTextField.text];
        }
        else
        {

        }
    }
    else if ([self.strNotificationName isEqual:@"openListPrice"])
    {
        if (currentEditedTextField.text.length > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:self.strNotificationName object:currentEditedTextField.text];
        }
        else
        {

        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:self.strNotificationName object:currentEditedTextField.text];
    }

    [currentEditedTextField resignFirstResponder];
    [activeField resignFirstResponder];

}


-(void)itemChangePricePopover:(NSNotification *)notification
{
    if (notification.object == nil)
    {
		[popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
	}
    else
    {
        PendingDeliveryCustomCell *cell = (PendingDeliveryCustomCell *) currentEditedTextField.superview.superview;
        
        currentEditedTextField.text = [notification.object stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        if(currentEditedTextField.tag == 2) // cost Textfield
        {
            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            
            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            if(tempSales.text.length > 0)
            {
                NSString *tmpProfitType = [(self.arrPendingDeliveryData)[self.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                
                float dProfitAmt=0;
                float dsellingAmt=tempSales.text.floatValue;
                float dcostAmt=tempCost.text.floatValue;
                
                UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                if(dcostAmt == 0.00)
                {
                    dProfitAmt = 100;
                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                    NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
                    dict[@"ProfitAmt"] = tempProfit.text;
                    (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
                }
                else
                {
                    if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                    {
                        dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
                        tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                        tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                    }
                    else // Margin Profit
                    {
                        dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
                        tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                        tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                    }
                    NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
                    NSString *strTempProfit = [tempProfit.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
                    dict[@"ProfitAmt"] = strTempProfit;
                    (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
                }
            }
            NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
            dict[@"CostPrice"] = tempCost.text;
            
            //hiten
            NSNumber *sPrice = @(tempSales.text.floatValue);
            tempSales.text = [self.rmsDbController.currencyFormatter stringFromNumber:sPrice];
            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            NSNumber *sCost = @(tempCost.text.floatValue);
            tempCost.text = [self.rmsDbController.currencyFormatter stringFromNumber:sCost];
            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
        }
        else if(currentEditedTextField.tag == 3) // price Textfield
        {
            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            if(tempCost.text.length > 0)
            {
                NSString *tmpProfitType = [(self.arrPendingDeliveryData)[self.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                
                float dProfitAmt=0;
                float dsellingAmt = tempSales.text.floatValue;
                float dcostAmt = tempCost.text.floatValue;
                UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
                if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                {
                    dProfitAmt=((dsellingAmt-dcostAmt)*100)/dcostAmt;
                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                    tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                }
                else // Margin Profit
                {
                    dProfitAmt=(1 - (dcostAmt/dsellingAmt)) * 100;
                    tempProfit.text=[NSString stringWithFormat:@"%.2f",dProfitAmt];
                    tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
                }
                NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
                NSString *strTempProfit = [tempProfit.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
                dict[@"ProfitAmt"] = strTempProfit;
                (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
            }
            NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
            dict[@"SalesPrice"] = tempSales.text;
            
            //hiten
            NSNumber *sPrice = @(tempSales.text.floatValue);
            tempSales.text = [self.rmsDbController.currencyFormatter stringFromNumber:sPrice];
            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            NSNumber *sCost = @(tempCost.text.floatValue);
            tempCost.text = [self.rmsDbController.currencyFormatter stringFromNumber:sCost];
            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            //
            (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
        }
        else if(currentEditedTextField.tag == 4) // Profit Textfield
        {
            UITextField *tempProfit = (UITextField *)[cell viewWithTag:4];
            tempProfit.text = [tempProfit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            UITextField *tempCost = (UITextField *)[cell viewWithTag:2];
            tempCost.text = [tempCost.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            
            UITextField *tempSales = (UITextField *)[cell viewWithTag:3];
            tempSales.text = [tempSales.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            
            if((![tempCost.text isEqualToString:@""]) && (![tempSales.text isEqualToString:@""]))
            {
                NSString *tmpProfitType = [(self.arrPendingDeliveryData)[self.clickedTextIndPath.row] valueForKey:@"ProfitType"];
                float dcostAmt=tempCost.text.floatValue;
                float dprofitper=tempProfit.text.floatValue;
                float dsellingamt=0;
                
                if([tmpProfitType isEqualToString:@"MarkUp"]) // MarkUp Profit
                {
                    if(dcostAmt>0 && dprofitper>0)
                    {
                        float dProfitAmt=0;
                        dProfitAmt=(dprofitper * dcostAmt)/100;
                        dsellingamt=dProfitAmt+dcostAmt;
                        tempSales.text=[NSString stringWithFormat:@"%.2f",dsellingamt];
                    }
                }
                else // Margin Profit
                {
                    dsellingamt= dcostAmt/((100-dprofitper)/100);
                    tempSales.text=[NSString stringWithFormat:@"%.2f",dsellingamt];
                }
                NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
                dict[@"SalesPrice"] = tempSales.text;
                (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
            }
            NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
            NSString *strTempProfit = [tempProfit.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            dict[@"ProfitAmt"] = strTempProfit;
            
            //hiten
            NSNumber *sPrice = @(tempSales.text.floatValue);
            tempSales.text = [self.rmsDbController.currencyFormatter stringFromNumber:sPrice];
            tempSales.text = [tempSales.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            NSNumber *sCost = @(tempCost.text.floatValue);
            tempCost.text = [self.rmsDbController.currencyFormatter stringFromNumber:sCost];
            tempCost.text = [tempCost.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"%"];
            NSRange range = [tempProfit.text rangeOfCharacterFromSet:cset];
            if (range.location == NSNotFound) {
                tempProfit.text=[NSString stringWithFormat:@"%@%%",tempProfit.text];
            } else {
                
            }
            (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
        }
        [popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
	}
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openListPrice" object:nil];
}

-(void)itemChangeQTYPopover:(NSNotification *)notification
{
    if (notification.object == nil)
    {
        [popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
	}
    else
    {
        currentEditedTextField.text = [notification.object stringByReplacingOccurrencesOfString:@"" withString:@""];
        
        if(currentEditedTextField.tag == 1) // ReOrder Textfield
        {
            NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
            dict[@"ReOrder"] = currentEditedTextField.text;
            (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
        }
        else if(currentEditedTextField.tag == 5) // Remark Textfield
        {
            NSMutableDictionary *dict = (self.arrPendingDeliveryData)[self.clickedTextIndPath.row];
            dict[@"FreeGoodsQty"] = currentEditedTextField.text;
            (self.arrPendingDeliveryData)[self.clickedTextIndPath.row] = dict;
        }
        [popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ItemQTY" object:nil];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if((textField == self.txtMainBarcode) && self.txtMainBarcode.text.length > 0)
    {
        [status setString:@""];
        [status appendFormat:@"%@", self.txtMainBarcode.text];
        [self searchScannedBarcode];
        self.txtMainBarcode.text = @"";
        if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
        {
            [self.txtMainBarcode becomeFirstResponder];
        }
        else
        {
            [self.txtMainBarcode resignFirstResponder];
        }
        return YES;
    }
    else
    {
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if ([self.strNotificationName isEqual:@"ItemQTY"])
            {
                if (currentEditedTextField.text.length > 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:self.strNotificationName object:currentEditedTextField.text];
                }
                else
                {
                    
                }
            }
            else if ([self.strNotificationName isEqual:@"openListPrice"])
            {
                if (currentEditedTextField.text.length > 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:self.strNotificationName object:currentEditedTextField.text];
                }
                else
                {
                    
                }
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:self.strNotificationName object:currentEditedTextField.text];
            }
            
        }

        
        [textField resignFirstResponder];
        return YES;
    }
    
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblOpenListData){
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            return 90;
        }
        else
        {
            return 73;
        }
    }
    else if (tableView == self.tblPendingDeliveryData){
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            return 134;
        }
        else
        {
            return 73;
        }
    }
    else{
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblOpenListData)
        return 1;
    else if (tableView == self.tblPendingDeliveryData)
        return 1;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblOpenListData)
        return self.arrOpenListData.count;
    else if(tableView == self.tblPendingDeliveryData)
        return self.arrPendingDeliveryData.count;
    else
        return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblOpenListData)
    {
        if(self.arrOpenListData.count > 0) // open po list
        {
           // if ([[UIDevice currentDevice]  userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

                static NSString *CellIdentifier = @"OpenOrder";
                OpenOrder_iPhone *cell = (OpenOrder_iPhone *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
               
                    if (cell == nil)
                    {
                        NSArray *nib;

                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                             nib = [[NSBundle mainBundle] loadNibNamed:@"OpenOrder_iPhone" owner:self options:nil];
                        }
                        else{
                             nib = [[NSBundle mainBundle] loadNibNamed:@"OpenOrderPO_iPad" owner:self options:nil];
                        }
                           cell = nib.firstObject;
                    }
            
                
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.btnDelivery.layer.cornerRadius = 5;
                    cell.btnDelivery.layer.borderWidth = 1.0f;
                    cell.btnDelivery.layer.borderColor = [UIColor clearColor].CGColor;
                    [cell.btnDelivery.layer setMasksToBounds:YES];

                    cell.lblItemName.text = [NSString stringWithFormat:@"%@",[(self.arrOpenListData)[indexPath.row] valueForKey:@"POTitle"]];
                    NSString  *strPono =[NSString stringWithFormat:@"%@",[(self.arrOpenListData)[indexPath.row] valueForKey:@"OpenOrderNo"]];
                    
                    cell.lblPONumber.text = strPono;
                    
                    NSString *strNewDate = [self getStringFormate:[(self.arrOpenListData)[indexPath.row] valueForKey:@"CreatedDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
                    
                    
                    NSArray *arraydate = [strNewDate componentsSeparatedByString:@" "];
                    
                    
                    //NSString  *Datetime = [NSString stringWithFormat:@"%@",[[arrOpenListData objectAtIndex:indexPath.row] valueForKey:@"CreatedDate"]];
                    
                    //NSArray *arrDateTime = [Datetime componentsSeparatedByString:@" "];
                    
                    cell.lblDate.text = [NSString stringWithFormat:@"%@ %@ %@",arraydate.firstObject,arraydate[1],arraydate[2]];
                    
                    cell.lblTime.text = [NSString stringWithFormat:@"%@ %@",arraydate[3],arraydate[4]];
                    
                    [cell.btnDelivery addTarget:self action:@selector(DeliverPO:) forControlEvents:UIControlEventTouchUpInside];
        
                    cell.btnPrint.tag = indexPath.row;
                    [cell.btnPrint setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    
                    [cell.btnPrint addTarget:self action:@selector(openMenuDeliveryOption:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return cell;

                
            }
    }
    if(tableView == self.tblPendingDeliveryData) // pending delivery list
    {
        if(self.arrPendingDeliveryData.count > 0)
        {
            static NSString *CellIdentifier = @"PendingDeliveryCustomCell";
            PendingDeliveryCustomCell *cell = (PendingDeliveryCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                NSArray *nib;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    nib = [[NSBundle mainBundle] loadNibNamed:@"PendingDeliveryCustomCell" owner:self options:nil];
                }
                else
                {
                    nib = [[NSBundle mainBundle] loadNibNamed:@"PendingDeliveryCustomCell_iPad" owner:self options:nil];
                }
                cell = nib.firstObject;
            }
            //    InvnetoryInCustomCell *cell= [InvnetoryInCustomCell dequeOrCreateInTable:tableView];
            
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didOpenOrderSwipeRight:)];
            gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
            [cell.contentView addGestureRecognizer:gestureRight];
            
            UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didOpenOrderSwipeLeft:)];
            gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            [cell.contentView addGestureRecognizer:gestureLeft];
            
            if(indexPath.row==self.indPath.row)
            {
                cell.viewOperation.frame=CGRectMake(0, cell.viewOperation.frame.origin.y, cell.viewOperation.frame.size.width, cell.viewOperation.frame.size.height);
                cell.viewOperation.hidden=NO;
            }
            else
            {
                cell.viewOperation.frame=CGRectMake(320.0, cell.viewOperation.frame.origin.y, cell.viewOperation.frame.size.width, cell.viewOperation.frame.size.height);
                cell.viewOperation.hidden=YES;
            }
            if(self.strSelectedDLTitle)
            {
              _lblDeliveryTitle.text = self.strSelectedDLTitle;
            }
            else{
               _lblDeliveryTitle.text = strDeliveryTitle;
            }
            _lblDeliveryDate.text = self.strSelectedDLDate;
            
            if([[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"Barcode"] isKindOfClass:[NSString class]])
            {
                if([[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@""] || [[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@"<null>"])
                {
                    cell.lblBarcode.text = @"";
                }
                else
                {
                    cell.lblBarcode.text = [NSString stringWithFormat:@"%@",[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"Barcode"]];
                }
            }
            else
            {
                cell.lblBarcode.text = @"";
            }
            
            
            if([(self.arrPendingDeliveryData)[indexPath.row]valueForKey:@"Gvalue"]){
                
                //Light Green
                cell.backgroundColor=[UIColor colorWithRed:149.0/225.0 green:223.0/255.0 blue:198.0/255.0 alpha:1.0];
            }
            else if([(self.arrPendingDeliveryData)[indexPath.row]valueForKey:@"Rvalue"]){
                
                cell.backgroundColor=[UIColor colorWithRed:228.0/225.0 green:171.0/255.0 blue:163.0/255.0 alpha:1.0];
            }
        
            NSString* strItemName = [[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"ItemName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
            cell.lblItemName.text = strItemName;
            cell.lblQTY.text = [NSString stringWithFormat:@"%@",[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"avaibleQty"]];
            
            // Reorder
            cell.txtReOrder.text = [NSString stringWithFormat:@"%@",[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"ReOrder"]];
            cell.txtReOrder.delegate = self;
//            cell.txtReOrder.tag = indexPath.row;
            cell.txtReOrder.keyboardType = UIKeyboardTypeNumberPad;

            // Cost
            //hiten
            NSNumber *scostPrice = @([[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"CostPrice"] floatValue ]);
            cell.txtCostPrice.text = [self.rmsDbController.currencyFormatter stringFromNumber:scostPrice];
            cell.txtCostPrice.text = [cell.txtCostPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            cell.txtCostPrice.delegate = self;
           // cell.txtCostPrice.tag = indexPath.row;
            cell.txtCostPrice.keyboardType = UIKeyboardTypeNumberPad;
            
            
    
            
           // cell.txtCostPrice.text = [NSString stringWithFormat:@"%.2f",[[[self.arrPendingDeliveryData objectAtIndex:indexPath.row] valueForKey:@"CostPrice"] floatValue ]];

            
            // Price
            //hiten
            NSNumber *sPrice = @([[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"SalesPrice"] floatValue]);
            cell.txtSalesPrice.text = [self.rmsDbController.currencyFormatter stringFromNumber:sPrice];
            cell.txtSalesPrice.text = [cell.txtSalesPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            cell.txtSalesPrice.delegate = self;
         //   cell.txtSalesPrice.tag = indexPath.row;
            cell.txtSalesPrice.keyboardType = UIKeyboardTypeNumberPad;
            
           // cell.txtSalesPrice.text = [NSString stringWithFormat:@"%.2f",[[[self.arrPendingDeliveryData objectAtIndex:indexPath.row] valueForKey:@"SalesPrice"] floatValue] ];

            // Profit
            cell.txtProfit.text = [NSString stringWithFormat:@"%.2f%%",[[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"ProfitAmt"] floatValue ]];
            cell.txtProfit.delegate = self;
          //  cell.txtProfit.tag = indexPath.row;
            cell.txtProfit.keyboardType = UIKeyboardTypeNumberPad;

            // Remark FreeGoodsQty
            cell.txtRemarks.text = [NSString stringWithFormat:@"%@",[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"FreeGoodsQty"]];
            cell.txtRemarks.delegate = self;
        //    cell.txtRemarks.tag = indexPath.row;
            cell.txtRemarks.keyboardType = UIKeyboardTypeNumberPad;
            
            //swipedRecordID=indexPath.row;
            
            cell.btnEdit.tag = indexPath.row;
            [cell.btnEdit addTarget:self action:@selector(deliveryeditItem:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnCopy.tag = indexPath.row;
            [cell.btnCopy addTarget:self action:@selector(deliverycopyItem:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnDelete.tag = indexPath.row;
            [cell.btnDelete addTarget:self action:@selector(deliverydeleteItem:) forControlEvents:UIControlEventTouchUpInside];
            
            
            cell.btnBacktoOrder.tag = indexPath.row;
            [cell.btnBacktoOrder addTarget:self action:@selector(moveItembackToOrder:) forControlEvents:UIControlEventTouchUpInside];
            
            if(!isDeliveryUpdate)
            {
                cell.btnBacktoOrder.hidden=YES;
                cell.lblbacktitle.hidden=YES;
                cell.imgBackOrder.hidden=YES;
                cell.btnSelection.hidden=YES;
            }
            else{
                 cell.btnSelection.hidden=NO;
            }
            
            [cell.imgBackground setHidden:YES];
            
            cell.btnSelection.tag = indexPath.row;
            if([[(self.arrPendingDeliveryData)[indexPath.row] valueForKey:@"ItemSelection"] floatValue]){
                
                cell.backgroundColor=[UIColor colorWithRed:149.0/225.0 green:223.0/255.0 blue:198.0/255.0 alpha:1.0];
            }
            else{
                
            }
            
            [cell.btnSelection addTarget:self action:@selector(selecItem:) forControlEvents:UIControlEventTouchUpInside];
        
            return cell;
        }
    }
    return nil;
}

-(IBAction)selecItem:(id)sender{
    
    NSMutableDictionary *dicttemp = [(self.arrPendingDeliveryData)[[sender tag]]mutableCopy];
    
    if([dicttemp valueForKey:@"ItemSelection"]){
        
        [dicttemp removeObjectForKey:@"ItemSelection"];
    }
    else{
        dicttemp[@"ItemSelection"] = @"1";
    }
    (self.arrPendingDeliveryData)[[sender tag]] = dicttemp;
    [self.tblPendingDeliveryData reloadData];
}

-(void)moveItembackToOrder:(id)sender{
    
    
    dictItemOrderInfo=(self.arrPendingDeliveryData)[[sender tag]];
    
    NSIndexPath *indpath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    deleteOrderIndPath=indpath;
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self AddItembacktoOrder];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Are you sure you want back to order" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    
}


-(UILabel *)layoutSubviews:(UILabel*)laltemp
{
    CGSize constraintSize = laltemp.frame.size;
    constraintSize.height = 100;
    CGRect textRect = [laltemp.text boundingRectWithSize:constraintSize
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:laltemp.font}
                                                          context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = laltemp.frame;
    lblNameFrame.size.height = size.height;
    laltemp.frame = lblNameFrame;
    
    return laltemp;
    
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
          
          delivetyButtonPosition = [sender convertPoint:CGPointZero toView:self.tblOpenListData];
          
          if (infoDelivetyOption)
          {
              [tempviewController dismissViewControllerAnimated:YES completion:nil];
          }
          [_viewDeliveryOption removeFromSuperview];
          _viewDeliveryOption.hidden = NO;
          tempviewController.view = _viewDeliveryOption;
          
          // Present the view controller using the popover style.
          tempviewController.modalPresentationStyle = UIModalPresentationPopover;
          [self presentViewController:tempviewController animated:YES completion:nil];
          
          // Get the popover presentation controller and configure it.
          infoDelivetyOption = [tempviewController popoverPresentationController];
          infoDelivetyOption.delegate = self;
          tempviewController.preferredContentSize = CGSizeMake(tempviewController.view.frame.size.width, tempviewController.view.frame.size.height);
          infoDelivetyOption.permittedArrowDirections = UIPopoverArrowDirectionRight;
          infoDelivetyOption.sourceView = self.tblOpenListData;
          infoDelivetyOption.sourceRect = CGRectMake( delivetyButtonPosition.x, delivetyButtonPosition.y-95,340,264);
      }

}

-(IBAction)btnMenuClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}
#pragma mark -
#pragma mark Action Sheet

-(IBAction)openActionSheet:(id)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"More"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Item Info", @"Order Info",@"Send Email", nil];
    
    actionSheet.tag = 111;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag==111){
        
        if  (buttonIndex == 0) {
            

            [self btnItemInfoClick:nil];
        }
        else if(buttonIndex == 1){
            
            [self btnGenerateOdrInfoClick:nil];
        }
        else if(buttonIndex == 2){
            
            [self sendEmail:nil];
        }
    }

    
}
#pragma mark -
-(void)openOptioin:(id)sender{
    
    
}

-(void)didOpenOrderSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblPendingDeliveryData];
    NSIndexPath *swipedIndexPath = [self.tblPendingDeliveryData indexPathForRowAtPoint:location];
    self.indPath=swipedIndexPath;
    [self.tblPendingDeliveryData reloadData];
}

-(void)didOpenOrderSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tblPendingDeliveryData];
    NSIndexPath *swipedIndexPath = [self.tblPendingDeliveryData indexPathForRowAtPoint:location];
    if(self.indPath.row == swipedIndexPath.row)
    {
        self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
        [self.tblPendingDeliveryData reloadData];
    }
}

-(void)deliveryeditItem:(id)sender
{
    swipedRecordID = [sender tag];
    [self getClickedItemOpenListData:(self.arrPendingDeliveryData)[[sender tag]]];
}
-(void)deliverycopyItem:(id)sender
{
//    self._rimController.objPOMenuList.isCopyItem = YES;
    flgCopyButtonClicked=TRUE;
    [self getClickedItemOpenListData:(self.arrPendingDeliveryData)[[sender tag]]];
}

- (void)getClickedItemOpenListData:(NSIndexPath *)indexPath
{

    Item *anItem=[self fetchAllItems:[indexPath valueForKey:@"ItemId"]];
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[dictItemClicked[@"DepartId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (departmentList.count>0)
    {
        Department *department=departmentList.firstObject;
        dictItemClicked[@"DepartmentName"] = department.deptName;
    }
    else
    {
        dictItemClicked[@"DepartmentName"] = @"";
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        ItemInfoEditVC *objAddNew = [[ItemInfoEditVC alloc] initWithNibName:@"ItemInfoEditVC" bundle:nil];
        objAddNew.managedObjectContext = self.rmsDbController.managedObjectContext;
        if (objAddNew.itemInfoDataObject==nil) {
            objAddNew.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
        objAddNew.isCopy = YES;
        if(flgCopyButtonClicked)
        {
            //objAddNew.clickedButton=@"copy";
            dictItemClicked[@"Barcode"] = @"";
            flgCopyButtonClicked=FALSE;
        }
        [objAddNew.itemInfoDataObject setItemMainDataFrom:dictItemClicked];
        objAddNew.NewOrderCalled=TRUE;
        objAddNew.dictNewOrderData=(self.arrPendingDeliveryData)[swipedRecordID];
        if(!(flgCopyScanITem))
        {
            (objAddNew.dictNewOrderData)[@"indexpath"] = [NSString stringWithFormat:@"%ld",(long)swipedRecordID];
        }
//        objAddNew.objOpenList=self;
        objAddNew.itemInfoEditVCDelegate =self;
        [self.navigationController pushViewController:objAddNew animated:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else
    {
        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
        navigationInfo[@"NewOrderCalled"] = @(TRUE);
        navigationInfo[@"objOpenList"] = self;
        navigationInfo[@"swipedRecordID"] = [NSString stringWithFormat:@"%ld",(long)swipedRecordID];
        if(flgCopyButtonClicked)
        {
           // anItem.barcode = @"";
            dictItemClicked[@"Barcode"] = @"";
            flgCopyButtonClicked = FALSE;
        }
//        [self._rimController.objPOMenuList showInventoryAddNew:dictItemClicked navigationInfo:navigationInfo];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo {
    
    [newItemInfo removeObjectForKey:@"AddedQty"];
    [newItemInfo removeObjectForKey:@"DepartId"];
    [newItemInfo removeObjectForKey:@"DepartmentName"];
    [newItemInfo removeObjectForKey:@"ItemImage"];
    [newItemInfo removeObjectForKey:@"ItemDiscount"];
    [newItemInfo removeObjectForKey:@"MaxStockLevel"];
    [newItemInfo removeObjectForKey:@"MinStockLevel"];
    [newItemInfo removeObjectForKey:@"ItemTag"];
    [newItemInfo removeObjectForKey:@"Remark"];
    
    [newItemInfo setValue:@"0" forKey:@"ReOrder"];
    [newItemInfo setValue:@"0" forKey:@"FreeGoodsQty"];
    
    if (indexRow == -1) {
        [self.arrPendingDeliveryData insertObject:newItemInfo atIndex:0];
    }
    else {
        (self.arrPendingDeliveryData)[indexRow] = newItemInfo;
    }
    [self.tblPendingDeliveryData reloadData];
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
}
- (void)didUpdateItemInfo:(NSDictionary*)itemInfoData{
    
}
- (void)dismissInventoryAddNewSplitterVC{
    
}
//- (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo {
//    NSMutableArray *arrToStoreDict = [[[NSMutableArray alloc] init] mutableCopy];
//    
//    [self.dictNewOrderData removeObjectForKey:@"AddedQty"];
//    [self.dictNewOrderData removeObjectForKey:@"DepartId"];
//    [self.dictNewOrderData removeObjectForKey:@"DepartmentName"];
//    [self.dictNewOrderData removeObjectForKey:@"ItemImage"];
//    [self.dictNewOrderData removeObjectForKey:@"ItemDiscount"];
//    [self.dictNewOrderData removeObjectForKey:@"MaxStockLevel"];
//    [self.dictNewOrderData removeObjectForKey:@"MinStockLevel"];
//    [self.dictNewOrderData removeObjectForKey:@"ItemTag"];
//    [self.dictNewOrderData removeObjectForKey:@"Remark"];
//    [self.dictNewOrderData setValue:@"0" forKey:@"ReOrder"];
//    [self.dictNewOrderData setValue:@"0" forKey:@"FreeGoodsQty"];
//    
//    [arrToStoreDict addObject:self.dictNewOrderData];
//    
//    [self.objOpenList.arrPendingDeliveryData replaceObjectAtIndex:[[self.dictNewOrderData objectForKey:@"indexpath"]integerValue] withObject:self.dictNewOrderData];
//    [self.objOpenList.tblPendingDeliveryData reloadData];
//    self.objOpenList.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
//    [self.dictNewOrderData removeObjectForKey:@"indexpath"];
//    [_activityIndicator hideActivityIndicator];
//    
//}
-(void)deliverydeleteItem:(id)sender
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
        [self.tblPendingDeliveryData reloadData];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self.arrPendingDeliveryData removeObjectAtIndex:self.indPath.row];
        //[[[self.arrayGlobalPandingList firstObject]valueForKey:@"lstPendingItems"]removeObjectAtIndex:self.indPath.row];
        self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
        [self.tblPendingDeliveryData reloadData];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Are you sure want to delete this item in this order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(tableView == self.tblOpenListData)
    {
        clickedIndexPath = [indexPath copy];
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:[(self.arrOpenListData)[indexPath.row] valueForKey:@"PoId"] forKey:@"PoId"];
        
        //
        [itemparam setValue:[(self.arrOpenListData)[indexPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getClickedPODataResponse:response error:error];
                  });
        };
        
        self.editOpenPurchaseOrderWC = [self.editOpenPurchaseOrderWC initWithRequest:KURL actionName:WSM_GET_OPEN_PURCHASE_OREDR_DATA_NEW params:itemparam completionHandler:completionHandler];
    }
}


- (void)getClickedPODataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
	{
        // Barcode wise search result data
		if ([response isKindOfClass:[NSDictionary class]])
		{
			if ([[response  valueForKey:@"IsError"] intValue] == 0)
			{
                NSMutableArray *arrtempPoData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                         _objGenerate = [[GenerateOrderView alloc] initWithNibName:@"GenerateOrderView" bundle:nil];
                        _objGenerateIpad.pOmenuListVCDelegate=self.pOmenuListVCDelegate;
//                        _objGenerate.txtPOTitle.hidden=YES;
                        _objGenerate.managedObjectContext = self.rmsDbController.managedObjectContext;
                        _objGenerate.arrUpdatePoData = [arrtempPoData mutableCopy];
                        
                        [_objGenerate supplierDepartmentArray:[arrtempPoData mutableCopy]];
                        
                        _objGenerate.strPopUpDepartment = [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Departments"];
                        _objGenerate.strPopUpSupplier = [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Suppliers"];
                        _objGenerate.strPopUpTags = [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Tags"];
                        
        
                        _objGenerate.strPopUpTimeDuration = [arrtempPoData.firstObject valueForKey:@"TimeDuration"];
                        
           
                        if([_objGenerate.strPopUpTimeDuration isEqualToString:@"DateWise"])
                        {

                        
                        // from
                        
                        _objGenerate.strPopUpFromDate =[arrtempPoData.firstObject valueForKey:@"FromDate"] ;
                        
                        
                        // to Date
                        
                        
                        _objGenerate.strPopUpToDate =[arrtempPoData.firstObject valueForKey:@"ToDate"] ;
                        
                        }
                        
                        [self.navigationController pushViewController:_objGenerate animated:YES];
                    }
                    else
                    {
                        _objGenerateIpad = [[GenerateOrderView alloc] initWithNibName:@"GenerateOrderView" bundle:nil];
                        _objGenerateIpad.pOmenuListVCDelegate=self.pOmenuListVCDelegate;
//                        _objGenerateIpad.txtPOTitle.hidden=YES;
                        _objGenerateIpad.arrUpdatePoData = [arrtempPoData mutableCopy];
                        _objGenerateIpad.managedObjectContext = self.rmsDbController.managedObjectContext;
                        _objGenerateIpad.strPopUpDepartment = [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Departments"];
                        _objGenerateIpad.strPopUpSupplier = [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Suppliers"];
                        _objGenerateIpad.strPopUpTags = [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Tags"];
                        [_objGenerateIpad supplierDepartmentArray:[arrtempPoData mutableCopy]];
                        _objGenerateIpad.strPopUpTimeDuration = [arrtempPoData.firstObject valueForKey:@"TimeDuration"];
                        if([_objGenerateIpad.strPopUpTimeDuration isEqualToString:@"DateWise"])
                        {
                        // from
                        _objGenerateIpad.strPopUpFromDate =[arrtempPoData.firstObject valueForKey:@"FromDate"] ;
                        // to Date
                        _objGenerateIpad.strPopUpToDate =[arrtempPoData.firstObject valueForKey:@"ToDate"] ;
                        }
                        [self.navigationController pushViewController:_objGenerateIpad animated:FALSE];
//                        [self.pOmenuListVCDelegate showViewFromViewController:_objGenerateIpad];
//                        self._rimController.objPOMenuList.btnBackButtonClick.hidden=NO;
//                        [self._rimController.objPOMenuList showViewFromViewController:_objGenerateIpad];
                    }

            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No Open Record Found." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(NSString *)setFormatter :(NSDate *)date
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentDate = [dateFormatter dateFromString:dateString];
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *result = [df stringFromDate:currentDate];
    return result;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if(tableView == self.tblOpenListData)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblOpenListData)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            deleteOrderIndPath = [indexPath copy];
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
                [self.tblOpenListData setEditing:NO];
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

                NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
                [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                [itemparam setValue:[(self.arrOpenListData)[deleteOrderIndPath.row] valueForKey:@"PoId"] forKey:@"PoId"];
                
                [itemparam setValue:[(self.arrOpenListData)[deleteOrderIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
                
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self deleteOpenPoDataResponse:response error:error];
                         });
                };
                
                self.deleteOpenPoWC = [self.deleteOpenPoWC initWithRequest:KURL actionName:WSM_DELETE_OPEN_PO_NEW params:itemparam completionHandler:completionHandler];
            
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Are you sure want to delete this order details?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];

        }
    }
}

-(void)DeliverPO:(id)sender
{
    
    NSIndexPath *indPathTemp = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    clickedIndexPath = [indPathTemp copy];
    
    strDeliveryTitle = [(self.arrOpenListData)[[sender tag]] valueForKey:@"POTitle"];
    _txtInvoiceNo.text=@"";
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblOpenListData];
    NSIndexPath *deliverIndPath = [self.tblOpenListData indexPathForRowAtPoint:buttonPosition];
    insertDelPOIndPath = [deliverIndPath copy];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[(self.arrOpenListData)[deliverIndPath.row] valueForKey:@"PoId"] forKey:@"PoId"];
    [itemparam setValue:@"Pending" forKey:@"DeliveryStatus"];
    
    [itemparam setValue:[(self.arrOpenListData)[deliverIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self getPendingDeliveryDataResponse:response error:error];
            });
    };
    
    self.getpendingdeliverydataWC = [self.getpendingdeliverydataWC initWithRequest:KURL actionName:WSM_GET_PENDING_DELIVERY_DATA_NEW params:itemparam completionHandler:completionHandler];
}

- (void)getPendingDeliveryDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *arrtempDeliveryDataTemp = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                self.arrayGlobalPandingList=arrtempDeliveryDataTemp;
                
                NSMutableArray *arrtempDeliveryData = [arrtempDeliveryDataTemp.firstObject valueForKey:@"lstPendingItems"];
                
                
                if(arrtempDeliveryData.count>0)
                {
                    
                    self.strPopUpDepartment  =  [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Departments"];
                    
                    self.strPopUpSupplier = [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Suppliers"];
                    
                    self.strPopUpTags = [(self.arrOpenListData)[clickedIndexPath.row] valueForKey:@"Tags"];
                    
                    
                    
                    self.strPopUpTimeDuration = [arrtempDeliveryDataTemp.firstObject valueForKey:@"TimeDuration"];
                    
                    // from
                    
                    if([self.strPopUpTimeDuration isEqualToString:@"DateWise"])
                    {
                        self.strPopUpFromDate =[arrtempDeliveryDataTemp.firstObject valueForKey:@"FromDate"] ;
                        
                        
                        // to Date
                        
                        self.strPopUpToDate =[arrtempDeliveryDataTemp.firstObject valueForKey:@"ToDate"] ;
                    }
                    
                    [self.arrPendingDeliveryData removeAllObjects];
                    self.arrPendingDeliveryData=[arrtempDeliveryData mutableCopy];
                    
                    self.uvPendingDeliveryList.hidden = NO;
                    
                    self.btnDeliveryIn.hidden=YES;
                    //                        self._rimController.objPOMenuList.btnBackButtonClick.hidden=NO;
                    
                    [self.tblPendingDeliveryData reloadData];
                    [self.tblPendingDeliveryData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
                    {
                        [self.txtMainBarcode becomeFirstResponder];
                    }
                    else
                    {
                        [self.txtMainBarcode resignFirstResponder];
                    }
                }
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
    _lblDeliveryTitle.text=strDeliveryTitle;
    _lblDeliveryTitle.hidden=NO;
}

// Update delivery record
- (void)responseUpdateRecievePoDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                // Delivery
                if([self.poStatus isEqualToString:@"Delivery"])
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                        {
                            isDeliveryUpdate=NO;
                        }
                        else{
                            isDeliveryUpdate=YES;
                        }
                        [self btnBackClicked:nil];
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Order has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    
                }
                else if([self.poStatus isEqualToString:@"Close"])
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                        {
                            isDeliveryUpdate=NO;
                        }
                        else{
                            isDeliveryUpdate=YES;
                        }
                        [self btnBackClicked:nil];
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Order has been closed successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    
                }
                else // other than delivery and close
                {
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                        {
                            isDeliveryUpdate=NO;
                        }
                        else{
                            isDeliveryUpdate=YES;
                        }
                        [self btnBackClicked:nil];
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Order has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    
                }
            }
            else
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

- (void)deleteOpenPoDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
	{
        // Barcode wise search result data
		if ([response isKindOfClass:[NSDictionary class]])
		{
			if ([[response  valueForKey:@"IsError"] intValue] == 0)
			{
                [self.arrOpenListData removeObjectAtIndex:deleteOrderIndPath.row];
                [self.tblOpenListData reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Open order details has been deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteOpenPoResult" object:nil];
}

#pragma mark - Footer Method

-(IBAction)btnSearchClick:(id)sender
{
//    POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionVC" bundle:nil];
//    
//    itemMultipleVC.checkSearchRecord = TRUE;
//    //        itemMultipleVC.objOpenList = self;
//    itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
//    itemMultipleVC.flgRedirectToOpenList = TRUE;
//    [self.navigationController pushViewController:itemMultipleVC animated:NO];
    NSString * strNibName = @"POMultipleItemSelectionHeaderVC";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        strNibName = @"POMultipleItemSelectionVC";
    }
    
    POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:strNibName bundle:nil];
    
    itemMultipleVC.checkSearchRecord = TRUE;
    itemMultipleVC.flgRedirectToGenerateOdr = TRUE;
    itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:itemMultipleVC animated:TRUE];
    }
    else {
        //        [self.navigationController pushViewController:itemMultipleVC animated:FALSE];
        [self presentViewController:itemMultipleVC animated:false completion:nil];
        
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
    self.txtMainBarcode.text = strBarcode;
    [self textFieldShouldReturn:self.txtMainBarcode];
}

-(IBAction)btnAddItemClick:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"You don't have rights to add new item. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

//    self._rimController.objPOMenuList.btnBackButtonClick.hidden=YES;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        ItemInfoEditVC *objInventoryAdd = [[ItemInfoEditVC alloc] initWithNibName:@"ItemInfoEditVC" bundle:nil];
        objInventoryAdd.NewOrderCalled=TRUE;
        objInventoryAdd.itemInfoEditVCDelegate=self;
        [self.navigationController pushViewController:objInventoryAdd animated:YES];
    }
    else
    {
        // Present InventoryAddNewSplitterVC
        NSMutableDictionary *navigationInfo = [[NSMutableDictionary alloc] init ];
        navigationInfo[@"NewOrderCalled"] = @(TRUE);
        navigationInfo[@"objOpenList"] = self;
        
        ItemDetailEditVC *addNewSplitterVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
        //addNewSplitterVC.item = item;
        addNewSplitterVC.selectedItemInfoDict=nil;
        addNewSplitterVC.navigationInfo = [navigationInfo mutableCopy];
        addNewSplitterVC.isItemCopy = FALSE;
        addNewSplitterVC.itemInfoEditRedirectionVCDelegate = self;
        addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self.pOmenuListVCDelegate willPresentViewController:addNewSplitterVC animated:YES completion:nil];

//        [self._rimController.objPOMenuList showInventoryAddNew:nil navigationInfo:navigationInfo];
    }
}

- (NSMutableArray *) PoReceiveDetailxml
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.arrPendingDeliveryData.count>0)
    {
        for (int isup=0; isup<self.arrPendingDeliveryData.count; isup++)
        {
            
            NSMutableDictionary *tmpSup = [(self.arrPendingDeliveryData)[isup] mutableCopy ];
            
//            public long ItemCode { get; set; }
//            public long ReOrder { get; set; }
//            public long FreeGoodsQty { get; set; }
//            public long AvailQty { get; set; }
//            public decimal Cost { get; set; }
//            public decimal Price { get; set; }
//            public decimal Margin { get; set; }
            
//            Barcode = 080480545406;
//            CreatedDate = "03/08/2014 07:02:50";
//            ItemName = "B & B DOM  LIQUOR ";
//            ProfitType = MarkUp;
            
           
            /*[tmpOdrDict removeObjectForKey:@"Barcode"];
            [tmpOdrDict removeObjectForKey:@"CreatedDate"];
            [tmpOdrDict removeObjectForKey:@"ItemName"];
            [tmpOdrDict removeObjectForKey:@"ProfitType"];*/
            
            [tmpSup setValue:[tmpSup valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpSup setValue:[tmpSup valueForKey:@"avaibleQty" ] forKey:@"AvailQty"];
            [tmpSup setValue:[tmpSup valueForKey:@"CostPrice" ] forKey:@"Cost"];
            [tmpSup setValue:[tmpSup valueForKey:@"SalesPrice" ] forKey:@"Price"];
            [tmpSup setValue:[tmpSup valueForKey:@"ProfitAmt" ] forKey:@"Margin"];
            
    
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"ItemCode",@"ReOrder",@"FreeGoodsQty",@"AvailQty",@"Cost",@"Price",@"Margin"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];

            
            /*[tmpOdrDict removeObjectForKey:@"ItemId"];
            [tmpOdrDict removeObjectForKey:@"avaibleQty"];
            [tmpOdrDict removeObjectForKey:@"CostPrice"];
            [tmpOdrDict removeObjectForKey:@"SalesPrice"];
            [tmpOdrDict removeObjectForKey:@"ProfitAmt"];*/
            
            
            [tmpSup removeObjectForKey:@"Rvalue"];
            [tmpSup removeObjectForKey:@"Gvalue"];
            [tmpSup removeObjectForKey:@"NewAdded"];
            [tmpSup removeObjectForKey:@"ItemSelection"];
            
            [itemSupplierData addObject:tmpSup];
        }
    }
	return itemSupplierData;
}

-(IBAction)btnSaveOrderClick:(id)sender
{
    if(isDeliveryUpdate) // Update existing Purchase order
    {
        if(_txtInvoiceNo.text.length == 0)
        {
            
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please enter invoice no." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
        // UpdateRecievePoDetail(PoReceiveDetailxml[] PoRecieveDetailxml,string PO_No, long PurchaseOrderId, long BranchId, long UserId, string InvoiceNo, string POstatus)
        
        NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
        dictPODetail[@"PoRecieveDetailxml"] = [self PoReceiveDetailxml];
        
        // get logged in user branch id and user id.
        
        [dictPODetail setValue:self.strSelectedPO_No forKey:@"PO_No"];
        [dictPODetail setValue:self.strSelectedPurOrdId forKey:@"PurchaseOrderId"];
        [dictPODetail setValue:self.strSelectedRecieveId forKey:@"RecieveId"];
        
        // hiten 20082014
        
        // [dictPODetail setObject:[[self.arrayGlobalPandingList firstObject] objectForKey:@"OrderN"] forKey:@"OrderNo"];
        
        dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
        dictPODetail[@"UserId"] = userID;
        
        [dictPODetail setValue:_txtInvoiceNo.text forKey:@"InvoiceNo"];
        [dictPODetail setValue:@"Delivery" forKey:@"POstatus"];
        self.poStatus = @"Delivery";
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *strDateTime = [formatter stringFromDate:date];

        [dictPODetail setValue:strDateTime forKey:@"DateTime"];
        
        dictPODetail[@"OpenOrderId"] = self.arrayGlobalPandingList.firstObject[@"OpenOrderId"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self responseUpdateRecievePoDetailResponse:response error:error];
                 });
        };
        
        self.updateRecievePoDetailWC = [self.updateRecievePoDetailWC initWithRequest:KURL actionName:WSM_UPDATE_RECIEVE_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
    
        
    }
    else // Add New Purchase order
    {
        if(_txtInvoiceNo.text.length == 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please enter invoice no." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

        
        // insertReceivePODetail(PoReceiveDetailxml[] PoRecieveDetailxml, string PO_No, long PurchaseOrderId, long BranchId, long UserId, string InvoiceNo, string POstatus)
        
        NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
        dictPODetail[@"PoRecieveDetailxml"] = [self PoReceiveDetailxml];
        
        // get logged in user branch id and user id.
        
        if(self.arrOpenListData.count>0)
        {
            [dictPODetail setValue:[(self.arrOpenListData)[insertDelPOIndPath.row] valueForKey:@"PO_No"] forKey:@"PO_No"];
            [dictPODetail setValue:[(self.arrOpenListData)[insertDelPOIndPath.row] valueForKey:@"PoId"] forKey:@"PurchaseOrderId"];
            
             [dictPODetail setValue:[(self.arrOpenListData)[insertDelPOIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
        }
        else{
            
            [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"PO_No"] forKey:@"PO_No"];
            [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"PurchaseOrderId"] forKey:@"PurchaseOrderId"];
            
             [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];

        }
      
        
        dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
        dictPODetail[@"UserId"] = userID;
        
        [dictPODetail setValue:_txtInvoiceNo.text forKey:@"InvoiceNo"];
        [dictPODetail setValue:@"Delivery" forKey:@"POstatus"];
        self.poStatus = @"Delivery";
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *strDateTime = [formatter stringFromDate:date];
        [dictPODetail setValue:strDateTime forKey:@"DateTime"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self responseinsertReceivePODetailResponse:response error:error];
                  });
        };
        
        self.insertReceivePODetailWC = [self.insertReceivePODetailWC initWithRequest:KURL actionName:WSM_INSERT_RECIEVE_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
    }
}

// insert delivery record
- (void)responseinsertReceivePODetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                if([self.poStatus isEqualToString:@"Delivery"])
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Delivery has been saved successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    
                }
                else if([self.poStatus isEqualToString:@"Close"])
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Delivery has been closed successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    
                }
                else // if other than Delivery and Close
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Delivery has been saved successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
                
                [self.arrPendingDeliveryData removeAllObjects];
                
                if(self.booltoolbardelivery)
                {
                    
                    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        
                        NSArray *arrayViecon = self.navigationController.viewControllers;
                        for(UIViewController *viewcon in arrayViecon){
                            if([viewcon isKindOfClass:[POmenuListVC class]]){
                                
                                [self.navigationController popToViewController:viewcon animated:YES];
                            }
                        }
                        
                    }
                    else{
                        
                        /* OpenListViewController *objOpenListIpad = [[OpenListViewController alloc] initWithNibName:@"OpenListViewController_iPad" bundle:nil];
                         
                         [self._rimController.objPOMenuList showViewFromViewController:objOpenListIpad];*/
                        
                        //                        self._rimController.objPOMenuList.objSideMenuMainPO.indPath=[NSIndexPath indexPathForRow:3 inSection:0];
                        //                        [self._rimController.objPOMenuList menuButtonOperationCell:self._rimController.objPOMenuList.objSideMenuMainPO.indPath.row];
                        
                    }
                    
                    
                }
                else{
                    [self.arrOpenListData removeObjectAtIndex:insertDelPOIndPath.row];
                    [self.tblOpenListData reloadData];
                    [self btnBackClicked:nil];
                }
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

-(IBAction)btnSave_CloseClick:(id)sender
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
         [self funSaveandClose];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Are you sure want to update any changes in order ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)funSaveandClose
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strcurrentDateTime = [formatter stringFromDate:date];
    

    if(isDeliveryUpdate) // Update existing Purchase order
    {
        if(_txtInvoiceNo.text.length == 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Please enter invoice no" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
        
        // UpdateRecievePoDetail(PoReceiveDetailxml[] PoRecieveDetailxml,string PO_No, long PurchaseOrderId, long BranchId, long UserId, string InvoiceNo, string POstatus)
        
        NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
        dictPODetail[@"PoRecieveDetailxml"] = [self PoReceiveDetailxml];
        
        // get logged in user branch id and user id.
        
        [dictPODetail setValue:self.strSelectedPO_No forKey:@"PO_No"];
        [dictPODetail setValue:self.strSelectedPurOrdId forKey:@"PurchaseOrderId"];
        [dictPODetail setValue:self.strSelectedRecieveId forKey:@"RecieveId"];
        
        // hiten 20082014
        
        // [dictPODetail setObject:[[self.arrayGlobalPandingList firstObject] objectForKey:@"OrderN"] forKey:@"OrderNo"];
        
        dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
        dictPODetail[@"UserId"] = userID;
        
        [dictPODetail setValue:_txtInvoiceNo.text forKey:@"InvoiceNo"];
        [dictPODetail setValue:strcurrentDateTime forKey:@"DateTime"];
        [dictPODetail setValue:@"Close" forKey:@"POstatus"];
        
        [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
        
        
        self.poStatus = @"Close";
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self responseUpdateRecievePoDetailResponse:response error:error];
                   });
        };
        
        self.updateRecievePoDetailWC2 = [self.updateRecievePoDetailWC2 initWithRequest:KURL actionName:WSM_UPDATE_RECIEVE_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
        
    }
    else // Add New Purchase order
    {
        if(_txtInvoiceNo.text.length == 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Open Order | Delivery" message:@"Please enter invoice no" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    
            return;
        }
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
        
        // insertReceivePODetail(PoReceiveDetailxml[] PoRecieveDetailxml, string PO_No, long PurchaseOrderId, long BranchId, long UserId, string InvoiceNo, string POstatus)
        
        NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
        dictPODetail[@"PoRecieveDetailxml"] = [self PoReceiveDetailxml];
        
        // get logged in user branch id and user id.
        
        if(self.arrOpenListData.count>0)
        {
        
            [dictPODetail setValue:[(self.arrOpenListData)[insertDelPOIndPath.row] valueForKey:@"PO_No"] forKey:@"PO_No"];
            [dictPODetail setValue:[(self.arrOpenListData)[insertDelPOIndPath.row] valueForKey:@"PoId"] forKey:@"PurchaseOrderId"];
            
            [dictPODetail setValue:[(self.arrOpenListData)[insertDelPOIndPath.row] valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
            
        }
        else{
            
            [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"PO_No"] forKey:@"PO_No"];
            [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"PurchaseOrderId"] forKey:@"PurchaseOrderId"];
            
            [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
        
        }
        
        dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
        dictPODetail[@"UserId"] = userID;
        
        [dictPODetail setValue:_txtInvoiceNo.text forKey:@"InvoiceNo"];
        [dictPODetail setValue:strcurrentDateTime forKey:@"DateTime"];
        [dictPODetail setValue:@"Close" forKey:@"POstatus"];
    
        self.poStatus = @"Close";
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responseinsertReceivePODetailResponse:response error:error];
            });
        };
        self.insertReceivePODetailWC2 = [self.insertReceivePODetailWC2 initWithRequest:KURL actionName:WSM_INSERT_RECIEVE_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];

    }
}

-(IBAction)btnItemInfoClick:(id)sender
{
    float totalQTYeach = 0;
    float totalCostPrice = 0;
    for( int iArr = 0 ; iArr < self.arrPendingDeliveryData.count; iArr++)
    {
        // Calculate Total CostPrice
        int iQty = [(self.arrPendingDeliveryData)[iArr][@"ReOrder"] intValue ];
        totalQTYeach = totalQTYeach + iQty;
        
        float iCost = [(self.arrPendingDeliveryData)[iArr][@"CostPrice"] floatValue ];
        totalCostPrice = totalCostPrice + (iQty * iCost);
        
    }
    
    _lblTotalItem.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.arrPendingDeliveryData.count];
    _lblTotalReOrderQTY.text = [NSString stringWithFormat:@"%.0f",totalQTYeach];
    _lblTotalCost.text = [NSString stringWithFormat:@"%.2f",totalCostPrice];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [_uvItemInformation setHidden:NO];
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if(screenBounds.size.height == 568)
        {
            _uvItemInformation.frame = CGRectMake(_uvItemInformation.frame.origin.x, 366, 320.0, 154.0);
        }
        else{
            _uvItemInformation.frame = CGRectMake(_uvItemInformation.frame.origin.x, 278, 320.0, 154.0);
            
        }
        [self.view bringSubviewToFront:_uvItemInformation];
        
    }
    else
    {
        if (infopopoverController)
        {
            [itemInformationViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [_uvItemInformation removeFromSuperview];
        _uvItemInformation.hidden = NO;
        itemInformationViewController.view = _uvItemInformation;
        
        // Present the view controller using the popover style.
        itemInformationViewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:itemInformationViewController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        infopopoverController = [itemInformationViewController popoverPresentationController];
        infopopoverController.delegate = self;
        itemInformationViewController.preferredContentSize = CGSizeMake(itemInformationViewController.view.frame.size.width, itemInformationViewController.view.frame.size.height);
        infopopoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        infopopoverController.sourceView = self.view;
        infopopoverController.sourceRect = CGRectMake(self.btnTotalItemInfo.frame.origin.x,
                                                      653,
                                                      self.btnTotalItemInfo.frame.size.width,
                                                      self.btnTotalItemInfo.frame.size.height);
    }
}


-(IBAction)hideItemInfoview:(id)sender{
    [_uvItemInformation setHidden:YES];
}
-(IBAction)btnGenerateOdrInfoClick:(id)sender
{
   /* if(strPopUpDepartment.length > 0)
        lblPopUpDepartment.text = [NSString stringWithFormat:@"Department : %@",strPopUpDepartment];
    else
        lblPopUpDepartment.text = @"";
    
    if(strPopUpSupplier.length > 0)
        lblPopUpSupplier.text = [NSString stringWithFormat:@"supplier : %@",strPopUpSupplier];
    else
        lblPopUpSupplier.text = @"";
    
    if(strPopUpTags.length > 0)
        lblPopUpTags.text = [NSString stringWithFormat:@"Tags : %@",strPopUpTags];
    else
        lblPopUpTags.text = @"";*/
    
    
    if(self.strPopUpFromDate.length > 0)
        self.lblPopUpFromDate.text = [NSString stringWithFormat:@"From Date: %@",self.strPopUpFromDate];
    else
        self.lblPopUpFromDate.text = @"";
    
    
    if(self.strPopUpToDate.length > 0)
        self.lblPopUpToDate.text = [NSString stringWithFormat:@"To Date: %@",self.strPopUpToDate];
    else
        self.lblPopUpToDate.text = @"";
    
    if(self.strPopUpTimeDuration.length > 0)
        self.lblPopUpTimeDuration.text = [NSString stringWithFormat:@"Time Duration: %@",self.strPopUpTimeDuration];
    else
        self.lblPopUpTimeDuration.text = @"None";
    
    
    if(self.strPopUpDepartment.length > 0)
       self.lblPopUpDepartment.text = [NSString stringWithFormat:@"Department: %@",self.strPopUpDepartment];
    else
        self.lblPopUpDepartment.text = @"";
    
    if(self.strPopUpSupplier.length > 0)
        self.lblPopUpSupplier.text = [NSString stringWithFormat:@"Supplier: %@",self.strPopUpSupplier];
    else
        self.lblPopUpSupplier.text = @"";
    
    if(self.strPopUpTags.length > 0)
        self.lblPopUpTags.text = [NSString stringWithFormat:@"Tags: %@",self.strPopUpTags];
    else
        self.lblPopUpTags.text = @"";
    
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [_uvGenerateOrderInfo setHidden:NO];
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if(screenBounds.size.height == 568)
        {
            _uvGenerateOrderInfo.frame = CGRectMake(0, 231, 320.0, 288.0);
        }
        else{
            _uvGenerateOrderInfo.frame = CGRectMake(0, 173, 320.0, 258.0);
            
        }
        [self.view bringSubviewToFront:_uvGenerateOrderInfo];

    }
    else
    {
        if (infopopoverController)
        {
            [generateOrderInfoViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [_uvGenerateOrderInfo removeFromSuperview];
        _uvGenerateOrderInfo.hidden = NO;
        generateOrderInfoViewController.view = _uvGenerateOrderInfo;
        
        // Present the view controller using the popover style.
        generateOrderInfoViewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:generateOrderInfoViewController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        infopopoverController = [generateOrderInfoViewController popoverPresentationController];
        infopopoverController.delegate = self;
        generateOrderInfoViewController.preferredContentSize = CGSizeMake(generateOrderInfoViewController.view.frame.size.width, generateOrderInfoViewController.view.frame.size.height);
        infopopoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        infopopoverController.sourceView = self.view;
        infopopoverController.sourceRect = CGRectMake(self.btnGenereteOdrinfo.frame.origin.x,
                                                      653,
                                                      self.btnGenereteOdrinfo.frame.size.width,
                                                      self.btnGenereteOdrinfo.frame.size.height);
    }
}
-(IBAction)hideuvGenerateOrderInfo:(id)sender{
    [_uvGenerateOrderInfo setHidden:YES];
}
-(void)deviceButtonPressed:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"OpenList"])
        {
            [status setString:@""];
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"OpenList"])
        {
            if(![status isEqualToString:@""])
            {
                [self searchScannedBarcode];
            }
        }
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status setString:@""];
        self.txtMainBarcode.text = barcode;
        [status appendFormat:@"%@", barcode];
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please set scanner type as scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }

}

- (void)searchScannedBarcode
{
    BOOL isScanItemfound = FALSE;
    
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcode==%@ AND active == %d", self.txtMainBarcode.text,TRUE];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    
    NSMutableDictionary *dictTempGlobal = [item.itemRMSDictionary mutableCopy];
    
    if(dictTempGlobal != nil)
    {
        dictTempGlobal[@"AddedQty"] = @"1";
        
        NSString * strItemCode=[NSString stringWithFormat:@"%d",[[dictTempGlobal valueForKey:@"ItemId"]intValue]];
        
        BOOL isExtisData=FALSE;
        
        if(self.arrPendingDeliveryData.count>0)
        {
            for (int idata=0; idata<self.arrPendingDeliveryData.count; idata++) {
                NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.arrPendingDeliveryData)[idata]valueForKey:@"ItemId"]intValue]];
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
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"%@ item already existed.",self.txtMainBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            [dictTempGlobal removeObjectForKey:@"DepartId"];
            [dictTempGlobal removeObjectForKey:@"ItemDiscount"];
            [dictTempGlobal removeObjectForKey:@"ItemImage"];
            [dictTempGlobal removeObjectForKey:@"ItemSupplierData"];
            [dictTempGlobal removeObjectForKey:@"ItemTag"];
            [dictTempGlobal removeObjectForKey:@"ProfitAmt"];
            [dictTempGlobal removeObjectForKey:@"ProfitType"];
            [dictTempGlobal removeObjectForKey:@"Remark"];
            [dictTempGlobal removeObjectForKey:@"SalesPrice"];
            [dictTempGlobal removeObjectForKey:@"selected"];
            [dictTempGlobal removeObjectForKey:@"ItemNo"];
            
            [dictTempGlobal removeObjectForKey:@"EBT"];
            [dictTempGlobal removeObjectForKey:@"NoDiscountFlg"];
            [dictTempGlobal removeObjectForKey:@"POSDISCOUNT"];
            [dictTempGlobal removeObjectForKey:@"TaxType"];
            [dictTempGlobal removeObjectForKey:@"isTax"];
            
            
            [dictTempGlobal setValue:@"0" forKey:@"FreeGoodsQty"];
            [dictTempGlobal setValue:@"0" forKey:@"ReOrder"];
            
            [self.arrPendingDeliveryData insertObject:dictTempGlobal atIndex:0];
            [self.tblPendingDeliveryData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self.tblPendingDeliveryData reloadData];
        }
        isScanItemfound = TRUE;
        [self.txtMainBarcode becomeFirstResponder];
    }
    if(!isScanItemfound)
    {
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:self.txtMainBarcode.text forKey:@"Code"];
        [itemparam setValue:@"Barcode" forKey:@"Type"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self responsePendingDeliveryDataResponse:response error:error];
                  });
        };
        
        self.mgmtItemInsertWC = [self.mgmtItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
        
    }
}

-(void)responsePendingDeliveryDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if(response!=nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            
            NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
            if(itemResponseArray.count > 0)
            {
                NSDictionary * itemDict =itemResponseArray.firstObject;
                if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"0"]) // if not active item
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"This Item is currently not Activated." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    [self.tblPendingDeliveryData reloadData];
                }
                else {
                    [self.updateManagerOpenList updateObjectsFromResponseDictionary:responseDictionary];
                    [self.updateManagerOpenList linkItemToDepartmentFromResponseDictionary:responseDictionary];
                    Item *anItem=[self fetchAllItems:[[[responseDictionary valueForKey:@"ItemArray"] firstObject ]valueForKey:@"ITEMCode"]];
                    NSMutableDictionary *dictTempGlobal = [NSMutableDictionary dictionaryWithDictionary:anItem.itemRMSDictionary];
                    
                    [dictTempGlobal removeObjectForKey:@"DepartId"];
                    [dictTempGlobal removeObjectForKey:@"ItemDiscount"];
                    [dictTempGlobal removeObjectForKey:@"ItemImage"];
                    [dictTempGlobal removeObjectForKey:@"ItemSupplierData"];
                    [dictTempGlobal removeObjectForKey:@"ItemTag"];
                    [dictTempGlobal removeObjectForKey:@"ProfitAmt"];
                    [dictTempGlobal removeObjectForKey:@"ProfitType"];
                    [dictTempGlobal removeObjectForKey:@"Remark"];
                    [dictTempGlobal removeObjectForKey:@"SalesPrice"];
                    [dictTempGlobal removeObjectForKey:@"selected"];
                    [dictTempGlobal removeObjectForKey:@"ItemNo"];
                    
                    [dictTempGlobal removeObjectForKey:@"EBT"];
                    [dictTempGlobal removeObjectForKey:@"NoDiscountFlg"];
                    [dictTempGlobal removeObjectForKey:@"POSDISCOUNT"];
                    [dictTempGlobal removeObjectForKey:@"TaxType"];
                    [dictTempGlobal removeObjectForKey:@"isTax"];
                    
                    [dictTempGlobal setValue:@"0" forKey:@"ReOrder"];
                    [dictTempGlobal setValue:@"0" forKey:@"FreeGoodsQty"];
                    
                    [self.arrPendingDeliveryData insertObject:dictTempGlobal atIndex:0];
                    [self.tblPendingDeliveryData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    [self.tblPendingDeliveryData reloadData];
                }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"No Record Found for %@",self.txtMainBarcode.text] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
    }
}


- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d AND active == %d", itemId.integerValue,TRUE];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
   
    if (_txtInvoiceNo.text.length >= 25 && range.length == 0)
    {
    	return NO; // return NO to not change text
    }
    
    return YES;
}
-(IBAction)iphoneback:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)insertDidFinish {
}
#pragma mark -
#pragma mark Create Pdf
-(IBAction)btn_ExportClick:(id)sender{
    
    [self.rmsDbController playButtonSound];
    if (emailPdfPopOverController)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [_emailPdfView removeFromSuperview];
    _emailPdfView.hidden = NO;
    emailPdfViewController.view = _emailPdfView;
    
    // Present the view controller using the popover style.
    emailPdfViewController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:emailPdfViewController animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    emailPdfPopOverController = [emailPdfViewController popoverPresentationController];
    emailPdfPopOverController.delegate = self;
    emailPdfViewController.preferredContentSize = CGSizeMake(emailPdfViewController.view.frame.size.width, emailPdfViewController.view.frame.size.height);
    emailPdfPopOverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    emailPdfPopOverController.sourceView = self.view;
    emailPdfPopOverController.sourceRect = CGRectMake(_pdfEmailBtn.frame.origin.x,
                                                      653,
                                                      _pdfEmailBtn.frame.size.width,
                                                      _pdfEmailBtn.frame.size.height);
}

-(IBAction)sendEmail:(id)sender{
    
    if(self.arrayGlobalPandingList.count>0)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillText:self.arrayGlobalPandingList];

    }
}

//hiten

-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"deliverypanding" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:self.arrPendingDeliveryData];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController_iPhone"];
    }
    else{
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
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"%@",@"Open Order"]];
    
    if(_txtInvoiceNo.text.length>0)
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$INVOICE_NO$$" withString:[NSString stringWithFormat:@"%@",_txtInvoiceNo.text]];
    }
    else{
         html = [html stringByReplacingOccurrencesOfString:@"$$INVOICE_NO$$" withString:@""];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ORDER_TITLE$$" withString:[NSString stringWithFormat:@"%@",[arrayInvoice.firstObject valueForKey:@"POTitle"]]];
    
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    NSString *CreatedDate = [arrayInvoice.firstObject valueForKey:@"CreatedDate"];
    
     NSString *strDate = [self getStringFormate:CreatedDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MM/dd/yyyy"];

    NSString *strTime = [self getStringFormate:CreatedDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
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
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%.2f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"avaibleQty"],[itemDictionary[@"ReOrder"]floatValue],[itemDictionary[@"CostPrice"]floatValue],[itemDictionary[@"SalesPrice"]floatValue],[itemDictionary[@"ProfitAmt"]floatValue],itemDictionary[@"FreeGoodsQty"]];
    
    return htmldata;
    
}


-(void)AddItembacktoOrder{
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strcurrentDateTime = [formatter stringFromDate:date];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary *dictPODetail = [[NSMutableDictionary alloc]init];

    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    dictPODetail[@"ItemCode"] = [dictItemOrderInfo valueForKey:@"ItemId"];
    dictPODetail[@"AvailQty"] = [dictItemOrderInfo valueForKey:@"avaibleQty"];
    dictPODetail[@"ReOrder"] = [dictItemOrderInfo valueForKey:@"ReOrder"];
    dictPODetail[@"FreeGoodsQty"] = [dictItemOrderInfo valueForKey:@"FreeGoodsQty"];

    dictPODetail[@"LocalDateTime"] = strcurrentDateTime;
    
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictPODetail[@"UserId"] = userID;
    
    [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
    
    [dictPODetail setValue:[self.arrayGlobalPandingList.firstObject valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addBacktoOpenResultResponse:response error:error];
            });
    };
    
    self.addBacktoOpenOrderWC = [self.addBacktoOpenOrderWC initWithRequest:KURL actionName:WSM_ADD_PURCHASE_BACK_ORDER params:dictPODetail completionHandler:completionHandler];
}
    
- (void)addBacktoOpenResultResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
	{
        // Barcode wise search result data
		 if ([response isKindOfClass:[NSDictionary class]])
		{
			if ([[response  valueForKey:@"IsError"] intValue] == 0)
			{
                [self.arrPendingDeliveryData removeObjectAtIndex:deleteOrderIndPath.row];
                [self.tblPendingDeliveryData reloadData];
                self.indPath = [NSIndexPath indexPathForRow:-1 inSection:0];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Back to open moved." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Error occur while moving order details, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(IBAction)deliveryListScan:(id)sender{
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {

        DeliveryListScanVC *objScan = [[DeliveryListScanVC alloc]initWithNibName:@"DeliveryListScanVC" bundle:nil];
        
        for(int i=0;i<self.arrPendingDeliveryData.count;i++) {
            
            NSMutableDictionary *dict= (self.arrPendingDeliveryData)[i];
            [dict removeObjectForKey:@"Rvalue"];
            [dict removeObjectForKey:@"Gvalue"];
            [dict removeObjectForKey:@"NewAdded"];
            [dict removeObjectForKey:@"ItemSelection"];
            
        }
        objScan.arrayDeliveryItemList=[self.arrPendingDeliveryData mutableCopy];
        objScan.objOpenList=self;
        [self.navigationController pushViewController:objScan animated:YES];
    }
    else{
        
        DeliveryListScanVC *objScan = [[DeliveryListScanVC alloc]initWithNibName:@"DeliveryListScanVC" bundle:nil];
        
        for(int i=0;i<self.arrPendingDeliveryData.count;i++) {
            
            NSMutableDictionary *dict= (self.arrPendingDeliveryData)[i];
            
            [dict removeObjectForKey:@"Rvalue"];
            [dict removeObjectForKey:@"Gvalue"];
            [dict removeObjectForKey:@"NewAdded"];
            [dict removeObjectForKey:@"ItemSelection"];

            
        }
        objScan.arrayDeliveryItemList=[self.arrPendingDeliveryData mutableCopy];
        objScan.objOpenList=self;
        [self.pOmenuListVCDelegate willPushViewController:objScan animated:YES];
//          [self._rimController.objPOMenuList.navigationController pushViewController:objScan animated:YES];
    }
  
    
}
//hiten
-(IBAction)previewandPrint:(id)sender{
    
    if(self.arrayGlobalPandingList.count>0)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillTextForPreview:self.arrayGlobalPandingList];
    }
}
-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"deliverypanding" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:self.arrPendingDeliveryData];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceipt.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    
    
    
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    // objPreviewandPrint.strPdfFilePath=htmlToPDF.PDFpath;
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

-(void)didSelectionChangeInPOMultipleItemSelectionVC:(NSMutableArray *) selectedObject{
    for(int i=0;i<selectedObject.count;i++)
    {
        NSMutableDictionary *dictSelected = [selectedObject[i]mutableCopy];
        if([dictSelected  valueForKey:@"selected"])
        {
            //recordCount +=1;
            
            // removed unnecessery object from array
            [dictSelected removeObjectForKey:@"AddedQty"];
            [dictSelected removeObjectForKey:@"DepartId"];
            [dictSelected removeObjectForKey:@"DepartmentName"];
            [dictSelected removeObjectForKey:@"ItemDiscount"];
            [dictSelected removeObjectForKey:@"ItemImage"];
            [dictSelected removeObjectForKey:@"ItemSupplierData"];
            [dictSelected removeObjectForKey:@"ItemTag"];
            [dictSelected removeObjectForKey:@"MaxStockLevel"];
            [dictSelected removeObjectForKey:@"MinStockLevel"];
            [dictSelected removeObjectForKey:@"selected"];
            [dictSelected removeObjectForKey:@"ItemNo"];
            
            [dictSelected removeObjectForKey:@"EBT"];
            [dictSelected removeObjectForKey:@"NoDiscountFlg"];
            [dictSelected removeObjectForKey:@"POSDISCOUNT"];
            [dictSelected removeObjectForKey:@"TaxType"];
            [dictSelected removeObjectForKey:@"isTax"];
            [dictSelected removeObjectForKey:@"Remark"];
            
            [dictSelected setValue:@"0" forKey:@"FreeGoodsQty"];
            [dictSelected setValue:@"0" forKey:@"ReOrder"];
            
            [self.arrPendingDeliveryData insertObject:dictSelected atIndex:0];
        }
    }
    [self.tblPendingDeliveryData reloadData];
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
