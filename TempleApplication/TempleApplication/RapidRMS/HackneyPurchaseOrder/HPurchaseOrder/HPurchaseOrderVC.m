//
//  HPurchaseOrderVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HPurchaseOrderVC.h"
#import "HPOItemListVC.h"
#import "RmsDbController.h"
#import "VPurchaseOrder+Dictionary.h"
#import "HDepartment.h"
#import "HBackorderListVC.h"
#import "Vendor_Item+Dictionary.h"
#import "VPurchaseOrderItem.h"

typedef NS_ENUM(NSUInteger, ORDER_INFO) {
    
    ORDER_NUMBER,
    ORDER_NAME,
    TAG_KEYWORD,
    DEPARTMENT,
    DATE_RANGE,
    ADD_BACK_ORDER
};


@interface HPurchaseOrderVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblGenerateOrder;

@property (nonatomic, weak) IBOutlet UIButton *btnCreatorder;

@property (nonatomic, weak) IBOutlet UIView *viewDatePicker;

@property (nonatomic, weak) IBOutlet UIDatePicker *dtpicker;

@property (nonatomic, weak) IBOutlet UILabel *lblDateLabel;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) VPurchaseOrder *vendorPoSession;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection *poWebservice;

@property (nonatomic, strong) NSMutableArray *orderInfo;

@property (nonatomic, strong) UITextField *txtOrderNo;
@property (nonatomic, strong) UITextField *txtOrderName;
@property (nonatomic, strong) UITextField *txtTagKeyword;
@property (nonatomic, strong) UITextField *txtDepartment;

@property (nonatomic, strong) NSString *webServiceName;
@property (nonatomic, strong) NSString *webServiceNameResponse;
@property (nonatomic, strong) NSString *strFromDate;
@property (nonatomic, strong) NSString *strToDate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HPurchaseOrderVC
@synthesize updateManager;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize dictDept,arrayBackorderArray;

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
    
    arrayBackorderArray =[[NSMutableArray alloc]init];
    
    self.orderInfo = [[NSMutableArray alloc] initWithObjects:@(ORDER_NAME),@(ADD_BACK_ORDER) ,nil];
    
    self.btnCreatorder.layer.cornerRadius=17.0;
    self.btnCreatorder.layer.masksToBounds=YES;
    self.btnCreatorder.layer.borderColor=[UIColor grayColor].CGColor;
    self.btnCreatorder.layer.borderWidth= 1.0f;
    [self.viewDatePicker setHidden:YES];
    
    self.poWebservice = [[RapidWebServiceConnection alloc]init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    //self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    [self allocTextField];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tblGenerateOrder reloadData];
}

