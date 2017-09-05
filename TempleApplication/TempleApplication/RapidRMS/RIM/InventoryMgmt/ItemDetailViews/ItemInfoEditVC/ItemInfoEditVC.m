//
//  ItemInfoEditVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 29/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Department+Dictionary.h"
#import "HoldInvoice+Dictionary.h"
#import "ImagesCell.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "Item+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "ItemDiscountVC.h"
#import "ItemHistoryVC.h"
#import "ItemImageSelectionVC.h"
#import "ItemInfoEditVC.h"
#import "ItemInfoVC.h"
#import "ItemOptionsVC.h"
#import "ItemPricingVC.h"
#import "ItemVariation_M+Dictionary.h"
#import "ItemVariation_Md+Dictionary.h"
#import "NSString+Validation.h"
#import "RimsController.h"
#import "RmsDbController.h"
#import "SelectUserOptionVC.h"
#import "SizeMaster+Dictionary.h"
#import "Variation_Master+Dictionary.h"
#import "Configuration.h"


@interface ItemInfoEditVC () <PriceChangeAndCalculationDelegate,ItemOptionsVCDelegate,ItemSelctionImageChangedVCDelegate>
{
    AsyncImageView * itemImage;
    UIImagePickerController *controller;
    UIImagePickerController *pickerCamera ;
    
    ItemInfoVC * itemInfoVC;
    ItemOptionsVC *itemOptionsVC;
    ItemHistoryVC *itemHistoryVC;
    ItemDiscountVC * itemDiscountVC;
    ItemPricingVC * itemPricingVC;
    Configuration *configuration;
    BOOL flgUpdate;
    BOOL IsImageDeleted;
    
    NSData *imageData;
    NSInteger deleteRecordId;
    NSInteger selectedDiscount;
    NSInteger selectedPricingOption;

    UIButton *btnCameraClick;
}

@property (nonatomic, strong) UpdateManager * itemUpdateManager;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, weak) IBOutlet UIView *parentItemInfoView;
@property (nonatomic, weak) IBOutlet UIView * editViewContainer;

@property (nonatomic, weak) IBOutlet UIButton *itemInfoBtn;
@property (nonatomic, weak) IBOutlet UIButton *itemDiscountBtn;
@property (nonatomic, weak) IBOutlet UIButton *itemHistroyBtn;
@property (nonatomic, weak) IBOutlet UIButton *itemOptionBtn;
@property (nonatomic, weak) IBOutlet UIButton *itemPricingBtn;
@property (nonatomic, weak) IBOutlet UIButton *btn_DeleteRecord;
@property (nonatomic, weak) IBOutlet UIButton *btnSave;

@property (nonatomic) BOOL isInvenHomeCalled;
@property (nonatomic) BOOL isImageSet;
@property (nonatomic) BOOL isGroupSchemeApply;

@property (nonatomic, strong) NSMutableArray * manualEntryAddItem;
@property (nonatomic, strong) NSMutableArray * SizeArray;
@property (nonatomic, strong) NSMutableArray * itemPricingSelection;
@property (nonatomic, strong) NSMutableArray * itemVariationMasterData;
@property (nonatomic, strong) NSMutableArray *pricingSelection;
@property (nonatomic, strong) NSMutableArray *departmentSelection;

@property (nonatomic, strong) NSMutableDictionary * itemUpdate;
@property (nonatomic, strong) NSMutableDictionary * itemInsert;
@property (nonatomic, strong) NSMutableDictionary * dictTemp;

@property (nonatomic, strong) NSString * clickedButton;
@property (nonatomic, strong) NSString * currentDateTime;
@property (nonatomic, strong) NSString * strUpdateType;

@property (nonatomic, strong) NSString * mixMatchFlg;
@property (nonatomic, strong) NSString * mixMatchId;
@property (nonatomic, strong) NSString * cate_MixMatchId;
@property (nonatomic, strong) NSString * cate_MixMatchFlg;
@property (nonatomic, strong) NSString * RetItemID;
@property (nonatomic, strong) NSString * retGroupId;
@property (nonatomic, strong) NSString * strTempBarcodeSave;
@property (nonatomic, strong) NSString * moduleCode;

@property (nonatomic, strong) RapidWebServiceConnection * itemInsertWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * itemUpdateWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *updatedItemWC;
@property (nonatomic, strong) RapidWebServiceConnection *itemDeletedWC;
@property (nonatomic, strong) RapidWebServiceConnection *manualEntryliveUpdateConnection;

@end

@implementation ItemInfoEditVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - UIView -
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    if (self.itemInfoDataObject == nil) {
        self.itemInfoDataObject = [[ItemInfoDataObject alloc]init];
    }
    self.itemInsertWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.itemUpdateWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.updatedItemWC = [[RapidWebServiceConnection alloc] init];
    self.itemDeletedWC = [[RapidWebServiceConnection alloc] init];
    self.manualEntryliveUpdateConnection = [[RapidWebServiceConnection alloc]init];
    
    self.itemUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];

    [self setupInitializationValue];
//    [self CoustomCellForTableView];

    if (!flgUpdate) {
//        if([self isRestaurentActive]) { 16-Nov-2016 defaul on by Beverage world
//            self.itemInfoDataObject.quantityManagementEnabled = TRUE;
//            self.itemInfoDataObject.oldquantityManagementEnabled = TRUE;
//        }
//        else{
//            self.itemInfoDataObject.quantityManagementEnabled = FALSE;
//            self.itemInfoDataObject.oldquantityManagementEnabled = FALSE;
//        }
        self.itemInfoDataObject.quantityManagementEnabled = FALSE;
        self.itemInfoDataObject.oldquantityManagementEnabled = FALSE;
    }
    [self loadItemInfo];
    [self loadItemPricing];
    [self loadItemDiscount];
    [self loadItemHistory];
    [self loadItemOptions];
   
    if ((self.itemInfoDataObject.DepartId.intValue == 0 && self.itemInfoDataObject.ITM_Type.intValue == 1) || (self.itemInfoDataObject.SubDepartId.intValue ==0  && self.itemInfoDataObject.ITM_Type.intValue == 2)) {
        _btnSave.enabled = NO;
        _btn_DeleteRecord.enabled = NO;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.rimsController.scannerButtonCalled=@"InvAdd";
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setupInitializationValue{
//    arrayList = [[NSMutableArray alloc] init];
    
    self.itemInfoDataObject.imageNameURL = self.itemInfoDataObject.ItemImage;
    if (!self.itemInfoDataObject.DepartId) {
        self.itemInfoDataObject.DepartId = @0;
    }

    self.mixMatchFlg = @"0";
    self.mixMatchId = @"0";
    self.cate_MixMatchFlg = @"0";
    self.cate_MixMatchId = @"0";
    self.isImageSet=FALSE;
    IsImageDeleted = FALSE;
    
//    self.ITM_Type = @"0";
    if([self.rimsController.scannerButtonCalled isEqualToString:@""]) {
        self.rimsController.scannerButtonCalled=@"InvAdd";
    }
    
    self.itemInfoDataObject.discountDetailsArray = [[NSMutableArray alloc] init];
    self.itemInfoDataObject.responseTagArray = [[NSMutableArray alloc] init];

    
    flgUpdate=FALSE;
    
    if(self.NewOrderCalled) {
        [self addDefaultBarcodeToArray];
    }
    if(self.isInvenHomeCalled) {
        [self addDefaultBarcodeToArray];
    }
    if(self.isInvenManageCalled) {
        [self addDefaultBarcodeToArray];
    }
    
    selectedDiscount = 0;
    self.isGroupSchemeApply = FALSE;

    
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSArray *moduleCodes = @[@"RCR",@"RCRGAS",@"RRRCR",@"RRCR"];
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@" ModuleCode IN %@",moduleCodes];
    NSArray *moduleArray = [activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (moduleArray.count > 0) {
        self.moduleCode = [moduleArray.firstObject valueForKey:@"ModuleCode"];
    }
    else{
        self.moduleCode = @"RCR";
    }
    
    if([self.moduleCode isEqualToString:@"RCRGAS"]) {
        [self configurePricingTabOptionsWithoutVariation];
//        self.itemInfoDataObject.quantityManagementEnabled = FALSE;
//        self.itemInfoDataObject.oldquantityManagementEnabled = FALSE;
    }
    else{
        [self configurePricingTabOptionsWithVariation];
//        self.itemInfoDataObject.quantityManagementEnabled = FALSE;
//        self.itemInfoDataObject.oldquantityManagementEnabled = FALSE;
    }
    
    // Weight Scale Pricing Data
    self.itemInfoDataObject.itemWeightScaleArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *weightDictionary = [@{
                                               @"PriceQtyType":@"",
                                               @"Qty":@"0",
                                               @"Cost":@"0.00",
                                               @"Profit":@"0.00",
                                               @"UnitPrice":@"0.00",
                                               @"PriceA":@"0.00",
                                               @"PriceB":@"0.00",
                                               @"PriceC":@"0.00",
                                               @"ApplyPrice":@"",
                                               @"CreatedDate":@"",
                                               @"IsPackCaseAllow":@"0",
                                               @"UnitType":@"",
                                               @"UnitQty":@"0",
                                               } mutableCopy ];
    [self.itemInfoDataObject.itemWeightScaleArray addObject:[weightDictionary mutableCopy ]];
    [self.itemInfoDataObject.itemWeightScaleArray addObject:[weightDictionary mutableCopy ]];
    [self.itemInfoDataObject.itemWeightScaleArray addObject:[weightDictionary mutableCopy ]];
    
    // Update dictionary with default value
    self.itemInfoDataObject.itemWeightScaleArray[0] [@"PriceQtyType"] = @"Single Item";
    self.itemInfoDataObject.itemWeightScaleArray[0] [@"Qty"] = @"1";
    self.itemInfoDataObject.itemWeightScaleArray[0] [@"ApplyPrice"] = @"UnitPrice";
    
    self.itemInfoDataObject.itemWeightScaleArray[1] [@"PriceQtyType"] = @"Case";
    self.itemInfoDataObject.itemWeightScaleArray[1] [@"ApplyPrice"] = @"UnitPrice";
    self.itemInfoDataObject.itemWeightScaleArray[2] [@"PriceQtyType"] = @"Pack";
    self.itemInfoDataObject.itemWeightScaleArray[2] [@"ApplyPrice"] = @"UnitPrice";
    
    // Appropreate Pricing Data
    self.itemInfoDataObject.itemPricingArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *pricingDictionary = [@{
                                                @"PriceQtyType":@"",
                                                @"Qty":@"0",
                                                @"Cost":@"0.00",
                                                @"Profit":@"0.00",
                                                @"UnitPrice":@"0.00",
                                                @"PriceA":@"0.00",
                                                @"PriceB":@"0.00",
                                                @"PriceC":@"0.00",
                                                @"ApplyPrice":@"",
                                                @"CreatedDate":@"",
                                                @"IsPackCaseAllow":@"0",
                                                @"UnitType":@"",
                                                @"UnitQty":@"0",
                                                } mutableCopy ];
    [self.itemInfoDataObject.itemPricingArray addObject:[pricingDictionary mutableCopy ]];
    [self.itemInfoDataObject.itemPricingArray addObject:[pricingDictionary mutableCopy ]];
    [self.itemInfoDataObject.itemPricingArray addObject:[pricingDictionary mutableCopy ]];
    
    // Update dictionary with default value
    self.itemInfoDataObject.itemPricingArray[0] [@"PriceQtyType"] = @"Single Item";
    self.itemInfoDataObject.itemPricingArray[0] [@"Qty"] = @"1";
    self.itemInfoDataObject.itemPricingArray[0] [@"ApplyPrice"] = @"UnitPrice";
    
    self.itemInfoDataObject.itemPricingArray[1] [@"PriceQtyType"] = @"Case";
    self.itemInfoDataObject.itemPricingArray[1] [@"ApplyPrice"] = @"UnitPrice";
    self.itemInfoDataObject.itemPricingArray[2] [@"PriceQtyType"] = @"Pack";
    self.itemInfoDataObject.itemPricingArray[2] [@"ApplyPrice"] = @"UnitPrice";
    
    [self.itemInfoDataObject createDuplicateItemPricingArray];
    [self.itemInfoDataObject createDuplicateItemWeightScaleArray];
    self.itemInfoDataObject.duplicateUPCItemCodes = @"";
    self.itemInfoDataObject.itemVariationTypes = [[NSMutableArray alloc] init];
    self.itemVariationMasterData = [[NSMutableArray alloc] init];
    
    if(self.itemInfoDataObject.arrItemAllBarcode == nil) {
        self.itemInfoDataObject.arrItemAllBarcode = [[NSMutableArray alloc] init ];
    }
    self.itemInfoDataObject.isCopy = self.isCopy;
    if([self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemId.stringValue] moc:self.managedObjectContext]) {
        if(self.isCopy) {
            flgUpdate = NO;
        }
        else{
            flgUpdate = TRUE;
        }
        if(![self.itemInfoDataObject.Barcode isEqualToString:@""]) {
            flgUpdate = TRUE;
            [self getItemMultipleBarcode];
        }
        else{
            dispatch_queue_t queue = dispatch_queue_create("getItemImage", NULL);
            dispatch_async(queue, ^{
                NSString *copyImageNameURL = self.itemInfoDataObject.ItemImage;
                if ([[copyImageNameURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                    self.itemInfoDataObject.selectedImage = nil;
                }
                else{
                    NSURL *url = [NSURL URLWithString:copyImageNameURL];
                    NSData *copyImageData = [NSData dataWithContentsOfURL:url];
                    self.isImageSet = TRUE;
                    self.itemInfoDataObject.selectedImage = [UIImage imageWithData:copyImageData];
                };
            });
        }
        [self viewItemMain];
    }
    else{ // insert process data
        selectedPricingOption = PricingAppropreate;
        self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingAppropreate), nil];
        self.itemInfoDataObject.isPricingLevelSelected = TRUE;
        self.itemInfoDataObject.PriceScale = @"APPPRICE";
    }
    
    if(deleteRecordId == 0 ) {
        _btn_DeleteRecord.enabled = FALSE;
    }
}
-(void)viewItemMain {

    deleteRecordId = self.itemInfoDataObject.ItemId.integerValue ;
    if([self.itemInfoDataObject.Barcode isEqualToString:@""]) {
        _btn_DeleteRecord.enabled = FALSE;
    }
    else{
        _btn_DeleteRecord.enabled = TRUE;
    }
    if(![self.clickedButton isEqualToString:@"copy"]) {
        self.strTempBarcodeSave = self.itemInfoDataObject.Barcode;
    }

    if (self.itemInfoDataObject.isQtyDiscount) {
        selectedDiscount = 1;
    }
    else{
        selectedDiscount = 0;
    }
    
    if([self.itemInfoDataObject.PriceScale isEqualToString:@"WSCALE"]) {
        self.itemInfoDataObject.PriceScale = @"WSCALE";
        selectedPricingOption = PricingWeightScale;
        self.itemInfoDataObject.isPricingLevelSelected = FALSE;
        [self.itemInfoDataObject.selectedPricingType insertObject:@(PricingWeightScale) atIndex:2];
        [self getWeightScaleData];
    }
    else if([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) {
        self.itemInfoDataObject.PriceScale = @"VARIATION";
        selectedPricingOption = PricingVariations;
        self.itemInfoDataObject.isPricingLevelSelected = TRUE;
        [self.itemInfoDataObject.selectedPricingType insertObject:@(PricingVariations) atIndex:2];
        [self getItemVariationData];
    }
    else if([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATIONAPPROPRIATE"]) {
        self.itemInfoDataObject.PriceScale = @"VARIATIONAPPROPRIATE";
        selectedPricingOption = PricingVariations_Appropreate;
        self.itemInfoDataObject.isPricingLevelSelected = TRUE;
        [self.itemInfoDataObject.selectedPricingType insertObject:@(PricingVariations_Appropreate) atIndex:2];
        [self getPricingData];
        [self getItemVariationData];
    }
    else{
        self.itemInfoDataObject.PriceScale = @"APPPRICE";
        selectedPricingOption = PricingAppropreate;
        self.itemInfoDataObject.isPricingLevelSelected = TRUE;
        [self.itemInfoDataObject.selectedPricingType insertObject:@(PricingAppropreate) atIndex:2];
        [self getPricingData];
    }
    
    if (self.itemInfoDataObject.IsduplicateUPC) {
        self.itemInfoDataObject.IsduplicateUPC = TRUE;
    }
    else{
        self.itemInfoDataObject.IsduplicateUPC = FALSE;
    }
//    self.itemInfoDataObject.DepartId = [self.itemInfoDataObject.DepartId stringValue];
//    self.itemInfoDataObject.subDeptIds = [self.itemInfoDataObject.SubDepartId stringValue];
//    self.subDeptName = [itemDataDict valueForKey:@"SubDepartmentName"];
    
    if (self.itemInfoDataObject.quantityManagementEnabled) {
        self.itemInfoDataObject.quantityManagementEnabled = TRUE;
        self.itemInfoDataObject.oldquantityManagementEnabled = TRUE;
        // switch status is ON
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"] isEqualToString:@"Yes"]) {
            self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty),@(PricingSectionItemUnitQty_Unit), nil];
        }
        else{ // when weight scale will not active from setting
            self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
        }
    }
    else{
        self.itemInfoDataObject.quantityManagementEnabled = FALSE;
        self.itemInfoDataObject.oldquantityManagementEnabled = FALSE;
        // switch status is OFF
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"] isEqualToString:@"Yes"]) {
            self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty),@(PricingSectionItemUnitQty_Unit), nil];
        }
        else // when weight scale will not active from setting
        {
            self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
        }
    }
}
-(void)addDefaultBarcodeToArray{
    if(self.itemInfoDataObject.arrItemAllBarcode == nil) {
        self.itemInfoDataObject.arrItemAllBarcode = [[NSMutableArray alloc] init ];
    }
    if (self.strScanBarcode && self.strScanBarcode.length >0 ) {
        self.itemInfoDataObject.Barcode = self.strScanBarcode;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"Barcode"] = self.itemInfoDataObject.Barcode;
        dict[@"PackageType"] = @"Single Item";
        dict[@"IsDefault"] = @"1";
        dict[@"isExist"] = @"";
        dict[@"notAllowItemCode"] = @"";
        [self.itemInfoDataObject.arrItemAllBarcode addObject:dict];
    }
}
#pragma mark - Configure Number of cell -
- (void)configurePricingTabOptionsWithoutVariation{ // Remove variations
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"] isEqualToString:@"Yes"]) {
        self.pricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingWeightScale),@(PricingAppropreate), nil];
        self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption), nil];
        self.itemInfoDataObject.pricingOption = [[NSMutableArray alloc] initWithObjects:@(PricingWeightScale),@(PricingAppropreate), nil];
        self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty),@(PricingSectionItemUnitQty_Unit), nil];
    }
    else{ // when weight scale will not active from setting
        self.pricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingAppropreate), nil];
        self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption), nil];
        self.itemInfoDataObject.pricingOption = [[NSMutableArray alloc] initWithObjects:@(PricingAppropreate), nil];
        self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
    }
    self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(TaxSection), nil];
    [self configureSectionBasedOnCurrentDevice];
}

