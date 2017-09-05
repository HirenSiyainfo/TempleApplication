//
//  HPOItemListVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HPOItemListVC.h"
#import "HPOItemListCell.h"
#import "RmsDbController.h"
#import "Vendor_Item+Dictionary.h"
#import "RimsController.h"
#import "HItemCatalogVC.h"
#import "Vendor_Item+Dictionary.h"
#import "VPurchaseOrder+Dictionary.h"
#import "VPurchaseOrderItem+Dictionary.h"
#import "HProductInfoVC.h"
#import "HGenerateOrderVC.h"
#import "HScanBarcodeVC.h"
#import "HItemProductVC.h"


@interface HPOItemListVC ()

@property (nonatomic, weak) IBOutlet UILabel *lbltotalCost;
@property (nonatomic, weak) IBOutlet UILabel *lbltotalItem;
@property (nonatomic, weak) IBOutlet UILabel *lblInfoOpened;
@property (nonatomic, weak) IBOutlet UILabel *lblInfoModified;
@property (nonatomic, weak) IBOutlet UILabel *lblInfoTotalCost;
@property (nonatomic, weak) IBOutlet UILabel *lblInfoNoofItem;
@property (nonatomic, weak) IBOutlet UILabel *lblPotitle;

@property (nonatomic, weak) IBOutlet UIView *viewItemInfo;
@property (nonatomic, weak) IBOutlet UIView *viewItemInfoInnerView;

@property (nonatomic, weak) IBOutlet UITableView *tblPoItemList;

@property (nonatomic, weak) IBOutlet UITextField *txtSearchField;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) VPurchaseOrderItem *vpurchaseOrderItem;
@property (nonatomic, strong) HScanBarcodeVC *hscanBarcode;

@property (nonatomic, strong) RapidWebServiceConnection *deleteItemwebservice;

@property (nonatomic, assign) float totalCost;

@property (nonatomic, strong) NSString *strItemId;

@property (nonatomic, strong) NSMutableArray *arrayReceiveItem;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *poItemResultSetController;

@property (nonatomic, strong) NSIndexPath *deleteOrderIndPath;

@property (nonatomic, strong) NSRecursiveLock *poitemEntryLock;

@end

@implementation HPOItemListVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize vPurchaseOrder,strPoID;
@synthesize poItemResultSetController = _poItemResultSetController;
@synthesize updateManager,deleteOrderIndPath,strItemId,arrayReceiveItem,vpurchaseOrderItem,UpdateDate;

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
    
    self.deleteItemwebservice = [[RapidWebServiceConnection alloc]init];
    
    //self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.arrayReceiveItem = [[NSMutableArray alloc]init];
    
    _viewItemInfoInnerView.layer.cornerRadius=5.0;
    _viewItemInfoInnerView.layer.masksToBounds=YES;
    _viewItemInfoInnerView.layer.borderColor=[UIColor clearColor].CGColor ;
    _viewItemInfoInnerView.layer.borderWidth= 1.0f;
    
    NSString  *itemListCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        itemListCell = @"HPOItemListCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:itemListCell bundle:nil];
    [self.tblPoItemList registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HPOItemListCell"];

    VPurchaseOrder *vpurchaseOrder = [self fetchPurchaseOrder:self.strPoID];
    _lblPotitle.text=[NSString stringWithFormat:@"%@",vpurchaseOrder.orderName];
    
    self.lbltotalCost.text = [self.rmsDbController applyCurrencyFomatter:@"0"];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    _poItemResultSetController=nil;
//   [self.tblPoItemList reloadData];
     [self calculatetotalItemCost];
}
#pragma mark - Fetch All Vendor Item

