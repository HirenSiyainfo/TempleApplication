//
//  RecallManualEntryVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 17/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RecallManualEntryVC.h"
#import "RmsDbController.h"
#import "RecallManualEntryCustomeCell.h"
#import "UpdateManager.h"
#import "ManualPOSession.h"
#import "UpdateManager.h"
#import "ManualReceivedItem+Dictionary.h"
#import "ManualEntryRecevieItemList.h"
#import "ManualPOEntryHomeVC.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "ManualEntryRecevieItemList.h"
#import "Item+Dictionary.h"

@interface RecallManualEntryVC ()
{
    NSString *strSwipeDire;
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UITableView *tblHoldManualEntryHistory;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) ManualPOSession *tempSession;
@property (nonatomic, strong) RecallManualEntryCustomeCell *recallManualEntryCustomeCell;

@property (nonatomic, strong) RapidWebServiceConnection *recallManualEntryServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *deleteManualEntryServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *recallManualEntryItemServiceConnection;

@property (nonatomic, strong) NSIndexPath *indPath;

@property (nonatomic, strong) NSMutableDictionary *dictPODetail;

@property (nonatomic, strong) NSArray *arrayItemCount;
@property (nonatomic, strong) NSMutableArray *arrHoldManualEntryHistory;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation RecallManualEntryVC

@synthesize managedObjectContext = __managedObjectContext;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
     [self.updateManager cleanUptheManaulPoTables:moc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.recallManualEntryServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.deleteManualEntryServiceConnection = [[RapidWebServiceConnection alloc] init];
     self.recallManualEntryItemServiceConnection = [[RapidWebServiceConnection alloc] init];
    
    _arrHoldManualEntryHistory = [[NSMutableArray alloc] init];
    
    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];

    [self callWebServiceForHoldManualEntryHistory];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
   // self.view.clipsToBounds=YES;

   
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)callWebServiceForHoldManualEntryHistory
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self holdManualEntryHistoryResponse:response error:error];
              });
    };
    
    self.recallManualEntryServiceConnection = [self.recallManualEntryServiceConnection initWithRequest:KURL actionName:WSM_HOLD_MANUAL_ENTERY_HISTORY params:param completionHandler:completionHandler];
    
}

- (void)holdManualEntryHistoryResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                response = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                _arrHoldManualEntryHistory = [response mutableCopy];
                [_tblHoldManualEntryHistory reloadData];
            }
        }
    }
}

- (IBAction)btnBackClicked:(id)sender
{
    NSArray *arrayView = self.navigationController.viewControllers;
    for(UIViewController *viewcon in arrayView){
        if([viewcon isKindOfClass:[ManualPOEntryHomeVC class]]){
            [self.navigationController popToViewController:viewcon animated:YES];
    
        }
    }
}

-(NSString *)fetchSupplierName:(NSString *)supplierId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId==%d",supplierId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *arrSupplierDetail = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    NSString *strSupplierName = [[NSString alloc] init];
    if (arrSupplierDetail.count>0)
    {
        SupplierCompany *supplierCompany = arrSupplierDetail.firstObject;
        NSDictionary *supplierCompanyDictionary=supplierCompany.supplierCompanyDetailsDictionary;
        strSupplierName = [supplierCompanyDictionary valueForKey:@"FirstName"];
    }
    return strSupplierName;
}