- (void)configureSectionBasedOnCurrentDevice{
    if(IsPhone()) {
        self.itemInfoDataObject.itemInfoSectionArray = [[NSMutableArray alloc] initWithObjects:@(ItemImageSection),@(ItemInfoSection),@(ItemPricingSection),@(ItemDepartmentTaxSection),@(SupplierSection),@(ProductInfoSection),@(DescriptionSection), nil];
    }
    else{
        self.itemInfoDataObject.itemInfoSectionArray = [[NSMutableArray alloc] initWithObjects:@(ItemInfoSection),@(ItemPricingSection),@(ItemDepartmentTaxSection),@(SupplierSection),@(ProductInfoSection),@(DescriptionSection), nil];
    }
}

- (void)configurePricingTabOptionsWithVariation{ // Add variations
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WeightScaleStatus"] isEqualToString:@"Yes"]) {
        self.pricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingWeightScale),@(PricingAppropreate),@(PricingVariations),@(PricingVariations_Appropreate),@(PricingVariation_1),@(PricingVariation_2), nil];
        self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption), nil];
        self.itemInfoDataObject.pricingOption = [[NSMutableArray alloc] initWithObjects:@(PricingWeightScale),@(PricingAppropreate),@(PricingVariations),@(PricingVariations_Appropreate), nil];
        self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty),@(PricingSectionItemUnitQty_Unit), nil];
    }
    else{ // when weight scale will not active from setting
        self.pricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingAppropreate),@(PricingVariations),@(PricingVariations_Appropreate), nil];
        self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption), nil];
        self.itemInfoDataObject.pricingOption = [[NSMutableArray alloc] initWithObjects:@(PricingAppropreate),@(PricingVariations),@(PricingVariations_Appropreate), nil];
        self.itemPricingSelection = [[NSMutableArray alloc] initWithObjects:@(PricingSectionItemTitle),@(PricingSectionItemQty),@(PricingSectionItemCost),@(PricingSectionItemProfit),@(PricingSectionItemSales),@(PricingSectionItemNoOfQty), nil];
    }
    if([self isSubDepartmentActive]) {
        self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(SubDepartmentSection),@(VariationSection),@(TaxSection), nil];
    }
    else{
        self.departmentSelection = [[NSMutableArray alloc] initWithObjects:@(DepartmentSection),@(VariationSection),@(TaxSection), nil];
    }
    [self configureSectionBasedOnCurrentDevice];
}

#pragma mark - Detail SubView -

-(void)loadItemInfo{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];

    itemInfoVC  = [storyboard instantiateViewControllerWithIdentifier:@"ItemInfoVC"];

    itemInfoVC.itemInfoDataObject=self.itemInfoDataObject;
    itemInfoVC.priceChangeAndCalculationDelegate=self;
    itemInfoVC.itemInfoSectionArray=self.itemInfoDataObject.itemInfoSectionArray;
    itemInfoVC.itemPricingSelection=self.itemPricingSelection;
    itemInfoVC.moduleCode=self.moduleCode;
    itemInfoVC.departmentSelection=self.departmentSelection;
    itemInfoVC.view.frame = _editViewContainer.bounds;
    [self addChildViewController:itemInfoVC];
    [_editViewContainer addSubview:itemInfoVC.view];
    itemInfoVC.view.hidden = NO;
}


-(void)loadItemHistory{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    
    itemHistoryVC  = [storyboard instantiateViewControllerWithIdentifier:@"ItemHistoryVC"];
    itemHistoryVC.itemInfoDataObject = self.itemInfoDataObject;
    itemHistoryVC.itemQtyDict=@{@"NumOfCase": [NSString stringWithFormat:@"%@",self.itemInfoDataObject.itemPricingArray[1][@"Qty"]],@"NumOfPack": [NSString stringWithFormat:@"%@",self.itemInfoDataObject.itemPricingArray[2][@"Qty"]]};
    
    itemHistoryVC.managedObjectContext = self.managedObjectContext;
    itemHistoryVC.view.frame = _editViewContainer.bounds;
    [self addChildViewController:itemHistoryVC];
    [_editViewContainer addSubview:itemHistoryVC.view];
    itemHistoryVC.view.hidden = YES;
}

-(void)loadItemOptions{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    
    itemOptionsVC  = [storyboard instantiateViewControllerWithIdentifier:@"ItemOptionsVC"];

    itemOptionsVC.itemOptionsVCDelegate = self;
    itemOptionsVC.itemInfoDataObject=self.itemInfoDataObject;
    itemOptionsVC.isUpdateItem = flgUpdate;
    itemOptionsVC.view.frame = _editViewContainer.bounds;
    [self addChildViewController:itemOptionsVC];
    [_editViewContainer addSubview:itemOptionsVC.view];
    itemOptionsVC.view.hidden = YES;
}

-(void)loadItemDiscount{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];

    itemDiscountVC  = [storyboard instantiateViewControllerWithIdentifier:@"ItemDiscountVC"];
    itemDiscountVC.itemInfoDataObject=self.itemInfoDataObject;
    
    itemDiscountVC.view.frame = _editViewContainer.bounds;
    [self addChildViewController:itemDiscountVC];
    [_editViewContainer addSubview:itemDiscountVC.view];
    itemDiscountVC.view.hidden = YES;
}

-(void)loadItemPricing{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];

    itemPricingVC  = [storyboard instantiateViewControllerWithIdentifier:@"ItemPricingVC"];
    itemPricingVC.itemInfoDataObject=self.itemInfoDataObject;
    itemPricingVC.priceChangeAndCalculationDelegate=self;
    itemPricingVC.selectedPricingOption=selectedPricingOption;
    itemPricingVC.view.frame = _editViewContainer.bounds;
    [self addChildViewController:itemPricingVC];
    [_editViewContainer addSubview:itemPricingVC.view];
    itemPricingVC.view.hidden = YES;
}

#pragma mark - Variation
-(void)setItemVariationsValue{
    self.itemInfoDataObject.itemVariationTypes = [self makeVariationArray];
    self.itemVariationMasterData = [self makeVariationItemArray];
    if(selectedPricingOption == PricingVariations) {
        self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingVariations), nil];
    }
    else if(selectedPricingOption == PricingVariations_Appropreate) {
        self.itemInfoDataObject.selectedPricingType = [[NSMutableArray alloc] initWithObjects:@(PricingPriceAtPos),@(PricingOption),@(PricingVariations_Appropreate), nil];
    }
}
#pragma mark - LoadPriceDetail Array -
-(void)getItemVariationData{
    if(self.itemInfoDataObject.itemVariationTypes.count > 0) {
        self.itemInfoDataObject.itemVariationData1 = [[NSMutableArray alloc] init];
        self.itemInfoDataObject.itemVariationData2 = [[NSMutableArray alloc] init];
        self.itemInfoDataObject.itemVariationData3 = [[NSMutableArray alloc] init];
        for (int i = 0 ; i < self.itemInfoDataObject.itemVariationTypes.count; i++) {
            if(i == 0) {
                NSNumber *checkId = [(self.itemInfoDataObject.itemVariationTypes)[i] valueForKey:@"Id" ];
                self.itemInfoDataObject.itemVariationData1 = [self getSpecificTypeVariations:checkId];
                [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_1)];
            }
            else if (i == 1) {
                NSNumber *checkId = [(self.itemInfoDataObject.itemVariationTypes)[i] valueForKey:@"Id" ];
                self.itemInfoDataObject.itemVariationData2 = [self getSpecificTypeVariations:checkId];
                [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_2)];
            }
            else if (i == 2) {
                NSNumber *checkId = [(self.itemInfoDataObject.itemVariationTypes)[i] valueForKey:@"Id" ];
                self.itemInfoDataObject.itemVariationData3 = [self getSpecificTypeVariations:checkId];
                [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_3)];
            }
        }
    }
    else{
        NSManagedObjectContext *context = self.managedObjectContext;
        self.itemInfoDataObject.itemVariationTypes = [[NSMutableArray alloc]init];
        Item *anItem = [self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemId.stringValue] moc:context];
        int cnt = 0;
        NSArray *itemVariations = anItem.itemVariations.allObjects ;
        NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"colPosNo" ascending:YES];
        NSArray *sortDescriptors = @[aSortDescriptor];
        NSArray *sortedArray = [itemVariations sortedArrayUsingDescriptors:sortDescriptors];
        
        for (ItemVariation_M *vari in sortedArray) {
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc]init];
            dictM[@"ColPosNo"] = vari.colPosNo;
            dictM[@"Id"] = vari.variationMMaster.vid;
            dictM[@"VariationId"] = vari.variationMMaster.vid;
            dictM[@"VariationName"] = vari.variationMMaster.name;
            [self.itemInfoDataObject.itemVariationTypes addObject:dictM];
            switch (cnt) {
                case 0:
                    self.itemInfoDataObject.itemVariationData1 = [self variationMDSforVariation:vari withItemVariationCode:anItem.itemCode ];
                    [self.itemVariationMasterData addObjectsFromArray:[self.itemInfoDataObject.itemVariationData1 mutableCopy]];
                    [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_1)];
                    break;
                case 1:
                    self.itemInfoDataObject.itemVariationData2 = [self variationMDSforVariation:vari withItemVariationCode:anItem.itemCode ];
                    [self.itemVariationMasterData addObjectsFromArray:[self.itemInfoDataObject.itemVariationData2 mutableCopy]];
                    [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_2)];
                    break;
                case 2:
                    self.itemInfoDataObject.itemVariationData3 = [self variationMDSforVariation:vari withItemVariationCode:anItem.itemCode ];
                    [self.itemVariationMasterData addObjectsFromArray:[self.itemInfoDataObject.itemVariationData3 mutableCopy]];
                    [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_3)];
                    break;
                    
                default:
                    break;
            }
            cnt++;
        }
