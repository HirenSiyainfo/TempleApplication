//
//  HItemProductVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HItemProductVC.h"
#import "HItemProductCell.h"
#import "HProductInfoVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Vendor_Item+Dictionary.h"
#import "HPOItemListVC.h"
#import "VPurchaseOrderItem+Dictionary.h"
#import "HDepartmentSelectionVC.h"
#import "HScanBarcodeVC.h"
#import "HOpenOrderVC.h"

@interface HItemProductVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblItemProduct;

@property (nonatomic, weak) IBOutlet UIButton *btnProandNew;
@property (nonatomic, weak) IBOutlet UIButton *btnPo;

@property (nonatomic, weak) IBOutlet UITextField *txtSearchField;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) VPurchaseOrder *vpurchaseOrder;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) VPurchaseOrderItem *vpurchaseOrderItem;

@property (nonatomic, strong) RapidWebServiceConnection *poItemAddWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *poList ;

@property (nonatomic, assign) BOOL boolisNew;

@property (nonatomic, strong) NSDictionary *dictProductInfo;

@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSString *strSingle;
@property (nonatomic, strong) NSString *strCase;

@property (nonatomic, strong) NSIndexPath *swipedIndexpath;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *vendorItemResultSetController;

@end

@implementation HItemProductVC
@synthesize swipedIndexpath;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize strCatelog,strCategory,isfromItem,strPoId,vpurchaseOrderItem,strUPC;
@synthesize indpathCatalog,indpathCategory,boolisNew,isFromNewRelease;


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
    NSString *strPO = [[NSUserDefaults standardUserDefaults]valueForKey:@"PoId"];
    self.strPoId=strPO;
    NSString *strIsNew = [[NSUserDefaults standardUserDefaults]valueForKey:@"New"];
    if([strIsNew isEqualToString:@"Y"]){
        self.boolisNew=YES;
    }
    else{
        self.boolisNew=NO;
    }
     _vpurchaseOrder = [self fetchPurchaseOrder:self.strPoId];
    [self changeNewRelaseButtonStatues];
    _vendorItemResultSetController=nil;
    [self.tblItemProduct reloadData];
}