- (NSFetchedResultsController *)poItemResultSetController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.poitemEntryLock];
    if (_poItemResultSetController != nil) {
        return _poItemResultSetController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VPurchaseOrderItem" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"vpoId.poId = %d",self.strPoID.integerValue];
    
    fetchRequest.predicate = predicatePO;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    //
    
    // Create and initialize the fetch results controller.
    _poItemResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _poItemResultSetController.delegate = self;
    [_poItemResultSetController performFetch:nil];
    
    NSArray *sections = _poItemResultSetController.sections;
    if(sections.count==0)
    {
        return nil;
    }
    [lock unlock];
    return _poItemResultSetController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.poItemResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 85.0;
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"HPOItemListCell";
    
    HPOItemListCell *productCell = (HPOItemListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    productCell.selectionStyle=UITableViewCellSelectionStyleNone;
    productCell.backgroundColor=[UIColor clearColor];
    
    productCell.viewUnit.layer.cornerRadius=5.0;
    productCell.viewUnit.layer.masksToBounds=YES;
    productCell.viewUnit.layer.borderColor=[UIColor colorWithRed:16.0/255.0 green:166.0/255.0 blue:172.0/255.0 alpha:1.0].CGColor ;
    productCell.viewUnit.layer.borderWidth= 3.0f;
    
    
    productCell.viewCase.layer.cornerRadius=5.0;
    productCell.viewCase.layer.masksToBounds=YES;
    productCell.viewCase.layer.borderColor=[UIColor colorWithRed:16.0/255.0 green:166.0/255.0 blue:172.0/255.0 alpha:1.0].CGColor ;
    productCell.viewCase.layer.borderWidth= 3.0f;
    
    VPurchaseOrderItem *vPoItem = [self.poItemResultSetController objectAtIndexPath:indexPath];
    NSMutableDictionary *purchaseOrderItem = [vPoItem.vendorPoItemDictionary mutableCopy];
    
    NSDictionary *vendoritemDict = vPoItem.vitems.getVendorItemDictionary;

    
    productCell.lblitemName.text=[NSString stringWithFormat:@"%@", [vendoritemDict valueForKey:@"ItemDescriptions"]];
    productCell.lblUPC.text=[NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Pack_UPC"]];
    

     productCell.lblCaseCount.text=[NSString stringWithFormat:@"%@",[purchaseOrderItem valueForKey:@"CasePOQty"]];
    productCell.lblUnitCount.text=[NSString stringWithFormat:@"%@",[purchaseOrderItem valueForKey:@"SinglePOQty"]];
    
    
    NSString *strUnitCost = [NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Unit_Cost"]];
    
    float caseCosttemp = [[vendoritemDict valueForKey:@"Unit_Cost"]floatValue]*[[vendoritemDict valueForKey:@"CaseUnits"]floatValue];

    
    float caseCost = caseCosttemp *[[purchaseOrderItem valueForKey:@"CasePOQty"]floatValue];
    
    NSString *strcaseCost = [NSString stringWithFormat:@"%.2f",caseCost];

    NSNumber *unitcostnum = @(strUnitCost.floatValue);
    
     NSNumber *casecostnum = @(strcaseCost.floatValue);
    
    productCell.lblUnitPrice.text=[NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:unitcostnum]];
    
     productCell.lblCasePrice.text=[NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:casecostnum]];
    
    
    float totalUnitCost = [[purchaseOrderItem valueForKey:@"SinglePOQty"] integerValue]*strUnitCost.floatValue;
    
    float totalCaseCost = [[purchaseOrderItem valueForKey:@"CasePOQty"] integerValue]*strcaseCost.floatValue;
    
    float totalPrice = totalUnitCost+totalCaseCost;
    
    NSNumber *price = @(totalPrice);
    
    productCell.lblPrice.text=[NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:price]];
    
    
    
    
    return productCell;

}

-(IBAction)browseOrAddItem:(id)sender{
    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//    HItemCatalogVC *hcatalog = [storyBoard instantiateViewControllerWithIdentifier:@"HItemCatalogVC"];
//    hcatalog.isfromItem=YES;
//    hcatalog.strPoID=self.strPoID;
//    [self.navigationController pushViewController:hcatalog animated:YES];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HItemProductVC *hproduct = [storyBoard instantiateViewControllerWithIdentifier:@"HItemProductVC"];
    hproduct.isfromItem=YES;
    hproduct.strPoId=self.strPoID;
    [self.navigationController pushViewController:hproduct animated:YES];
    
    
}

