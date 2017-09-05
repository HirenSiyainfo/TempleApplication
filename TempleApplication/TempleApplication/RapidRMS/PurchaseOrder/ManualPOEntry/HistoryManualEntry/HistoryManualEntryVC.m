//
//  RecallManualEntryVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 17/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HistoryManualEntryVC.h"
#import "RmsDbController.h"
#import "HistoryManualEntryCustomeCell.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "UpdateManager.h"
#import "ManualPOSession.h"
#import "UpdateManager.h"
#import "ManualReceivedItem+Dictionary.h"
#import "ManualEntryRecevieItemList.h"
#import "ManualPOEntryHomeVC.h"
#import "MEHistroyFilterVC.h"
#import "Item.h"

@interface HistoryManualEntryVC ()<MEFilterDelegate>
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnSearch;
@property (nonatomic, weak) IBOutlet UITextField *universalSearch;

@property(nonatomic, strong) NSDate *fromdate;
@property(nonatomic, strong) NSDate *todate;

@property (nonatomic, weak) IBOutlet UITableView *tblHistoryManualEntry;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) HistoryManualEntryCustomeCell *historyManualEntryCustomeCell;
@property (nonatomic, strong) ManualPOSession *tempSession;

@property (nonatomic, strong) RapidWebServiceConnection *historyManualEntryServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *histroyManualItemreceive;
@property (nonatomic, strong) RapidWebServiceConnection *filterWebserviceConnection;

@property (nonatomic, strong) NSMutableDictionary *dictPODetail;

@property (nonatomic, strong) NSArray *arrayItemCount;
@property (nonatomic, strong) NSMutableArray *arrHistoryManualEntryGlabal;
@property (nonatomic, strong) NSMutableArray *arrHistoryManualEntry;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak)  IBOutlet UIButton *histroyFilter;

@property (nonatomic, strong) UIPopoverController *dateTimePopOverView;

@end

@implementation HistoryManualEntryVC
@synthesize managedObjectContext = __managedObjectContext;

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.historyManualEntryServiceConnection = [[RapidWebServiceConnection alloc] init];
    
    self.histroyManualItemreceive = [[RapidWebServiceConnection alloc]init];
    self.filterWebserviceConnection = [[RapidWebServiceConnection alloc]init];
    
    self.arrHistoryManualEntry = [[NSMutableArray alloc] init];
    self.arrHistoryManualEntryGlabal = [[NSMutableArray alloc]init];
    
    self.todate = [NSDate date];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = -1;
    
    self.fromdate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self.todate options:0];
    
    [self callWebServiceForManualEntryHistory:self.fromdate toDate:self.todate];

    //[self callWebServiceForManualEntryHistory];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSManagedObjectContext *moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];

    [self.updateManager cleanUptheManaulPoTables:moc];
}

- (NSArray*)fetchAllPoDetails:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualPOSession" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}
- (NSArray*)fetchAllPoitemDetails:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualReceivedItem" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    return arryTemp;
}

- (void)callWebServiceForManualEntryHistory:(NSDate *)fromdate toDate:(NSDate *)todate
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    param[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    formatter1.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime1 = [formatter1 stringFromDate:fromdate];
    param[@"StartDate"] = currentDateTime1;
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    formatter2.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime2 = [formatter2 stringFromDate:todate];
    param[@"EndDate"] = currentDateTime2;

    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self histroyManualEntryHistoryResponse:response error:error];
         });
    };
    self.historyManualEntryServiceConnection = [self.historyManualEntryServiceConnection initWithRequest:KURL actionName:WSM_RECONCILE_MANUAL_ENTRY_HISTORY_BYDATE params:param completionHandler:completionHandler];
}

- (void)histroyManualEntryHistoryResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
        
            if ([[response valueForKey:@"IsError"] intValue] == 0 )
            {
                response = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if (response != nil) {
                    [self setSupplierName:response];
                    self.arrHistoryManualEntry = [response mutableCopy];
                    self.arrHistoryManualEntryGlabal = [response mutableCopy];
                    [_tblHistoryManualEntry reloadData];
                }
                else
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"No Record Found" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
                
            }
        }
    }
}

