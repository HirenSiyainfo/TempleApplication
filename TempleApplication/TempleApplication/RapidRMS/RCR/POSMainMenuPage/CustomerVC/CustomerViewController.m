
//
//  CustomerViewController.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CustomerViewController.h"
#import "AddCustomerVC.h"
#import "RmsDbController.h"
#import "CustomerDetailCell.h"
#import "CustomerLoyaltyVC.h"
#import "RmsDashboardVC.h"
#import "DashBoardSettingVC.h"
#import "UpdateManager.h"
#import "Customer.h"

@interface CustomerViewController () <AddCustomerVCdelegate , CustomerLoyaltyVCDelegate , UpdateDelegate, NSFetchedResultsControllerDelegate>
{
    AddCustomerVC *addCustomerVC;
    CustomerDetailCell *customerCell;
    BOOL isFirstTimeLoaded;
    NSIndexPath *currentViewedCustomerIndexpath;
    NSString *strSwipeDire;
    Customer *customer ;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (strong, nonatomic) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager * updateManager;

@property (strong, nonatomic) RapidWebServiceConnection *globalCustomerConnection;
@property (strong, nonatomic) RapidWebServiceConnection *customerLoyaltyConnection;
@property (strong, nonatomic) RapidWebServiceConnection *deleteCustomerConnection;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *CustomerListRC;

@property (nonatomic, weak) IBOutlet UIImageView *imgBG;

@property (nonatomic, weak) IBOutlet UITextField *txtCustomer;
@property (nonatomic, weak) IBOutlet UITableView *tblCustomer;
@property (nonatomic, weak) IBOutlet UIView *viewBG;
@property (nonatomic, weak) IBOutlet UISwitch *barcodeSearchOnOff;
@property (nonatomic, weak) IBOutlet UIButton *btnFilter;
@property (nonatomic, weak) IBOutlet UITableView *filterTypeTable;
@property (nonatomic, weak) IBOutlet UIButton *btnDone;
@property (nonatomic, weak) IBOutlet UIButton *btnAddCustomer;

@property (nonatomic) BOOL isKeywordFilter;
@property (nonatomic) BOOL isContinuousFiltering;

@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSMutableDictionary *custDetail;
@property (nonatomic, strong) NSIndexPath *indPath;
//@property (nonatomic, strong) NSMutableArray *customerDisplayArray;
//@property (nonatomic, strong) NSMutableArray *globalCustomerList;
@property (nonatomic, strong) NSMutableArray *filterTypeArray;

@end

@implementation CustomerViewController
@synthesize indPath, isFromDashBoard;

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
    //    ISscan = false;
    self.txtCustomer.tintColor = [UIColor blackColor];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
  //  self.customerDisplayArray = [[NSMutableArray alloc]init];
 //   self.globalCustomerList = [[NSMutableArray alloc]init];
    self.globalCustomerConnection = [[RapidWebServiceConnection alloc]init];
    self.customerLoyaltyConnection = [[RapidWebServiceConnection alloc]init];
    self.deleteCustomerConnection = [[RapidWebServiceConnection alloc]init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];

    self.filterTypeArray = [[NSMutableArray alloc] initWithObjects:@"ABC Shorting",@"Keyword",nil];
    self.filterTypeTable.hidden = YES;
    self.filterTypeTable.layer.borderWidth = 1;
    self.filterTypeTable.layer.borderColor = [UIColor lightGrayColor].CGColor;

    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    if (isFromDashBoard == YES)
    {
        self.btnDone.hidden = YES;
    }
    _viewBG.layer.cornerRadius = 15.0;
    _imgBG.image = [[UIImage imageNamed:@"RCR_Invoice_patch.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,50)];
    self.btnDone.layer.cornerRadius = 5.0;
    self.btnAddCustomer.layer.cornerRadius = 5.0;
   _barcodeSearchOnOff.on = YES;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _txtCustomer.text = @"";
    [self CustomerList:@""];
    [self checkItemFilterType];
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
}

- (void)CustomerList:(NSString *)searchText
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:searchText forKey:@"SearchText"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self customerInfoResultResponse:response error:error];
        });
    };
    
    self.globalCustomerConnection = [self.globalCustomerConnection initWithRequest:KURL actionName:WSM_CUSTOMER_INFO params:itemparam completionHandler:completionHandler];
    
}