//        [self.itemInfoDataObject createDuplicateItemVariationTypes];
//        
//        [self.itemInfoDataObject createDuplicateItemVariationData1];
//        [self.itemInfoDataObject createDuplicateItemVariationData2];
//        [self.itemInfoDataObject createDuplicateItemVariationData3];
    }
}
-(void)setItemVariationItemData{
    if(self.itemInfoDataObject.itemVariationTypes.count > 0) {
        self.itemInfoDataObject.itemVariationData1 = [[NSMutableArray alloc] init];
        self.itemInfoDataObject.itemVariationData2 = [[NSMutableArray alloc] init];
        self.itemInfoDataObject.itemVariationData3 = [[NSMutableArray alloc] init];
        for (int i = 0 ; i < self.itemInfoDataObject.itemVariationTypes.count; i++) {
            if(i == 0) {
                NSNumber *checkId = [(self.itemInfoDataObject.itemVariationTypes)[i] valueForKey:@"Id" ];
                self.itemInfoDataObject.itemVariationData1 = [self getSpecificTypeVariations:checkId];
                [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_1)];
            }
            else if (i == 1) {
                NSNumber *checkId = [(self.itemInfoDataObject.itemVariationTypes)[i] valueForKey:@"Id" ];
                self.itemInfoDataObject.itemVariationData2 = [self getSpecificTypeVariations:checkId];
                [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_2)];
            }
            else if (i == 2) {
                NSNumber *checkId = [(self.itemInfoDataObject.itemVariationTypes)[i] valueForKey:@"Id" ];
                self.itemInfoDataObject.itemVariationData3 = [self getSpecificTypeVariations:checkId];
                [self.itemInfoDataObject.selectedPricingType addObject:@(PricingVariation_3)];
            }
        }
    }
}
- (NSMutableArray *)getSpecificTypeVariations:(NSNumber *)varianceId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Id == %@ ",varianceId];
    NSArray *isVariationsFound = [self.itemVariationMasterData filteredArrayUsingPredicate:predicate];
    
    if(isVariationsFound.count > 0) {
        return [isVariationsFound mutableCopy];
    }
    else{
        isVariationsFound = [[NSArray alloc] init ];
        return [isVariationsFound mutableCopy];
    }
}
- (NSMutableArray *)variationMDSforVariation:(ItemVariation_M *)itemVariation_M withItemVariationCode:(NSNumber *)itemcode{
    if (itemVariation_M.variationMVariationMds.allObjects .count == 0) {
        return nil;
    }
    NSArray *variationMDS = itemVariation_M.variationMVariationMds.allObjects ;
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowPosNo" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    NSArray *sortedVarArray = [variationMDS sortedArrayUsingDescriptors:sortDescriptors];
    NSMutableArray *variationArray = [[NSMutableArray alloc] init];
    if(sortedVarArray.count>0) {
        for (ItemVariation_Md *varimd in sortedVarArray) {
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc]init];
            dictM[@"RowPosNo"] = varimd.rowPosNo;
            dictM[@"Id"] = varimd.variationMdVariationM.variationMasterId;
            dictM[@"Name"] = varimd.name;
            dictM[@"Cost"] = varimd.cost;
            dictM[@"Profit"] = varimd.profit;
            dictM[@"UnitPrice"] = varimd.unitPrice;
            dictM[@"PriceA"] = varimd.priceA;
            dictM[@"PriceB"] = varimd.priceB;
            dictM[@"PriceC"] = varimd.priceC;
            if(varimd.applyPrice.length>0) {
                dictM[@"ApplyPrice"] = [NSString stringWithFormat:@"%@",varimd.applyPrice ];
            }
            else{
                dictM[@"ApplyPrice"] = @"UnitPrice";
            }
            [variationArray addObject:dictM];
        }
    }
    return variationArray;
}
-(void)getWeightScaleData{
    NSManagedObjectContext *context = self.managedObjectContext;
    Item *anItem = [self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemId.stringValue] moc:context];
    self.itemInfoDataObject.itemWeightScaleArray = [[NSMutableArray alloc]init];
    for (Item_Price_MD *pricing in anItem.itemToPriceMd) {
        NSMutableDictionary *pricingDict = [[NSMutableDictionary alloc]init];
        pricingDict[@"PriceQtyType"] = pricing.priceqtytype;
        pricingDict[@"Qty"] = pricing.qty;
        pricingDict[@"Cost"] = pricing.cost;
        pricingDict[@"Profit"] = pricing.profit;
        pricingDict[@"UnitPrice"] = pricing.unitPrice;
        pricingDict[@"PriceA"] = pricing.priceA;
        pricingDict[@"PriceB"] = pricing.priceB;
        pricingDict[@"PriceC"] = pricing.priceC;
        pricingDict[@"ApplyPrice"] = pricing.applyPrice;
        pricingDict[@"IsPackCaseAllow"] = pricing.isPackCaseAllow;
        pricingDict[@"UnitType"] = pricing.unitType;
        pricingDict[@"UnitQty"] = pricing.unitQty;
        [self.itemInfoDataObject.itemWeightScaleArray addObject:pricingDict];
    }
    
    if(self.itemInfoDataObject.itemWeightScaleArray.count < 3) {
        NSArray *packageType = @[@"Single Item",@"Case",@"Pack"];
        NSMutableArray *priceQtyType = [self.itemInfoDataObject.itemWeightScaleArray valueForKey:@"PriceQtyType"];
        NSMutableArray *remainingPriceArray = [NSMutableArray arrayWithArray:packageType];
        [remainingPriceArray removeObjectsInArray:priceQtyType];
        NSMutableDictionary *pricingDictionary = [@{
                                                    @"PriceQtyType":@"",
                                                    @"Qty":@"0",
                                                    @"Cost":@"0.00",
                                                    @"Profit":@"0.00",
                                                    @"UnitPrice":@"0.00",
                                                    @"PriceA":@"0.00",
                                                    @"PriceB":@"0.00",
                                                    @"PriceC":@"0.00",
                                                    @"ApplyPrice":@"",
                                                    @"CreatedDate":@"",
                                                    @"IsPackCaseAllow":@"0",
                                                    @"UnitType":@"",
                                                    @"UnitQty":@"0",
                                                    } mutableCopy ];
        
        for (NSString *remPriceQtyType in remainingPriceArray) {
            NSMutableDictionary *priceDict = [pricingDictionary mutableCopy];
            priceDict [@"PriceQtyType"] = remPriceQtyType;
            priceDict [@"ApplyPrice"] = @"UnitPrice";
            [self.itemInfoDataObject.itemWeightScaleArray addObject:priceDict];
        }
    }
    
    [self.itemInfoDataObject.itemWeightScaleArray sortUsingComparator:
     ^NSComparisonResult(id obj1, id obj2) {
         NSDictionary *p1 = (NSDictionary *)obj1;
         NSDictionary *p2 = (NSDictionary *)obj2;
         
         int type1 = 10;
         int type2 = 10;
         
         type1 = [self qtyTypeForPricingDictionary:p1];
         type2 = [self qtyTypeForPricingDictionary:p2];
         
         if (type1 > type2) {
             return (NSComparisonResult)NSOrderedDescending;
         }
         if (type1 < type2) {
             return (NSComparisonResult)NSOrderedAscending;
         }
         return (NSComparisonResult)NSOrderedSame;
     }];
    [self.itemInfoDataObject createDuplicateItemWeightScaleArray];
}
-(void)getPricingData{
    NSManagedObjectContext *context = self.managedObjectContext;
    Item *anItem = [self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.ItemId.stringValue] moc:context];
    if (anItem) {
        self.itemInfoDataObject.itemPricingArray = [[NSMutableArray alloc]init];
        for (Item_Price_MD *pricing in anItem.itemToPriceMd) {
            NSMutableDictionary *pricingDict = [[NSMutableDictionary alloc]init];
            pricingDict[@"PriceQtyType"] = pricing.priceqtytype;
            pricingDict[@"Qty"] = pricing.qty;
            pricingDict[@"Cost"] = pricing.cost;
            pricingDict[@"Profit"] = pricing.profit;
            pricingDict[@"UnitPrice"] = pricing.unitPrice;
            pricingDict[@"PriceA"] = pricing.priceA;
            pricingDict[@"PriceB"] = pricing.priceB;
            pricingDict[@"PriceC"] = pricing.priceC;
            pricingDict[@"ApplyPrice"] = pricing.applyPrice;
            pricingDict[@"IsPackCaseAllow"] = pricing.isPackCaseAllow;
            pricingDict[@"UnitType"] = @"";
            pricingDict[@"UnitQty"] = @"0";
            [self.itemInfoDataObject.itemPricingArray addObject:pricingDict];
        }
        [self addPricingData];
        if(self.itemInfoDataObject.itemPricingArray.count < 3) {
            NSArray *packageType = @[@"Single Item",@"Case",@"Pack"];
            NSMutableArray *priceQtyType = [self.itemInfoDataObject.itemPricingArray valueForKey:@"PriceQtyType"];
            NSMutableArray *remainingPriceArray = [NSMutableArray arrayWithArray:packageType];
            [remainingPriceArray removeObjectsInArray:priceQtyType];
            
            NSMutableDictionary *pricingDictionary = [@{
                                                        @"PriceQtyType":@"",
                                                        @"Qty":@"0",
                                                        @"Cost":@"0.00",
                                                        @"Profit":@"0.00",
                                                        @"UnitPrice":@"0.00",
                                                        @"PriceA":@"0.00",
                                                        @"PriceB":@"0.00",
                                                        @"PriceC":@"0.00",
                                                        @"ApplyPrice":@"",
                                                        @"CreatedDate":@"",
                                                        @"IsPackCaseAllow":@"0",
                                                        @"UnitType":@"",
                                                        @"UnitQty":@"0",
                                                        } mutableCopy ];
            
            for (NSString *remPriceQtyType in remainingPriceArray) {
                NSMutableDictionary *priceDict = [pricingDictionary mutableCopy];
                priceDict [@"PriceQtyType"] = remPriceQtyType;
                priceDict [@"ApplyPrice"] = @"UnitPrice";
                [self.itemInfoDataObject.itemPricingArray addObject:priceDict];
            }
        }
        
        [self.itemInfoDataObject.itemPricingArray sortUsingComparator:
         ^NSComparisonResult(id obj1, id obj2) {
             
             NSDictionary *p1 = (NSDictionary *)obj1;
             NSDictionary *p2 = (NSDictionary *)obj2;
             
             int type1 = 10;
             int type2 = 10;
             
             type1 = [self qtyTypeForPricingDictionary:p1];
             type2 = [self qtyTypeForPricingDictionary:p2];
             
             if (type1 > type2) {
                 return (NSComparisonResult)NSOrderedDescending;
             }
             if (type1 < type2) {
                 return (NSComparisonResult)NSOrderedAscending;
             }
             return (NSComparisonResult)NSOrderedSame;
         }];
        [self.itemInfoDataObject createDuplicateItemPricingArray];
    }
}

-(void)addPricingData{
    
    if(self.itemInfoDataObject.itemPricingArray.count > 3) {
        
        NSMutableArray *itemPricingArrayTemp = [[NSMutableArray alloc]init];
        
        NSArray * arrayPricing = (NSArray *)self.itemInfoDataObject.itemPricingArray;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Qty" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        self.itemInfoDataObject.itemPricingArray = [(NSMutableArray *)[arrayPricing sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        
        // Check for Single Item Qty == 1
        
        NSPredicate *singlePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty == 1", @"Single Item"];
        NSArray *arraySingleItem = [self.itemInfoDataObject.itemPricingArray filteredArrayUsingPredicate:singlePredicate];
        if(arraySingleItem.count>0) {
            
            [itemPricingArrayTemp addObject:arraySingleItem.firstObject];
        }
        
        // Check for Single Item Qty > 1 then change to Case
        
        NSPredicate *singlePredicate1 = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Single Item"];
        NSArray *arraySingleItem2 = [self.itemInfoDataObject.itemPricingArray filteredArrayUsingPredicate:singlePredicate1];
        
        for (int i =0 ;i <arraySingleItem2.count;i++) {
            NSMutableDictionary *dictObject = arraySingleItem2[i];
            dictObject[@"PriceQtyType"] = @"Case";
        }
        
        // Predicate for Case and Qty > 1
        
        NSPredicate *casePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Case"];
        NSArray *arrayCaseItem = [self.itemInfoDataObject.itemPricingArray filteredArrayUsingPredicate:casePredicate];
        
        if(arrayCaseItem.count>0) {
            
            [itemPricingArrayTemp addObject:arrayCaseItem.firstObject];
        }
        
        // Predicate for Case and Qty > 1
        
        NSPredicate *packPredicate = [NSPredicate predicateWithFormat:@"PriceQtyType == %@ AND Qty > 1", @"Pack"];
        NSArray *arrayPackItem = [self.itemInfoDataObject.itemPricingArray filteredArrayUsingPredicate:packPredicate];
        
        if(arrayPackItem.count>0) {
            
            [itemPricingArrayTemp addObject:arrayPackItem.firstObject];
        }
        
        self.itemInfoDataObject.itemPricingArray = itemPricingArrayTemp;
    }
    
}

- (int)qtyTypeForPricingDictionary:(NSDictionary *)p1{
    int type = 10;
    if([p1[@"PriceQtyType"] isEqualToString:@"Single Item"] || [p1[@"PriceQtyType"] isEqualToString:@"SINGLE ITEM"] || [p1[@"PriceQtyType"] isEqualToString:@"Single item"]) {
        type = 1;
    }
    else if([p1[@"PriceQtyType"] isEqualToString:@"Case"] || [p1[@"PriceQtyType"] isEqualToString:@"CASE"]) {
        type = 2;
    }
    else if([p1[@"PriceQtyType"] isEqualToString:@"Pack"] || [p1[@"PriceQtyType"] isEqualToString:@"PACK"]) {
        type = 3;
    }
    return type;
}
#pragma mark UIImagePickerController Delegate Method

