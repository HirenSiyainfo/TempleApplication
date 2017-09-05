//
//  PurchaseOrderFilterListDetail.m
//  RapidRMS
//
//  Created by Siya on 14/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PurchaseOrderFilterListDetail.h"
#import "RmsDbController.h"
#import "UpdateManager.h"
#import "EmailFromViewController.h"
#import "GenerateOrderPoCell.h"
#import "PurchaseOrderFilterVC.h"
#import "RimPopOverVC.h"
#import "SideMenuPOViewController.h"
#import "POmenuListVC.h"
//#import "POmenuListVC_iPhone.h"
#import "POMultipleItemSelectionVC.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "POmenuListVC.h"
#import "Item+Dictionary.h"
#import "CameraScanVC.h"


@interface PurchaseOrderFilterListDetail ()<CameraScanVCDelegate,POMultipleItemSelectionVCDelegate,UIPopoverPresentationControllerDelegate , EmailFromViewControllerDelegate> {
    UITextField *activeField;
    UITextField *currentEditedTextField;
    
    BOOL isPoUpdate;
    
    UIPopoverPresentationController *infopopoverController;
    
    CGPoint infoButtonPosition;
    
    UIViewController *tempviewController;
    UIViewController *itemInformationViewController;
    UIViewController *orderInfoController;
    UIViewController *emailPdfViewController;
    UIViewController *searchOptionViewcontroller;

    UIPopoverPresentationController *emailPdfPopOverController;
    UIPopoverPresentationController *popOverController;
    UIPopoverPresentationController *searchOptionPopOverController;
    
    RimPopOverVC * popoverController;
    EmailFromViewController *emailFromViewController;
}

@property (nonatomic, weak) IBOutlet UIView *uvItemInfoTapped;
@property (nonatomic, weak) IBOutlet UIView *uvItemInformation;
@property (nonatomic, weak) IBOutlet UIView *uvGenerateOrderInfo;
@property (nonatomic, weak) IBOutlet UIView *emailPdfView;
@property (nonatomic, weak) IBOutlet UIView *uvSearchOption;

@property (nonatomic, weak) IBOutlet UITextField *txtMainBarcode;
@property (nonatomic, weak) IBOutlet UITextField *txtMinStock;
@property (nonatomic, weak) IBOutlet UITextField *txtOrderNo;
@property (nonatomic, weak) IBOutlet UITextField *txtPOTitle;

@property (nonatomic, weak) IBOutlet UITableView *tblPurchaseOrderList;

@property (nonatomic, weak) IBOutlet UILabel *lblPopUpDepartment;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpSupplier;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpTags;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpFromDate;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpToDate;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpTimeDuration;
@property (nonatomic, weak) IBOutlet UILabel *lblAutoGenPO;
@property (nonatomic, weak) IBOutlet UILabel *lblPODate;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedCost;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedPrice;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedSoldDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedWeek;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped1Month;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped6Month;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped1Year;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalItem;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalReOrderQTY;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalCost;
@property (nonatomic, weak) IBOutlet UILabel *lblFromDate;
@property (nonatomic, weak) IBOutlet UILabel *lblToDate;
@property (nonatomic, weak) IBOutlet UILabel *lblOrderType;

@property (nonatomic, weak) IBOutlet UIButton *btnGenereteOdrinfo;
@property (nonatomic, weak) IBOutlet UIButton *btnTotalItemInfo;
@property (nonatomic, weak) IBOutlet UIButton *pdfEmailBtn;
@property (nonatomic, weak) IBOutlet UIButton *btnFilter;
@property (nonatomic, weak) IBOutlet UIButton *btnSearch;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) UpdateManager *updateManagerGenerateOrder;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) ManualFilterOptionViewController *objManualOption;

@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, strong) NSString *strDeptIDAll;
@property (nonatomic, strong) NSString *strSuppIDAll;
@property (nonatomic, strong) NSString *supplierString;
@property (nonatomic, strong) NSString *departmentString;
@property (nonatomic, strong) NSString *tagString;
@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) NSMutableArray *arrTempSelectedData;
@property (nonatomic, strong) NSMutableArray *arrGenerateOrderDataGlobal;
@property (nonatomic, strong) NSMutableArray *arrGenerateOrderData;

@property (nonatomic, strong) RapidWebServiceConnection *activeItemPOWSC;
@property (nonatomic, strong) RapidWebServiceConnection *pOItemInfoWC;
@property (nonatomic, strong) RapidWebServiceConnection *updatePoDetailNewWC;
@property (nonatomic, strong) RapidWebServiceConnection *insertOpenPODetailNewWC;
@property (nonatomic, strong) RapidWebServiceConnection *mgmtItemInsertWC;

@end

@implementation PurchaseOrderFilterListDetail

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    // {
    self.navigationController.navigationBarHidden = YES;
    // }
    
    