- (void)customerInfoResultResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray * responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(_txtCustomer.text.length > 0)
                {
                   // self.customerDisplayArray = responsearray;
                   // [self.globalCustomerList addObject:responsearray];
                }
                else
                {
                    [self deleteAllCustomers];
                  //  self.customerDisplayArray = responsearray;
                 //   self.globalCustomerList = [self.customerDisplayArray mutableCopy];
                }
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.updateManager updateCustomerInfo:responsearray moc:privateContextObject];
                [UpdateManager saveContext:privateContextObject];

                isFirstTimeLoaded = FALSE;
                self.CustomerListRC = nil;
                [_tblCustomer reloadData];
            }
            else
            {
                if (isFirstTimeLoaded)
                {
                    isFirstTimeLoaded = FALSE;
                }
                else
                {
                    if ([[response valueForKey:@"IsError"] intValue] == 1)
                    {
                        [self deleteAllCustomers];
                    }
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                
                    [_tblCustomer reloadData];
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No customer found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    _txtCustomer.text = @"";
                    isFirstTimeLoaded = FALSE;
                }
            }
        }
    }
//    else
//    {
//      //  self.customerDisplayArray  = [[self fetchAllCustomer:self.managedObjectContext] mutableCopy];
//       // [_tblCustomer reloadData];
//    }

    [_activityIndicator hideActivityIndicator];;
}


-(NSArray *)fetchAllCustomer:(NsmoContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Customer" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    NSMutableArray * arrCustomerInfo = [[NSMutableArray alloc]init];
    for (Customer *customerInfo in resultSet) {
        [arrCustomerInfo addObject:[customerInfo customerInfoDictionary]];
    }
    return arrCustomerInfo;
}


- (void)checkItemFilterType
{
    if (_barcodeSearchOnOff.on == YES)
    {
        self.isKeywordFilter = FALSE;
        self.isContinuousFiltering = FALSE;
        _txtCustomer.placeholder = @"Customer No";
        [_txtCustomer setValue:[UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000]
                   forKeyPath:@"_placeholderLabel.textColor"];
        self.filterTypeTable.hidden = YES;
        _btnFilter.userInteractionEnabled = NO;
    }
    else
    {
        _btnFilter.userInteractionEnabled = YES;
        if([self.rmsDbController.customerSelectedFilterType isEqualToString:@"ABC Shorting"])
            {
                self.rmsDbController.customerSelectedFilterType = @"ABC Shorting";
                self.isKeywordFilter = FALSE;
                self.isContinuousFiltering = TRUE;
                _txtCustomer.placeholder = @"Customer Name";
                [_txtCustomer setValue:[UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000]
                           forKeyPath:@"_placeholderLabel.textColor"];
                self.filterTypeTable.hidden = YES;
            }
        else
            {
                self.rmsDbController.customerSelectedFilterType = @"Keyword";
                self.isKeywordFilter = TRUE;
                self.isContinuousFiltering = FALSE;
                _txtCustomer.placeholder = @"Customer Name , Contact No , Email , Customer No";
                [_txtCustomer setValue:[UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000]
                                forKeyPath:@"_placeholderLabel.textColor"];
                
                self.filterTypeTable.hidden = YES;
            }
    }
}

-(IBAction)filterButtonClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [_txtCustomer resignFirstResponder];
    self.filterTypeTable.hidden = NO;
}


- (IBAction)btnBarcodeSearchOnOff:(id)sender
{
    [self checkItemFilterType];
}