-(void)takePhoto{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (IsPhone()) {
            pickerCamera = [[UIImagePickerController alloc] init];
            pickerCamera.delegate = self;
            pickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerCamera animated:YES completion:NULL];
        }
        else{
            pickerCamera = [[UIImagePickerController alloc] init];
            pickerCamera.delegate = self;
            pickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerCamera animated:YES completion:nil];
        }
    }
    else{
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Camera not available" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}
-(void)ChooseExisting:(UIView *)sender {
    if(IsPad()) {
        btnCameraClick = [[UIButton alloc] initWithFrame:CGRectMake(840, 120, 64, 64)];
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:imagePicker animated:YES completion:nil];
        UIPopoverPresentationController * popup =imagePicker.popoverPresentationController;
        popup.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popup.sourceView = sender;
        popup.sourceRect = sender.bounds;
    }
    else{
        controller =[[UIImagePickerController alloc]init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate  = self;
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}
-(void)ChooseFromInternet:(UIView *)sender {
    
    ItemImageSelectionVC * itemImageSelectionVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard()
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemImageSelectionVC_sid"];
    
    itemImageSelectionVC.itemSelctionImageChangedVCDelegate = self;
    itemImageSelectionVC.strSearchText = self.itemInfoDataObject.ItemName;
    if (IsPad()) {
        [itemImageSelectionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
    }
    else {
        [self.navigationController pushViewController:itemImageSelectionVC animated:YES];
    }
}
-(void)removeItemImage {
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action) {
        [Appsee addEvent:kRIMItemRemoveImageCancel];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        [Appsee addEvent:kRIMItemRemoveImageDone];
        self.itemInfoDataObject.selectedImage = nil;
        NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
        [itemData setValue:@"" forKey:@"ItemImage"];
        self.isImageSet = TRUE;
        IsImageDeleted = TRUE;
        [self.itemInfoEditVCDelegate didUpdateItemInfo:itemData];
        [itemInfoVC.tblItemInfo reloadData];
        self.itemInfoDataObject.imageNameURL = @"";
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"Are you sure you want to remove item image ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];

}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    self.itemInfoDataObject.selectedImage = info[UIImagePickerControllerOriginalImage];
    NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
    
    [self setItemImageReloadSideInfoView:(UIImage *)self.itemInfoDataObject.selectedImage withImageUrl:@""];
    
    self.isImageSet = TRUE;
    IsImageDeleted = FALSE;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    pickerCamera = nil;
    
    [self.itemInfoEditVCDelegate didUpdateItemInfo:itemData];
    [itemInfoVC.tblItemInfo reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Item Image Selection -
-(void)willChangeItemSelectedImage:(UIButton *)sender{
    [self selectImageCapture:sender];
}
-(void)selectImageCapture:(UIButton *)sender{
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"Take A Photo",@"Choose Existing",@"Internet",@"Remove Image"] OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        if ([arrSelection[0] isEqualToString:@"Take A Photo"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self takePhoto];
            });
        }
        else if ([arrSelection[0] isEqualToString:@"Choose Existing"]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self ChooseExisting:sender];
            });
        }
        else if ([arrSelection[0] isEqualToString:@"Internet"]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self ChooseFromInternet:sender];
            });
            
        }
        else if ([arrSelection[0] isEqualToString:@"Remove Image"]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeItemImage];
            });
        }
        
    } SelectionColse:^(UIViewController * popUpVC){
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}
-(void)itemImageChangeNewImage:(UIImage *)image withImageUrl:(NSString *)imageUrl {
    self.isImageSet = TRUE;
    IsImageDeleted = FALSE;
    
    [self setItemImageReloadSideInfoView:image withImageUrl:imageUrl];
    if (IsPad()) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [itemInfoVC.tblItemInfo reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)setItemImageReloadSideInfoView:(UIImage *)image withImageUrl:(NSString *)strImageUrl{

    self.itemInfoDataObject.selectedImage = image;
    self.itemInfoDataObject.ItemImage = (NSString *)image;
    [self.itemInfoEditVCDelegate didUpdateItemInfo:self.itemInfoDataObject.itemMainInsertData];
}

#pragma mark - Delete Added Item -
-(IBAction)btn_DeleteRecord:(id)sender{
    [Appsee addEvent:kRIMFooterDeleteItem];
    
    [self.rmsDbController playButtonSound];
    if([self.itemInfoDataObject.ITM_Type isEqualToNumber:@1] || [self.itemInfoDataObject.ITM_Type isEqualToNumber:@2]) {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You can not delete this department from Item list, please delete it from department." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;
    }
    else if([self isAvailableInOffLineHolds:deleteRecordId]){
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"You can not delete this item,It is in offline Hold Invoice." buttonTitles:@[@"Yes"] buttonHandlers:@[rightHandler]];
    }
    else if(deleteRecordId != 0 ) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action) {
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
            [self deleteRecord:deleteRecordId];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this item?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}
-(BOOL)isAvailableInOffLineHolds:(NSInteger) itemCode{
    BOOL isInHold = FALSE;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext * privateMOC = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSString * strItemId = [NSString stringWithFormat:@"%ld",(long)itemCode];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"HoldInvoice" inManagedObjectContext:privateMOC];
    fetchRequest.entity = entity;
    
    NSArray *resultSet = [UpdateManager executeForContext:privateMOC FetchRequest:fetchRequest];
    
    for (HoldInvoice * objHoldInvoice in resultSet) {
        isInHold = [self checkitemInOfflineData:objHoldInvoice.holdData withItemID:strItemId];
        if (isInHold) {
            return isInHold;
        }
    }
    return isInHold;
}
-(BOOL)checkitemInOfflineData:(NSData *)recallOfflineData withItemID:(NSString *)strItemID {
    NSDictionary * dictrecallData = [NSKeyedUnarchiver unarchiveObjectWithData:recallOfflineData];
    NSArray * arrInvoiceDetail = dictrecallData[@"InvoiceDetail"];
    NSDictionary * dictItemInfo = arrInvoiceDetail.firstObject;
    NSArray * arrItems = dictItemInfo[@"InvoiceItemDetail"];
    NSArray * arrItemsId = [arrItems valueForKey:@"ItemCode"];
    if ([arrItemsId containsObject:strItemID]) {
        return YES;
    }
    else {
        return FALSE;
    }
}
-(void) deleteRecord:(NSInteger)deleteID{
    NSString *deleteItemCode = [NSString stringWithFormat:@"%ld", (long)deleteID];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    NSMutableDictionary *deleteparam=[[NSMutableDictionary alloc]init];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    self.currentDateTime = [formatter stringFromDate:date];
    deleteparam[@"Updatedate"] = self.currentDateTime;
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    deleteparam[@"UserId"] = userID;
    deleteparam[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    [deleteparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [deleteparam setValue:deleteItemCode forKey:@"ItemCode"];
    
    NSDictionary *deleteDict = @{kRIMItemDeleteWebServiceCallKey : deleteItemCode};
    [Appsee addEvent:kRIMItemDeleteWebServiceCall withProperties:deleteDict];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteAddItemResponse:response error:error];
        });
    };
    
    self.itemDeletedWC = [self.itemDeletedWC initWithRequest:KURL actionName:WSM_ITEM_DELETED params:deleteparam completionHandler:completionHandler];
}

- (void)deleteAddItemResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0) {
                NSDictionary *deleteDict = @{kRIMItemDeleteWebServiceResponseKey : @"Item Deleted Successfully"};
                [Appsee addEvent:kRIMItemDeleteWebServiceResponse withProperties:deleteDict];
                
                // deleteRecordId
                if (self.itemInfoDataObject.oldActive) {
                    Item * currentItem = [self fetchAllItems:[NSString stringWithFormat:@"%ld",(long)deleteRecordId] moc:self.managedObjectContext];
                    currentItem.active = @0;
                    NSError *error = nil;
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                    }
                }
                else {
                    [self.itemUpdateManager deleteItemWithItemCode:@(deleteRecordId)];
                }
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                    if (IsPad()) {
                        [self dismissSplitter:nil];
                    }
                    else{
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item has been deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                //                self.rimsController.objInvenMgmt.searchText = @"";
                //                self.rimsController.objInvenMgmt.txtUniversalSearch.text = @"";
                //                [self.rimsController.objInvenMgmt reloadInventoryMgmtTable];
            }
            else if ([[response  valueForKey:@"IsError"] intValue] == -2) {
                NSDictionary *deleteDict = @{kRIMItemDeleteWebServiceResponseKey : [response valueForKey:@"Data"]};
                [Appsee addEvent:kRIMItemDeleteWebServiceResponse withProperties:deleteDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else{
                NSDictionary *deleteDict = @{kRIMItemDeleteWebServiceResponseKey : @"Item not deleted"};
                [Appsee addEvent:kRIMItemDeleteWebServiceResponse withProperties:deleteDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Item not deleted" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}
#pragma mark - Dismiss Splitter
- (IBAction)dismissSplitter:(id)sender{
    [self.rmsDbController playButtonSound];
    if (IsPhone()) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.itemInfoEditVCDelegate dismissInventoryAddNewSplitterVC];
    }
}


-(IBAction)ChangeDisplayEditView:(UIButton *)sender{
    [self.rmsDbController playButtonSound];

    [self.view endEditing:YES];
    
    itemInfoVC.view.hidden = YES;
    itemHistoryVC.view.hidden = YES;
    itemOptionsVC.view.hidden = YES;
    itemDiscountVC.view.hidden = YES;
    itemPricingVC.view.hidden = YES;
    _editViewContainer.hidden=FALSE;
    [self tabbuttonDeselectedAllItemTab];
    sender.selected = TRUE;
    switch (sender.tag) {// Info
        case ItemEditTabInfo:{
            [Appsee addEvent:kRIMDisplayViewInfo];
            itemInfoVC.view.hidden = NO;
            [itemInfoVC.tblItemInfo reloadData];
        }
            break;
        case ItemEditTabDiscount:{// Discount
            [Appsee addEvent:kRIMDisplayViewDiscount];
            itemDiscountVC.view.hidden=NO;
            [itemDiscountVC.tblDiscountDetails reloadData];
        }
            break;
        case ItemEditTabHistory:{// History
            itemHistoryVC.itemQtyDict=@{@"NumOfCase": [NSString stringWithFormat:@"%@",self.itemInfoDataObject.itemPricingArray[1][@"Qty"]],@"NumOfPack": [NSString stringWithFormat:@"%@",self.itemInfoDataObject.itemPricingArray[2][@"Qty"]]};
            [itemHistoryVC.tblHistory reloadData];
            [Appsee addEvent:kRIMDisplayViewHistory];
            itemHistoryVC.view.hidden = NO;
        }
            break;
        case ItemEditTabOption:{ // Option
            [Appsee addEvent:kRIMDisplayViewOption];
            itemOptionsVC.view.hidden = NO;
            [itemOptionsVC.tblOption reloadData];
        }
            break;
        case ItemEditTabPricing:{// Pricing
            [Appsee addEvent:kRIMDisplayViewPricing];
            itemPricingVC.view.hidden=FALSE;
            [itemPricingVC.tblItemPricing reloadData];
        }
            break;
        default:
            break;
    }
}
-(void)tabbuttonDeselectedAllItemTab {
    self.itemInfoBtn.selected = FALSE;
    self.itemDiscountBtn.selected = FALSE;
    self.itemHistroyBtn.selected = FALSE;
    self.itemOptionBtn.selected = FALSE;
    self.itemPricingBtn.selected = FALSE;
}

#pragma mark - Change Price And Calculation -
-(void)didPriceChangeOfInputWeight:(NSNumber *)inputValue InputWeightUnit:(NSString *)weightUnit  ValueIndex:(int)IndexNumber{
    
    (self.itemInfoDataObject.itemWeightScaleArray[IndexNumber])[@"UnitQty"] = inputValue;
    
    (self.itemInfoDataObject.itemWeightScaleArray[IndexNumber])[@"UnitType"] = [NSString stringWithFormat:@"%@",weightUnit];
    [itemInfoVC.tblItemInfo reloadData];
    [itemPricingVC.tblItemPricing reloadData];
}
-(void)didPriceChangeOf:(PricingSectionItem)PriceValueType inputValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber{
    NSMutableArray * arrCalculation;
    if(self.itemInfoDataObject.isPricingLevelSelected) {
        arrCalculation=self.itemInfoDataObject.itemPricingArray;
    }
    else{
        arrCalculation=self.itemInfoDataObject.itemWeightScaleArray;
    }
    NSMutableArray * indexArray;
    NSString * strKey=@"";
    switch (PriceValueType) {
        case PricingSectionItemQty:{
            strKey=@"";
            if (IndexNumber>0) {
                NSArray *stringArray = [[NSString stringWithFormat:@"%.1f",inputValue.floatValue] componentsSeparatedByString:@"." ];
                if(stringArray.count == 2) {
                    int x = [stringArray[0] intValue ];
                    int y = [stringArray[1] intValue ];
                    float totalQty=[[self.itemInfoDataObject.itemPricingArray[IndexNumber] valueForKey:@"Qty"] floatValue];
                    inputValue=@(totalQty*x);
                    inputValue=@(inputValue.intValue+y);
                }
                else{
                    int x = [stringArray[0] intValue ];
                    float totalQty=[[self.itemInfoDataObject.itemPricingArray[IndexNumber] valueForKey:@"Qty"] floatValue];
                    inputValue=@(totalQty*x);
                }
            }
            self.itemInfoDataObject.avaibleQty = inputValue;
        }
            break;
        case PricingSectionItemCost:{
            strKey=@"Cost";
            [self ChangeCostInCasePackNewCost:inputValue ValueIndex:IndexNumber priceList:arrCalculation];

            NSUInteger reloadedRow=[itemInfoVC.itemPricingSelection indexOfObject:@(PricingSectionItemProfit)];
            [indexArray addObject:[NSIndexPath indexPathForRow:reloadedRow inSection:2]];
            break;
        }
        case PricingSectionItemProfit:
            strKey=@"";
            [self ChangeItemMarginNewMargin:inputValue ValueIndex:IndexNumber priceList:arrCalculation];
            break;
        case PricingSectionItemSales:
            strKey=@"UnitPrice";
            [self ChangeItemPriceNewPrice:inputValue ValueIndex:IndexNumber priceList:arrCalculation];
            if (IndexNumber==0) {
                self.itemInfoDataObject.SalesPrice = inputValue;
            }
            break;
        case PricingSectionItemNoOfQty:
            strKey=@"Qty";
            int packNoOfQTY = [arrCalculation[2][@"Qty"] intValue];
            int caseNoOfQTY = [arrCalculation[1][@"Qty"] intValue];
            if(IndexNumber == 1 && packNoOfQTY != 0){
                if (packNoOfQTY == inputValue.intValue) {
//                    strKey=@"";
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"# of Qty of Cash,Pack could not be same." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    return;
                }
            }
            else if(IndexNumber == 2 && caseNoOfQTY != 0){
                if (caseNoOfQTY == inputValue.intValue) {
//                    strKey=@"";
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {};
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"# of Qty of Cash,Pack could not be same." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    return;
                }
            }
            [self ChangeItemQtyNewQty:inputValue ValueIndex:IndexNumber priceList:arrCalculation];
            break;
        case PricingSectionItemUnitQty_Unit:
            strKey=@"";
            break;
        default:
            break;
    }
    if (![strKey isEqualToString:@""]) {
        if (PriceValueType == PricingSectionItemNoOfQty) {
            (arrCalculation[IndexNumber])[strKey] = [NSString stringWithFormat:@
                                                    "%d",(int)inputValue.intValue];
        }
        else{
            (arrCalculation[IndexNumber])[strKey] = [NSString stringWithFormat:@
                                                    "%.2f",inputValue.floatValue];
        }
    }
    NSMutableDictionary * dictItemSideInfo = [self.itemInfoDataObject getItemMainInsertData];
    dictItemSideInfo[@"responseTagArray"] = [self.itemInfoDataObject.responseTagArray valueForKey:@"SizeName"];
    
    NSArray * arrSupplierAll = [self.itemInfoDataObject.itemsupplierarray valueForKeyPath:@"SalesRepresentatives.FirstName"];
    NSMutableArray * arrSupplierName = [NSMutableArray array];
    for (NSArray * arrSupplier in arrSupplierAll) {
        if ([arrSupplier isKindOfClass:[NSArray class]] && arrSupplier.count > 0) {
            [arrSupplierName addObjectsFromArray:arrSupplier];
        }
    }
    NSSet * supplier = [[NSSet alloc]initWithArray:arrSupplierName];
    dictItemSideInfo[@"itemsupplierarray"] = [supplier allObjects];
    [self.itemInfoEditVCDelegate didUpdateItemInfo:dictItemSideInfo];
    [itemInfoVC.tblItemInfo reloadData];
    [itemPricingVC.tblItemPricing reloadData];
}
-(void)didPriceChangeOfMarkUPValue:(NSNumber *)inputValue ValueIndex:(int)IndexNumber{
    NSMutableArray * arrCalculation;
    if(self.itemInfoDataObject.isPricingLevelSelected) {
        arrCalculation=self.itemInfoDataObject.itemPricingArray;
    }
    else{
        arrCalculation=self.itemInfoDataObject.itemWeightScaleArray;
    }
    float cost = [[arrCalculation[IndexNumber] valueForKey:@"Cost"] floatValue];
    float Pirce=(cost*inputValue.floatValue)/100;
    Pirce=Pirce+cost;
    [self didPriceChangeOf:PricingSectionItemSales inputValue:@(Pirce) ValueIndex:IndexNumber];
}
-(void)ChangeCostInCasePackNewCost:(NSNumber *)newCost ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    
    float oneQtyCost=newCost.floatValue/[arrPriceList[IndexNumber][@"Qty"] floatValue];
    if (isnan(oneQtyCost) || isinf(oneQtyCost)) {
        oneQtyCost = 0;
    }
    (arrPriceList[0])[@"Cost"] = @(oneQtyCost);
    
    self.itemInfoDataObject.CostPrice = @(oneQtyCost);
    [self ChangeItemCostNewCost:oneQtyCost ValueIndex:0 priceList:arrPriceList];
    float caseCost=oneQtyCost*[arrPriceList[1][@"Qty"] floatValue];
    (arrPriceList[1])[@"Cost"] = @(caseCost);
    [self ChangeItemCostNewCost:caseCost ValueIndex:1 priceList:arrPriceList];
    
    float packCost=oneQtyCost*[arrPriceList[2][@"Qty"] floatValue];
    (arrPriceList[2])[@"Cost"] = @(packCost);
    
    [self ChangeItemCostNewCost:packCost ValueIndex:2 priceList:arrPriceList];
}
-(void)ChangeItemCostNewCost:(float)newCost ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    float margin;
    float Profit = [[arrPriceList[IndexNumber] valueForKey:@"UnitPrice"] floatValue]-newCost;
    float price = [[arrPriceList[IndexNumber] valueForKey:@"UnitPrice"] floatValue];
    margin=Profit/price;
    margin = margin*100;
    if (isnan(margin) || isinf(margin)) {
        margin = 0;
    }
//    NSString * marging=[NSString stringWithFormat:@"%.2f",margin*100];
//    if([marging isEqualToString:@"nan"] || [marging isEqualToString:@"-inf"] || [marging isEqualToString:@"inf"] || [marging isEqualToString:@"-100.00"]) {
//        marging=@"0.00";
//    }
    (arrPriceList[IndexNumber])[@"Profit"] = @(margin);
    if (IndexNumber==0) {
        self.itemInfoDataObject.ProfitAmt = @(margin);
    }
}
-(void)ChangeItemMarginNewMargin:(NSNumber *)newMargin ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    float price;
    float cost= [[arrPriceList[IndexNumber] valueForKey:@"Cost"] floatValue];
    price=cost/((100-newMargin.floatValue)/100);
    (arrPriceList[IndexNumber])[@"UnitPrice"] = @(price);
    if (IndexNumber==0) {
        self.itemInfoDataObject.SalesPrice = @(price);
    }
    
    //    [self ChangeItemPriceNewPrice:[[arrPriceList[IndexNumber] valueForKey:@"UnitPrice"] floatValue] ValueIndex:IndexNumber priceList:arrPriceList];
}
-(void)ChangeItemPriceNewPrice:(NSNumber *)newPrice ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    float margin;
    float Profit = newPrice.floatValue-[[arrPriceList[IndexNumber] valueForKey:@"Cost"] floatValue];
    
    margin=Profit/newPrice.floatValue;
    margin=margin*100;