//    [self._rimController.objPOMenuList.btnBackButtonClick removeTarget:nil
//                                                                action:NULL
//                                                      forControlEvents:UIControlEventAllEvents];
//    
//    [self._rimController.objPOMenuList.btnBackButtonClick addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rimsController.scannerButtonCalled=@"GenerateOdr";
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    emailPdfViewController = [[UIViewController alloc]init];
    searchOptionViewcontroller = [[UIViewController alloc]init];
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.pOItemInfoWC = [[RapidWebServiceConnection alloc]init];
    self.updatePoDetailNewWC = [[RapidWebServiceConnection alloc]init];
    self.insertOpenPODetailNewWC = [[RapidWebServiceConnection alloc]init];
    self.mgmtItemInsertWC = [[RapidWebServiceConnection alloc]init];
    self.activeItemPOWSC = [[RapidWebServiceConnection alloc]init];
    self.updateManagerGenerateOrder = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    
    tempviewController = [[UIViewController alloc] init];
    orderInfoController = [[UIViewController alloc] init];
    itemInformationViewController = [[UIViewController alloc] init];
    
    self.arrGenerateOrderData = [[NSMutableArray alloc] init];
    
    
    if(self.arrUpdatePoData.count > 0)
    {
        isPoUpdate = TRUE;
        
        if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
        {
            [self.txtMainBarcode becomeFirstResponder];
        }
        else
        {
            [self.txtMainBarcode resignFirstResponder];
        }
        
        _txtOrderNo.text = self.arrUpdatePoData.firstObject[@"OrderNo"];
        _txtPOTitle.text = self.arrUpdatePoData.firstObject[@"POTitle"];
        
        _lblFromDate.text=self.arrUpdatePoData.firstObject[@"FromDate"];
        _lblToDate.text=self.arrUpdatePoData.firstObject[@"ToDate"];
        _lblOrderType.text=self.arrUpdatePoData.firstObject[@"TimeDuration"];
        
        
        _lblAutoGenPO.text = [NSString stringWithFormat:@"PO # : %@", self.arrUpdatePoData.firstObject[@"PO_No"]];
        
        self.supplierString = self.arrUpdatePoData.firstObject[@"SupplierIds"];
        self.departmentString = self.arrUpdatePoData.firstObject[@"DeptIds"];
        self.tagString = self.arrUpdatePoData.firstObject[@"Tags"];
        
        NSString *createdDate = self.arrUpdatePoData.firstObject[@"CreatedDate"];
        
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        NSDate *convertedDate = [formatter dateFromString:createdDate];
        NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init];
        formatter2.dateFormat = @"MMMM,dd yyyy hh:mm a";
        NSString *dispCreatedDate = [formatter2 stringFromDate:convertedDate];
        _lblPODate.text = dispCreatedDate;
        
        self.arrGenerateOrderData = [self.arrUpdatePoData.firstObject[@"lstItem"]mutableCopy];
        
        self.arrGenerateOrderDataGlobal=[self.arrUpdatePoData.firstObject[@"lstItem"]mutableCopy];
        
        
        [self.tblPurchaseOrderList reloadData];
        [self.tblPurchaseOrderList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    
    NSString  *generateorderCell;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        generateorderCell = @"GenerateOrderPoCell";
    }
    else{
        generateorderCell = @"GenerateOrderPoCell_iPad";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:generateorderCell bundle:nil];
    [self.tblPurchaseOrderList registerNib:mixGenerateirderNib forCellReuseIdentifier:@"Generateorderpocell"];
    
    
    
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblPurchaseOrderList)
        return 1;
    else
        return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        if(indexPath.row==0)
        {
            return 44.0;
        }
        else{
            return 134;
        }
        
    }
    else{
        return 73;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblPurchaseOrderList)
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            return self.arrGenerateOrderData.count+1;
        }
        else{
            return self.arrGenerateOrderData.count;
        }
        
    }
    
    else
        return 1;
    
}
- (void)OrderListData:(NSIndexPath *)indexPath generateOrdPocell:(GenerateOrderPoCell *)generateOrdPocell cell_p:(UITableViewCell **)cell_p
{
    generateOrdPocell.lblTitle.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"ItemName"]];
    
    if([[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Barcode"] isKindOfClass:[NSString class]])
    {
        if([[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@""] || [[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@"<null>"])
        {
            
            generateOrdPocell.lblBarcode.text=@"";
        }
        else
        {
            generateOrdPocell.lblBarcode.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Barcode"]];
            
        }
    }
    else
    {
        
        generateOrdPocell.lblBarcode.text=@"";
    }
    
    generateOrdPocell.lblsoldqty.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Sold"]];
    
    generateOrdPocell.lblavailableqty.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"avaibleQty"]];
    
    
    generateOrdPocell.txtReorder.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"ReOrder"]];
    generateOrdPocell.txtReorder.delegate = self;
    generateOrdPocell.txtReorder.tag = indexPath.row;
    generateOrdPocell.txtReorder.keyboardType = UIKeyboardTypeNumberPad;
    generateOrdPocell.txtReorder.textAlignment = NSTextAlignmentCenter;
    generateOrdPocell.txtReorder.layer.borderWidth = 1.0;
    generateOrdPocell.txtReorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    generateOrdPocell.lblmax.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"MaxStockLevel"]];
    
    
    generateOrdPocell.lblmin.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"MinStockLevel"]];
    
    
    [generateOrdPocell.btnItemInfo addTarget:self
                                      action:@selector(itemInfoTapped:) forControlEvents:UIControlEventTouchDown];
    
    generateOrdPocell.btnItemInfo.tag = indexPath.row;
    *cell_p=generateOrdPocell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];

    if(tableView == self.tblPurchaseOrderList)
    {
        if(self.arrGenerateOrderData.count > 0)
        {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ItemName" ascending:YES];
            [self.arrGenerateOrderData sortUsingDescriptors:@[sort]];
            
            //            if ([[UIDevice currentDevice]  userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            //            {
            //
            NSString *cellIdentifier = @"Generateorderpocell";
            
            GenerateOrderPoCell *generateOrdPocell = (GenerateOrderPoCell *)[self.tblPurchaseOrderList dequeueReusableCellWithIdentifier:cellIdentifier];
            
            generateOrdPocell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                if(indexPath.row==0)
                {
                    UIView *viewborder = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1)];
                    viewborder.backgroundColor=[UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
                    _lblAutoGenPO.frame=CGRectMake(15.0, 2.0, 208.0, 20.0);
                    _lblPODate.frame=CGRectMake(15.0, 22.0, 209.0, 20.0);
                     _btnFilter.frame=CGRectMake(232, 0.0, 88.0, 43.0);
                    
                    
                    if(_lblPODate.text.length>0 || _lblAutoGenPO.text.length>0)
                    {
                        _lblPODate.text=_lblPODate.text;
                        _lblAutoGenPO.text=_lblAutoGenPO.text;
                    }
                    
                    [cell addSubview:_lblAutoGenPO];
                    [cell addSubview:_lblPODate];
                    [cell addSubview:_btnFilter];
                    [cell addSubview:viewborder];
                    return cell;
                }
                else{
                      NSIndexPath *tempPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
                    [self OrderListData:tempPath generateOrdPocell:generateOrdPocell cell_p:&cell];

                }
            }
            else{
                
                [self OrderListData:indexPath generateOrdPocell:generateOrdPocell cell_p:&cell];

            }
            
            return cell;
        }
    }
    
    return cell;
    
}
-(void)itemInfoTapped:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    infoButtonPosition = [sender convertPoint:CGPointZero toView:self.tblPurchaseOrderList];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[(self.arrGenerateOrderData)[[sender tag]] valueForKey:@"ItemId"] forKey:@"ItemId"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    [itemparam setValue:strDateTime forKey:@"LocalDateTime"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self getItemInfoResponse:response error:error];
            });
    };
    self.pOItemInfoWC = [self.pOItemInfoWC initWithRequest:KURL actionName:WSM_PO_ITEM_INFO_NEW params:itemparam completionHandler:completionHandler];
    
}
-(void)getItemInfoResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
	{
        // Barcode wise search result data
		if ([response isKindOfClass:[NSDictionary class]])
		{
			if ([[response  valueForKey:@"IsError"] intValue] == 0)
			{
                    NSMutableArray *arrSelectedItemInfo = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                    
                    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        [_uvItemInfoTapped setHidden:NO];
                        CGRect screenBounds = [UIScreen mainScreen].bounds;
                        if(screenBounds.size.height == 568)
                        {
                            _uvItemInfoTapped.frame = CGRectMake(0, 240, 320.0, 283.0);
                        }
                        else
                        {
                            _uvItemInfoTapped.frame = CGRectMake(0, 152, 320.0, 283.0);
                        }
                        [self.view bringSubviewToFront:_uvItemInfoTapped];
                        
                    }
                    else
                    {
                        if (infopopoverController)
                        {
                            [tempviewController dismissViewControllerAnimated:YES completion:nil];
                        }
                        [_uvItemInfoTapped removeFromSuperview];
                        _uvItemInfoTapped.hidden = NO;
                        tempviewController.view = _uvItemInfoTapped;
                        
                        // Present the view controller using the popover style.
                        tempviewController.modalPresentationStyle = UIModalPresentationPopover;
                        [self presentViewController:tempviewController animated:YES completion:nil];
                        
                        // Get the popover presentation controller and configure it.
                        infopopoverController = [tempviewController popoverPresentationController];
                        infopopoverController.delegate = self;
                        tempviewController.preferredContentSize = CGSizeMake(tempviewController.view.frame.size.width, tempviewController.view.frame.size.height);
                        infopopoverController.permittedArrowDirections = UIPopoverArrowDirectionRight;
                        infopopoverController.sourceView = self.tblPurchaseOrderList;
                        infopopoverController.sourceRect = CGRectMake(infoButtonPosition.x,infoButtonPosition.y-97,340,264);
                    }
                    _lblTappedCost.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"Cost"]];
                    _lblTappedPrice.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"Price"]];
                    
                    NSString *strLastSoldDate = [arrSelectedItemInfo.firstObject valueForKey:@"LastSoldDate"];
                    
                    if([strLastSoldDate isKindOfClass:[NSString class]])
                    {
                        _lblTappedSoldDate.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"LastSoldDate"]];
                    }
                    else{
                        _lblTappedSoldDate.text = @"-";
                    }
                    _lblTappedWeek.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"WeeklySoldQty"]];
                    _lblTapped1Month.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"MonthlySoldQty"]];
                    _lblTapped6Month.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"SixMonthlySoldQty"]];
                    _lblTapped1Year.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"YrarlySoldQty"]];
                
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

-(IBAction)btnGenerateOdrInfoClick:(id)sender
{
    [Appsee addEvent:kPOFilterListDetailFooterOrderInfo];
    if(!isPoUpdate) // Update existing Purchase order
    {
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
            self.lblPopUpTimeDuration.text = @"Time Duration: None";
        
        
       // lblPopUpDepartment.text = lblSelectedDepartment.text;
        //lblPopUpSupplier.text = lblSelectedSupplier.text;
        
        if(self.tagString.length > 0)
            self.lblPopUpTags.text = [NSString stringWithFormat:@"Tags : %@",self.tagString];
        else
            self.lblPopUpTags.text = @"";
    }
    else
    {
        
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
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [_uvGenerateOrderInfo setHidden:NO];
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if(screenBounds.size.height == 568)
            {
                _uvGenerateOrderInfo.frame = CGRectMake(0, 231, 320.0, 288.0);
            }
            else{
                _uvGenerateOrderInfo.frame = CGRectMake(0, 173, 320.0, 258.0);
                
            }
        }
        [self.view bringSubviewToFront:_uvGenerateOrderInfo];
    }
    else
    {
        if (infopopoverController)
        {
            [orderInfoController dismissViewControllerAnimated:YES completion:nil];
        }
        [_uvGenerateOrderInfo removeFromSuperview];
        _uvGenerateOrderInfo.hidden = NO;
        orderInfoController.view = _uvGenerateOrderInfo;
        
        // Present the view controller using the popover style.
        orderInfoController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:orderInfoController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        infopopoverController = [orderInfoController popoverPresentationController];
        infopopoverController.delegate = self;
        orderInfoController.preferredContentSize = CGSizeMake(orderInfoController.view.frame.size.width, orderInfoController.view.frame.size.height);
        infopopoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        infopopoverController.sourceView = self.view;
        infopopoverController.sourceRect = CGRectMake(self.btnGenereteOdrinfo.frame.origin.x,
                                                      653,
                                                      self.btnGenereteOdrinfo.frame.size.width,
                                                      self.btnGenereteOdrinfo.frame.size.height);
    }
}
#pragma mark -
#pragma mark Create Pdf
-(IBAction)btn_ExportClick:(id)sender{
    [Appsee addEvent:kPOFilterListDetailFooterExport];
    [self.rmsDbController playButtonSound];
    if (emailPdfPopOverController)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [_emailPdfView removeFromSuperview];
    _emailPdfView.hidden = FALSE;
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
    [Appsee addEvent:kPOFilterListDetailExportOptionEmail];
    if(self.arrUpdatePoData.count>0)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillText:self.arrUpdatePoData];
    }
    else if(self.arrGenerateOrderData.count>0){
        
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillText:self.arrGenerateOrderData];
        
    }
}