- (IBAction)btnSearchClick:(id)sender
{
    self.CustomerListRC = nil;
    if (_barcodeSearchOnOff.on == YES && self.CustomerListRC.fetchedObjects.count == 1) {
       Customer *searchCustomer = self.CustomerListRC.fetchedObjects.firstObject;
        self.custDetail = [searchCustomer.customerInfoDictionary mutableCopy];
        
        if (self.customerSelectionDelegate == nil)
        {
            [_tblCustomer reloadData];
            [_activityIndicator hideActivityIndicator];
        }
        else
        {
            RapidCustomerLoyalty *rapidCustomerLoyalty = [[RapidCustomerLoyalty alloc] init];
            [rapidCustomerLoyalty setupCustomerDetail:self.custDetail];
            [self.customerSelectionDelegate didSelectCustomerWithDetail:rapidCustomerLoyalty customerDictionary:self.custDetail withIsCustomerFromHouseCharge:FALSE withIscollectPay:FALSE];
            [self.navigationController popViewControllerAnimated:YES];
            
        }

    }
    else if(self.CustomerListRC.fetchedObjects.count > 0)
    {
        [self.tblCustomer reloadData];
        [_activityIndicator hideActivityIndicator];

    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            _txtCustomer.text = @"";
            _CustomerListRC = nil;
            [_tblCustomer reloadData];

        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No customer found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        [_activityIndicator hideActivityIndicator];
    }
}

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;
    if (searchData.length > 0) {
        
        if (_barcodeSearchOnOff.on == YES)
        {
            //        dbFields = @[@"QRCode contains[cd] %@"];
            return [NSPredicate predicateWithFormat:@"qRCode contains[cd] %@",searchData];
        }
        else
        {
            if(self.isKeywordFilter)
            {
                // For - Filter the when I click "return" or "search button" - Keyword
                dbFields = @[ @"firstName contains[cd] %@",@"lastName contains[cd] %@", @"contactNo contains[cd] %@",@"email contains[cd] %@" , @"qRCode contains[cd] %@"];
            }
            else
            {
                // For - Filter the item list as I type the keywords - ABC Shorting
                dbFields = @[ @"firstName BEGINSWITH[cd] %@",@"lastName BEGINSWITH[cd] %@"];
            }
        }
        
        for (int i=0; i<textArray.count; i++)
        {
            NSString *str=textArray[i];
            str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSMutableArray *searchTextPredicates = [NSMutableArray array];
            for (NSString *dbField in dbFields)
            {
                if (![str isEqualToString:@""])
                {
                    [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, str]];
                }
            }
            NSPredicate *compoundpred = [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
            [fieldWisePredicates addObject:compoundpred];
        }
    }
     NSPredicate *isDeleted = [NSPredicate predicateWithFormat:@"isDelete = %@",@(0)];
    [fieldWisePredicates addObject:isDeleted];
    return [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
}

- (IBAction)btnAddClick:(id)sender{
//add
    BOOL hasRights = [UserRights hasRights:UserRightCustomerLoyalty];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to add new customer. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    addCustomerVC = [storyBoard instantiateViewControllerWithIdentifier:@"AddCustomerVC"];
    addCustomerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    addCustomerVC.addCustomerVCdelegate = self;
   // addCustomerVC.view.frame=CGRectMake(0, 0,943, 768);
    addCustomerVC.view.frame = self.view.bounds;
    addCustomerVC.view.tag = 2626;
    [self.view addSubview:addCustomerVC.view];
}

- (IBAction)btnDoneClick:(id)sender{
//select
   if (self.custDetail)
   {
        RapidCustomerLoyalty *rapidCustomerLoyalty = [[RapidCustomerLoyalty alloc] init];
       [rapidCustomerLoyalty setupCustomerDetail:self.custDetail];
        [self.customerSelectionDelegate didSelectCustomerWithDetail:rapidCustomerLoyalty customerDictionary:self.custDetail withIsCustomerFromHouseCharge:FALSE withIscollectPay:FALSE];
       [self.navigationController popViewControllerAnimated:YES];

    }
    else{
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Select Customer" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        [_tblCustomer reloadData];
    }
}