//    NSString * marging=[NSString stringWithFormat:@"%.2f",margin*100];
    if (isnan(margin) || isinf(margin)) {
        margin = 0;
    }
    (arrPriceList[IndexNumber])[@"Profit"] = @(margin);
    if (IndexNumber == 0) {
        self.itemInfoDataObject.ProfitAmt = @(margin);
    }
}
-(void)ChangeItemQtyNewQty:(NSNumber *)newQty ValueIndex:(int)IndexNumber priceList:(NSMutableArray *) arrPriceList{
    
    float cost = [[arrPriceList[0] valueForKey:@"Cost"] floatValue];
    cost=cost*newQty.intValue;
    
    float profit=[[arrPriceList[IndexNumber] valueForKey:@"Profit"] floatValue];
    if (profit == 0 && IndexNumber>0) {
        float margin;
        float Profit = [[arrPriceList[0] valueForKey:@"UnitPrice"] floatValue]-[[arrPriceList[0] valueForKey:@"Cost"] floatValue];
        float price = [[arrPriceList[0] valueForKey:@"UnitPrice"] floatValue];
        margin=Profit/price;
        
//        NSString * marging=[NSString stringWithFormat:@"%.2f",margin*100];
//        if([marging isEqualToString:@"nan"] || [marging isEqualToString:@"-inf"] || [marging isEqualToString:@"inf"] || [marging isEqualToString:@"-100.00"]) {
//            marging=@"0.00";
//        }
        if (isnan(margin) || isinf(margin)) {
            margin = 0;
        }
        if(newQty.intValue == 0) {
            (arrPriceList[IndexNumber])[@"Profit"] = @0;
        }
        else{
            (arrPriceList[IndexNumber])[@"Profit"] = @(margin*100);
        }
        price=cost/((100-margin*100)/100);
        if (isnan(price) || isinf(price)) {
            price = 0;
        }
        (arrPriceList[IndexNumber])[@"UnitPrice"] = @(price);
        (arrPriceList[IndexNumber])[@"Cost"] = @(cost);
    }
    else {
        float Markgin=(100-profit)/100;
        if (isnan(Markgin) || isinf(Markgin)) {
            Markgin = 0;
        }
        float price=cost/Markgin;
        if (isnan(price) || isinf(price)) {
            price = 0;
        }

        (arrPriceList[IndexNumber])[@"Cost"] = @(cost);
        (arrPriceList[IndexNumber])[@"UnitPrice"] = @(price);
        if(newQty.intValue == 0) {
            (arrPriceList[IndexNumber])[@"Profit"] = @0;
        }
        
        if (IndexNumber == 0) {
            self.itemInfoDataObject.SalesPrice = @(price);
        }

    }
}

#pragma mark - ItemOptionsVCDelegate Method -

- (void)isActiveApply:(BOOL)isActive{
    self.itemInfoDataObject.Active = isActive;
}
- (void)isFavoriteApply:(BOOL)isFavorite{
    self.itemInfoDataObject.IsFavourite = isFavorite;
}
- (void)isdisplayInPosApply:(BOOL)isDisplayInPos{
    self.itemInfoDataObject.DisplayInPOS = isDisplayInPos;
}
- (void)quantityManagementEnable:(BOOL)isQtyMgtEnabled{
    self.itemInfoDataObject.quantityManagementEnabled = isQtyMgtEnabled;
}
- (void)isItemPayoutApply:(BOOL)isItemPayout{
    self.itemInfoDataObject.isItemPayout = isItemPayout;
}
- (void)isMemoApplyToItem:(BOOL)isMemoApply {
    self.itemInfoDataObject.Memo = isMemoApply;
}
- (void)isEBTApplyToItem:(BOOL)isEBTApply {
    self.itemInfoDataObject.EBT = @(isEBTApply);
}
- (void)minStockLevel:(NSNumber *)MinStock {
    self.itemInfoDataObject.MinStockLevel = MinStock;
}
- (void)maxStockLevel:(NSNumber *)MaxStock{
    self.itemInfoDataObject.MaxStockLevel = MaxStock;
}
- (void)parentItemSelected:(NSNumber *) CITM_Code {
    self.itemInfoDataObject.CITM_Code = CITM_Code;
}
- (void)childQtyForItem:(NSNumber *)ChildQty {
        self.itemInfoDataObject.ChildQty = ChildQty;
}
- (void)didRemoveParentItem {
    self.itemInfoDataObject.CITM_Code = @0;
    self.itemInfoDataObject.ChildQty = @0;
}

#pragma mark - Save Item -
-(IBAction)btnSaveItemClicked:(id)sender{
    [Appsee addEvent:kRIMFooterSaveItem];
    [self.rmsDbController playButtonSound];
    [self.view endEditing:YES];
    
    NSString * strDuplicateUPC = [self validateAndGetDuplicateBarcode];

    if([NSString trimSpacesFromStartAndEnd:self.itemInfoDataObject.ItemName].length == 0) {
        [self showAlerView:@"Please enter name"];
        return;
    }
    else if ([NSString trimSpacesFromStartAndEnd:self.itemInfoDataObject.Barcode].length == 0) {
        [self showAlerView:@"Please enter UPC / barcode"];
        return;
    }
    else if ([self isDiscountInComplete]) {
        [self showAlerView:@"Please enter discount quantity and price"];
        return;
    }
    else if ([self isMixMatchInComplete]) {
        [self showAlerView:@"Please enter mix match discount scheme"];
        return;
    }
    else if (strDuplicateUPC.length > 0) {
        [self showAlerView:[NSString stringWithFormat:@"%@ Barcode type contains duplication barcodes.",strDuplicateUPC]];
        return;
    }
    else if ([self.itemInfoDataObject.TaxType isEqualToString:@"Tax wise"]) {
        if (self.itemInfoDataObject.itemtaxarray == nil || self.itemInfoDataObject.itemtaxarray.count == 0) {
            [self showAlerView:@"Please select at least one tax."];
            return;
        }
    }

//    else if ([self.itemInfoDataObject.PriceScale isEqualToString:@"APPPRICE"]) {
//        if ([self isAppropreateCostInComplete]) {
//            [self showAlerView:@"Please enter Retail Cost"];
//            return;
//        }
//        else if ([self isAppropreatePriceInComplete]) {
//            [self showAlerView:@"Please enter Retail Price"];
//            return;
//        }
//
//    }
//        else if ([self.priceScale isEqualToString:@"WSCALE"])
//        {
//            if ([self isWeightScaleInComplete])
//            {
//                [self showAlerView:@"Please enter weight scale qty and type"];
//                return;
//            }
//        }
    else if ([self isPriceLowerThanCost]) {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
            [self inserOrUpdateItemDetail];
        };
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action) {
            
        };
        NSString * strMessage = [NSString stringWithFormat:@"%@ Price of the product is lower than the cost of the product. Do you want to continue ?",[self getPackageTypePriceLowerThanCost]];
        [self.rmsDbController popupAlertFromVC:self title:@"Warning" message:strMessage buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        return;
    }
    [self inserOrUpdateItemDetail];
}
-(void)inserOrUpdateItemDetail{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    
    if(flgUpdate) {
        
        if([self.strTempBarcodeSave isEqualToString:self.itemInfoDataObject.Barcode]) {
            [self getItemUpdatesAndCallWebService];
        }
        else{
            if(self.itemInfoDataObject.IsduplicateUPC) {
                [self getItemUpdatesAndCallWebService];
            }
            else{
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription
                                               entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
                fetchRequest.entity = entity;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcode==%@ AND itemCode != %@", self.itemInfoDataObject.Barcode,self.itemInfoDataObject.ItemId];
                fetchRequest.predicate = predicate;
                
                NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
                if (resultSet.count == 0) {
                    [self getItemUpdatesAndCallWebService];
                }
                else{
                    [_activityIndicator hideActivityIndicator];
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"UPC is already exists." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    self.itemInfoDataObject.Barcode = @"";
                    [itemInfoVC.tblItemInfo reloadData];
                }
            }
        }
    }
    else{
        if(self.itemInfoDataObject.IsduplicateUPC) {
            [self getItemInsertAndCallWebService];
        }
        else{
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
            fetchRequest.entity = entity;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcode==%@ AND itemCode != %@", self.itemInfoDataObject.Barcode,self.itemInfoDataObject.ItemId];
            fetchRequest.predicate = predicate;
            
            NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
            if (resultSet.count == 0) {
                [self getItemInsertAndCallWebService];
            }
            else{
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"UPC is already exists." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
                self.itemInfoDataObject.Barcode = @"";
                [itemInfoVC.tblItemInfo reloadData];
            }
        }
    }
}
-(BOOL)isDiscountInComplete{
    BOOL isInComplete = NO;
    NSMutableArray *discountList = self.itemInfoDataObject.discountDetailsArray;
    if(discountList.count > 0) {
        for(int isDisc=0; isDisc<discountList.count;isDisc++) {
                NSMutableDictionary *discountDictionary = [discountList[isDisc] mutableCopy ];
                
                NSNumber *disUnitPrice = [discountDictionary valueForKey:@"DIS_UnitPrice"];
                NSNumber *disQty = [discountDictionary valueForKey:@"DIS_Qty"];
                if(disUnitPrice == nil || disQty == nil ) {
                    isInComplete = YES;
                    break;
                }
        }
    }
    return isInComplete;
}
-(BOOL)isMixMatchInComplete{
    BOOL isMixMatchInComplete = NO;
    if (selectedDiscount == 1) {
        if([self.mixMatchFlg isEqualToString:@"1"] && ([self.mixMatchId isEqualToString:@"0"])) {
            return isMixMatchInComplete = YES;
        }
        else if ([self.cate_MixMatchFlg isEqualToString:@"1"] && ([self.cate_MixMatchId isEqualToString:@"0"])) {
            return isMixMatchInComplete = YES;
        }
    }
    return isMixMatchInComplete;
}
-(BOOL)isPriceLowerThanCost{
    BOOL isPriceLoverThanCost = NO;
    for (NSDictionary * dictPriceInfo in self.itemInfoDataObject.itemPricingArray) {
        if ([[dictPriceInfo valueForKey:@"Cost"] floatValue]>[[dictPriceInfo valueForKey:@"UnitPrice"] floatValue]) {
            isPriceLoverThanCost = TRUE;
            break;
        }
    }
    return isPriceLoverThanCost;
}
-(NSString *)getPackageTypePriceLowerThanCost{
    NSString * isPriceLoverThanCost = @"";
    for (NSDictionary * dictPriceInfo in self.itemInfoDataObject.itemPricingArray) {
        if ([[dictPriceInfo valueForKey:@"Cost"] floatValue]>[[dictPriceInfo valueForKey:@"UnitPrice"] floatValue]) {
            isPriceLoverThanCost = [dictPriceInfo valueForKey:@"PriceQtyType"];
            break;
        }
    }
    return isPriceLoverThanCost;
}
- (void)getItemUpdatesAndCallWebService{ // Update web service
    self.itemUpdate = [self getInsertProcessData];
    NSLog(@"%@",[self.rmsDbController jsonStringFromObject:self.itemUpdate]);
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doUpdateProcessResponse:response error:error];
        });
    };
    
    self.itemUpdateWebServiceConnection = [self.itemUpdateWebServiceConnection initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:self.itemUpdate completionHandler:completionHandler];
}