//hiten

-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"purchaseorderitem" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
  
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    
    NSString *itemHtml;
    
    if([arryInvoice.firstObject valueForKey:@"lstItem"]){
        
        itemHtml= [self htmlBillTextForItem:self.arrGenerateOrderData];
    }
    else{
        itemHtml= [self htmlBillTextForItem:arryInvoice];
    }
    
    
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController_iPhone"];
    }
    else
    {
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
    (emailFromViewController.dictParameter)[@"fileName"] = @"PurchaseOrderItem.html";
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
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    if([arrayInvoice.firstObject valueForKey:@"lstItem"]){
        
        NSString *CreatedDate = [arrayInvoice.firstObject valueForKey:@"CreatedDate"];
        
        NSString *strDate = [self getStringFormate:CreatedDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MM/dd/yyyy"];
        
        NSString *strTime = [self getStringFormate:CreatedDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
        
        html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    }
    else{
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy";
        NSString* strDate = [formatter stringFromDate:date];
        NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init];
        formatter2.dateFormat = @"hh:mm a";
        NSString* strTime = [formatter2 stringFromDate:date];
        
        html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    }
    
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
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td>&nbsp</td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></td><td align=\"center\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"Sold"],[itemDictionary[@"avaibleQty"]floatValue],[itemDictionary[@"ReOrder"]floatValue],itemDictionary[@"MaxStockLevel"],itemDictionary[@"MinStockLevel"]];
    
    return htmldata;
    
}
-(IBAction)btnItemInfoClick:(id)sender
{
    [Appsee addEvent:kPOFilterListDetailFooterItemInfo];
    _lblTotalItem.text = @"";
    _lblTotalReOrderQTY.text = @"";
    _lblTotalCost.text = @"";
    
    float totalQTYeach = 0.0;
    float totalCostPrice = 0.0;
    for( int iArr = 0 ; iArr < self.arrGenerateOrderData.count; iArr++)
    {
        // Calculate Total CostPrice
        int iQty = [(self.arrGenerateOrderData)[iArr][@"ReOrder"] intValue ];
        totalQTYeach = totalQTYeach + iQty;
        
        float iCost = [(self.arrGenerateOrderData)[iArr][@"CostPrice"] floatValue ];
        totalCostPrice = totalCostPrice + (iQty * iCost);
        
    }
    
    _lblTotalItem.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.arrGenerateOrderData.count];
    _lblTotalReOrderQTY.text = [NSString stringWithFormat:@"%.0f",totalQTYeach];
    _lblTotalCost.text = [NSString stringWithFormat:@"%.2f",totalCostPrice];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [_uvItemInformation setHidden:NO];
        _uvItemInformation.frame = CGRectMake(_uvItemInformation.frame.origin.x, _uvItemInformation.frame.origin.y, 320.0, 163.0);
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

-(void)supplierDepartmentArray:(NSMutableArray *)pArrayTemp{
    
    
    if([pArrayTemp.firstObject valueForKey:@"lstItem"])
    {
        NSMutableArray *supplierListArray = [[[pArrayTemp.firstObject valueForKey:@"lstItem"]valueForKeyPath:@"@distinctUnionOfObjects.SupplierIds"]mutableCopy];
        
        
        for(int i=0;i<supplierListArray.count;i++){
            
            if ([supplierListArray[i] isKindOfClass:[NSNull class]]) {
                [supplierListArray removeObjectAtIndex:i];
            }
        }
        
        NSMutableArray *departmentListArray = [[[pArrayTemp.firstObject valueForKey:@"lstItem"]valueForKeyPath:@"@distinctUnionOfObjects.DeptId"]mutableCopy];
        
        for(int i=0;i<departmentListArray.count;i++){
            
            if ([departmentListArray[i] isKindOfClass:[NSNull class]]) {
                [departmentListArray removeObjectAtIndex:i];
            }
        }
        self.arrdepartmentList=departmentListArray;
        self.arrsupplierlist=supplierListArray;
        
    }
    else if([pArrayTemp.firstObject valueForKey:@"lstPendingItems"])
    {
        NSMutableArray *supplierListArray = [[[pArrayTemp.firstObject valueForKey:@"lstPendingItems"]valueForKeyPath:@"@distinctUnionOfObjects.SupplierIds"]mutableCopy];
        
        
        for(int i=0;i<supplierListArray.count;i++){
            
            if ([supplierListArray[i] isKindOfClass:[NSNull class]]) {
                [supplierListArray removeObjectAtIndex:i];
            }
        }
        
        NSMutableArray *departmentListArray = [[[pArrayTemp.firstObject valueForKey:@"lstPendingItems"]valueForKeyPath:@"@distinctUnionOfObjects.DeptId"]mutableCopy];
        
        for(int i=0;i<departmentListArray.count;i++){
            
            if ([departmentListArray[i] isKindOfClass:[NSNull class]]) {
                [departmentListArray removeObjectAtIndex:i];
            }
        }
        self.arrdepartmentList=departmentListArray;
        self.arrsupplierlist=supplierListArray;
        
    }
    
    for(int i=0;i<self.arrdepartmentList.count;i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"DeptId"] = (self.arrdepartmentList)[i];
        dict[@"selection"] = @"0";
        (self.arrdepartmentList)[i] = dict;
        
    }
    for(int i=0;i<self.arrsupplierlist.count;i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"Suppid"] = (self.arrsupplierlist)[i];
        dict[@"selection"] = @"0";
        (self.arrsupplierlist)[i] = dict;
        
    }
    
    NSMutableString *strResult = [NSMutableString string];
    for(int i=0;i<self.arrsupplierlist.count;i++){
        
        NSMutableDictionary *dict = (self.arrsupplierlist)[i];
        
        NSString *ch = [dict valueForKey:@"Suppid"];
        [strResult appendFormat:@"%@,", ch];
    }
    
    NSArray *arrayTemp;
    if(strResult.length>0)
    {
        NSString *strList = [strResult substringToIndex:strResult.length-1];
        arrayTemp = [strList componentsSeparatedByString:@","];
        
    }
    
    NSArray *newArray =  [NSSet setWithArray:arrayTemp].allObjects;
    
    [self.arrsupplierlist removeAllObjects];
    
    for(int i=0;i<newArray.count;i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"Suppid"] = newArray[i];
        dict[@"selection"] = @"0";
        [self.arrsupplierlist addObject:dict];
        
    }
    
    [self getDepartmentListFilter];
    [self getSupplierDetailsFilter];
    
}
-(void)filterDepartmentamdSupplierforFilterList{
    

    if(self.strPredicateDept.length>0 && self.strPredicateSupp.length==0)
    {
        [self.arrGenerateOrderData removeAllObjects];
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@",self.strPredicateDept]];
        
        self.arrGenerateOrderData = [[self.arrGenerateOrderDataGlobal filteredArrayUsingPredicate:datePredicate] mutableCopy];
        [self.tblPurchaseOrderList reloadData];
    }
    else if(self.strPredicateSupp.length>0 && self.strPredicateDept.length==0){
        
        [self.arrGenerateOrderData removeAllObjects];
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:self.strPredicateSupp];
        self.arrGenerateOrderData = [[self.arrGenerateOrderDataGlobal filteredArrayUsingPredicate:datePredicate] mutableCopy];
        [self.tblPurchaseOrderList reloadData];
    }
    else if(self.strPredicateDept.length>0 && self.strPredicateSupp.length>0){
        
        [self.arrGenerateOrderData removeAllObjects];
        NSString *strPredicate=[NSString stringWithFormat:@"%@ AND %@",self.strPredicateDept,self.strPredicateSupp];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:strPredicate];
        self.arrGenerateOrderData = [[self.arrGenerateOrderDataGlobal filteredArrayUsingPredicate:datePredicate] mutableCopy ];
        [self.tblPurchaseOrderList reloadData];
    }
    else if(self.strPredicateSupp.length==0 && self.strPredicateDept.length==0){
        
        [self.arrGenerateOrderData removeAllObjects];
        self.arrGenerateOrderData= [self.arrGenerateOrderDataGlobal mutableCopy];
        [self.tblPurchaseOrderList reloadData];
    }
    
    if(self.arrSelectedManualList.count>0)
    {
        
        NSMutableArray *result = [self.arrSelectedManualList mutableCopy];
        for (id object in self.arrGenerateOrderData)
        {
            [result removeObject:object];  // make sure you don't add it if it's already there.
            [result addObject:object];
        }
        
    
        self.arrGenerateOrderData = result;
        
        if(self.strPredicateDept.length==0 && self.strPredicateSupp.length==0){
            
            
            self.arrGenerateOrderData = [self.arrSelectedManualList mutableCopy];
        }

        
        
        [self.tblPurchaseOrderList reloadData];
    }
    
    
    
}
-(IBAction)filterButtonClick:(id)sender{
    [Appsee addEvent:kPOFilterListDetailFilter];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        PurchaseOrderFilterVC *objPurFilter = [[PurchaseOrderFilterVC alloc]initWithNibName:@"PurchaseOrderFilterVC" bundle:nil];
        objPurFilter.arrayDepartment=[self.arrdepartmentList mutableCopy];
        objPurFilter.arraySupplier=[self.arrsupplierlist mutableCopy];
        //objPurFilter.arrmainPurchaseOrderList=[[[self.arrUpdatePoData firstObject] objectForKey:@"lstItem"]mutableCopy];
        objPurFilter.arrmainPurchaseOrderList=[self.arrGenerateOrderDataGlobal mutableCopy];
        objPurFilter.objPlist=self;
        [self.navigationController pushViewController:objPurFilter animated:YES];

    }
    else{
        
        PurchaseOrderFilterVC *objPurFilter = [[PurchaseOrderFilterVC alloc]initWithNibName:@"PurchaseOrderFilterVC" bundle:nil];
        objPurFilter.arrayDepartment=[self.arrdepartmentList mutableCopy];
        objPurFilter.arraySupplier=[self.arrsupplierlist mutableCopy];
        //objPurFilter.arrmainPurchaseOrderList=[[[self.arrUpdatePoData firstObject] objectForKey:@"lstItem"]mutableCopy];
        objPurFilter.arrmainPurchaseOrderList=[self.arrGenerateOrderDataGlobal mutableCopy];
        objPurFilter.objPlist=self;
//        [self._rimController.objPOMenuList.navigationController pushViewController:objPurFilter animated:YES];
        [self.pOmenuListVCDelegate willPushViewController:objPurFilter animated:YES];
    }
    
}