- (IBAction)btnCancelClick:(id)sender{
    if (self.customerSelectionDelegate) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    else
    {
        NSArray *viewControllerArray = self.navigationController.viewControllers;
     
        for (UIViewController *vc in viewControllerArray)
        {
            if ([vc isKindOfClass:[DashBoardSettingVC class]] || [vc isKindOfClass:[RmsDashboardVC class]])
            {
                [self.navigationController popToViewController:vc animated:TRUE];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.filterTypeTable)
    {
        return self.filterTypeArray.count;
    }
    else
    {
        NSArray *sections = self.CustomerListRC.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        return sectionInfo.numberOfObjects;

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell.backgroundColor = [UIColor clearColor];
    if(tableView == self.filterTypeTable)
    {
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *filterCell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"filterCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        filterCell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        filterCell.textLabel.text = (self.filterTypeArray)[indexPath.row];
        cell = filterCell;

    }
    else
    {

    static NSString *cellIdentifier = @"CustomerDetailCell";
        
    customerCell  = (CustomerDetailCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
        Customer * objCustomer = [self.CustomerListRC objectAtIndexPath:indexPath];
    customerCell.lblFirstName.text = objCustomer.firstName;
    customerCell.lblLastName.text = objCustomer.lastName;
    customerCell.lblConatctNo.text = objCustomer.contactNo;
    customerCell.lblEmail.text = objCustomer.email;
    customerCell.lblCity.text = objCustomer.city;
    customerCell.lblZipCode.text = objCustomer.zipCode.stringValue;
    customerCell.lblQRcode.text = objCustomer.qRCode;

    (customerCell.btnView).tag = indexPath.row;
    [customerCell.btnView addTarget:self action:@selector(viewCustomer:) forControlEvents:UIControlEventTouchUpInside];
        
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithWhite:0.745 alpha:1.000];
    customerCell.selectedBackgroundView = selectionColor;

    (customerCell.btnDelete).tag = indexPath.section;
    [customerCell.btnDelete addTarget:self action:@selector(deleteCustomerSwipe:) forControlEvents:UIControlEventTouchUpInside];
        customerCell.backgroundColor = [UIColor clearColor];
    [self customerSwipeMethod:customerCell indexPath:indexPath];

    cell = customerCell;

    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (tableView == self.filterTypeTable)
     {
        [self.rmsDbController playButtonSound];
        if(indexPath.row == 0)
        {
            self.rmsDbController.customerSelectedFilterType = @"ABC Shorting";
            self.isKeywordFilter = FALSE;
            self.isContinuousFiltering = TRUE;
            _txtCustomer.placeholder = @"Customer Name";
            [_txtCustomer setValue:[UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000]
                       forKeyPath:@"_placeholderLabel.textColor"];
            self.filterTypeTable.hidden = YES;
        }
        else if (indexPath.row == 1)
        {
            self.rmsDbController.customerSelectedFilterType = @"Keyword";
            self.isKeywordFilter = TRUE;
            self.isContinuousFiltering = FALSE;
            _txtCustomer.placeholder = @"Customer Name , Contact No , Email , Customer No";
            [_txtCustomer setValue:[UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000]
                       forKeyPath:@"_placeholderLabel.textColor"];
            self.filterTypeTable.hidden = YES;
        }
        if((_txtCustomer.text.length > 0) || (self.searchText.length > 0))
        {
            _txtCustomer.text = @"";
            self.searchText = @"";
        
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        }
         _CustomerListRC = nil;
        [_tblCustomer reloadData];
        [_activityIndicator hideActivityIndicator];;
     }
    else
    {
        Customer *searchCustomer = [self.CustomerListRC objectAtIndexPath:indexPath];
        self.custDetail = [searchCustomer.customerInfoDictionary mutableCopy];
    }
}

- (void)customerSwipeMethod:(CustomerDetailCell *)cell_p indexPath:(NSIndexPath *)indexPath
{
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [cell_p addGestureRecognizer:gestureRight];

    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell_p addGestureRecognizer:gestureLeft];

    if(indexPath.section == self.indPath.section && indexPath.row == self.indPath.row)
    {
        cell_p.viewOperation.frame = CGRectMake(0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
        cell_p.viewOperation.hidden = NO;
    }
    else
    {
        cell_p.viewOperation.frame = CGRectMake(913.0, cell_p.viewOperation.frame.origin.y, cell_p.viewOperation.frame.size.width, cell_p.viewOperation.frame.size.height);
        cell_p.viewOperation.hidden = YES;
    }
}

#pragma mark - Left / Right / Edit / Delete swipe Method

-(void)didSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:_tblCustomer];
    NSIndexPath *swipedIndexPath = [_tblCustomer indexPathForRowAtPoint:location];
    self.indPath = swipedIndexPath;
    strSwipeDire = @"Right";
//    strCustID = @"";
    [_tblCustomer reloadData];
}

-(void)didSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:_tblCustomer];
    NSIndexPath *swipedIndexPath = [_tblCustomer indexPathForRowAtPoint:location];
    if(self.indPath.row == swipedIndexPath.row)
    {
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        strSwipeDire = @"Left";
        [_tblCustomer reloadData];
    }
}

-(void)editCustomerWithDetail :(NSMutableDictionary *)customerDetail
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    addCustomerVC = [storyBoard instantiateViewControllerWithIdentifier:@"AddCustomerVC"];
    addCustomerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    addCustomerVC.addCustomerVCdelegate = self;
    addCustomerVC.view.frame=self.view.bounds;
    addCustomerVC.view.tag = 2626;