- (void)getItemInsertAndCallWebService{ // Insert web service
    self.itemInsert = [self getInsertProcessData];
    [Appsee addEvent:kRIMItemInsertWebServiceCall];
     NSLog(@"%@",[self.rmsDbController jsonStringFromObject:self.itemInsert]);
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doInsertProcessResponse:response error:error];
        });
    };
    
    self.itemInsertWebServiceConnection = [self.itemInsertWebServiceConnection initWithRequest:KURL actionName:WSM_INV_ITEM_INSERT params:self.itemInsert completionHandler:completionHandler];

}

- (NSMutableDictionary *) getInsertProcessData{
    NSMutableDictionary * addItemDataDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * itemDetails = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    NSMutableArray * arrItemMain = [self ItemMain];
    itemDetailDict[@"ItemMain"] = arrItemMain;
    
    [self addAndDeleteBarcodeDetail:itemDetailDict];
    
    [self itemPriceingAndItemVariationsData:itemDetailDict];
    
//    [itemDetailDict setObject:[self ItemTaxData] forKey:@"ItemTaxData"];
    [self ItemTaxData:itemDetailDict];
    
    [self ItemSupplierData:itemDetailDict];
    

    [self ItemTagData:itemDetailDict];
    
    [self itemDiscountData:itemDetailDict];
    
    NSMutableArray *ticketArray = [[NSMutableArray alloc]init];
    
    if (self.itemInfoDataObject.changeItemTicketInfo || !flgUpdate) {
        NSMutableDictionary * dictItemTicket = self.itemInfoDataObject.itemTicketInfo;
        
        if (dictItemTicket.allKeys.count>0) {
            ticketArray = [[NSMutableArray alloc]initWithObjects:dictItemTicket, nil];
        }
        
        itemDetailDict[@"ItemTicketArray"] = ticketArray;
    }
    else {
        itemDetailDict[@"ItemTicketArray"] = [[NSArray alloc]init];
    }
    
    
    [itemDetails addObject:itemDetailDict];
    addItemDataDic[@"ItemData"] = itemDetails;
    
    return addItemDataDic;
}
-(NSString *)validateAndGetDuplicateBarcode {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemBarCode_Md" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSArray *barcodeList = [self.itemInfoDataObject.arrItemAllBarcode valueForKey:@"Barcode"];
    if (!barcodeList) {
        return @"";
    }
    NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barCode IN %@ AND itemCode != %@", barcodeList,self.itemInfoDataObject.ItemId];
    fetchRequest.predicate = barcodePredicate;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if(resultSet.count > 0) {
        for (ItemBarCode_Md *anBarcode in resultSet) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Barcode == %@", anBarcode.barCode];
            NSArray *isBarcodeResult = [self.itemInfoDataObject.arrItemAllBarcode filteredArrayUsingPredicate:predicate];
            isBarcodeResult.firstObject [@"isExist"] = @"YES";
        }
    }
    return [self.itemInfoDataObject getDuplicateBarcodenumber];
}
-(void)addAndDeleteBarcodeDetail:(NSMutableDictionary *)itemDetailDict {
    itemDetailDict[@"AddedBarcodesArray"] = self.itemInfoDataObject.arrAddedBarcodeList;
    itemDetailDict[@"DeletedBarcodesArray"] = self.itemInfoDataObject.arrDeletedBarcodeList;
}
- (NSMutableArray *) ItemMain{
    NSMutableArray *itemMain = [[NSMutableArray alloc] init];
    NSMutableDictionary *itemDataDict;
    
    if (flgUpdate) {
        itemDataDict = self.itemInfoDataObject.itemMainUpdateData;
        
        itemDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        
        NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
        itemDataDict[@"UserId"] = userID;
        
        
        if(self.isImageSet) {
            imageData = UIImageJPEGRepresentation(self.itemInfoDataObject.selectedImage, 0);
            if(imageData) {
                itemDataDict[@"ItemImage"] = [imageData base64EncodedStringWithOptions:0];
            }
        }
        if (IsImageDeleted) {
            itemDataDict[@"IsImageDeleted"] = @(IsImageDeleted);
        }
        if(self.itemInfoDataObject.isPass) {
            itemDataDict[@"IsTicket"] = @"1";
        }
        else{
            itemDataDict[@"IsTicket"] = @"0";
        }
        NSArray * arrKeys = itemDataDict.allKeys;
        for (NSString * strKey in arrKeys) {
            [itemMain addObject:@{@"Key":strKey,@"Value":[itemDataDict valueForKey:strKey]}];
        }
    }
    else{
        itemDataDict = self.itemInfoDataObject.itemMainInsertData;
        
        if([self.itemInfoDataObject.duplicateUPCItemCodes isEqualToString:@""]) {
            [itemDataDict setValue:@"" forKey:@"duplicateUPCItemCodes"]; // for duplicate barcode
        }
        else{
            [itemDataDict setValue:self.itemInfoDataObject.duplicateUPCItemCodes forKey:@"duplicateUPCItemCodes"]; // for duplicate barcode
        }
        
        itemDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
        itemDataDict[@"UserId"] = userID;
        
        itemDataDict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
        
        [itemDataDict setValue:self.itemInfoDataObject.Barcode forKey:@"DefaultBarcode"];
        
        if(self.isImageSet) {
            imageData = UIImageJPEGRepresentation(self.itemInfoDataObject.selectedImage, 0);
            if(imageData) {
                itemDataDict[@"ItemImage"] = [imageData base64EncodedStringWithOptions:0];
            }
            else{
                itemDataDict[@"ItemImage"] = @"";
            }
            itemDataDict[@"IsImageDeleted"] = @(IsImageDeleted);
        }
        else{
            
            itemDataDict[@"ItemImage"] = @"";
            itemDataDict[@"IsImageDeleted"] = @(IsImageDeleted);
        }
        if(self.itemInfoDataObject.isPass) {
            itemDataDict[@"IsTicket"] = @"1";
            
        }
        else{
            itemDataDict[@"IsTicket"] = @"0";
        }
        [itemMain addObject:itemDataDict];
    }
    
    return itemMain;
}