- (void) getSupplierDetailsFilter
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"companyId" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    NSMutableArray *arrayTem=[[NSMutableArray alloc]init];
    
    if (resultSet.count > 0)
    {
        for (SupplierCompany *supplier in resultSet) {
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"compName"] = supplier.companyName;
            supplierDict[@"Supp"] = supplier.companyName;
            supplierDict[@"Suppid"] = supplier.companyId;
            supplierDict[@"selection"] = @"0";
            [arrayTem addObject:supplierDict];
        }
    }
    if(resultSet.count > 0)
    {

        NSMutableString *strResult = [NSMutableString string];
         NSMutableString *strSuppAll = [NSMutableString string];
        if(self.arrsupplierlist.count>0)
        {
            for(int i=0;i<self.arrsupplierlist.count;i++){
                
                NSMutableDictionary *dict = (self.arrsupplierlist)[i];
                NSString *ch = [dict valueForKey:@"Suppid"];
                [strResult appendFormat:@"Suppid == %@ OR ", ch];
                [strSuppAll appendFormat:@"%@,", ch];
            }
            if(strResult.length>0)
            {
                self.strPredicateSupp = [strResult substringToIndex:strResult.length-4];
            }
            else{
                self.strPredicateSupp =@"";
            }
            
            
            
            //[arrsupplierlist removeAllObjects];
            NSPredicate *datePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@",self.strPredicateSupp]];
            
            self.arrsupplierlist = [[arrayTem filteredArrayUsingPredicate:datePredicate] mutableCopy];
        }
    
        if(strSuppAll.length>0)
        {
             self.strSuppIDAll=[strSuppAll substringToIndex:strSuppAll.length-1];
        }

    }

}


- (void) getDepartmentListFilter
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deptId" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    
    NSMutableArray *arrayTem=[[NSMutableArray alloc]init];
    
    if (resultSet.count > 0)
    {
        for (Department *departmentmst in resultSet) {
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"Dept"] = departmentmst.deptName;
            supplierDict[@"DeptId"] = departmentmst.deptId;
            supplierDict[@"selection"] = @"0";
            [arrayTem addObject:supplierDict];
        }
    }
    if(resultSet.count > 0)
    {
        NSMutableString *strResult = [NSMutableString string];
        NSMutableString *strDeptAll = [NSMutableString string];
        if(self.arrdepartmentList.count>0)
        {
            for(int i=0;i<self.arrdepartmentList.count;i++){
                
                NSMutableDictionary *dict = (self.arrdepartmentList)[i];
                NSString *ch = [dict valueForKey:@"DeptId"];
                [strResult appendFormat:@"DeptId == %@ OR ", ch];
                [strDeptAll appendFormat:@"%@,", ch];
                
            }
            if(strResult.length>0)
            {
                self.strPredicateDept = [strResult substringToIndex:strResult.length-4];
            }
            else{
                self.strPredicateDept =@"";
            }
            
            
            //[arrdepartmentList removeAllObjects];
            NSPredicate *datePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@",self.strPredicateDept]];
            
            self.arrdepartmentList  = [[arrayTem filteredArrayUsingPredicate:datePredicate] mutableCopy];
            
        }
        
        if(strDeptAll.length>0)
        {
              self.strDeptIDAll=[strDeptAll substringToIndex:strDeptAll.length-1];
        }

    }
    
}

-(IBAction)iphoneBack:(id)sender{
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        if((textField != self.txtMainBarcode) && (textField != _txtOrderNo) && (textField != _txtPOTitle))
        {
            activeField = textField;
            currentEditedTextField = textField;
            
            UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            numberToolbar.barStyle = UIBarStyleBlackTranslucent;
            numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton)]];
            textField.inputAccessoryView = numberToolbar;
            //textField.text = @"";
            
        }
    }
    else
    {
    
            if((textField != self.txtMainBarcode) && (textField != _txtOrderNo) && (textField != _txtPOTitle))
            {
                activeField = textField;
                [currentEditedTextField resignFirstResponder];
                [_txtPOTitle resignFirstResponder];
                [_txtOrderNo resignFirstResponder];
                [self.txtMainBarcode resignFirstResponder];
                
                currentEditedTextField = textField;
                
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangeReOrder:) name:@"ItemReOrder" object:nil];
                
                popoverController = [[RimPopOverVC alloc] initWithNibName:@"RimPopOverVC" bundle:nil];
                popoverController.notificationName = @"ItemReOrder";

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
                __weak typeof(self) weakSelf = self;
                UITextField *__weak weakcurrentEditedTextField = currentEditedTextField;
                UITextField *__weak weakactiveField = activeField;
                RimPopOverVC *__weak weakpopOverController = popoverController;

                popoverController.didEnterAmountBlock = ^(NSString * strPrice, NSDictionary * userInfo){
                    if(strPrice.length>0 && strPrice.integerValue != 0){
                        weakcurrentEditedTextField.text = [strPrice stringByReplacingOccurrencesOfString:@"$" withString:@""];
                         weakcurrentEditedTextField.text = [NSString stringWithFormat:@"%d",strPrice.intValue];
                        
                        //        txtQTY.text=currentEditedTextField.text;
                        if (self.arrGenerateOrderData != nil && self.arrGenerateOrderData.count > 0) {
                            NSMutableDictionary *dict = (weakSelf.arrGenerateOrderData)[weakactiveField.tag];
                            dict[@"ReOrder"] = weakcurrentEditedTextField.text;
                            (weakSelf.arrGenerateOrderData)[weakactiveField.tag] = dict;
                            
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
                
                return NO;
            }
            
        
    }
    return YES;
}
-(void)itemChangeReOrder:(NSNotification *)notification
{
    if (notification.object == nil)
    {
		[popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
	}
    else
    {
		currentEditedTextField.text = [notification.object stringByReplacingOccurrencesOfString:@"$" withString:@""];
        //        txtQTY.text=currentEditedTextField.text;
        if (self.arrGenerateOrderData != nil && self.arrGenerateOrderData.count > 0) {
            NSMutableDictionary *dict = (self.arrGenerateOrderData)[activeField.tag];
            dict[@"ReOrder"] = currentEditedTextField.text;
            (self.arrGenerateOrderData)[activeField.tag] = dict;
        }
		[popoverController dismissViewControllerAnimated:YES completion:nil];
		popOverController = nil;
	}
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ItemReOrder" object:nil];
}

-(void)createNewPurchaseOrderArray{
    
   NSMutableArray *result = [self.arrGenerateOrderDataGlobal mutableCopy];
    for (id object in self.arrGenerateOrderData)
    {
        [result removeObject:object];  // make sure you don't add it if it's already there.
        [result addObject:object];
    }
    
    self.arrGenerateOrderData = result;
    
}


- (NSMutableArray *) PoDetailxml
{
   
   // [self createNewPurchaseOrderArray];
    
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.arrGenerateOrderData.count>0)
    {
        for (int isup=0; isup<self.arrGenerateOrderData.count; isup++)
        {
             NSMutableDictionary *tmpSup = [(self.arrGenerateOrderData)[isup] mutableCopy ];
            
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"ItemId",@"ReOrder",@"Sold",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];
            
            // Barcode = 90;
            // DepartmentName = Mixes;
            // "ITEM_No" = "";
            // ItemName = "1800 Anejo Tequila 50ml";
            // Margin = 100;
            // MarkUp = 0;
            // MaxStockLevel = 0;
            // MinStockLevel = 0;
            // Suppliers = Kam;
            
            /*NSMutableDictionary *tmpOdrDict=[self.arrGenerateOrderData objectAtIndex:isup];
            [tmpOdrDict removeObjectForKey:@"Barcode"];
            [tmpOdrDict removeObjectForKey:@"DepartmentName"];
            [tmpOdrDict removeObjectForKey:@"ITEM_No"];
            [tmpOdrDict removeObjectForKey:@"ItemName"];
            [tmpOdrDict removeObjectForKey:@"Margin"];
            [tmpOdrDict removeObjectForKey:@"MarkUp"];
            [tmpOdrDict removeObjectForKey:@"MaxStockLevel"];
            [tmpOdrDict removeObjectForKey:@"MinStockLevel"];
            [tmpOdrDict removeObjectForKey:@"Suppliers"];
            
            // getting this field in edit/update mode
            
            [tmpOdrDict removeObjectForKey:@"ColumnNames"];
            [tmpOdrDict removeObjectForKey:@"Image"];
            [tmpOdrDict removeObjectForKey:@"ItemInfo"];
            [tmpOdrDict removeObjectForKey:@"Profit"];
            
            // ItemId == ItemCode, Sold == SoldQty, avaibleQty == AvailQty
            // AvailQty,ItemCode,ReOrder,SoldQty -- need to send this parameter so other must be removed*/
            
            [tmpSup setValue:[tmpSup valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpSup setValue:[tmpSup valueForKey:@"Sold" ] forKey:@"SoldQty"];
            [tmpSup setValue:[tmpSup valueForKey:@"avaibleQty" ] forKey:@"AvailQty"];
            
            [tmpSup removeObjectForKey:@"ItemId"];
            [tmpSup removeObjectForKey:@"Sold"];
            [tmpSup removeObjectForKey:@"avaibleQty"];
            
            [itemSupplierData addObject:tmpSup];
        }
    }
	return itemSupplierData;
}