-(void)changeNewRelaseButtonStatues{
    
    if(self.boolisNew){
        
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : ON" forState:UIControlStateNormal];
        self.btnProandNew.selected=YES;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
    }
    else{
        self.btnProandNew.selected=NO;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : OFF" forState:UIControlStateNormal];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.swipedIndexpath= [NSIndexPath indexPathForRow:-1 inSection:0];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    //self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.poItemAddWebservice =[[RapidWebServiceConnection alloc]init];
    self.poList =[[RapidWebServiceConnection alloc]init];
    
    self.btnProandNew.layer.cornerRadius=self.btnProandNew.frame.size.height/2;
    self.btnProandNew.layer.masksToBounds=YES;
    self.btnProandNew.layer.borderColor=[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0].CGColor ;
    self.btnProandNew.layer.borderWidth= 1.0f;
    
    NSString  *catalogCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        catalogCell = @"HItemProductCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:catalogCell bundle:nil];
    [self.tblItemProduct registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HItemProductCell"];
    
     if(self.isfromItem){
         self.btnPo.hidden=YES;
         //self.btnProandNew.hidden=NO;
     }
     else{
         self.btnPo.hidden=NO;
         //self.btnProandNew.hidden=YES;
     }
    if(self.isFromNewRelease){
        
        self.btnProandNew.hidden = YES;
        self.btnPo.frame=CGRectMake((self.view.frame.size.width/2 - self.btnPo.frame.size.width/2), self.btnPo.frame.origin.y, self.btnPo.frame.size.width, self.btnPo.frame.size.height);
        }
    else{
        self.btnProandNew.hidden = NO;
    }
    self.indpathCatalog = [NSIndexPath indexPathForRow:-1 inSection:-1];
    self.indpathCategory = [NSIndexPath indexPathForRow:-1 inSection:-1];
   
}

-(IBAction)promotionItems:(id)sender{
    
    if(self.btnProandNew.selected){
        self.btnProandNew.selected=NO;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        boolisNew=NO;
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : OFF" forState:UIControlStateNormal];
        _vendorItemResultSetController=nil;
        [self.tblItemProduct reloadData];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"N" forKey:@"New"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
    }
    else{
        self.btnProandNew.selected=YES;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
        boolisNew=YES;
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : ON" forState:UIControlStateNormal];
        _vendorItemResultSetController=nil;
        [self.tblItemProduct reloadData];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"Y" forKey:@"New"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}


#pragma mark - Fetch All Vendor Item

- (NSFetchedResultsController *)vendorItemResultSetController {
    
    if (_vendorItemResultSetController != nil) {
        return _vendorItemResultSetController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryDesc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSPredicate *predicate;
    
    if(boolisNew)
    {
        predicate = [NSPredicate predicateWithFormat:@"isNew = %@ && effectiveDate >= %@", @(1),[NSDate date]];
        
    }
    else{
       // predicate = [NSPredicate predicateWithFormat:@"isNew = %@",@(0)];
    }
    
    NSPredicate *predicate2 = [self getPredicate];
    
    if(predicate2!=nil && predicate!=nil){
        NSPredicate *newpredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate, predicate2]];
        fetchRequest.predicate = newpredicate;
    }
    else if(predicate2!=nil){
        
        fetchRequest.predicate = predicate2;
    }
    else if(predicate!=nil){
        
        fetchRequest.predicate = predicate;
    }
    
    _vendorItemResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_vendorItemResultSetController performFetch:nil];
    _vendorItemResultSetController.delegate = self;
    
     NSArray *sections = self.vendorItemResultSetController.sections;
    if(sections.count==0)
    {
        return nil;
    }
    return _vendorItemResultSetController;
}

-(NSPredicate *)getPredicate{
    
    NSPredicate *predicate;
    
    if(self.searchText.length>0)
    {
        if(self.strCatelog!=nil){
            
            if(self.strCategory==nil){
                
                predicate = [NSPredicate predicateWithFormat:@"categoryDescription = %@ AND itemDescription contains[cd] %@",self.strCatelog,self.searchText];
            }
            else{
              
                  predicate = [NSPredicate predicateWithFormat:@"categoryDescription = %@ AND categoryDesc = %@ AND itemDescription contains[cd] %@",self.strCatelog,self.strCategory,self.searchText];
            }
        }
        else{
            predicate = [NSPredicate predicateWithFormat:@"itemDescription contains[cd] %@ || cartonUpc == %@ || packUpc == %@",self.searchText,self.searchText,self.searchText];
        }
    }
    else if(self.strCatelog!=nil){
        
            if(self.strCategory==nil){
                
                predicate = [NSPredicate predicateWithFormat:@"categoryDescription = %@",self.strCatelog];
            }
            else{
                predicate = [NSPredicate predicateWithFormat:@"categoryDescription = %@ AND categoryDesc = %@",self.strCatelog,self.strCategory];
            }
    }
    else if(self.strUPC!=nil){
        
        predicate = [NSPredicate predicateWithFormat:@"cartonUpc = %@",self.strUPC];
        
    }
    return predicate;
}

-(IBAction)openFilterCatalog:(id)sender{
    

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.vendorItemResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    NSInteger count = sectionInfo.numberOfObjects;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 90.0;
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
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.tblItemProduct)
    {
        return [self.vendorItemResultSetController sectionForSectionIndexTitle:title atIndex:index];
    }
    else
    {
        return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"HItemProductCell";
    
    HItemProductCell *productCell = (HItemProductCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    productCell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    Vendor_Item *vitem = [self.vendorItemResultSetController objectAtIndexPath:indexPath];
    NSMutableDictionary *vendoritemDict = [vitem.getVendorItemDictionary mutableCopy];
    
    if([[vendoritemDict valueForKey:@"IsNew"]integerValue]==1){
        
        if([self checkEffectiveDate:[vendoritemDict valueForKey:@"Effective_Date"]]){
            
              productCell.lblEffectiveDate.text = [NSString stringWithFormat:@"Released %@",[self getEffectiveDate:[vendoritemDict valueForKey:@"Effective_Date"]]];
        }

    }
    else{
        
        productCell.lblEffectiveDate.text=@"";
    }
    
    productCell.lblProductName.text=[NSString stringWithFormat:@"%@", [vendoritemDict valueForKey:@"ItemDescriptions"]];
    productCell.lblProducts.text=[NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Pack_UPC"]];

    productCell.lblPrice1.text = [self.rmsDbController applyCurrencyFomatter:[vendoritemDict valueForKey:@"Unit_Cost"]];
    
    float caseCost = [[vendoritemDict valueForKey:@"Unit_Cost"]floatValue]*[[vendoritemDict valueForKey:@"CaseUnits"]floatValue];
    
    NSString *strcaseCost = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",caseCost]];
    
    productCell.lblPrice2.text=strcaseCost;

    productCell.lblCashQty.text=@"0";
    productCell.lblUnitQty.text=@"0";
   
    productCell.lblProducts.text=[NSString stringWithFormat:@"%@ Available",[vendoritemDict valueForKey:@"CaseUnits"]];
    
    [productCell.btnCashQtyMinus addTarget:self action:@selector(lblCashQtyminus:) forControlEvents:UIControlEventTouchUpInside];
    productCell.btnCashQtyMinus.tag = indexPath.row;
    
    [productCell.btnCashQtyPlus addTarget:self action:@selector(lblCashQtyAdd:) forControlEvents:UIControlEventTouchUpInside];
    productCell.btnCashQtyPlus.tag = indexPath.row;
    
    [productCell.btnUnitQtyPlus addTarget:self action:@selector(lblUnitQtyAdd:) forControlEvents:UIControlEventTouchUpInside];
    productCell.btnUnitQtyPlus.tag = indexPath.row;
    
    [productCell.btnUnitQtyMinus addTarget:self action:@selector(lblUnitQtyminus:) forControlEvents:UIControlEventTouchUpInside];
    productCell.btnUnitQtyMinus.tag = indexPath.row;
    
    [productCell.btnAddItem addTarget:self action:@selector(btnAddOrderItem:) forControlEvents:UIControlEventTouchUpInside];
    productCell.btnAddItem.tag = indexPath.row;

    if(self.swipedIndexpath.row==indexPath.row){
        
        productCell.viewAddQty.hidden=NO;
        productCell.viewAddQty.frame=CGRectMake(0, productCell.viewAddQty.frame.origin.y, productCell.viewAddQty.frame.size.width, productCell.viewAddQty.frame.size.height);
        
    }
    else{
        productCell.viewAddQty.hidden=YES;
         productCell.viewAddQty.frame=CGRectMake(320.0, productCell.viewAddQty.frame.origin.y, productCell.viewAddQty.frame.size.width, productCell.viewAddQty.frame.size.height);
    }
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    // Adding the swipe gesture on image view
    [productCell addGestureRecognizer:swipeLeft];
    [productCell addGestureRecognizer:swipeRight];
    
    return productCell;
}
-(BOOL)checkEffectiveDate:(NSDate *)pDate{
    
    BOOL isNew = NO;

    NSDate *today = [NSDate date]; // it will give you current date
    
    NSComparisonResult result;
    result = [today compare:pDate]; // comparing two dates
    
    if(result == NSOrderedAscending)
        isNew = YES;
    else if(result == NSOrderedDescending)
        
        isNew = NO;
    else
        isNew = NO;
    
    return isNew;
}

-(NSString *)getEffectiveDate:(NSDate *)pDate{
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"IST"];
    dateFormatter2.timeZone = gmt;
    dateFormatter2.dateFormat = @"dd/MM/yyyy";
    NSString *streffectiveDate = [dateFormatter2 stringFromDate:pDate];
    
    return streffectiveDate;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
//    if(isfromItem)
//    {
        CGPoint location = [swipe locationInView:self.tblItemProduct];
        
        NSIndexPath *indpath = [self.tblItemProduct indexPathForRowAtPoint:location];
        
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
            if(indpath.row==self.swipedIndexpath.row){
                self.swipedIndexpath= [NSIndexPath indexPathForRow:-1 inSection:0];
            }
        }
        
        if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {

            self.swipedIndexpath=indpath;
        }
        [self.tblItemProduct reloadData];
   // }
}

-(void)btnAddOrderItem:(id)sender{
    
    if(self.strPoId.length>0 && _vpurchaseOrder!=nil){
        
        HItemProductCell *productCell = (HItemProductCell *)[self.tblItemProduct cellForRowAtIndexPath:swipedIndexpath];
    
        Vendor_Item *vPoItem = [self.vendorItemResultSetController objectAtIndexPath:self.swipedIndexpath];
        
        _dictProductInfo = vPoItem.getVendorItemDictionary;
        
        _strSingle =productCell.lblUnitQty.text;
        _strCase =productCell.lblCashQty.text;
        
        [self callWebServiceForPurchaseOrderAddItem];
        
    }
    else{
        
        [self ListofPO];
    }
}

- (void)ListofPO
{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchID"];
    param[@"Status"] = @"1";
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
            [self poListResponse:response error:error];
        });
    };
    
    self.poList = [self.poList initWithRequest:KURL actionName:WSM_LIST_HACKNEY_PO params:param completionHandler:completionHandler];
    
}