-(void)allocTextField{
    _txtOrderNo = [[UITextField alloc]initWithFrame:CGRectMake(130.0, 5.0, 130.0, 35.0)];
    _txtOrderName = [[UITextField alloc]initWithFrame:CGRectMake(130.0, 5.0, 130.0, 35.0)];
    _txtTagKeyword = [[UITextField alloc]initWithFrame:CGRectMake(130.0, 5.0, 130.0, 35.0)];
    
     _txtDepartment = [[UITextField alloc]initWithFrame:CGRectMake(110.0, 5.0, 130.0, 35.0)];
    
     _txtDepartment.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
    _txtTagKeyword.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];

    _txtOrderName.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];

    _txtOrderNo.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.orderInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
    
    [[cell viewWithTag:1000]removeFromSuperview];
    

    UIView *viewBg = [[UIView alloc]initWithFrame:CGRectMake(20.0, 10.0, 280.0,45.0)];
    
    viewBg.tag = 1000;
    viewBg.layer.cornerRadius=25.0;
    viewBg.layer.masksToBounds=YES;
    viewBg.layer.borderColor=[UIColor grayColor].CGColor;
    viewBg.layer.borderWidth= 1.0f;
    
    ORDER_INFO InfoSection = [self.orderInfo[indexPath.row] integerValue];
    
    switch (InfoSection) {
        case ORDER_NUMBER:
        {
            UILabel *lblcellName = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 2.0, 130.0, 40)];
            lblcellName.text = @"Order Number :";
            lblcellName.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
            
            // _txtOrderNo.backgroundColor = [UIColor redColor];
            _txtOrderNo.delegate=self;
            [viewBg addSubview:lblcellName];
            [viewBg addSubview:_txtOrderNo];
        }
        break;
        case ORDER_NAME:
        {
            UILabel *lblcellName = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 2.0, 130.0, 40)];
            lblcellName.text = @"Order Name :";
            lblcellName.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
            
            // _txtOrderName.backgroundColor = [UIColor redColor];
            _txtOrderName.delegate=self;
            [viewBg addSubview:lblcellName];
            [viewBg addSubview:_txtOrderName];
        }
        break;
            
        case TAG_KEYWORD:
        {
            UILabel *lblcellName = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 2.0, 130.0, 40)];
            lblcellName.text = @"Tag/Keyword :";
            lblcellName.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
            
            // _txtTagKeyword.backgroundColor = [UIColor redColor];
            
            _txtTagKeyword.delegate=self;
            [viewBg addSubview:lblcellName];
            [viewBg addSubview:_txtTagKeyword];
        }
        break;
        case DEPARTMENT:
        {
            UILabel *lblcellName = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 2.0, 130.0, 40)];
            lblcellName.text = @"Department :";
            lblcellName.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
            
            
            if(dictDept){
                _txtDepartment.text=[dictDept valueForKey:@"Invoice_Cat_Description"];
            }
            //_txtDepartment.backgroundColor = [UIColor redColor];
            
            _txtDepartment.delegate=self;
            _txtDepartment.enabled=NO;
            [viewBg addSubview:lblcellName];
            [viewBg addSubview:_txtDepartment];
            
            UIButton *btnDateDepartment = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDateDepartment.frame=CGRectMake(15.0, 2.0, 300.0, 40);
            [btnDateDepartment addTarget:self action:@selector(selectDepartment:) forControlEvents:UIControlEventTouchUpInside];
            [viewBg addSubview:btnDateDepartment];
        }
        break;
        case DATE_RANGE:
        {
            UILabel *lblcellName = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 2.0, 130.0, 40)];
            lblcellName.text = @"Date Range :";
            lblcellName.font = [UIFont fontWithName:@"Helvetica New" size:15.0];
            
            UITextField *txtValue = [[UITextField alloc]initWithFrame:CGRectMake(120.0, 5.0, 130.0, 35.0)];
            
            if(_strFromDate){
                
                txtValue.text=@"Select To Date";
            }
            else{
                txtValue.text=@"Select From Date";
            }
            
            
            //txtValue.backgroundColor = [UIColor redColor];
            txtValue.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
            txtValue.delegate=self;
            [viewBg addSubview:lblcellName];
            [viewBg addSubview:txtValue];
            
            UIButton *btnDateRange = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDateRange.frame=CGRectMake(15.0, 2.0, 300.0, 40);
            [btnDateRange addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
            [viewBg addSubview:btnDateRange];
        }
            break;

        case ADD_BACK_ORDER:
        {
            
            UIButton *btnAddBackorder = [UIButton buttonWithType:UIButtonTypeCustom];
            btnAddBackorder.frame = CGRectMake(10.0, 5.0, 200.0, 40);
            [btnAddBackorder setTitle:@"Add From Backorder List" forState:UIControlStateNormal];
            [btnAddBackorder setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnAddBackorder.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
            [btnAddBackorder addTarget:self action:@selector(getBackOrderList:) forControlEvents:UIControlEventTouchUpInside];
            [viewBg addSubview:btnAddBackorder];
        }
            break;
        default:
            break;
    }
    
    [cell addSubview:viewBg];
    
    return cell;
}
        
-(void)getBackOrderList:(id)sender{
 
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HBackorderListVC *backorderList = [storyBoard instantiateViewControllerWithIdentifier:@"HBackorderListVC"];
    backorderList.purchaseOrder=self;
    [self.navigationController presentViewController:backorderList animated:YES completion:nil];
}

-(void)selectDepartment:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HDepartment *hitemDept = [storyBoard instantiateViewControllerWithIdentifier:@"HDepartment"];
    hitemDept.hpurchaseOrder=self;
    [self.navigationController pushViewController:hitemDept animated:YES];
    
}

-(void)showDatePicker:(id)sender{
    
    if(_strFromDate){
        
        _lblDateLabel.text=@"To Date";
    }
    else{
        _lblDateLabel.text=@"From Date";
    }
    [self.viewDatePicker setHidden:NO];
}