- (NSMutableArray *) PoDetailxmlforNewOrder
{
    
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.arrGenerateOrderData.count>0)
    {
        for (int isup=0; isup<self.arrGenerateOrderData.count; isup++)
        {
            
            // Barcode = 90;
            // DepartmentName = Mixes;
            // "ITEM_No" = "";
            // ItemName = "1800 Anejo Tequila 50ml";
            // Margin = 100;
            // MarkUp = 0;
            // MaxStockLevel = 0;
            // MinStockLevel = 0;
            // Suppliers = Kam;
            
            NSMutableDictionary *tmpOdrDict=[(self.arrGenerateOrderData)[isup]mutableCopy];
            

            /*[tmpOdrDict removeObjectForKey:@"Barcode"];
            [tmpOdrDict removeObjectForKey:@"DepartmentName"];
            [tmpOdrDict removeObjectForKey:@"ITEM_No"];
            [tmpOdrDict removeObjectForKey:@"ItemName"];
            [tmpOdrDict removeObjectForKey:@"Margin"];
            [tmpOdrDict removeObjectForKey:@"MarkUp"];
            [tmpOdrDict removeObjectForKey:@"MaxStockLevel"];
            [tmpOdrDict removeObjectForKey:@"MinStockLevel"];
            [tmpOdrDict removeObjectForKey:@"Suppliers"];
            
            // getting this field in edit/update mode
            
            [tmpOdrDict removeObjectForKey:@"ColumnNames"];
            [tmpOdrDict removeObjectForKey:@"Image"];
            [tmpOdrDict removeObjectForKey:@"ItemInfo"];
            [tmpOdrDict removeObjectForKey:@"Profit"];*/
            
            // ItemId == ItemCode, Sold == SoldQty, avaibleQty == AvailQty
            // AvailQty,ItemCode,ReOrder,SoldQty -- need to send this parameter so other must be removed
            
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"Sold" ] forKey:@"SoldQty"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"avaibleQty" ] forKey:@"AvailQty"];
            
            NSMutableDictionary *speDict = [tmpOdrDict mutableCopy];
            NSArray *removedKeys = @[@"AvailQty",@"ItemCode",@"ReOrder",@"SoldQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpOdrDict removeObjectsForKeys:speKeys];

            
            /*[tmpOdrDict removeObjectForKey:@"ItemId"];
            [tmpOdrDict removeObjectForKey:@"Sold"];
            [tmpOdrDict removeObjectForKey:@"avaibleQty"];
            
            [tmpOdrDict removeObjectForKey:@"SupplierIds"];
            [tmpOdrDict removeObjectForKey:@"CostPrice"];
            [tmpOdrDict removeObjectForKey:@"DeptId"];
            [tmpOdrDict removeObjectForKey:@"SalesPrice"];*/
            
            [itemSupplierData addObject:tmpOdrDict];
        }
    }
	return itemSupplierData;
}



-(IBAction)btnSaveOrderClick:(id)sender{
    [Appsee addEvent:kPOFilterListDetailFooterSave];
    [self.rmsDbController playButtonSound];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
    dictPODetail[@"PoDetailxml"] = [self PoDetailxml];
    
    // long PoId, string PO_No, string POTitle, string OrderNo, string FromDate, string ToDate, string SupplierIds, string DeptIds, int MinStock, long BranchId, long UserId, string TimeDuration, string ColumnsNames
    
    dictPODetail[@"PoId"] = self.arrUpdatePoData.firstObject[@"PurchaseOrderId"];
    
    dictPODetail[@"PO_No"] = _lblAutoGenPO.text;
    dictPODetail[@"POTitle"] = self.arrUpdatePoData.firstObject[@"POTitle"];
    dictPODetail[@"OrderNo"] = @"";
    
    if(_lblFromDate.text.length == 0)
        [dictPODetail setValue:@"" forKey:@"FromDate"];
    else
        [dictPODetail setValue:_lblFromDate.text forKey:@"FromDate"];
    
    if(_lblToDate.text.length == 0)
        [dictPODetail setValue:@"" forKey:@"ToDate"];
    else
        [dictPODetail setValue:_lblToDate.text forKey:@"ToDate"];
    
    [dictPODetail setValue:self.supplierString forKey:@"SupplierIds"];
    [dictPODetail setValue:self.departmentString forKey:@"DeptIds"];
    [dictPODetail setValue:self.tagString forKey:@"Tags"];
    
    if(_txtMinStock.text.length == 0)
        [dictPODetail setValue:@"-1" forKey:@"MinStock"];
    else
        [dictPODetail setValue:_txtMinStock.text forKey:@"MinStock"];
    
    [dictPODetail setValue:_lblOrderType.text forKey:@"TimeDuration"];
    [dictPODetail setValue:@"Barcode,ITEM_Desc,SoldQty,AvailQty,ReOrder" forKey:@"ColumnsNames"];
    
    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictPODetail[@"UserId"] = userID;
    
    
    //hiten
    
    NSString *strDate =   [self getStringFormate:_lblPODate.text fromFormate:@"MMMM,dd yyyy hh:mm a" toFormate:@"MM/dd/yyyy hh:mm a"];
    
    [dictPODetail setValue:strDate forKey:@"DateTime"];
    
    [Appsee addEvent:kPOUpdatePODetailWebServiceCall];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self responseUpdatePoNewDetailResponse:response error:error];
              });
    };
    
    self.updatePoDetailNewWC = [self.updatePoDetailNewWC initWithRequest:KURL actionName:WSM_UPDATE_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
} 