- (void)poListResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *arrPOList = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(arrPOList.count>0){
                    
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                    HOpenOrderVC *hOpenOrder = [storyBoard instantiateViewControllerWithIdentifier:@"HOpenOrderVC"];
                    hOpenOrder.isselection=YES;
                    [self.navigationController pushViewController:hOpenOrder animated:YES];
                }
                else{
                    
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"NO PO Generated." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
            }
            else{
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


- (void)callWebServiceForPurchaseOrderAddItem
{

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    
    [param setValue:@"0" forKey:@"Id"];
    [param setValue:self.strPoId forKey:@"POId"];
    [param setValue:@"0" forKey:@"POItemId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:[_dictProductInfo valueForKey:@"SupplierItemCode"] forKey:@"ItemCode"];
    [param setValue:_strSingle forKey:@"SinglePOQty"];
    [param setValue:_strCase forKey:@"CasePOQty"];
    [param setValue:@"0" forKey:@"PackPOQty"];
    [param setValue:@"0" forKey:@"SingleReceivedQty"];
    [param setValue:@"0" forKey:@"CaseReceivedQty"];
    [param setValue:@"0" forKey:@"PackReceivedQty"];
    [param setValue:@"0" forKey:@"IsReturn"];
    [param setValue:@"0" forKey:@"OldQty"];
    [param setValue:@"" forKey:@"Remarks"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    param[@"CreatedDate"] = strDateTime;
    
    
    NSMutableDictionary *poparam = [[NSMutableDictionary alloc] init ];
    [poparam setValue:param forKey:@"ItemData"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), 	dispatch_get_main_queue(), ^{
              [self purchaseOrderItemAddResponse:response error:error];
               });
    };
    
    self.poItemAddWebservice = [self.poItemAddWebservice initWithRequest:KURL actionName:WSM_ADD_HACKNEY_PO_ITEM params:poparam completionHandler:completionHandler];
    
}

- (void)purchaseOrderItemAddResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                
                NSString *strItemID = response[@"Data"];
                [self insertVendorPOItemWithDictionary:strItemID];
        
                
            }
        }
    }
}
-(void)insertVendorPOItemWithDictionary:(NSString *)strItemID{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"0" forKey:@"Id"];
    [dict setValue:self.strPoId forKey:@"POId"];
    [dict setValue:strItemID forKey:@"POItemId"];
    [dict setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [dict setValue:[self.dictProductInfo valueForKey:@"SupplierItemCode"] forKey:@"ItemCode"];
    [dict setValue:_strSingle forKey:@"SinglePOQty"];
    [dict setValue:_strCase forKey:@"CasePOQty"];
    [dict setValue:@"0" forKey:@"PackPOQty"];
    [dict setValue:@"0" forKey:@"SingleReceivedQty"];
    [dict setValue:@"0" forKey:@"CaseReceivedQty"];
    [dict setValue:@"0" forKey:@"PackReceivedQty"];
    [dict setValue:@"0" forKey:@"IsReturn"];
    [dict setValue:@"0" forKey:@"OldQty"];
    [dict setValue:@"" forKey:@"Remarks"];
    
    
    Vendor_Item *vanItem = [self fetchVendorItem:[[self.dictProductInfo valueForKey:@"SupplierItemCode"]integerValue]];
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    [self.updateManager updatePurchaseOrderItemListwithDetail:dict withVendorItem:(Vendor_Item *)OBJECT_COPY(vanItem, privateContextObject) withpurchaseOrderItem:(VPurchaseOrderItem *)OBJECT_COPY(vpurchaseOrderItem, privateContextObject) withPurchaseOrder:(VPurchaseOrder *)OBJECT_COPY(_vpurchaseOrder, privateContextObject) withManageObjectContext:privateContextObject];
    
    vpurchaseOrderItem = (VPurchaseOrderItem *)OBJECT_COPY(vpurchaseOrderItem, self.managedObjectContext);
    _vpurchaseOrder = (VPurchaseOrder *)OBJECT_COPY(_vpurchaseOrder, self.managedObjectContext);
    if(self.isfromItem){
        
        NSArray *arrayView = self.navigationController.viewControllers;
        for(UIViewController *viewcon in arrayView){
            if([viewcon isKindOfClass:[HPOItemListVC class]]){
                [self.navigationController popToViewController:viewcon animated:YES];
                
            }
        }
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Item added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        
        self.swipedIndexpath= [NSIndexPath indexPathForRow:-1 inSection:0];
        [self.tblItemProduct reloadData];

    }
}
- (Vendor_Item *)fetchVendorItem :(NSInteger)itemId
{
    Vendor_Item *vitem=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vin==%d", itemId];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        vitem=resultSet.firstObject;
    }
    return vitem;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.swipedIndexpath.row != indexPath.row)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        HProductInfoVC *hitemProductinfo = [storyBoard instantiateViewControllerWithIdentifier:@"HProductInfoVC"];
        
        Vendor_Item *vitem = [self.vendorItemResultSetController objectAtIndexPath:indexPath];
        NSMutableDictionary *vendoritemDict = [vitem.getVendorItemDictionary mutableCopy];
        hitemProductinfo.isfromItem=self.isfromItem;
        hitemProductinfo.strPoId=self.strPoId;
        hitemProductinfo.dictProductInfo=[vendoritemDict mutableCopy];
        [self.navigationController pushViewController:hitemProductinfo animated:YES];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField == self.txtSearchField)
    {
        self.searchText=self.txtSearchField.text;
        [self searchItemwithPredicate:self.searchText];
    }
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.text.length == 1 && [string isEqualToString:@""]) {
        self.searchText = @"";
    }
    else{
        self.searchText = searchString;
    }
    
    [self searchItemwithPredicate:self.searchText];
    
    return YES;
}