-(IBAction)sendPurchaseOrder:(id)sender{
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
       [self sendPurchaseOrderCall];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Confirm Send Order?" message:@"This action is final and can not be reversed." buttonTitles:@[@"Cancel",@"OK"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)sendPurchaseOrderCall{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
   
    NSMutableDictionary *poparam=[[NSMutableDictionary alloc]init];
    [poparam setValue:self.strPoID forKey:@"POId"];
    [poparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self sendPurchaseOrderItemResponse:response error:error];
        });
    };
    
    self.deleteItemwebservice = [self.deleteItemwebservice initWithRequest:KURL actionName:WSM_SENT_HACKNEY_PO params:poparam completionHandler:completionHandler];
    
}

- (void)sendPurchaseOrderItemResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    NSArray *arrayView = self.navigationController.viewControllers;
                    for(UIViewController *viewcon in arrayView){
                        if([viewcon isKindOfClass:[HGenerateOrderVC class]]){
                            [self.navigationController popToViewController:viewcon animated:YES];
                            
                        }
                    }
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Purchase order send successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Error occur while sending details" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HProductInfoVC *hitemProductinfo = [storyBoard instantiateViewControllerWithIdentifier:@"HProductInfoVC"];
    
    VPurchaseOrderItem *vPoItem = [self.poItemResultSetController objectAtIndexPath:indexPath];
    NSDictionary *vendoritemDict = vPoItem.vitems.getVendorItemDictionary;
    hitemProductinfo.isfromItem=YES;
    hitemProductinfo.isUpdate=YES;
    hitemProductinfo.strPoId=self.strPoID;
    hitemProductinfo.vpurchaseOrderItem = vPoItem;
    hitemProductinfo.dictProductInfo=[vendoritemDict mutableCopy];
    [self.navigationController pushViewController:hitemProductinfo animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES; // Return YES, if enable delete on swipe.
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        deleteOrderIndPath = [indexPath copy];
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {

        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            vpurchaseOrderItem = [self.poItemResultSetController objectAtIndexPath:deleteOrderIndPath];
            if(vpurchaseOrderItem.poItemId.integerValue==0){
                
                [self deleteSinglePOItemFromTable:vpurchaseOrderItem];
                 vpurchaseOrderItem=nil;
            }
            else{
                
                 [self deleteVendorPOItem:indexPath];
            }

        
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Are you sure want to delete this order details?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        
    }
}

-(void)deleteVendorPOItem:(NSIndexPath *)indPath{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:self.strPoID forKey:@"POId"];
    VPurchaseOrderItem *vPoItem = [self.poItemResultSetController objectAtIndexPath:indPath];
    strItemId=[NSString stringWithFormat:@"%@", vPoItem.poItemId];
    [itemparam setValue:strItemId forKey:@"POItemId"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self deleteVendorPOItemPoResponse:response error:error];
        });
    };
    
    self.deleteItemwebservice = [self.deleteItemwebservice initWithRequest:KURL actionName:WSM_DELETE_HACKNEY_PO_ITEM params:itemparam completionHandler:completionHandler];

}

- (void)deleteVendorPOItemPoResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [self deletePurchaseOrderItemfromTable];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    _poItemResultSetController=nil;
                    [self.tblPoItemList reloadData];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Purchase order item deleted successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Error occur while deleting Item details, Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(void)deletePurchaseOrderItemfromTable{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSArray *purchaseOrderItem = [self.updateManager getPurchaseOrderItem:privateContextObject withItemID:strItemId andPoID:self.strPoID];
    
    for (NSManagedObject *poitem in purchaseOrderItem)
    {
        [UpdateManager deleteFromContext:privateContextObject object:poitem];
    }
    [UpdateManager saveContext:privateContextObject];
    
    [self calculatetotalItemCost];
}

-(IBAction)btnInfoOkClicked:(id)sender{

    [self.viewItemInfo setHidden:YES];
}

-(IBAction)btnInfoClicked:(id)sender{
    
    [self calculatetotalItemCost];
    [self.viewItemInfo setHidden:NO];
}