-(void)itemPriceingAndItemVariationsData:(NSMutableDictionary *)itemDetailDict{

    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    self.currentDateTime = [formatter stringFromDate:date];
    itemDetailDict[@"Updatedate"] = self.currentDateTime;

    [self setItemVariationItemData];
    
    self.itemVariationMasterData = [[NSMutableArray alloc] init ];
    if(self.itemInfoDataObject.itemVariationData1.count > 0) {
        [self.itemVariationMasterData addObjectsFromArray:self.itemInfoDataObject.itemVariationData1 ];
    }
    if(self.itemInfoDataObject.itemVariationData2.count > 0) {
        [self.itemVariationMasterData addObjectsFromArray:self.itemInfoDataObject.itemVariationData2 ];
    }
    if(self.itemInfoDataObject.itemVariationData3.count > 0) {
        [self.itemVariationMasterData addObjectsFromArray:self.itemInfoDataObject.itemVariationData3 ];
    }
    if (flgUpdate) {
        
        //added by vishal lakum
        
        NSMutableDictionary *pricingDetail = [[NSMutableDictionary alloc] initWithDictionary:itemDetailDict copyItems: YES];
        //        ItemPriceSingle
        
        NSMutableArray * itemPriceSingleChanged = (self.itemInfoDataObject).changedItemPricingSingle;
        pricingDetail[@"ItemPriceSingle"] = itemPriceSingleChanged;
        //        ItemPriceCase
        
        NSMutableArray * itemPriceCaseChanged = (self.itemInfoDataObject).changedItemPricingCase;
        pricingDetail[@"ItemPriceCase"] = itemPriceCaseChanged;
        //        ItemPricePack
        
        NSMutableArray * itemPricePackChanged = (self.itemInfoDataObject).changedItemPricingPack;
        pricingDetail[@"ItemPricePack"] = itemPricePackChanged;
        
        if([self.itemInfoDataObject.PriceScale isEqualToString:@"APPPRICE"]) {
            if (pricingDetail) {
                [itemDetailDict addEntriesFromDictionary: pricingDetail];
            }
        }
        else if([self.itemInfoDataObject.PriceScale isEqualToString:@"WSCALE"]) {
            // Weight Scale Data
            //        ItemPriceSingle
            NSMutableArray * itemPriceSingleChanged = self.itemInfoDataObject.getChangedItemWeightScalePricingSingle;
            itemDetailDict[@"ItemPriceSingle"] = itemPriceSingleChanged;
            //        ItemPriceCase
            NSMutableArray * itemPriceCaseChanged = self.itemInfoDataObject.getChangedItemWeightScalePricingCase;
            itemDetailDict[@"ItemPriceCase"] = itemPriceCaseChanged;
            //        ItemPricePack
            NSMutableArray * itemPricePackChanged = self.itemInfoDataObject.getChangedItemWeightScalePricingPack;
            itemDetailDict[@"ItemPricePack"] = itemPricePackChanged;
            
            itemDetailDict[@"VariationArray"] = self.itemInfoDataObject.itemVariationTypes;
            itemDetailDict[@"VariationItemArray"] = self.itemVariationMasterData;
        }
        else if([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) {
            itemDetailDict[@"VariationArray"] = self.itemInfoDataObject.itemVariationTypes;
            itemDetailDict[@"VariationItemArray"] = self.itemVariationMasterData;
        }
        else{
            if (pricingDetail) {
                [itemDetailDict addEntriesFromDictionary: pricingDetail];
            }
            itemDetailDict[@"VariationArray"] = self.itemInfoDataObject.itemVariationTypes;
            itemDetailDict[@"VariationItemArray"] = self.itemVariationMasterData;
        }
    }
    else {
        if([self.itemInfoDataObject.PriceScale isEqualToString:@"APPPRICE"]) {
            // Pricing Data
            
            itemDetailDict[@"ItemPrice"] = [self addDateInPricingArray:self.itemInfoDataObject.itemPricingArray];
            
            itemDetailDict[@"VariationArray"] = self.itemInfoDataObject.itemVariationTypes;
            itemDetailDict[@"VariationItemArray"] = self.itemVariationMasterData;
            
        }
        else if([self.itemInfoDataObject.PriceScale isEqualToString:@"WSCALE"]) {
            // Weight Scale Data
            itemDetailDict[@"ItemPrice"] = [self addDateInPricingArray:self.itemInfoDataObject.changedItemWeightScaleArray];
            
//            [itemDetailDict setObject:[self addDateInPricingArray:self.itemInfoDataObject.itemPricingArray] forKey:@"ItemPrice"];
            
            itemDetailDict[@"VariationArray"] = self.itemInfoDataObject.itemVariationTypes;
            itemDetailDict[@"VariationItemArray"] = self.itemVariationMasterData;
        }
        else if([self.itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) {
            // Pricing Data
            itemDetailDict[@"ItemPrice"] = [self addDateInPricingArray:self.itemInfoDataObject.itemPricingArray];
            
            itemDetailDict[@"VariationArray"] = self.itemInfoDataObject.itemVariationTypes;
            itemDetailDict[@"VariationItemArray"] = self.itemVariationMasterData;
        }
        else{
            // Pricing Data
            itemDetailDict[@"ItemPrice"] = [self addDateInPricingArray:self.itemInfoDataObject.itemPricingArray];
            
            itemDetailDict[@"VariationArray"] = self.itemInfoDataObject.itemVariationTypes;
            itemDetailDict[@"VariationItemArray"] = self.itemVariationMasterData;
        }
    }
}
-(NSMutableArray *)addDateInPricingArray:(NSMutableArray *) arrPricing{
    if (self.currentDateTime == nil || self.currentDateTime.length == 0) {
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        self.currentDateTime = [formatter stringFromDate:date];
    }
    for (int i = 0; i<arrPricing.count; i++) {
        arrPricing[i] [@"CreatedDate"] = self.currentDateTime;
    }
    return arrPricing;
}
- (void)ItemTaxData :(NSMutableDictionary *) itemDetailDict {
    
    if (flgUpdate) {
        //        addedItemTaxData
        NSMutableArray * itemaddedTax = self.itemInfoDataObject.changedItemAddedTaxArray;
        itemDetailDict[@"addedItemTaxData"] = itemaddedTax;
        //        DeletedItemTaxData
        //        NSMutableArray * itemdeletedTax = [self.itemInfoDataObject getChangedItemDeletedTaxArray];
        itemDetailDict[@"DeletedItemTaxIds"] = self.itemInfoDataObject.changedItemDeletedTaxArray;
    }
    else {
        NSMutableArray *itemTaxData = [[NSMutableArray alloc] init];
        NSMutableArray * arrTagList = self.itemInfoDataObject.itemtaxarray;
        if(arrTagList.count>0) {
            for (int isup=0; isup<arrTagList.count; isup++) {
                NSMutableDictionary *tmpSup=[arrTagList[isup] mutableCopy ];
                [tmpSup removeObjectForKey:@"Checked"];
                [tmpSup removeObjectForKey:@"PERCENTAGE"];
                [tmpSup removeObjectForKey:@"TAXNAME"];
                [itemTaxData addObject:tmpSup];
            }
        }
        itemDetailDict[@"ItemTaxData"] = itemTaxData;
    }
}

- (void)ItemSupplierData :(NSMutableDictionary *)itemDetailDict{
    if (flgUpdate) {
        //        addedItemSupplierData
        NSMutableArray * itemaddedSupplier = self.itemInfoDataObject.changedItemAddedSupplierarray;
        itemDetailDict[@"addedItemSupplierData"] = itemaddedSupplier;
        //        DeletedItemSupplierData
        NSMutableArray * itemdeletedSupplier = self.itemInfoDataObject.changedItemDeletedSupplierarray;
        itemDetailDict[@"DeletedItemSupplierData"] = itemdeletedSupplier;
    }
    else {
        NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
        NSMutableArray * arrSupplierData = self.itemInfoDataObject.itemsupplierarray;
        if(arrSupplierData.count>0) {
            for (int isup = 0; isup < arrSupplierData.count; isup++) {
                // Id,VendorId
                NSArray *SalesRepresentatives = [arrSupplierData[isup] valueForKey:@"SalesRepresentatives"];
                if(SalesRepresentatives.count > 0) {
                    for (int i = 0; i < SalesRepresentatives.count; i++) {
                        NSMutableDictionary *tmpSup = [SalesRepresentatives[i] mutableCopy ];
                        NSMutableDictionary *speDict = [tmpSup mutableCopy];
                        NSArray *removedKeys = @[@"VendorId",@"Id"]; // rename it from 'Id'
                        [speDict removeObjectsForKeys:removedKeys];
                        NSArray *speKeys = speDict.allKeys;
                        [tmpSup removeObjectsForKeys:speKeys];
                        [itemSupplierData addObject:tmpSup];
                    }
                }
                else{
                    NSMutableDictionary *tmpSup = [arrSupplierData[isup] mutableCopy ];
                    NSMutableDictionary *speDict = [tmpSup mutableCopy];
                    NSArray *removedKeys = @[@"VendorId"]; // rename it from 'Id'
                    [speDict removeObjectsForKeys:removedKeys];
                    NSArray *speKeys = speDict.allKeys;
                    [tmpSup removeObjectsForKeys:speKeys];
                    [tmpSup setValue:@"0" forKey:@"Id"]; // add value 'SUPId' those vender have no sales representative
                    [itemSupplierData addObject:tmpSup];
                }
            }
        }
        itemDetailDict[@"ItemSupplierData"] = itemSupplierData;
    }
}

- (void)ItemTagData:(NSMutableDictionary *) itemDetailDict {
    
    if (flgUpdate) {
        //        addedItemTag
        NSMutableArray * itemaddedTag = self.itemInfoDataObject.changedItemAddedTagArray;
        itemDetailDict[@"addedItemTag"] = itemaddedTag;

        itemDetailDict[@"DeletedItemTagIds"] = self.itemInfoDataObject.changedItemDeletedTagArray;
    }
    else {
        itemDetailDict[@"ItemTag"] = self.itemInfoDataObject.responseTagArray;
    }
}

- (void)itemDiscountData:(NSMutableDictionary *)itemDetailDict {

    if (flgUpdate) {
        //        addedItemDiscount
        NSMutableArray * itemaddedDiscount = self.itemInfoDataObject.changedItemAddedDiscountDetailsArray;
        itemDetailDict[@"addedItemDiscount"] = itemaddedDiscount;
        //        DeletedItemDiscount
        itemDetailDict[@"DeletedItemDiscountIds"] = self.itemInfoDataObject.changedItemDeletedDiscountDetailsArray;
    }
    else {
        NSMutableArray *discountData = [[NSMutableArray alloc] init ];
        NSMutableArray *discountList = self.itemInfoDataObject.discountDetailsArray;
        if(discountList.count > 0) {
            for(int isDisc=0; isDisc<discountList.count;isDisc++) {
                NSMutableDictionary *discountDictionary = discountList[isDisc];
                NSString *newRowId = [NSString stringWithFormat:@"%d",isDisc];
                [discountDictionary removeObjectForKey:@"UnitPriceWithTax"];
                [discountDictionary removeObjectForKey:@"applyTax"];
                NSNumber *disUnitPrice = [discountDictionary valueForKey:@"DIS_UnitPrice"];
                NSNumber *disQty = [discountDictionary valueForKey:@"DIS_Qty"];
                if(disUnitPrice != nil && disQty != nil ) {
                    [discountDictionary setValue:newRowId forKeyPath:@"RowId"];
                    [discountData addObject:discountDictionary];
                }
            }
        }
        
        itemDetailDict[@"ItemDiscount"] = discountData;
    }
}

#pragma mark - Save Item Validation -
-(BOOL)isAppropreateCostInComplete{
    BOOL isAppropreateCostInComplete = NO;
    if(self.itemInfoDataObject.itemPricingArray.count > 0) {
        for(int isDisc=0; isDisc<self.itemInfoDataObject.itemPricingArray.count;isDisc++) {
            NSMutableDictionary *discountDictionary = [(self.itemInfoDataObject.itemPricingArray)[isDisc] mutableCopy ];
            NSNumber *Cost = [discountDictionary valueForKey:@"Cost"];
            float Qty = [[discountDictionary valueForKey:@"Qty"] floatValue];
            if (Qty > 0) {
                if(Cost.floatValue == 0.00) {
                        isAppropreateCostInComplete = YES;
                        break;
                }
            }
        }
    }
    return isAppropreateCostInComplete;
}

-(BOOL)isAppropreatePriceInComplete{
    BOOL isAppropreatePriceInComplete = NO;
    if(self.itemInfoDataObject.itemPricingArray.count > 0) {
        for(int isDisc=0; isDisc<self.itemInfoDataObject.itemPricingArray.count;isDisc++) {
            NSMutableDictionary *discountDictionary = [(self.itemInfoDataObject.itemPricingArray)[isDisc] mutableCopy ];
            NSNumber *UnitPrice = [discountDictionary valueForKey:@"UnitPrice"];
            float Qty = [[discountDictionary valueForKey:@"Qty"] floatValue];
            if (Qty > 0) {
                if(UnitPrice.floatValue == 0.00 ) {
                    isAppropreatePriceInComplete = YES;
                    break;
                }
            }
        }
    }
    return isAppropreatePriceInComplete;
}

/*-(BOOL)isWeightScaleInComplete
{
    BOOL isWeightScaleInComplete = NO;
    if([itemWeightScaleArray count] > 0)
    {
        for(int isDisc=0; isDisc<[itemWeightScaleArray count];isDisc++)
        {
            NSMutableDictionary *discountDictionary = [[itemWeightScaleArray objectAtIndex:isDisc] mutableCopy ];
            NSNumber *Cost = [discountDictionary valueForKey:@"Cost"];
            NSNumber *Profit = [discountDictionary valueForKey:@"Profit"];
            NSNumber *UnitPrice = [discountDictionary valueForKey:@"UnitPrice"];
            NSNumber *Qty = [discountDictionary valueForKey:@"Qty"];
            if(([Cost floatValue] != 0.00 ) || ([Profit floatValue] != 0.00 ) || ([UnitPrice floatValue] != 0.00 ))
            {
                if([Qty floatValue] == 0 )
                {
                    isWeightScaleInComplete = YES;
                    break;
                }
            }
        }
    }
    return isWeightScaleInComplete;
}*/

-(void)showAlerView:(NSString *)alertMessage{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:alertMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}
#pragma mark - Update Item to Database -
- (void) doUpdateProcessResponse:(id)response error:(NSError *)error {
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            self.RetItemID = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
            deleteRecordId = self.RetItemID.integerValue;
            _btn_DeleteRecord.enabled = TRUE;
            self.retGroupId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"GroupId"]];
            
            // Add custom master
            NSMutableArray *customVariationMaster = [arrayRetString.firstObject valueForKey:@"lstVariationMaster"];
            NSPredicate *Predicate = [NSPredicate predicateWithFormat:@"vid != %@",@(0)];
            NSArray *arrayCount = [customVariationMaster filteredArrayUsingPredicate:Predicate];
            if(arrayCount.count > 0) {
                [self.itemUpdateManager insertCustomVariationMasterToCoreData:[arrayCount mutableCopy]];
            }
            
            // Add Size Master
            NSMutableArray *sizeMaster = [arrayRetString.firstObject valueForKey:@"lstSize"];
            if([sizeMaster isKindOfClass:[NSMutableArray class]] && sizeMaster.count > 0)
            {
                [self.itemUpdateManager updateSizeMasterToCoreData:[sizeMaster mutableCopy]];
            }
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Item Updated Successfully"};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                NSString * tempIndexPath = [self.dictNewOrderData valueForKey:@"indexpath"];
                
                self.dictNewOrderData = [[NSMutableDictionary alloc] init];
                [self.dictNewOrderData setValue:tempIndexPath forKey:@"indexpath"];
                
                NSMutableArray *arrayTemp  = [[self.itemUpdate valueForKey:@"ItemData"]valueForKey:@"ItemMain"];
                self.dictTemp = [[NSMutableDictionary alloc]init];
                self.dictTemp = [[arrayTemp.firstObject firstObject]mutableCopy ];
                [self.dictNewOrderData setValue:@"1" forKey:@"AddedQty"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"Barcode"] forKey:@"Barcode"];
                self.strTempBarcodeSave = [NSString stringWithFormat:@"%@",[self.dictTemp valueForKey:@"Barcode"]];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"CostPrice"] forKey:@"CostPrice"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"DepartId"] forKey:@"DepartId"];
                [self.dictNewOrderData setValue:self.itemInfoDataObject.DepartmentName forKey:@"DepartmentName"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"ItemId"] forKey:@"ItemId"];
                [self.dictNewOrderData setValue:[NSString stringWithFormat:@"%@",self.itemInfoDataObject.imageNameURL] forKey:@"ItemImage"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"ItemName"] forKey:@"ItemName"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"SalesPrice"] forKey:@"SalesPrice"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"availableQty"] forKey:@"avaibleQty"];
                
                [self.dictNewOrderData setValue:self.itemInfoDataObject.responseTagArray forKey:@"ItemTag"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"ProfitAmt"] forKey:@"ProfitAmt"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"ProfitType"] forKey:@"ProfitType"];
                
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"MaxStockLevel"] forKey:@"MaxStockLevel"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"MinStockLevel"] forKey:@"MinStockLevel"];
                [self.dictNewOrderData setValue:[self.dictTemp valueForKey:@"Remark"] forKey:@"Remark"];
                
                if(![self.itemInfoDataObject.duplicateUPCItemCodes isEqualToString:@""]) {
                    [self allowBarcodeDuplicationForItem]; // set Barcode Duplication Yes for allowed Item
                }
                
                if([[self.dictTemp valueForKey:@"CateId"] isEqualToString:@"-1"]) {
                    [self addCustomGroupName];
                }
                
                if(self.isImageSet) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self updateDataInDataBase_RIM];
                    });
                }
                else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self updateDataInDataBase_RIM];
                    });
                }
            }
            else if ([[response  valueForKey:@"IsError"] intValue] == -2) {
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n UPC is already exists"};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Error code : 104 \n UPC is already exists" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                self.itemInfoDataObject.Barcode = @"";
            }
            else{
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Error code : 104 \n Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}