- (void)responseUpdatePoNewDetailResponse:(id)response error:(NSError *)error
{
    NSDictionary *poUpdateDict;
    [_activityIndicator hideActivityIndicator];
    if (response != nil){
    if ([response isKindOfClass:[NSDictionary class]])
    {
        _txtOrderNo.text=@"";
        _txtPOTitle.text=@"";
        
        if ([[response valueForKey:@"IsError"] intValue] == 0)
        {
            poUpdateDict = @{kPOUpdatePODetailWebServiceResponseKey : @"Purchase order has been updated successfully"};
            [Appsee addEvent:kPOUpdatePODetailWebServiceResponse withProperties:poUpdateDict];
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [self btnBackClicked:nil];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Purchase order has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            
            isPoUpdate = FALSE;
            [self.arrGenerateOrderData removeAllObjects];
            _txtMinStock.text = @"";
            
           
        }
        else
        {
            if([response valueForKey:@"Data"] == nil || [response valueForKey:@"Data"] == [NSNull null])
            {
                poUpdateDict = @{kPOUpdatePODetailWebServiceResponseKey : @"Response is nil"};
                [Appsee addEvent:kPOUpdatePODetailWebServiceResponse withProperties:poUpdateDict];
            }
            else
            {
                poUpdateDict = @{kPOUpdatePODetailWebServiceResponseKey : [response valueForKey:@"Data"]};
                [Appsee addEvent:kPOUpdatePODetailWebServiceResponse withProperties:poUpdateDict];
            }
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
    else
    {
        if([response valueForKey:@"Data"] == nil || [response valueForKey:@"Data"] == [NSNull null])
        {
            poUpdateDict = @{kPOUpdatePODetailWebServiceResponseKey : @"Response is nil"};
            [Appsee addEvent:kPOUpdatePODetailWebServiceResponse withProperties:poUpdateDict];
        }
        else
        {
            poUpdateDict = @{kPOUpdatePODetailWebServiceResponseKey : [response valueForKey:@"Data"]};
            [Appsee addEvent:kPOUpdatePODetailWebServiceResponse withProperties:poUpdateDict];
        }

        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}
}


-(IBAction)btnBackClicked:(id)sender
{
    [self.txtMainBarcode resignFirstResponder];
    _txtPOTitle.text=@"";
    _txtOrderNo.text=@"";
    [self.rmsDbController playButtonSound];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        [self.arrGenerateOrderData removeAllObjects];
        _txtMinStock.text = @"";
//        self._rimController.objPOMenuList.btnBackButtonClick.hidden=YES;
//        self._rimController.objPOMenuList.objSideMenuMainPO.indPath=[NSIndexPath indexPathForRow:0 inSection:0];
//        [self._rimController.objPOMenuList menuButtonOperationCell:self._rimController.objPOMenuList.objSideMenuMainPO.indPath.row];
    }
    else
    {
        NSArray *viewcon = self.navigationController.viewControllers;
        for(UIViewController *tempcon in viewcon){
            if([tempcon isKindOfClass:[POmenuListVC class]])
            {
                [self.navigationController popToViewController:tempcon animated:YES];
            }
        }
        //[self.navigationController popToViewController:[viewcon objectAtIndex:2] animated:YES];
        //[self.view removeFromSuperview];
    }
}

#pragma mark - Footer Button Functions

-(IBAction)btnSearchClick:(id)sender {
    
    [Appsee addEvent:kPOFilterListDetailFooterSearch];
    
    [self.rmsDbController playButtonSound];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionVC" bundle:nil];
        
        itemMultipleVC.checkSearchRecord = TRUE;
        itemMultipleVC.flgRedirectToGenerateOdr = TRUE;
        itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
        [self.navigationController pushViewController:itemMultipleVC animated:YES];
        
//        NSArray *arryView = [self._rimController.objInvHome.navigationController viewControllers];
//        for(int i=0;i<[arryView count];i++)
//        {
//            UIViewController *viewCon = [arryView objectAtIndex:i];
//            if([viewCon isKindOfClass:[InventoryManagement class]]){
//                [self._rimController.objInvHome.navigationController popToViewController:viewCon animated:YES];
//                [self.view setHidden:YES];
//                return;
//            }
//        }
//        
//        if(strSuppidList.length>0 || strDeprtidList.length>0)
//        {
//            
//            UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                          initWithTitle:@"Search"
//                                          delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                          destructiveButtonTitle:nil
//                                          otherButtonTitles:@"Search from Inventory", @"Search from po", nil];
//            actionSheet.tag=222;
//            [actionSheet showInView:self.view];
//            
//        }
//        else{
//         
//            if(!self._rimController.objInvenMgmt)
//            {
//                
//                POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionVC" bundle:nil];
//                
//                itemMultipleVC.checkSearchRecord = TRUE;
//                itemMultipleVC.objPurchaseOrderList = self;
//                itemMultipleVC.flgRedirectToOpenList = TRUE;
//                
//                [self._rimController.objInvHome.navigationController pushViewController:itemMultipleVC animated:YES];
//                
//                
//            }
//            else
//            {
//                UIViewController *viewcon = self._rimController.objInvenMgmt;
//                UIView  *viewFooterTemp = (UIView *)[viewcon.view viewWithTag:2222];
//                UIButton *btmAdd = (UIButton *)[viewFooterTemp viewWithTag:1111];
//                [btmAdd setHidden:YES];
//                UILabel *lblAddNewItem = (UILabel *)[viewFooterTemp viewWithTag:1212];
//                [lblAddNewItem setHidden:YES];
//                
//                [self.navigationController pushViewController:self._rimController.objPoItemList animated:YES];
//            }
//
//        }
//        
//        
    }
    else
    {
        
        if(self.strSuppidList.length>0 || self.strDeprtidList.length>0)
        {
            [_uvSearchOption removeFromSuperview];
            _uvSearchOption.hidden = NO;
            searchOptionViewcontroller.view = _uvSearchOption;
            
            // Present the view controller using the popover style.
            searchOptionViewcontroller.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:searchOptionViewcontroller animated:YES completion:nil];
            
            // Get the popover presentation controller and configure it.
            searchOptionPopOverController = [searchOptionViewcontroller popoverPresentationController];
            searchOptionPopOverController.delegate = self;
            searchOptionViewcontroller.preferredContentSize = CGSizeMake(searchOptionViewcontroller.view.frame.size.width, searchOptionViewcontroller.view.frame.size.height);
            searchOptionPopOverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
            searchOptionPopOverController.sourceView = self.view;
            searchOptionPopOverController.sourceRect = CGRectMake(_btnSearch.frame.origin.x,
                                                                  653,
                                                                  _btnSearch.frame.size.width,
                                                                  _btnSearch.frame.size.height);
        }
        else{

            POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionHeaderVC" bundle:nil];
            
            itemMultipleVC.checkSearchRecord = TRUE;
//            itemMultipleVC.objPurchaseOrderList = self;
            itemMultipleVC.flgRedirectToGenerateOdr = TRUE;
            itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
            //itemMultipleVC.poMultipleItemSelectionDelegate = self;
            //itemMultipleVC.objGenerateOrder = self;
//            [self._rimController.objPOMenuList showItemManagementView:itemMultipleVC];
//            [self.pOmenuListVCDelegate showItemManagementView:itemMultipleVC];
//            [self.navigationController pushViewController:itemMultipleVC animated:NO];
            [self presentViewController:itemMultipleVC animated:false completion:nil];
        }
    }
}
-(void)didSelectionChangeInPOMultipleItemSelectionVC:(NSMutableArray *) selectedObject{
    for(int i=0;i<selectedObject.count;i++) {
        
        NSMutableDictionary *dictSelected = [selectedObject[i]mutableCopy];
        if([dictSelected  valueForKey:@"selected"]) {
            
            [dictSelected removeObjectForKey:@"AddedQty"];
            // [dictSelected removeObjectForKey:@"CostPrice"];
            [dictSelected removeObjectForKey:@"DepartId"];
            [dictSelected removeObjectForKey:@"ItemDiscount"];
            [dictSelected removeObjectForKey:@"ItemImage"];
            [dictSelected removeObjectForKey:@"ItemSupplierData"];
            [dictSelected removeObjectForKey:@"ItemTag"];
            [dictSelected removeObjectForKey:@"ProfitAmt"];
            [dictSelected removeObjectForKey:@"ProfitType"];
            [dictSelected removeObjectForKey:@"Remark"];
            [dictSelected removeObjectForKey:@"SalesPrice"];
            [dictSelected removeObjectForKey:@"selected"];
            [dictSelected removeObjectForKey:@"ItemNo"];
            
            [dictSelected removeObjectForKey:@"EBT"];
            [dictSelected removeObjectForKey:@"NoDiscountFlg"];
            [dictSelected removeObjectForKey:@"POSDISCOUNT"];
            [dictSelected removeObjectForKey:@"TaxType"];
            [dictSelected removeObjectForKey:@"isTax"];
            
            [dictSelected setValue:@"0" forKey:@"ReOrder"];
            [dictSelected setValue:@"0" forKey:@"Sold"];
            
            [self.arrGenerateOrderData insertObject:dictSelected atIndex:0];
        }
    }

    [self.tblPurchaseOrderList reloadData];
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

-(IBAction)openMultipleItemSelection:(id)sender{
    
    POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionVC" bundle:nil];
    
    itemMultipleVC.checkSearchRecord = TRUE;
//    itemMultipleVC.objPurchaseOrderList = self;
    itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
    itemMultipleVC.flgRedirectToGenerateOdr = TRUE;
    
    //itemMultipleVC.poMultipleItemSelectionDelegate = self;
    //itemMultipleVC.objGenerateOrder = self;
//    [self._rimController.objPOMenuList showItemManagementView:itemMultipleVC];
    
    [searchOptionViewcontroller dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)openPOBackList:(id)sender{
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
         self.objManualOption  = [[ManualFilterOptionViewController alloc]initWithNibName:@"ManualFilterOptionViewController_iPhone2" bundle:nil];
    }
    else{
         self.objManualOption  = [[ManualFilterOptionViewController alloc]initWithNibName:@"ManualFilterOptionViewController2" bundle:nil];
    }
   
    self.objManualOption.objPur=self;
    self.objManualOption.arrayMainPurchaseOrderList=[self.arrGenerateOrderDataGlobal mutableCopy];
    self.objManualOption.manualOption=NO;
    [searchOptionViewcontroller dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:self.objManualOption animated:YES completion:nil];
    

}

-(void)didSelectItems:(NSArray *) arrTempSelected
{
    for(int i=0;i<arrTempSelected.count;i++)
    {
        NSMutableDictionary *dictSelected = [arrTempSelected[i]mutableCopy];
        if([dictSelected  valueForKey:@"selected"])
        {
            [dictSelected removeObjectForKey:@"AddedQty"];
            // [dictSelected removeObjectForKey:@"CostPrice"];
            [dictSelected removeObjectForKey:@"DepartId"];
            [dictSelected removeObjectForKey:@"ItemDiscount"];
            [dictSelected removeObjectForKey:@"ItemImage"];
            [dictSelected removeObjectForKey:@"ItemSupplierData"];
            [dictSelected removeObjectForKey:@"ItemTag"];
            [dictSelected removeObjectForKey:@"ProfitAmt"];
            [dictSelected removeObjectForKey:@"ProfitType"];
            [dictSelected removeObjectForKey:@"Remark"];
            [dictSelected removeObjectForKey:@"SalesPrice"];
            [dictSelected removeObjectForKey:@"selected"];
            [dictSelected removeObjectForKey:@"ItemNo"];
            
            [dictSelected removeObjectForKey:@"EBT"];
            [dictSelected removeObjectForKey:@"NoDiscountFlg"];
            [dictSelected removeObjectForKey:@"POSDISCOUNT"];
            [dictSelected removeObjectForKey:@"TaxType"];
            [dictSelected removeObjectForKey:@"isTax"];
            
            [dictSelected setValue:@"0" forKey:@"ReOrder"];
            [dictSelected setValue:@"0" forKey:@"Sold"];
            
            [self.arrGenerateOrderData insertObject:dictSelected atIndex:0];
            self.arrTempSelectedData = [[NSMutableArray alloc]init];
            self.arrTempSelectedData = [arrTempSelected mutableCopy];
        }
    }
    [self.arrTempSelectedData removeAllObjects];
    //    checkSearchRecord=FALSE;
    //    flgRedirectToGenerateOdr = FALSE;
    [self.tblPurchaseOrderList reloadData];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
//        [self._rimController.objPOMenuList showViewFromViewController:self];
    }
}

