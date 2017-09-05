//
//  DeliveryListView.m
//  I-RMS
//
//  Created by Siya Infotech on 06/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CloseListVC.h"
#import "RmsDbController.h"
#import "CloseOrderPo_iPhone.h"
#import "POmenuListVC.h"
#import "GenerateOrderPoCell.h"
#import "EmailFromViewController.h"

@interface CloseListVC () <UIPopoverPresentationControllerDelegate , EmailFromViewControllerDelegate>
{
    UIPopoverPresentationController *infoDelivetyOption;
    UIPopoverPresentationController *infopopoverController;
    UIPopoverPresentationController *emailPdfPopOverController;
    
    UIViewController *tempviewController;
    UIViewController *deliveryOptionViewController;
    UIViewController *emailPdfViewController;

    CGPoint delivetyButtonPosition;
    CGPoint infoButtonPosition;

    NSMutableArray *arrGlobalCoseData;
    EmailFromViewController *emailFromViewController;
}

@property (nonatomic, weak) IBOutlet UIView *viewDeliveryOption;
@property (nonatomic, weak) IBOutlet UIView *uvItemInfoTapped;
@property (nonatomic, weak) IBOutlet UIView *emailPdfView;
@property (nonatomic, weak) IBOutlet UITextField *txtOrderNo;
@property (nonatomic, weak) IBOutlet UITextField *txtPOTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedCost;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedPrice;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedSoldDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedWeek;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped1Month;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped6Month;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped1Year;
@property (nonatomic, weak) IBOutlet UILabel *lblAutoGenPO;
@property (nonatomic, weak) IBOutlet UILabel *lblPODate;
@property (nonatomic, weak) IBOutlet UIButton *pdfEmailBtn;
@property (nonatomic, weak) IBOutlet UITableView *tblCloseList;
@property (nonatomic, weak) IBOutlet UIView *uvGenerateOdrData;
@property (nonatomic, weak) IBOutlet UITableView *tblGenerateOdrData;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

@property (nonatomic, strong) RapidWebServiceConnection *getCloseOrderDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *editOpenPurchaseOrderDataWC;
@property (nonatomic, strong) RapidWebServiceConnection *pOItemInfoWC;

@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, strong) NSString *emaiItemHtml;
@property (nonatomic, strong) NSMutableArray *arrCloseList;
@property (nonatomic, strong) NSMutableArray *arrGenerateOrderData;

@end

@implementation CloseListVC


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
    
    self.navigationController.navigationBar.hidden=YES;
    emailPdfViewController = [[UIViewController alloc]init];

    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.getCloseOrderDetailWC = [[RapidWebServiceConnection alloc] init];
    self.editOpenPurchaseOrderDataWC = [[RapidWebServiceConnection alloc] init];
    self.pOItemInfoWC = [[RapidWebServiceConnection alloc] init];
    tempviewController = [[UIViewController alloc] init];
    deliveryOptionViewController = [[UIViewController alloc] init];
    self.arrCloseList = [[NSMutableArray alloc] init];
    
    [self.uvGenerateOdrData setHidden:YES];
    [self setInitializeParameter];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)setInitializeParameter{
    
    [_txtPOTitle setEnabled:NO];
    [_txtOrderNo setEnabled:NO];
    
    NSString  *generateorderCell = @"";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        generateorderCell = @"GenerateOrderPoCell";
    }
    else{
        generateorderCell = @"GenerateOrderPoCell_iPad";
    }
    UINib *mixGenerateirderNib = [UINib nibWithNibName:generateorderCell bundle:nil];
    [self.tblGenerateOdrData registerNib:mixGenerateirderNib forCellReuseIdentifier:@"Generateorderpocell"];

    [self getCloseOrderList];

}

-(IBAction)btncloseOrderInfo:(id)sender{
    
//    self._RimsController.objPOMenuList.btnBackButtonClick.hidden=YES;
    [self.uvGenerateOdrData setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self._RimsController.objPOMenuList.btnBackButtonClick removeTarget:nil
//                                                                action:NULL
//                                                      forControlEvents:UIControlEventAllEvents];

    
    
}

-(void)getCloseOrderList
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    }
    else{
        UINavigationController * objNav = self.pOmenuListVCDelegate.POmenuListNavigationController;
        UIViewController * topVC = objNav.topViewController;
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:topVC.view];
//        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self._RimsController.objPOMenuList.view];
    }
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [self getClosePOListResponse:response error:error];
        });
    };
    
    self.getCloseOrderDetailWC = [self.getCloseOrderDetailWC initWithRequest:KURL actionName:WSM_GET_CLOSE_ORDER_DETAIL_NEW params:itemparam completionHandler:completionHandler];

}