- (void)calculatetotalItemCost {
    
    NSArray *arrayItems = [self fetchAllPurchaseOrderItems];
    _lblInfoNoofItem.text=[NSString stringWithFormat:@"%lu",(unsigned long)arrayItems.count];
    _lbltotalItem.text=[NSString stringWithFormat:@"%lu Items",(unsigned long)arrayItems.count];
    
    VPurchaseOrder *vpurchaseOrder = [self fetchPurchaseOrder:self.strPoID];
  
    NSDictionary *dictPO = vpurchaseOrder.vendorPoDictionary;
    
    NSString *strDate = [self getStringFormate:[dictPO valueForKey:@"CreatedDate"] fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"dd/MM/yyy"];
    _lblInfoOpened.text=strDate;
    
   NSString *strUpdateDate = [self getStringFormate:[dictPO valueForKey:@"UpdateDate"] fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"dd/MM/yyy"];
    _lblInfoModified.text=strUpdateDate;
    
    _totalCost=0.0;
    
    for(int i=0;i<arrayItems.count;i++){
        
        VPurchaseOrderItem *vmrItem = arrayItems[i];
        
        NSDictionary *purchaseOrderItem = vmrItem.vendorPoItemDictionary;
        
        NSDictionary *vendoritemDict = vmrItem.vitems.getVendorItemDictionary;
        
//        NSString *strUnitCost = [NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Unit_Cost"]];
//        
//        float caseCosttemp = [[vendoritemDict valueForKey:@"Unit_Cost"]floatValue]*[[vendoritemDict valueForKey:@"CaseUnits"]floatValue];
//        
//        float caseCost = caseCosttemp*[[purchaseOrderItem valueForKey:@"CasePOQty"]floatValue];
//        
//        NSString *strcaseCost = [NSString stringWithFormat:@"%.2f",caseCost];
//        
//    
//        
//        _totalCost = _totalCost +[strUnitCost floatValue]+[strcaseCost floatValue];
        
        NSString *strUnitCost = [NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Unit_Cost"]];
        
        float caseCosttemp = [[vendoritemDict valueForKey:@"Unit_Cost"]floatValue]*[[vendoritemDict valueForKey:@"CaseUnits"]floatValue];
        
        float totalUnitCost = [[purchaseOrderItem valueForKey:@"SinglePOQty"] integerValue]*strUnitCost.floatValue;
        
        float caseCost = caseCosttemp *[[purchaseOrderItem valueForKey:@"CasePOQty"]floatValue];
        
        NSString *strcaseCost = [NSString stringWithFormat:@"%.2f",caseCost];
        
        float totalCaseCost = [[purchaseOrderItem valueForKey:@"CasePOQty"] integerValue]*strcaseCost.floatValue;
        
        float totalPrice = totalUnitCost+totalCaseCost;
        
        _totalCost = _totalCost+totalPrice;
        
        NSNumber *totalCostnum = @(_totalCost);
    
        _lbltotalCost.text =[NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:totalCostnum]];
        
        _lblInfoTotalCost.text =[NSString stringWithFormat:@"%@",[self.rmsDbController.currencyFormatter stringFromNumber:totalCostnum]];
        
    }
}

- (VPurchaseOrder *)fetchPurchaseOrder :(NSString *)poid
{
    VPurchaseOrder *purchaseorder=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"VPurchaseOrder" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"poId==%d", poid.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        purchaseorder=resultSet.firstObject;
    }
    return purchaseorder;
}

- (NSString *)getStringFormateFromString:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    dateFormatter2.dateFormat = pstrToformate;
    NSString *result = [dateFormatter2 stringFromDate:dateFromString];
    
    return result;
}



-(NSString *)getStringFormate:(NSDate *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDate *dateFromString =pstrDate;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.txtSearchField && textField.text.length>0){
        
        [self searchVendorItemWithSearchString:self.txtSearchField.text];
        textField.text=@"";
    }
     [textField resignFirstResponder];
    return YES;
}

