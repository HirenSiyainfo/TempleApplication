//
//  HScanBarcodeVC.m
//  RapidRMS
//
//  Created by Siya on 17/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HScanBarcodeVC.h"
#import "RmsDbController.h"
#import "Vendor_Item+Dictionary.h"
#import "RimsController.h"
#import "HItemProductCell.h"
#import "HOpenOrderVC.h"
#import "HProductInfoVC.h"

@interface HScanBarcodeVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblItemProduct;
@property (nonatomic, weak) IBOutlet UIView *viewPreview;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) VPurchaseOrder *vpurchaseOrder;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) VPurchaseOrderItem *vpurchaseOrderItem;

@property (nonatomic, strong) RapidWebServiceConnection *poItemAddWebservice;
@property (nonatomic, strong) RapidWebServiceConnection *poList;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) NSDictionary *dictProductInfo;

@property (nonatomic, strong) NSMutableArray *vendorItemArray;

@property (nonatomic, strong) NSString *strSingle;
@property (nonatomic, strong) NSString *strCase;
@property (nonatomic, strong) NSString *strBarcode;
@property (nonatomic, strong) NSString *strPoId;

@property (nonatomic, strong) NSIndexPath *swipedIndexpath;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HScanBarcodeVC
@synthesize swipedIndexpath,strPoId;
@synthesize itemLitVC,itemReceiveListVC,itemProductVC,vpurchaseOrderItem;
@synthesize managedObjectContext = __managedObjectContext;


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *strPO = [[NSUserDefaults standardUserDefaults]valueForKey:@"PoId"];
    self.strPoId=strPO;
     _vpurchaseOrder = [self fetchPurchaseOrder:self.strPoId];
    [self startReading];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.vendorItemArray = [[NSMutableArray alloc]init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
  
    self.swipedIndexpath= [NSIndexPath indexPathForRow:-1 inSection:0];
    self.tblItemProduct.backgroundColor = [UIColor whiteColor];
    self.tblItemProduct.layer.opacity = 0.50;
    self.tblItemProduct.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.poItemAddWebservice =[[RapidWebServiceConnection alloc]init];
    self.poList =[[RapidWebServiceConnection alloc]init];
    
    NSString  *catalogCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        catalogCell = @"HItemProductCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:catalogCell bundle:nil];
    [self.tblItemProduct registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HItemProductCell"];

   
       // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", error.localizedDescription);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _videoPreviewLayer.frame = _viewPreview.layer.bounds;
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && metadataObjects.count > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects.firstObject;
        //if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
            
            //            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            //            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
        
        if (metadataObj.stringValue != nil) {
                //[self stopReading];
                NSArray *arrMetaData = [metadataObj.stringValue componentsSeparatedByString:@";"];
                _strBarcode = arrMetaData.firstObject;
                //_strQRCode = [arrMetaData objectAtIndex:1];
                
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                    if([self checkBarcodeExists:_strBarcode])
                    {
                             if(self.itemLitVC)
                             {
                                // [self.itemLitVC searchVendorItemWithSearchString:_strBarcode];
                                 [self.tblItemProduct reloadData];

                             }
                             else if(self.itemReceiveListVC){
                                   [self.navigationController popViewControllerAnimated:NO];
                                 [self.itemReceiveListVC searchVendorItemWithSearchString:_strBarcode];
                             }
                             else{
                                 
                                 self.itemProductVC.strUPC=_strBarcode;
                                 [self.navigationController popViewControllerAnimated:YES];
                             }
                             
                   
                        }
                    });
                
                }
                else
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [self.navigationController popViewControllerAnimated:NO];
                    });
                    
                }
           // }
        }
}