-(void)setSupplierName:(NSMutableArray *)response{
  
    for (NSMutableDictionary *dict in response) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %d",[[dict valueForKey:@"SupplierId"] integerValue]];
        fetchRequest.predicate = predicate;
        NSArray *uniqueVendors = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        
        SupplierCompany *suppComp = [uniqueVendors firstObject];
        if(suppComp!=nil){
            [dict setObject:suppComp.companyName forKey:@"CompanyName"];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.arrHistoryManualEntry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"HistoryManualEntryCustomeCell";
   
    _historyManualEntryCustomeCell = (HistoryManualEntryCustomeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    _historyManualEntryCustomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableDictionary *historyManualEntryDictionary = self.arrHistoryManualEntry[indexPath.row];
    

    _historyManualEntryCustomeCell.lblVendorName.text = [self fetchSupplierName:[[historyManualEntryDictionary valueForKey:@"SupplierId"] stringValue]];
    _historyManualEntryCustomeCell.lblInvoiceNo.text = [historyManualEntryDictionary valueForKey:@"InvoiceNo"];
 //   _historyManualEntryCustomeCell.lblManualEntryPONo.text = [[historyManualEntryDictionary valueForKey:@"ManualEntryId"] stringValue];
    _historyManualEntryCustomeCell.lblTitle.text = [historyManualEntryDictionary valueForKey:@"Remarks"] ;

    _historyManualEntryCustomeCell.lblDateReceived.text = [self getStringFormate:[historyManualEntryDictionary valueForKey:@"ReceiveDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];
    _historyManualEntryCustomeCell.lblDateStarted.text = [self getStringFormate:[historyManualEntryDictionary valueForKey:@"LocalDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];
    _historyManualEntryCustomeCell.lblDateClosed.text = [self getStringFormate:[historyManualEntryDictionary valueForKey:@"CloseDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMM dd, yyyy"];

    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
    _historyManualEntryCustomeCell.selectedBackgroundView = selectionColor;

    return _historyManualEntryCustomeCell;
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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    self.dictPODetail = (self.arrHistoryManualEntry)[indexPath.row];
    
    if([[self.dictPODetail valueForKey:@"Status"] isEqualToString:@"InProcess"]){
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self callRecallItemWebservice];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Are you sure you want to procide with inprocess manual entry " buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        
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
    
    self.histroyManualItemreceive = [self.histroyManualItemreceive initWithRequest:KURL actionName:WSM_MANUAL_ENTRY_ITEM_DETAIL params:param completionHandler:completionHandler];
    
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
                //[self.navigationController popViewControllerAnimated:YES];
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
        
        dict[@"createDate"] = [NSDate date];
        
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
//            objManualItem.showView=YES;
//        }
//    }
    
    UIStoryboard *storyBoard1 = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    ManualEntryRecevieItemList *manualEntryList = [storyBoard1 instantiateViewControllerWithIdentifier:@"ManualEntryRecevieItemList"];
    manualEntryList.posession=_tempSession;
    manualEntryList.strManualPoID=[self.dictPODetail valueForKey:@"ManualEntryId"];
    manualEntryList.strInvoiceNo = [self.dictPODetail valueForKey:@"InvoiceNo"];
    manualEntryList.strTitle = [self.dictPODetail valueForKey:@"Remarks"];
    manualEntryList.dictSupplier=[self supplierDictionary];
    manualEntryList.isHistory = YES;
    manualEntryList.showView=YES;
    [self.navigationController pushViewController:manualEntryList animated:NO];
    
}

-(NSMutableDictionary *)supplierDictionary{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"Suppid"] = [self.dictPODetail valueForKey:@"SupplierId"];
    
    SupplierCompany *supMaster = [self fetchSupplierFromSupplierCompany:[self.dictPODetail valueForKey:@"SupplierId"]];
    
    NSString *strReceivingDate = [self getStringFormate:[self.dictPODetail valueForKey:@"ReceiveDate"] fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy"];
    
    dict[@"invoiceNo"] = [self.dictPODetail valueForKey:@"InvoiceNo"];
    
    dict[@"ReceiveDate"] = strReceivingDate;
    if(supMaster != nil)
    {
         dict[@"SuppName"] = supMaster.companyName;
    }
    return dict;
}

- (SupplierCompany *)fetchSupplierFromSupplierCompany :(NSString *)supplierID
{
    SupplierCompany *suppMaster = nil;
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
#pragma mark - Filter Datewise Histroy

-(IBAction)openDateFilter:(id)sender
{
    if (self.dateTimePopOverView.popoverVisible)
    {
        [self.dateTimePopOverView dismissPopoverAnimated:YES];
    }
    else
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        MEHistroyFilterVC *histroyFilter = [storyBoard instantiateViewControllerWithIdentifier:@"MEHistroyFilterVC"];
        histroyFilter.meFilterDelegate = self;
        histroyFilter.fromdate = self.fromdate;
        histroyFilter.todate = self.todate;
        self.dateTimePopOverView = [[UIPopoverController alloc] initWithContentViewController:histroyFilter];
        self.dateTimePopOverView.popoverContentSize = CGSizeMake(360, 398);

        CGRect pooverRect = CGRectMake(self.histroyFilter.frame.origin.x, self.histroyFilter.frame.origin.y , self.histroyFilter.frame.size.width, self.histroyFilter.frame.size.height);
        [self.dateTimePopOverView presentPopoverFromRect:pooverRect inView:self.view
                             permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

-(void)didSubmitewithDate:(NSDate *)fromdate toDate:(NSDate *)todate
{
    [self callWebServiceForManualEntryHistory:fromdate toDate:todate];
    [self.dateTimePopOverView dismissPopoverAnimated:YES];
    self.fromdate = fromdate;
    self.todate = todate;
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(textField.text.length>0){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"InvoiceNo contains[cd] %@ || ManualEntryId == %d",textField.text ,[textField.text integerValue]];
        self.arrHistoryManualEntry = (NSMutableArray *)[self.arrHistoryManualEntry filteredArrayUsingPredicate:predicate];
        [self.tblHistoryManualEntry reloadData];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField.text.length>0){
       NSPredicate *predicate = [NSPredicate predicateWithFormat:@"CompanyName contains[cd] %@ || InvoiceNo contains[cd] %@ || ManualEntryId == %d",textField.text,textField.text,[textField.text integerValue]];
        self.arrHistoryManualEntry = (NSMutableArray *)[self.arrHistoryManualEntryGlabal
 filteredArrayUsingPredicate:predicate];
        [self.tblHistoryManualEntry reloadData];
    }

    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
     NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(searchString.length==0){
        self.arrHistoryManualEntry = self.arrHistoryManualEntryGlabal;
        [self.tblHistoryManualEntry reloadData];
    }
    else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"CompanyName contains[cd] %@ || InvoiceNo contains[cd] %@ || ManualEntryId == %d",searchString,searchString,[searchString integerValue]];
        self.arrHistoryManualEntry = (NSMutableArray *)[self.arrHistoryManualEntryGlabal filteredArrayUsingPredicate:predicate];
        [self.tblHistoryManualEntry reloadData];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.arrHistoryManualEntry = self.arrHistoryManualEntryGlabal;
    [self.tblHistoryManualEntry reloadData];
    return YES;
}

-(IBAction)universalSearchClick:(id)sender{
    
    if(self.universalSearch.text.length>0){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"CompanyName contains[cd] %@ || InvoiceNo contains[cd] %@ || ManualEntryId == %d",self.universalSearch.text,self.universalSearch.text,[self.universalSearch.text integerValue]];
        self.arrHistoryManualEntry = (NSMutableArray *)[self.arrHistoryManualEntryGlabal filteredArrayUsingPredicate:predicate];
        [self.tblHistoryManualEntry reloadData];

    }
}

#pragma mark

-(NSDate *)getDateFromString:(NSString *)strDate{
    
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    dateFormatter.dateFormat = @"mm/dd/yyyy HH:mm:ss";
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;
    
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