-(void)searchItemwithPredicate:(NSString *)searchString{
    
    if(self.txtSearchField.text.length > 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            _vendorItemResultSetController = nil;
            [self.tblItemProduct reloadData];
        });
    }
    else{
        _vendorItemResultSetController = nil;
        [self.tblItemProduct reloadData];
    }
}


-(void)lblCashQtyAdd:(id)sender{
    
    NSIndexPath *indPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    HItemProductCell *productCell= (HItemProductCell *)[self.tblItemProduct cellForRowAtIndexPath:indPath];

    UILabel *lblCase = (UILabel *)[productCell viewWithTag:500];
    lblCase.text=[NSString stringWithFormat:@"%ld",(long)lblCase.text.integerValue+1];
}

-(void)lblCashQtyminus:(id)sender{
    
    NSIndexPath *indPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    HItemProductCell *productCell= (HItemProductCell *)[self.tblItemProduct cellForRowAtIndexPath:indPath];
    
    UILabel *lblCase = (UILabel *)[productCell viewWithTag:500];
    lblCase.text=[NSString stringWithFormat:@"%ld", (long)lblCase.text.integerValue-1];
}

-(void)lblUnitQtyAdd:(id)sender{
    
    NSIndexPath *indPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    HItemProductCell *productCell= (HItemProductCell *)[self.tblItemProduct cellForRowAtIndexPath:indPath];
    
    UILabel *lblUnit = (UILabel *)[productCell viewWithTag:600];
    lblUnit.text=[NSString stringWithFormat:@"%ld", (long)lblUnit.text.integerValue+1];
    
}