-(IBAction)btnInsertOpenPoDetailNew:(id)sender{
    [Appsee addEvent:kPOFilterListDetailFooterCreateOpenOrder];
    [self.rmsDbController playButtonSound];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
    dictPODetail[@"PoDetailxml"] = [self PoDetailxmlforNewOrder];
    
    // long PoId, string PO_No, string POTitle, string OrderNo, string FromDate, string ToDate, string SupplierIds, string DeptIds, int MinStock, long BranchId, long UserId, string TimeDuration, string ColumnsNames
    
    dictPODetail[@"PurchaseOrderId"] = self.arrUpdatePoData.firstObject[@"PurchaseOrderId"];
    
    dictPODetail[@"PO_No"] = _lblAutoGenPO.text;
    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    dictPODetail[@"UserId"] = userID;
    
    if(self.strDeprtidList.length>0 || self.strSuppidList.length>0){
        
        if(self.strDeprtidList.length>0){
        
              [dictPODetail setValue:self.strDeprtidList forKey:@"DeptIds"];
        }
        else{
              [dictPODetail setValue:@"" forKey:@"DeptIds"];
        }
      
        
        if(self.strSuppidList.length>0){
             [dictPODetail setValue:self.strSuppidList forKey:@"SupplierIds"];
        }
        else{
             [dictPODetail setValue:@"" forKey:@"SupplierIds"];
        }
    }
    else{
        
       if(self.strDeprtidList.length>0){
           
           [dictPODetail setValue:self.strDeptIDAll forKey:@"DeptIds"];
       }
       else{
              [dictPODetail setValue:@"" forKey:@"DeptIds"];
       }
        if(self.strSuppidList.length>0){
             [dictPODetail setValue:self.strSuppIDAll forKey:@"SupplierIds"];
        }
        else{
             [dictPODetail setValue:@"" forKey:@"SupplierIds"];
        }
       
    }
    //hiten
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    [dictPODetail setValue:strDateTime forKey:@"DateTime"];
    
    [Appsee addEvent:kPOInsertOpenPODetailWebServiceCall];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self insertOpenPODetailNewResultResponse:response error:error];
             });
    };
    
    self.insertOpenPODetailNewWC = [self.insertOpenPODetailNewWC initWithRequest:KURL actionName:WSM_INSERT_OPEN_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
}

- (void)insertOpenPODetailNewResultResponse:(id)response error:(NSError *)error
{
    NSDictionary *insertResponseDict;
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            _txtOrderNo.text=@"";
            _txtPOTitle.text=@"";
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                insertResponseDict = @{kPOInsertOpenPODetailWebServiceResponseKey : @"Open order has been created successfully"};
                [Appsee addEvent:kPOInsertOpenPODetailWebServiceResponse withProperties:insertResponseDict];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [self btnBackClicked:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Open order has been created successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
                //isPoUpdate = FALSE;
                [self.arrGenerateOrderData removeAllObjects];
                //_txtMinStock.text = @"";
            }
            else
            {
                if ([response valueForKey:@"Data"] == nil || [response valueForKey:@"Data"] == [NSNull null]) {
                    insertResponseDict = @{kPOInsertOpenPODetailWebServiceResponseKey : @"Response is nil"};
                    [Appsee addEvent:kPOInsertOpenPODetailWebServiceResponse withProperties:insertResponseDict];
                }
                else
                {
                    insertResponseDict = @{kPOInsertOpenPODetailWebServiceResponseKey : [response valueForKey:@"Data"]};
                    [Appsee addEvent:kPOInsertOpenPODetailWebServiceResponse withProperties:insertResponseDict];
                }
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
    }
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    if(tableView == self.tblPurchaseOrderList )
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self.tblPurchaseOrderList setEditing:NO];

        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                [self.arrGenerateOrderData removeObjectAtIndex:indexPath.row];
            }
            else
            {
                [self.arrGenerateOrderData removeObjectAtIndex:indexPath.row-1];
            }

            [self.tblPurchaseOrderList reloadData];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Are you sure you want to delete item in this order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

-(IBAction)hideItemInfoview:(id)sender{
    [_uvItemInformation setHidden:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if((textField == self.txtMainBarcode) && self.txtMainBarcode.text.length > 0)
    {
        NSDictionary *searchDict = @{kPOFilterListDetailSearchBarcodeKey : self.txtMainBarcode.text};
        [Appsee addEvent:kPOFilterListDetailSearchBarcode withProperties:searchDict];
        [self searchScannedBarcodeGenerate];
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
        [textField resignFirstResponder];
        return YES;
    }
}
- (void)searchScannedBarcodeGenerate
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
    NSDictionary *searchResultDict = @{kPOFilterListDetailSearchBarcodeResultKey : @(resultSet.count)};
    [Appsee addEvent:kPOFilterListDetailSearchBarcode withProperties:searchResultDict];
   
    NSMutableDictionary *dictTempGlobal = [item.itemRMSDictionary mutableCopy];
    
    if(dictTempGlobal != nil)
    {
        dictTempGlobal[@"AddedQty"] = @"1";
        
        NSString * strItemCode=[NSString stringWithFormat:@"%d",[[dictTempGlobal valueForKey:@"ItemId"]intValue]];
        
        BOOL isExtisData=FALSE;
        
        if(self.arrGenerateOrderData.count>0)
        {
            for (int idata=0; idata<self.arrGenerateOrderData.count; idata++) {
                NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.arrGenerateOrderData)[idata]valueForKey:@"ItemId"]intValue]];
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
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Item is already existes." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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
            
            [dictTempGlobal setValue:@"0" forKey:@"ReOrder"];
            [dictTempGlobal setValue:@"0" forKey:@"Sold"];
            
            [self.arrGenerateOrderData insertObject:dictTempGlobal atIndex:0];
            [self.tblPurchaseOrderList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self.tblPurchaseOrderList reloadData];
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
                  [self responseGenerateOrderDataResponse:response error:error];
                });
        };
        
        self.mgmtItemInsertWC = [self.mgmtItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
        
        // [appDelegate setAlert:@"Generate Order" withMessage:@"No Record Found." withDelegate:self withTag:501 andButtons:@"OK",nil];
    }
}