- (void)getClosePOListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            // Barcode wise search result dat
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                self.arrCloseList = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                [self.tblCloseList reloadData];
                [self.tblCloseList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No record found for close order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
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
    if(tableView == self.tblCloseList)
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            return 108;
        }
        else{
            return 73;
        }
    }
    if(tableView == self.tblGenerateOdrData)
    {
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            return 134;
        }
        else{
            return 73;
        }
    }

    else{
        return 44;

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblCloseList){
        return 1;
    }
    if(tableView == self.tblGenerateOdrData){
        return 1;
    }
    else{
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblCloseList){
        
        return self.arrCloseList.count;
    }
    else if(tableView == self.tblGenerateOdrData){
        
        return self.arrGenerateOrderData.count;
    }
    else{
         return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(tableView == self.tblCloseList)
    {
        if(self.arrCloseList.count > 0)
        {
        //if ([[UIDevice currentDevice]  userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

                static NSString *CellIdentifier = @"CloseOrderPo_iPhone";
                CloseOrderPo_iPhone *cell = (CloseOrderPo_iPhone *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                
                    if (cell == nil)
                    {
                        NSArray *nib;
                        
                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                            nib = [[NSBundle mainBundle] loadNibNamed:@"CloseOrderPo_iPhone" owner:self options:nil];
                        }
                        else{
                            nib = [[NSBundle mainBundle] loadNibNamed:@"CloseOrderPOCell_iPad" owner:self options:nil];
                        }
                        cell = nib.firstObject;
                    }

                
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
                    cell.lblPONumber.text = [NSString stringWithFormat:@"%@",[(self.arrCloseList)[indexPath.row] valueForKey:@"OpenOrderNo"]];
                    cell.lblInvoiceNumber.text = [NSString stringWithFormat:@"%@",[(self.arrCloseList)[indexPath.row] valueForKey:@"InvoiceNo"]];

                    NSString  *Datetime = [NSString stringWithFormat:@"%@",[(self.arrCloseList)[indexPath.row] valueForKey:@"CreatedDate"]];
                    
                    NSString *strNewDate = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
                    
                    NSArray *arraydate = [strNewDate componentsSeparatedByString:@" "];

            
                    cell.lblDeliveryDate.text = [NSString stringWithFormat:@"%@ %@ %@",arraydate.firstObject,arraydate[1],arraydate[2]];
                    
                    cell.lblDeliveryTime.text = [NSString stringWithFormat:@"%@ %@",arraydate[3],arraydate[4]];


                    NSString  *DatetimeUpdate = [NSString stringWithFormat:@"%@",[(self.arrCloseList)[indexPath.row] valueForKey:@"UpdatedDate"]];
                    
                    NSString *strNewDate2 = [self getStringFormate:DatetimeUpdate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy hh:mm a"];
                    
                    NSArray *arraydate2 = [strNewDate2 componentsSeparatedByString:@" "];
                    
                    cell.lblCloseOrderDate.text = [NSString stringWithFormat:@"%@ %@ %@",arraydate2.firstObject,arraydate2[1],arraydate2[2]];
                    
                    cell.lblCloseOrderTime.text = [NSString stringWithFormat:@"%@ %@",arraydate2[3],arraydate2[4]];
                    
                     [cell.btnPrint addTarget:self action:@selector(openMenuDeliveryOption:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return cell;
                
            }
    }
    else if(tableView == self.tblGenerateOdrData)
    {
        if(self.arrGenerateOrderData.count > 0)
        {
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ItemName" ascending:YES];
            [self.arrGenerateOrderData sortUsingDescriptors:@[sort]];
            
           // if ([[UIDevice currentDevice]  userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
           // {
                
                NSString *cellIdentifier = @"Generateorderpocell";
                
                GenerateOrderPoCell *generateOrdPocell = (GenerateOrderPoCell *)[self.tblGenerateOdrData dequeueReusableCellWithIdentifier:cellIdentifier];
                
                generateOrdPocell.selectionStyle = UITableViewCellSelectionStyleNone;
                
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
                [generateOrdPocell.txtReorder setEnabled:NO];
                
                generateOrdPocell.lblmax.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"MaxStockLevel"]];
                
                
                generateOrdPocell.lblmin.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"MinStockLevel"]];
                
                
                [generateOrdPocell.btnItemInfo addTarget:self
                                                  action:@selector(itemInfoTapped:) forControlEvents:UIControlEventTouchDown];
            
                generateOrdPocell.btnItemInfo.tag = indexPath.row;
                cell=generateOrdPocell;
                
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
        
        delivetyButtonPosition = [sender convertPoint:CGPointZero toView:self.tblCloseList];
        
        NSIndexPath *indpath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        UITableViewCell *cell = [self.tblCloseList cellForRowAtIndexPath:indpath];
        for(UIView *temp in cell.subviews){
            if([temp isKindOfClass:[UIButton class]]){
                delivetyButtonPosition=temp.frame.origin;
                
            }
        }
        
        if (infoDelivetyOption)
        {
            [deliveryOptionViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [_viewDeliveryOption removeFromSuperview];
        _viewDeliveryOption.hidden = NO;
        deliveryOptionViewController.view = _viewDeliveryOption;
        
        // Present the view controller using the popover style.
        deliveryOptionViewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:deliveryOptionViewController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        infoDelivetyOption = [deliveryOptionViewController popoverPresentationController];
        infoDelivetyOption.delegate = self;
        deliveryOptionViewController.preferredContentSize = CGSizeMake(deliveryOptionViewController.view.frame.size.width, deliveryOptionViewController.view.frame.size.height);
        infoDelivetyOption.permittedArrowDirections = UIPopoverArrowDirectionRight;
        infoDelivetyOption.sourceView = self.tblCloseList;
        infoDelivetyOption.sourceRect = CGRectMake( delivetyButtonPosition.x, delivetyButtonPosition.y-95,340,264);
    }
}

-(IBAction)btnMenuClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblCloseList)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [itemparam setValue:[(self.arrCloseList)[indexPath.row] valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
        
        // hiten 20082014
        
        itemparam[@"OpenOrderId"] = (self.arrCloseList)[indexPath.row][@"OpenOrderId"];
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                [self getClickedPODataResponse:response error:error];
                });
        };
        
        self.editOpenPurchaseOrderDataWC = [self.editOpenPurchaseOrderDataWC initWithRequest:KURL actionName:WSM_GET_OPEN_PURCHASE_OREDR_DATA_NEW params:itemparam completionHandler:completionHandler];
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
                arrGlobalCoseData=arrtempPoData;
                [self fillcloseIteminfo:arrtempPoData];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No record found close order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }

}
-(void)fillcloseIteminfo :(NSMutableArray *)pcloseArray {
    
    _txtOrderNo.text=[pcloseArray.firstObject valueForKey:@"OrderNo"];
    _txtPOTitle.text=[pcloseArray.firstObject valueForKey:@"POTitle"];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if(screenBounds.size.height == 568)
        {
            self.uvGenerateOdrData.frame = CGRectMake(0.0, 0.0, 320.0, 568.0);
        }
        else
        {
            self.uvGenerateOdrData.frame = CGRectMake(0, 0.0, 320.0, 480.0);
        }
        [self.uvGenerateOdrData setHidden:NO];
        
    }
    else{
           [self.uvGenerateOdrData setHidden:NO];
    }
 
    
    _lblAutoGenPO.text = [NSString stringWithFormat:@"PO # : %@", pcloseArray.firstObject[@"PO_No"]];
    
    NSString *createdDate = pcloseArray.firstObject[@"CreatedDate"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSDate *convertedDate = [formatter dateFromString:createdDate];
    NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init];
    formatter2.dateFormat = @"MMMM,dd yyyy hh:mm a";
    NSString *dispCreatedDate = [formatter2 stringFromDate:convertedDate];
    _lblPODate.text = dispCreatedDate;
    
    self.arrGenerateOrderData = pcloseArray.firstObject[@"lstItem"];
    
    [self.tblGenerateOdrData reloadData];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        
    }
    else{
        
//        self._RimsController.objPOMenuList.btnBackButtonClick.hidden=NO;
//        [self._RimsController.objPOMenuList.btnBackButtonClick addTarget:self action:@selector(btncloseOrderInfo:) forControlEvents:UIControlEventTouchUpInside];
    }

}