-(void)searchVendorItemWithSearchString:(NSString *)strSearch{
    
    Vendor_Item *vitem=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = kCFNumberFormatterNoStyle;
    NSNumber *upcnumber = [f numberFromString:strSearch];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemDescription contains[cd] %@ || cartonUpc == %@ || packUpc == %@", strSearch,upcnumber,upcnumber];
    fetchRequest.predicate = predicate;

    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count==0)
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
    
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"No Record Found" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    for(int i=0;i<resultSet.count;i++){
        
        vitem=resultSet[i];
        NSMutableDictionary *dictTempGlobal = [vitem.getVendorItemDictionary mutableCopy];
        [self.arrayReceiveItem insertObject:dictTempGlobal atIndex:0];
        
    }
    
    if (resultSet.count>0)
    {
        [self didSelectItems:self.arrayReceiveItem];
        [self.arrayReceiveItem removeAllObjects];
    }
}

- (BOOL)checkItemisAlreadyIntheList:(NSString *)strItemCode
{
    BOOL alreadyExit=NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"VPurchaseOrderItem" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"vpoId.poId = %d",self.strPoID.integerValue];
    
    fetchRequest.predicate = predicatePO;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    for(int i=0;i<resultSet.count;i++){
        
        NSIndexPath *indPath = [NSIndexPath indexPathForRow:i inSection:0];
        VPurchaseOrderItem *vItem = [self.poItemResultSetController objectAtIndexPath:indPath];
        NSDictionary *itemDictionary = vItem.vitems.getVendorItemDictionary;
        
        NSString *stritemCode =  [NSString stringWithFormat:@"%@",[itemDictionary valueForKey:@"SupplierItemCode"]];
        
        if([stritemCode isEqualToString:strItemCode]){
            
            alreadyExit=YES;
            break ;

        }
    }
    
    return alreadyExit;
}

-(NSArray *)removeAlreadyExitsItemFromArray:(NSArray *) selectedItems{
    
    NSMutableArray *arrayTemp = (NSMutableArray *)selectedItems;
    
    for(int i=0;i<arrayTemp.count;i++){
        
        NSMutableDictionary *dict = selectedItems[i];
        NSString *strItemCode = [NSString stringWithFormat:@"%@",[dict valueForKey:@"SupplierItemCode"]];
        BOOL checkisExits = [self checkItemisAlreadyIntheList:strItemCode];
        if(checkisExits)
        {
            [arrayTemp removeObjectAtIndex:i];
        }
    }
    return (NSArray *)arrayTemp;
}

-(void)didSelectItems:(NSArray *) selectedItems{
    
   // selectedItems = [self removeAlreadyExitsItemFromArray:selectedItems];
    
    for (int i = 0 ; i < selectedItems.count; i++)
    {
        vpurchaseOrderItem=nil;
        
        NSString *itemCode = [NSString stringWithFormat:@"%@",[selectedItems[i] valueForKey:@"SupplierItemCode"]];
        
        Vendor_Item *vItem = [self fetchVendorAllItems:itemCode];
        VPurchaseOrder *vpurchaseOrder = [self fetchPurchaseOrder:self.strPoID];
        
        NSMutableDictionary *dict =  [self createPricisingDictionary:vItem];
        
        if (selectedItems.count == 1)
        {
            NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            
            vpurchaseOrderItem =  [self.updateManager updatePurchaseOrderItemListwithDetailReturn:dict withVendorItem:(Vendor_Item *)OBJECT_COPY(vItem, privateContextObject) withpurchaseOrderItem:(VPurchaseOrderItem *)OBJECT_COPY(vpurchaseOrderItem, privateContextObject) withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(vpurchaseOrder, privateContextObject) withManageObjectContext:privateContextObject];
            
            vpurchaseOrderItem = (VPurchaseOrderItem *)OBJECT_COPY(vpurchaseOrderItem, self.managedObjectContext);
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HProductInfoVC *hitemProductinfo = [storyBoard instantiateViewControllerWithIdentifier:@"HProductInfoVC"];
            
            NSDictionary *vendoritemDict = vpurchaseOrderItem.vitems.getVendorItemDictionary;
            hitemProductinfo.isfromItem=YES;
            hitemProductinfo.isUpdate=YES;
            hitemProductinfo.strPoId=self.strPoID;
            hitemProductinfo.vpurchaseOrderItem = vpurchaseOrderItem;
            hitemProductinfo.dictProductInfo=[vendoritemDict mutableCopy];
            [self.navigationController pushViewController:hitemProductinfo animated:YES];
            
    
        }
        else
        {
            NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            [self.updateManager updatePurchaseOrderItemListwithDetail:dict withVendorItem:(Vendor_Item *)OBJECT_COPY(vItem, privateContextObject) withpurchaseOrderItem:nil withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(vpurchaseOrder, privateContextObject) withManageObjectContext:privateContextObject];
            
        }
    }
    _poItemResultSetController=nil;
    [self.tblPoItemList reloadData];
}