-(void)responseGenerateOrderDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if(response!=nil)
    {
        NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
        
        NSPredicate *inActiveItemPredicate = [NSPredicate predicateWithFormat:@"isDeleted == %d",FALSE];
        
        NSArray *itemResponseArray = [[responseDictionary valueForKey:@"ItemArray"] filteredArrayUsingPredicate:inActiveItemPredicate];
        if(itemResponseArray.count > 0)
        {
            NSDictionary * itemDict =itemResponseArray.firstObject;
            if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"0"]) // if not active item
            {
                PurchaseOrderFilterListDetail * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    NSString *strItemId = [NSString stringWithFormat:@"%@",[itemDict valueForKey:@"ITEMCode"]];
                    Item *currentItem = [self fetchAllItems:strItemId isCheckActiveFlag:NO];
                    [myWeakReference movePOFLInActiveItemToActiveItemList:currentItem];
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"This item is inactive would you like to activate it?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
            }
            else {
                [self.updateManagerGenerateOrder updateObjectsFromResponseDictionary:responseDictionary];
                [self.updateManagerGenerateOrder linkItemToDepartmentFromResponseDictionary:responseDictionary];
                Item *anItem=[self fetchAllItems:[[[responseDictionary valueForKey:@"ItemArray"] firstObject ]valueForKey:@"ITEMCode"] isCheckActiveFlag:YES];
                NSMutableDictionary *dictTempGlobal = [[NSMutableDictionary dictionaryWithDictionary:anItem.itemRMSDictionary] mutableCopy];
                
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
                [dictTempGlobal setValue:@"0" forKey:@"Sold"];
                
                [self.arrGenerateOrderData insertObject:dictTempGlobal atIndex:0];
                [self.tblPurchaseOrderList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                [self.tblPurchaseOrderList reloadData];
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No record found for purchase order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

- (void)movePOFLInActiveItemToActiveItemList:(Item *)anItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictItemInfo;
    dictItemInfo = [self getParamToActiveItem:anItem isItemActive:@"1"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self responsePOFLForMoveItemToActiveListResponse:response error:error];
              });
    };
    
    self.activeItemPOWSC = [self.activeItemPOWSC initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];
}
-(void)responsePOFLForMoveItemToActiveListResponse:(id)response error:(NSError *)error {
    
    if (response != nil) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                Item * currentItem = [self fetchAllItems:strItemId isCheckActiveFlag:NO];
                currentItem.active = @1;
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                }
                [self searchScannedBarcodeGenerate];
                self.txtMainBarcode.text = @"";
            }
            else{
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}

- (NSMutableDictionary *)getParamToActiveItem:(Item *)anItem isItemActive:(NSString *)strIsAcite {
    NSMutableDictionary * addItemDataDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * itemDetails = [[NSMutableArray alloc] init];
    NSMutableDictionary * itemDataDict = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    
    NSString * strItemCode = [dictItemClicked valueForKey:@"ItemId"];
    BOOL isDuplicateUPC = [[dictItemClicked valueForKey:@"IsduplicateUPC"] boolValue];
    
    itemDataDict[@"ItemId"] = strItemCode;
    
    itemDataDict[@"ItemName"] = [NSString stringWithFormat:@"%@",[dictItemClicked valueForKey:@"ItemName"]];
    
    itemDataDict[@"Active"] = strIsAcite;
    
    if (isDuplicateUPC) {
        itemDataDict[@"IsduplicateUPC"] = @"1";
    }
    else {
        itemDataDict[@"IsduplicateUPC"] = @"0";
    }
    
    itemDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    itemDataDict[@"UserId"] = userID;
    NSArray * arrKeys = itemDataDict.allKeys;
    NSMutableArray *itemMain = [[NSMutableArray alloc] init];
    for (NSString * strKey in arrKeys) {
        [itemMain addObject:@{@"Key":strKey,@"Value":[itemDataDict valueForKey:strKey]}];
    }
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    //    NSMutableArray * arrItemMain = [self ItemMain];
    itemDetailDict[@"ItemMain"] = itemMain;
    
    itemDetailDict[@"ItemPriceSingle"] = [[NSArray alloc]init];
    itemDetailDict[@"ItemPriceCase"] = [[NSArray alloc]init];
    itemDetailDict[@"ItemPricePack"] = [[NSArray alloc]init];
    
    itemDetailDict[@"AddedBarcodesArray"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedBarcodesArray"] = [[NSArray alloc]init];
    
    itemDetailDict[@"VariationArray"] = [[NSArray alloc]init];
    itemDetailDict[@"VariationItemArray"] = [[NSArray alloc]init];
    
    itemDetailDict[@"addedItemTaxData"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemTaxIds"] = @"";
    
    itemDetailDict[@"addedItemSupplierData"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemSupplierData"] = [[NSArray alloc]init];
    
    itemDetailDict[@"addedItemTag"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemTagIds"] = @"";
    
    itemDetailDict[@"addedItemDiscount"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemDiscountIds"] = @"";
    
    itemDetailDict[@"ItemTicketArray"] = [[NSArray alloc]init];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    itemDetailDict[@"Updatedate"] = [formatter stringFromDate:date];
    
    [itemDetails addObject:itemDetailDict];
    addItemDataDic[@"ItemData"] = itemDetails;
    
    return addItemDataDic;
}


- (Item*)fetchAllItems :(NSString *)itemId isCheckActiveFlag:(BOOL)isCheckActiveFlag
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate;
    if (isCheckActiveFlag) {
        predicate = [NSPredicate predicateWithFormat:@"itemCode==%d AND active == %d", itemId.integerValue,TRUE];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    }
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}
- (void)doneButton
{
    if(currentEditedTextField.text.length == 0)
    {
        NSMutableDictionary *dict = (self.arrGenerateOrderData)[activeField.tag];
        dict[@"ReOrder"] = @"0";
        (self.arrGenerateOrderData)[activeField.tag] = dict;
        currentEditedTextField.text = @"0";
    }
    else
    {
        NSMutableDictionary *dict = (self.arrGenerateOrderData)[activeField.tag];
        dict[@"ReOrder"] = currentEditedTextField.text;
        (self.arrGenerateOrderData)[activeField.tag] = dict;
    }
    [currentEditedTextField resignFirstResponder];
    [activeField resignFirstResponder];
}
-(IBAction)backClick:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)hideuvItemInfoTapped:(id)sender{
    
    [_uvItemInfoTapped setHidden:YES];
}

-(IBAction)generateorderinfocancel:(id)sender{
    
    [_uvGenerateOrderInfo setHidden:YES];
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
    actionSheet.tag=111;
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
    else if(actionSheet.tag==222){
        
        if  (buttonIndex == 0)
        {
//            
//            if(!self._rimController.objInvenMgmt)
//            {
//                
//                InventoryManagement *objManagement=[[InventoryManagement alloc]initWithNibName:@"InventoryManagement" bundle:nil];
//                // [objManagement resetTableViewData];
//                [self._rimController.objInvHome.navigationController pushViewController:objManagement animated:YES];
//                
//                
//            }
//            else
//            {
//                UIViewController *viewcon = self._rimController.objInvenMgmt;
//                UIView  *viewFooterTemp = (UIView *)[viewcon.view viewWithTag:2222];
//                UIButton *btmAdd = (UIButton *)[viewFooterTemp viewWithTag:1111];
//                [btmAdd setHidden:YES];
//                UILabel *lblAddNewItem = (UILabel *)[viewFooterTemp viewWithTag:1212];
//                [lblAddNewItem setHidden:YES];
//                
//                [self.navigationController pushViewController:self._rimController.objInvenMgmt animated:YES];
//            }
//
        }
        else if(buttonIndex == 1){
            
            [self openPOBackList:nil];
        }
        
    }
    

    
}

//hiten
-(IBAction)previewandPrint:(id)sender{
    [Appsee addEvent:kPOFilterListDetailExportOptionPreview];
    if(self.arrUpdatePoData.count>0)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillTextForPreview:self.arrUpdatePoData];
    }
    else if(self.arrGenerateOrderData.count>0){
        
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillTextForPreview:self.arrGenerateOrderData];
        
    }
}
-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"purchaseorderitem" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
  
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    
    NSString *itemHtml;
    
    if([arryInvoice.firstObject valueForKey:@"lstItem"]){
        
        itemHtml= [self htmlBillTextForItem:self.arrGenerateOrderData];
    }
    else{
        itemHtml= [self htmlBillTextForItem:arryInvoice];
    }
    
    
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