-(void)itemInfoTapped:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    infoButtonPosition = [sender convertPoint:CGPointZero toView:self.tblGenerateOdrData];
    
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
    
    self.pOItemInfoWC = [self.pOItemInfoWC initWithRequest:KURL actionName:WSM_PO_ITEM_INFO params:itemparam completionHandler:completionHandler];
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
                        infopopoverController.sourceView = self.tblGenerateOdrData;
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
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response  valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
}
-(IBAction)hideuvItemInfoTapped:(id)sender{
    [_uvItemInfoTapped setHidden:YES];
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
    
    if(self.arrCloseList.count>0)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillText:arrGlobalCoseData];
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
    NSString *itemHtml = [self htmlBillTextForItem:[arryInvoice.firstObject valueForKey:@"lstItem"]];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
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
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"%@",@"Close Order"]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ORDER_TYPE$$" withString:[NSString stringWithFormat:@"%@",[arrayInvoice.firstObject valueForKey:@"OrderNo"]]];
    
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
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td>&nbsp</td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></td><td align=\"center\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"Sold"],[itemDictionary[@"avaibleQty"]floatValue],[itemDictionary[@"ReOrder"]floatValue],itemDictionary[@"MaxStockLevel"],itemDictionary[@"MinStockLevel"]];
    
    return htmldata;
    
}
#pragma mark -
#pragma mark Action Sheet

-(IBAction)openActionSheet:(id)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"More"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Send Email", nil];
    actionSheet.tag=111;
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(actionSheet.tag==111){
        
        
        if(buttonIndex == 0){
            
            [self sendEmail:nil];
        }
    }
    
}
//hiten
-(IBAction)previewandPrint:(id)sender{
    
    if(self.arrCloseList.count>0)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillTextForPreview:arrGlobalCoseData];
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
    NSString *itemHtml = [self htmlBillTextForItem:[arryInvoice.firstObject valueForKey:@"lstItem"]];
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
    

   // [[self navigationController] pushViewController:previewer animated:YES];

  
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