-(void)deleteSinglePOItemFromTable:(VPurchaseOrderItem *)vitem{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    [UpdateManager deleteFromContext:privateContextObject objectId:vitem.objectID];
    
    [UpdateManager saveContext:privateContextObject];
    
    _poItemResultSetController=nil;
    [self.tblPoItemList reloadData];
}

-(NSMutableDictionary *)createPricisingDictionary:(Vendor_Item *)vitem {
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"0" forKey:@"Id"];
    [dict setValue:self.strPoID forKey:@"POId"];
    [dict setValue:@"0" forKey:@"POItemId"];
    [dict setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [dict setValue:self.strItemId forKey:@"ItemCode"];
    [dict setValue:@"0" forKey:@"SinglePOQty"];
    [dict setValue:@"0" forKey:@"CasePOQty"];
    [dict setValue:@"0" forKey:@"PackPOQty"];
    [dict setValue:@"0" forKey:@"SingleReceivedQty"];
    [dict setValue:@"0" forKey:@"CaseReceivedQty"];
    [dict setValue:@"0" forKey:@"PackReceivedQty"];
    [dict setValue:@"0" forKey:@"IsReturn"];
    [dict setValue:@"0" forKey:@"OldQty"];
    [dict setValue:@"" forKey:@"Remarks"];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    dict[@"CreatedDate"] = strDateTime;
    
    return  dict;
}

- (Vendor_Item *)fetchVendorAllItems :(NSString *)itemId
{
    Vendor_Item *vitem=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vin==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        vitem=resultSet.firstObject;
    }
    return vitem;
}

-(IBAction)scanBarcodeClick:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    _hscanBarcode = [storyBoard instantiateViewControllerWithIdentifier:@"HScanBarcodeVC"];
    _hscanBarcode.itemLitVC=self;
    [self.navigationController pushViewController:_hscanBarcode animated:YES];

}

- (NSArray *)fetchAllPurchaseOrderItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"VPurchaseOrderItem" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"vpoId.poId = %d",self.strPoID.integerValue];
    fetchRequest.predicate = predicatePO;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    return resultSet;
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if(controller != _poItemResultSetController)
    {
        [self unlockResultController];
        return;
    }
    else if (_poItemResultSetController == nil){
        return;
    }

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblPoItemList beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _poItemResultSetController)
    {
        return;
    }
    else if (_poItemResultSetController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblPoItemList insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblPoItemList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblPoItemList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tblPoItemList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tblPoItemList insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != _poItemResultSetController)
    {
        return;
    }
    else if (_poItemResultSetController == nil){
        return;
    }

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblPoItemList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblPoItemList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _poItemResultSetController)
    {
        return;
    }
    else if (_poItemResultSetController == nil){
        return;
    }

    [self.tblPoItemList endUpdates];
    [self unlockResultController];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)poitemEntryLock {
    if (_poitemEntryLock == nil) {
        _poitemEntryLock = [[NSRecursiveLock alloc] init];
    }
    return _poitemEntryLock;
}

-(void)lockResultController
{
    [self.poitemEntryLock lock];
}

-(void)unlockResultController
{
    [self.poitemEntryLock unlock];
}
-(void)setPoItemResultSetController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.poitemEntryLock];
    _poItemResultSetController = resultController;
    [lock unlock];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)gotoPurchaseOrder:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
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
