//
//  HReceiveOrderItemListVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HReceiveOrderItemListVC.h"
#import "POReceiveOrderItemListCell.h"
#import "HReceiveOrderItemInfo.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Vendor_Item+Dictionary.h"
#import "VPurchaseOrder+Dictionary.h"
#import "VPurchaseOrderItem+Dictionary.h"
#import "HGenerateOrderVC.h"
#import "HItemCatalogVC.h"
#import "HScanBarcodeVC.h"
#import "HProductInfoVC.h"
#import "NDHTMLtoPDF.h"
#import "HItemProductVC.h"

@interface HReceiveOrderItemListVC () <UIDocumentInteractionControllerDelegate,NDHTMLtoPDFDelegate , EmailFromViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tblreceiveItemList;
@property (nonatomic, weak) IBOutlet UILabel *lblPoTitle;

@property (nonatomic, weak) EmailFromViewController *emailFromViewController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) HScanBarcodeVC *hscanBarcode;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) VPurchaseOrderItem *vpurchaseOrderItem;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection *closeWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *deleteItemwebservice;

@property (nonatomic, strong) NSString *strItemId;
@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) NSMutableArray *arrayReceiveItem;

@property (nonatomic, strong) NSIndexPath *deleteOrderIndPath;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) NSFetchedResultsController *receiveItemResultSetController;

@end

@implementation HReceiveOrderItemListVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize strPoid,arrayReceiveItem,vpurchaseOrderItem,updateManager,deleteOrderIndPath,strItemId,emaiItemHtml;

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
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.rimsController = [RimsController sharedrimController];
    
     self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
      self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.closeWebservice =[[RapidWebServiceConnection alloc]init];
    self.deleteItemwebservice=[[RapidWebServiceConnection alloc]init];
    
    NSString  *itemListCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        itemListCell = @"POReceiveOrderItemListCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:itemListCell bundle:nil];
    [self.tblreceiveItemList registerNib:mixGenerateirderNib forCellReuseIdentifier:@"POReceiveOrderItemListCell"];
    
    VPurchaseOrder *vpurchaseOrder = [self fetchPurchaseOrder:self.strPoid];
    _lblPoTitle.text=[NSString stringWithFormat:@"%@",vpurchaseOrder.orderName];
    
    self.arrayReceiveItem = [[NSMutableArray alloc]init];
    
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
#pragma mark - Fetch All Vendor Item