-(IBAction)btnDatepickerDoneClick:(id)sender{
  
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *dateString = [dateFormatter stringFromDate:_dtpicker.date];
    
    if(_strFromDate){

        _strToDate=dateString;
    }
    else{
        _strFromDate=dateString;
    }
    [self.tblGenerateOrder reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.viewDatePicker setHidden:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(IBAction)createOrderClick:(id)sender{

   [self callWebServiceForPurchaseOrder];
}

#pragma mark -
#pragma mark Required Method
-(BOOL)checkRequireFields{
    
    if([_txtOrderNo.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter order no" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return FALSE;
        
    }
    else if([_txtOrderName.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter order name" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        return FALSE;
        
    }
    else if([_txtTagKeyword.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Enter Tag/Keyword" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        return FALSE;
        
    }
    else if([_txtDepartment.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Select  department" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        return FALSE;
        
    }
    else if(_strFromDate==nil){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Select  start date" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        return FALSE;
        
    }
    else if(_strToDate==nil){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Select  to date" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        return FALSE;
        
    }
    else{
        return TRUE;
    }
}



- (void)callWebServiceForPurchaseOrder
{
//    if([self checkRequireFields])
//    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *poparam = [[NSMutableDictionary alloc] init];
   
        if(self.arrayBackorderArray.count==0){
            
            self.webServiceName = @"AddHackneyPO";
            self.webServiceNameResponse=@"AddHackneyPOResult";
            param = [self poDictionary];
            [poparam setValue:param forKey:@"ItemData"];
        }
        else{
            
            self.webServiceName = @"BackOrderHackneyPOItem";
            self.webServiceNameResponse=@"BackOrderHackneyPOItemResult";
            
            [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            NSMutableArray *arrayPO = [[NSMutableArray alloc]init];
            [arrayPO addObject:[self poDictionary]];
            param[@"HackneyPOObjectArray"] = arrayPO;
            param[@"HackneyPOItembjectyArray"] = self.arrayBackorderArray;

            [poparam setValue:param forKey:@"objHackneyPOBack"];
        }
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self purchaseOrderResponse:response error:error];
        });
    };
    
    self.poWebservice = [self.poWebservice initWithRequest:KURL actionName:self.webServiceName params:poparam completionHandler:completionHandler];
    
   // }
}

- (void)purchaseOrderResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                if([self.webServiceNameResponse isEqualToString:@"BackOrderHackneyPOItemResult"]){
                    
                    NSMutableArray *arrayItem = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                    
                    NSString *strID = [arrayItem.firstObject valueForKey:@"POId"];
                    [[NSUserDefaults standardUserDefaults]setObject:strID forKey:@"PoId"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    _vendorPoSession  = [self insertVendorPOWithDictionary:strID];
                    
                    [self strorePurchaseOrderItemList:arrayItem withPoid:strID];
                    
                    
                }
                else{
                    
                    NSString *strID = response[@"Data"];
                    
                    [[NSUserDefaults standardUserDefaults]setObject:strID forKey:@"PoId"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    _vendorPoSession  = [self insertVendorPOWithDictionary:strID];
                    
                    if(!self.fromHome){
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else{
                        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                        HPOItemListVC *hitemList = [storyBoard instantiateViewControllerWithIdentifier:@"HPOItemListVC"];
                        hitemList.strPoID=strID;
                        [self.navigationController pushViewController:hitemList animated:YES];
                    }
                    
                    
                }
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Error occured in hold Purchase Order" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}



-(NSMutableDictionary *)poDictionary{
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:@"0" forKey:@"Id"];
    [param setValue:@"0" forKey:@"POId"];
    param[@"UserID"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    param[@"OrderNo"] = _txtOrderNo.text;
    param[@"OrderName"] = _txtOrderName.text;
    param[@"Keyowrd"] = _txtTagKeyword.text;
    
    NSString *strvendorId = [[NSUserDefaults standardUserDefaults]valueForKey:@"HSupplierID"];
    param[@"SupplierId"] = strvendorId;
    
    if(dictDept==nil)
    {
        param[@"Department"] = @"0";

    }
    else{
        param[@"Department"] = [dictDept valueForKey:@"Invoice_CatId"];

    }
    if(_strFromDate==nil)
    {
        param[@"StartDate"] = @"";
    }
    else{
         param[@"StartDate"] = _strFromDate;
    }
    if(_strToDate==nil)
    {
       param[@"EndDate"] = @"";
    }
    else{
        param[@"EndDate"] = _strToDate;
    }

    param[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    param[@"Status"] = @"0";
    
    param[@"CreatedDate"] = strDateTime;
    
    param[@"IsDeleted"] = @"0";
    
    return param;
}



-(void)strorePurchaseOrderItemList:(NSMutableArray *)arrayTemp withPoid:(NSString *)strpoid{
    
    for(int i=0;i<arrayTemp.count;i++){
        
        NSMutableDictionary *dictTemp = arrayTemp[i];
        
        NSString *itemCode = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"ItemCode"]];
        
        Vendor_Item *vanItem =  [self.updateManager fetchVendorItem:itemCode.integerValue manageObjectContext:self.managedObjectContext];
        
        VPurchaseOrderItem *vmanualItem=nil;
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        [self.updateManager updatePurchaseOrderItemListwithDetail:dictTemp withVendorItem:(Vendor_Item *)OBJECT_COPY(vanItem, privateContextObject) withpurchaseOrderItem:(VPurchaseOrderItem *)OBJECT_COPY(vmanualItem, privateContextObject) withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(_vendorPoSession, privateContextObject) withManageObjectContext:privateContextObject];
        
        _vendorPoSession = (VPurchaseOrder *)OBJECT_COPY(_vendorPoSession, self.managedObjectContext);
    }
    
    if(!self.fromHome){
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        HPOItemListVC *hitemList = [storyBoard instantiateViewControllerWithIdentifier:@"HPOItemListVC"];
        hitemList.strPoID=strpoid;
        [self.navigationController pushViewController:hitemList animated:YES];
    }
}

- (void)callWebServiceForBackOrderItem
{
    if([self checkRequireFields])
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        [param setValue:@"0" forKey:@"Id"];
        [param setValue:@"0" forKey:@"POId"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        param[@"UserID"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        param[@"OrderNo"] = _txtOrderNo.text;
        param[@"OrderName"] = _txtOrderName.text;
        param[@"Keyowrd"] = _txtTagKeyword.text;
        
        param[@"Department"] = [dictDept valueForKey:@"Invoice_CatId"];
        param[@"StartDate"] = _strFromDate;
        param[@"EndDate"] = _strToDate;
        
        param[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
        param[@"Status"] = @"0";
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *strDateTime = [formatter stringFromDate:date];
        param[@"CreatedDate"] = strDateTime;
        param[@"IsDeleted"] = @"0";
        
        NSMutableDictionary *poparam = [[NSMutableDictionary alloc] init ];
        [poparam setValue:param forKey:@"objHackneyPOBack"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
                [self addbackOrderItemListResponse:response error:error];
            });
        };
        self.poWebservice = [self.poWebservice initWithRequest:KURL actionName:WSM_BACK_ORDER_HACKNEY_PO_ITEM params:poparam completionHandler:completionHandler];
        
    }
}

- (void)addbackOrderItemListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {

            }
        }
    }
}

-(VPurchaseOrder *)insertVendorPOWithDictionary:(NSString *)strPOID{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"POId"] = strPOID;
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"UserID"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"OrderNo"] = _txtOrderNo.text;
    dict[@"OrderName"] = _txtOrderName.text;
    dict[@"Keyowrd"] = _txtTagKeyword.text;
    if(dictDept == nil){

        dict[@"Department"] = @"0";
        
    }
    else{
        dict[@"Department"] = _txtDepartment.text;
    }
    
    if(_strFromDate == nil){
            dict[@"StartDate"] = @"";
    }
    else{
        dict[@"StartDate"] = _strFromDate;
    }
    
     if(_strToDate == nil){
         
         dict[@"EndDate"] = @"";
     }
     else{
         dict[@"EndDate"] = _strToDate;
     }

    
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"Status"] = @"0";
    dict[@"IsDeleted"] = @"0";
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    dict[@"CreatedDate"] = strDateTime;

    dict[@"UpdateDate"] = strDateTime;

    _vendorPoSession = [self.updateManager insertVendorPoDictionary:dict];
    
    return _vendorPoSession;
    
}

-(IBAction)gotoHome:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