- (NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    dateFormatter2.dateFormat = pstrToformate;
    NSString *result = [dateFormatter2 stringFromDate:dateFromString];
    
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.arrHoldManualEntryHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"RecallManualEntry";
    
    _recallManualEntryCustomeCell = (RecallManualEntryCustomeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    _recallManualEntryCustomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableDictionary *recallManualEntryDictionary = _arrHoldManualEntryHistory[indexPath.row];
    
    _recallManualEntryCustomeCell.lblVendorName.text = [self fetchSupplierName:[[recallManualEntryDictionary valueForKey:@"SupplierId"] stringValue]];
    _recallManualEntryCustomeCell.lblInvoiceNo.text = [recallManualEntryDictionary valueForKey:@"InvoiceNo"];
  //  _recallManualEntryCustomeCell.lblManualEntryPONo.text = [[recallManualEntryDictionary valueForKey:@"ManualEntryId"] stringValue];
    _recallManualEntryCustomeCell.lblTitle.text = [recallManualEntryDictionary valueForKey:@"Remarks"];

    _recallManualEntryCustomeCell.lblDateReceived.text = [self getStringFormate:[recallManualEntryDictionary valueForKey:@"ReceiveDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];
    _recallManualEntryCustomeCell.lblDateStarted.text = [self getStringFormate:[recallManualEntryDictionary valueForKey:@"LocalDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
    _recallManualEntryCustomeCell.selectedBackgroundView = selectionColor;
    
    _recallManualEntryCustomeCell.btnDelete.tag = indexPath.section;
    [_recallManualEntryCustomeCell.btnDelete addTarget:self action:@selector(deleteManualEntrySwipe:) forControlEvents:UIControlEventTouchUpInside];
    
    [self recallManualEntrySwipe:_recallManualEntryCustomeCell indexPath:indexPath];
    
    return _recallManualEntryCustomeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.dictPODetail = (self.arrHoldManualEntryHistory)[indexPath.row];
    
    if([[self.dictPODetail valueForKey:@"Status"] isEqualToString:@"InProcess"]){
        
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
             [self callRecallItemWebservice];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Are you sure you want to provide with inprocess manual entry " buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];

    }
    else{
     
        [self callRecallItemWebservice];
    }
    
}
-(void)callRecallItemWebservice{

    NSMutableDictionary *dictPoSession = [[NSMutableDictionary alloc]init];
    dictPoSession[@"manualPoId"] = [self.dictPODetail valueForKey:@"ManualEntryId"];
    dictPoSession[@"invoiceNumber"] = [self.dictPODetail valueForKey:@"InvoiceNo"];
    dictPoSession[@"poRemark"] = [self.dictPODetail valueForKey:@"Remarks"];
    
    NSDate *localDate = [self getDateFromString:[self.dictPODetail valueForKey:@"LocalDate"]];
    
    dictPoSession[@"receivedDate"] = localDate;
    dictPoSession[@"poNum"] = [self.dictPODetail valueForKey:@"InvoiceNo"];
    dictPoSession[@"supplierId"] = [self.dictPODetail valueForKey:@"SupplierId"];
    
    _tempSession = [self.updateManager fetchManualPOWithDictionary:[[self.dictPODetail valueForKey:@"ManualEntryId"]integerValue ] withManageObjectContext:self.managedObjectContext];
    
    if(_tempSession==nil)
    {
        _tempSession  = [self.updateManager insertManualPOWithDictionary:dictPoSession];
        
    }
    
    [self callWebServiceForHoldManualEntryitemList];
}

- (void)callWebServiceForHoldManualEntryitemList
{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
     [param setValue:[self.dictPODetail valueForKey:@"ManualEntryId"] forKey:@"ManualEntryId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self manyalEntryItemDetailResponse:response error:error];
              });
    };
    
    self.recallManualEntryItemServiceConnection = [self.recallManualEntryItemServiceConnection initWithRequest:KURL actionName:WSM_MANUAL_ENTRY_ITEM_DETAIL params:param completionHandler:completionHandler];
    
}

- (void)manyalEntryItemDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                response = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                _arrayItemCount=(NSArray *)response;
                [self storeManualReceiveItems:response];
            }
        }
    }
    
}

-(void)storeManualReceiveItems:(NSMutableArray *)arrayTemp{
    
    for(int i=0;i<arrayTemp.count;i++){
        
        NSMutableArray *dictTemp  = arrayTemp[i];
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        dict[@"caseCost"] = [dictTemp valueForKey:@"CaseCost"];
        dict[@"caseMarkup"] = @"0";
        dict[@"casePrice"] = [dictTemp valueForKey:@"CasePrice"];
        dict[@"caseQuantityReceived"] = [dictTemp valueForKey:@"CaseReceivedQty"];
        dict[@"cashQtyonHand"] = [dictTemp valueForKey:@"CaseOnHandQty"];
        
        dict[@"packCost"] = [dictTemp valueForKey:@"PackCost"];
        dict[@"packMarkup"] = @"0";
        dict[@"packPrice"] = [dictTemp valueForKey:@"PackPrice"];
        dict[@"packQuantityReceived"] = [dictTemp valueForKey:@"PackReceivedQty"];
        dict[@"packQtyonHand"] = [dictTemp valueForKey:@"PackOnHandQty"];
        
        dict[@"unitCost"] = [dictTemp valueForKey:@"Cost"];
        dict[@"unitMarkup"] = @"0";
        dict[@"unitPrice"] = [dictTemp valueForKey:@"Price"];
        dict[@"unitQuantityReceived"] = [dictTemp valueForKey:@"SingleReceivedQty"];
        dict[@"unitQtyonHand"] = [dictTemp valueForKey:@"SingleOnHandQty"];
        
        dict[@"LocalDate"] = [NSDate date];
        
        dict[@"receivedItemId"] = [dictTemp valueForKey:@"Id"];
        
        dict[@"singleReceivedFreeGoodQty"] = [dictTemp valueForKey:@"SingleReceivedFreeGoodQty"];
        dict[@"packReceivedFreeGoodQty"] = [dictTemp valueForKey:@"PackReceivedFreeGoodQty"];
        dict[@"caseReceivedFreeGoodQty"] = [dictTemp valueForKey:@"CaseReceivedFreeGoodQty"];
        
        dict[@"freeGoodCost"] = [dictTemp valueForKey:@"FreeGoodCost"];
        dict[@"freeGoodPackCost"] = [dictTemp valueForKey:@"FreeGoodPackCost"];
        dict[@"freeGoodCaseCost"] = [dictTemp valueForKey:@"FreeGoodCaseCost"];
        
        if([dictTemp valueForKey:@"IsReturn"])
        {
            dict[@"isReturn"] = [dictTemp valueForKey:@"IsReturn"];

        }
        
        
        NSString *itemCode = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"ItemCode"]];
        Item *anItem = [self fetchAllItems:itemCode];
        
        ManualReceivedItem *manualItem=nil;
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        [self.updateManager updateItemReceiveListwithDetail:dict withItem:(Item *)OBJECT_COPY(anItem, privateContextObject) withitemReceive:manualItem withManualPoSession:(ManualPOSession *)OBJECT_COPY(_tempSession, privateContextObject) withManageObjectContext:privateContextObject];

        _tempSession = (ManualPOSession *)OBJECT_COPY(_tempSession, self.managedObjectContext);
    }
    