- (NSFetchedResultsController *)receiveItemResultSetController {
    
    if (_receiveItemResultSetController != nil) {
        return _receiveItemResultSetController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VPurchaseOrderItem" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"vpoId.poId = %d",self.strPoid.integerValue];
    
    fetchRequest.predicate = predicatePO;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    //
    
    // Create and initialize the fetch results controller.
    _receiveItemResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _receiveItemResultSetController.delegate = self;
    [_receiveItemResultSetController performFetch:nil];
    
    NSArray *sections = _receiveItemResultSetController.sections;
    if(sections.count==0)
    {
        return nil;
    }
    
    return _receiveItemResultSetController;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *sections = self.receiveItemResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100.0;
    
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
    NSString *cellIdentifier = @"POReceiveOrderItemListCell";
    
    POReceiveOrderItemListCell *receiveOrderitemCell = (POReceiveOrderItemListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    receiveOrderitemCell.selectionStyle=UITableViewCellSelectionStyleNone;
    receiveOrderitemCell.backgroundColor=[UIColor clearColor];

    receiveOrderitemCell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    VPurchaseOrderItem *vPoItem = [self.receiveItemResultSetController objectAtIndexPath:indexPath];

    NSDictionary *vendorreceiveitemDict = vPoItem.vendorPoItemDictionary;

    NSDictionary *vendoritemDict = vPoItem.vitems.getVendorItemDictionary;
    
    receiveOrderitemCell.lblItemName.text= [NSString stringWithFormat:@"%@", [vendoritemDict valueForKey:@"ItemDescriptions"]];
    receiveOrderitemCell.lblUpc.text=  [NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Carton_UPC"]];
    receiveOrderitemCell.lblcount.text=  [NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Size"]];
    
    NSInteger QtyOrder = [[vendorreceiveitemDict valueForKey:@"CasePOQty"] integerValue] + [[vendorreceiveitemDict valueForKey:@"SinglePOQty"] integerValue];
    
    NSInteger ReceivedOrder = [[vendorreceiveitemDict valueForKey:@"CaseReceivedQty"] integerValue] + [[vendorreceiveitemDict valueForKey:@"SingleReceivedQty"] integerValue];
    
    if(QtyOrder==ReceivedOrder){
        
        [receiveOrderitemCell.btnCheck setImage:[UIImage imageNamed:@"receive_order_check.png"] forState:UIControlStateNormal];
    }
    if(QtyOrder<ReceivedOrder){
        
        [receiveOrderitemCell.btnCheck  setImage:[UIImage imageNamed:@"check_blue_icon.png"] forState:UIControlStateNormal];
    }
    if(QtyOrder>ReceivedOrder){
        
        [receiveOrderitemCell.btnCheck  setImage:[UIImage imageNamed:@"receive_order_uncheck.png"] forState:UIControlStateNormal];
    }
    //[receiveOrderitemCell.btnCheck addTarget:self action:@selector(checkItem:) forControlEvents:UIControlEventTouchUpInside];
    receiveOrderitemCell.btnCheck.tag = indexPath.row;
    
    return receiveOrderitemCell;
    
}


-(void)checkItem:(id)sender{
    
    NSIndexPath *indpath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    POReceiveOrderItemListCell *receiveOrderitemCell = (POReceiveOrderItemListCell *)[_tblreceiveItemList cellForRowAtIndexPath:indpath];
    
    
    if(receiveOrderitemCell.btnCheck.selected)
    {
        receiveOrderitemCell.btnCheck.selected=NO;
    }
    else{
        receiveOrderitemCell.btnCheck.selected=YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HReceiveOrderItemInfo *orderInfo = [storyBoard instantiateViewControllerWithIdentifier:@"HReceiveOrderItemInfo"];
    
    VPurchaseOrderItem *vPoItem = [self.receiveItemResultSetController objectAtIndexPath:indexPath];
    NSDictionary *vendoritemDict = vPoItem.vitems.getVendorItemDictionary;
    
    NSInteger totalQty = vPoItem.singlePOQty.integerValue+ vPoItem.casePOQty.integerValue;
    
    [vendoritemDict setValue:[NSString stringWithFormat:@"%ld", (long)totalQty] forKey:@"OrderdQty"];
    [vendoritemDict setValue:@"0" forKey:@"FreeGoods"];

    orderInfo.strPOID=self.strPoid;
    orderInfo.vpurchaseOrderitem = vPoItem;
    orderInfo.strItemId=[NSString stringWithFormat:@"%@",vPoItem.poItemId];
    orderInfo.dictitemOrderInfo= [vendoritemDict mutableCopy];
    [self.navigationController pushViewController:orderInfo animated:YES];
}

-(IBAction)closePurchaseOrder:(id)sender{
    
    [self closePurchaseOrderCall];
}

-(void)closePurchaseOrderCall{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    NSMutableDictionary *poparam=[[NSMutableDictionary alloc]init];
    [poparam setValue:self.strPoid forKey:@"POId"];
    [poparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self closePurchaseOrderDetailResponse:response error:error];
        });
    };
    
    self.closeWebservice = [self.closeWebservice initWithRequest:KURL actionName:WSM_CLOSE_HACKNEY_PO params:poparam completionHandler:completionHandler];
    
}

- (void)closePurchaseOrderDetailResponse:(id)response error:(NSError *)error
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
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Purchase order closed successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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

-(IBAction)browseOrAddItem:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HItemProductVC *hproduct = [storyBoard instantiateViewControllerWithIdentifier:@"HItemProductVC"];
    hproduct.isfromItem=YES;
    hproduct.strPoId=self.strPoid;
    [self.navigationController pushViewController:hproduct animated:YES];
    
}

-(IBAction)scanBarcodeClick:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    _hscanBarcode = [storyBoard instantiateViewControllerWithIdentifier:@"HScanBarcodeVC"];
    _hscanBarcode.itemReceiveListVC=self;
    [self.navigationController pushViewController:_hscanBarcode animated:YES];
    
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemDescription contains[cd] %@ || cartonUpc == %@", strSearch,upcnumber];
    fetchRequest.predicate = predicate;
    
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count==0)
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"No Record Found" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
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