-(void)lblUnitQtyminus:(id)sender{
    
    NSIndexPath *indPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    HItemProductCell *productCell= (HItemProductCell *)[self.tblItemProduct cellForRowAtIndexPath:indPath];
    
    UILabel *lblUnit = (UILabel *)[productCell viewWithTag:600];
    lblUnit.text=[NSString stringWithFormat:@"%ld",(long)lblUnit.text.integerValue-1];
}

-(IBAction)gotoCatalog:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didselectinoDeparment:(NSString *)strDept withIndexpath:(NSIndexPath *)indpath{
    
    self.strCatelog=strDept;
    self.strCategory=nil;
    self.indpathCatalog=indpath;
    self.indpathCategory=[NSIndexPath indexPathForRow:-1 inSection:-1];
    _vendorItemResultSetController=nil;
    [self.tblItemProduct reloadData];
    
}
-(IBAction)exitfromDepartment:(UIStoryboardSegue *)sender{
    
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(IBAction)openPOList:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HOpenOrderVC *hOpenOrder = [storyBoard instantiateViewControllerWithIdentifier:@"HOpenOrderVC"];
    hOpenOrder.isselection=YES;
    [self.navigationController pushViewController:hOpenOrder animated:YES];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"HDepartmentSelectionVC"]){
        HDepartmentSelectionVC *destVC = segue.destinationViewController;
        destVC.indCategory =self.indpathCategory;
        destVC.indcatalog =self.indpathCatalog;
        destVC.isFromNewRelease=self.isFromNewRelease;
        destVC.departmentSelectionDelegate = self;
    }
    if([segue.identifier isEqualToString:@"ProductToBarcodeScan"]){
        HScanBarcodeVC *destVC = segue.destinationViewController;
        destVC.itemProductVC = self;
        self.strCatelog=nil;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