-(BOOL)checkBarcodeExists:(NSString *)strSearch{
    
    BOOL isexits=NO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = kCFNumberFormatterNoStyle;
    NSNumber *upcnumber = [f numberFromString:strSearch];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cartonUpc == %@ || packUpc == %@",upcnumber,upcnumber];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];

    if(resultSet.count>0)
    {
        isexits=YES;
        [self.vendorItemArray removeAllObjects];
        Vendor_Item *vItem = resultSet.firstObject;
        NSDictionary *dict = [vItem.getVendorItemDictionary mutableCopy];
        [self.vendorItemArray addObject:dict];
    }
    else{
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self startReading];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"No Barcode Found" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    return isexits;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.vendorItemArray.count;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"HItemProductCell";
    
    HItemProductCell *productCell = (HItemProductCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    productCell.selectionStyle=UITableViewCellSelectionStyleNone;
    productCell.backgroundColor = [UIColor clearColor];
    NSMutableDictionary *vendoritemDict = [(self.vendorItemArray)[indexPath.row]mutableCopy];
    
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
    
    [productCell.btnAddItem addTarget:self action:@selector(btnScanAddOrderItem:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self stopReading];
    if(self.swipedIndexpath.row != indexPath.row)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        HProductInfoVC *hitemProductinfo = [storyBoard instantiateViewControllerWithIdentifier:@"HProductInfoVC"];
        NSMutableDictionary *vendoritemDict = (self.vendorItemArray)[indexPath.row];
        hitemProductinfo.isfromItem=YES;
        hitemProductinfo.strPoId=self.strPoId;
        hitemProductinfo.dictProductInfo=[vendoritemDict mutableCopy];
        [self.navigationController pushViewController:hitemProductinfo animated:YES];
    }
    
}

-(NSString *)getEffectiveDate:(NSDate *)pDate{
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"IST"];
    dateFormatter2.timeZone = gmt;
    dateFormatter2.dateFormat = @"dd/MM/yyyy";
    NSString *streffectiveDate = [dateFormatter2 stringFromDate:pDate];
    
    return streffectiveDate;
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
    lblCase.text=[NSString stringWithFormat:@"%ld",(long)lblCase.text.integerValue-1];
}

-(void)lblUnitQtyAdd:(id)sender{
    
    NSIndexPath *indPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    HItemProductCell *productCell= (HItemProductCell *)[self.tblItemProduct cellForRowAtIndexPath:indPath];
    
    UILabel *lblUnit = (UILabel *)[productCell viewWithTag:600];
    lblUnit.text=[NSString stringWithFormat:@"%ld",(long)lblUnit.text.integerValue+1];
    
}

-(void)lblUnitQtyminus:(id)sender{
    
    NSIndexPath *indPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    HItemProductCell *productCell= (HItemProductCell *)[self.tblItemProduct cellForRowAtIndexPath:indPath];
    
    UILabel *lblUnit = (UILabel *)[productCell viewWithTag:600];
    lblUnit.text=[NSString stringWithFormat:@"%ld", (long)lblUnit.text.integerValue-1];
}
-(void)btnScanAddOrderItem:(id)sender{
    
    if(self.strPoId.length>0 && _vpurchaseOrder!=nil){
        
        HItemProductCell *productCell = (HItemProductCell *)[self.tblItemProduct cellForRowAtIndexPath:swipedIndexpath];
    
        _dictProductInfo = (self.vendorItemArray)[[sender tag]];
        
        _strSingle =productCell.lblUnitQty.text;
        _strCase =productCell.lblCashQty.text;
        
        [self callWebServiceForScanPurchaseOrderAddItem];
        
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


- (void)callWebServiceForScanPurchaseOrderAddItem
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
            [self scanpurchaseOrderItemAddResponse:response error:error];
        });
    };
    
    self.poItemAddWebservice = [self.poItemAddWebservice initWithRequest:KURL actionName:WSM_ADD_HACKNEY_PO_ITEM params:poparam completionHandler:completionHandler];

}

- (void)scanpurchaseOrderItemAddResponse:(id)response error:(NSError *)error

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
    
    //if(self.isfromItem){
        
        NSArray *arrayView = self.navigationController.viewControllers;
        for(UIViewController *viewcon in arrayView){
            if([viewcon isKindOfClass:[HPOItemListVC class]]){
                [self stopReading];
                [self.navigationController popToViewController:viewcon animated:YES];
                
            }
        }
   /* }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Item added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
        
        self.swipedIndexpath= [NSIndexPath indexPathForRow:-1 inSection:0];
        [self.tblItemProduct reloadData];
        
    }*/
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

-(IBAction)cancelClick:(id)sender{
    
    [self stopReading];
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