-(NSMutableDictionary *)createPricisingDictionary:(Vendor_Item *)vitem {
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"0" forKey:@"Id"];
    [dict setValue:self.strPoid forKey:@"POId"];
    [dict setValue:@"0" forKey:@"POItemId"];
    [dict setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [dict setValue:vitem.vendor_Item_Id forKey:@"ItemCode"];
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

-(void)didSelectItems:(NSArray *) selectedItems{
    
   // selectedItems = [self removeAlreadyExitsItemFromArray:selectedItems];
    
    for (int i = 0 ; i < selectedItems.count; i++)
    {
        vpurchaseOrderItem=nil;
        
        NSString *itemCode = [NSString stringWithFormat:@"%@",[selectedItems[i] valueForKey:@"SupplierItemCode"]];
        
        Vendor_Item *vItem = [self fetchVendorAllItems:itemCode];
        VPurchaseOrder *vpurchaseOrder = [self fetchPurchaseOrder:self.strPoid];
        
        NSMutableDictionary *dict =  [self createPricisingDictionary:vItem];
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        [self.updateManager updatePurchaseOrderItemListwithDetail:dict withVendorItem:(Vendor_Item *)(VPurchaseOrder *)OBJECT_COPY(vItem, privateContextObject) withpurchaseOrderItem:nil withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(vpurchaseOrder, privateContextObject) withManageObjectContext:privateContextObject];
        
    }
    
    _receiveItemResultSetController=nil;
    [self.tblreceiveItemList reloadData];
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


- (NSArray *)fetchAllPurchaseOrderItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"VPurchaseOrderItem" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"vpoId.poId = %d",self.strPoid.integerValue];
    fetchRequest.predicate = predicatePO;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    return resultSet;
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
            
            vpurchaseOrderItem = [self.receiveItemResultSetController objectAtIndexPath:deleteOrderIndPath];
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

-(void)deleteSinglePOItemFromTable:(VPurchaseOrderItem *)vitem{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    [UpdateManager deleteFromContext:privateContextObject objectId:vitem.objectID];
    [UpdateManager saveContext:privateContextObject];
    _receiveItemResultSetController=nil;
    [self.tblreceiveItemList reloadData];
}
-(void)deleteVendorPOItem:(NSIndexPath *)indPath{
    
     _activityIndicator =  [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:self.strPoid forKey:@"POId"];
    VPurchaseOrderItem *vPoItem = [self.receiveItemResultSetController objectAtIndexPath:indPath];
    strItemId=[NSString stringWithFormat:@"%@", vPoItem.poItemId];
    [itemparam setValue:strItemId forKey:@"POItemId"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self deleteReceivePOItemPoResponse:response error:error];
        });
    };
    
    self.deleteItemwebservice = [self.deleteItemwebservice initWithRequest:KURL actionName:WSM_DELETE_HACKNEY_PO_ITEM params:itemparam completionHandler:completionHandler];
    
}