-(void)updateDataInDataBase_RIM{

    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
    [itemLiveUpdate setValue:@"Update" forKeyPath:@"Action"];
    [itemLiveUpdate setValue:[self.dictTemp valueForKey:@"ItemId"] forKey:@"Code"];
    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
    [itemLiveUpdate setValue:@"Item" forKey:@"Type"];
    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkAndRedirectToAppropreateView];
    });
}
-(void)checkAndRedirectToAppropreateView{
    [_activityIndicator hideActivityIndicator];
    if(self.NewOrderCalled) {
        if(IsPhone()) {
            self.rimsController.scannerButtonCalled = @"";
            
            [self.itemInfoEditVCDelegate ItemInfornationChangeAt:[(self.dictNewOrderData)[@"indexpath"]integerValue] WithNewData:self.dictNewOrderData];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            self.rimsController.scannerButtonCalled = @"";
            
            [self.itemInfoEditVCDelegate ItemInfornationChangeAt:[(self.dictNewOrderData)[@"indexpath"]integerValue] WithNewData:self.dictNewOrderData];
            [self dismissSplitter:nil];
        }
    }
    else{
        if(IsPad()) {
            [self dismissSplitter:nil];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    // Call Update Tag service in BackGround
    [self getTagListUpadated_RIM];
}

-(void)getTagListUpadated_RIM{
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:self.currentDateTime forKey:@"datetime"];
    [param setValue:self.RetItemID forKey:@"ItemCode"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self responseItemTag_RIMResponse:response error:error];
    };

    self.updatedItemWC = [self.updatedItemWC initWithRequest:KURL actionName:WSM_UPDATE_TAG_LIST params:param completionHandler:completionHandler];
}
-(void)responseItemTag_RIMResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSArray *responseArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            NSDictionary *responseDictionary = responseArray.firstObject;
            if (responseDictionary != nil) {
                
                self.SizeArray = [responseDictionary valueForKey:@"SizeArray"];
                
                // Delete Sizemaster from DB
                for (int i=0; i<self.SizeArray.count; i++) {
                    NSMutableDictionary *dict = (self.SizeArray)[i];
                    [self deleteSizemaster:dict[@"SizeId"]];
                }
                
                // Insert Updated Sizemaster to DB
                NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                
                if (self.SizeArray.count>0) {
                    [self.itemUpdateManager insertSizeMaster:self.SizeArray moc:privateManagedObjectContext];
                }
                [UpdateManager saveContext:privateManagedObjectContext];
            }

        }
    }
}
// DELETE TAG / SIZE MASTERS FOR THE UPDATED ITEM
-(void)deleteSizemaster :(NSString *)strSizeId{
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SizeMaster" inManagedObjectContext:privateManagedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sizeId==%d", strSizeId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *arryTemp = [UpdateManager executeForContext:privateManagedObjectContext FetchRequest:fetchRequest];
    for (NSManagedObject *product in arryTemp) {
        [UpdateManager deleteFromContext:privateManagedObjectContext object:product];
    }
    [UpdateManager saveContext:privateManagedObjectContext];
}
#pragma mark - Insert Item to Database -
- (void) doInsertProcessResponse:(id)response error:(NSError *)error{
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            self.RetItemID = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
            deleteRecordId = self.RetItemID.integerValue;
            _btn_DeleteRecord.enabled = TRUE;
            self.retGroupId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"GroupId"]];
            
            // Add custom master
            NSMutableArray *customVariationMaster = [arrayRetString.firstObject valueForKey:@"lstVariationMaster"];
            NSPredicate *Predicate = [NSPredicate predicateWithFormat:@"vid != %@",@(0)];
            NSArray *arrayCount = [customVariationMaster filteredArrayUsingPredicate:Predicate];
            if(arrayCount.count > 0) {
                [self.itemUpdateManager insertCustomVariationMasterToCoreData:[arrayCount mutableCopy]];
            }
            // Add Size Master
            NSMutableArray *sizeMaster = [arrayRetString.firstObject valueForKey:@"lstSize"];
            if([sizeMaster isKindOfClass:[NSMutableArray class]] && sizeMaster.count > 0)
            {
                [self.itemUpdateManager updateSizeMasterToCoreData:[sizeMaster mutableCopy]];
            }
            if ([[response  valueForKey:@"IsError"] intValue] == 0) {
                NSDictionary *updateDict = @{kRIMItemInsertWebServiceResponseKey : @"Item Inserted Successfully"};
                [Appsee addEvent:kRIMItemInsertWebServiceResponse withProperties:updateDict];
                self.clickedButton=@"";
                NSMutableArray *arrayTemp  = [[self.itemInsert valueForKey:@"ItemData"]valueForKey:@"ItemMain"];
                self.dictTemp = [[NSMutableDictionary alloc] init];
                self.dictTemp = [[arrayTemp.firstObject firstObject] mutableCopy ];
                
                NSMutableDictionary *dictInsertNewOrder = [[[NSMutableDictionary alloc] init] mutableCopy ];
                [dictInsertNewOrder setValue:@"1" forKey:@"AddedQty"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"Barcode"] forKey:@"Barcode"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"CostPrice"] forKey:@"CostPrice"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"DepartId"] forKey:@"DepartId"];
                //[dictInsertNewOrder setValue:lblItemdept.text forKey:@"DepartmentName"];
                [dictInsertNewOrder setValue:self.RetItemID forKey:@"ItemId"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"ItemImage"] forKey:@"ItemImage"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"ItemName"] forKey:@"ItemName"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"SalesPrice"] forKey:@"SalesPrice"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"availableQty"] forKey:@"avaibleQty"];
                //[dictInsertNewOrder setValue:responseTagArray forKey:@"ItemTag"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"ProfitAmt"] forKey:@"ProfitAmt"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"ProfitType"] forKey:@"ProfitType"];
                //[dictInsertNewOrder setValue:discountDetailsArray forKey:@"ItemDiscount"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"MaxStockLevel"] forKey:@"MaxStockLevel"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"MinStockLevel"] forKey:@"MinStockLevel"];
                [dictInsertNewOrder setValue:[self.dictTemp valueForKey:@"Remark"] forKey:@"Remark"];
                
                if([[self.dictTemp valueForKey:@"CateId"] isEqualToString:@"-1"]) {
                    [self addCustomGroupName];
                }
                if(![self.itemInfoDataObject.duplicateUPCItemCodes isEqualToString:@""]) {
                    [self allowBarcodeDuplicationForItem]; // set Barcode Duplication Yes for allowed Item
                }
                
                if (self.isWaitForLiveUpdate) {
                    
                    NSMutableArray *arrToStoreDict = [[[NSMutableArray alloc] init] mutableCopy];
                    [arrToStoreDict addObject:dictInsertNewOrder];
                    
                    self.manualEntryAddItem =arrToStoreDict;
                    
                    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
                    [itemLiveUpdate setValue:@"Insert" forKeyPath:@"Action"];
                    [itemLiveUpdate setValue:[self.manualEntryAddItem.firstObject valueForKey:@"ItemId"] forKey:@"Code"];
                    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
                    [itemLiveUpdate setValue:@"Item" forKey:@"Type"];
                    [self doManualEntryNewItem:itemLiveUpdate];
                }
                else {
                    [_activityIndicator hideActivityIndicator];
                    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
                    [itemLiveUpdate setValue:@"Insert" forKeyPath:@"Action"];
                    [itemLiveUpdate setValue:[self.dictTemp valueForKey:@"ItemId"] forKey:@"Code"];
                    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
                    [itemLiveUpdate setValue:@"Item" forKey:@"Type"];
                    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
                    
                    flgUpdate = TRUE;
                    self.strTempBarcodeSave = self.itemInfoDataObject.Barcode;
                    self.itemInfoDataObject.ItemId =  @(self.RetItemID.intValue);
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self responseAddInvnetoryDataVC];
                    });
                    [self.itemInfoEditVCDelegate ItemInfornationChangeAt:-1 WithNewData:dictInsertNewOrder];
                    [self dismissSplitter:nil];
                }
            }
            else if ([[response  valueForKey:@"IsError"] intValue] == -2) {
                [_activityIndicator hideActivityIndicator];
                NSDictionary *updateDict = @{kRIMItemInsertWebServiceResponseKey : @"Error code : 103 \n UPC already exits."};
                [Appsee addEvent:kRIMItemInsertWebServiceResponse withProperties:updateDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Item not Added" message:@"Error code : 103 \n UPC already exits." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else{
                [_activityIndicator hideActivityIndicator];
                NSDictionary *updateDict = @{kRIMItemInsertWebServiceResponseKey : @"Item not Added"};
                [Appsee addEvent:kRIMItemInsertWebServiceResponse withProperties:updateDict];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Error code : 103 \n Item not Added" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}
- (void)addCustomGroupName{
    NSArray *groupInsert = @[@{@"GroupId": @(self.retGroupId.integerValue),@"GroupName": [self.dictTemp valueForKey:@"GroupName"]} ];
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    [self.itemUpdateManager insertGroupMaster:groupInsert moc:privateManagedObjectContext];
    [UpdateManager saveContext:privateManagedObjectContext];
}
-(void)allowBarcodeDuplicationForItem{ // 1,2,3
    NSManagedObjectContext *privateManagedObjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSArray *itemCodeArray = [self.itemInfoDataObject.duplicateUPCItemCodes componentsSeparatedByString:@","];
    for (NSString *itemCode in itemCodeArray) {
        Item *item = [self fetchAllItems:itemCode moc:privateManagedObjectContext];
        item.isDuplicateBarcodeAllowed = @(1);
    }
    [UpdateManager saveContext:privateManagedObjectContext];
}
-(void)responseAddInvnetoryDataVC{//:(NSNotification *)notification
    if(IsPad()) {
    }
    else{
//        [self.rimsController.objInvenMgmt callNotification]; // calling this mehtod for iphone update
    }
    // Call Update Tag service in BackGround
    [self getTagListUpadated_RIM];
}
#pragma mark - Manual Entry Of New Item -
-(void)doManualEntryNewItem:(NSMutableDictionary *)dictItem{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    self.strUpdateType=[dictItem valueForKey:@"Action"];
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[dictItem valueForKey:@"Code"] forKey:@"Code"];
    [itemparam setValue:@"" forKey:@"Type"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ManualEntryliveUpdateResponse:response error:error];
        });
    };
    
    self.manualEntryliveUpdateConnection = [self.manualEntryliveUpdateConnection initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
}

- (void)ManualEntryliveUpdateResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSMutableArray *responseData = [self.rmsDbController objectFromJsonString:response[@"Data"]];
                if(responseData.count > 0)
                {
                    NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                    if([self.strUpdateType isEqualToString:@"Insert"]) {
                        [self.itemUpdateManager liveUpdateFromResponseDictionary:responseDictionary];
                        
                        NSString *strImagePath = [[[responseDictionary valueForKey:@"ItemArray"]firstObject]valueForKey:@"Item_ImagePath"];
                        self.manualEntryAddItem.firstObject[@"ItemImage"] = strImagePath;
                        [self.itemInfoEditVCDelegate ItemInfornationChangeAt:-1 WithNewData:self.manualEntryAddItem];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self dismissSplitter:nil];
                        });
                    }
                }
            }
            else if([[response valueForKey:@"IsError"] intValue] == -1) {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}
-(void)checkBarcodeArrayIsAlloc{
    if(self.itemInfoDataObject.arrItemAllBarcode == nil) {
        self.itemInfoDataObject.arrItemAllBarcode = [[NSMutableArray alloc] init ];
    }
}
// Configure Price At Pos in Pricing Section

-(BOOL)isRestaurentActive{
    BOOL isRestaurentActive = FALSE;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSPredicate *restaurentActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ || ModuleCode == %@",@"RRRCR",@"RRCR"];
    NSArray *restaurentArray = [activeModulesArray filteredArrayUsingPredicate:restaurentActive];
    if (restaurentArray.count > 0 ) {
        isRestaurentActive = TRUE;
    }
    else{
        isRestaurentActive = FALSE;
    }
    return isRestaurentActive;
}

-(BOOL)isSubDepartmentActive
{
    BOOL isSubdepart = FALSE;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSPredicate *restaurentActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@", @"RCR",@"RCRGAS",@"RRRCR",@"RRCR"];
    NSArray *restaurentArray = [activeModulesArray filteredArrayUsingPredicate:restaurentActive];
    if (restaurentArray.count > 0)
    {
        NSString * moduleCode = [[restaurentArray valueForKey:@"ModuleCode"]firstObject];
        if ([moduleCode isEqualToString:@"RCR"] && [configuration.subDepartment isEqual:@(1)]) {
            isSubdepart = TRUE;
        }
        else if ([moduleCode isEqualToString:@"RRRCR"] && [configuration.subDepartment isEqual:@(1)]) {
            isSubdepart = TRUE;
        }
        else if([moduleCode isEqualToString:@"RCRGAS"])
        {
            isSubdepart= FALSE;
        }
        else if([moduleCode isEqualToString:@"RRCR"])
        {
            isSubdepart = TRUE;
        }
       
    }
    else if([configuration.subDepartment isEqual:@(1)]){
        isSubdepart = TRUE;
    }
    else{
        isSubdepart = FALSE;
    }
    return isSubdepart;

}

-(void)getItemMultipleBarcode{
    NSManagedObjectContext *context = self.managedObjectContext;
    Item *anItem = [self fetchAllItems:[NSString stringWithFormat:@"%@",(self.itemInfoDataObject.ItemId).stringValue] moc:context];
    self.itemInfoDataObject.arrItemAllBarcode = [[NSMutableArray alloc]init];
    for (ItemBarCode_Md *barcode in anItem.itemBarcodes) {
        if([barcode.isBarcodeDeleted  isEqual: @(0)]) {
            NSMutableDictionary *barcodeDict = [[NSMutableDictionary alloc]init];
            barcodeDict[@"Barcode"] = barcode.barCode;
            barcodeDict[@"PackageType"] = barcode.packageType;
            barcodeDict[@"IsDefault"] = barcode.isDefault.stringValue;
            barcodeDict[@"isExist"] = @"";
            barcodeDict[@"notAllowItemCode"] = @"";
            if([barcode.isDefault  isEqual: @(1)]) {
                self.itemInfoDataObject.Barcode = barcode.barCode;
            }
            [self.itemInfoDataObject.arrItemAllBarcode addObject:barcodeDict];
        }
    }
    [self.itemInfoDataObject createDuplicateItemBarcodeArray];
}
- (Item*)fetchAllItems :(NSString *)itemId moc:(NSManagedObjectContext *)moc{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    if (resultSet.count>0) {
        item=resultSet.firstObject;
    }
    return item;
}
-(NSMutableArray *)makeVariationArray{
    NSMutableDictionary *dictOptionMain;
    NSMutableArray *arrayM = [[NSMutableArray alloc]init];
    for(int i=0;i<self.itemInfoDataObject.arrayVariation.count;i++) {
        NSMutableDictionary *dict = [(self.itemInfoDataObject.arrayVariation)[i]mutableCopy];
        NSMutableArray *arrayTemp = [[dict valueForKey:@"variationsubArray"]mutableCopy];
        if(arrayTemp.count>0) {
            dictOptionMain = [[NSMutableDictionary alloc]init];
            dictOptionMain[@"ColPosNo"] = [dict valueForKey:@"ColPosNo"];
            dictOptionMain[@"Id"] = [dict valueForKey:@"ColPosNo"];
            dictOptionMain[@"VariationId"] = [dict valueForKey:@"varianceId"];
            dictOptionMain[@"VariationName"] = [dict valueForKey:@"variationName"];
            [arrayM addObject:[dictOptionMain mutableCopy]];
        }
    }
    return arrayM;
}
-(NSMutableArray *)makeVariationItemArray{
    NSMutableDictionary *dictOptionMain;
    NSMutableArray *arrayMD = [[NSMutableArray alloc]init];
    NSMutableArray *arrayVariation = [self.itemInfoDataObject.arrayVariation mutableCopy];
    for(int i=0;i<arrayVariation.count;i++) {
        NSMutableDictionary *dict = [arrayVariation[i]mutableCopy];
        NSMutableArray *arrayTemp = [[dict valueForKey:@"variationsubArray"]mutableCopy];
        for(int j=0;j<arrayTemp.count;j++) {
            dictOptionMain = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *dictoption = [arrayTemp[j]mutableCopy];
            dictOptionMain[@"RowPosNo"] = [dictoption valueForKey:@"RowPosNo"];
            dictOptionMain[@"Id"] = [dict valueForKey:@"ColPosNo"];
            dictOptionMain[@"Name"] = [dictoption valueForKey:@"Value"];
            dictOptionMain[@"Cost"] = [dictoption valueForKey:@"Cost"];
            dictOptionMain[@"Profit"] = [dictoption valueForKey:@"Profit"];
            dictOptionMain[@"UnitPrice"] = [dictoption valueForKey:@"UnitPrice"];
            dictOptionMain[@"PriceA"] = [dictoption valueForKey:@"PriceA"];
            dictOptionMain[@"PriceB"] = [dictoption valueForKey:@"PriceB"];
            dictOptionMain[@"PriceC"] = [dictoption valueForKey:@"PriceC"];
            dictOptionMain[@"ApplyPrice"] = [dictoption valueForKey:@"ApplyPrice"];
            [arrayMD addObject:[dictOptionMain mutableCopy]];
        }
    }
    return  arrayMD;
}
-(IBAction)btn_HomeScreen:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)createsupplierList{
    [itemInfoVC didChangeSupplier:self.itemInfoDataObject.itemsupplierarray];
}
#pragma mark - didChangeSupplierPagePO -
- (void)didChangeSupplierPagePO:(NSMutableArray *)SupplierListArray withOtherData:(NSDictionary *) dictInfo {
    if (self.itemInfoDataObject==nil) {
        self.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
    }
    self.itemInfoDataObject.itemsupplierarray=[SupplierListArray mutableCopy];
    [self createsupplierList];
}
@end