//    addCustomerVC.customerDetailDict = [customerDetail mutableCopy];
    addCustomerVC.rapidCustomerLoyalty = [self configureCustomerForDetail:customerDetail];
    [self.view addSubview:addCustomerVC.view];
}
-(RapidCustomerLoyalty *)configureCustomerForDetail:(NSMutableDictionary *)customerDetail
{
    RapidCustomerLoyalty *rapidCustomerLoyalty = [[RapidCustomerLoyalty alloc]init];
    [rapidCustomerLoyalty setupCustomerDetail:customerDetail];
    return rapidCustomerLoyalty;
}


-(void)viewCustomer:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];


    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tblCustomer];
    currentViewedCustomerIndexpath = [_tblCustomer indexPathForRowAtPoint:buttonPosition];
    
    Customer *searchCustomer = [self.CustomerListRC objectAtIndexPath:currentViewedCustomerIndexpath];


    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:searchCustomer.custId forKey:@"CustomerId"];
    [itemparam setValue:@"All" forKey:@"TimeDuration"];
    [itemparam setValue:strDateTime forKey:@"FromDate"];
    [itemparam setValue:strDateTime forKey:@"ToDate"];
    [itemparam setValue:strDateTime forKey:@"LocalDateTime"];
   
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self detailsForCustomerResponse:response error:error];
        });
    };

    self.customerLoyaltyConnection = [self.customerLoyaltyConnection initWithRequest:KURL actionName:WSM_DETAIL_FOR_CUSTOMER params:itemparam completionHandler:completionHandler];

}


- (void)detailsForCustomerResponse:(id)response error:(NSError *)error
{
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [_activityIndicator hideActivityIndicator];;
                Customer *searchCustomer = [self.CustomerListRC objectAtIndexPath:currentViewedCustomerIndexpath];

                NSMutableArray *responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomerLoyalty" bundle:nil];
                CustomerLoyaltyVC *customerLoyalty = [storyBoard instantiateViewControllerWithIdentifier:@"CustomerLoyaltyVC"];
                customerLoyalty.customerLoyaltyVCDelegate = self;
                customerLoyalty.customerLoyaltyDetail = responsearray;
                customerLoyalty.isFromDashBoard = isFromDashBoard;
                customerLoyalty.rapidCustomerLoyaltyVCObject = [self configureCustomerForDetail:searchCustomer.customerInfoDictionary.mutableCopy];
                [self.navigationController pushViewController:customerLoyalty animated:YES];
                
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured in Customer Detail View Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];;
}


-(void)deleteCustomerSwipe:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightCustomerLoyalty];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to delete customer. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    CustomerViewController * __weak myWeakReference = self;

    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        myWeakReference.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        strSwipeDire = @"Left";
        [_tblCustomer reloadData];
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference deleteCustomer];
    };

    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to delete this Customer?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)deleteCustomer
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    Customer *searchCustomer = [self.CustomerListRC objectAtIndexPath:self.indPath];

    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:searchCustomer.custId forKey:@"CustId"];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteCustomerResponse:response error:error];
        });
    };
    
    self.deleteCustomerConnection = [self.deleteCustomerConnection initWithRequest:KURL actionName:WSM_DELETE_CUSTOMER params:itemparam completionHandler:completionHandler];
    
}

-(void)deleteCustomerResponse:(id)response error:(NSError *)error
{
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self updateDataInDataBase];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Deleted Successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                _txtCustomer.text = @"";
                _isCustomerDeleted = YES;
                Customer *searchCustomer = [self.CustomerListRC objectAtIndexPath:self.indPath];
                [self.managedObjectContext deleteObject:searchCustomer];
                [UpdateManager saveContext:self.managedObjectContext];
                self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
            }
            else if([[response valueForKey:@"IsError"] intValue] == -1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Can not delete customer due to remaining House Charge balance." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured in Delete Customer." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
        
}