- (void)deleteReceivePOItemPoResponse:(id)response error:(NSError *)error
{
   [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [self deletePurchaseOrderItemfromTable];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    _receiveItemResultSetController=nil;
                    [self.tblreceiveItemList reloadData];
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
    NSArray *purchaseOrderItem = [self.updateManager getPurchaseOrderItem:privateContextObject withItemID:strItemId andPoID:self.strPoid];
    
    for (NSManagedObject *poitem in purchaseOrderItem)
    {
        [UpdateManager deleteFromContext:privateContextObject object:poitem];
    }
    [UpdateManager saveContext:privateContextObject];
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _receiveItemResultSetController)
    {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblreceiveItemList beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(controller != _receiveItemResultSetController)
    {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblreceiveItemList insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblreceiveItemList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tblreceiveItemList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tblreceiveItemList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tblreceiveItemList insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(controller != _receiveItemResultSetController)
    {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblreceiveItemList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblreceiveItemList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if(controller != _receiveItemResultSetController)
    {
        return;
    }
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tblreceiveItemList endUpdates];
}


-(IBAction)shareOrderClicked:(id)sender
{
    UIButton *button;
    button = sender;
    
    UIAlertController *popup = [UIAlertController alertControllerWithTitle:@"Export" message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *print = [UIAlertAction actionWithTitle:@"Print" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                [popup dismissViewControllerAnimated:YES completion:nil];
                                [self printPreviewBeforePrint];
                            }];
    
    UIAlertAction *email = [UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                [popup dismissViewControllerAnimated:YES completion:nil];
                                [self createHTMLViewandLaunchSendEmailVC];
                            }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [popup dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [popup addAction:print];
    [popup addAction:email];
    [popup addAction:cancel];
    
    UIPopoverPresentationController *popPresenter = popup.popoverPresentationController;
    popPresenter.sourceView = button;
    popPresenter.sourceRect = button.bounds;
    [self presentViewController:popup animated:YES completion:nil];
}

-(NSString *)htmlBillHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"Vendor List"]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]
                                                                                     ]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    //    NSString  *Datetime = [NSString stringWithFormat:@"%@",[[arrayInvoice firstObject] valueForKey:@"CreatedDate"]];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString  *currentDateTime = [formatter stringFromDate:date];
    NSString *strTime = [self getStringFormate:currentDateTime fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"hh:mm a"];
    NSString *strDate = [self getStringFormate:currentDateTime fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"MMM dd, yyyy"];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"%@",strDate]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    
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
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"left\" valign=\"top\"style=\"width:50%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"AddedQty"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"avaibleQty"]];
    return htmldata;
}

-(void)writeDataOnCacheDirectory :(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.emaiItemHtml])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.emaiItemHtml error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.emaiItemHtml = [documentsDirectory stringByAppendingPathComponent:@"ReconcileItemList.html"];
    [data writeToFile:self.emaiItemHtml atomically:YES];
}

#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl
{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    // present the preview
    [self.controller presentPreviewAnimated:YES];
}

- (UIDocumentInteractionController *)controller {
    
    if (!self.documentController)
    {
        self.documentController = [[UIDocumentInteractionController alloc]init];
        self.documentController.delegate = self;
    }
    return self.documentController;
}


#pragma mark - Share Inventory CountList methods - Himanshu

- (void)createHTMLViewandLaunchSendEmailVC
{
    NSMutableArray *arryInvoice = [[NSMutableArray alloc] init];
    //    NSArray *fetchedData = [self.itemInventoryCountResultController fetchedObjects];
    //    [arryInvoice addObjectsFromArray:fetchedData];
    NSMutableArray *inventoryMain = [[NSMutableArray alloc] init];
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ReconcileItemList" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:inventoryMain];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    _emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController_iPhone"];
    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    NSString *strsubjectLine = @"";
    _emailFromViewController.emailFromViewControllerDelegate = self;

    _emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
    (_emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (_emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
    (_emailFromViewController.dictParameter)[@"postfile"] = myData;
    (_emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (_emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
    [self.view addSubview:_emailFromViewController.view];
}

-(void)didCancelEmail
{
    [_emailFromViewController.view removeFromSuperview];
}


- (void)printPreviewBeforePrint
{
    NSMutableArray *arryInvoice = [[NSMutableArray alloc] init];
    NSMutableArray *inventoryMain = [[NSMutableArray alloc] init];
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"ReconcileItemList" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
  
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:inventoryMain];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:arryInvoice];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    CGSize paperSize = CGSizeMake(320, 841.8);
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/Reconclie Item List.pdf".stringByExpandingTildeInPath delegate:self pageSize:paperSize margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}


#pragma mark - Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
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
-(IBAction)gotoReceiveOrder:(id)sender{
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