//    NSArray *arrayView = [self.navigationController viewControllers];
//    for(UIViewController *viewcon in arrayView){
//        if([viewcon isKindOfClass:[ManualEntryRecevieItemList class]]){
//            ManualEntryRecevieItemList *objManualItem = (ManualEntryRecevieItemList *)viewcon;
//            objManualItem.posession=_tempSession;
//            objManualItem.strManualPoID=[self.dictPODetail valueForKey:@"ManualEntryId"];
//            objManualItem.strInvoiceNo = [self.dictPODetail valueForKey:@"InvoiceNo"];
//            objManualItem.dictSupplier=[self supplierDictionary];
//        }
//    }
    
    UIStoryboard *storyBoard1 = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    ManualEntryRecevieItemList *manualEntryList = [storyBoard1 instantiateViewControllerWithIdentifier:@"ManualEntryRecevieItemList"];
    manualEntryList.posession=_tempSession;
    manualEntryList.strManualPoID=[self.dictPODetail valueForKey:@"ManualEntryId"];
    manualEntryList.strInvoiceNo = [self.dictPODetail valueForKey:@"InvoiceNo"];
    manualEntryList.strTitle = [self.dictPODetail valueForKey:@"Remarks"];
    manualEntryList.dictSupplier=[self supplierDictionary];
    manualEntryList.isHistory = NO;
    manualEntryList.showView=NO;
    [self.navigationController pushViewController:manualEntryList animated:NO];
}

-(NSMutableDictionary *)supplierDictionary{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"Suppid"] = [self.dictPODetail valueForKey:@"SupplierId"];
    
    SupplierCompany *supMaster = [self fetchSupplierFromSupplierCompany:[self.dictPODetail valueForKey:@"SupplierId"]];
    
    NSString *strReceivingDate = [self getStringFormate:[self.dictPODetail valueForKey:@"ReceiveDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy"];
    
    dict[@"invoiceNo"] = [self.dictPODetail valueForKey:@"InvoiceNo"];

    dict[@"ReceiveDate"] = strReceivingDate;
    if(supMaster!=nil){
        dict[@"SuppName"] = supMaster.companyName;
    }
    
    return dict;
}

- (SupplierCompany *)fetchSupplierFromSupplierCompany :(NSString *)supplierID
{
    SupplierCompany *suppMaster=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SupplierCompany" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId==%d", supplierID.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        suppMaster=resultSet.firstObject;
    }
    return suppMaster;
}


- (Item *)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
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


-(NSDate *)getDateFromString:(NSString *)strDate{
    
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    dateFormatter.dateFormat = @"mm/dd/yyyy HH:mm:ss";
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;

}


//-(ManualPOSession *)insertPOWithDictionary:(NSString *)strPOID{
//    
//   
//    
//}


- (void)recallManualEntrySwipe:(RecallManualEntryCustomeCell *)cell_p indexPath:(NSIndexPath *)indexPath
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
    CGPoint location = [gesture locationInView:_tblHoldManualEntryHistory];
    NSIndexPath *swipedIndexPath = [_tblHoldManualEntryHistory indexPathForRowAtPoint:location];
    self.indPath = swipedIndexPath;
    strSwipeDire = @"Right";
    [_tblHoldManualEntryHistory reloadData];
}

-(void)didSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:_tblHoldManualEntryHistory];
    NSIndexPath *swipedIndexPath = [_tblHoldManualEntryHistory indexPathForRowAtPoint:location];
    if(self.indPath.row == swipedIndexPath.row)
    {
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        strSwipeDire = @"Left";
        [_tblHoldManualEntryHistory reloadData];
    }
}


-(void)deleteManualEntrySwipe:(id)sender
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        self.indPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        strSwipeDire = @"Left";
        [_tblHoldManualEntryHistory reloadData];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
         [self deleteManualEntry];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Are you sure you want to delete this Manual Entry?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)deleteManualEntry
{

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:[_arrHoldManualEntryHistory[self.indPath.row] valueForKey:@"ManualEntryId"] forKey:@"ManualEntryId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self deleteManualEntryFromRecallResponse:response error:error];
    };
    
    self.deleteManualEntryServiceConnection = [self.deleteManualEntryServiceConnection initWithRequest:KURL actionName:WSM_DELETE_MANUAL_ENTERY params:param completionHandler:completionHandler];

}

- (void)deleteManualEntryFromRecallResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
                    [self callWebServiceForHoldManualEntryHistory];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -1)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
                
                self.indPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
                [self.tblHoldManualEntryHistory reloadData];
                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Error occurred in delete Manual Entry" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