-(void)updateDataInDataBase {
    
    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
    [itemLiveUpdate setValue:@"Update" forKeyPath:@"Action"];
    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
    [itemLiveUpdate setValue:@"Customer" forKey:@"Type"];
    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.filterTypeTable.hidden = YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.filterTypeTable.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];

    [textField resignFirstResponder];
    if (textField.text.length > 0)
    {
        [self btnSearchClick:nil];
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(!self.isKeywordFilter)
    {
        if(self.isContinuousFiltering)
        {
            if(textField == _txtCustomer)
            {
                _txtCustomer.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
                _CustomerListRC = nil;
                [_tblCustomer reloadData];
              [_activityIndicator hideActivityIndicator];
                return NO;
            }
        }
    }
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"";
    self.searchText = @"";
//    self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
//    [_tblCustomer scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
   // [self checkItemFilterType];

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    _CustomerListRC = nil;
    [_tblCustomer reloadData];
    [_activityIndicator hideActivityIndicator];;


    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didUpdateCustomerList
{
    [self CustomerList:@""];
}

-(void)didCustomerWithHouseChargeDetail:(NSMutableDictionary *)customerDictionary withAmount:(CGFloat)balanceAmount withIsCollectPay:(BOOL)isCollectPay
{
    RapidCustomerLoyalty *rapidCustomerLoyalty = [[RapidCustomerLoyalty alloc] init];
    [rapidCustomerLoyalty setupCustomerDetail:customerDictionary];
    rapidCustomerLoyalty.balanceAmount = @(balanceAmount);
    [self.customerSelectionDelegate didSelectCustomerWithDetail:rapidCustomerLoyalty customerDictionary:self.custDetail withIsCustomerFromHouseCharge:TRUE withIscollectPay:isCollectPay];
}

#pragma mark - CoreData Methods -
-(void)deleteAllCustomers{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customer" inManagedObjectContext:privateContextObject];
    [fetchRequest setEntity:entity];
    NSArray * arrAllCustomer = [UpdateManager executeForContext:privateContextObject FetchRequest:fetchRequest];
    for (Customer * objCustomer in arrAllCustomer) {
        [privateContextObject deleteObject:objCustomer];
    }
    [UpdateManager saveContext:privateContextObject];
}
- (NSFetchedResultsController *)CustomerListRC {
    
    if (_CustomerListRC != nil) {
        return _CustomerListRC;
    }
    
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customer" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    

    fetchRequest.fetchBatchSize = 30;
   
    [fetchRequest setPredicate:[self searchPredicateForText:_txtCustomer.text]];
    
    NSSortDescriptor * aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:TRUE];
    NSArray *sortDescriptors = @[aSortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _CustomerListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_CustomerListRC performFetch:nil];
    _CustomerListRC.delegate = self;
    return _CustomerListRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.CustomerListRC]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblCustomer beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.CustomerListRC]) {
        return;
    }
    
    UITableView *tableView = self.tblCustomer;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([[tableView indexPathsForVisibleRows] indexOfObject:indexPath] != NSNotFound) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.CustomerListRC]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblCustomer insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblCustomer deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.CustomerListRC]) {
        return;
    }
    [self.tblCustomer endUpdates];
}

#pragma mark - Scanner Device Methods

-(void)deviceButtonPressed:(int)which {
    if ([self.rmsDbController.globalScanDevice[@"Type"]isEqualToString:@"Scanner"]) {
        //if([self.scannerButtonCalled isEqualToString:@"InvenMgmt"]) {
        self.searchText = @"";
        //}
    }
}
//
-(void)deviceButtonReleased:(int)which {
    if ([self.rmsDbController.globalScanDevice[@"Type"]isEqualToString:@"Scanner"]) {
        //if([self.rimsController.scannerButtonCalled isEqualToString:@"InvenMgmt"]) {
        if(![self.searchText isEqualToString:@""]) {
            [_tblCustomer reloadData];
        }
        //}
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type {
    if ([self.rmsDbController.globalScanDevice[@"Type"]isEqualToString:@"Scanner"]) {
        self.searchText = barcode;
        self.txtCustomer.text = barcode;
        //ISscan = true;
    }
    else {
        [self showMessage:@"Please set scanner type as scanner."];
    }
}

-(void)showMessage:(NSString *)strMessage {
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Customer List" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

-(void)barcodeScanned:(NSString *)strBarcode {
//    ISscan = true;
    [self.txtCustomer resignFirstResponder];
    self.searchText = strBarcode;
    self.txtCustomer.text = strBarcode;
    [_tblCustomer reloadData];
    
}

@end
