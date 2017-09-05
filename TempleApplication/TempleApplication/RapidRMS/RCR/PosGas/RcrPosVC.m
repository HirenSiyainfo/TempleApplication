//
//  RcrPosVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 30/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//
#import "RapidWebViewVC.h"
#import "RcrPosVC.h"
#import "RmsDbController.h"
#import "RcrController.h"
#import "FlowerMenuView.h"
#import "FlowerMenu.h"
#import "DepartmetCollectionVC.h"
#import "ItemDisplayViewController.h"
#import "TenderItemTableCustomCell.h"
#import "TenderViewController.h"
#import "RecallViewController.h"
#import "POmenuListVC.h"
#import "RimMenuVC.h"
#import "PosMenuVC.h"
#import "LastInvoiceReceiptPrint.h"
#import "LastGasInvoiceReceiptPrint.h"
#import "LastPostpayGasInvoiceReceiptPrint.h"
#import "CardReceiptPrint.h"
/*#import "Bill.h"
 #import "BillItem.h"
 #import "BillAmountComponents.h"*/

#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "SubDepartment+Dictionary.h"
#import "BillAmountCalculator.h"
#import "TopUpDiscountVC.h"
#import "HoldTransactionVC.h"
#import "Keychain.h"
#import "UpdateManager.h"
#import "GroupMaster+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"
#import "ItemSwipeEditVC.h"
#import "FavouriteCollectionVC.h"
#import "AgeVerificationVC.h"
#import "PriceAtPosVC.h"
#import "DropAmountVC.h"
#import "InvoiceDetail.h"
#import "ShiftInOutPopOverVC.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "MultipleItemBarcodeRingUpVC.h"
#import "CustomerViewController.h"
#import "LastInvoiceData+NSDictionary.h"
#import "NSArray+Methods.h"
#import "RasterDocument.h"
#import "StarBitmap.h"
#import "Item_Price_MD+Dictionary.h"
#import "ClockInDetailsView.h"
#import "CashinOutViewController.h"
#import "WieghtScalePriceAtPosVC.h"

#import "CKOCalendarViewController.h"
#import "RCR_MemoVC.h"
#import "RestaurantItem+Dictionary.h"
#import "RestaurantOrder+Dictionary.h"
#import "RestaurantOrderList.h"
#import "GiftCardPosVC.h"
#import "VariationSelectionVC.h"
#import "CameraScanVC.h"
#import "ShiftOpenCloseVC.h"

#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif
#import "HoldInvoice+Dictionary.h"
#import "NoSale+Dictionary.h"
#import "OfflineRecordVC.h"
#import "PosMenuItem.h"
#import "GiftCardPopUpVC.h"
#import "GiftCardCheckBalanceVC.h"
#import "RemoveTaxVC.h"
#import "RemoveTaxMessageVC.h"
#import "RCRSlideMenuVC.h"
#import "Configuration+Dictionary.h"
#import "ItemTicketValidation.h"
#import "PrintJob.h"
#import "CommonEnum.h"

#import "PassPrinting.h"
#import "RCRBillSummary.h"
#import "RapidCustomerLoyalty.h"
#import "PrinterFunctions.h"
#import "RasterPrintJob.h"
#import "TenderPay.h"
#import "SubDeptItemCollectionVC.h"
#import "AddDepartmentVC.h"
#import "AddSubDepartmentVC.h"
#import "ItemDetailEditVC.h"
#import "RapidInvoicePrint.h"
#import "RDiscountCalculator.h"
#import "DiscountBillDetailVC.h"
#import "NDHTMLtoPDF.h"
#import "DailyReportVC.h"
#import "ShiftReportDetailsVC.h"
#import "PrintJobBase.h"
#import "RasterPrintJobBase.h"
#import "RapidMultipleBarcodeRingUpHelper.h"
#import "Customer.h"
#import "ItemPackageTypeRingUpVC.h"
#import "CardTransactionRequestVC.h"
#import "InvoiceData_T+Dictionary.h"
#import "ItemInfoDataObject.h"
#import "DrawerStatus.h"


#define CANCEL_TRANSACTION_ALERT 923
#define VOID_TRANSACTION_ALERT 924
#define INVOICE_VIEW_TAG 937
#define DISCOUNT_VIEW_TAG 938
#define ITEM_SWIPE_EDIT_TAG 939
#define NEXT_PROCESS_TAG 944
#define REMOVETAX_VIEW_TAG 1225
#define EBT_VIEW_TAG 1230
#define REMOVE_CUSTOMER_NAME 965
#define NO_SALE 968
#define CARD_TRANSACTION_TAG 970



#define DEPARTMENT_FAVORITE_CONTAINER_HEIGHT 630

//#define CheckRights


typedef NS_ENUM(NSInteger, SHORTCUT_MENU_ITEM) {
    DASHBOARD_SHORTCUT,
    CLOCK_IN_OUT_SHORTCUT,
    SHIFT_IN_OUT_SHORTCUT,
    REPORT_SHORTCUT,
    PURCHASEORDER_SHORTCUT,
    INVENTORY_SHORTCUT,
    GASPUMP_SHORTCUT,
};

typedef NS_ENUM(NSInteger, LastPrintProcess) {
    LastInvoice_PrintBegin,
    LastInvoice_PassPrint,
    LastInvoice_CardPrint,
    LastInvoice_InvoicePrint,
    LastInvoice_PrintDone,
    LastInvoice_PrintCancel,
};

@interface RcrPosVC () <FlowerMenuDelegate, ItemRingupSelectionDelegate, DepartmetCollectionVcDelegate,TopUpDiscountDelegate,UpdateDelegate,
                        RecallDelegate,HoldTransactionDelegate,FavouriteCollectionDelegate,ItemSwipeEditDelegate,AgeVerificationDelegate,PriceAtPosDelegate,
                        DropAmountDelegate,TenderDelegate,InvoiceDetailDelegate,ShiftInOutPopOverDelegate,MultipleItemBarcodeRingUpDelegate,
                        CustomerSelectionDelegate,TenderItemTableCellDelegate,TenderShortCutDelegate,
                        WeightScalePriceAtPosDelegate,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate,RCR_MemoDelegate,NSFetchedResultsControllerDelegate,VariationSelectionDelegate
                        ,CameraScanVCDelegate,GiftCardPopUpDelegate,RemoveTaxDelegate,RemoveTaxPopUpMessageDelegate,LoginResultDelegate,RCRSlideMenuVCDelegate
                      ,ItemTicketValidationDelegate,GiftCardCheckBalancePosDelegate,PrinterFunctionsDelegate,SubDepartmetCollectionVcDelegate,SubDepartmetItemsVcDelegate,FavouriteCollectionCountDelegate,DepartmetCollectionCountDelegate,SubDepartmetCollectionCountDelegate,SubDepartmetItemsCountDelegate,EBTDelegate , DiscountBillDetailDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate , ItemPackageTypeRingUpDelegate , CardTransactionRequestVCDelegate >

{
    VariationSelectionVC *variationSelectionVC;
    BillAmountCalculator *billAmountCalculator;
    TopUpDiscountVC *topUpDiscountVC;
    PrintJob *printJob;
    HoldTransactionVC *holdTransactionVC;
    ItemSwipeEditVC *itemSwipeEditVC;
    AgeVerificationVC *ageVerificationVC;
    PriceAtPosVC *priceAtPosVC;
    DropAmountVC *dropAmountVC;
    InvoiceDetail *invoiceview;
    ShiftInOutPopOverVC *shiftInOutPopOverVC;
    WieghtScalePriceAtPosVC *wieghtScalePriceAtPosVC;
    RCR_MemoVC *rcr_MemoVC;
    RemoveTaxMessageVC *removeTaxMessageVC;
    GiftCardPosVC *giftcardVC;
    GiftCardCheckBalanceVC *giftcardCheckBalanceVC;
    GiftCardPopUpVC *giftcardPopupVC;
    OfflineRecordVC *offlineRecordVC;
    LastInvoiceReceiptPrint *lastInvoiceRcptPrint;
    LastGasInvoiceReceiptPrint *lastGasInvoiceRcptPrint;
    LastPostpayGasInvoiceReceiptPrint *lastPostPayGasInvoiceRcptPrint;
    CardTransactionRequestVC *cardTransactionRequestVC ;
    Configuration *objConfiguration;
    CardReceiptPrint *cardRcptPrint;
    ItemTicketValidation *itemTicketValidation;
    RCRBillSummary *rcrBillSummary;
    RapidCustomerLoyalty *rcrRapidCustomerLoayalty;
    RDiscountCalculator *rdDiscountCalculator;
    DiscountBillDetailVC *discountBillDetailVC;
    MultipleItemBarcodeRingUpVC * multipleItemBarcodeRingUpVC;
    ItemPackageTypeRingUpVC *itemPackageTypeRingUpVC;
    CustomerViewController *customerVC;
    POSLoginView *loginView;
    IntercomHandler *intercomHandler;
    InvoiceData_T *invoiceData;

    DrawerStatus *drawerStatus;
    
    NSInteger columnWidths[6];
    NSInteger columnAlignments[6];
    NSInteger upperAge;
    NSInteger lowerAge;
    NSInteger currentBarcodeItemIndex;
    NSInteger selectedPort;
    NSInteger currentPrintStep;

    UINavigationController *invoiceNav;
    
    UIView *dummyView;
    
    CGFloat balaceAmount;
    CGFloat creditLimitValue;
    NSString *itemBarcode;
    NSString *itemRingUpQty;

    NSString *stringBarcodeText;
    NSString *noSaleType;
    NSString *holdMessage;
    NSString *strPrintBarcode;
    NSString *itemUnitType;
    NSString *itemUnitQty;
    NSString *holdRemark;
    

    NSArray *array_port;

    NSMutableArray *itemForBarcodeArray;
    NSMutableArray *priceMdForBarcodes;
    NSMutableArray *locallastInvoiceTicketPassArray;
    
    NSDictionary *holdDataDictionary;
    
    NSMutableDictionary *dictLastInvoiceInfo;

    BOOL is2decimalamt;
    BOOL isTicketValid;
    BOOL isEBTValid;
    BOOL isNoSalesPrint;
    BOOL needToCheckDrawerStatus;
    
    BOOL isHouseChargeCollectPay;
    
    BOOL isOpenEbt ;
    CGFloat houseChargeValue;

    int cant;
    
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
}
@property (nonatomic, weak) IBOutlet UITableView *tenderItemTableView;
@property (nonatomic, weak) IBOutlet UIView *popupContainerView;
@property (nonatomic, weak) IBOutlet UITextField *barcodeScanTextField;
@property (nonatomic, weak) IBOutlet UITextField *keyBoardTextField;
@property (nonatomic, weak) IBOutlet UIButton *keyBoardButton;
@property (nonatomic, weak) IBOutlet UIButton *manualQtyBtn;
@property (nonatomic, weak) IBOutlet UIButton *btnAddItem;
@property (nonatomic, weak) IBOutlet UILabel *itemCountLabel;
@property (nonatomic, weak) IBOutlet UITextView *holdViewmsgBox;
@property (nonatomic, weak) IBOutlet UIButton *departmentButton;
@property (nonatomic, weak) IBOutlet UIButton *favouriteButton;
@property (nonatomic, weak) IBOutlet UILabel *lblCustomerName;
@property (nonatomic, weak) IBOutlet UIButton *btnRemoveCustomer;
@property (nonatomic, weak) IBOutlet UIView *tenderShortCutMenuContainer;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UILabel *offlineInvoiceCount;
@property (nonatomic, weak) IBOutlet UIImageView *offlineInvoiceCountImage;
@property (nonatomic, weak) IBOutlet UIView *offlineIndicationView;
@property (nonatomic, weak) IBOutlet UILabel *offlineIndicationLabel;
@property (nonatomic, weak) IBOutlet UIButton *rcrLeftSlideMenuButton;
@property (nonatomic, weak) IBOutlet UIButton *rcrRightSlideMenuButton;
@property (nonatomic, weak) IBOutlet UILabel *registerName;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIImageView *imgDepartmentBGView;
@property (nonatomic, weak) IBOutlet UIImageView *imgFavouriteBgView;
@property (nonatomic, weak) IBOutlet UILabel *departmentCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *favouriteCountLabel;
@property (nonatomic, weak) IBOutlet UIView *departmentContainerView;
@property (nonatomic, weak) IBOutlet UIView *favouriteContainerView;
@property (nonatomic, weak) IBOutlet UILabel *storeNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentDate;
@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UILabel *liveUpdateStatusLabel;
@property (nonatomic, strong) PaymentData *paymentData;


// RingUpItem Declaration
@property (nonatomic, weak) IBOutlet UILabel *subTotalLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalDiscountLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalTaxLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalEBTLabel;
@property (nonatomic, weak) IBOutlet UILabel *lblEBT;
@property (nonatomic, weak) IBOutlet UILabel *billAmountLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalItemLabel;
@property (nonatomic, weak) IBOutlet UIView *holdMessageView;
@property (nonatomic, strong) UIDocumentInteractionController *controller;


@property (nonatomic, weak) IBOutlet FlowerMenuView *flowerMenuView;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) FlowerMenu *flowerMenu;
@property (nonatomic, strong) RCRSlideMenuVC *rcrRightSlideMenuVC;
@property (nonatomic, strong) RCRSlideMenuVC *rcrLeftSlideMenuVC;
@property (nonatomic, strong) RecallViewController *recallView;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

@property (nonatomic, strong) ItemInfoDataObject * itemInfoDataObject;

@property (nonatomic, strong) RapidWebServiceConnection *deleteRecallConnection;
@property (nonatomic, strong) RapidWebServiceConnection *holdInvoiceWC;
@property (nonatomic, strong) RapidWebServiceConnection *voidTransactionsWC;
@property (nonatomic, strong) RapidWebServiceConnection *recallInvListWC;
@property (nonatomic, strong) RapidWebServiceConnection *itemDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *noSaleInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection *cancelInvoiceTransaction;
@property (nonatomic, strong) RapidWebServiceConnection *recallCountServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection *updateItemByFavouriteConnection;
@property (nonatomic, strong) RapidWebServiceConnection *CheckHouseChargeCreditLimitWC;



@property (nonatomic, strong) UIPopoverController *calendarPopOverController;

@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;
@property (nonatomic, strong) NSIndexPath *scrollToIndexPath;

@property (nonatomic) BOOL isPreviousItemProcessInProgress;

@property (nonatomic, weak) UIButton *syncButton;

@property (nonatomic, weak) UILabel *guestFloatingLabel;

@property (nonatomic, strong) NSString *guestLabelText;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *itemCodeId;
@property (nonatomic, strong) NSString *priceAtPOSAmount;
@property (nonatomic, strong) NSString *emailReciptHtml;
@property (nonatomic, strong) NSString *cardReciptHtml;

@property (nonatomic, strong) NSNumber *tipSetting;

@property (nonatomic, strong) NSMutableArray *itemLogArray;
@property (nonatomic, strong) NSMutableArray *flowerMenuActiveIds;
@property (nonatomic, strong) NSMutableArray *flowerMenuTitles;
@property (nonatomic, strong) NSMutableArray *flowerMenuNormalImages;
@property (nonatomic, strong) NSMutableArray *flowerMenuSelectedImages;
@property (nonatomic, strong) NSMutableArray *itemRingUpQueue;

@property (nonatomic,strong) NSFetchedResultsController *offlineInvoiceCountResultController;
@property (nonatomic,strong) NSFetchedResultsController *itemRingUpResultController;
@property (nonatomic,strong) NSFetchedResultsController *masterDataResultController;

@end

@implementation RcrPosVC

@synthesize tenderItemTableView;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize payentVoidDataAry,dictGiftCard,removeTaxVC,selectedFuelDict;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}
- (void)SetPortInfo
{
    NSString *localPortName;
    
    NSString *Str = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterSelection"];
    
    if(Str.length > 0)
    {
        if ([Str isEqualToString:@"Bluetooth"])
        {
            localPortName=@"BT:Star Micronics";
        }
        else if([Str isEqualToString:@"TCP"]){
            
            NSString *tcp = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedTCPPrinter"];
            localPortName=tcp;
        }
    }
    else{
        localPortName=@"BT:Star Micronics";
    }
    
    [RcrPosVC setPortName:localPortName];
    [RcrPosVC setPortSettings:array_port[selectedPort]];
}

-(void)didSelectSubDepartment:(SubDepartment *)selectedSubDepartment
{

}

-(void)didSelectDepartmentFromSubDepartment:(Department *)selectedDepartment
{

}

-(void)didSelectSubDeptItem:(Item *)selectedSubDeprItem
{

}
-(void)didSelectSubDeptFromItem:(SubDepartment *)selectedSubDepartment department:(Department *)selectedDepartment
{

}


- (void)loadDepartment
{
    [_departmentFavouriteContainer bringSubviewToFront:self.departments.view.superview];
    [_departmentFavouriteContainer sendSubviewToBack:self.favourite.view.superview];
    
    self.departments.view.hidden = NO;
    self.favourite.view.hidden = YES;
    self.departments.numerOfItemPerPage = [self numberOfItemInOnePage];
    [self.departments scrollDepartmentCollectionViewToTop];
/*    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    if(self.departments == nil)
    {
        self.departments = [storyBoard instantiateViewControllerWithIdentifier:@"GasDeptCollectionVC"];
        self.departments.view.frame = self.departmentView.bounds;
        self.departments.departmetCollectionVcDelegate = self;
        self.departments.numerOfItemPerPage = [self numberOfItemInOnePage];
        [self.departmentView addSubview:self.departments.view];
    }
    else
    {
        [self.departments scrollDepartmentCollectionViewToTop];
    }*/
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardWillHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
}

-(NSInteger)numberOfItemInOnePage
{
    return 15.0;
}

- (NSMutableArray *)posMenuItems

{    
    Item *giftCarditem = [self fetchAllItemForGiftCard:@"RapidRMS Gift Card"];
    NSArray  *menuTitles;
    NSArray  *selectedImages;
    NSArray *normalImages;
    
    
    if(giftCarditem)
    {
        menuTitles = @[@"Hold",@"Recall",@"Discount",@"Cancel Tnx.",@"Refund",@"Gift Card"];
        selectedImages = @[@"RCR_holdselected.png",@"RCR_recallselected.png",@"RCR_discountselected.png",@"cancletnxselected.png",@"RCR_refundselected.png",@"RCR_giftcardselected"];
        normalImages = @[@"RCR_hold.png",@"RCR_recall.png",@"RCR_discount.png",@"cancletnx.png",@"RCR_refund.png",@"RCR_giftcard.png"];
        menuId = @[@(HOLD_POS_MENU),
                   @(RECALL_POS_MENU),
                   @(DISCOUNT_POS_MENU),
                   @(CANCEL_POS_MENU),
                   @(REFUND_POS_MENU),
                   @(GIFT_CARD_POS_MENU),
                   @(MANAGER_REPORTS_POS_MENU)
                   ];
    }
    else
    {
        menuTitles = @[@"Hold",@"Recall",@"Discount",@"Cancel Tnx.",@"Refund"];
        selectedImages = @[@"RCR_holdselected.png",@"RCR_recallselected.png",@"RCR_discountselected.png",@"cancletnxselected.png",@"RCR_refundselected.png"];
        normalImages = @[@"RCR_hold.png",@"RCR_recall.png",@"RCR_discount.png",@"cancletnx.png",@"RCR_refund.png"];
        menuId = @[@(HOLD_POS_MENU),
                   @(RECALL_POS_MENU),
                   @(DISCOUNT_POS_MENU),
                   @(CANCEL_POS_MENU),
                   @(REFUND_POS_MENU),
                   @(MANAGER_REPORTS_POS_MENU)
                   ];
    }
    
    NSMutableArray *menuItemArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < menuTitles.count; i++)
    {
        NSMutableDictionary *menuItemDictionary = [[NSMutableDictionary alloc]init];
        menuItemDictionary[@"menuTitle"] = menuTitles[i];
        menuItemDictionary[@"selectedImage"] = selectedImages[i];
        menuItemDictionary[@"normalImage"] = normalImages[i];
        menuItemDictionary[@"menuId"] = menuId[i];
        [menuItemArray addObject:menuItemDictionary];
    }
    return menuItemArray;
}
-(NSString *)setupPosIdentifier
{
    NSString *posIdentifier = @"PosMenuVC";
    return posIdentifier;
}

-( RCRSlideMenuVC *)loadLeftRcrSlideMenu
{
    for (UIView *view in self.view.subviews) {
        if ([view isEqual: self.rcrLeftSlideMenuVC.view]) {
            [self.rcrLeftSlideMenuVC.view removeFromSuperview];
        }
    }
    self.rcrLeftSlideMenuVC = nil;
    if (self.rcrLeftSlideMenuVC == nil) {
        self.rcrLeftSlideMenuVC = [self loadRcrSlideMenu:self.rcrLeftSlideMenuVC withIdentifier:@"RCRLeftSlideMenu"];
        [self.view addSubview:self.rcrLeftSlideMenuVC.view];

    }
    return self.rcrLeftSlideMenuVC;
}
-( RCRSlideMenuVC *)loadRightRcrSlideMenu
{
    for (UIView *view in self.view.subviews) {
        if ([view isEqual: self.rcrRightSlideMenuVC.view]) {
            [self.rcrRightSlideMenuVC.view removeFromSuperview];
        }
    }
    
    self.rcrRightSlideMenuVC = nil;
    if (self.rcrRightSlideMenuVC == nil) {
        self.rcrRightSlideMenuVC = [self loadRcrSlideMenu:self.rcrRightSlideMenuVC withIdentifier:@"RCRRightSlideMenu"];
        [self.view addSubview:self.rcrRightSlideMenuVC.view];

    }
    return self.rcrRightSlideMenuVC;
}


-(RCRSlideMenuVC *)loadRcrSlideMenu:(RCRSlideMenuVC *)rcrSlideMenu withIdentifier:(NSString *)identifier
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    rcrSlideMenu = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    rcrSlideMenu.rcrSlideMenuVCDelegate = self;
  
    
    if ([identifier isEqualToString:@"RCRLeftSlideMenu"])
    {
        rcrSlideMenu.view.frame = CGRectMake(-rcrSlideMenu.view.frame.size.width, 0,rcrSlideMenu.view.frame.size.width, rcrSlideMenu.view.frame.size.height);
        
        NSArray *slideMenuEmumArray = @[@(RcrSlideMenuNoSale),@(RcrSlideMenuDrop),@(RcrSlideMenuInvoice),@(RcrSlideMenuTaxRemove)];
        if (isTicketValid == TRUE && isEBTValid == FALSE) {
            slideMenuEmumArray = @[@(RcrSlideMenuNoSale),@(RcrSlideMenuDrop),@(RcrSlideMenuInvoice),@(RcrSlideMenuTaxRemove),@(RCRSlideMenuTicketValidation)];
        }
        
       else if (isTicketValid == TRUE && isEBTValid == TRUE) {
            slideMenuEmumArray = @[@(RcrSlideMenuNoSale),@(RcrSlideMenuDrop),@(RcrSlideMenuInvoice),@(RcrSlideMenuTaxRemove),@(RCRSlideMenuTicketValidation),@(RCRSlideMenuEBT)];
        }
        
       else if (isTicketValid == FALSE && isEBTValid == TRUE) {
           slideMenuEmumArray = @[@(RcrSlideMenuNoSale),@(RcrSlideMenuDrop),@(RcrSlideMenuInvoice),@(RcrSlideMenuTaxRemove),@(RCRSlideMenuEBT)];
       }
        
        
        rcrSlideMenu.rcrSlideMenuItemEnum = slideMenuEmumArray;
        if (isTicketValid == TRUE && isEBTValid == TRUE) {
//            rcrSlideMenu.rcrSlideMenuNames = @[@"No Sales",@"Drop",@"Invoice",@"Tax Remove",@"Ticket Validation",@"EBT"];
            rcrSlideMenu.rcrSlideMenuNormalImages = @[@"NoSale_Slide_Menu.png",@"Drop_Slide_Menu.png",@"Invoice_Slide_Menu.png",@"RemoveTax_Slide_Menu.png",@"TicketValidation_Slide_Menu.png",@"Ebt_Slide_Menu.png"];
            
            rcrSlideMenu.rcrSlideMenuSelectedImages = @[@"NoSale_Slide_Menu_selected.png",@"Drop_Slide_Menu_selected.png",@"Invoice_Slide_Menu_selected.png",@"RemoveTax_Slide_Menu_selected.png",@"TicketValidation_Slide_Menu_selected.png",@"Ebt_Slide_Menu_selected.png"];
        }
      else if (isTicketValid == TRUE && isEBTValid == FALSE) {
//            rcrSlideMenu.rcrSlideMenuNames = @[@"No Sales",@"Drop",@"Invoice",@"Tax Remove",@"Ticket Validation"];
            rcrSlideMenu.rcrSlideMenuNormalImages = @[@"NoSale_Slide_Menu.png",@"Drop_Slide_Menu.png",@"Invoice_Slide_Menu.png",@"RemoveTax_Slide_Menu.png",@"TicketValidation_Slide_Menu.png"];
         
          rcrSlideMenu.rcrSlideMenuSelectedImages = @[@"NoSale_Slide_Menu_selected.png",@"Drop_Slide_Menu_selected.png",@"Invoice_Slide_Menu_selected.png",@"RemoveTax_Slide_Menu_selected.png",@"TicketValidation_Slide_Menu_selected.png"];

        }
      else if (isTicketValid == FALSE && isEBTValid == TRUE) {
//          rcrSlideMenu.rcrSlideMenuNames = @[@"No Sales",@"Drop",@"Invoice",@"Tax Remove",@"EBT"];
          rcrSlideMenu.rcrSlideMenuNormalImages = @[@"NoSale_Slide_Menu.png",@"Drop_Slide_Menu.png",@"Invoice_Slide_Menu.png",@"RemoveTax_Slide_Menu.png",@"Ebt_Slide_Menu.png"];
          
          rcrSlideMenu.rcrSlideMenuSelectedImages = @[@"NoSale_Slide_Menu_selected.png",@"Drop_Slide_Menu_selected.png",@"Invoice_Slide_Menu_selected.png",@"RemoveTax_Slide_Menu_selected.png",@"Ebt_Slide_Menu_selected.png"];

      }
        else
        {
//            rcrSlideMenu.rcrSlideMenuNames = @[@"No Sales",@"Drop",@"Invoice",@"Tax Remove",@"EBT"];
            rcrSlideMenu.rcrSlideMenuNormalImages = @[@"NoSale_Slide_Menu.png",@"Drop_Slide_Menu.png",@"Invoice_Slide_Menu.png",@"RemoveTax_Slide_Menu.png",@"RemoveTax_Slide_Menu.png"];
        }
    }
    if ([identifier isEqualToString:@"RCRRightSlideMenu"])
    {
        rcrSlideMenu.view.frame = CGRectMake(self.view.frame.size.width, 0,rcrSlideMenu.view.frame.size.width, rcrSlideMenu.view.frame.size.height);
        rcrSlideMenu.rcrSlideMenuItemEnum = @[@(RcrSlideMenuSwichUser
                                              ),@(RCRSlideMenuLogOut)];
        rcrSlideMenu.rcrSlideMenuNames = @[@"Swich User",@"Log Out"];
        rcrSlideMenu.rcrSlideMenuNormalImages = @[@"SwitchUser_Slide_Menu.png",@"LogOut_Slide_Menu.png"];
    }
    if ([identifier isEqualToString:@"RCRAddItemFavouriteMenu"])
    {
        rcrSlideMenu.view.frame = CGRectMake(self.view.frame.size.width, 0,rcrSlideMenu.view.frame.size.width, rcrSlideMenu.view.frame.size.height);
        rcrSlideMenu.rcrSlideMenuItemEnum = @[@(RCRAddItemMenu
                                              ),@(RCRAddToFavouriteMenu)];
        rcrSlideMenu.rcrSlideMenuNames = @[@"Add Item",@"Add To Favourite Item"];
        rcrSlideMenu.rcrSlideMenuNormalImages = @[@"SwitchUser_Slide_Menu.png",@"LogOut_Slide_Menu.png"];
    }
    return rcrSlideMenu;
}
-(void)hideShowRCRSlideMenu:(RCRSlideMenuVC *)rcrSlideMenuVC
{
    [self slideInOutRcrMenu:rcrSlideMenuVC];
}

-(void)didSelectRCRMenuItem:(RcrSlideMenuItem)rcrSlideMenuItem forRCRSlideMenuVC:(RCRSlideMenuVC *)rcrSlideMenuVC
{
    [self slideInOutRcrMenu:rcrSlideMenuVC];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        switch (rcrSlideMenuItem) {
            case RcrSlideMenuNoSale:
                [self noSaleButtonClicked:nil];
                break;
            case RcrSlideMenuDrop:
                [self dropButtonClicked:nil];
                break;
                
            case   RcrSlideMenuInvoice:
                [self invoiceButtonClicked];
                break;
                
            case   RcrSlideMenuGiftCard:
                if (!self.rmsDbController.isInternetRechable) {
                    return;
                }
                 // [self openGiftCardView];
                break;
                
            case   RcrSlideMenuTaxRemove:
                
                if (!self.rmsDbController.isInternetRechable) {
                    return;
                }
                [self removeTaxButtonClicked:nil];
                
                break;
                
            case RcrSlideMenuSwichUser:
                [self switchuserButtonClick:nil];
                break;
            case RCRSlideMenuLogOut:
                [self logoutButtonClicked:nil];
                break;
            case RCRSlideMenuTicketValidation:
                [self showTicketValidationScreen];
                break;
                
            case RCRSlideMenuEBT:
                [self eBTButtonClicked:nil];
                break;
            case RCRAddItemMenu:
                [self addItem:nil];
                break;
            case RCRAddToFavouriteMenu:
                [self addToFavouriteItem:nil];
                break;
                
                
            }
    });
    
}

-(NSString *)currentRegisterInvoiceNumber
{
    NSString *keyChainInvoiceNo = [Keychain getStringForKey:@"tenderInvoiceNo"];
    NSInteger number = keyChainInvoiceNo.integerValue;
    number++;
    NSString *updatedTenderInvoiceNo = [NSString stringWithFormat: @"%d", (int)number];
    return updatedTenderInvoiceNo;
}


- (void)slideInOutRcrMenu:(RCRSlideMenuVC *)rcrSlideMenu
{
   
    BOOL isHide = FALSE;
    
    
    CGFloat currentXPostion = 0.00;
    if (rcrSlideMenu == self.rcrLeftSlideMenuVC ) {
        
        CGRect currentFrame = rcrSlideMenu.view.frame;
         currentXPostion = currentFrame.origin.x;
        
        if (currentXPostion == 0) {
            _rcrLeftSlideMenuButton.selected = NO;
            currentXPostion = -rcrSlideMenu.view.frame.size.width;
            isHide = TRUE;
        }
        else
        {
            _rcrLeftSlideMenuButton.selected = YES;
            currentXPostion = 0;
        }
    }
    
    
    if (rcrSlideMenu == self.rcrRightSlideMenuVC ) {
        
//        animationOption = UIViewAnimationOptionTransitionFlipFromRight;
//        CGRect currentFrame = rcrSlideMenu.view.frame;
//         currentXPostion = currentFrame.origin.x;
//        
//        if (currentXPostion == self.view.frame.size.width)
//        {
//            rcrRightSlideMenuButton.selected = YES;
//            currentXPostion = 75;
//        }
//        else
//        {
//            isHide = TRUE;
//            rcrRightSlideMenuButton.selected = NO;
//            currentXPostion =  self.view.frame.size.width;
//        }
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = rcrSlideMenu.view.frame;
        frame.origin = CGPointMake(currentXPostion, 0);
        if (rcrSlideMenu == self.rcrRightSlideMenuVC)
        {
         //   frame.origin = CGPointMake(currentXPostion, 75);
        }
        rcrSlideMenu.view.frame = frame;
    } completion:^(BOOL finished)
     {
         if (isHide) {
         }
    }];

}


-(IBAction)rcrLeftSlideMenuButton:(id)sender
{
    [self slideInOutRcrMenu:[self loadLeftRcrSlideMenu]];
}
-(IBAction)rcrRightSlideMenuButton:(id)sender
{
  //  [self slideInOutRcrMenu:[self loadRightRcrSlideMenu]];
//self.rcrRightSlideMenuVC = [self loadRcrSlideMenu:self.rcrRightSlideMenuVC withIdentifier:@"RCRRightSlideMenu"];
    for (UIView *view in self.view.subviews)
    {
        if ([view isEqual:self.rcrRightSlideMenuVC.view]) {
            if (giftcardPopOverController)
            {
                [giftcardPopup dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    self.rcrRightSlideMenuVC = nil;
    if (self.rcrRightSlideMenuVC == nil)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
        self.rcrRightSlideMenuVC = [storyBoard instantiateViewControllerWithIdentifier:@"RCRRightSlideMenu"];
        giftcardPopup = self.rcrRightSlideMenuVC;
        self.rcrRightSlideMenuVC.rcrSlideMenuVCDelegate = self;
        
        // Present the view controller using the popover style.
        giftcardPopup.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:giftcardPopup animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        giftcardPopOverController = [giftcardPopup popoverPresentationController];
        giftcardPopOverController.delegate = self;
        giftcardPopup.preferredContentSize = CGSizeMake(170, 110);
        giftcardPopOverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        giftcardPopOverController.sourceView = self.view;
        giftcardPopOverController.sourceRect = CGRectMake(885, 0, 140, 78);

        
        
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
//        self.rcrRightSlideMenuVC = [storyBoard instantiateViewControllerWithIdentifier:@"RCRRightSlideMenu"];
//        self.rcrRightSlideMenuVC.rcrSlideMenuVCDelegate = self;
//        self.rcrRightSlideMenuVC.view.frame = CGRectMake(825, 78, 191, 161);
        self.rcrRightSlideMenuVC.rcrSlideMenuItemEnum = @[@(RcrSlideMenuSwichUser
                                                          ),@(RCRSlideMenuLogOut)];
        self.rcrRightSlideMenuVC.isPresentAsPopOver = TRUE;
        self.rcrRightSlideMenuVC.rcrSlideMenuNames = @[@"SWITCH USER",@"LOG OUT"];
        self.rcrRightSlideMenuVC.rcrSlideMenuNormalImages = @[@"rcr_switchuser.png",@"rcr_logouticon.png"];
        self.rcrRightSlideMenuVC.rcrSlideMenuSelectedImages = @[@"rcr_switchuserselected.png",@"rcr_logouticonselected.png"];
      //  [self.view addSubview:self.rcrRightSlideMenuVC.view];
    }
   }


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"RcrPosMenuSegue"]  || [segueIdentifier isEqualToString:@"RestaurantPosSegue"] || [segueIdentifier isEqualToString:@"RetailReataurantPosMenuSegue"] || [segueIdentifier isEqualToString:@"PcrPosGasSegue"]) {
        self.posMenuVC  = (PosMenuVC*) segue.destinationViewController;
        self.posMenuVC.view.frame = self.posMenuContainer.bounds;
        [self.posMenuContainer addSubview:self.posMenuVC.view];
        [self.posMenuVC setMenuTitles:[self posMenuItems]];
        self.posMenuVC.menuDelegate = self;
    }
    if ([segueIdentifier isEqualToString:@"RetailDepartmentCollectionSegue"] || [segueIdentifier isEqualToString:@"RestaurantDepartmentSegue"] || [segueIdentifier isEqualToString:@"RetailRestaurantDepartmentSegue"] || [segueIdentifier isEqualToString:@"PosGasDepartmentSegue"]) {
        self.departments  = (DepartmetCollectionVC*) segue.destinationViewController;
        self.departments.departmetCollectionVcDelegate = self;
        self.departments.departmetCollectionCountDelegate = self;
        //[_departmentFavouriteContainer addSubview:self.departments.view];
    }
    if ([segueIdentifier isEqualToString:@"RetailFavouriteCollectionSegue"] || [segueIdentifier isEqualToString:@"RestaurantFavouriteSegue"] || [segueIdentifier isEqualToString:@"RetailRestaurantFavouriteSegue"] || [segueIdentifier isEqualToString:@"PosGasRestaurantFavouriteSegue"] ) {
        self.favourite  = (FavouriteCollectionVC*) segue.destinationViewController;
        self.favourite.favouriteCollectionDelegate = self;
        self.favourite.favouriteCollectionCountDelegate = self;
        [_departmentFavouriteContainer addSubview:self.favourite.view];
    }
    if ([segueIdentifier isEqualToString:@"RetailTenderShortcutSegue"] || [segueIdentifier isEqualToString:@"RestaurantTenderShortcutSegue"] || [segueIdentifier isEqualToString:@"RetailRestaurantTenderShortcutSegue"] || [segueIdentifier isEqualToString:@"GasTenderShortcutSegue"])
    {
        self.tenderShortcutVC = (TenderShortcutVC*) segue.destinationViewController;
        self.tenderShortcutVC.managedObjectContext = self.rmsDbController.managedObjectContext;
       // self.tenderShortcutVC.view.frame = tenderShortCutMenuContainer.bounds;
        self.tenderShortcutVC.tenderShortCutDelegate = self;
       // [tenderShortCutMenuContainer addSubview:self.tenderShortcutVC.view];
    }
    if ([segueIdentifier isEqualToString:@"RetailRestaurantSubdepartmentSegue"] || [segueIdentifier isEqualToString:@"RestaurantSubdepartmentSegue"]) {
        self.subDeptCollectionVC  = (SubDepartmetCollectionVC*) segue.destinationViewController;
        self.subDeptCollectionVC.subDepartmetCollectionVcDelegate = self;
        self.subDeptCollectionVC.subDepartmetCollectionCountDelegate = self;
        self.subDeptCollectionVC.view.hidden = YES;
    }
    if ([segueIdentifier isEqualToString:@"RetailRestaurantSubDepartmentItemSegue"] || [segueIdentifier isEqualToString:@"RestaurantSubDepartmentItemSegue"]) {
        self.subDeptItemCollectionVC  = (SubDeptItemCollectionVC*) segue.destinationViewController;
        self.subDeptItemCollectionVC.subDepartmetItemsVcDelegate = self;
        self.subDeptItemCollectionVC.subDepartmetItemsCountDelegate = self;
        self.subDeptCollectionVC.view.hidden = YES;
    }
}

- (void)setupPosMenu
{
    // This is POSMenu SetUp....
    self.posMenuVC.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.posMenuVC.billAmountCalculator = billAmountCalculator;
    if (self.rmsDbController.isInternetRechable)
    {
        self.posMenuVC.alphaOpasity = 1.0;
        _offlineIndicationView.alpha = 0;
        _offlineIndicationLabel.hidden = YES;
    }
    else
    {
        self.posMenuVC.alphaOpasity = 0.3;
        _offlineIndicationView.alpha = 1.0;
        _offlineIndicationLabel.hidden = NO;
    }
}

- (void)internetBreakDown:(NSNotification *)notification
{
    if (self.rmsDbController.isInternetRechable)
    {
        [self.posMenuVC setOpasityForCollectionview:1.0];
        _offlineIndicationView.alpha = 0.0;
        _offlineIndicationLabel.hidden = YES;
        
    }
    else
    {
        [self.posMenuVC setOpasityForCollectionview:0.3];
        _offlineIndicationView.alpha = 1.0;
        _offlineIndicationLabel.hidden = NO;
    }
}


-(void)didTenderTransactionUsingTenderType :(NSString *)tenderType withPayId:(NSNumber *)strPayId
{
    [self tenderTransactionWithTenderType:tenderType withPayId:strPayId];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.reciptDataAry = [[NSMutableArray alloc]init];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    self.holdInvoiceWC = [[RapidWebServiceConnection alloc]init];
    self.voidTransactionsWC = [[RapidWebServiceConnection alloc]init];
    self.recallInvListWC = [[RapidWebServiceConnection alloc]init];
    self.cancelInvoiceTransaction = [[RapidWebServiceConnection alloc]init];
    self.itemDetailWC = [[RapidWebServiceConnection alloc]init];
    self.noSaleInsertWC = [[RapidWebServiceConnection alloc]init];
    self.CheckHouseChargeCreditLimitWC = [[RapidWebServiceConnection alloc]init];

    billAmountCalculator = [[BillAmountCalculator alloc]initWithManageObjectcontext:self.managedObjectContext];
    rcrBillSummary = [[RCRBillSummary alloc] init];
    self.recallCountServiceConnection = [[RapidWebServiceConnection alloc]init];
    self.updateItemByFavouriteConnection = [[RapidWebServiceConnection alloc]init];
    self.itemRingUpQueue = [[NSMutableArray alloc]init];
    rdDiscountCalculator = [[RDiscountCalculator alloc] init];

    lastInvoiceRcptPrint = [[LastInvoiceReceiptPrint alloc]init];
    lastGasInvoiceRcptPrint = [[LastGasInvoiceReceiptPrint alloc]init];
    lastPostPayGasInvoiceRcptPrint = [[LastPostpayGasInvoiceReceiptPrint alloc]init];
    
    objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    self.tipSetting = objConfiguration.localTipsSetting;
    isTicketValid = objConfiguration.localTicketSetting.boolValue;
    isEBTValid = objConfiguration.localEbt.boolValue;
    
    [self setAddcustomerloyaltyFrame];
    
      _storeNameLabel.text = [NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetBreakDown:) name:@"InternetBreakDown" object:nil];
#ifdef LINEAPRO_SUPPORTED
    dtdev=[DTDevices sharedDevice];
	[dtdev addDelegate:self];
    [dtdev connect];
#endif
    NSMutableArray *arrayShortcutSelectionArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ModuleSelectionShortCut"]mutableCopy];
    
    if (self.rmsDbController.isFirstShortCutIcon && arrayShortcutSelectionArray.count == 0)
    {
        arrayShortcutSelectionArray = [[NSMutableArray alloc] init];
        NSDictionary *dictShortCutArray = @{
                                            @"module" :@"Dashboard",
                                            @"moduleIndex" :@"1",
                                            };
        [arrayShortcutSelectionArray addObject:dictShortCutArray];
        [[NSUserDefaults standardUserDefaults]setObject:arrayShortcutSelectionArray forKey:@"ModuleSelectionShortCut"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if(arrayShortcutSelectionArray.count>0)
    {
        self.flowerMenuView.hidden=NO;
        [self setupTheFlowerArray];
    }
    else
    {
        self.flowerMenuView.hidden=YES;
    }
    isNoSalesPrint = FALSE;
    [self registerNotifications];
    [self setupPosMenu];
    [_btnRemoveCustomer setHidden:YES];
    [_barcodeScanTextField becomeFirstResponder];
    if(_longPressGesture != nil)
    {
        [self.view addGestureRecognizer:_longPressGesture];
    }
    
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;
    
    _itemLogArray = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LiveHoldUpdateCount:) name:@"LiveHoldUpdateCount" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectedFromLiveUpdate:) name:LiveUpdateConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectedFromLiveUpdate:) name:LiveUpdateDisconnectedNotification object:nil];
    
    if (self.rmsDbController.xmppConnected) {
        self.liveUpdateStatusLabel.backgroundColor = [UIColor greenColor];
    }
    else
    {
        self.liveUpdateStatusLabel.backgroundColor = [UIColor redColor];
    }
    
    [self.view addSubview:_popupContainerView];
    _popupContainerView.hidden = YES;
    [self resetAgeRestriction];
    _departmentNumpadView.hidden = YES;
    UIImage *stretchableImage  =  [[UIImage imageNamed:@"patch.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,200)];
    _imgDepartmentBGView.image = stretchableImage;
    _imgFavouriteBgView.image = stretchableImage;
    
    dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self setCurrencyFormatterToBottomLabel];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];

    [self checkPreviousTransactionStatus];
    self.deleteRecallConnection = [[RapidWebServiceConnection alloc] init];
    [self addSyncButton];
    self.presentedViewControllers = [[NSMutableArray alloc] init];
    
    _itemInfoDataObject = [[ItemInfoDataObject alloc]init];
    drawerStatus = [[DrawerStatus alloc] init];
    needToCheckDrawerStatus = [drawerStatus isDrawerConfigured];
}

-(void)setAddcustomerloyaltyFrame
{
    if (!objConfiguration.localCustomerLoyalty.boolValue)
    {
            _btnAddCustomerLoyalty.hidden = YES ;
    }
}

- (void)addSyncButton
{
    UIButton *button = [self syncButtonWithFrame];
    [self.view addSubview:button];
    self.syncButton = button;
    [self.syncButton setImage:[UIImage imageNamed:@"syncbtn.png"] forState:UIControlStateNormal];
    [self.syncButton setImage:[UIImage imageNamed:@"syncbtnselected.png"] forState:UIControlStateHighlighted];
    [self.syncButton setImage:[UIImage imageNamed:@"syncbtnselected.png"] forState:UIControlStateSelected];
    [self.syncButton addTarget:self action:@selector(synchronize24HoursClickedFromSalesScreen:) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)syncButtonWithFrame
{
    UIButton *button = [[UIButton alloc] initWithFrame:[self getRectForSyncButton]];
    return button;
}

- (CGRect)getRectForSyncButton
{
    CGRect rect;
    if ([self.moduleIdentifierString isEqualToString:@"RetailRestaurant"])
    {
        rect = CGRectMake(796, 30, 37, 37);
    }
    else if ([self.moduleIdentifierString isEqualToString:@"RcrPosRestaurantVC"])
    {
        rect = CGRectMake(796, 30, 37, 37);
    }
    else if ([self.moduleIdentifierString isEqualToString:@"RcrPosVC"])
    {
        rect = CGRectMake(796, 30, 37, 37);
    }
    else if ([self.moduleIdentifierString isEqualToString:@"RcrPosGasVC"])
    {
        rect = CGRectMake(796, 30, 37, 37);
    }
    else
    {
        rect = CGRectMake(0, 0, 0, 0);
    }
    return rect;
}

-(IBAction)synchronize24HoursClickedFromSalesScreen:(id)sender
{
    [self.rmsDbController playButtonSound];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseCompleteSyncDataFromSalesScreen:) name:@"CompleteSyncData" object:nil];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self.rmsDbController startSynchronizeUpdate:3600*24];
}

-(void)responseCompleteSyncDataFromSalesScreen:(NSNotification *)notification
{
    [_activityIndicator hideActivityIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteSyncData" object:nil];
}

- (void)setCurrencyFormatterToBottomLabel
{
    self.subTotalLabel.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    self.totalDiscountLabel.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    self.totalTaxLabel.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    self.billAmountLabel.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    if (isEBTValid) {
        self.totalEBTLabel.text = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    }
    else
    {
        self.totalEBTLabel.text = @"";
        self.lblEBT.text = @"";
    }

}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

-(void)didConnectedFromLiveUpdate :(NSNotification*)notification
{
    self.liveUpdateStatusLabel.backgroundColor = [UIColor greenColor];
}

-(void)didDisconnectedFromLiveUpdate :(NSNotification*)notification
{
    self.liveUpdateStatusLabel.backgroundColor = [UIColor redColor];
}

-(void)LiveHoldUpdateCount :(NSNotification*)notification
{
    NSDictionary *response = notification.object;
    self.crmController.recallCount = [response[@"Code"]integerValue];
    [self updateRecallCountWithOfflineHoldInvoice];
}

-(NSUInteger )indexForPosMenuId:(POS_MENU )posMenuId
{
    return [menuId indexOfObject:@(posMenuId)];

}

-(NSMutableArray *)configureCreditCardPaymentData
{
    NSMutableArray *paymentModeItems = self.paymentData.paymentModes;
    NSMutableArray *paymentModeItemsArray = [[NSMutableArray alloc]init];
    
    for (int i =0; i < paymentModeItems.count; i++) {
        NSMutableArray *paymentModeArray = paymentModeItems[i];
        for (int j =0; j < paymentModeArray.count; j++) {
            PaymentModeItem *item = paymentModeArray[j];
            
            if ([[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"Credit"]  || [[item.paymentModeDictionary valueForKey:@"CardIntType"] isEqualToString:@"Debit"])
            {
                
               if ( item.creditTransactionId.length > 0){
                if ((item.actualAmount.floatValue + item.calculatedAmount.floatValue)!= 0 && (item.creditCardTransactionStatus.integerValue == Requesting || item.creditCardTransactionStatus.integerValue == Approved || item.creditCardTransactionStatus.integerValue == PartialApproved ))
                {
                    [paymentModeItemsArray addObject:item];
                }
                }
            }
        }
    }
    return paymentModeItemsArray;
}



- (void)restoreItemDataFromUserDefault
{
    
    // configure payment data object which we store in order object
    NSManagedObjectContext *privateManageobjectContext = self.managedObjectContext;
    RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
    if (restaurantOrder != nil && restaurantOrder.paymentData != nil) {
        self.paymentData = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantOrder.paymentData];
        
        if ([[self configureCreditCardPaymentData] count] > 0) {
            
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            cardTransactionRequestVC = [storyBoard instantiateViewControllerWithIdentifier:@"CardTransactionRequestVC"];
            cardTransactionRequestVC.cardTransactionRequestVCDelegate = self;
            cardTransactionRequestVC.paymentData = self.paymentData;
            cardTransactionRequestVC.modalPresentationStyle = UIModalPresentationPopover;
            cardTransactionRequestVC.view.frame =self.view.bounds;
            [self.view addSubview:cardTransactionRequestVC.view];
            cardTransactionRequestVC.view.frame = CGRectMake(50, 84, 800, 600);
            [self presentViewAsModal:cardTransactionRequestVC];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Transaction NOT complete" message:@"Oops!Transaction not complete. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        
        [UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]].tintColor = [UIColor blackColor];
        [UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]].backgroundColor = [UIColor colorWithRed:250.0/255.0 green:249.0/255.0 blue:158.0/255.0 alpha:1.0];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:nil];
                                                       [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setBackgroundColor:nil];
                                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }
    [self updateBillUI];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    [self updateOfflineInvoiceCount];
    [_barcodeScanTextField becomeFirstResponder];
    
    [self.posMenuVC setRecallCount:self.crmController.recallCount AtIndex:[self indexForPosMenuId:RECALL_POS_MENU]];
    if ([self.shiftInRequire isEqualToString:@"Require"])
    {
        shiftInOutPopOverVC = [[ShiftInOutPopOverVC alloc]initWithNibName:@"ShiftInOutPopOverVC" bundle:nil];
        shiftInOutPopOverVC.shiftInOutPopOverDelegate = self;
        shiftInOutPopOverVC.strType = @"SHIFT OPEN";
        [self presentViewAsModal:shiftInOutPopOverVC];
    }
    self.shiftInRequire = @"";
    if (rcrRapidCustomerLoayalty)
    {
       
        _lblCustomerName.text = rcrRapidCustomerLoayalty.customerName;
        [_btnRemoveCustomer setHidden:NO];
    }
}

-(void)displayPreviousCompletedTransactionAlert:(RestaurantOrder *)restaurantOrder withInvoice:(InvoiceData_T *)invoiceT
{
    NSString *message = [NSString stringWithFormat:@"Oops! Something went wrong, but your transaction(%@) is completed. You can re-print the receipt under invoice section.",restaurantOrder.invoiceNo] ;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Transcation successfuly completed" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]].tintColor = [UIColor blackColor];
    [UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]].backgroundColor = [UIColor colorWithRed:250.0/255.0 green:249.0/255.0 blue:158.0/255.0 alpha:1.0];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self removeRestaurantOrderObject];
                                   
                                   [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:nil];
                                   
                                   [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setBackgroundColor:nil];
                                    [self generatePumpCartIfTransactionSuccess:invoiceT];
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)checkDrawerStatus:(BOOL)needToSwitchDrawerType {
    if (!drawerStatus) {
        drawerStatus = [[DrawerStatus alloc] init];
    }
    [drawerStatus checkDrawerStatusWithDelegate:self needToSwitchDrawerType:needToSwitchDrawerType];
}

-(void)checkPreviousTransactionStatus
{
    if (self.restaurantOrderObjectId == nil)
    {
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        RestaurantOrder  *restaurantOrder = [self.updateManager fetchRestaurantOrderForInvoiceNo:[self currentRegisterInvoiceNumber] withContext:privateContextObject];
        
        if (restaurantOrder == nil) {
            
            NSMutableDictionary *restaurantOrderDetail = [[NSMutableDictionary alloc]init];
            restaurantOrderDetail[@"noOfGuest"] = @"1";
            restaurantOrderDetail[@"tableName"] = @"Retail";
            restaurantOrderDetail[@"orderid"] = @(0);
            restaurantOrderDetail[@"orderState"] = @(OPEN_ORDER);
            restaurantOrderDetail[@"InvoiceNo"] = [self currentRegisterInvoiceNumber];
            restaurantOrder = [self.updateManager insertRestaurantOrderListInLocalDataBase:restaurantOrderDetail withContext:privateContextObject];
            self.restaurantOrderObjectId = restaurantOrder.objectID;
        }
        else
        {
            
            if (restaurantOrder.orderStatus.integerValue == TP_DONE) {
                return;
            }
            
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
            fetchRequest.entity = entity;
            NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"regInvoiceNo == %@",restaurantOrder.invoiceNo];
            fetchRequest.predicate = offlineDataDisplayPredicate;
            NSArray *offlineInvoice = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
            InvoiceData_T *invoiceDataT = offlineInvoice.firstObject;
            if (offlineInvoice.count > 0) {
                
              // [self displayPreviousCompletedTransactionAlert:restaurantOrder];
                [self displayPreviousCompletedTransactionAlert:restaurantOrder withInvoice:invoiceDataT];

            }
            else{
                
                self.restaurantOrderObjectId = restaurantOrder.objectID;
                if ([self reciptDataAryForBillOrder].count == 0)
                {
                    return;
                }

                [self restoreItemDataFromUserDefault];
            }
        }
    }
}

-(void)generatePumpCartIfTransactionSuccess:(InvoiceData_T *)invoiceDataT{

    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceMstData] firstObject];
    invoiceDetailDict[@"InvoiceItemDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoiceItemData] firstObject];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:invoiceDataT.invoicePaymentData] firstObject];
    
    if([self.rmsDbController checkGasPumpisActive]){
        
        NSMutableDictionary *invoiceDetail = [NSMutableDictionary dictionary];
        
        invoiceDetail[@"RegisterInvNo"] = [[invoiceDetailDict[@"InvoiceMaster"] firstObject] valueForKey:@"RegisterInvNo"];
        
        invoiceDetail[@"UserId"] = @([[[invoiceDetailDict[@"InvoiceMaster"] firstObject] valueForKey:@"UserId"] integerValue]);
        
        invoiceDetail[@"RegisterId"] = @([[[invoiceDetailDict[@"InvoiceMaster"] firstObject] valueForKey:@"RegisterId"] integerValue]);
        
        NSArray *itemDetail = [invoiceDetailDict valueForKey:@"InvoiceItemDetail"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"InvoicePumpCart != nil"];
        itemDetail = [itemDetail filteredArrayUsingPredicate:predicate];
        
//        [self.rmsDbController.rapidPetroPos createPumpCartForInvoice:itemDetail withInvoiceDetail:invoiceDetail];
    }
}

-(void)removeTenderBillData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TenderBillData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)loadFavouriteItem
{
    
    [_departmentFavouriteContainer bringSubviewToFront:self.favourite.view.superview];
    [_departmentFavouriteContainer sendSubviewToBack:self.departments.view.superview];

    self.departments.view.hidden = YES;
    self.favourite.view.hidden = NO;
  }

- (void)updateDateLabel
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSString* str = [formatter stringFromDate:date];
	self.currentDate.text = str;
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (needToCheckDrawerStatus) {
        [self checkDrawerStatus:NO];
    }

    self.userName.text = [self.rmsDbController userNameOfApp];
    _registerName.text = (self.rmsDbController.globalDict)[@"RegisterName"];
    [self updateDateLabel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self GetLastInvoice];
    });
    
    self.holdMessageView.hidden = YES;
    if(customerVC.isCustomerDeleted == YES){
        _lblCustomerName.text = @"";
        rcrRapidCustomerLoayalty = nil;

    }
    [self hideCustomerView];
}

#pragma mark - DashBoardVC Header Button Methods

- (IBAction)switchuserButtonClick:(UIButton *)sender
{
        [giftcardPopup dismissViewControllerAnimated:YES completion:nil];

        loginView = [[POSLoginView alloc] initWithNibName:@"POSVoidInvoiceLogin" bundle:nil];
        loginView.navigationController.navigationBar.hidden=YES;
        loginView.loginResultDelegate=self;
        loginView.view.frame = CGRectMake(0, 0, 1024, 768);
       
        [self.view addSubview:loginView.view];

}

-(void)userDidLogin:(NSMutableDictionary *)userdict{
    self.userName.text = [self.rmsDbController userNameOfApp];
    self.userName.backgroundColor = [UIColor redColor];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(changeColor) userInfo:nil repeats:NO];
    [loginView.view removeFromSuperview];
}

-(void)changeColor{
    self.userName.backgroundColor = [UIColor clearColor];
}

-(NSString *)logOutMessage
{
    return @"please complete or void this transcation.";
}

-(IBAction)logoutButtonClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    
    
    if (!(self.reciptDataAryForBillOrder.count > 0))
    {
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        for (UIViewController *viewController in viewControllerArray)
        {
            if ([viewController isKindOfClass:[POSLoginView class]])
            {
                [giftcardPopup dismissViewControllerAnimated:YES completion:nil];
                [self.rcrLeftSlideMenuVC.view removeFromSuperview];
                [self.navigationController popToViewController:viewController animated:TRUE];
                break;
            }
        }
    }
    else
    {
        [giftcardPopup dismissViewControllerAnimated:YES completion:nil];

        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:self.logOutMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

#pragma mark - Department and Favorite Methods

-(IBAction)loadDepartment:(id)sender
{
    self.departments.view.hidden = NO;
    self.favourite.view.hidden = YES;
    
    _departmentButton.selected = YES;
    _favouriteButton.selected = NO;

    [_departmentFavouriteContainer bringSubviewToFront:self.departments.view.superview];
    [_departmentFavouriteContainer sendSubviewToBack:self.favourite.view.superview];

}

-(void)setButtonSelectionState :(UIButton *)selectedButton defaultButton:(UIButton *)defaultButton
{
    [defaultButton setTitleColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1.0] forState:UIControlStateNormal];
    [selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(IBAction)loadFavouriteItem:(id)sender
{
    [_departmentFavouriteContainer sendSubviewToBack:self.departments.view.superview];
    [_departmentFavouriteContainer bringSubviewToFront:self.favourite.view.superview];
    self.departments.view.hidden = YES;
    self.favourite.view.hidden = NO;
    _departmentButton.selected = NO;
    _favouriteButton.selected = YES;
    

}
-(void)didAddItemFromFavouriteList :(NSString *)itemId
{
    [self didSelectItemRingupId:itemId];
}

#pragma mark - UITableView Delegate Method


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.itemRingUpResultController.sections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.itemRingUpResultController.sections;
    if (sections.count == 0) {
        return 1;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float headerHeight = [self tableHeaderHeight];
    
    RestaurantItem *restaurantItem = [self.itemRingUpResultController objectAtIndexPath:indexPath];
    NSDictionary *billDictionaryAtIndexPath  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail ];

        if ([[billDictionaryAtIndexPath[@"item"] valueForKey:@"isCheckCash"] boolValue] ==YES) {
        headerHeight += 20.0;
        }
    if([[billDictionaryAtIndexPath[@"item"]valueForKey:@"isExtraCharge"]boolValue]==YES)
        {
            headerHeight+=20.0;
        }
        if(billDictionaryAtIndexPath[@"InvoiceVariationdetail"])
        {
            headerHeight+= [billDictionaryAtIndexPath[@"InvoiceVariationdetail"] count ]*  20.0;
        }
        if([[billDictionaryAtIndexPath valueForKey:@"itemName"] isEqualToString:@"GAS"])
        {
            headerHeight = 140.0;
        }
 
	return headerHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tenderItemTableView )
    {
        if (isOpenEbt)
        {
            if ([self updateEBTApplicableForDisplayFlag:TRUE atIndexPath:indexPath] == TRUE)
            {
                [self.tenderItemTableView selectRowAtIndexPath:indexPath animated:TRUE scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

-(BOOL)updateEBTApplicableForDisplayFlag:(BOOL)isApplicableForDisplay atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isUpdateEBTApplicableFlag = FALSE;
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantItem *selectedRestaurantItem = [self.itemRingUpResultController objectAtIndexPath:indexPath];
    NSMutableDictionary *dict  = [NSKeyedUnarchiver unarchiveObjectWithData:selectedRestaurantItem.itemDetail];
    
   if ([[dict[@"item"]valueForKey:@"isExtraCharge"] boolValue] == TRUE || [[dict[@"item"]valueForKey:@"isDeduct"] boolValue] == TRUE || [[dict[@"item"]valueForKey:@"isCheckCash"] boolValue] == TRUE)
    {
        [self.tenderItemTableView deselectRowAtIndexPath:indexPath animated:YES];
        return isUpdateEBTApplicableFlag;

    }
    isUpdateEBTApplicableFlag = TRUE;
    dict[@"EBTApplicableForDisplay"] = @(isApplicableForDisplay);
    selectedRestaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:selectedRestaurantItem.objectID];
    selectedRestaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:dict];
    [UpdateManager saveContext:privateManageobjectContext];
    NSMutableArray *recieptBillArray = self.reciptDataAryForBillOrder;
    [rcrBillSummary updateBillSummrayWithDetail:recieptBillArray];
    [self updateBillSummaryWithReceiptArray:recieptBillArray];
    return isUpdateEBTApplicableFlag;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tenderItemTableView)
    {
        if (isOpenEbt)
        {
            [self updateEBTApplicableForDisplayFlag:FALSE atIndexPath:indexPath];
        }
    }
}

-(NSString *)sectionNameForHeader:(NSString *)sectionName
{
    return @"";
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self sectionNameForHeader:self.itemRingUpResultController.sections[section].name];
}

- (UITableViewCell *)noItemCell:(UITableView *)tableView
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"NoItems"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoItems"];
    }
    UILabel * noitemLebel = cell.textLabel;
    noitemLebel.text = @"No items were selected.";
    noitemLebel.textAlignment = NSTextAlignmentCenter;
    noitemLebel.backgroundColor = [UIColor clearColor];
    noitemLebel.textColor = [UIColor darkGrayColor];
    noitemLebel.font = [UIFont boldSystemFontOfSize:12];
    return cell;
}

-(IBAction)toggleSelection:(id)sender
{
    if (tenderItemTableView.allowsMultipleSelection == YES)
    {
        tenderItemTableView.allowsMultipleSelection = NO;
        [sender setTitle:@"Single Selection" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"singleSelection.png"] forState:UIControlStateNormal];
    }
    else
    {
        [sender setTitle:@"Multiple Selection" forState:UIControlStateNormal];
        tenderItemTableView.allowsMultipleSelection = YES;
        [sender setImage:[UIImage imageNamed:@"multiSelection.png"] forState:UIControlStateNormal];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.reciptDataAryForBillOrder.count == 0)
    {
        cell = [self noItemCell:tableView];
    }
    else
    {
        static NSString *CellIdentifier = @"TenderItemTableViewCell";
        TenderItemTableCustomCell *tenderItemCell = (TenderItemTableCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        tenderItemCell.currencyFormatter = self.crmController.currencyFormatter;
        tenderItemCell.indexPathForCell = indexPath;
        tenderItemCell.tenderItemTableCellDelegate = self;
        
        RestaurantItem *restaurantItem = [self.itemRingUpResultController objectAtIndexPath:indexPath];
        
        if(restaurantItem.isPrinted.integerValue==1){
            
            tenderItemCell.backgroundColor = [UIColor lightGrayColor];
        }
        else{
           tenderItemCell.backgroundColor = [UIColor clearColor];
        }
        NSDictionary *billDictionaryAtIndexPath  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail ];

        Item *item = [self fetchAllItems:[billDictionaryAtIndexPath valueForKey:@"itemId"]];
        [tenderItemCell updateCellWithBillItem:billDictionaryAtIndexPath withItem:item];
        

        if([[billDictionaryAtIndexPath valueForKey:@"itemName"] isEqualToString:@"GAS"]){

//            cell = [self loadGasPumpCell:indexPath withItemDetail:billDictionaryAtIndexPath];
//
//            UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(itemEditSwipe:)];
//            swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
//            [cell.contentView addGestureRecognizer:swipeGesture];
//            return cell;
            
        }
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(itemEditSwipe:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [tenderItemCell.contentView addGestureRecognizer:swipeGesture];
        [_barcodeScanTextField becomeFirstResponder];
        
        cell = tenderItemCell;
    }
    
    return cell;
}

//-(UITableViewCell *)loadGasPumpCell:(NSIndexPath *)indexPath withItemDetail:(NSDictionary *)itemDetail{
////
////    TenderGasItemCustomCell *gasCell = [self.tenderItemTableView dequeueReusableCellWithIdentifier:@"TenderGasItemCustomCell" forIndexPath:indexPath];
////    gasCell.selectionStyle = UITableViewCellSelectionStyleNone;
////    gasCell.currencyFormatter = self.crmController.currencyFormatter;
////    [gasCell updateGasCellWithBillItem:itemDetail];
////    return gasCell;
//}


-(CGRect)frameForSwipeEditView
{
    CGRect frameForSwipeEditView = CGRectMake(650, 64, 405, 592);
    return frameForSwipeEditView;
}
-(NSString *)ItemSwipeEditIdentifier
{
    return @"ItemSwipeEditRestaurantVC";
}
-(NSMutableDictionary *)billDictionaryAtIndexpath:(NSIndexPath *)indexpath
{
    RestaurantItem *restaurantItem = [self.itemRingUpResultController objectAtIndexPath:indexpath];
    NSMutableDictionary *billDictionaryAtIndexPath  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail ];
    return billDictionaryAtIndexPath;
}

- (void)launchSwipeEditView:(NSIndexPath *)swipedIndexPath
{
    
    RestaurantItem *restaurantItem = [self.itemRingUpResultController objectAtIndexPath:swipedIndexPath];
    NSMutableDictionary *billSwipeDictionary  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail ];
    if ([[billSwipeDictionary valueForKey:@"itemName"] isEqualToString:@"RapidRMS Gift Card"]) {
        return;
    }
    NSDictionary *itemSwipeDictionary = @{kPosItemSwipeKey: [billSwipeDictionary  valueForKey:@"itemId"]};

    [Appsee addEvent:kPosItemSwipe withProperties:itemSwipeDictionary];

    [self removeViewFromMainViewWithTag:ITEM_SWIPE_EDIT_TAG];
    self.selectedItemIndexPath = swipedIndexPath;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    itemSwipeEditVC = [storyBoard instantiateViewControllerWithIdentifier:@"ItemSwipeEditRestaurantVC"];
    itemSwipeEditVC.swipeDictionary = billSwipeDictionary;
    itemSwipeEditVC.moduleIdentifier = [self moduleIdentifier];
    itemSwipeEditVC.itemSwipeEditDelegate = self;
    itemSwipeEditVC.isNoPrintForItem = restaurantItem.isNoPrint.boolValue;
    itemSwipeEditVC.view.tag = ITEM_SWIPE_EDIT_TAG;
    itemSwipeEditVC.view.frame =  CGRectMake(_popupContainerView.center.x, _popupContainerView.center.y, 415,596);
    [self presentViewAsModal:itemSwipeEditVC];
    [tenderItemTableView selectRowAtIndexPath:self.selectedItemIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

-(void)itemEditSwipe:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tenderItemTableView];
    NSIndexPath *swipedIndexPath = [self.tenderItemTableView indexPathForRowAtPoint:location];
    [self launchSwipeEditView:swipedIndexPath];
}

-(NSMutableArray *)reciptDataAryForBillOrder
{
    NSMutableArray *reciptArray = [[NSMutableArray alloc]init];
    if (self.restaurantOrderObjectId == nil) {
        return reciptArray;
    }
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
    NSPredicate *resturantPrintPredicate = [NSPredicate predicateWithFormat:@"isCanceled = %@ ",@(FALSE)];
    NSArray *filterRestaurantBillArray = [restaurantOrder.restaurantOrderItem.allObjects filteredArrayUsingPredicate:resturantPrintPredicate];
    for (RestaurantItem *restaurantItem in filterRestaurantBillArray) {
        NSDictionary *billDictionaryAtIndexPath  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
        [reciptArray addObject:billDictionaryAtIndexPath];
    }
    [privateManageobjectContext reset];
    return reciptArray;
}

-(void)checkforGasPriceChanged:(NSMutableDictionary *)editDictionary{
    
    NSArray *arrayPump = [editDictionary[@"Pump"] componentsSeparatedByString:@" "];
//    for (RapidPetroCartPayment *prepayData in self.rmsDbController.rapidPetroPos.arrPumpCartTender) {
//        if (prepayData.paymentType == PaymentTypePrePay && prepayData.pumpIndex.integerValue == [arrayPump[1] integerValue]) {
//            prepayData.prePayAmountLimit =editDictionary[@"editItemPriceDisplay"];
//        }
////        if([prepayDict[@"selectedPump"] integerValue] == [arrayPump[1] integerValue]){
////            prepayDict[@"number"] = editDictionary[@"editItemPriceDisplay"];
////        }
//    }
}

-(void)didEditItemWithEditPrice :(BOOL)isEditPrice withEditedPrice:(NSNumber *)editedPrice withEditQty:(BOOL)isEditQty withBillEntry:(NSMutableDictionary *)editDictionary;
{
    [self.posMenuVC clearSelection];
    [self checkforGasPriceChanged:editDictionary];
    if (isEditQty)
    {
        [self setEditQtyStatusInBillEntry:editDictionary];
        NSDictionary *itemSwipeEditQtyDictionary = @{kPosItemSwipeQtyEditKey: [editDictionary valueForKey:@"itemQty"]};
        [Appsee addEvent:kPosItemSwipeQtyEdit withProperties:itemSwipeEditQtyDictionary];
    }
    
    [self removePresentModalView];
    
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantItem * restaurantItem = [self.itemRingUpResultController objectAtIndexPath:self.selectedItemIndexPath];
    if (editDictionary[@"NoPrintStatus"]) {
        restaurantItem.isNoPrint = @([[editDictionary valueForKey:@"NoPrintStatus"] boolValue]);
    }
    restaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:editDictionary];
    [UpdateManager saveContext:privateManageobjectContext];
    
    [self updateBillUI];
}
-(void)calCulatePriceAtPosDiscountWith:(NSMutableDictionary *)priceAtPosDiscountDict withItemPrice:(NSString*)itemPrice
{
    if ([priceAtPosDiscountDict[@"PriceAtPos"] floatValue] > 0)
    {
        float discPrice = 0.0;
        if ([priceAtPosDiscountDict[@"ItemBasicPrice"] floatValue] > [priceAtPosDiscountDict[@"PriceAtPos"] floatValue]) {
            discPrice = [priceAtPosDiscountDict[@"ItemBasicPrice"] floatValue] - [priceAtPosDiscountDict[@"PriceAtPos"] floatValue];
        }
        
        priceAtPosDiscountDict[@"itemPrice"] = @([priceAtPosDiscountDict[@"PriceAtPos"] floatValue]);
        priceAtPosDiscountDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%.2f",discPrice];
        float  totalItemPercenatge = discPrice / [priceAtPosDiscountDict[@"ItemBasicPrice"] floatValue] * 100;
        priceAtPosDiscountDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
    }
    else
    {
        priceAtPosDiscountDict[@"itemPrice"] = @(itemPrice.floatValue);
        priceAtPosDiscountDict[@"ItemDiscount"] = @"0";
        priceAtPosDiscountDict[@"ItemDiscountPercentage"] = @(0);
    }
    
}
-(void)didCancelEditSwipe
{
    [Appsee addEvent:kPosItemSwipeCancel];
    [self.posMenuVC clearSelection];
    [self removePresentModalView];
}
-(void)didRemoveItem
{
    RestaurantItem *restaurantItem = [self.itemRingUpResultController objectAtIndexPath:self.selectedItemIndexPath];
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    restaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:restaurantItem.objectID];

    NSMutableDictionary *billEntry  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
    NSDictionary *itemSwipeRemoveDictionary = @{kPosItemSwipeRemoveKey: [billEntry valueForKey:@"itemId"]};
    [Appsee addEvent:kPosItemSwipeRemove withProperties:itemSwipeRemoveDictionary];
    
    if ([[billEntry valueForKey:@"HouseChargeAmount"] floatValue] > 0.00)
    {
        isHouseChargeCollectPay = FALSE;
    }
//    if(self.rmsDbController.rapidPetroPos && self.rmsDbController.rapidPetroPos.arrPumpCartTender.count>0){
//
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ObjectID != %@",restaurantItem.objectID];
//
//        NSArray *prepayArray = [self.rmsDbController.rapidPetroPos.arrPumpCartTender filteredArrayUsingPredicate:predicate];
//        self.rmsDbController.rapidPetroPos.arrPumpCartTender = [[NSMutableArray alloc]initWithArray:prepayArray] ;
//    }
    [self.posMenuVC clearSelection];
    [self removePresentModalView];

    restaurantItem.isCanceled = @(TRUE);
    restaurantItem.quantity = @(0);
    restaurantItem.isPrinted = @(FALSE);
    [UpdateManager saveContext:privateManageobjectContext];
    
    if (self.reciptDataAryForBillOrder.count ==0)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:@"ClearAllRecord" forKey:@"Tender"];
        [self.crmController writeDictionaryToCustomerDisplay:dict];
    }
    [self updateBillUI];
}

-(IBAction)clearBarcodeText:(id)sender
{
    _barcodeScanTextField.text = @"";
}

-(void)cancelRestaurantOrder
{
    if (self.restaurantOrderObjectId != nil) {
        NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
        restaurantOrder.state = @(CANCEL_ORDER);
        [UpdateManager saveContext:privateManageobjectContext];
    }
}
- (void)updateRestaurantItem:(NSMutableDictionary *)billEntry
{
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantItem *restaurentItem = (RestaurantItem *)[privateManageobjectContext objectWithID:(NSManagedObjectID *)billEntry[@"RestaurantItemObjectId"]];

    NSMutableDictionary *tempDictionary = [billEntry mutableCopy];
    [tempDictionary removeObjectForKey:@"RestaurantItemObjectId"];
    restaurentItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:tempDictionary];
    restaurentItem.quantity = @([[billEntry valueForKey:@"itemQty"] intValue]);
    
    if (restaurentItem.quantity.integerValue != restaurentItem.previousQuantity.integerValue ) {
        restaurentItem.isPrinted = @(FALSE);
    }
    else
    {
        restaurentItem.isPrinted = @(TRUE);
    }
    [UpdateManager saveContext:privateManageobjectContext];
}
-(void)didAddQtyAtIndxPath:(NSIndexPath *)indexpath
{
    RestaurantItem *restaurantItem = [self.itemRingUpResultController objectAtIndexPath:indexpath];
    NSMutableDictionary *billEntry  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
    [self setEditQtyStatusInBillEntry:billEntry];
    [self.rmsDbController playButtonSound];
    
    if(![[billEntry valueForKey:@"itemName"] isEqualToString:@"RapidRMS Gift Card"] && ![[billEntry valueForKey:@"itemName"] isEqualToString:@"GAS"] && ![[billEntry valueForKey:@"itemName"] isEqualToString:@"HouseCharge"] )
    {
        [self.rmsDbController playButtonSound];
        NSMutableArray *reciptDataArray = [billEntry valueForKey:@"item"];
        
        if ([[reciptDataArray valueForKey:@"isCheckCash"] boolValue] == YES)
        {
            return;
        }
        
//        if ([[billEntry valueForKey:@"IsRefundFromInvoice"] isEqual:@(1)])
//        {
//            return;
//        }
//        
        self.scrollToIndexPath = indexpath;
        NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        restaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:restaurantItem.objectID];
        billEntry  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
        
        CGFloat perItemDiscount =  [billEntry[@"ItemDiscount"] floatValue] /  [billEntry[@"itemQty"] floatValue];
        
        CGFloat itemQty = [[billEntry valueForKey:@"itemQty"] floatValue] / [[billEntry valueForKey:@"PackageQty"] floatValue];
        itemQty = itemQty + 1;
        NSNumber * singleQTY = @(itemQty *  [[billEntry valueForKey:@"PackageQty"] floatValue]);
        billEntry[@"itemQty"] = [NSString stringWithFormat:@"%@", singleQTY ];
        
        if ([[billEntry objectForKey:@"IsRefundFromInvoice"] boolValue] == TRUE) {
            billEntry[@"ItemDiscount"] = @(perItemDiscount * [billEntry[@"itemQty"] floatValue]);
        }
        
        restaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:billEntry];
        restaurantItem.quantity = @([[billEntry valueForKey:@"itemQty"] intValue]);
        if (restaurantItem.quantity.integerValue != restaurantItem.previousQuantity.integerValue ) {
            restaurantItem.isPrinted = @(FALSE);
        }
        else
        {
            restaurantItem.isPrinted = @(TRUE);
        }
        [UpdateManager saveContext:privateManageobjectContext];
        [self updateBillUI];
    }
}
-(void)didSubtractQtyAtIndxPath:(NSIndexPath *)indexpath
{
    RestaurantItem *restaurantItem = [self.itemRingUpResultController objectAtIndexPath:indexpath];
    NSMutableDictionary *billEntry  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
    [self setEditQtyStatusInBillEntry:billEntry];
    
    [self.rmsDbController playButtonSound];
    if ([[billEntry valueForKey:@"itemQty"] intValue] > 1)
    {
//        if ([[billEntry valueForKey:@"IsRefundFromInvoice"] isEqual:@(1)])
//        {
//            return;
//        }
        self.scrollToIndexPath = indexpath;
        NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        restaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:restaurantItem.objectID];
        billEntry  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
        
        CGFloat perItemDiscount =  [billEntry[@"ItemDiscount"] floatValue] /  [billEntry[@"itemQty"] floatValue];
        CGFloat itemQty = [[billEntry valueForKey:@"itemQty"] floatValue] / [[billEntry valueForKey:@"PackageQty"] floatValue];
        
        itemQty = itemQty - 1;
        if (itemQty == 0) {
            return;
        }
        NSNumber * singleQTY = @(itemQty *  [[billEntry valueForKey:@"PackageQty"] floatValue]);
        billEntry[@"itemQty"] = [NSString stringWithFormat:@"%@", singleQTY ];
        
        if ([[billEntry objectForKey:@"IsRefundFromInvoice"] boolValue] == TRUE) {
            billEntry[@"ItemDiscount"] = @(perItemDiscount * [billEntry[@"itemQty"] floatValue]);
        }
        restaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:billEntry];
        restaurantItem.quantity = @([[billEntry valueForKey:@"itemQty"] intValue]);
        if (restaurantItem.quantity.integerValue != restaurantItem.previousQuantity.integerValue ) {
            restaurantItem.isPrinted = @(FALSE);
        }
        else
        {
            restaurantItem.isPrinted = @(TRUE);
        }
        [UpdateManager saveContext:privateManageobjectContext];
        [self updateBillUI];
    }
}

-(CGFloat)tableHeaderHeight
{
    return 75.0;
}

#pragma mark - DashBoardVC Footer Button Methods

-(IBAction)itemButtonClicked:(id)sender
{
    [Appsee addEvent:kPosMenuItem];
    [self.rmsDbController playButtonSound];
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self.rmsDbController playButtonSound];
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [[self.view viewWithTag:252322]removeFromSuperview ];
                       ItemDisplayViewController *objItemDisplay=[[ItemDisplayViewController alloc]initWithNibName:@"ItemDisplayViewController" bundle:nil];
                       objItemDisplay.rcrPosVcDeleage = self;
                       objItemDisplay.isItemForFavourite = FALSE;
                       [self presentViewController:objItemDisplay animated:YES completion:^{
                       }];
                       [_activityIndicator hideActivityIndicator];;
                   });
}

- (void)presentViewAsModal:(UIViewController *)presentedViewController {
    [self addChildViewController:presentedViewController];
    [self.presentedViewControllers addObject:presentedViewController];
    [self presentView:presentedViewController.view];
}

- (void)presentView:(UIView *)view {
    view.center = _popupContainerView.center;
    [_popupContainerView addSubview:view];
    _popupContainerView.hidden = NO;
    [self.view bringSubviewToFront:_popupContainerView];
}

-(IBAction)holdButtonClicked:(id)sender
{
    [Appsee addEvent:kPosMenuHold];
    [self.rmsDbController playButtonSound];
    if (self.reciptDataAryForBillOrder.count >0)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
        holdTransactionVC = [storyBoard instantiateViewControllerWithIdentifier:@"HoldTransactionVC"];
        holdTransactionVC.holdTransactionDelegate = self;
        holdTransactionVC.strMessage = holdMessage;
        holdTransactionVC.view.frame = CGRectMake(297, 209, 539, 620);
        [self presentViewAsModal:holdTransactionVC];
    }
    else
    {
        [self.posMenuVC clearSelection];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please add an Item to put on Hold." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)didHoldTransactionWithHoldMessage :(NSString *)message
{
    [self.posMenuVC clearSelection];
    holdMessage = message;
    [self removePresentModalView];
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    if (reciptArray.count > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
		NSMutableDictionary * param = [self getCurrentBillDataForBillOrder:reciptArray];
        holdDataDictionary = param;
        holdRemark = message;
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self holdInvoiceProcessResponse:response error:error];
            });
        };
        self.holdInvoiceWC = [self.holdInvoiceWC initWithRequest:KURL actionName:WSM_ADD_HOLD_INVOICE_LIST params:param completionHandler:completionHandler];
	}
}
- (void)holdInvoiceProcessResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                if (self.reciptDataAryForBillOrder.count > 0)
                {
                    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
                    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
                    
                    [self removeTenderBillData];
                    billAmountCalculator.billWiseDiscountType = BillWiseDiscountTypeNone;
                    [self hideCustomerView];
                    self.selectedCustomerDetail = nil;
                    rcrRapidCustomerLoayalty = nil;
                    [self clearBillUI];
                }
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else
    {
        [self insertOfflineHoldRecord];
        [self removeTenderBillData];
    }
    [self recallDataCount];
    self.crmController.isbillOrderFromRecall=FALSE;
    self.crmController.isbillOrderFromRecallOffline=FALSE;
    [_activityIndicator hideActivityIndicator];
}

- (void)removePresentModalView
{
    [self.posMenuVC clearSelection];
    [self removePresentedViewFromContainer];
}

- (void)removePresentedViewFromContainer {
    [self.presentedViewControllers.lastObject.view removeFromSuperview];
    [self.presentedViewControllers.lastObject removeFromParentViewController];
    [self.presentedViewControllers removeLastObject];
    if (self.presentedViewControllers.count == 0) {
        _popupContainerView.hidden = YES;
    }
}

- (void)removeView {
    for (UIView *presentView in _popupContainerView.subviews)
    {
        [presentView removeFromSuperview];
    }
    _popupContainerView.hidden = YES;
}

-(void)didCancelHoldTransaction
{
    [Appsee addEvent:kPosMenuHoldCancel];
    [self.posMenuVC clearSelection];
    
    [self removePresentModalView];
}
- (void)insertOfflineHoldRecord
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSMutableDictionary *holdDetailOfOffline = [[NSMutableDictionary alloc]init];
    holdDetailOfOffline[@"HoldRemark"] = holdRemark;
    holdDetailOfOffline[@"HoldUserName"] = (self.rmsDbController.globalDict)[@"RegisterName"];
    holdDetailOfOffline[@"HoldData"] = holdDataDictionary;

    float total = rcrBillSummary.totalSubTotalAmount.floatValue + rcrBillSummary.totalTaxAmount.floatValue;
    NSNumber *totalBillAmount= @(total);
    holdDetailOfOffline[@"HoldBillAmount"] = totalBillAmount.stringValue;
    if(self.crmController.isbillOrderFromRecall){
        
        NSInteger recallCount = self.crmController.recallInvoiceId.integerValue;
        holdDetailOfOffline[@"HoldTransActionNo"] = @(recallCount);
        [self.updateManager updateHoldTransctionInLocalDataBase:holdDetailOfOffline withContext:privateContextObject];
    }
    else{
        
        NSArray *offlineHoldInvoices = [self.updateManager fetchEntityFromDatabase:privateContextObject withEntityName:@"HoldInvoice"];
        NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"transActionNo" ascending:NO];
        NSArray *sortDescriptors = @[aSortDescriptor];
        offlineHoldInvoices = [offlineHoldInvoices sortedArrayUsingDescriptors:sortDescriptors];
        NSArray *transactionNumbers = [offlineHoldInvoices valueForKey:@"transActionNo"];
        NSInteger recallCount = [[transactionNumbers firstObject] integerValue] + 1 ;
        holdDetailOfOffline[@"HoldTransActionNo"] = @(recallCount);
        [self.updateManager insertHoldTransctionInLocalDataBase:holdDetailOfOffline withContext:privateContextObject];
    }
    billAmountCalculator.billWiseDiscountType = BillWiseDiscountTypeNone;
    [self clearBillUI];
}

-(void) recallDataCount
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self recallDataCountlistResponse:response error:error];
        });
    };

    self.recallCountServiceConnection = [self.recallCountServiceConnection initWithRequest:KURL actionName:WSM_RECALL_INVOICE_LIST_SERVICE params:param completionHandler:completionHandler];
    
}
- (void)updateRecallCountWithOfflineHoldInvoice {
    
    self.crmController.recallCount +=[self.updateManager fetchEntityObjectsCounts:@"HoldInvoice" withManageObjectContext:self.managedObjectContext];
    [self.posMenuVC setRecallCount:self.crmController.recallCount AtIndex:[self indexForPosMenuId:RECALL_POS_MENU]];
}

- (void)recallDataCountlistResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray * responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(responsearray.count>0)
                {
                    self.crmController.recallCount = responsearray.count;
                }
                else
                {
                    self.crmController.recallCount = responsearray.count;
                }
                [self updateRecallCountWithOfflineHoldInvoice];
            }
        }
    }
    else
    {
        self.crmController.recallCount = 0;
        [self updateRecallCountWithOfflineHoldInvoice];
    }
}

- (void)cancelTransaction:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self clearBillUI];
    }
}

- (void)VoidTransaction:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self VoidTransactions];
    }
}

- (void)configureItemTicketsPrintArrayForLastInvoice:(NSArray *)itemDetails
{
    locallastInvoiceTicketPassArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *item in itemDetails) {
        if (item[@"ItemTicketDetail"]) {
            
            NSArray * itemTicketDetail = item[@"ItemTicketDetail"];
            if ([itemTicketDetail isKindOfClass:[NSArray class]] && itemTicketDetail.count > 0) {
                
                for (NSMutableDictionary *itemTicketDictionary in itemTicketDetail) {
                    itemTicketDictionary[@"InvoiceNo"] = dictLastInvoiceInfo[@"LastInvoiceNo"];
                    itemTicketDictionary[@"ItemName"] = [item valueForKey:@"ItemName"];
                    [locallastInvoiceTicketPassArray addObject:itemTicketDictionary];
                }
            }
        }
    }
}

-(NSArray *)fetchLastInvoiceArray
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LastInvoiceData" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *lastInvoice = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    lastInvoice = [lastInvoice sortingArrayWithValue:@"regInvoiceNo" WithAscendingType:NO];
    return lastInvoice;
}

- (NSString *)lastInvoiceRecieptDate:(NSString *)strLastInvoiceDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *lastInvoiceDate = [dateFormatter dateFromString:strLastInvoiceDate];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    dateFormatter2.dateFormat = @"MM/dd/yyyy hh:mm a";
    return [dateFormatter2 stringFromDate:lastInvoiceDate];
}

-(void)printInvoiceReceipt
{
    NSArray * lastInvoiceArray = [self fetchLastInvoiceArray];
    if (lastInvoiceArray.count > 0)
    {
        LastInvoiceData *lastInvoiceData = lastInvoiceArray.firstObject;
        NSMutableArray * invoiceDetails = [NSKeyedUnarchiver unarchiveObjectWithData:lastInvoiceData.invoiceData];
        
        NSArray *itemDetails = [self itemDetailDictionary:[invoiceDetails.firstObject valueForKey:@"InvoiceItemDetail"]];
        NSArray *paymentArray = [invoiceDetails.firstObject valueForKey:@"InvoicePaymentDetail"];
        NSString *lastInvoiceDate = [self lastInvoiceRecieptDate:[[[invoiceDetails.firstObject valueForKey:@"InvoiceMst"] firstObject] valueForKey:@"Datetime"]];
        
        NSString *portName     = @"";
        NSString *portSettings = @"";
        [self SetPortInfo];
        
        portName     = [RcrController getPortName];
        portSettings = [RcrController getPortSettings];
        
        LastInvoiceReceiptPrint *lastInvoiceReceiptPrint = [[LastInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetails withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:lastInvoiceDate];
        [lastInvoiceReceiptPrint printInvoiceReceiptForInvoiceNo:dictLastInvoiceInfo[@"LastInvoiceNo"] withChangeDue:dictLastInvoiceInfo[@"LastChangeDue"] withDelegate:self];
    }
    else
    {
        [self nextPrint];
    }
}
-(void)printCardReciept
{
    NSArray * lastInvoiceArray = [self fetchLastInvoiceArray];
    
    if (lastInvoiceArray.count > 0)
    {
        LastInvoiceData *lastInvoiceData = lastInvoiceArray.firstObject;
        NSMutableArray *invoiceDetails = [NSKeyedUnarchiver unarchiveObjectWithData:lastInvoiceData.invoiceData];
        
        NSArray *paymentArray = [[invoiceDetails valueForKey:@"InvoicePaymentDetail"] firstObject];
        BOOL isCreditCardAvailable = [self isCreditCardAvailable:paymentArray];
        if (isCreditCardAvailable)
        {
            [self printCardRecieptFromArray:paymentArray invoiceDetails:invoiceDetails];
        }
        else
        {
            [self nextPrint];
        }
    }
    else
    {
        [self nextPrint];
    }
}
-(NSMutableArray *)getUserDetail{
    NSArray * lastInvoiceArray = [self fetchLastInvoiceArray];

    NSMutableArray *userDetail = [[NSMutableArray alloc]init];
    NSMutableDictionary *userDetailDict = [[NSMutableDictionary alloc]init];
    LastInvoiceData *lastInvoiceData = lastInvoiceArray.firstObject;
    NSMutableArray * invoiceDetails = [NSKeyedUnarchiver unarchiveObjectWithData:lastInvoiceData.invoiceData];
    NSMutableArray *masterDetails = [invoiceDetails.firstObject valueForKey:@"InvoiceMst"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Customer" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"custId == %@", [masterDetails.firstObject valueForKey:@"CustId"]];
    
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    NSLog(@"%@",resultSet.firstObject);
    if (resultSet.count > 0)
    {
        Customer *customer = resultSet.firstObject;
        userDetailDict[@"Custid"] = customer.custId;
        userDetailDict[@"CustName"] = customer.firstName;
        userDetailDict[@"CustEmail"] = customer.email;
        userDetailDict[@"CustContactNo"] = customer.contactNo;
        userDetailDict[@"AvailableBalance"] = [NSString stringWithFormat:@"%.2f",balaceAmount];
        userDetailDict[@"CreditLimit"] = [NSString stringWithFormat:@"%.2f",creditLimitValue];
        [userDetail addObject:userDetailDict];
        
    }
    return userDetail;
    
}
-(void)creditLimitForHouseCharge
{
    NSArray * lastInvoiceArray = [self fetchLastInvoiceArray];

    LastInvoiceData *lastInvoiceData = lastInvoiceArray.firstObject;
    NSMutableArray * invoiceDetails = [NSKeyedUnarchiver unarchiveObjectWithData:lastInvoiceData.invoiceData];
    NSMutableArray *masterDetails = [invoiceDetails.firstObject valueForKey:@"InvoiceMst"];

    NSMutableDictionary *param=[[NSMutableDictionary alloc]init];
    [param setValue:[masterDetails.firstObject valueForKey:@"CustId"] forKey:@"CustomerId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkHouseChargeCreditLimitWCResponce:response error:error];
        });
    };
    self.CheckHouseChargeCreditLimitWC = [self.CheckHouseChargeCreditLimitWC initWithRequest:KURL actionName:WSM_CUSTOMER_CREDIT_LIMIT params:param completionHandler:completionHandler];
    
}

-(void)checkHouseChargeCreditLimitWCResponce:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *dictBalance = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                balaceAmount = [[dictBalance valueForKey:@"Balance"] floatValue] ;
                creditLimitValue = [[dictBalance valueForKey:@"CreditLimit"] floatValue];
                
                if(![dictLastInvoiceInfo[@"LastInvoiceNo"] isEqualToString:@"-"])
                {
                    [self.rmsDbController playButtonSound];
                    
                    RcrPosVC * __weak myWeakReference = self;
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        [myWeakReference fetchAndPrintInvoiceData];
                    };
                    
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Do You Want To Print Last Receipt?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                }
            }
        }
    }
    else{
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            currentPrintStep++;
            [self nextPrint];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Can not reach to server for check credit limit. Do you want to retry?" buttonTitles:@[@"No",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (void)fetchAndPrintInvoiceData
{
    NSArray * lastInvoiceArray = [self fetchLastInvoiceArray];
    if (lastInvoiceArray.count > 0)
    {
        NSString *portName     = @"";
        NSString *portSettings = @"";
        
        [self SetPortInfo];
        portName     = [RcrController getPortName];
        portSettings = [RcrController getPortSettings];
        
        LastInvoiceData *lastInvoiceData = lastInvoiceArray.firstObject;
        NSMutableArray * invoiceDetails = [NSKeyedUnarchiver unarchiveObjectWithData:lastInvoiceData.invoiceData];
        
        NSMutableArray *itemDetails = [invoiceDetails.firstObject valueForKey:@"InvoiceItemDetail"];
        NSMutableArray *paymentDetails = [invoiceDetails.firstObject valueForKey:@"InvoicePaymentDetail"];
        NSMutableArray *masterDetails = [invoiceDetails.firstObject valueForKey:@"InvoiceMst"];
        
        RapidInvoicePrint *rapidInvoicePrint = [[RapidInvoicePrint alloc]init];

        NSArray *arrayPumpCart;
        if([self.rmsDbController checkGasPumpisActive]){
            
//            NSManagedObjectContext *privateMOC = [UpdateManager privateConextFromParentContext:self.rmsDbController.rapidPetroPos.petroMOC];
//            
//           arrayPumpCart = [self.updateManager fetcPumpCartWithName:@"PumpCart" key:@"regInvNum" value:[masterDetails.firstObject  valueForKey:@"RegisterInvNo"] moc:privateMOC];
//            
//            arrayPumpCart = [self createPumpCartArray:arrayPumpCart];
        }
        else{
            arrayPumpCart = nil;
        }
        rapidInvoicePrint.rapidCustomerArray = [self getUserDetail];

        rapidInvoicePrint.isFromCustomerLoyalty = FALSE;
        rapidInvoicePrint = [rapidInvoicePrint initWithPortName:portName portSetting:portSettings ItemDetail:itemDetails  withPaymentDetail:paymentDetails withMasterDetails:masterDetails fromViewController:self withTipSetting:self.tipSetting tipsPercentArray:nil withChangeDue:dictLastInvoiceInfo[@"LastChangeDue"] withPumpCart:[arrayPumpCart mutableCopy]];
        [rapidInvoicePrint startPrint];

    }
    return;
}

- (NSArray *)itemDetailDictionary:(NSArray *)itemDetailsArray
{
    if (itemDetailsArray.count > 0 ) {
        for (NSMutableDictionary *dict in itemDetailsArray) {
            NSMutableDictionary *dictToAdd = [[NSMutableDictionary alloc] init];
            dictToAdd[@"CheckCashCharge"] = [dict valueForKey:@"CheckCashAmount"];
            dictToAdd[@"ExtraCharge"] = [dict valueForKey:@"ExtraCharge"];
            if ([[dict valueForKey:@"ExtraCharge"] floatValue] > 0) {
                dictToAdd[@"isExtraCharge"] = @(1);
            }
            else
            {
                dictToAdd[@"isExtraCharge"] = @(0);
            }
            dictToAdd[@"isAgeApply"] = [dict valueForKey:@"isAgeApply"];
            dictToAdd[@"isCheckCash"] = [dict valueForKey:@"isCheckCash"];
            dictToAdd[@"isDeduct"] = [dict valueForKey:@"isDeduct"];
            dict[@"Item"] = dictToAdd;
        }
    }
    return itemDetailsArray;
}

- (float)variationCostForPrintbillEntryDictionary:(NSDictionary *)billEntryDictionary
{
    float variationCost=0.0;
    if(billEntryDictionary[@"InvoiceVariationdetail"])
    {
        NSArray *variationDetails = [billEntryDictionary valueForKey:@"InvoiceVariationdetail"];
        if ([variationDetails isKindOfClass:[NSArray class]] && variationDetails.count > 0)
        {
            variationCost = [[(NSArray *)billEntryDictionary[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.Price"] floatValue];
            variationCost = variationCost * [billEntryDictionary[@"ItemQty"]floatValue];
        }
    }
    return variationCost;
}

-(CGFloat)getSumOfTheValue:(NSString *)key forBillDetail:(NSArray *)billDetailArray
{
    CGFloat sum  = 0.00;
    for (NSDictionary *dictionary in billDetailArray) {
        sum += [[dictionary valueForKey:key] floatValue];
    }
    return sum;
}

-(void)GetLastInvoice
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LastInvoiceData" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *offlineInvoice = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    offlineInvoice = [offlineInvoice sortingArrayWithValue:@"regInvoiceNo" WithAscendingType:NO];
    if (offlineInvoice.count > 0)
    {
        dictLastInvoiceInfo=[[NSMutableDictionary alloc]init];
        LastInvoiceData *lastInvoiceData = offlineInvoice.firstObject;
        dictLastInvoiceInfo[@"LastInvoiceNo"] = [NSString stringWithFormat:@"%@",lastInvoiceData.regInvoiceNo];
        NSNumber *sLastInvoiceNo = @(lastInvoiceData.collectAmount.floatValue);
        dictLastInvoiceInfo[@"LastTenderedAmount"] = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sLastInvoiceNo]];
        dictLastInvoiceInfo[@"LastTenderedType"] = [NSString stringWithFormat:@"%@",lastInvoiceData.paymentType];
        NSNumber *sLasttenderAmount = @(lastInvoiceData.tenderAmount.floatValue);
        dictLastInvoiceInfo[@"LastBillAmount"] = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sLasttenderAmount]];
        NSNumber *sLastChangeDue = @(lastInvoiceData.changeDue.floatValue);
        dictLastInvoiceInfo[@"LastChangeDue"] = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sLastChangeDue]];
    }
}

-(void)printCardRecieptFromArray:(NSArray *)paymentDetails invoiceDetails:(NSArray *)invoiceDetails
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    
    
    NSString *lastInvoiceDate = [self lastInvoiceRecieptDate:[[[invoiceDetails.firstObject valueForKey:@"InvoiceMst"] firstObject] valueForKey:@"Datetime"]];
    
        CardReceiptPrint *cardReceiptPrint = [[CardReceiptPrint alloc] initWithPortName:portName portSetting:portSettings withPaymentDatail:paymentDetails tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:lastInvoiceDate];
        [cardReceiptPrint printCardReceiptForInvoiceNo:dictLastInvoiceInfo[@"LastInvoiceNo"] withDelegate:self];
}

//Credit Card Receipt

-(BOOL)isCreditCardAvailable :(NSArray *)paymentArray
{
    BOOL isCreditCardAvailable = NO;
    for(int i = 0;i<paymentArray.count;i++)
    {
        NSMutableDictionary *paymentDict = paymentArray[i];
        if([[paymentDict valueForKey:@"AuthCode"]length]>0 && [[paymentDict valueForKey:@"CardType"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0 && [[paymentDict valueForKey:@"AccNo"]length]>0)
        {
            if (!([[paymentDict valueForKey:@"SignatureImage"]length] >0))
            {
                isCreditCardAvailable = YES;
            }
        }
    }
    return isCreditCardAvailable;
}

#pragma mark - Discount

-(NSString *)setDiscountIdentifier
{
    NSString *discountIdentifier = @"TopUpDiscountVC";
    return discountIdentifier;
}
-(CGRect)topupDiscountFrame
{
    CGRect topupDiscountFrame = CGRectMake(self.view.frame.size.width ,14, 402, 740);
    return topupDiscountFrame;
}

-(IBAction)discountButtonClicked:(id)sender
{
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    if(reciptArray.count == 1)
    {
        [self.tenderItemTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:TRUE scrollPosition:UITableViewScrollPositionNone];
    }
    
    [Appsee addEvent:kPosMenuDiscount];
    [self.rmsDbController playButtonSound];
    BOOL hasRights = [UserRights hasRights:UserRightDiscount];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have discount rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    tenderItemTableView.allowsMultipleSelection = YES;
    
    if (giftcardPopOverController)
    {
        [topUpDiscountVC dismissViewControllerAnimated:YES completion:nil];
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    topUpDiscountVC = [storyBoard instantiateViewControllerWithIdentifier:@"TopUpDiscountVC"];
    topUpDiscountVC.topUpDiscountDelegate = self;
  
    topUpDiscountVC.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:topUpDiscountVC animated:YES completion:nil];
    
    giftcardPopOverController = [topUpDiscountVC popoverPresentationController];
    giftcardPopOverController.delegate = self;
    topUpDiscountVC.preferredContentSize = CGSizeMake(402, 650);
    giftcardPopOverController.permittedArrowDirections = 0;
    giftcardPopOverController.sourceView = self.view;
    giftcardPopOverController.passthroughViews = @[self.tenderItemTableView];
    giftcardPopOverController.sourceRect = CGRectMake(622 , 160 , 402, 650);
}

-(IBAction)removeTaxButtonClicked:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightTax];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to remove tax. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    [self didCancelTopupDiscount];
    [self removeViewFromMainViewWithTag:DISCOUNT_VIEW_TAG];
    [self removeViewFromMainViewWithTag:EBT_VIEW_TAG];
    [self.rmsDbController playButtonSound];
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    if(reciptArray.count>0)
    {
        tenderItemTableView.allowsMultipleSelection = YES;
        if (giftcardPopOverController)
        {
            [self.removeTaxVC dismissViewControllerAnimated:YES completion:nil];
        }
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
        self.removeTaxVC = [storyBoard instantiateViewControllerWithIdentifier:@"RemoveTaxVC"];
        self.removeTaxVC.removeTaxDelegate = self;

        self.removeTaxVC.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:self.removeTaxVC animated:YES completion:nil];
        giftcardPopOverController = [self.removeTaxVC popoverPresentationController];
        giftcardPopOverController.delegate = self;
        self.removeTaxVC.preferredContentSize = CGSizeMake(364, 440);
        giftcardPopOverController.permittedArrowDirections = 0;
        giftcardPopOverController.sourceView = self.view;
        giftcardPopOverController.passthroughViews = @[self.tenderItemTableView];
        giftcardPopOverController.sourceRect = CGRectMake(655, 164, 364, 440);
        [self selectedItems];
        [self.removeTaxVC removeAllTax:nil];
    }
}

#pragma mark - EBT

-(void)updateEbtDiplayFlagInLocalDatabaseForArray:(NSMutableArray *)receiptDataArray withIsThisChangeForAllItems:(BOOL )isThisChangeIsForAllItems
{
    for (NSMutableDictionary *dict in receiptDataArray)
    {
        if (isThisChangeIsForAllItems == TRUE) {
            dict[@"EBTApplicableForDisplay"] = @(isThisChangeIsForAllItems);
            continue;
        }
        BOOL isEbtApplicable = [[dict valueForKey:@"EBTApplicable"] boolValue];
        BOOL isEBTApplied = [[dict valueForKey:@"EBTApplied"] boolValue];
        if (isEBTApplied == TRUE) {
            dict[@"EBTApplicableForDisplay"] = @(FALSE);
        }
        else
        {
            dict[@"EBTApplicableForDisplay"] = @(isEbtApplicable);
        }
    }
}
-(void)removeEbtDiplayFlagInForArray:(NSMutableArray *)receiptDataArray
{
    for (NSMutableDictionary *dict in receiptDataArray)
    {
        BOOL isEbtApplicable = FALSE ;
        dict[@"EBTApplicableForDisplay"] = @(isEbtApplicable);
    }
}

-(IBAction)eBTButtonClicked:(id)sender
{
    /// Remove discount top up view if its display.........
    [self didCancelTopupDiscount];
    [self removeViewFromMainViewWithTag:DISCOUNT_VIEW_TAG];
    
    /// Remove Tax Remove view if its display.........
    [self removeViewFromMainViewWithTag:REMOVETAX_VIEW_TAG];
    
    [self.rmsDbController playButtonSound];
    
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    
    if(reciptArray.count>0)
    {
        // Put this line first always......
        tenderItemTableView.allowsMultipleSelection = YES;

        /// Configure ebt detail for reciept array......
        [self configureEBTDetailForBillWith:reciptArray];
        
        [self didSelectEBTApplicableItems];

        //// Remove EBT view tag if its display....
        [self removeViewFromMainViewWithTag:EBT_VIEW_TAG];

        /// Launch EBT ViewController.....
        
        if (giftcardPopOverController)
        {
            isOpenEbt = FALSE ;
            [self.eBTViewController dismissViewControllerAnimated:YES completion:nil];
        }
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
        self.eBTViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EBTViewController"];

        self.eBTViewController.eBTDelegate = self;
        isOpenEbt = TRUE ;
        self.eBTViewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:self.eBTViewController animated:YES completion:nil];
        
        giftcardPopOverController = [self.eBTViewController popoverPresentationController];
        giftcardPopOverController.delegate = self;
        self.eBTViewController.preferredContentSize = CGSizeMake(330, 390);
        giftcardPopOverController.permittedArrowDirections = 0;
        giftcardPopOverController.sourceView = self.view;
        giftcardPopOverController.passthroughViews = @[self.tenderItemTableView];
        giftcardPopOverController.sourceRect = CGRectMake(680, 164, 330, 390);
    }
}
-(void)didCancelTransaction
{
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    
    if(reciptArray.count>0)
    {
        [rcrBillSummary updateBillSummrayWithDetail:reciptArray];
        [self updateBillSummaryWithReceiptArray:reciptArray];
    }
}

-(void)configureEBTDetailForBillWith:(NSMutableArray *)reciptArray
{
    [self updateEbtDiplayFlagInLocalDatabaseForArray:reciptArray withIsThisChangeForAllItems:FALSE];
    [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:reciptArray];
    [rcrBillSummary updateBillSummrayWithDetail:reciptArray];
    [self updateBillSummaryWithReceiptArray:reciptArray];
}

-(void)didEbtAppliedWithMessage:(NSString *)strMessage
{
    NSArray *selectedRows = tenderItemTableView.indexPathsForSelectedRows;
    if ([self shouldEBTRestrictedForBill] == TRUE)
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self.eBTViewController title:@"Message" message:@"You can not apply EBT " buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;

    }
    if(selectedRows.count>0){
        billAmountCalculator.isEBTApplicaleForBill = YES;
        [self removeTaxForEBTWithMessage:strMessage];
        if (giftcardPopOverController)
        {
            isOpenEbt = FALSE ;
            [self.eBTViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        if(self.eBTViewController.imgChk1.hidden && self.eBTViewController.imgChk2.hidden){
            
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self.eBTViewController title:@"Message" message:@"Please select option" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self.eBTViewController title:@"Message" message:@"Please select items" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

- (void)removeTaxForEBTWithMessage:(NSString *)message
{
    [Appsee addEvent:kPosMenuDiscountRemove];
    [self.posMenuVC clearSelection];
    [self updateEBTApplicableAndAppliedValueInDatabase];
    tenderItemTableView.allowsMultipleSelection = NO;
    [self updateBillUI];
    [self removePresentModalView];
    if (giftcardPopOverController)
    {
        isOpenEbt = FALSE ;
        [self.eBTViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didRemoveEBT
{
    billAmountCalculator.isEBTApplicaleForBill = FALSE;
    
    NSMutableArray *tenderReciptDataAry = self.reciptDataAryForBillOrder;
    
    for (NSMutableDictionary *receiptDictionary in tenderReciptDataAry) {
        BOOL isEbtApplicable = [[receiptDictionary valueForKey:@"EBTApplicable"] boolValue];
        if (isEbtApplicable) {
            receiptDictionary[@"EBTApplied"] = @(0);
        }
        Item *anItem = [self fetchAllItems:receiptDictionary[@"itemId"]];
        NSMutableArray *taxDetail = [billAmountCalculator fetchTaxDetailForItem:anItem];
        if (taxDetail != nil) {
            receiptDictionary[@"ItemTaxDetail"] = taxDetail;
             receiptDictionary[@"EBTApplicableForDisplay"] = @(FALSE);
        }
    }
    [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:tenderReciptDataAry];
    [self updateBillUI];
    
    [self.posMenuVC clearSelection];
    tenderItemTableView.allowsMultipleSelection = NO;
    if (giftcardPopOverController)
    {
        isOpenEbt = FALSE ;
        [self.eBTViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didSelectEBTItemsWithIsThisChangeForAllItems:(BOOL)isThisChangeForAllItems;
{
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    if(reciptArray.count>0)
    {
        [self updateEbtDiplayFlagInLocalDatabaseForArray:reciptArray withIsThisChangeForAllItems:isThisChangeForAllItems];
        [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:reciptArray];
        [rcrBillSummary updateBillSummrayWithDetail:reciptArray];
        [self updateBillSummaryWithReceiptArray:reciptArray];
    }
    [self didSelectEBTApplicableItems];
}

-(void)didSelectEBTApplicableItems
{
    for (int section = 0; section < self.tenderItemTableView.numberOfSections; section ++)
    {
        for (int row = 0; row < [self.tenderItemTableView numberOfRowsInSection:section]; row ++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            RestaurantItem *selectedRestaurantItem = [self.itemRingUpResultController objectAtIndexPath:indexPath];
            NSMutableDictionary *dict  = [NSKeyedUnarchiver unarchiveObjectWithData:selectedRestaurantItem.itemDetail];
          if ([[dict[@"item"]valueForKey:@"isExtraCharge"] boolValue] == TRUE || [[dict[@"item"]valueForKey:@"isDeduct"] boolValue] == TRUE || [[dict[@"item"]valueForKey:@"isCheckCash"] boolValue] == TRUE)
            {
                continue;
            }

            if ([[dict valueForKey:@"EBTApplicableForDisplay"] boolValue] == TRUE && [[dict valueForKey:@"EBTApplied"] boolValue] == FALSE) {
                [self.tenderItemTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

-(void)didCancelEBT
{
    [self.posMenuVC clearSelection];
    tenderItemTableView.allowsMultipleSelection = NO;
    if (giftcardPopOverController)
    {
        isOpenEbt = FALSE ;
        [self.eBTViewController dismissViewControllerAnimated:YES completion:nil];
    }

    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    if (reciptArray>0)
    {
        [self removeEbtDiplayFlagInForArray:reciptArray];
        [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:reciptArray];
        [rcrBillSummary updateBillSummrayWithDetail:reciptArray];
        [self updateBillSummaryWithReceiptArray:reciptArray];
    }
}

-(void)buttonManagerReportsTapped:(id)sender{
    [self.posMenuVC clearSelection];
    RapidWebViewVC * rapidWebVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidWebViewVC_sid"];
    rapidWebVC.pageId=PageIdManagerReports;
    [self.navigationController pushViewController:rapidWebVC animated:YES];
}

-(void)didCancelRemoveTax
{
    [Appsee addEvent:kPosMenuDiscountCancel];
    [self.posMenuVC clearSelection];
    tenderItemTableView.allowsMultipleSelection = NO;
    
    if (giftcardPopOverController)
    {
        [self.removeTaxVC dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didSelectAll{

    for (int section = 0; section < self.tenderItemTableView.numberOfSections; section ++)
    {
        for (int row = 0; row < [self.tenderItemTableView numberOfRowsInSection:section]; row ++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [self.tenderItemTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}
-(void)selectedItems{
    
    for (int section = 0; section < self.tenderItemTableView.numberOfSections; section ++)
    {
        for (int row = 0; row < [self.tenderItemTableView numberOfRowsInSection:section]; row ++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [self.tenderItemTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

#pragma mark-
#pragma mark- DiscountDelegate Methods

- (void)logForbillDiscountAmount:(NSString *)amount
{
    NSString *strbillold = [NSString stringWithFormat:@"%@%%",amount];
    strbillold = [strbillold substringFromIndex:1];
    [self createInvoiceLogsArray:@"BillwiseDiscount" withOperation:@"change" withOldValue:@"0.00" andNewValue:strbillold withItemCode:@"0" withMessage:@""];
}

- (void)billDiscountLogForAmount:(NSString *)amount
{
    BOOL boolBillDiscount = NO;
    
    switch (billAmountCalculator.billWiseDiscountType) {
        case BillWiseDiscountTypeNone:
            boolBillDiscount = NO;

            break;
        case BillWiseDiscountTypeAmount:
            boolBillDiscount = YES;
            [self logForbillDiscountAmount:amount];


            break;
        case BillWiseDiscountTypePercentage:
            boolBillDiscount = YES;
            [self logForbillDiscountAmount:amount];
            break;
            
        default:
            break;
    }
    
    NSString *strbill = [NSString stringWithFormat:@"%@%%",billAmountCalculator.billWiseDiscount];
    if(!boolBillDiscount){
        [self createInvoiceLogsArray:@"BillwiseDiscount" withOperation:@"add" withOldValue:@"0.00" andNewValue:strbill withItemCode:@"0" withMessage:@""];
    }
}

- (void)applyBillDiscountForAmount:(NSString *)amount withSelectedDiscountType:(NSString *)selectedDiscountType withDiscountId:(NSNumber *)discountId
{
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    for(int i=0;i<reciptArray.count;i++)
    {
        NSMutableDictionary *dict = reciptArray[i];
        
        [dict setValue:@"0" forKey:@"ItemDiscount"];
        [dict setValue:selectedDiscountType forKey:@"SalesManualDiscountType"];
        dict[@"SalesManualDiscountId"] = discountId;

        dict[@"ItemDiscountPercentage"] = @(0);
        [dict removeObjectForKey:@"ItemWiseDiscountValue"];
        [dict removeObjectForKey:@"ItemWiseDiscountType"];
        
        NSString *strbillold = [NSString stringWithFormat:@"%@%%",amount];
        strbillold = [strbillold substringFromIndex:1];
        
        float percentage = 0.00;
        if (amount.length > 0) {
           percentage = [amount substringFromIndex:1].floatValue;
        }
        
        NSString *strDisAmt = [NSString stringWithFormat:@"%.2f",[dict[@"ItemBasicPrice"] floatValue] * percentage/100];
        
        [self setDiscountDetail:dict withType:BILL_WISE_PER_MANUAL discount:strbillold discountAmount:strDisAmt];
        
    }
    [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:reciptArray];
    [self billDiscountLogForAmount:amount];
}

-(void)didAddTopupDiscountWithDiscountType :(NSString *)discountType withDiscountAmount:(NSString *)amount withItemDiscountType:(NSString *)itemDiscountType
                       selectedDiscountType:(NSString *)selectedDiscountType withItemDiscountID:(NSNumber *)discountId
{
    NSMutableDictionary *detailDict = [[NSMutableDictionary alloc] init];
    detailDict[@"DiscountType"] = discountType;
    if (amount == nil)
    {
        amount = [self.rmsDbController applyCurrencyFomatter:@"0.00"];
    }
    detailDict[@"Amount"] = amount;
    detailDict[@"ItemDiscountType"] = itemDiscountType;
    [self.posMenuVC clearSelection];
    
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    if ([itemDiscountType isEqualToString:@"Per"])
    {
        if ([discountType isEqualToString:@"Item"])
        {
            NSArray *selectedRows = tenderItemTableView.indexPathsForSelectedRows;
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                RestaurantItem *selectedRestaurantItem = [self.itemRingUpResultController objectAtIndexPath:selectionIndex];
                NSMutableDictionary *dict  = [NSKeyedUnarchiver unarchiveObjectWithData:selectedRestaurantItem.itemDetail];
                float  itemWiseDiscountValue = [amount stringByReplacingOccurrencesOfString:@"%" withString:@""].floatValue;
                NSString *strType = @"add";
                if([dict valueForKey:@"ItemWiseDiscountValue"]){
                    float  imemdisold = [[dict valueForKey:@"ItemWiseDiscountValue"]floatValue];
                    if(imemdisold != itemWiseDiscountValue){
                        strType = @"change";
                    }
                }
                dict[@"ItemWiseDiscountValue"] = [NSString stringWithFormat:@"%f",itemWiseDiscountValue];
                dict[@"ItemWiseDiscountType"] = @"Percentage";
                dict[@"SalesManualDiscountType"] = selectedDiscountType;
                dict[@"SalesManualDiscountId"] = discountId;

                
                [self createInvoiceLogsArray:@"ItemwiseDiscount" withOperation:strType withOldValue:@"0.00" andNewValue:[NSString stringWithFormat:@"%f",itemWiseDiscountValue] withItemCode:[dict valueForKey:@"itemId"] withMessage:@""];
                
                NSString *strPer = [NSString stringWithFormat:@"%.2f%%",[dict[@"ItemWiseDiscountValue"] floatValue]];
                NSString *strDisAmt = [NSString stringWithFormat:@"%.2f",[dict[@"ItemBasicPrice"] floatValue] * [dict[@"ItemWiseDiscountValue"] floatValue]/100];
                [self setDiscountDetail:dict withType:ITEM_WISE_PER_MANUAL discount:strPer discountAmount:strDisAmt];
                
                selectedRestaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:selectedRestaurantItem.objectID];
                selectedRestaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:dict];
                [UpdateManager saveContext:privateManageobjectContext];
            }
        }
        else if ([discountType isEqualToString:@"Bill"])
        {
            billAmountCalculator.billWiseDiscountType = BillWiseDiscountTypePercentage;
            billAmountCalculator.billWiseDiscount = @([amount stringByReplacingOccurrencesOfString:@"%" withString:@""].floatValue);
            [self applyBillDiscountForAmount:amount withSelectedDiscountType:selectedDiscountType withDiscountId:discountId];
            
        }
    }
    else if ([itemDiscountType isEqualToString:@"Amount"])
    {
        if ([discountType isEqualToString:@"Item"])
        {
            NSArray *selectedRows = tenderItemTableView.indexPathsForSelectedRows;
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                NSString *discountValue = [amount stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
                float discPrice=[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:discountValue].floatValue].floatValue;
                RestaurantItem *selectedRestaurantItem = [self.itemRingUpResultController objectAtIndexPath:selectionIndex];
                NSMutableDictionary *dict  = [NSKeyedUnarchiver unarchiveObjectWithData:selectedRestaurantItem.itemDetail];
                
                CGFloat basicPrice = [[dict valueForKey:@"ItemBasicPrice"] floatValue];
                if (basicPrice < 0 ) {
                    basicPrice  = - basicPrice;
                    
                }
                if (basicPrice >= discPrice )
                {
                    dict[@"ItemWiseDiscountValue"] = amount;
                    dict[@"ItemWiseDiscountType"] = @"Amount";
                    dict[@"SalesManualDiscountType"] = selectedDiscountType;
                    dict[@"SalesManualDiscountId"] = discountId;

                    selectedRestaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:selectedRestaurantItem.objectID];
                    selectedRestaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:dict];
                    [UpdateManager saveContext:privateManageobjectContext];
                    
                    if ([discountType isEqualToString:@"Item"])
                    {
                        [self createInvoiceLogsArray:@"ItemwiseDiscount" withOperation:@"add" withOldValue:@"0.00" andNewValue:amount withItemCode:[dict valueForKey:@"itemId"] withMessage:@""];
                        
                        NSString *strPer = [NSString stringWithFormat:@"%@",amount];
                        NSString *strDisAmt = [NSString stringWithFormat:@"%@",amount];
                        [self setDiscountDetail:dict withType:ITEM_WISE_D_MANUAL discount:strPer discountAmount:strDisAmt];
                        
                    }
                    else if ([discountType isEqualToString:@"Bill"])
                    {
                        [self createInvoiceLogsArray:@"BillwiseDiscount" withOperation:@"add" withOldValue:@"0.00" andNewValue:amount withItemCode:@"0" withMessage:@""];
                    
                        NSString *strPer = [NSString stringWithFormat:@"%.2f%%",[dict[@"ItemWiseDiscountValue"] floatValue]];
                        NSString *strDisAmt = [NSString stringWithFormat:@"%.2f",[dict[@"ItemBasicPrice"] floatValue] * [dict[@"ItemWiseDiscountValue"] floatValue]/100];
                        [self setDiscountDetail:dict withType:BILL_WISE_D_MANUAL discount:strPer discountAmount:strDisAmt];
                    }
                }
            }
        }
        else if ([discountType isEqualToString:@"Bill"])
        {
            billAmountCalculator.billWiseDiscountType = BillWiseDiscountTypeAmount;
            NSString *sAmount=[amount stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
            CGFloat fsAmount = [self.crmController.currencyFormatter numberFromString:sAmount].floatValue;
            billAmountCalculator.billWiseDiscount = @(fsAmount);
            [self applyBillDiscountForAmount:amount withSelectedDiscountType:selectedDiscountType withDiscountId:discountId];
        }
    }
    
    for(NSDictionary *dictInvLog in _itemLogArray){
        [self.crmController.reciptItemLogDataAry addObject:dictInvLog];
    }
    [_itemLogArray removeAllObjects];
    
    if (giftcardPopOverController)
    {
        [topUpDiscountVC dismissViewControllerAnimated:YES completion:nil];
    }

    tenderItemTableView.allowsMultipleSelection = NO;
    [self updateBillUI];
}


-(void)setDiscountDetail:(NSMutableDictionary *)itemDict withType:(int)intDiscountType discount:(NSString *)strDis discountAmount:(NSString *)strDisAmt{
    return;
    NSMutableArray *dicountArray = itemDict[@"Discount"];
    
    if([dicountArray isKindOfClass:[NSString class]]){
        
        NSMutableArray *arrayDis = [[NSMutableArray alloc]init];
        NSMutableDictionary *dictDis = [[NSMutableDictionary alloc]init];
        dictDis[@"DiscountType"] = [NSString stringWithFormat:@"%d",intDiscountType];
        dictDis[@"Discount"] = strDis;
        dictDis[@"DiscountAmount"] = strDisAmt;
        [arrayDis addObject:dictDis];
        itemDict[@"Discount"] = arrayDis;
    }
    else{
        
        NSMutableDictionary *dictDis = [[NSMutableDictionary alloc]init];
        dictDis[@"DiscountType"] = [NSString stringWithFormat:@"%d",intDiscountType];
        dictDis[@"Discount"] = strDis;
        dictDis[@"DiscountAmount"] = strDisAmt;
        [dicountArray addObject:dictDis];
        itemDict[@"Discount"] = dicountArray;
    }

}

-(void)createInvoiceLogsArray:(NSString *)strfieldname withOperation:(NSString *)strOperation withOldValue:(NSString *)strOldValue andNewValue:(NSString *)strNewValue withItemCode:(NSString *)strItemCode withMessage:(NSString *)reason{
    
    NSMutableDictionary *dictInvoiceLog = [[NSMutableDictionary alloc]init];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    dictInvoiceLog[@"Id"] = @"0";
    dictInvoiceLog[@"RegisterId"] = @"0";
    dictInvoiceLog[@"InvoiceNo"] = @"0";
    dictInvoiceLog[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dictInvoiceLog[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    dictInvoiceLog[@"TimeStamp"] = strDateTime;
    dictInvoiceLog[@"ItemCode"] = strItemCode;
    dictInvoiceLog[@"FieldName"] = strfieldname;
    dictInvoiceLog[@"Operation"] = strOperation;
    dictInvoiceLog[@"OldValue"] = strOldValue;
    dictInvoiceLog[@"NewValue"] = strNewValue;
    dictInvoiceLog[@"Reason"] = reason;
    [_itemLogArray addObject:dictInvoiceLog];
}

-(void)didremoveTax:(NSString *)strMessage
{
    NSArray *selectedRows = tenderItemTableView.indexPathsForSelectedRows;
    if(selectedRows.count>0)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            if (giftcardPopOverController)
            {
                [self.removeTaxVC dismissViewControllerAnimated:YES completion:nil];
            }
            [self  removeTaxWithMessage:strMessage];
        };
        [self.rmsDbController popupAlertFromVC:self.removeTaxVC title:@"Message" message:@"Are you sure you want remove tax from items?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
    else{
    
        if(removeTaxVC.imgChk1.hidden && removeTaxVC.imgChk2.hidden)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self.removeTaxVC title:@"Message" message:@"Please select option" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self.removeTaxVC title:@"Message" message:@"Please select items" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

-(void)removeTaxWithMessage :(NSString *)message{
    
    [Appsee addEvent:kPosMenuDiscountRemove];
    [self.posMenuVC clearSelection];
    removeTaxMessageVC.view.hidden = YES;
    [self removeTaxForItems:message];
    tenderItemTableView.allowsMultipleSelection = NO;
    [self updateBillUI];
    [self removePresentModalView];
}

-(void)launchRemoveTaxPopUp
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    removeTaxMessageVC = [storyBoard instantiateViewControllerWithIdentifier:@"RemoveTaxMessageVC"];
    removeTaxMessageVC.removeTaxPopUpMessageDelegate = self;
    [self presentViewAsModal:removeTaxMessageVC];
}

#pragma mark-
#pragma mark - RemoveTaxMessageVC Delegate Methods

-(void)openItemTaxRemoveMessagePopUp{
    
    [self launchRemoveTaxPopUp];
}

-(void)didsendRemoveTaxMessage :(NSString *)message{
    
    [itemSwipeEditVC removeTaxWithMessage:message];
    
    [Appsee addEvent:kPosMenuDiscountRemove];
    [self.posMenuVC clearSelection];
    removeTaxMessageVC.view.hidden = YES;
   [self removePresentModalView];
}
-(void)didCancelRemoveTaxPopup{
    
    [self removePresentModalView];
    [self didCancelRemoveTax];
}


-(void)didRemoveTopupDiscount
{
    [Appsee addEvent:kPosMenuDiscountRemove];
    [self.posMenuVC clearSelection];
    if (giftcardPopOverController)
    {
        [topUpDiscountVC dismissViewControllerAnimated:YES completion:nil];
    }
    [self removeTopupDiscount];
    tenderItemTableView.allowsMultipleSelection = NO;
    [self updateBillUI];
}

-(void)didCancelTopupDiscount
{
    [Appsee addEvent:kPosMenuDiscountCancel];
    [self.posMenuVC clearSelection];
    tenderItemTableView.allowsMultipleSelection = NO;

    
    if (giftcardPopOverController)
    {
        [topUpDiscountVC dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)removeTopupDiscount
{
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    for(int i=0;i<reciptArray.count;i++)
    {
        NSMutableDictionary *dict = reciptArray[i];
        if([dict valueForKey:@"ItemWiseDiscountValue"]){
            
            [self createInvoiceLogsArray:@"ItemwiseDiscount" withOperation:@"remove" withOldValue:[dict valueForKey:@"ItemWiseDiscountValue"] andNewValue:@"0.00" withItemCode:[dict valueForKey:@"itemId"] withMessage:@""];
        }
        [dict setValue:@"0" forKey:@"ItemDiscount"];
        dict[@"ItemDiscountPercentage"] = @(0);
        [dict removeObjectForKey:@"ItemWiseDiscountValue"];
        [dict removeObjectForKey:@"ItemWiseDiscountType"];
        
        NSMutableArray *dicountArray = dict[@"Discount"];
        if([dicountArray isKindOfClass:[NSMutableArray class]]){
            
            [self removeDiscount:dicountArray];
            
        }
        
      //  billAmountCalculator.billWiseDiscountApplied = FALSE;
        billAmountCalculator.billWiseDiscountType = BillWiseDiscountTypeNone;
        billAmountCalculator.billWiseDiscount = 0;
    }
    [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:reciptArray];
}

-(void)removeDiscount:(NSMutableArray *)discountArray{
    
    for (int i=0; i<discountArray.count; i++) {
        NSMutableDictionary *dict = discountArray[i];
        if([[dict valueForKey:@"DiscountType"]integerValue] == 6 || [[dict valueForKey:@"DiscountType"]integerValue] == 7 || [[dict valueForKey:@"DiscountType"]integerValue] == 8 || [[dict valueForKey:@"DiscountType"]integerValue] == 9){
            [discountArray removeObjectAtIndex:i];
        }
    }
}

-(void)removeTaxForItems:(NSString *)strMessage
{
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];

    NSArray *selectedRows = tenderItemTableView.indexPathsForSelectedRows;
    for (NSIndexPath *selectionIndex in selectedRows)
    {
        RestaurantItem *selectedRestaurantItem = [self.itemRingUpResultController objectAtIndexPath:selectionIndex];
        NSMutableDictionary *dict  = [NSKeyedUnarchiver unarchiveObjectWithData:selectedRestaurantItem.itemDetail];
        dict[@"ItemTaxDetail"] = @"";
        dict[@"TotalTaxPercentage"] = @"0.00";
        dict[@"itemTax"] = @(0.0);
        
        dict[@"ReasonType"] = @"Tax";
        if(strMessage){
            dict[@"Reason"] = strMessage;
        }
        else{
            dict[@"Reason"] = @"";
        }
        
        selectedRestaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:selectedRestaurantItem.objectID];
        selectedRestaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:dict];
        [UpdateManager saveContext:privateManageobjectContext];
    }
}

-(void)updateEBTAppliedWithMessage:(NSString *)strMessage
{
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    NSArray *selectedRows = tenderItemTableView.indexPathsForSelectedRows;
    for (NSIndexPath *selectionIndex in selectedRows)
    {
        RestaurantItem *selectedRestaurantItem = [self.itemRingUpResultController objectAtIndexPath:selectionIndex];
        NSMutableDictionary *dict  = [NSKeyedUnarchiver unarchiveObjectWithData:selectedRestaurantItem.itemDetail];
        BOOL isEbtApplicable = [[dict valueForKey:@"EBTApplicable"] boolValue];
        if (isEbtApplicable) {
            dict[@"EBTApplied"] = @(1);
            //[dict setObject:@"" forKey:@"ItemTaxDetail"];
            dict[@"TotalTaxPercentage"] = @"0.00";
            dict[@"itemTax"] = @(0.0);
            dict[@"ReasonType"] = @"Tax";
            if(strMessage){
                dict[@"Reason"] = strMessage;
            }
            else{
                dict[@"Reason"] = @"";
            }
        }
        selectedRestaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:selectedRestaurantItem.objectID];
        selectedRestaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:dict];
        [UpdateManager saveContext:privateManageobjectContext];
    }
}

-(BOOL)shouldEBTRestrictedForBill
{
    BOOL shouldEBTRestrictedForBill = FALSE;
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    for (NSMutableDictionary *dict in reciptArray)
    {
        if ([dict[@"ItemBasicPrice"]floatValue] < 0 || [[dict[@"item"]valueForKey:@"isCheckCash"] boolValue] == TRUE || [[dict[@"item"]valueForKey:@"isDeduct"] boolValue] == TRUE)
        {
            shouldEBTRestrictedForBill = TRUE;
            break;
        }
        
    }
    return shouldEBTRestrictedForBill;

}

-(BOOL)shouldRefundRestrictedForItem:(Item *)anItem
{
    BOOL shouldRefundRestrictedForItem = FALSE;
  
    if (anItem.itemDepartment != nil )
    {
        if (anItem.itemDepartment.chkExtra.boolValue == TRUE )
        {
            shouldRefundRestrictedForItem = TRUE;
        }
    }
    return shouldRefundRestrictedForItem;
    
}

-(BOOL)shouldEBTRestrictedForItem:(Item *)anItem
{
    BOOL shouldEBTRestrictedForItem = FALSE;
    if (anItem.isItemPayout.boolValue == TRUE || billAmountCalculator.itemRefund == TRUE)
    {
        shouldEBTRestrictedForItem = TRUE;
        
    }
    else if (anItem.itemDepartment != nil )
    {
        if (anItem.itemDepartment.chkCheckCash.boolValue == TRUE || anItem.itemDepartment.deductChk.boolValue == TRUE)
        {
            shouldEBTRestrictedForItem = TRUE;
        }
    }
       return shouldEBTRestrictedForItem;
    
}



-(void)updateEBTApplicableAndAppliedValueInDatabase
{
    NSArray *selectedRows = self.tenderItemTableView.indexPathsForSelectedRows;
    
    for (NSIndexPath *selectedRowIndexpath in selectedRows) {
        NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        RestaurantItem *selectedRestaurantItem = [self.itemRingUpResultController objectAtIndexPath:selectedRowIndexpath];
        NSMutableDictionary *dict  = [NSKeyedUnarchiver unarchiveObjectWithData:selectedRestaurantItem.itemDetail];
        
        if ([[dict valueForKey:@"EBTApplicableForDisplay"] boolValue] == TRUE)
        {
            dict [@"EBTApplied"] = @(TRUE);
            if ([[dict valueForKey:@"EBTApplicable"] boolValue] == FALSE) {
                dict [@"EBTApplicable"] = @(TRUE);
            }
            dict[@"ItemTaxDetail"] = @"";
            dict[@"TotalTaxPercentage"] = @"0.00";
            dict[@"itemTax"] = @(0.0);
        }
        dict [@"EBTApplicableForDisplay"] = @(FALSE);
        
        
        selectedRestaurantItem = (RestaurantItem*) [privateManageobjectContext objectWithID:selectedRestaurantItem.objectID];
        selectedRestaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:dict];
        [UpdateManager saveContext:privateManageobjectContext];
    }
}



#pragma mark - Hold

- (void)openHoldMessageView
{
    _holdViewmsgBox.text=@"";
    self.holdMessageView.frame=CGRectMake(0, 0, self.holdMessageView.frame.size.width, self.holdMessageView.frame.size.height);
    self.holdMessageView.hidden = NO;
    [_holdViewmsgBox becomeFirstResponder];
}

- (IBAction)holdViewYesClicked:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];
    if(_holdViewmsgBox.text.length > 0)
    {
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHoldInvoiceProcess:) name:@"HoldInvoice" object:nil];
        // [self doHoldItemProcess];
    }
    else
    {
        RcrPosVC * __weak myWeakReference = self;

        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference.posMenuVC clearSelection];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please write message to put item(s) on Hold." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
    }
}

- (IBAction)holdViewNoClicked:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];
    [_holdViewmsgBox resignFirstResponder];
    //    [self focus];
    self.holdMessageView.hidden = YES;
}

#pragma mark - Recall
-(IBAction)recallButtonClicked:(id)sender
{
    [Appsee addEvent:kPosMenuRecall];
    [self.rmsDbController playButtonSound];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[self.view viewWithTag:353231]removeFromSuperview ];
        self.recallView = [[RecallViewController alloc]initWithNibName:@"RecallViewController" bundle:nil];
        self.recallView.recallDelegate = self;
        CGRect recallViewFrame = self.view.bounds;
     //   recallViewFrame.origin.y = recallViewFrame.origin.y+20;
        self.recallView.view.frame = recallViewFrame;
        [self.view addSubview:self.recallView.view];
    });
}
#pragma mark - Cancel

-(IBAction)cancelButtonClicked:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightCancelInvoice];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to cancel invoice. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    if ([self reciptDataAryForBillOrder].count > 0)
    {
        [Appsee addEvent:kPosMenuCancel];
        [self.rmsDbController playButtonSound];
        removeTaxVC.view.hidden = YES;
        RcrPosVC * __weak myWeakReference = self;
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            if (self.crmController.isbillOrderFromRecall == TRUE && self.crmController.isbillOrderFromRecallOffline == FALSE)
            {
                [myWeakReference cancelTransactionDetail:self.crmController.recallInvoiceId];
            }
            else
            {
                [myWeakReference cancelTransactionDetail:@"0"];
            }
            [self removeTenderBillData];
        };
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference.posMenuVC clearSelection];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to clear screen?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        [self resetAgeRestriction];
    }
}

-(void)cancelTransactionDetail:(NSString *)recallId
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:[self setCancelLogArray] forKey:@"InvCancelLogDetail"];
    [param setValue:recallId forKey:@"HoldId"];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    
    param[@"DeleteDateTime"] = strDate;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self cancelTransactionRecordResponse:response error:error];
        });
    };

    self.cancelInvoiceTransaction = [self.cancelInvoiceTransaction initWithRequest:KURL actionName:WSM_CANCEL_INVOICE_TRANSCATION params:param completionHandler:completionHandler];
}

- (void)cancelTransactionRecordResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseDict = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSInteger recallCount = [[responseDict valueForKey:@"RecallCount"] integerValue];
                
                if(self.crmController.recallCount != recallCount)
                {
                    self.crmController.recallCount = recallCount;
                    NSDictionary *recallCountDict = @{@"Code" : @(recallCount)};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveHoldUpdateCount" object:recallCountDict];
                }
                [self clearBillUI];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured in Cancel Transaction Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}


-(void)deleteRecallDataForId:(NSString *)recallId
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:recallId forKey:@"SrNo"];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    
    param[@"DeleteDateTime"] = strDate;

    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteRecallRecordResponse:response error:error];
        });
    };

    self.deleteRecallConnection = [self.deleteRecallConnection initWithRequest:KURL actionName:WSM_RECALL_INVOICE_DELETE params:param completionHandler:completionHandler];
    
}

- (void)deleteRecallRecordResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseDict = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSInteger recallCount = [[responseDict valueForKey:@"RecallCount"] integerValue];
                
                if(self.crmController.recallCount != recallCount)
                {
                    self.crmController.recallCount = recallCount;
                    NSDictionary *recallCountDict = @{@"Code" : @(recallCount)};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveHoldUpdateCount" object:recallCountDict];
                }
                [self clearBillUI];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured in Delete Recall Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            
        }
    }

}


#pragma mark - Refund
-(IBAction)refundButtonClicked:(id)sender
{
    [Appsee addEvent:kPosMenuRefund];
    if (billAmountCalculator.itemRefund)
    {
        billAmountCalculator.itemRefund = FALSE;
        [self.posMenuVC clearSelection];
    }
    else
    {
        billAmountCalculator.itemRefund = TRUE;
    }
}


#pragma mark - Void

-(IBAction)voidButtonClicked:(id)sender
{
    [Appsee addEvent:kPosMenuVoid];

    [self.rmsDbController playButtonSound];
    
    if ([self reciptDataAryForBillOrder].count > 0)
    {
        RcrPosVC * __weak myWeakReference = self;
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference VoidTransactions];
        };
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference.posMenuVC clearSelection];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to void transaction?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
    else
    {
        [self.posMenuVC clearSelection];
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please add an Item to Void Transaction." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}
#pragma mark - NoSale

-(IBAction)noSaleButtonClicked:(id)sender
{
    [Appsee addEvent:kPosMenuNoSale];
    [self.rmsDbController playButtonSound];
    
    RcrPosVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        noSaleType = @"POS";
        [myWeakReference nosale];
        [myWeakReference.posMenuVC clearSelection];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference.posMenuVC clearSelection];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Do you want to open drawer?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(CGFloat)totalCheckCashForBillOrderArray:(NSMutableArray *)reciptArray
{
    CGFloat totalCheckCashAmount = 0.00;
    for (int i = 0; i < reciptArray.count; i++)
    {
       
        NSDictionary *itemDictionary = [reciptArray[i] valueForKey:@"item"];
        
        BOOL isChargeCashvalue=[itemDictionary[@"isCheckCash"] boolValue];
        
        if (isChargeCashvalue == TRUE)
        {
            totalCheckCashAmount += [[reciptArray[i] valueForKey:@"itemPrice"] floatValue];
        }
    }
    return totalCheckCashAmount;
}

-(CGFloat)totalEBTForBillEntry:(NSMutableArray *)reciptArray
{
    CGFloat totalEBT = 0.00;
    if (billAmountCalculator.isEbtApplied == TRUE) {
        NSPredicate *fetchEBTData = [NSPredicate predicateWithFormat:@"isEBTApplicable == %@",@(TRUE)];
        
        NSArray *filterEBTData = [reciptArray filteredArrayUsingPredicate:fetchEBTData];
        if (filterEBTData.count > 0) {
            totalEBT = [[filterEBTData valueForKeyPath:@"@sum.VariationBasicPrice"] floatValue];
        }
    }
    return totalEBT;
}

#pragma mark - Tender
-(IBAction)btnTenderClick:(id)sender
{
   [self tenderTransactionWithTenderType:@"" withPayId:0];
}

-(IBAction)CashTenderClick:(id)sender
{
    [self tenderTransactionWithTenderType:@"Cash" withPayId:0];
}

-(IBAction)CreditTenderClick:(id)sender
{
    [self tenderTransactionWithTenderType:@"Credit" withPayId:0];
}

-(void)tenderTransactionWithTenderType :(NSString *)tenderType withPayId:(NSNumber *)payId
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    double delayInSeconds = 0.1;
    self.view.userInteractionEnabled = NO;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {

        NSMutableArray *reciptArray1 = [self configureDiscountArrayForBill]; //[self reciptDataAryForBillOrder];
        
        NSSortDescriptor *sorting = [[NSSortDescriptor alloc]initWithKey:@"itemIndex" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sorting];
        NSMutableArray *reciptArray = [[reciptArray1 sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:[reciptArray mutableCopy]];
        
        if ([tenderType isEqualToString:@"EBT/Food Stamp"] && rcrBillSummary.totalEBTAmount.floatValue == 0)
        {
            self.view.userInteractionEnabled = YES;
            [_activityIndicator hideActivityIndicator];

            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"EBT is Not Applied. Please select EBT item ." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        
        
        if(reciptArray.count>0)
        {
            for (NSArray *array in reciptArray)
            {
                self.view.userInteractionEnabled = YES;
                [_activityIndicator hideActivityIndicator];

                if ([[array valueForKey:@"itemQty"] floatValue] == 0)
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Select at least one QTY." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    return;
                }
                
                if (!(rcrRapidCustomerLoayalty) && [[array valueForKey:@"CardType"] isEqualToString:@"2"] )
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Select Customer." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    return;
                }

            }
            
            BOOL allPaymentOptionDisable;
            allPaymentOptionDisable = [self allPaymentOptionDisable];
            if (allPaymentOptionDisable)
            {
                self.view.userInteractionEnabled = YES;
                [_activityIndicator hideActivityIndicator];

                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"All payment options are disabled. Please enable at least one payment option." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                return;
            }
            
            BOOL isEBTNotAvl = [self fetchPaymentForPaymentEBT];
            if (!isEBTNotAvl && rcrBillSummary.totalEBTAmount.floatValue != 0.00)
            {
                self.view.userInteractionEnabled = YES;
                [_activityIndicator hideActivityIndicator];

                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please insert EBT Payment type for complete this Trancation." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                return;
            }
            
            
            
            TenderViewController *tenderview = [[TenderViewController alloc] initWithNibName:@"TenderViewController" bundle:nil];
            self.crmController.singleTap1.enabled = NO;
            tenderview.receiptDataArray = reciptArray;
            tenderview.dictCustomerInfo = self.selectedCustomerDetail;
            tenderview.billItemDetailString = [self billItemDetailStringForOrder:reciptArray];
            tenderview.isGasItem = [self checkForGasitem];
            tenderview.tenderDelegate = self;
            tenderview.tenderRapidCustomerLoyalty = rcrRapidCustomerLoayalty;
            tenderview.rcrBillSummary = rcrBillSummary;
            tenderview.selectedFuelType = self.selectedFuelDict;
            NSMutableDictionary *dictAmoutInfo = [[self setSubTotalsToDictionaryForReciptArray:reciptArray] mutableCopy];
            tenderview.dictAmoutInfo = dictAmoutInfo;
            tenderview.tenderType = tenderType;
            tenderview.payId = payId;

            tenderview.billAmountCalculator = billAmountCalculator;
            tenderview.tenderItemCount = reciptArray.count;
            tenderview.moduleIdentifier = [self moduleIdentifier];
            //        if(self.payentVoidDataAry.count>0){
            //            tenderview.paymentForVoid = self.payentVoidDataAry;
            //        }
//            tenderview.tenderReciptDataAry  = reciptArray;
            tenderview.checkcashAmount = [self totalCheckCashForBillOrderArray:reciptArray];
            tenderview.ebtAmount = rcrBillSummary.totalEBTAmount.floatValue;
            tenderview.houseChargeValue = houseChargeValue;

            tenderview.houseChargeAmount = rcrBillSummary.totalHouseChargeAmount.floatValue;
            tenderview.isHouseChargePay = isHouseChargeCollectPay;

            //        if ([[self moduleIdentifier] isEqualToString:@"RcrPosRestaurantVC"])
            //        {
            tenderview.restaurantOrderTenderObjectId = self.restaurantOrderObjectId;
            //        }
            if ([self totalCheckCashForBillOrderArray:reciptArray] != 0)
            {
                tenderview.isCheckCashApplicableAplliedToBill = TRUE;
            }
            else
            {
                tenderview.isCheckCashApplicableAplliedToBill = FALSE;
            }
            if (tenderview.isCheckCashApplicableAplliedToBill)
            {
                BOOL isCheckCashNotAvl = [self fetchPaymentForPaymentMasterName];
                if (!isCheckCashNotAvl)
                {
                    self.view.userInteractionEnabled = YES;
                    [_activityIndicator hideActivityIndicator];

                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please insert Cheque Payment type for complete this Trancation." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    return;
                }
            }
            self.view.userInteractionEnabled = YES;
            [_activityIndicator hideActivityIndicator];
            [self.navigationController pushViewController:tenderview animated:YES];
        
        NSMutableArray *array = [reciptArray mutableCopy];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:@"ShowTender" forKey:@"Tender"];
        [dict setValue:array forKey:@"BillEntries"];
        [dict setValue:dictAmoutInfo forKey:@"TenderSubTotals"];
        [self.crmController writeDictionaryToCustomerDisplay:dict];

        }
        else{
            self.view.userInteractionEnabled = YES;
            [_activityIndicator hideActivityIndicator];
        }
        

    });
    
}
-(BOOL)checkForGasitem{
    BOOL isGas = NO;

    NSMutableArray *reciptArray1 = [self configureDiscountArrayForBill]; //[self reciptDataAryForBillOrder];
    NSSortDescriptor *sorting = [[NSSortDescriptor alloc]initWithKey:@"itemIndex" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sorting];
    NSMutableArray *reciptArray = [[reciptArray1 sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    NSMutableArray *tenderReciptDataAry = reciptArray;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Barcode == %@",@"GAS"];
    NSArray *arrayGas = [tenderReciptDataAry filteredArrayUsingPredicate:predicate];
    if(arrayGas.count>0 && [arrayGas.firstObject[@"Discription"] isEqualToString:@"PRE-PAY"]){
        isGas = YES;
    }
    return isGas;

}
-(BOOL)fetchPaymentForPaymentMasterName
{
    BOOL isCheckCaseValue = FALSE;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *tenderFetchPredicate = [NSPredicate predicateWithFormat:@"cardIntType = %@",@"Check"];
    fetchRequest.predicate = tenderFetchPredicate;
    
    NSArray *uniquePaymentMaster = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (uniquePaymentMaster.count >0)
    {
        isCheckCaseValue = TRUE;
    }
    return isCheckCaseValue;
}

-(BOOL)fetchPaymentForPaymentEBT
{
    BOOL isEBTValue = FALSE;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *tenderFetchPredicate = [NSPredicate predicateWithFormat:@"cardIntType = %@",@"EBT/Food Stamp"];
    fetchRequest.predicate = tenderFetchPredicate;
    
    NSArray *uniquePaymentMaster = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (uniquePaymentMaster.count >0)
    {
        isEBTValue = TRUE;
    }
    return isEBTValue;
}
- (BOOL)allPaymentOptionDisable
{
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig"];
    NSPredicate * filterTenderPrediacte = [NSPredicate predicateWithFormat:@"SpecOption == %@",@"11"];
    BOOL allPaymentOptionDisable = FALSE;
    
    NSArray  *filterTenderDisablearray = [arrTemp filteredArrayUsingPredicate:filterTenderPrediacte];
    if (filterTenderDisablearray.count > 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        
        if (resultSet.count == filterTenderDisablearray.count)
        {
            allPaymentOptionDisable = TRUE;
            
        }
    }
    return allPaymentOptionDisable;
}
#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(textView == _holdViewmsgBox)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        self.holdMessageView.frame=CGRectMake(0, -150, self.holdMessageView.frame.size.width, self.holdMessageView.frame.size.height);
        [UIView commitAnimations];
    }
}

#pragma mark - UITextField Delegate

#pragma mark - Keyboard Delegate

-(void)keyboardWillShow:(NSNotification *)note
{
    UIView *viewTemp = [self.view viewWithTag:REMOVETAX_VIEW_TAG];
    
    if(viewTemp && removeTaxVC.txtMessage.isFirstResponder){
        
      //  removeTaxVC.view.frame = CGRectMake(655, -50, removeTaxVC.view.frame.size.width, removeTaxVC.view.frame.size.height);
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    if (self.holdMessageView.hidden == NO)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.1];
        self.holdMessageView.frame=CGRectMake(0, 0, self.holdMessageView.frame.size.width, self.holdMessageView.frame.size.height);
        [UIView commitAnimations];
    }
   // UIView *viewTemp = [self.view viewWithTag:REMOVETAX_VIEW_TAG];
    
//    if(removeTaxVC.view.frame.origin.x != self.view.frame.size.width){
//        
//        removeTaxVC.view.frame = CGRectMake(655, 164, removeTaxVC.view.frame.size.width,removeTaxVC.view.frame.size.height);
//    }
}

#pragma mark - setupFlowerMenu

- (void)gasPumpAppClicked
{
    [self.rmsDbController playButtonSound];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self LoadGasPumpApplication];
    });
}

-(void)LoadGasPumpApplication
{
//    GasPumpDashBoardVC *gasPumpVC=[[GasPumpDashBoardVC alloc]initWithNibName:@"GasPumpDashBoardVC" bundle:nil];
//    gasPumpVC.gasPumpDashBoardDelegate = self;
//    [self.navigationController pushViewController:gasPumpVC animated:TRUE];
//    [_activityIndicator hideActivityIndicator];;
}

-(NSMutableArray *)checkActiveModule:(int)moduleId
{
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND ModuleId == %@", (self.rmsDbController.globalDict)[@"DeviceId"],@(moduleId)];
    NSMutableArray *isFoundArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    return isFoundArray;
}

-(void)setupFlowerMenu
{
    self.flowerMenu = [[FlowerMenu alloc] initWithMenuView:self.flowerMenuView];
    self.flowerMenuView.quadrantOffset = M_PI_2 * 3;
    self.flowerMenuView.totalAngle =  M_PI_2;
    self.flowerMenuView.bloomFactor = 3.5;
}

-(void)setupTheFlowerArray
{
    self.flowerMenuActiveIds = [[NSMutableArray alloc] init];
    self.flowerMenuTitles = [[NSMutableArray alloc] init];
    self.flowerMenuNormalImages = [[NSMutableArray alloc] init];
    self.flowerMenuSelectedImages = [[NSMutableArray alloc] init];
    
    [self setupFlowerMenu];
    
    if([self checkActiveModuleForShortCut:@"1"].count>0)
    {
        [self.flowerMenuTitles addObjectsFromArray:@[@"Dashboard"]];
        [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_Icon_Dashboard.png"]];
        [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_Icon_Dashboard.png"]];
        [self.flowerMenuActiveIds addObjectsFromArray:@[@(DASHBOARD_SHORTCUT)]];
    }
    if([self checkActiveModuleForShortCut:@"2"].count>0)
    {
        [self.flowerMenuTitles addObjectsFromArray:@[@"Clock In Out"]];
        [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_ClockinIcon.png"]];
        [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_ClockinIcon.png"]];
        [self.flowerMenuActiveIds addObjectsFromArray:@[@(CLOCK_IN_OUT_SHORTCUT)]];
    }
    if([self checkActiveModuleForShortCut:@"3"].count>0)
    {
        [self.flowerMenuTitles addObjectsFromArray:@[@"Shift In Out"]];
        [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_shiftInOutIcon.png"]];
        [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_shiftInOutIcon.png"]];
        [self.flowerMenuActiveIds addObjectsFromArray:@[@(SHIFT_IN_OUT_SHORTCUT)]];
    }
    
    if([self checkActiveModuleForShortCut:@"4"].count>0)
    {
        [self.flowerMenuTitles addObjectsFromArray:@[@"Report"]];
        [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_Icon_dailyReport.png"]];
        [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_Icon_dailyReport.png"]];
        [self.flowerMenuActiveIds addObjectsFromArray:@[@(REPORT_SHORTCUT)]];
    }
    
    if([self checkActiveModuleForShortCut:@"5"].count>0)
    {
        [self.flowerMenuTitles addObjectsFromArray:@[@"Inventory"]];
        [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_Icon_Inventory.png"]];
        [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_Icon_Inventory.png"]];
        [self.flowerMenuActiveIds addObjectsFromArray:@[@(INVENTORY_SHORTCUT)]];
    }
    if([self checkActiveModuleForShortCut:@"6"].count>0)
    {
        [self.flowerMenuTitles addObjectsFromArray:@[@"Purchase Order"]];
        [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_Icon_purchaseOrderIcon"]];
        [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_Icon_purchaseOrderIcon"]];
        [self.flowerMenuActiveIds addObjectsFromArray:@[@(PURCHASEORDER_SHORTCUT)]];
        
    }
    
    [self.flowerMenu setupMenuWithTitles:[self.flowerMenuTitles mutableCopy ] normalImages:[self.flowerMenuNormalImages mutableCopy] selectedImages:[self.flowerMenuSelectedImages mutableCopy] disabledImages:nil delegate:self];
    
    /* if(([self checkActiveModule:1].count > 0) || ([self checkActiveModule:5].count > 0)) // RCR Module
     {
     [self.flowerMenuTitles addObjectsFromArray:@[@"Dashboard",@"Report"]];
     [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_Icon_Dashboard",@"f_Icon_dailyReport"]];
     [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_Icon_Dashboard",@"f_Icon_dailyReport"]];
     [self.flowerMenuActiveIds addObjectsFromArray:@[@(DASHBOARD_SHORTCUT),@(REPORT_SHORTCUT)]];
     }
     if([self checkActiveModule:2].count > 0) // RIM Module
     {
     [self.flowerMenuTitles addObjectsFromArray:@[@"Inventory"]];
     [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_Icon_Inventory.png"]];
     [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_Icon_Inventory.png"]];
     [self.flowerMenuActiveIds addObjectsFromArray:@[@(INVENTORY_SHORTCUT)]];
     }
     if([self checkActiveModule:3].count > 0) // PO Module
     {
     [self.flowerMenuTitles addObjectsFromArray:@[@"Purchase Order"]];
     [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_Icon_purchaseOrderIcon"]];
     [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_Icon_purchaseOrderIcon"]];
     [self.flowerMenuActiveIds addObjectsFromArray:@[@(PURCHASEORDER_SHORTCUT)]];
     }
     if([self checkActiveModule:5].count > 0) // Gas Pump Module
     {
     [self.flowerMenuTitles addObjectsFromArray:@[@"GasPump"]];
     [self.flowerMenuNormalImages addObjectsFromArray:@[@"f_Icon_gaspump.png"]];
     [self.flowerMenuSelectedImages addObjectsFromArray:@[@"f_Icon_gaspump.png"]];
     [self.flowerMenuActiveIds addObjectsFromArray:@[@(GASPUMP_SHORTCUT)]];
     // self.flowerMenuView.bloomFactor = 2.5;
     }*/
    
    
}

-(NSMutableArray *)checkActiveModuleForShortCut:(NSString *)moduleId
{
    
    NSMutableArray *arrayShortcutSelectionArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ModuleSelectionShortCut"]mutableCopy];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moduleIndex == %@",moduleId];
    NSMutableArray *isFoundArray = [[arrayShortcutSelectionArray filteredArrayUsingPredicate:predicate] mutableCopy ];
    return isFoundArray;
}



- (void)insertDidFinish {
}

- (void)flowerMenu:(FlowerMenu *)flowerMenu didSelectMenuItem:(NSInteger)index
{
    index = [self.flowerMenuActiveIds[index] integerValue];
    
    if (index != DASHBOARD_SHORTCUT)
    {
        if (!self.rmsDbController.isInternetRechable) {
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"you can not access this module in offline mode" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            
            return;
        }
    }
    
    if (index == DASHBOARD_SHORTCUT)
    {
        [self gotoDashboard];
    }
    else if (index == REPORT_SHORTCUT)
    {
#ifdef CheckRights
        BOOL shiftReportRights = [UserRights hasRights:UserRightShiftInOut];
        BOOL xReportRights = [UserRights hasRights:UserRightXReport];
        if (!shiftReportRights && !xReportRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have X-Report & Shift Report rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
#endif
        [self pushToReport];
    }
    else if (index == PURCHASEORDER_SHORTCUT)
    {
        [self gotoPurchaseOrder];
    }
    else if (index == INVENTORY_SHORTCUT)
    {
        BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have inventory info rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        [self gotoRapidInventoryManagement];
    }
    else if (index == GASPUMP_SHORTCUT)
    {
        [self gasPumpAppClicked];
    }
    else if (index == CLOCK_IN_OUT_SHORTCUT)
    {
#ifdef CheckRights
        BOOL hasRights = [UserRights hasRights:UserRightClockInOut];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to access clock in out. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            [_activityIndicator hideActivityIndicator];;
            return;
        }
#endif
        [self gotoClockInout];
    }
    else if (index == SHIFT_IN_OUT_SHORTCUT)
    {
#ifdef CheckRights
        BOOL hasRights = [UserRights hasRights:UserRightShiftInOut];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to access Shift In Out Module. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
#endif
        [self gotoShiftInout];
    }
}

-(void)gotoDashboard
{
    if (!(self.reciptDataAryForBillOrder.count > 0))
    {
        
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        for (UIViewController *vc in viewControllerArray)
        {
            if ([vc isKindOfClass:[DashBoardSettingVC class]])
            {
                [self.rcrLeftSlideMenuVC.view removeFromSuperview];

                [self.navigationController popToViewController:vc animated:TRUE];
            }
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"please complete or void this transcation." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)gotoPurchaseOrder
{
    POmenuListVC *objPoMenu = [[POmenuListVC alloc] initWithNibName:@"POmenuListVC" bundle:nil];
    [self.navigationController pushViewController:objPoMenu animated:YES];
}

-(void)gotoClockInout
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
    ClockInDetailsView  *clockInOutDetail = [storyBoard instantiateViewControllerWithIdentifier:@"ClockInDetailsView"];
    [self.navigationController pushViewController:clockInOutDetail animated:YES];
}

-(void)gotoShiftInout
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
    ShiftReportDetailsVC *shiftReportDetailsVC = [storyBoard instantiateViewControllerWithIdentifier:@"ShiftReportDetailsVC"];
    NSMutableDictionary *dictUInfo = [self.rmsDbController.globalDict valueForKey:@"UserInfo"];
    
    if([[dictUInfo valueForKey:@"CashInOutFlg"]integerValue]==0 && [[dictUInfo valueForKey:@"CashInRequire"]integerValue]==0) {
    }
    else {
        dictUInfo[@"CashInOutFlg"] = @"1";
        dictUInfo[@"CashInRequire"] = @"0";
        (self.rmsDbController.globalDict)[@"UserInfo"] = dictUInfo;
    }
    shiftReportDetailsVC.isfromDashBoard = true;
    [self.navigationController pushViewController:shiftReportDetailsVC animated:YES];
    return;

    
//    ShiftOpenCloseVC *shiftOpenClose =[[ShiftOpenCloseVC alloc]initWithNibName:@"ShiftOpenCloseVC" bundle:nil];
//    shiftOpenClose.isfromDashBoard = YES;
//    
//    NSMutableDictionary *dictUInfo = [self.rmsDbController.globalDict valueForKey:@"UserInfo"];
//    
//    if([[dictUInfo valueForKey:@"CashInOutFlg"]integerValue]==0 && [[dictUInfo valueForKey:@"CashInRequire"]integerValue]==0){
//        
//        
//    }
//    else{
//        dictUInfo[@"CashInOutFlg"] = @"1";
//        dictUInfo[@"CashInRequire"] = @"0";
//        (self.rmsDbController.globalDict)[@"UserInfo"] = dictUInfo;
//    }
//
//    [self.navigationController pushViewController:shiftOpenClose animated:YES];

}

-(void)pushToReport
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Reporting" bundle:nil];
    DailyReportVC *dailyReportVC = [storyBoard instantiateViewControllerWithIdentifier:@"DailyReportVC"];
    [self.navigationController pushViewController:dailyReportVC animated:YES];
    return;
    
    ReportViewController  *reportVC = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
    [self.navigationController pushViewController:reportVC animated:YES];
}

- (void)gotoRapidInventoryManagement
{
    [self.rmsDbController playButtonSound];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self LoadRimApplication];
    });
}

-(void)LoadRimApplication
{
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND ModuleId == %@", (self.rmsDbController.globalDict)[@"DeviceId"],@(2)];
    //NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", tmpMac];
    NSMutableArray *isFoundArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    
    if(isFoundArray.count > 0)
    {
        RimMenuVC * objInvenHome =
        [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimMenuVC_sid"];

        [self.navigationController pushViewController:objInvenHome animated:YES];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"RIM Module is Not Active on your Device." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    [_activityIndicator hideActivityIndicator];;
}

#pragma mark - DepartmetCollectionVcDelegate Method

-(void)didSelectedDepartment:(Department *)selectedDepartment withUICollectionViewCell:(UICollectionViewCell *)collectionCell
{
    [_manualQtyBtn setEnabled:YES];
    self.crmController.manualQtyValue = @"1";
    [_manualQtyBtn setTitle:@"QTY: 1"  forState:UIControlStateNormal];
    
    Item *anItem=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d and isPriceAtPOS==%@ ", selectedDepartment.itemcode.integerValue , @"0"];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count > 0)
    {
        anItem=resultSet.firstObject;
        NSNumber *numerCost=@(anItem.salesPrice.floatValue);
        self.crmController.manualPriceValue=[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:numerCost]];
    }
    else
    {
    }
    Item *anItem2 = [self fetchAllItems:selectedDepartment.itemcode.stringValue];
    if(anItem2)
    {
        [self addDepartmentToRingUpQueue:anItem2.itemCode.stringValue];
    }
    else
    {
        NSString *deptName = selectedDepartment.deptName;
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"%@ not available",deptName] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
}

-(Department *)didFetchDepartmentWithItemId :(NSString *)itemId
{
    Department *department = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemcode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        department=resultSet.firstObject;
    }
    return department;
}

- (void)didRingUpDepartmentWithItemId:(Item *)anItem2
{
    self.isDepartment = TRUE;
    [self verifyAgeForItem:anItem2];
}

- (void)didRingUpSubDepartmentWithItemId:(Item *)anItem2
{
     self.isDepartment = TRUE;
    [self verifyAgeForItem:anItem2];
}

#pragma mark - SubDepartment and Department // called From RcrPosRestaurent

-(void)didSelectedSubDepartment:(SubDepartment *)selectedSubDepartment department:(Department *)selectedDepartment
{
    [_manualQtyBtn setEnabled:YES];
    self.crmController.manualQtyValue = @"1";
    [_manualQtyBtn setTitle:@"QTY: 1"  forState:UIControlStateNormal];
    
    Item *anItem=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d and isPriceAtPOS==%@", selectedSubDepartment.itemCode.integerValue , @"0"];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count > 0)
    {
        anItem=resultSet.firstObject;
        NSNumber *numerCost=@(anItem.salesPrice.floatValue);
        self.crmController.manualPriceValue=[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:numerCost]];
    }
    else
    {
    }
    Item *anItem2 = [self fetchAllItems:selectedSubDepartment.itemCode.stringValue];
    if(anItem2)
    {
        [self addSubDepartmentToRingUpQueue:anItem2.itemCode.stringValue];
    }
    else
    {
        NSString *deptName = selectedDepartment.deptName;
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"%@ not available",deptName] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
}

#pragma mark - ItemRingupSelectionDelegate Method

-(void)didSelectItemRingup:(Item *)ringupItem
{
}

- (void)setCurrencyFormatter:(double)amount label:(UILabel *)selectedLabel
{
    NSNumber *tempAmount = @(amount);
    NSString *labelAmount = [self.crmController.currencyFormatter stringFromNumber:tempAmount];
    selectedLabel.text = [labelAmount stringByReplacingOccurrencesOfString:@"," withString:@""];
}
-(void) didCancelItemRingup
{
    [self.posMenuVC clearSelection];
}


-(void)didItemRingUpFromItemId :(NSString *)ringupItemId
{
    [self.posMenuVC clearSelection];
    [_manualQtyBtn setEnabled:YES];
    self.crmController.manualQtyValue = @"1";
    [_manualQtyBtn setTitle:@"QTY: 1"  forState:UIControlStateNormal];
    Item *anItem = [self fetchAllItems:ringupItemId];
    [_itemInfoDataObject setItemMainDataFrom:[anItem.itemRMSDictionary mutableCopy]];

    self.isDepartment = FALSE;
    
    // CheckItemDetail With Item.......
//    NSInteger dept_id = [anItem.deptId integerValue];
    self.itemCodeId = ringupItemId;
    if (anItem.itemDepartment) {
        [self verifyAgeForItem:anItem];
    }
    else
    {
        [self launchPriceAtLatestPosForItem:anItem];
    }
}

-(void)launchPriceAtLatestPosForItem :(Item *)anItem
{
    if ( self.isDepartment == FALSE)
    {
        if (anItem.isPriceAtPOS.boolValue == TRUE)
        {
            //  launch variation popup if required.....
            if ([[self moduleIdentifier] isEqualToString:@"RcrPosRestaurantVC"] || [[self moduleIdentifier] isEqualToString:@"RetailRestaurant"] || [[self moduleIdentifier] isEqualToString:@"RcrPosVC"])
            {
                if ((anItem.itemVariations.count > 0 && [_itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) || [_itemInfoDataObject.PriceScale isEqualToString:@"VARIATIONAPPROPRIATE"])
                {
                    [self showVariationSelectionWithDetail:anItem withBillAmountCalculator:billAmountCalculator];
                }
                else
                {
                    [self _launchPriceAtPos_Retail:anItem];
                }
            }
            else
            {
                [self _launchPriceAtPos_Retail:anItem];
            }
        }
        else
        {
            //  launch variation popup if required.....
            if (([[self moduleIdentifier] isEqualToString:@"RcrPosRestaurantVC"] || [[self moduleIdentifier] isEqualToString:@"RetailRestaurant"] || [[self moduleIdentifier] isEqualToString:@"RcrPosVC"]))
            {
                if ((anItem.itemVariations.count > 0 && [_itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) || [_itemInfoDataObject.PriceScale isEqualToString:@"VARIATIONAPPROPRIATE"])
                {
                    [self showVariationSelectionWithDetail:anItem withBillAmountCalculator:billAmountCalculator];
                }
                else
                {
                    if (anItem.memo.boolValue == TRUE) {
                        [self launchMemoVC];
                    }
                    else
                    {
                        [self setItemDetail:anItem];
                    }
                }
            }
            else
            {
                if (anItem.memo.boolValue == TRUE) {
                    [self launchMemoVC];
                }
                else
                {
                    [self setItemDetail:anItem];
                }
            }
        }
    }
    else
    {
        
        if ((anItem.itemVariations.count > 0 && [_itemInfoDataObject.PriceScale isEqualToString:@"VARIATION"]) || [_itemInfoDataObject.PriceScale isEqualToString:@"VARIATIONAPPROPRIATE"])
        {
            [self showVariationSelectionWithDetail:anItem withBillAmountCalculator:billAmountCalculator];
        }
        else
        {
            if (anItem.isPriceAtPOS.boolValue) {
                [_enterDepartment setTitle:@"CANCEL" forState:UIControlStateNormal];
                _departmentAmountTextField.text = @"";
                _departmentNumpadView.hidden = NO;
                _departmentNumpadView.center = _popupContainerView.center;
                [self presentView:_departmentNumpadView];
                
            }
            else
            {
                [self setItemDetail:anItem];
            }
            
        }
    }
}

-(void)didSelectItemRingupId:(NSString *)ringupItemId
{
    [self addItemToRingUpQueue:ringupItemId];
}
-(void) didSelectwithMultipleItemArray:(NSMutableArray *)selectedItemArray
{
//    NSDictionary *selectedItemRingUpDictionary = @{kPosItemRingUpKey: selectedItemArray};
//    [Appsee addEvent:kPosItemSelectedForRingUp withProperties:selectedItemRingUpDictionary];
    for (NSDictionary * itemDictionary in selectedItemArray) {
        [self addItemToRingUpQueue:[itemDictionary valueForKey:@"itemId"]];
    }
}
-(void) didselectFavouriteItem:(NSString *)favouriteItemString withUnfavouriteItem:(NSString *)unFavouriteItemItemString
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    [param setValue:favouriteItemString forKey:@"Items"];
    [param setValue:strDateTime forKey:@"UpdatedDateTime"];
    [param setValue:unFavouriteItemItemString forKey:@"NotFavouriteItems"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateItemByfavouriteResponse:response error:error];
        });
    };
    
    self.updateItemByFavouriteConnection = [self.updateItemByFavouriteConnection initWithRequest:KURL actionName:WSM_UPDATE_ITEM_BY_FAVOURITE params:param completionHandler:completionHandler];
    
}

- (void)updateItemByfavouriteResponse:(id)response error:(NSError *)error

{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
                [itemLiveUpdate setValue:@"Update" forKeyPath:@"Action"];
                [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
                [itemLiveUpdate setValue:@"Item" forKey:@"Type"];
                [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}


#pragma mark - Database Items Methods

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

- (Item*)fetchAllItemForGiftCard :(NSString *)strGiftCard
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item_Desc contains[cd] %@", strGiftCard];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}


- (Department*)fetchAllDepartments :(NSString *)strdeptId
{
    Department *department=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d", strdeptId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        department=resultSet.firstObject;
    }
    return department;
}

//- (SubDepartment *)fetchAllSubDepartments :(NSString *)strSubDeptId
//{
//    SubDepartment *subDepartment=nil;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubDepartment" inManagedObjectContext:__managedObjectContext];
//    [fetchRequest setEntity:entity];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brnSubDeptID==%d", [strSubDeptId integerValue]];
//    [fetchRequest setPredicate:predicate];
//    // NSError *error;
//    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
//    if (resultSet.count>0)
//    {
//        subDepartment = [resultSet firstObject];
//    }
//    return subDepartment;
//}


#pragma mark- Set Item and Department Detail

- (void)addDepartmentWithId:(NSString *)departmentId
{
    Item *anItem = [self fetchAllItems:departmentId];
    Department *aDepartment=[self fetchAllDepartments:anItem.deptId.stringValue];
    NSMutableDictionary *departmentDictionary = [aDepartment.departmentDictionary mutableCopy];
    if (aDepartment !=nil && departmentDictionary!=nil)
    {
        departmentDictionary[@"ExtraCharge"] = @"0";
        departmentDictionary[@"CheckCashCharge"] = @"0";
        
        BOOL isChargeCashvalue=[departmentDictionary[@"isCheckCash"] boolValue];
        BOOL isExtrachargeValue=[departmentDictionary[@"isExtraCharge"]boolValue];
        
        if (isChargeCashvalue)
        {
            NSString *sCheckCashtype=aDepartment.checkCashType;
            float fCheckCashAmt=aDepartment.checkCashAmt.floatValue;
            
            departmentDictionary[@"ChargeType"] = sCheckCashtype;
            departmentDictionary[@"ChargeAmount"] = aDepartment.checkCashAmt;
            
            [self setFeesAmount:[NSString stringWithFormat:@"%f",fCheckCashAmt] type:sCheckCashtype checkCash:YES];
        }
        else if(isExtrachargeValue)
        {
            departmentDictionary[@"ChargeType"] = aDepartment.chargeTyp;
            departmentDictionary[@"ChargeAmount"] = aDepartment.chargeAmt;
            
            [self setFeesAmount:[NSString stringWithFormat:@"%@", aDepartment.chargeAmt] type:aDepartment.chargeTyp checkCash:NO];
        }
        else
        {
            departmentDictionary[@"ChargeType"] = @"";
            departmentDictionary[@"ChargeAmount"] = @"0";
        }
        currentBillEntryDictionary = departmentDictionary;
    }
}

- (void)setFeesAmount:(NSString*)amountValue type:(NSString*)type checkCash:(BOOL)checkCash {
    
    CGFloat amount = amountValue.floatValue;
    if([type isEqualToString:@"Fix Charge"])
    {
        
    }
    else if([type isEqualToString:@"Percentage(%)"])
    {
        NSString *sAmount=[self.priceAtPOSAmount stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
        float fenterprice = [self.crmController.currencyFormatter numberFromString:sAmount].floatValue;
        amount = fenterprice * amount * 0.01;
    }
    
    if (checkCash) {
        billAmountCalculator.fCheckCashCharge = amount;
        billAmountCalculator.isCheckCash = YES;
    } else {
        billAmountCalculator.fExtraChargeAmt = amount;
        billAmountCalculator.isCheckCash = NO;

    }
}

- (void)addItemWithItemId:(NSString *)itemId withSalesPrice:(NSString *)salesPrice
{
    Item *anItem = [self fetchAllItems:itemId];
    if (anItem !=nil) {
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc]init];
        
        itemDictionary[@"itemId"] = anItem.itemCode.stringValue;
        if (anItem.itemDepartment)
        {
            if(anItem.itemDepartment.isAgeApply != nil)
            {
                itemDictionary[@"isAgeApply"] = anItem.itemDepartment.isAgeApply;
            }
            else
            {
                itemDictionary[@"isAgeApply"] = @"0";
            }
        }
        else
        {
            itemDictionary[@"isAgeApply"] = @"0";
        }
        
//        NSInteger dep_id=[anItem.deptId integerValue];
//        if(dep_id>0)
//        {
//            if(anItem.itemDepartment.isAgeApply != nil)
//            {
//                [itemDictionary setObject:anItem.itemDepartment.isAgeApply forKey:@"isAgeApply"];
//            }
//            else
//            {
//                [itemDictionary setObject:@"0" forKey:@"isAgeApply"];
//            }
//        }
//        else
//        {
//            [itemDictionary setObject:@"0" forKey:@"isAgeApply"];
//        }
//        
        
        itemDictionary[@"isCheckCash"] = @"0";
        itemDictionary[@"isDeduct"] = @"0";
        itemDictionary[@"isExtraCharge"] = @"0";
        itemDictionary[@"isTax"] = anItem.taxApply;
        itemDictionary[@"ExtraCharge"] = @"0";
        itemDictionary[@"CheckCashCharge"] = @"0";
        itemDictionary[@"ChargeType"] = @"";
        itemDictionary[@"ChargeAmount"] = @"0";
        
        if (anItem.itemDepartment)
        {
            NSMutableDictionary *departmentDictionary = [anItem.itemDepartment.departmentDictionary mutableCopy];
            BOOL isExtrachargeValue=[departmentDictionary[@"isExtraCharge"]boolValue];
            if(isExtrachargeValue)
            {
                itemDictionary[@"ChargeType"] = anItem.itemDepartment.chargeTyp;
                itemDictionary[@"ChargeAmount"] = anItem.itemDepartment.chargeAmt;
                if([anItem.itemDepartment.chargeTyp isEqualToString:@"Fix Charge"])
                {
                    billAmountCalculator.fExtraChargeAmt = anItem.itemDepartment.chargeAmt.floatValue;
                }
                else if([anItem.itemDepartment.chargeTyp isEqualToString:@"Percentage(%)"])
                {
                    billAmountCalculator.fExtraChargeAmt = salesPrice.floatValue * anItem.itemDepartment.chargeAmt.floatValue * 0.01;
                }
            }
        }
        currentBillEntryDictionary = itemDictionary;
    }
}




-(void)setReceiptArrayDataWithId :(NSString *)dataId withSalesPrice:(NSString *)salesPrice
{
    if( self.isDepartment==TRUE)
    {
        [self addDepartmentWithId:dataId];
    }
    else if( self.isDepartment == FALSE)
    {
        [self addItemWithItemId:dataId withSalesPrice:salesPrice];
    }
}


#pragma mark-
#pragma mark - Update UI Methods

-(void)clearBillUI
{
    isHouseChargeCollectPay = FALSE;
    billAmountCalculator.isEBTApplicaleForBill = FALSE;
 //   self.dictGiftCard = nil;
    tenderItemTableView.allowsMultipleSelection = NO;
    topUpDiscountVC.view.hidden = YES;
    removeTaxVC.view.hidden = YES;
   // [itemSwipeEditVC.view removeFromSuperview];
    [self resetAgeRestriction];
    [self clearRingUpOrderList];
    [self.crmController.reciptItemLogDataAry removeAllObjects];
    [self.payentVoidDataAry removeAllObjects];
    [self.itemRingUpQueue removeAllObjects];
    self.isPreviousItemProcessInProgress = FALSE;
    cant=0;
    billAmountCalculator.itemRefund = FALSE;
    billAmountCalculator.billWiseDiscountType = BillWiseDiscountTypeNone;

    self.crmController.isbillOrderFromRecall = FALSE;
    self.crmController.isbillOrderFromRecallOffline = FALSE;
//    [self.rmsDbController.rapidPetroPos.arrPumpCartTender removeAllObjects];
    
    [self resetTotal];
    [self.posMenuVC clearSelection];

    [self didClearCustomerDiplayUI];
    
   
    
    _itemCountLabel.text = @"0";
}



-(NSMutableArray *)setCancelLogArray
{
    NSMutableArray *cancelTransaction = [[NSMutableArray alloc]init];
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    int i =1;
    for (NSMutableDictionary *reciptDictionary in reciptArray)
    {
        
        NSString *strOldValue = [NSString stringWithFormat:@"%f",[reciptDictionary[@"itemPrice"] floatValue]];

        NSMutableDictionary *dictInvoiceLog = [[NSMutableDictionary alloc]init];
        dictInvoiceLog[@"ItemCode"] = [reciptDictionary valueForKey:@"itemId"];
        dictInvoiceLog[@"RowPosition"] = [NSString stringWithFormat:@"%d",i];
        dictInvoiceLog[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
        dictInvoiceLog[@"FieldName"] = @"Item";
        dictInvoiceLog[@"Operation"] = @"Cancel Transaction";
        dictInvoiceLog[@"OldValue"] = strOldValue;
        dictInvoiceLog[@"NewValue"] = strOldValue;
        dictInvoiceLog[@"Reason"] = @"";
        dictInvoiceLog[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
        dictInvoiceLog[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
        NSString *strDateTime = [formatter stringFromDate:date];
        dictInvoiceLog[@"TimeStamp"] = strDateTime;
        [cancelTransaction addObject:dictInvoiceLog];
        i++;
    }
    return cancelTransaction;
 
}
- (void) resetTotal
{
    NSString * displyValue = @"0.00";
    NSNumber *sPrice = [NSNumber numberWithFloat:displyValue.integerValue];
    NSString *iAmount = [self.crmController.currencyFormatter stringFromNumber:sPrice];
    
	self.subTotalLabel.text =iAmount;
	self.totalTaxLabel.text = iAmount;
	self.totalDiscountLabel.text = iAmount;
    self.billAmountLabel.text=iAmount;
    if (isEBTValid) {
        self.totalEBTLabel.text=iAmount;
    }
    else
    {
        self.totalEBTLabel.text = @"";
        self.lblEBT.text = @"";
    }

}

#pragma mark- set ItemDetail
-(void)setItemDetail:(Item *)anitem
{
    if (billAmountCalculator.isEBTApplicaleForBill == TRUE && [self shouldEBTRestrictedForItem:anitem] == TRUE)
    {
        billAmountCalculator.variationDetail = nil;

        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self processNextStepForItem];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"You can not add this item in bill." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;
    }
    
    if (billAmountCalculator.isItemRefund == TRUE && [self shouldRefundRestrictedForItem:anitem] == TRUE)
    {
        billAmountCalculator.variationDetail = nil;
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self processNextStepForItem];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"You can not Refund this item." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;
        
    }
    
    if (anitem.itemToPriceMd.count == 0)
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [self processNextStepForItem];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Item PriceMD nil. You can not Ringup this item." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;
        
    }
    
    NSString * itemId = anitem.itemCode.stringValue;
    NSString *price = @"";
    if (anitem.isPriceAtPOS.boolValue == TRUE)
    {
        NSString *sPOSAmount;
        NSNumber *priceValue = 0;

        if(![anitem.item_Desc isEqualToString:@"HouseCharge"] )
        {
            sPOSAmount =[NSString stringWithFormat:@"%f",[self.crmController.currencyFormatter numberFromString:self.priceAtPOSAmount].floatValue];
                for (Item_Price_MD *price_md in anitem.itemToPriceMd)
                {
                    if ([price_md.priceqtytype isEqualToString:billAmountCalculator.packageType]&& price_md.qty.floatValue > 0) {
                        priceValue = @(sPOSAmount.floatValue / price_md.qty.floatValue);
                    }
                }
        }
        else
        {
            priceValue = anitem.salesPrice;
        }
        price = priceValue.stringValue;
        if (price == nil) {
            priceValue = @(sPOSAmount.floatValue) ;
            price = priceValue.stringValue;
        }
        
    }
    else
    {
        NSString *priceScale = anitem.pricescale;
        if([priceScale isEqualToString:@"WSCALE"] || [priceScale isEqualToString:@"APPPRICE"] ||
           [priceScale isEqualToString:@"VARIATIONAPPROPRIATE"] )
        {
            NSNumber *priceValue = 0;
            
            for (Item_Price_MD *price_md in anitem.itemToPriceMd)
            {
                if ([price_md.priceqtytype isEqualToString:billAmountCalculator.packageType]&& price_md.qty.floatValue > 0) {
                    NSString *priceType = [NSString stringWithFormat:@"%@",price_md.applyPrice];
                    if ([priceType isEqualToString:@"PriceA"])
                    {
                        priceValue = price_md.priceA;
                    }
                    else if ([priceType isEqualToString:@"PriceB"])
                    {
                        priceValue = price_md.priceB;
                    }
                    else if ([priceType isEqualToString:@"PriceC"])
                    {
                        priceValue = price_md.priceC;
                    }
                    else
                    {
                        priceValue = price_md.unitPrice;
                    }

                    if (price_md.unitPrice.floatValue > priceValue.floatValue) {
                        priceValue = price_md.unitPrice;
                    }
                    
                    priceValue = @(priceValue.floatValue / price_md.qty.floatValue);
                }
            }
            price = priceValue.stringValue;
            
        }
        else if ([priceScale isEqualToString:@"VARIATION"]) // VARIATION
        {
            price = @"0.00";
        }
        else
        {
            
            NSNumber *priceValue = 0;
            
            for (Item_Price_MD *price_md in anitem.itemToPriceMd)
            {
                if ([price_md.priceqtytype isEqualToString:billAmountCalculator.packageType]&& price_md.qty.floatValue > 0) {
                    NSString *priceType = [NSString stringWithFormat:@"%@",price_md.applyPrice];
                    if ([priceType isEqualToString:@"PriceA"])
                    {
                        priceValue = price_md.priceA;
                    }
                    else if ([priceType isEqualToString:@"PriceB"])
                    {
                        priceValue = price_md.priceB;
                    }
                    else if ([priceType isEqualToString:@"PriceC"])
                    {
                        priceValue = price_md.priceC;
                    }
                    else
                    {
                        priceValue = price_md.unitPrice;
                    }
                    
                    if (price_md.unitPrice.floatValue > priceValue.floatValue) {
                        priceValue = price_md.unitPrice;
                    }
                    
                    priceValue = @(priceValue.floatValue / price_md.qty.floatValue);
                }
            }
            price = priceValue.stringValue;

        }
    }
    
    [self setReceiptArrayDataWithId:itemId withSalesPrice:price];
    
    
    NSString * qty = @"1";
    if (itemRingUpQty.length > 0) {
        qty = itemRingUpQty;
    }
    itemRingUpQty = @"";
    
    NSString * imagePath = anitem.item_ImagePath;
    if (self.isDepartment == TRUE) {
        Department * department = [self didFetchDepartmentWithItemId:anitem.itemCode.stringValue];
        if (department !=nil) {
            imagePath = department.imagePath;
        }
    }
    
    NSString *barcode = anitem.barcode;
    if (itemBarcode.length > 0) {
        barcode = itemBarcode;
    }
    itemBarcode = @"";
    
    
    NSString *itemunitType = @"";
    if (itemUnitType.length > 0) {
        itemunitType = itemUnitType;
    }
    itemUnitType = @"";
    
    NSString *itemUnitqty = @"";
    if (itemUnitQty.length > 0) {
        itemUnitqty = itemUnitQty;
    }
    itemUnitQty = @"";
    
    NSMutableDictionary *billDictionary =  [billAmountCalculator setItemDetailWithBillEntry:currentBillEntryDictionary withItem:anitem WithItemPrice:price WithItemQty:qty WithItemImage:imagePath withItemBarcode:barcode withItemUnitType:itemunitType withItemUnitQty:itemUnitqty];
    billDictionary[@"Discount"] = [[NSMutableArray alloc]init];
    if([self.dictGiftCard valueForKey:@"LoadAmount"]){
        
        billDictionary[@"CardNo"] = [self.dictGiftCard valueForKey:@"CardNo"];
        billDictionary[@"CardType"] = [self.dictGiftCard valueForKey:@"CardType"];
        billDictionary[@"Remark"] = [self.dictGiftCard valueForKey:@"Remark"];
        billDictionary[@"GiftCardTotalBalance"] = [self.dictGiftCard valueForKey:@"GiftCardTotalBalance"];
        [self.dictGiftCard removeAllObjects];
    }
    else if ([self.dictGiftCard valueForKey:@"HouseChargeAmount"])
    {
        billDictionary[@"CardType"] = [self.dictGiftCard valueForKey:@"CardType"];
        billDictionary[@"HouseChargeAmount"] = [self.dictGiftCard valueForKey:@"HouseChargeAmount"];
        [self.dictGiftCard removeAllObjects];
        
    }
    else{
        billDictionary[@"CardNo"] = @"";
        billDictionary[@"CardType"] = @"0";
        billDictionary[@"Remark"] = @"";
        billDictionary[@"GiftCardTotalBalance"] = @(0);
        
    }
    
    [self createRestaurantOrderForBillDictionary:billDictionary forItem:anitem];
    [self updateBillUI];
    [self scrollTableView];
    //    [tenderItemTableView selectRowAtIndexPath:self.currentItemIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    self.priceAtPOSAmount = @"";
}

-(void)createRestaurantOrderForBillDictionary:(NSMutableDictionary *)billDictionary forItem:(Item *)anitem
{
    
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantOrder *restaurantOrder;
    if (self.restaurantOrderObjectId == nil)
    {
        NSMutableDictionary *restaurantOrderDetail = [[NSMutableDictionary alloc]init];
        restaurantOrderDetail[@"noOfGuest"] = @"1";
        restaurantOrderDetail[@"tableName"] = @"Retail";
        restaurantOrderDetail[@"orderid"] = @(0);
        restaurantOrderDetail[@"orderState"] = @(OPEN_ORDER);
        restaurantOrderDetail[@"InvoiceNo"] = [self currentRegisterInvoiceNumber];
        restaurantOrder = [self.updateManager insertRestaurantOrderListInLocalDataBase:restaurantOrderDetail withContext:privateManageobjectContext];
        self.restaurantOrderObjectId = restaurantOrder.objectID;
    }
    else
    {
        restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
    }
    
    NSMutableDictionary *restaurantItemList = [[NSMutableDictionary alloc]init];
    restaurantItemList[@"isCanceled"] = @(0);
    restaurantItemList[@"isNoPrint"] = @(0);
    restaurantItemList[@"isDineIn"] = @(restaurantOrder.isDineIn.boolValue);
    restaurantItemList[@"isPrinted"] = @(0);
    restaurantItemList[@"itemId"] = [billDictionary valueForKey:@"itemId"];
    restaurantItemList[@"itemIndex"] = @(restaurantOrder.restaurantOrderItem.allObjects.count);
    restaurantItemList[@"noteToChef"] = @"";
    restaurantItemList[@"orderId"] = @(0);
    restaurantItemList[@"orderItemId"] = @(0);
    restaurantItemList[@"previousQuantity"] = @(0);
    restaurantItemList[@"quantity"] = [billDictionary valueForKey:@"itemQty"];
    restaurantItemList[@"itemName"] = [billDictionary valueForKey:@"itemName"];
    restaurantItemList[@"guestId"] = @(guestSelectionVC.selectedGuestId);
    billDictionary[@"guestId"] = @(guestSelectionVC.selectedGuestId);
    billDictionary[@"isDineIn"] = @(restaurantOrder.isDineIn.boolValue);
    billDictionary[@"itemIndex"] = @(restaurantOrder.restaurantOrderItem.allObjects.count);
    restaurantItemList[@"itemDetail"] = billDictionary;
    
    
    Item *itemTolink = (Item *)[privateManageobjectContext objectWithID:anitem.objectID];
    [self.updateManager insertRestaurantItemInLocalDataBase:restaurantItemList withContext:privateManageobjectContext withItemRestaurantOrder:restaurantOrder withItem:itemTolink];

}

-(void)TaxCalculateForReciptDataArray:(NSMutableArray *)reciptArray
{
    for (int i=0; i<reciptArray.count; i++)
    {
        NSMutableDictionary *itemRcptDisc = reciptArray[i];
        NSMutableArray *taxArray = [itemRcptDisc valueForKey:@"ItemTaxDetail"];
        if([taxArray isKindOfClass:[NSMutableArray class]])
        {
            BOOL isEBTApplicable = [itemRcptDisc[@"EBTApplicable"] boolValue];
            if (isEBTApplicable) {
                BOOL isEBTApplied = [itemRcptDisc[@"EBTApplied"] boolValue];
                if (isEBTApplicable == TRUE && isEBTApplied == TRUE) {
                    continue;
                }
            }

                float TaxAmount = 0;
                for (int i=0; i<taxArray.count; i++)
                {
                    NSMutableDictionary *Dict = taxArray[i];
                    float price = 0.00;
                    
                    if ([[itemRcptDisc valueForKey:@"itemType"] isEqualToString:@"Item"])
                    {
                        Item *anItem = [self fetchAllItems:[itemRcptDisc valueForKey:@"itemId"]];
                        
                        if([anItem.taxType isEqualToString:@"Tax wise"])
                        {
                            float variationAmount = [itemRcptDisc[@"TotalVarionCost"] floatValue] / [[itemRcptDisc valueForKey:@"itemQty"] floatValue] ;

                            price = [itemRcptDisc[@"itemPrice"] floatValue] + variationAmount;
                        }
                        else if([anItem.taxType isEqualToString:@"Department wise"])
                        {
                            Department *department=[self fetchAllDepartments:[NSString stringWithFormat:@"%ld",(long)[itemRcptDisc[@"departId"]integerValue ]]];
                            
                            float variationAmount = [itemRcptDisc[@"TotalVarionCost"] floatValue] / [[itemRcptDisc valueForKey:@"itemQty"] floatValue] ;
                            float itemPrice = [itemRcptDisc[@"itemPrice"] floatValue];
                            
                            NSString *totalPrice = [NSString stringWithFormat:@"%.2f", variationAmount + itemPrice];
                            
                            price = [self departmentTaxcalculation:totalPrice department:department];
                        }
                        else
                        {
                            float variationAmount = [itemRcptDisc[@"TotalVarionCost"] floatValue] / [[itemRcptDisc valueForKey:@"itemQty"] floatValue] ;
                            
                            price = [itemRcptDisc[@"itemPrice"] floatValue] + variationAmount;
                        }
                    }
                    else if ([[itemRcptDisc valueForKey:@"itemType"] isEqualToString:@"Department"])
                    {
                        Department *department = [self fetchAllDepartments:[NSString stringWithFormat:@"%ld",(long)[itemRcptDisc[@"departId"]integerValue ]]];
                        price = [self departmentTaxcalculation:[NSString stringWithFormat:@"%@", itemRcptDisc[@"itemPrice"]] department:department];
                    }
                    
                    float despriceTaxAmount = (price * [Dict[@"TaxPercentage"] floatValue]*0.01);
                    float itmDiscout=[[itemRcptDisc valueForKey:@"itemQty"] floatValue]*despriceTaxAmount;
                    
                    NSString *priceValuetax1 = [NSString stringWithFormat:@"%f",itmDiscout];
                    TaxAmount+=itmDiscout;
                    Dict[@"ItemTaxAmount"] = priceValuetax1;
                    taxArray[i] = Dict;
                }
                itemRcptDisc[@"ItemTaxDetail"] = taxArray;
                itemRcptDisc[@"itemTax"] = @(TaxAmount);
        }
    }
}

#pragma mark -
#pragma mark calculateTotal

- (void)updateSubtotal:(float)totalPrice taxValue:(float)taxValue totalDiscount:(float)totalDiscount

{
    NSNumber *sTotal = @(totalPrice);
    self.subTotalLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sTotal]];
    
    NSString *stingToFloatTax=[NSString stringWithFormat:@"%.2f", taxValue];
    
    NSNumber *sTotalTax = @(stingToFloatTax.floatValue );
    self.totalTaxLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sTotalTax]];
    
    
    NSString *stingToFloatDiscount=[NSString stringWithFormat:@"%.2f",totalDiscount];
    
    NSNumber *sTotalDiscount = @(stingToFloatDiscount.floatValue);
    self.totalDiscountLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sTotalDiscount]];
    
    float total=totalPrice + taxValue;
    NSNumber *TOtal= @(total);
    self.billAmountLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:TOtal]];
    //tenderTotal.text = self.lblTotal.text;

}

- (float)itemVariationCost:(NSMutableDictionary *)ringupEntry
{
    float itemVariationCost=0.0;
    if([ringupEntry valueForKey:@"InvoiceVariationdetail"])
    {
        itemVariationCost = [[(NSArray *)ringupEntry[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.VariationBasicPrice"] floatValue];
    }
    return itemVariationCost;
}

- (float)itemVariationCostForDiscountedPrice:(NSMutableDictionary *)ringupEntry
{
    float itemVariationCost=0.0;
    if([ringupEntry valueForKey:@"InvoiceVariationdetail"])
    {
        itemVariationCost = [[(NSArray *)ringupEntry[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.Price"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue];
    }
    return itemVariationCost;
}


- (void) calculateTotalForReciptArray:(NSMutableArray *)reciptArray
{
    float totalPrice = 0.0f;
    float taxValue = 0.0f;
    float totalDiscount = 0.0f;
    
    if (reciptArray.count > 0)
    {
		for (int i=0; i<reciptArray.count; i++)
        {
            NSMutableDictionary *ringupEntry = reciptArray[i];
            NSMutableArray *reciptDataArray = [ringupEntry valueForKey:@"item"];
            BOOL  checkcash=[[reciptDataArray valueForKey:@"isCheckCash"] boolValue];
            BOOL  extracharge=[[reciptDataArray valueForKey:@"isExtraCharge"] boolValue];
            
            if(checkcash)
            {
                totalPrice -= ([ringupEntry[@"itemPrice"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]);//-([[ringupEntry valueForKey:@"ItemDiscount"] floatValue]));

                
                totalPrice +=[[reciptDataArray valueForKey:@"CheckCashCharge"] floatValue];
                
                taxValue += [ringupEntry[@"itemTax"] floatValue];
                
                totalDiscount += [ringupEntry[@"ItemDiscountPercentage"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]*[[ringupEntry valueForKey:@"ItemBasicPrice"] floatValue]*0.01;
                // checkcash=1;
            }
            else if(extracharge)
            {
                totalPrice += ([ringupEntry[@"itemPrice"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]);//-([[ringupEntry valueForKey:@"ItemDiscount"] floatValue]));
                
                totalPrice+=[[reciptDataArray valueForKey:@"ExtraCharge"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] intValue];
                
                taxValue += [ringupEntry[@"itemTax"] floatValue];
                
                
                totalDiscount += [ringupEntry[@"ItemDiscountPercentage"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]*[[ringupEntry valueForKey:@"ItemBasicPrice"] floatValue]*0.01;
                
                //   totalDiscount += [[ringupEntry valueForKey:@"ItemDiscount"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue];
            }
            else
            {
                //#define ADDRESS_FLOATING_POINT
#ifdef ADDRESS_FLOATING_POINT
                totalPrice += [ringupEntry[@"TotalPrice"] floatValue];
                taxValue += [ringupEntry[@"itemTax"] floatValue];
                totalDiscount += [ringupEntry[@"TotalDiscount"] floatValue];
#else
                
                float itemVariationCost = [self itemVariationCost:ringupEntry];
             
                float itevariationWithDiscount = [self itemVariationCostForDiscountedPrice:ringupEntry];
                
                totalPrice += ([ringupEntry[@"itemPrice"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]) + itevariationWithDiscount;
                taxValue += [ringupEntry[@"itemTax"] floatValue];
                //                totalDiscount += [[ringupEntry valueForKey:@"ItemDiscount"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue];
                
                float totalItemPrice = [[ringupEntry valueForKey:@"ItemBasicPrice"] floatValue] + itemVariationCost;
                
                totalDiscount += [ringupEntry[@"ItemDiscountPercentage"] floatValue]*[[ringupEntry valueForKey:@"itemQty"] floatValue]* totalItemPrice *0.01;
#endif
            }
        }
        
	}
    
    [self updateSubtotal:totalPrice taxValue:taxValue totalDiscount:totalDiscount];
    
    CGFloat qty = 0;
    for (int i = 0 ; i < reciptArray.count; i++) {
        CGFloat totalQty = [[reciptArray[i] valueForKeyPath:@"itemQty"] floatValue] / [[reciptArray[i] valueForKeyPath:@"PackageQty"] floatValue];
        qty += totalQty;
    }
    _itemCountLabel.text= [NSString stringWithFormat:@"%@",@(qty)];

}
- (float)departmentTaxcalculation:(NSString *)salesPrice department:(Department *)department
{
    float checkCashPrice = 0.00;
    
    if (department.chkExtra.boolValue || department.chkCheckCash.boolValue)
    {
        
        if ([department.taxApplyIn isEqualToString:@"Fee"])
        {
            if(department.chkExtra.boolValue)
            {
                checkCashPrice = [self getDepartmentExtraChargeAmount:department withSalesPrice:salesPrice];
            }
            else if (department.chkCheckCash.boolValue)
            {
                checkCashPrice = [self getDepartmentCheckCashAmount:department withSalesPrice:salesPrice];
            }
            
        }
        else if ([department.taxApplyIn isEqualToString:@"Both"])
        {
            float departmentCheckExtraAmt = 0.00;
            
            
            
            if(department.chkExtra.boolValue)
            {
                departmentCheckExtraAmt = [self getDepartmentExtraChargeAmount:department withSalesPrice:salesPrice];
            }
            else if (department.chkCheckCash.boolValue)
            {
                departmentCheckExtraAmt = [self getDepartmentCheckCashAmount:department withSalesPrice:salesPrice];

            }
        
            checkCashPrice = salesPrice.floatValue + departmentCheckExtraAmt;
        }
        else
        {
            checkCashPrice = salesPrice.floatValue;
        }
    }
    else
        
    {
        checkCashPrice = salesPrice.floatValue;
        
    }
    return checkCashPrice;
}
- (CGFloat)getDepartmentExtraChargeAmount:(Department *)department withSalesPrice:(NSString *)salesPrice
{
    float extraChargeAmount = 0.00;
    NSString *sChargetype=department.chargeTyp;
    float fChargeAmt=department.chargeAmt.floatValue;
    
    if([sChargetype isEqualToString:@"Fix Charge"])
    {
        extraChargeAmount = fChargeAmt;
    }
    else if([sChargetype isEqualToString:@"Percentage(%)"])
    {
        NSString *sAmount = salesPrice;
        float fenterprice=sAmount.floatValue;
        extraChargeAmount = fenterprice * fChargeAmt * 0.01;
    }
    else
    {
        
    }
    return extraChargeAmount;
}

- (CGFloat)getDepartmentCheckCashAmount:(Department *)department withSalesPrice:(NSString *)salesPrice
{
    float checkCashPrice = 0.00;
    
    NSString *sCheckCashtype=department.checkCashType;
    float fCheckCashAmt=department.checkCashAmt.floatValue;
    
    if([sCheckCashtype isEqualToString:@"Fix Charge"])
    {
        checkCashPrice = fCheckCashAmt;
    }
    else if([sCheckCashtype isEqualToString:@"Percentage(%)"])
    {
        NSString *sAmount = salesPrice;
        
        float fenterprice=sAmount.floatValue;
        checkCashPrice = fenterprice * fCheckCashAmt * 0.01;
    }
    else
    {
        
    }
    return checkCashPrice;
}

- (void)removeRestaurantOrderObject
{

    if (self.restaurantOrderObjectId == nil) {
        return;
    }

    if ([self.moduleIdentifierString isEqualToString:@"RcrPosRestaurantVC"])
    {

        NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        RestaurantOrder *restaurantOrder = (RestaurantOrder *) [privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
        restaurantOrder = (RestaurantOrder * )[privateManageobjectContext objectWithID:restaurantOrder.objectID];

        if (restaurantOrder.restaurantOrderItem.allObjects.count > 0) {
            for (RestaurantItem *restaurantItem in restaurantOrder.restaurantOrderItem.allObjects) {

                restaurantItem.isCanceled = @(TRUE);
            }
            [UpdateManager saveContext:privateManageobjectContext];
        }
    }
    else
    {
        NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];

        [UpdateManager deleteFromContext:privateManageobjectContext objectId:self.restaurantOrderObjectId];
        [UpdateManager saveContext:privateManageobjectContext];
        self.restaurantOrderObjectId = nil;
    }

}

-(void)clearRingUpOrderList
{
    [self removeRestaurantOrderObject];
}

-(void)removeRestaurantOrderFromOrderList
{
    [self removeRestaurantOrderObject];
}

#pragma mark-
#pragma mark - Void Transaction Process
-(void) VoidTransactions
{
    
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;

    if (reciptArray.count>0)
    {
		NSMutableDictionary * param = [self getCurrentBillDataForBillOrder:reciptArray];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            [self voidTransactionProcessResponse:response error:error];
        };
        
        self.voidTransactionsWC = [self.voidTransactionsWC initWithRequest:KURL actionName:WSM_ADD_VOID_INVOICE_TRANS params:param completionHandler:completionHandler];
	}
}
- (void)voidTransactionProcessResponse:(id)response error:(NSError *)error
{
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableDictionary *responseVoidDict = [self.rmsDbController objectFromJsonString:[response  valueForKey:@"Data"]];
                
                [self voidOrderFromLocalDatabase];
                
                [self clearBillUI];
                NSInteger recallDataCount = [[responseVoidDict valueForKey:@"RecallCount"] integerValue];
                
                self.crmController.recallCount = recallDataCount;
                [self.posMenuVC setRecallCount:self.crmController.recallCount AtIndex:[self indexForPosMenuId:RECALL_POS_MENU]];
                
            } else {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else {
        
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error in web services.\nPlease try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
        
    }
    [_activityIndicator hideActivityIndicator];

}

- (void)voidOrderFromLocalDatabase
{
    if ([[self moduleIdentifier] isEqualToString:@"RcrPosRestaurantVC"])
    {
        [self cancelRestaurantOrder];
        
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        for (UIViewController *viewController in viewControllerArray)
        {
            if ([viewController isKindOfClass:[RestaurantOrderList class]])
            {

                [self.navigationController popToViewController:viewController animated:TRUE];
                break;
            }
        }
    }
    else
    {
        [self removeRestaurantOrderObject];
    }
}


#pragma mark-
#pragma mark- Set BillEntry Data
- (NSString *)billItemDetailStringForOrder:(NSMutableArray *)reciptArray
{
    NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
    itemDictionary[@"BillItemDetail"] = reciptArray;
    if (billAmountCalculator.billWiseDiscount) {
        itemDictionary[@"IsBillDiscountApplicable"] = billAmountCalculator.billWiseDiscount;
    }
    else
    {
        itemDictionary[@"IsBillDiscountApplicable"] = @(0);
    }
    itemDictionary[@"BillDiscountType"] = @(billAmountCalculator.billWiseDiscountType);
    
    
    if (self.crmController.recallInvoiceId.length > 0) {
        itemDictionary[@"RecallInvoiceId"] = [NSString stringWithFormat:@"%@",self.crmController.recallInvoiceId];
    }
    else
    {
        itemDictionary[@"RecallInvoiceId"] = @"";
    }
    
    if (rcrRapidCustomerLoayalty)
    {
        itemDictionary[@"BillCustomerDetail"] = rcrRapidCustomerLoayalty.customerDetailDictionary;
    }
    else
    {
        itemDictionary[@"BillCustomerDetail"] = @"";
    }
    

    NSString *jsonStringOfBillData = [self.rmsDbController jsonStringFromObject:itemDictionary];
    return jsonStringOfBillData;
}

- (NSMutableDictionary *) getCurrentBillDataForBillOrder:(NSMutableArray *)reciptArray
{
    NSMutableDictionary *currentInvoiceDic = [[NSMutableDictionary alloc] init];
    
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [self InvoiceBillMst];
    invoiceDetailDict[@"InvoiceItemDetail"] = [self InvoiceBillItemDetailForBillArray:reciptArray];
    if(self.crmController.reciptItemLogDataAry.count>0)
    {
        invoiceDetailDict[@"InvoiceItemLog"] = self.crmController.reciptItemLogDataAry;
    }
    
    NSString *jsonStringOfBillData = [self billItemDetailStringForOrder:reciptArray];
    
    [invoiceDetail addObject:invoiceDetailDict];
    
    currentInvoiceDic[@"InvoiceDetail"] = invoiceDetail;
    currentInvoiceDic[@"BillDetail"] = jsonStringOfBillData;

    return currentInvoiceDic;
}


- (NSMutableArray *) InvoiceBillMst
{
	NSMutableArray * invoiceMst = [[NSMutableArray alloc] init];
	NSMutableDictionary * invoiceDataDict = [[NSMutableDictionary alloc] init];
    invoiceDataDict[@"InvoiceNo"] = @"0";  // invoice no increment in server side and service side invoiceno datatype is long so Set Object is 0...
    
    if (self.crmController.isbillOrderFromRecall)
    {
        invoiceDataDict[@"InvoiceholdId"] = self.crmController.recallInvoiceId;
    }
    else
    {
        invoiceDataDict[@"InvoiceholdId"] = @"0";  // invoice no increment in server side and service side invoiceno datatype is long so Set Object is 0...
    }

    invoiceDataDict[@"RegisterInvNo"] = @"0";
    
	invoiceDataDict[@"CustRefID"] = @"0";
	invoiceDataDict[@"Discount"] = [self.rmsDbController.globalDict valueForKey:@"BillDiscount"];
	invoiceDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
	invoiceDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    invoiceDataDict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    invoiceDataDict[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
    NSString *subTotal=[self.subTotalLabel.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
	invoiceDataDict[@"SubTotal"] = [NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:subTotal].floatValue];
    
    NSString *taxTotal=[self.totalTaxLabel.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
	invoiceDataDict[@"TaxAmount"] = [NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:taxTotal].floatValue];
    
    NSString *sTotal=[self.billAmountLabel.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
	invoiceDataDict[@"BillAmount"] = [NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sTotal].floatValue];
    
    if (holdMessage.length > 0)
    {
        invoiceDataDict[@"Message"] = holdMessage;
    }
    else
    {
        invoiceDataDict[@"Message"] = @"";
    }
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSString *strDate=[NSString stringWithFormat:@"%@",destinationDate];
    invoiceDataDict[@"Datetime"] = strDate;
    
	[invoiceMst addObject:invoiceDataDict];
	
	return invoiceMst;
}

- (NSMutableArray *) InvoiceBillItemDetailForBillArray:(NSMutableArray *)reciptArray
{
    NSMutableArray * invoiceItemDetail = [[NSMutableArray alloc] init];
    for (int i=0; i<reciptArray.count; i++)
    {
        NSMutableDictionary * tempObject = reciptArray[i];
        NSMutableDictionary * itemsDataDict = [[NSMutableDictionary alloc] init];
        
        itemsDataDict[@"ItemCode"] = [tempObject valueForKey:@"itemId"];
        itemsDataDict[@"ItemAmount"] = [NSString stringWithFormat:@"%.02f", [tempObject[@"itemPrice"] floatValue]];
        itemsDataDict[@"ItemImage"] = [tempObject valueForKey:@"itemImage"];
        itemsDataDict[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
        itemsDataDict[@"isAgeApply"] = [tempObject valueForKey:@"item"][@"isAgeApply"];
        
        itemsDataDict[@"isCheckCash"] = [tempObject valueForKey:@"item"][@"isCheckCash"];
        itemsDataDict[@"CheckCashAmount"] = [tempObject valueForKey:@"item"][@"CheckCashCharge"];
        itemsDataDict[@"isDeduct"] = [tempObject valueForKey:@"item"][@"isDeduct"];
        itemsDataDict[@"isAgeApply"] = [tempObject valueForKey:@"item"][@"isAgeApply"];
        itemsDataDict[@"PackageQty"] = [tempObject valueForKey:@"PackageQty"];
        itemsDataDict[@"PackageType"] = [tempObject valueForKey:@"PackageType"];

        itemsDataDict[@"ExtraCharge"] = [tempObject valueForKey:@"item"][@"ExtraCharge"];
        itemsDataDict[@"ItemType"] = [tempObject valueForKey:@"itemType"];
        
        itemsDataDict[@"PackageQty"] = [tempObject valueForKey:@"PackageQty"];
        itemsDataDict[@"PackageType"] = [tempObject valueForKey:@"PackageType"];
        itemsDataDict[@"departId"] = [tempObject valueForKey:@"departId"];
        itemsDataDict[@"Barcode"] = [tempObject valueForKey:@"Barcode"];
        itemsDataDict[@"ItemCost"] = [tempObject valueForKey:@"ItemCost"];
        itemsDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
        itemsDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        
        itemsDataDict[@"ItemName"] = [tempObject valueForKey:@"itemName"];
        
        itemsDataDict[@"ItemDiscountAmount"] = [tempObject valueForKey:@"ItemDiscount"];
        itemsDataDict[@"ItemQty"] = [tempObject valueForKey:@"itemQty"];
        
        
        if ([tempObject valueForKey:@"EBTApplied"])
        {
            itemsDataDict[@"IsEBT"] = [tempObject valueForKey:@"EBTApplied"];
        }

        
        if ([[tempObject valueForKey:@"ItemBasicPrice"] floatValue] < 1 && [[tempObject valueForKey:@"ItemBasicPrice"] floatValue] > 0) {
            itemsDataDict[@"ItemBasicAmount"] = [NSString stringWithFormat:@"0%@",[tempObject valueForKey:@"ItemBasicPrice"]];
        } else if ([[tempObject valueForKey:@"ItemBasicPrice"] floatValue] < 0) {
            itemsDataDict[@"ItemBasicAmount"] = [NSString stringWithFormat:@"-0%@",[[tempObject valueForKey:@"ItemBasicPrice"] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        } else {
            itemsDataDict[@"ItemBasicAmount"] = [tempObject valueForKey:@"ItemBasicPrice"];
        }
        float TotTax=0.0;
        
        if (([tempObject[@"itemTax"] floatValue] != 0.0) && !([tempObject[@"itemTax"] floatValue] < 0.0)) {
            
            TotTax=[[tempObject valueForKey:@"itemQty"] floatValue]*[tempObject[@"itemTax"] floatValue];
            
            
            itemsDataDict[@"ItemTaxAmount"] = [NSString stringWithFormat:@"%f",TotTax];
        } else {
            itemsDataDict[@"ItemTaxAmount"] = @"0.0";
        }
        itemsDataDict[@"TotalItemAmount"] = [NSString stringWithFormat:@"%.2f",[[tempObject valueForKey:@"itemQty"] intValue]*[tempObject[@"itemPrice"] floatValue]+TotTax];
        
        itemsDataDict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
        
        if (![[reciptArray[i] valueForKey:@"ItemTaxDetail"] isEqual:@""]) {
            if ([[reciptArray[i] valueForKey:@"ItemTaxDetail"] count] > 0) {
                NSMutableArray * itemRecptTaxarray = [[NSMutableArray alloc] init];
                for (int z=0; z<[[reciptArray[i] valueForKey:@"ItemTaxDetail"] count]; z++) {
                    NSMutableDictionary * tempTaxItem = [NSMutableDictionary dictionaryWithDictionary:[reciptArray[i] valueForKey:@"ItemTaxDetail"][z]];
                    tempTaxItem[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
                    tempTaxItem[@"ItemCode"] = [tempObject valueForKey:@"itemId"];
                    tempTaxItem[@"TaxId"] = [tempTaxItem valueForKey:@"TaxId"];
                    tempTaxItem[@"TaxPercentage"] = [tempTaxItem valueForKey:@"TaxPercentage"];
                    tempTaxItem[@"TaxAmount"] = [tempTaxItem valueForKey:@"TaxAmount"];
                    //   [tempTaxItem setObject:[tempTaxItem valueForKey:@"ItemTaxAmount"] forKey:@"ItemTaxAmount"];
                    NSString *strTaxAmount=[NSString stringWithFormat:@"%f",[[tempObject valueForKey:@"itemQty"] intValue] *[[tempTaxItem valueForKey:@"ItemTaxAmount"] floatValue]];
                    tempTaxItem[@"ItemTaxAmount"] = strTaxAmount;
                    tempTaxItem[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
                    
                    [itemRecptTaxarray addObject:tempTaxItem];
                }
                itemsDataDict[@"ItemTaxDetail"] = itemRecptTaxarray;
            } else {
                itemsDataDict[@"ItemTaxDetail"] = @"";
            }
        } else {
            itemsDataDict[@"ItemTaxDetail"] = @"";
        }
        
        
        if (tempObject[@"InvoiceVariationdetail"])
        {
            NSMutableArray * variationDetail = tempObject[@"InvoiceVariationdetail"];
            for (int iVar = 0; iVar < variationDetail.count; iVar++)
            {
                NSMutableDictionary *variatonDict = variationDetail[iVar];
                variatonDict[@"RowPosition"] = [NSString stringWithFormat:@"%d",i+1];
            }
            itemsDataDict[@"InvoiceVariationdetail"] = variationDetail;
        }
        else
        {
            itemsDataDict[@"InvoiceVariationdetail"] = @"";
        }
        
        
        float retailAmount = [tempObject[@"itemPrice"] floatValue];
        float variationAmount = [tempObject[@"TotalVarionCost"] floatValue];
        
        itemsDataDict[@"VariationAmount"] = [NSString stringWithFormat:@"%f", variationAmount];
        itemsDataDict[@"RetailAmount"] = [NSString stringWithFormat:@"%f", retailAmount];
        itemsDataDict[@"UnitQty"] = @"0";
        itemsDataDict[@"UnitType"] = @"";
        itemsDataDict[@"ItemMemo"] = tempObject[@"Memo"];
        
        
        [invoiceItemDetail addObject:itemsDataDict];
    }
    return invoiceItemDetail;
}

#pragma mark-
#pragma mark- Recall Delegate Methods

-(void)didCancelRecallOrder
{
    [Appsee addEvent:kPosMenuRecallCancel];
    [self.posMenuVC clearSelection];
    [self.posMenuVC setRecallCount:self.crmController.recallCount AtIndex:[self indexForPosMenuId:RECALL_POS_MENU]];
}

-(void)didRecallOrderWithInvoiceId :(NSString *)invoiceId
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

    [self.posMenuVC clearSelection];
    [self.posMenuVC setRecallCount:self.crmController.recallCount AtIndex:[self indexForPosMenuId:RECALL_POS_MENU]];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:self.crmController.recallInvoiceId forKey:@"SrNoInvoiceHold"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self recallInvListProcessResponse:response error:error];
        });
    };

    
    self.recallInvListWC = [self.recallInvListWC initWithRequest:KURL actionName:WSM_RECALL_INVOICE_LIST params:param completionHandler:completionHandler];

}

- (void)recallInvListProcessResponse:(id)response error:(NSError *)error{
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray * responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSString *billDetail = [responsearray.firstObject valueForKey:@"BillDetail"];
                
                NSError *jsonError;
                NSData *objectData = [billDetail dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *billDetailDictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                     options:NSJSONReadingMutableContainers
                                                                                       error:&jsonError];
                NSArray *sortDescriptors = [self sortDiscriptorForItemRingUPResultController];

                NSArray *billReciptArray = [[billDetailDictionary valueForKey:@"BillItemDetail"] sortedArrayUsingDescriptors:sortDescriptors];

                if (billReciptArray.count > 0) {
                    [self clearBillUI];
                    
                    billAmountCalculator.billWiseDiscountType = [[billDetailDictionary valueForKey:@"BillDiscountType"] integerValue];
                    billAmountCalculator.billWiseDiscount = [billDetailDictionary valueForKey:@"IsBillDiscountApplicable"];
                    
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:@"ClearAllRecord" forKey:@"Tender"];
                    [self.crmController writeDictionaryToCustomerDisplay:dict];
                    self.crmController.isbillOrderFromRecall = TRUE;
                    
                    for (NSMutableDictionary *billDictionary in billReciptArray)
                    {
                        if ([[billDictionary valueForKey:@"EBTApplied"] boolValue] == TRUE)
                        {
                            billAmountCalculator.isEBTApplicaleForBill = TRUE;
                        }
                        
                        Item *item = [self fetchAllItems:[billDictionary valueForKey:@"itemId"]];
                        if (item != nil) {
                            [self createRestaurantOrderForBillDictionary:billDictionary forItem:item];
                        }
                    }
                    
                    if (billDetailDictionary[@"BillCustomerDetail"] && [billDetailDictionary[@"BillCustomerDetail"] isKindOfClass:[NSDictionary class]] )
                    {
                        rcrRapidCustomerLoayalty = [[RapidCustomerLoyalty alloc] init];
                        [rcrRapidCustomerLoayalty setupCustomerDetail:billDetailDictionary[@"BillCustomerDetail"]];
                        
                        self.selectedCustomerDetail = billDetailDictionary[@"BillCustomerDetail"];
                        _lblCustomerName.text = rcrRapidCustomerLoayalty.customerName;
                        [_btnRemoveCustomer setHidden:NO];
                    }
                    else{
                        _lblCustomerName.text = @"";
                        [_btnRemoveCustomer setHidden:YES];
                    }
                    
                    [self createPrepayArrayfromHoldTransaction:billReciptArray];
                }
                else
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Can not process for Recall. Please try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                [self updateBillUI];
                
                
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please try again later." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}


-(void)createPrepayArrayfromHoldTransaction:(NSArray *)itemList{
    
    for (NSDictionary *itemDetail in itemList) {
        
        if([itemDetail[@"Barcode"] isEqualToString:@"GAS"] && itemDetail[@"Pump"]){
           
            NSArray *pumpNo = [itemDetail[@"Pump"] componentsSeparatedByString:@" "];
            
//            NSDictionary *dictprepay = [@{
//                                          @"isAmount":@(1),
//                                          @"number":[NSNumber numberWithFloat:[itemDetail[@"ItemCost"] floatValue]],
//                                          @"selectedPump":pumpNo[1],
//                                          } mutableCopy ];
            
//            RapidPetroCartPayment * hold = [[RapidPetroCartPayment alloc]init];
//            hold.pumpIndex = pumpNo[1];
//            hold.prePayAmountLimit = [NSNumber numberWithFloat:[itemDetail[@"ItemCost"] floatValue]];
//            hold.paymentType = PaymentTypePrePay;
//            [self.rmsDbController.rapidPetroPos.arrPumpCartTender addObject:hold];

        }
    }
}

-(void)didRecallOrderWithOfflineInvoiceId :(NSString *)invoiceId withOfflineData:(NSData *)recallOfflineData
{
    [self.posMenuVC clearSelection];
    [self clearBillUI];
    self.crmController.isbillOrderFromRecallOffline = TRUE;
    [self.posMenuVC setRecallCount:self.crmController.recallCount AtIndex:[self indexForPosMenuId:RECALL_POS_MENU]];
    NSMutableArray *recallDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:recallOfflineData];
    [self setInvoiceItemDetail:[[recallDataArray valueForKey:@"InvoiceDetail"] valueForKey:@"InvoiceItemDetail"]];
    self.crmController.isbillOrderFromRecall = TRUE;
}



- (void) setInvoiceItemDetail:(NSMutableArray *)invoiceItemData
{
    [self.crmController.reciptItemLogDataAry removeAllObjects];
    
	for (int i=0; i<[invoiceItemData.firstObject count]; i++)
    {
        NSMutableDictionary * tempItemData = invoiceItemData.firstObject[i];
		NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setValue:[tempItemData valueForKey:@"ItemCode"] forKey:@"itemId"];
        
        tempDict[@"itemPrice"] = @([[tempItemData valueForKey:@"ItemAmount"] floatValue]);
        [tempDict setValue:[tempItemData valueForKey:@"ItemBasicAmount"] forKey:@"ItemBasicPrice"];
        [tempDict setValue:[tempItemData valueForKey:@"ItemDiscountAmount"] forKey:@"ItemDiscount"];
        tempDict[@"itemTax"] = @([[tempItemData valueForKey:@"ItemTaxAmount"] floatValue]);
        [tempDict setValue:[tempItemData valueForKey:@"ItemName"] forKey:@"itemName"];
        [tempDict setValue:[tempItemData valueForKey:@"ItemQty"] forKey:@"itemQty"];
        [tempDict setValue:[tempItemData valueForKey:@"ItemImage"] forKey:@"itemImage"];
        [tempDict setValue:[tempItemData valueForKey:@"ItemType"] forKey:@"itemType"];
        [tempDict setValue:[tempItemData valueForKey:@"departId"] forKey:@"departId"];
        [tempDict setValue:[tempItemData valueForKey:@"Barcode"] forKey:@"Barcode"];
        [tempDict setValue:[tempItemData valueForKey:@"ItemCost"] forKey:@"ItemCost"];
        [tempDict setValue:[tempItemData valueForKey:@"PackageType"] forKey:@"PackageType"];
        [tempDict setValue:[tempItemData valueForKey:@"PackageQty"] forKey:@"PackageQty"];

        // add item information.
		NSMutableDictionary * itemInfo = [[NSMutableDictionary alloc] init];
        
        // add data in data dictionary.
		itemInfo[@"itemId"] = [tempItemData valueForKey:@"ItemCode"];
		itemInfo[@"CheckCashCharge"] = [tempItemData valueForKey:@"CheckCashAmount"];
		itemInfo[@"ExtraCharge"] = [tempItemData valueForKey:@"ExtraCharge"];
        NSInteger iextChare=[[tempItemData valueForKey:@"ExtraCharge"] intValue];
        if(iextChare==0)
        {
            itemInfo[@"isExtraCharge"] = @"0";//--
            
        }
        else
        {
            itemInfo[@"isExtraCharge"] = @"1";
        }
        
        itemInfo[@"isAgeApply"] = [tempItemData valueForKey:@"isAgeApply"];
        
        NSInteger iTaxAmount=[[tempItemData valueForKey:@"ItemTaxAmount"] intValue];
        if(iTaxAmount==0)
        {
            itemInfo[@"isTax"] = @"0";
        }
        else
        {
            itemInfo[@"isTax"] = @"1";
        }
        itemInfo[@"isCheckCash"] = [tempItemData valueForKey:@"isCheckCash"];
        itemInfo[@"isDeduct"] = [tempItemData valueForKey:@"isDeduct"];
		
        if(itemInfo != nil) {
			tempDict[@"item"] = itemInfo;
		}
        
        NSMutableArray *itemTaxArray= [tempItemData valueForKey:@"ItemTaxDetail"];
        
        if ([itemTaxArray isKindOfClass:[NSArray class]]) {
            for (int j=0; j<itemTaxArray.count; j++) {
                
                NSMutableDictionary *tmpItemTax=itemTaxArray[j];
                [tmpItemTax removeObjectForKey:@"ItemCode"];
                [tmpItemTax removeObjectForKey:@"RowPosition"];
            }
        }
        tempDict[@"ItemTaxDetail"] = itemTaxArray;
        
        NSString *strItemId=[NSString stringWithFormat:@"%ld",(long)[[tempItemData valueForKey:@"ItemCode"] integerValue]];
        Item *anitem=[self fetchAllItems:strItemId];
        if(anitem.itemGroupMaster.groupId)
        {
            tempDict[@"categoryId"] = anitem.itemGroupMaster.groupId;
            
        }
        else
        {
            tempDict[@"categoryId"] = @"0";
            
        }
        
        if(anitem.itemMixMatchDisc.mixMatchId)
        {
            tempDict[@"mixMatchId"] = anitem.itemMixMatchDisc.mixMatchId;
        }
        else
        {
            tempDict[@"mixMatchId"] = @"0";
        }
        
        tempDict[@"IsQtyEdited"] = @"1";
        tempDict[@"ItemDiscountPercentage"] = @(0);
        tempDict[@"ItemExternalDiscount"] = @(0);
        tempDict[@"ItemInternalDiscount"] = @(0);
        
        
        if (tempItemData[@"InvoiceVariationdetail"]) {
            if ([tempItemData[@"InvoiceVariationdetail"] isKindOfClass:[NSArray class]]) {
                [tempDict setValue:[tempItemData valueForKey:@"InvoiceVariationdetail"] forKey:@"InvoiceVariationdetail"];
            }
        }
        
        if (tempItemData[@"VariationAmount"]) {
            [tempDict setValue:[NSString stringWithFormat:@"%.2f",[[tempItemData valueForKey:@"VariationAmount"]floatValue]] forKey:@"TotalVarionCost"];
        }
        if (tempItemData[@"RetailAmount"]) {
            [tempDict setValue:[NSString stringWithFormat:@"%.2f",[[tempItemData valueForKey:@"RetailAmount"]floatValue]] forKey:@"RetailAmount"];
        }
        
        if (tempItemData[@"ItemMemo"]) {
            [tempDict setValue:[NSString stringWithFormat:@"%@",[tempItemData valueForKey:@"ItemMemo"]] forKey:@"Memo"];
        }
        else
        {
                [tempDict setValue:@"" forKey:@"Memo"];
        }
        [self setRecallDataAccordingToPriceAtPOS:tempDict tempItemData:tempItemData];
        NSMutableArray *receiptArray = [[NSMutableArray alloc]init];
        [receiptArray addObject:tempDict];
        [self insertInvoiceListInToLocalDataBaseWithInvoiceDetail:receiptArray];
   //     self.currentItemIndexPath = [NSIndexPath indexPathForRow:[self.reciptDataAry count]-1 inSection:0];
        
	}
//    billAmountCalculator.billWiseDiscountType = BillWiseDiscountTypePercentage;
//    billAmountCalculator.billWiseDiscount = @(5.00);
    [self updateBillUI];
    
}

- (void)setRecallDataAccordingToPriceAtPOS:(NSMutableDictionary *)tempDict tempItemData:(NSMutableDictionary *)tempItemData {
    if ([tempItemData[@"ItemBasicAmount"] floatValue] > [[tempItemData valueForKey:@"ItemAmount"] floatValue])
    {
        tempDict[@"PriceAtPos"] = [NSString stringWithFormat:@"%f",[[tempItemData valueForKey:@"ItemAmount"] floatValue]];
        tempDict[@"IsQtyEdited"] = @"0";
        
        float ItemDisCount=[tempDict[@"ItemBasicPrice"] floatValue]-[[tempItemData valueForKey:@"ItemAmount"] floatValue];
        tempDict[@"ItemDiscount"] = [NSString stringWithFormat:@"%f",ItemDisCount];
        float  totalItemPercenatge = ItemDisCount / [tempDict[@"ItemBasicPrice"] floatValue] *100;
        tempDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
    }
    else if ([tempItemData[@"ItemBasicAmount"] floatValue] < [[tempItemData valueForKey:@"ItemAmount"] floatValue])
    {
        tempDict[@"PriceAtPos"] = [NSString stringWithFormat:@"%f",[[tempItemData valueForKey:@"ItemAmount"] floatValue]];
        tempDict[@"IsQtyEdited"] = @"0";
        
    }
    else if ([tempItemData[@"ItemBasicAmount"] floatValue] == [[tempItemData valueForKey:@"ItemAmount"] floatValue])
    {
        [tempDict removeObjectForKey:@"PriceAtPos"];
    }
}

#pragma mark-
#pragma mark- Set Edit QTY Status
-(void)setEditQtyStatusInBillEntry:(NSMutableDictionary*)billDict
{
    /*NSPredicate *itemCodePredicate = [NSPredicate predicateWithFormat:@"itemId = %@", billDict[@"itemId"]];
    NSArray *filteredArray = [reciptArray filteredArrayUsingPredicate:itemCodePredicate];
    
    for (NSMutableDictionary *billEntry in filteredArray) {
        if (billEntry[@"PriceAtPos"]) {
            [billEntry setObject:@"1" forKey:@"IsQtyEdited"];
        }
    }*/
    
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
    NSPredicate *resturantPrintPredicate = [NSPredicate predicateWithFormat:@"isCanceled = %@ ",@(FALSE)];
    NSArray *filterRestaurantBillArray = [restaurantOrder.restaurantOrderItem.allObjects filteredArrayUsingPredicate:resturantPrintPredicate];
    NSInteger itemId = [billDict[@"itemId"] integerValue];
    
    for (RestaurantItem *restaurantItem in filterRestaurantBillArray) {
        NSMutableDictionary *billDictionaryAtIndexPath  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
        if ([billDictionaryAtIndexPath[@"itemId"] integerValue] == itemId && [[billDict valueForKey:@"itemIndex"] isEqualToNumber:restaurantItem.itemIndex]) {
            [billDictionaryAtIndexPath setObject:@"1" forKey:@"IsQtyEdited"];
            restaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:billDictionaryAtIndexPath];
            [UpdateManager saveContext:privateManageobjectContext];
        }
    }
}
-(NSString *)moduleIdentifier
{
    return self.moduleIdentifierString;
}

#pragma mark-
#pragma mark- Launch ViewControllers
- (void)_launchPriceAtPos_Retail:(Item *)item
{
    if ([item.pricescale isEqualToString:@"WSCALE"])
    {
        [self showWieghtScalePriceAtPosVcWithDetail:item];
    }
    else
    {
        [Appsee addEvent:kPosLaunchPriceAtPos];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
        priceAtPosVC = [storyBoard instantiateViewControllerWithIdentifier:@"PriceAtPosVC"];
        priceAtPosVC.priceAtPosDelegate= self;
        priceAtPosVC.priceAtPosDictionary = [self setPriceAtPosDictionary:item];
        [self presentViewAsModal:priceAtPosVC];
    }
}



-(NSMutableDictionary*)setPriceAtPosDictionary :(Item *)item
{
    NSMutableDictionary *priceAtPosDictionary = [[NSMutableDictionary alloc]init];
    priceAtPosDictionary[@"ItemName"] = item.item_Desc;
    if (item.barcode) {
        priceAtPosDictionary[@"Barcode"] = item.barcode;
    }
    else
    {
        priceAtPosDictionary[@"Barcode"] = @"";
        
    }
    
    if (item.itemDepartment) {
        priceAtPosDictionary[@"Department"] = item.itemDepartment.deptName;
    }
    else
    {
        priceAtPosDictionary[@"Department"] = @"";
      }
    
   /* if([item.deptId integerValue] > 0)
    {
        NSInteger deptCheck=[item.itemDepartment.deptId integerValue];
        if (deptCheck==0)
        {
            [priceAtPosDictionary setObject:@"" forKey:@"Department"];
        }
        else
        {
            [priceAtPosDictionary setObject:item.itemDepartment.deptName forKey:@"Department"];
        }
    }
    else
    {
        [priceAtPosDictionary setObject:@"" forKey:@"Department"];
    }*/
    return priceAtPosDictionary;
}
-(void)launchAgeVerification
{
    [Appsee addEvent:kPosLaunchAgeVerification];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    ageVerificationVC = [storyBoard instantiateViewControllerWithIdentifier:@"AgeVerificationVC"];
    ageVerificationVC.ageVerificationDelegate= self;
    ageVerificationVC.age = self.age;
    [self presentViewAsModal:ageVerificationVC];
}

#pragma mark- Department Numpad Delegate Methods

-(IBAction)enterDepartmentClick:(id)sender
{
    [self removeView];
    
    if (_departmentAmountTextField.text.length == 0)
    {
        itemRingUpQty = @"";
        [self processNextStepForItem];
        return;
    }
    self.priceAtPOSAmount = _departmentAmountTextField.text;
    Item *anItem=[self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemCodeId]];
    
    if (anItem.memo.boolValue == TRUE) {
        [self launchMemoVC];
    }
    else
    {
        [self setItemDetail:anItem];
    }
//    [self setItemDetail:anItem];
}

-(IBAction)cancelDepartmentclick:(id)sender
{
    _departmentAmountTextField.text = @"";
    itemRingUpQty = @"";
    [self removeView];
    [self processNextStepForItem];
}

#pragma mark- AgeRestriction Delegate Methods

-(void)didVerifiedAge
{
    [Appsee addEvent:kPosVerifiedAge];
    lowerAge = self.age.intValue;
    [self.rmsDbController playButtonSound];
    [self removePresentModalView];
    Item *anItem=[self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemCodeId]];
    [_itemInfoDataObject setItemMainDataFrom:[anItem.itemRMSDictionary mutableCopy]];

    [self launchPriceAtLatestPosForItem:anItem];
}

-(void)didDeclineAge
{
    [Appsee addEvent:kPosDeclineAge];
  //  upperAge = [self.age intValue];
    [self.rmsDbController playButtonSound];
    [self removePresentModalView];

    RcrPosVC * __weak myWeakReference = self;
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference processNextStepForItem];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"You have Age Restrited" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    
    
}

- (void)resetAgeRestriction
{
    // Do any additional setup after loading the view.
    lowerAge = 0;
    upperAge = 200;
}

- (BOOL)isUnderAge:(NSInteger)age {
    return (age >= upperAge);
}

//- (BOOL)isAgeVerified:(NSInteger)age {
//    return ((age >= lowerAge) && (age <= upperAge));
//}
//
- (BOOL)isAgeVerificationRequired:(NSInteger)age {
    return ((age < upperAge) && (age > lowerAge));
}

- (BOOL)ageVarificationRequiredForItem:(Item *)anItem
{
    BOOL ageVreificationRequired = anItem.itemDepartment.isAgeApply.integerValue;
    return ageVreificationRequired;
}

- (NSString *)ageLimitForItem:(Item *)anItem
{
    NSString *ageValue = anItem.itemDepartment.applyAgeDesc;
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"+"];
    NSString *ageLimit = [ageValue stringByTrimmingCharactersInSet:chs];
    return ageLimit;
}

- (void)verifyAgeForItem:(Item *)anItem
{
    BOOL ageVreificationRequired = [self ageVarificationRequiredForItem:anItem];
    if(ageVreificationRequired)
    {
        NSString *ageLimit = [self ageLimitForItem:anItem];
        self.age = ageLimit;
        int ageToVerify = self.age.intValue;
        
        if ([self isAgeVerificationRequired:ageToVerify]) {
            [self launchAgeVerification];
            return;
        } else if ([self isUnderAge:ageToVerify]) {
            // Under age
            // Launch pop up
            [self launchAgeVerification];
//
//            RcrPosVC * __weak myWeakReference = self;
//            
//            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//            {
//                [myWeakReference processNextStepForItem];
//            };
//            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"You have Age Restrited" buttonTitles:@[@"Ok"] buttonHandlers:@[leftHandler]];
//            
            return;
        } else {
            //
        }
    }
    [self checkPriceAtPOSForItem:anItem];
}

- (void)checkPriceAtPOSForItem:(Item *)anItem {
    [_itemInfoDataObject setItemMainDataFrom:[anItem.itemRMSDictionary mutableCopy]];

    [self launchPriceAtLatestPosForItem:anItem];
}

- (IBAction) pressDepartmentKeyPadButton:(id)sender
{
    [self.rmsDbController playButtonSound];
    NSNumberFormatter   *currencyFormatterMain = [[NSNumberFormatter alloc] init];
    currencyFormatterMain.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatterMain.maximumFractionDigits = 0;
	if ([sender tag] >= 0 && [sender tag] < 10)
    {
        NSString *sym = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
        
        if (_departmentAmountTextField.text==nil )
        {
            _departmentAmountTextField.text=@"";
        }
        if ([_departmentAmountTextField.text isEqualToString:@"$0.00"])
        {
            _departmentAmountTextField.text=@"";
        }
		if (_departmentAmountTextField.text.length > 0) {
            
            
            NSString *displayAmount=nil;
            
            if(is2decimalamt)
            {
                
                NSString *newString= [_departmentAmountTextField.text stringByReplacingCharactersInRange:NSMakeRange(2,1) withString:@""];
                
                //   NSString *newString= [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"0" withString:@""];
                
                displayAmount=newString;
            }
            else
            {
                displayAmount=_departmentAmountTextField.text;
            }
            
            
			NSString * displyValue = [displayAmount stringByAppendingFormat:@"%ld",(long)[sender tag]];
			_departmentAmountTextField.text = displyValue;
            
            is2decimalamt=FALSE;
            
		} else {
            
            
            is2decimalamt=TRUE;
            
            NSString * displyValue = [_departmentAmountTextField.text stringByAppendingFormat:@"%@0%ld",sym,(long)[sender tag]];
            _departmentAmountTextField.text = displyValue;
            
            // NSString * displyValue = [_departmentAmountTextField.text stringByAppendingFormat:@"0%d",[sender tag]];
            // NSNumber *sPrice = [NSNumber numberWithFloat:[displyValue floatValue]];
            // _departmentAmountTextField.text = [currencyFormatterMain stringFromNumber:sPrice];
			
		}
	}
    else if ([sender tag] == -99)
    {
		if (_departmentAmountTextField.text.length > 0) {
            is2decimalamt=FALSE;
			//_departmentAmountTextField.text = [_departmentAmountTextField.text substringToIndex:[_departmentAmountTextField.text length]-1];
			//if ([_departmentAmountTextField.text isEqual:@"$"] || [_departmentAmountTextField.text isEqual:@"$."] || [_departmentAmountTextField.text isEqual:@"$."])
            _departmentAmountTextField.text = @"";
            
        }
        
        [_manualQtyBtn setEnabled:YES];
        [_manualQtyBtn setTitle:@"QTY: 1"  forState:UIControlStateNormal];
        self.crmController.manualQtyValue = @"1";
    }
    else if ([sender tag] == 553)
    {
        if (_departmentAmountTextField.text.length > 0) {
            is2decimalamt=FALSE;
            
            _departmentAmountTextField.text = [_departmentAmountTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            NSNumberFormatter * currencyFormat = [[NSNumberFormatter alloc] init];
            currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
            currencyFormat.maximumFractionDigits = 2;
            
            _departmentAmountTextField.text = [_departmentAmountTextField.text substringToIndex:_departmentAmountTextField.text.length-1];
        
            if(_departmentAmountTextField.text.length > 0)
            {
                
                _departmentAmountTextField.text = [_departmentAmountTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                
                if ([_departmentAmountTextField.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length >= 2)
                {
                    _departmentAmountTextField.text = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                    _departmentAmountTextField.text = [NSString stringWithFormat:@"%@.%@",[_departmentAmountTextField.text substringToIndex:_departmentAmountTextField.text.length-2],[_departmentAmountTextField.text substringFromIndex:_departmentAmountTextField.text.length-2]];
                }
                else if ([_departmentAmountTextField.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1)
                {
                    _departmentAmountTextField.text = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                    _departmentAmountTextField.text = [NSString stringWithFormat:@"%@0.0%@",[_departmentAmountTextField.text substringToIndex:_departmentAmountTextField.text.length-2],[_departmentAmountTextField.text substringFromIndex:_departmentAmountTextField.text.length-2]];
                }
                else if ([_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1)
                {
                    _departmentAmountTextField.text = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                    _departmentAmountTextField.text = [NSString stringWithFormat:@"0.0%@",_departmentAmountTextField.text];
                }
                
                NSNumber *dSales = @(_departmentAmountTextField.text.doubleValue );
                _departmentAmountTextField.text = [currencyFormat stringFromNumber:dSales];
                _departmentAmountTextField.text = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
        }
    }
    else if ([sender tag] == 101)
    {
		if (_departmentAmountTextField.text.length > 0) {
            is2decimalamt=FALSE;
			NSString * displyValue = [_departmentAmountTextField.text stringByAppendingFormat:@"00"];
			_departmentAmountTextField.text = displyValue;
		}
		else {
            
            is2decimalamt=FALSE;
            NSString * displyValue = [_departmentAmountTextField.text stringByAppendingFormat:@"%d",00];
            NSNumber *sPrice = @(displyValue.floatValue);
            _departmentAmountTextField.text = [currencyFormatterMain stringFromNumber:sPrice];
            
            
		}
	}
	
	/*if (isQtyOn) {
     _departmentAmountTextField.text = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
     self.crmController.manualQtyValue = [NSString stringWithFormat:@"%@",_departmentAmountTextField.text];
     } else {*/
    
    if ([sender tag] != 553)
    {
        if ([_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1) {
            _departmentAmountTextField.text = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            if (_departmentAmountTextField.text.length >=4) {
                
                NSString *firstLetter = [_departmentAmountTextField.text substringWithRange:NSMakeRange(1, 1)];
                NSString *secondlatter = [_departmentAmountTextField.text substringWithRange:NSMakeRange(3, 1)];;
                if([firstLetter isEqualToString:@"0"] && secondlatter.integerValue>0){
                    _departmentAmountTextField.text = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"0" withString:@""];
                }
            }
            
            _departmentAmountTextField.text = [NSString stringWithFormat:@"%@.%@",[_departmentAmountTextField.text substringToIndex:_departmentAmountTextField.text.length-2],[_departmentAmountTextField.text substringFromIndex:_departmentAmountTextField.text.length-2]];
            
        }
        else if ([_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1) {
            _departmentAmountTextField.text = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _departmentAmountTextField.text = [NSString stringWithFormat:@"%@.%@",[_departmentAmountTextField.text substringToIndex:_departmentAmountTextField.text.length-1],[_departmentAmountTextField.text substringFromIndex:_departmentAmountTextField.text.length-1]];
        }
    }
    
    
    if (_departmentAmountTextField.text.length>0)
    {
        [_enterDepartment setTitle:@"ENTER" forState:UIControlStateNormal];
    }
    else
    {
        [_enterDepartment setTitle:@"CANCEL" forState:UIControlStateNormal];
        
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // [self setKeypad:uvnumpad];
    });
    
    
    NSString *sAmount=[_departmentAmountTextField.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    
	NSString *tempPrice = [NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sAmount].floatValue];
    
    NSString *strTemp = [NSString stringWithFormat:@"%f",tempPrice.floatValue*100];
    
    tempPrice = [NSString stringWithFormat:@"%ld",(long)strTemp.integerValue];
    
    if (tempPrice.integerValue > 99)
    {
        [_manualQtyBtn setEnabled:NO];
    }
    else
    {
        [_manualQtyBtn setEnabled:YES];
    }
}
- (IBAction) addQtyValueInItem:(id)sender
{
    
    NSString *sAmount = [_departmentAmountTextField.text stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    
	NSString *tempPrice = [NSString stringWithFormat:@"%.2f",[self.crmController.currencyFormatter numberFromString:sAmount].floatValue];
    
    NSString *strTemp = [NSString stringWithFormat:@"%.2f",tempPrice.floatValue*100];
    
    tempPrice = [NSString stringWithFormat:@"%ld",(long)strTemp.integerValue];
    
    if (tempPrice.integerValue > 99)
    {
        self.crmController.manualQtyValue = @"1";
        itemRingUpQty = @"1";
		[_manualQtyBtn setTitle:[NSString stringWithFormat:@"QTY: %d",self.crmController.manualQtyValue.intValue] forState:UIControlStateNormal];
		_departmentAmountTextField.text = @"";
	}
    else if ([_departmentAmountTextField.text isEqualToString:@""])
    {
        self.crmController.manualQtyValue = @"1";
        itemRingUpQty = @"1";
		[_manualQtyBtn setTitle:[NSString stringWithFormat:@"QTY: %d",self.crmController.manualQtyValue.intValue] forState:UIControlStateNormal];
		_departmentAmountTextField.text = @"";
    }
    else
    {
        self.crmController.manualQtyValue = tempPrice;
        itemRingUpQty = tempPrice;
		[_manualQtyBtn setTitle:[NSString stringWithFormat:@"QTY: %d",self.crmController.manualQtyValue.intValue] forState:UIControlStateNormal];
		_departmentAmountTextField.text = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //    if ([[self.rmsDbController.globalScanDevice objectForKey:@"Type"]isEqualToString:@"Bluetooth"])
    //    {
    if(textField== _barcodeScanTextField)
    {
        if(_barcodeScanTextField.text.length>0)
        {
            BOOL isNumeric;
            NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:_barcodeScanTextField.text];
            isNumeric = [alphaNums isSupersetOfSet:inStringSet];
            if (isNumeric) // numeric
            {
                _barcodeScanTextField.text = [self.rmsDbController trimmedBarcode:_barcodeScanTextField.text];
            }
            stringBarcodeText = _barcodeScanTextField.text;

            [self addItemBarcodeToRingUpQueue:stringBarcodeText];
            _barcodeScanTextField.text = @"";
            return NO;
        }
    }
    //    }
    return YES;
}

-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}

#pragma mark - Camera Scan Delegate Methods

-(void)barcodeScanned:(NSString *)strBarcode
{
    _barcodeScanTextField.text = strBarcode;
    [self textFieldShouldReturn:_barcodeScanTextField];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if((textField == _barcodeScanTextField) && (_keyBoardButton.tag == 1))
    {
        _barcodeScanTextField.inputView = nil;
        [_barcodeScanTextField becomeFirstResponder];
    }
    else
    {
        _barcodeScanTextField.inputView = dummyView;
    }
    
}
- (IBAction)btn_itemKeyboard:(id)sender
{
    if([sender tag]==0)
    {
        [_keyBoardTextField becomeFirstResponder];
        _keyBoardButton.selected = YES;
        [sender setTag:1];
    }
    else
    {
        [sender setTag:0];
        [_keyBoardTextField resignFirstResponder];
        [_barcodeScanTextField resignFirstResponder];
        _keyBoardButton.selected = NO;
    }
    [_barcodeScanTextField becomeFirstResponder];
    
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([objConfiguration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

- (NSArray *)fetchItemWithItemBarcode :(NSString *)itemData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    //   ANY itemBarcodes.barCode == %@ OR barcode == %@
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode like[cd] %@ AND((packageType == %@ OR barcodePrice_MD.isPackCaseAllow == %@))",itemData,@"Single Item",@1];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barcode == %@ OR ANY itemBarcodes.barCode == %@",itemData,itemData];
    //////// Change It ///////
    NSPredicate *predicate;
    if ([self isSubDepartmentEnableInBackOffice]) {
        predicate = [NSPredicate predicateWithFormat:@"ANY itemBarcodes.barCode == %@ ",itemData];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"ANY itemBarcodes.barCode == %@ AND itm_Type != %@",itemData,@(2)];
    }

    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    /*   if (resultSet.count>0)
     {
     item=[resultSet firstObject];
     }*/
    return resultSet;
}

- (NSArray *)fetchPrice_MD_WithItemBarcode :(NSString *)itemData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item_Price_MD" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    //   ANY itemBarcodes.barCode == %@ OR barcode == %@
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode like[cd] %@ AND((packageType == %@ OR barcodePrice_MD.isPackCaseAllow == %@))",itemData,@"Single Item",@1];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY priceBarcodes.barCode like[cd] %@",itemData];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    /*   if (resultSet.count>0)
     {
     item=[resultSet firstObject];
     }*/
    return resultSet;
}


// do not delete the below two methods.
#pragma mark - sendRestaurantOrder
-(IBAction)sendOrder:(id)sender
{
    
}
#pragma mark - switchRestaurantOrder

-(IBAction)switchTable:(id)sender
{
    
}

-(void)openGiftCardView:(CGPoint)point{
    if (giftcardPopOverController)
    {
        [giftcardPopup dismissViewControllerAnimated:YES completion:nil];
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    giftcardPopupVC = [storyBoard instantiateViewControllerWithIdentifier:@"GiftCardPopUpVC"];
    giftcardPopupVC.isRefund = billAmountCalculator.itemRefund;
    giftcardPopup = giftcardPopupVC;
    giftcardPopupVC.giftCardPopUpDelegate=self;
    
    // Present the view controller using the popover style.
    giftcardPopup.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:giftcardPopup animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    giftcardPopOverController = [giftcardPopup popoverPresentationController];
    giftcardPopOverController.delegate = self;
    giftcardPopup.preferredContentSize = CGSizeMake(215, 195);
    giftcardPopOverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    giftcardPopOverController.sourceView = self.view;
    giftcardPopOverController.sourceRect = CGRectMake(point.x,
                                                      point.y - 10.0,
                                                      30,
                                                      5);
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if ([popoverPresentationController isEqual:giftcardPopOverController]) {
        [self.posMenuVC clearSelection];
        if (giftcardPopOverController.presentedViewController == _eBTViewController) {
            isOpenEbt = FALSE;
            NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
            if (reciptArray>0)
            {
                [self removeEbtDiplayFlagInForArray:reciptArray];
                [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:reciptArray];
                [rcrBillSummary updateBillSummrayWithDetail:reciptArray];
                [self updateBillSummaryWithReceiptArray:reciptArray];
            }
        }

    }
}

-(void)opengiftCardView:(BOOL)isload withRefund:(BOOL)isRefund{

    [giftcardPopup dismissViewControllerAnimated:YES completion:nil];
    if(isload){
        
        [self loadGiftCardView:isload withRefund:isRefund];
    }
    else{
        
        [self checkGiftCardView:isload withRefund:isRefund];
    }

    
}
-(NSString *)giftCardIdentifier:(BOOL)isLoad
{
    NSString *identifier = @"";
    
    if (isLoad) {
        
        identifier = @"GiftCardPosLoadBalanceVC";
    }
    else
    {
        identifier = @"GiftCardCheckBalanceVC";
    }
    return identifier;
}


-(void)opneLoadGiftCard:(NSString *)strGiftCardNo{
    
    //[self loadGiftCardView:YES withRefund:NO];
    [self loadGiftCardViewWithgiftCardNO:YES withRefund:NO giftCardNp:strGiftCardNo];
}
-(void)didCancelCheckBalanceGiftCard{
    
    [self didCancelGiftCard];

}

-(void)checkGiftCardView:(BOOL)isLoad withRefund:(BOOL)isRefund{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    giftcardCheckBalanceVC = [storyBoard instantiateViewControllerWithIdentifier:[self giftCardIdentifier:isLoad]];
    giftcardCheckBalanceVC.dictCustomerInfo = self.selectedCustomerDetail;
    giftcardCheckBalanceVC.giftCardCheckBalancePosDelegate = self;
    giftcardCheckBalanceVC.custName = _lblCustomerName.text;
    giftcardCheckBalanceVC.isLoad = isLoad;
    giftcardCheckBalanceVC.isRefund = isRefund;
    giftcardCheckBalanceVC.isFromTender = NO;
    [self presentViewAsModal:giftcardCheckBalanceVC];
}

-(void)loadGiftCardView:(BOOL)isLoad withRefund:(BOOL)isRefund{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    giftcardVC = [storyBoard instantiateViewControllerWithIdentifier:[self giftCardIdentifier:isLoad]];
    giftcardVC.dictCustomerInfo = self.selectedCustomerDetail;
    giftcardVC.giftCardPosDelegate = self;
    giftcardVC.custName = _lblCustomerName.text;
    giftcardVC.isLoad = isLoad;
    giftcardVC.isRefund = isRefund;
    giftcardVC.isFromTender = NO;
    [self presentViewAsModal:giftcardVC];
}

-(void)loadGiftCardViewWithgiftCardNO:(BOOL)isLoad withRefund:(BOOL)isRefund giftCardNp:(NSString *)strGiftCardNo{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    giftcardVC = [storyBoard instantiateViewControllerWithIdentifier:[self giftCardIdentifier:isLoad]];
    giftcardVC.dictCustomerInfo = self.selectedCustomerDetail;
    giftcardVC.giftCardPosDelegate = self;
    giftcardVC.custName = _lblCustomerName.text;
    giftcardVC.isLoad = isLoad;
    giftcardVC.isRefund = isRefund;
    giftcardVC.isFromTender = NO;
    [self presentViewAsModal:giftcardVC];
    giftcardVC.txtGiftCardNo.text = strGiftCardNo;
}


#pragma GiftCard Delegate Method

-(void)successfullDoneWithCardDetail:(NSMutableDictionary *)cardDetail{
    
    [self removePresentModalView];
    Item *giftCarditem = [self fetchAllItemForGiftCard:@"RapidRMS Gift Card"];
    if(giftCarditem){
        
        float intAmount = [[cardDetail valueForKey:@"LoadAmount"] floatValue];
        giftCarditem.salesPrice =  @(intAmount);
        self.priceAtPOSAmount = [NSString stringWithFormat:@"$%.2f", intAmount];
        self.dictGiftCard = cardDetail;
        billAmountCalculator.packageQty = @(1);
        billAmountCalculator.packageType = @"Single Item";
        [self setItemDetail:giftCarditem];

    }
    else{
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Gift Card item not available" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        
    }
    
}

-(void)successfullDone:(NSString *)strAmount{
    
    [self removePresentModalView];
    Item *giftCarditem = [self fetchAllItemForGiftCard:@"RapidRMS Gift Card"];
    int intAmount = strAmount.intValue;
    giftCarditem.salesPrice =  @(intAmount);
    self.priceAtPOSAmount = [NSString stringWithFormat:@"$%@", strAmount];
    [self setItemDetail:giftCarditem];

}

-(NSMutableDictionary *)createGiftCardDictionary:(NSString *)strAmount{
    
    NSMutableDictionary *dictgiftCard = [[NSMutableDictionary alloc]init];
    dictgiftCard[@"Barcode"] = @"";
    dictgiftCard[@"IsPriceEdited"] = @"";
    dictgiftCard[@"IsQtyEdited"] = @"";
    dictgiftCard[@"ItemBasicPrice"] = strAmount;
    dictgiftCard[@"ItemDiscount"] = @"";
    dictgiftCard[@"ItemDiscountPercentage"] = @"";
    dictgiftCard[@"ItemExternalDiscount"] = @"";
    dictgiftCard[@"Memo"] = @"";
    dictgiftCard[@"SubDeptId"] = @"";
    dictgiftCard[@"UnitQty"] = @"";
    dictgiftCard[@"UnitType"] = @"";
    dictgiftCard[@"categoryId"] = @"";
    dictgiftCard[@"departId"] = @"";
    dictgiftCard[@"isBasicDiscounted"] = @"";
    dictgiftCard[@"itemId"] = @"";
    
    dictgiftCard[@"itemImage"] = @"";
    dictgiftCard[@"itemId"] = @"";
    dictgiftCard[@"itemName"] = @"Gift Card";
    dictgiftCard[@"itemPrice"] = strAmount;
    dictgiftCard[@"itemQty"] = @"1";
    dictgiftCard[@"itemTax"] = @"0";
    dictgiftCard[@"itemType"] = @"1";
    dictgiftCard[@"mixMatchId"] = @"1";
    dictgiftCard[@"isGiftCard"] = @"1";
    
    return dictgiftCard;
}

-(void)didCancelGiftCard{
    
    [self removePresentModalView];
}
#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didSelectMenu:(PosMenuVC *)posMenu menuId:(NSInteger)posMenuId {
    
    CGPoint point = CGPointZero;
    
    for (int i = 0; i<posMenu.posMenuVCarray.count; i++){
    
        NSIndexPath *indapth = [NSIndexPath indexPathForRow:i inSection:0];
        PosMenuItem *posMenuItemAtIndexPath = (posMenu.posMenuVCarray)[indapth.row];
        if(posMenuId == posMenuItemAtIndexPath.menuId){
            point = [posMenu centerForMenuAtPoint:indapth];
            
        }
    }

    switch (posMenuId)
    {
        case ITEM_POS_MENU:
            [self itemButtonClicked:nil];
            break;
        case HOLD_POS_MENU:
            [self holdButtonClicked:nil];
            break;
        case RECALL_POS_MENU:
            [self recallButtonClicked:nil];
            break;
        case VOID_POS_MENU:
            if (!self.rmsDbController.isInternetRechable)
            {
                return;
            }
            [self voidButtonClicked:nil];
            break;
        case DISCOUNT_POS_MENU:
            [self discountButtonClicked:nil];
            break;
        case CANCEL_POS_MENU:
            [self cancelButtonClicked:nil];
            break;
        case REFUND_POS_MENU:
            [self refundButtonClicked:nil];
            break;
        case INVOICE_POS_MENU:
            [self invoiceButtonClicked];
            break;
        case NO_SALE_POS_MENU:
            [self noSaleButtonClicked:nil];
            break;
        case DROP_POS_MENU:
            if (!self.rmsDbController.isInternetRechable) {
                return;
            }
            [self dropButtonClicked:nil];
            break;
        case SEND_ORDER_POS_MENU:
            [self sendOrder:nil];
            break;
        case SWITCH_TABLE_POS_MENU:
            [self switchTable:nil];
            break;
            
        case GIFT_CARD_POS_MENU:
            if (!self.rmsDbController.isInternetRechable) {
                return;
            }
            [self openGiftCardView:point];
            break;
            
        case REMOVE_TAX_MENU:
            if (!self.rmsDbController.isInternetRechable) {
                return;
            }
            [self removeTaxButtonClicked:nil];
            break;
        case MANAGER_REPORTS_POS_MENU:
            [self buttonManagerReportsTapped:nil];
            break;

        default:
            break;
    }
}


- (void)scrollTableView
{
    if (self.tenderItemTableView.contentSize.height > self.tenderItemTableView.frame.size.height)
    {
        self.tenderItemTableView.contentOffset = CGPointMake(0, self.tenderItemTableView.contentSize.height-self.tenderItemTableView.frame.size.height);
    }
    else
    {
        self.tenderItemTableView.contentOffset = CGPointMake(0, 0);
    }
    
}
-(void)launchMemoVC
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    rcr_MemoVC = [storyBoard instantiateViewControllerWithIdentifier:@"RCR_MemoVC"];
    rcr_MemoVC.rcr_MemoDelegate = self;
    rcr_MemoVC.view.frame = CGRectMake(302, 209, 420, 350);
    [self presentViewAsModal:rcr_MemoVC];
}



#pragma mark-
#pragma mark - PriceAtPOS Delegate  methods
-(void)didAddItemWithPosPrice:(NSString *)priceAtPos
{
//    NSDictionary *priceAtPosDictionary = @{kPosPriceAtPosKey: priceAtPos};
//    [Appsee addEvent:kPosAddPriceAtPos withProperties:priceAtPosDictionary];

    [self removePresentModalView];
    self.priceAtPOSAmount = priceAtPos;
    Item *anItem=[self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemCodeId]];
    if (anItem.memo.boolValue == TRUE) {
        [self launchMemoVC];
    }
    else
    {
        [self setItemDetail:anItem];
    }
}
-(void)didCancelPriceAtPos
{
    [Appsee addEvent:kPosCancelPriceAtPos];
    [self removePresentModalView];
    [self processNextStepForItem];
}
#pragma mark-
#pragma mark - Memo Delegate Methods

-(void)didAddMemo :(NSString *)message
{
    [self removePresentModalView];
    billAmountCalculator.memoMessage = message;
    Item *anItem=[self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemCodeId]];
    [self setItemDetail:anItem];
}
-(void)didCancelMemoVC
{
    [self removePresentModalView];
    [self processNextStepForItem];
}
#pragma mark-
#pragma mark - Tender Transaction Delegate Methods

-(void)didFinishTransactionSuccessFully
{
    [self updateRecallCountWithOfflineHoldInvoice];
    self.selectedCustomerDetail = nil;
    rcrRapidCustomerLoayalty = nil;
    [self refundButtonClicked:nil];
    [self clearBillUI];
}
-(void)didFailTransaction
{
    
}

#pragma mark-
#pragma mark - DropAmountVC Delegate  methods
-(void)dropAmountProcessSuccessfullyDone
{
    [Appsee addEvent:kPosMenuDropAmountProcessDone];
    [self.posMenuVC clearSelection];
    dropAmountVC.view.hidden = YES;
    noSaleType = @"";
}
-(void)dropAmountProcessFailed
{
    [Appsee addEvent:kPosMenuDropAmountProcessFailed];
}
-(void)dismissDropAmountViewController
{
    [self.posMenuVC clearSelection];
    dropAmountVC.view.hidden = YES;
    noSaleType = @"";
}
-(IBAction)dropButtonClicked:(id)sender
{
    [Appsee addEvent:kPosMenuDrop];
    [self.rmsDbController playButtonSound];

    RcrPosVC * __weak myWeakReference = self;

    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference openDropAmountPopUpWithDrawerOpened:NO];
    };
    
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        noSaleType = @"DROP";
        [myWeakReference nosale];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@" Do you want to Open drawer ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)openDropAmountPopUpWithDrawerOpened:(BOOL)isDrawerOpened
{
    dropAmountVC = [[DropAmountVC alloc]initWithNibName:@"DropAmountVC" bundle:nil];
    dropAmountVC.dropAmountDelegate = self;
    dropAmountVC.isDrawerOpened = isDrawerOpened;
    dropAmountVC.strPrintBarcode = strPrintBarcode;
    [self.view addSubview:dropAmountVC.view];
}

#pragma mark -
#pragma mark - Invoice Delegate Methods

-(void)insertInvoiceListInToLocalDataBaseWithInvoiceDetail:(NSMutableArray *)invoiceListArray
{
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantOrder *restaurantOrder;
    if (self.restaurantOrderObjectId == nil)
    {
        NSMutableDictionary *restaurantOrderDetail = [[NSMutableDictionary alloc]init];
        restaurantOrderDetail[@"noOfGuest"] = @"1";
        restaurantOrderDetail[@"tableName"] = @"Retail";
        restaurantOrderDetail[@"orderid"] = @(0);
        restaurantOrderDetail[@"orderState"] = @(OPEN_ORDER);
        restaurantOrderDetail[@"InvoiceNo"] = [self currentRegisterInvoiceNumber];
        restaurantOrder = [self.updateManager insertRestaurantOrderListInLocalDataBase:restaurantOrderDetail withContext:privateManageobjectContext];
        self.restaurantOrderObjectId = restaurantOrder.objectID;
    }
    else
    {
        restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
    }
    
    for (NSMutableDictionary *invoiceList in invoiceListArray)
    {
        NSMutableDictionary *restaurantItemList = [[NSMutableDictionary alloc]init];
        restaurantItemList[@"isCanceled"] = @(0);
        restaurantItemList[@"isNoPrint"] = @(0);
        restaurantItemList[@"isPrinted"] = @(0);
        restaurantItemList[@"itemId"] = [invoiceList valueForKey:@"itemId"];
        restaurantItemList[@"itemIndex"] = @(restaurantOrder.restaurantOrderItem.allObjects.count);
        restaurantItemList[@"noteToChef"] = @"";
        restaurantItemList[@"orderId"] = @(0);
        restaurantItemList[@"orderItemId"] = @(0);
        restaurantItemList[@"previousQuantity"] = @(0);
        restaurantItemList[@"quantity"] = [invoiceList valueForKey:@"itemQty"];
        restaurantItemList[@"itemName"] = [invoiceList valueForKey:@"itemName"];
        restaurantItemList[@"guestId"] = @(guestSelectionVC.selectedGuestId);
        invoiceList[@"guestId"] = @(guestSelectionVC.selectedGuestId);
        invoiceList[@"itemIndex"] = @(restaurantOrder.restaurantOrderItem.allObjects.count);
        restaurantItemList[@"itemDetail"] = invoiceList;
        Item *anitem = [self fetchAllItems:[invoiceList valueForKey:@"itemId"]];
        if(anitem != nil)
        {
            Item *itemTolink = (Item *)[privateManageobjectContext objectWithID:anitem.objectID];
            [self.updateManager insertRestaurantItemInLocalDataBase:restaurantItemList withContext:privateManageobjectContext withItemRestaurantOrder:restaurantOrder withItem:itemTolink];
        }
    }
}

-(void)didVoidTransactonForInvoice:(NSMutableArray *)invoiceListArray andPaymentArray:(NSMutableArray *)payarray{
    
    [Appsee addEvent:kPosMenuInvoiceAddItem];
    [_barcodeScanTextField becomeFirstResponder];
    [self insertInvoiceListInToLocalDataBaseWithInvoiceDetail:invoiceListArray];
    self.payentVoidDataAry = payarray;
    //  self.currentItemIndexPath = [NSIndexPath indexPathForRow:[self.reciptDataAry count]-1 inSection:0];
    [self.posMenuVC clearSelection];
    [self updateBillUI];
//    [tenderItemTableView selectRowAtIndexPath:self.currentItemIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
}


-(void)didAddItemFromInvoiceListWithInvoiceDetail:(NSMutableArray *)invoiceListArray
{
    [Appsee addEvent:kPosMenuInvoiceAddItem];
    [_barcodeScanTextField becomeFirstResponder];
    [self insertInvoiceListInToLocalDataBaseWithInvoiceDetail:invoiceListArray];
  //  self.currentItemIndexPath = [NSIndexPath indexPathForRow:[self.reciptDataAry count]-1 inSection:0];
    [self.posMenuVC clearSelection];
    //[invoiceview.view removeFromSuperview];
     [invoiceNav dismissViewControllerAnimated:YES completion:nil];
    [self updateBillUI];
//    [tenderItemTableView selectRowAtIndexPath:self.currentItemIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}
-(void)didCancelInvoiceList
{
    [Appsee addEvent:kPosMenuInvoiceCancel];
    [_barcodeScanTextField becomeFirstResponder];
    [self.posMenuVC clearSelection];
   // [invoiceview.view removeFromSuperview];
    
    [invoiceNav dismissViewControllerAnimated:YES completion:nil];
    invoiceNav = nil;
    invoiceview = nil;
}

-(void)voidTransactionProcessWithMultiplePayment{
    [self tenderTransactionWithTenderType:@"" withPayId:0];
}

-(void)creditCardVoidTransactionProcess{
    
    [self tenderTransactionWithTenderType:@"Credit" withPayId:0];
}
-(void)invoiceButtonClicked
{
    [Appsee addEvent:kPosMenuInvoice];
    [self removeViewFromMainViewWithTag:INVOICE_VIEW_TAG];
    if(invoiceview){
        [invoiceview removeFromParentViewController];
    }

    invoiceview = [[InvoiceDetail alloc]initWithNibName:@"InvoiceDetail" bundle:nil];
    
    invoiceNav = [[UINavigationController alloc]initWithRootViewController:invoiceview];
    invoiceNav.navigationBar.hidden=YES;
    invoiceview.invoiceDetailDelegate = self;
    invoiceview.view.tag = INVOICE_VIEW_TAG;
    CGRect invoiceviewFrame = self.view.bounds;
    invoiceviewFrame.origin.y = invoiceviewFrame.origin.y+20;
    invoiceview.view.frame = invoiceviewFrame;
    //[self.view addSubview:invoiceview.view];
   // [self addChildViewController:invoiceview];
    
    [self.navigationController presentViewController:invoiceNav animated:YES completion:nil];
}

-(void)removeViewFromMainViewWithTag :(NSInteger)tag
{
    [[self.view viewWithTag:tag] removeFromSuperview];
}

#pragma mark-
#pragma mark - ShiftIn_Out Delegate methods
-(void)shiftIn_OutSuccessfullyDone
{
    [self removePresentModalView];
}

-(void)ShiftIn_OutProcessFailed
{
    
}


-(void)dismissShiftIn_OutController
{
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    for (UIViewController *viewController in viewControllerArray)
    {
        if ([viewController isKindOfClass:[POSLoginView class]])
        {

            [self.navigationController popToViewController:viewController animated:TRUE];
            break;
        }
    }
}




#pragma mark-
#pragma mark ItemRingUp Flow

- (NSMutableDictionary *)createQueDictionaryForRingUP:(NSString * )itemcode withType:(NSString *)type withItemKeyName:(NSString*)keyName
{
    NSMutableDictionary * itemRingUpQueDictionary = [[NSMutableDictionary alloc]init];
    itemRingUpQueDictionary[keyName] = [NSString stringWithFormat:@"%@",itemcode];
    itemRingUpQueDictionary[@"Type"] = [NSString stringWithFormat:@"%@",type];
    return itemRingUpQueDictionary;
}

-(void)addItemToRingUpQueue :(NSString * )itemcode
{
    NSMutableDictionary *itemRingUpQueDictionary;
    itemRingUpQueDictionary = [self createQueDictionaryForRingUP:itemcode withType:@"Item" withItemKeyName:@"itemId"];
    [self.itemRingUpQueue addObject:itemRingUpQueDictionary];
    if (!self.isPreviousItemProcessInProgress)
    {
        [self performRingUpProcess];
    }
}

-(void)addDepartmentToRingUpQueue :(NSString * )itemcode
{
//    NSDictionary *selectedDepartmentRingUpDictionary = @{kPosDepartmentRingUpKey: itemcode};
//    [Appsee addEvent:kPosDepartmentSelectedForRingUp withProperties:selectedDepartmentRingUpDictionary];

    NSMutableDictionary *itemRingUpQueDictionary;
    itemRingUpQueDictionary = [self createQueDictionaryForRingUP:itemcode withType:@"Department" withItemKeyName:@"itemId"];
    [self.itemRingUpQueue addObject:itemRingUpQueDictionary];
    if (!self.isPreviousItemProcessInProgress)
    {
        [self performRingUpProcess];
    }
}

-(void)addSubDepartmentToRingUpQueue :(NSString * )itemcode
{
    NSMutableDictionary *itemRingUpQueDictionary;
    itemRingUpQueDictionary = [self createQueDictionaryForRingUP:itemcode withType:@"SubDepartment" withItemKeyName:@"itemId"];
    [self.itemRingUpQueue addObject:itemRingUpQueDictionary];
    if (!self.isPreviousItemProcessInProgress)
    {
        [self performRingUpProcess];
    }
}

-(void)addItemBarcodeToRingUpQueue :(NSString * )barcode
{
    NSMutableDictionary *itemRingUpQueDictionary;
    itemRingUpQueDictionary = [self createQueDictionaryForRingUP:barcode withType:@"Item" withItemKeyName:@"Barcode"];
    [self.itemRingUpQueue addObject:itemRingUpQueDictionary];
    if (!self.isPreviousItemProcessInProgress)
    {
        [self performRingUpProcess];
    }
}

-(void)performRingUpProcess
{
    if (self.itemRingUpQueue.count > 0)
    {
        NSDictionary *itemRingUpQueDictionary = self.itemRingUpQueue[0];
        if (itemRingUpQueDictionary[@"itemId"])
        {
            if ([[itemRingUpQueDictionary valueForKey:@"Type"] isEqualToString:@"Item"])
            {
                self.itemCodeId = [itemRingUpQueDictionary valueForKey:@"itemId"];
                self.isPreviousItemProcessInProgress = TRUE;
               
                Item *anItem = [self fetchAllItems:[itemRingUpQueDictionary valueForKey:@"itemId"]];
                NSMutableArray *arrayItem = [[NSMutableArray alloc]init];
                
                for (Item_Price_MD  *itemPriceMD in anItem.itemToPriceMd) {
                    if (itemPriceMD.qty.integerValue > 0) {
                        [arrayItem addObject:itemPriceMD];
                        
                    }
                }
                
                
                if (arrayItem.count > 1)
                {
                    
                    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"qty"  ascending:YES];
                    NSSortDescriptor *givenDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priceqtytype"  ascending:YES];
                    NSArray *sortDescriptors = @[nameDescriptor, givenDescriptor];
                    NSMutableArray *ordered = [[arrayItem sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                    
                    [self showPackegeTypePopupWithDetail:ordered withItemName:anItem.item_Desc];
                }
                else{
                    Item_Price_MD *priceMd = (Item_Price_MD*) [arrayItem firstObject];
                    billAmountCalculator.packageType = priceMd.priceqtytype;
                    billAmountCalculator.packageQty = priceMd.qty;
                    [self didItemRingUpFromItemId:[itemRingUpQueDictionary valueForKey:@"itemId"]];

                }
            }
            else if ([[itemRingUpQueDictionary valueForKey:@"Type"] isEqualToString:@"Department"])
            {
                self.isPreviousItemProcessInProgress = TRUE;
                self.itemCodeId = [itemRingUpQueDictionary valueForKey:@"itemId"];
                Item *anItem2 = [self fetchAllItems:[itemRingUpQueDictionary valueForKey:@"itemId"]];
                
                billAmountCalculator.packageType = @"Single Item";
                billAmountCalculator.packageQty = @(1);

                [self didRingUpDepartmentWithItemId:anItem2];
            }
            else if ([[itemRingUpQueDictionary valueForKey:@"Type"] isEqualToString:@"SubDepartment"])
            {
                self.isPreviousItemProcessInProgress = TRUE;
                self.itemCodeId = [itemRingUpQueDictionary valueForKey:@"itemId"];
                Item *anItem2 = [self fetchAllItems:[itemRingUpQueDictionary valueForKey:@"itemId"]];
                billAmountCalculator.packageType = @"Single Item";
                billAmountCalculator.packageQty = @(1);
                [self didRingUpSubDepartmentWithItemId:anItem2];
            }
            else
            {
                
            }
        }
        else if (itemRingUpQueDictionary[@"Barcode"])
        {
            self.itemCodeId = [itemRingUpQueDictionary valueForKey:@"itemId"];
            self.isPreviousItemProcessInProgress = TRUE;
            [self didRingUpItemWithItemBarcode:[itemRingUpQueDictionary valueForKey:@"Barcode"]];
        }
        else
        {
            
        }
    }
}

-(NSMutableArray *)setPackageTypeItemDetail:(NSString *)ringUpItemId
{
    Item *anItem = [self fetchAllItems:ringUpItemId];
    NSMutableArray *arrayItem = [[NSMutableArray alloc]init];
    for (Item_Price_MD  *itemPriceMD in anItem.itemToPriceMd) {
        if (itemPriceMD.qty.integerValue > 0) {
            [arrayItem addObject:itemPriceMD];
        }
    }
    return arrayItem;
}

-(void)processNextStepForItem
{
    if (self.itemRingUpQueue.count > 0) {
        [self.itemRingUpQueue removeObjectAtIndex:0];
        self.isPreviousItemProcessInProgress = FALSE;
        [self performRingUpProcess];
    }
}

-(NSArray *)setItemArrayFromBarcodeArray :(NSArray *)barcodeArray
{
    NSMutableArray *itemArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < barcodeArray.count; i++)
    {
        ItemBarCode_Md *item_Barcode = barcodeArray[i];
        if (item_Barcode != nil  && item_Barcode.barcodeItem != nil)
        {
            [itemArray addObject:item_Barcode.barcodeItem.itemCode.stringValue];
        }
    }
    return [NSSet setWithArray:itemArray].allObjects;
}

- (NSArray *)filterBarcodeArrayForCasePackFlag:(NSArray *)itemArray
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"packageType == %@ OR barcodePrice_MD.isPackCaseAllow == %@",@"Single Item",@1];
    NSArray  *filterItemArray = [itemArray filteredArrayUsingPredicate:predicate];
    if (filterItemArray.count==0)
    {
        filterItemArray = itemArray;
    }
    return filterItemArray;
}


-(NSArray *)numberOfBarcode_MD_ForBarcode :(Item *)item withItemBarcode:(NSString *)barcode WithItemPriceType:(NSString *)priceType
{
    NSArray * array = item.itemBarcodes.allObjects;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode like[cd] %@ AND packageType == %@",barcode,priceType];
    return  [array filteredArrayUsingPredicate:predicate];
}


-(NSArray *)numberOfBarcode_MD_ForSingleItemBarcode :(Item *)item withItemBarcode:(NSString *)barcode WithItemPriceType:(NSString *)priceType
{
    NSArray * array = item.itemBarcodes.allObjects;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode like[cd] %@ AND (packageType == %@ OR packageType == %@)",barcode,@"Single item",@"Single Item"];
    return  [array filteredArrayUsingPredicate:predicate];
}

- (NSArray *)fetchBarcodeFromBarcode_MD :(NSString *)itemData withPriceType:(NSString *)priceType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    //   ANY itemBarcodes.barCode == %@ OR barcode == %@
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode like[cd] %@ AND((packageType == %@ OR barcodePrice_MD.isPackCaseAllow == %@))",itemData,@"Single Item",@1];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY itemBarcodes.barCode like[cd] %@ AND ANY itemBarcodes.packageType == %@",itemData,priceType];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    /*   if (resultSet.count>0)
     {
     item=[resultSet firstObject];
     }*/
    return resultSet;
}
//- (NSArray *)sortArrayForBarcodeRingUpProcess:(Item *)currentItem
//{
//    NSArray * itemToPriceArray = currentItem.itemToPriceMd.allObjects;
//    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priceqtytype"
//                                                                   ascending:YES ];
//    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
//    NSArray *itemToPriceSortedArray = [itemToPriceArray sortedArrayUsingDescriptors:sortDescriptors];
//    return itemToPriceSortedArray;
//}
//
//- (void)nextProcessForBarcode
//{
//    if (currentBarcodeItemIndex >= itemForBarcodeArray.count ) {
//        return;
//    }
//    BOOL isCasePackAllow = FALSE;
//    
//    Item *currentItem = itemForBarcodeArray[currentBarcodeItemIndex];
//    
//    NSArray *itemToPriceSortedArray = [self sortArrayForBarcodeRingUpProcess:currentItem];
//    
//    for (Item_Price_MD *price_md in itemToPriceSortedArray)
//    {
//        if ([price_md.priceqtytype isEqualToString:@"Case"])
//        {
//            if([currentItem.pricescale isEqualToString:@"WSCALE"] && currentItem.isPriceAtPOS.boolValue == TRUE)
//            {
//                continue;
//            }
//            
//            if (price_md.isPackCaseAllow.boolValue == TRUE || [self numberOfBarcode_MD_ForBarcode:currentItem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0)
//            {
//                if (isCasePackAllow == FALSE)
//                {
//                    isCasePackAllow = price_md.isPackCaseAllow.boolValue;
//                }
//                [priceMdForBarcodes addObject:price_md];
//            }
//        }
//        else  if ([price_md.priceqtytype isEqualToString:@"Single item"] || [price_md.priceqtytype isEqualToString:@"Single Item"])
//        {
//            if([self numberOfBarcode_MD_ForSingleItemBarcode:currentItem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0 || isCasePackAllow == TRUE )
//            {
//                [priceMdForBarcodes addObject:price_md];
//            }
//        }
//        else if ([price_md.priceqtytype isEqualToString:@"Pack"] )
//        {
//            if([currentItem.pricescale isEqualToString:@"WSCALE"] && currentItem.isPriceAtPOS.boolValue == TRUE)
//            {
//                continue;
//            }
//            
//            
//            if (price_md.isPackCaseAllow.boolValue == TRUE ||  [self numberOfBarcode_MD_ForBarcode:currentItem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0)
//            {
//                if (isCasePackAllow == FALSE)
//                {
//                    isCasePackAllow = price_md.isPackCaseAllow.boolValue;
//                }
//                [priceMdForBarcodes addObject:price_md];
//            }
//        }
//    }
//    
//    currentBarcodeItemIndex ++;
//    [self nextProcessForBarcode];
//}
//
//- (void)performNextForItembarcodeProcess:(NSArray *)itemsForBarcode
//{
//    currentBarcodeItemIndex = 0;
//    priceMdForBarcodes = [[NSMutableArray alloc]init];
//    [itemForBarcodeArray removeAllObjects];
//    itemForBarcodeArray = [itemsForBarcode mutableCopy];
//    [self nextProcessForBarcode];
//}

-(void)rigupProcessForItemBarcode:(NSString *)barcode
{
    NSArray *itemsForBarcode = [self fetchItemWithItemBarcode:barcode];
    if (itemsForBarcode.count == 0)
    {
        stringBarcodeText = barcode;
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:barcode forKey:@"Code"];
        [itemparam setValue:@"Barcode" forKey:@"Type"];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self itemSearchListResultResponse:response error:error withBarcode:barcode];
            });
        };
        
        self.itemDetailWC = [self.itemDetailWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
    }
    else
    {
      //  barcodeScanTextField.text = @"";
        itemBarcode = barcode;
        
        RapidMultipleBarcodeRingUpHelper *rapidMultipleBarcodeRingUpHelper = [[RapidMultipleBarcodeRingUpHelper alloc]init];
        
        priceMdForBarcodes = [rapidMultipleBarcodeRingUpHelper rigupProcessForItemBarcode:itemsForBarcode withItemBarcode:itemBarcode];
        
        NSPredicate *itemInActivePredicate = [NSPredicate predicateWithFormat:@"priceToItem.active == %@",@(1)];
        
        priceMdForBarcodes = (NSMutableArray *)[priceMdForBarcodes filteredArrayUsingPredicate:itemInActivePredicate];
        
        if (priceMdForBarcodes.count == 0) {
            RcrPosVC * __weak myWeakReference = self;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                [myWeakReference processNextStepForItem];
                itemBarcode = @"";
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@" No Item with UPC #%@ found.",stringBarcodeText] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
        
        if (priceMdForBarcodes.count > 1)
        {
            [self showMultipleItemForBarcodeWithDetail:priceMdForBarcodes withItemBarcode:barcode];
        }
        
        if (priceMdForBarcodes.count == 1)
        {
            Item_Price_MD *md = priceMdForBarcodes.firstObject;
            billAmountCalculator.packageType = md.priceqtytype;
            billAmountCalculator.packageQty = md.qty;
            itemRingUpQty = md.qty.stringValue;
            Item *anItem = md.priceToItem;
            [self didItemRingUpFromItemId:anItem.itemCode.stringValue];
        }
    }
}

- (void)itemSearchListResultResponse:(id)response error:(NSError *)error withBarcode:(NSString *)strbarcode
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                [Appsee addEvent:@"ItemSearchListResultResponse" withProperties:@{@"ItemSearchListResultResponse" : @"No Item with UPC found."}];
                NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
                NSMutableArray *itemResponseArray = [responseDictionary valueForKey:@"ItemArray"];
                if (itemResponseArray.count>0)
                {
                    [self.updateManager updateObjectsFromResponseDictionary:responseDictionary];
                    if (itemResponseArray.count>0)
                    {
                        NSDictionary *itemDict = itemResponseArray.firstObject;
                        if ([[[itemDict valueForKey:@"isDeleted"] stringValue] isEqualToString:@"1"])
                        {
                            RcrPosVC * __weak myWeakReference = self;
                            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                            {
                                [myWeakReference processNextStepForItem];
                            };
                            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"No Item with UPC #%@ found.", stringBarcodeText ] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                            _barcodeScanTextField.text = @"";
                            return;
                        }
                        
                        Item *anItem=[self fetchAllItems:[itemResponseArray.firstObject valueForKey:@"ITEMCode"]];
                        
                        [self.updateManager linkWithDepartmentFromItem:anItem moc:self.rmsDbController.managedObjectContext];
                        [self.rmsDbController saveContext];
                        self.itemCodeId = anItem.itemCode.stringValue;
                        itemBarcode = strbarcode;
                        priceMdForBarcodes = [self barcodeArrayFromItemDetail:anItem];
                        
                        NSPredicate *itemInActivePredicate = [NSPredicate predicateWithFormat:@"priceToItem.active == %@",@(1)];
                        
                        priceMdForBarcodes = (NSMutableArray *)[priceMdForBarcodes filteredArrayUsingPredicate:itemInActivePredicate];
                        
                        if (priceMdForBarcodes.count == 0) {
                            RcrPosVC * __weak myWeakReference = self;
                            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                            {
                                [myWeakReference processNextStepForItem];
                                itemBarcode = @"";
                            };
                            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@" No Item with UPC #%@ found.",stringBarcodeText] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                        }
                        
                        if (priceMdForBarcodes.count > 1)
                        {
                            [self showMultipleItemForBarcodeWithDetail:priceMdForBarcodes withItemBarcode:strbarcode];
                        }
                        
                        if (priceMdForBarcodes.count == 1)
                        {
                            Item_Price_MD *md = priceMdForBarcodes.firstObject;
                            billAmountCalculator.packageType = md.priceqtytype;
                            billAmountCalculator.packageQty = md.qty;
                            itemRingUpQty = md.qty.stringValue;
                            Item *anItem = md.priceToItem;
                            [self didItemRingUpFromItemId:anItem.itemCode.stringValue];
                        }
                    }
                }
            }
            else if([[response valueForKey:@"IsError"] intValue] == 1)
            {
                [Appsee addEvent:@"ItemSearchListResultResponse" withProperties:@{@"ItemSearchListResultResponse" : @"No Item with UPC found."}];
                RcrPosVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference processNextStepForItem];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@" No Item with UPC #%@ found.",stringBarcodeText] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else if([[response valueForKey:@"IsError"] intValue] == -1)
            {
                [Appsee addEvent:@"ItemSearchListResultResponse" withProperties:@{@"ItemSearchListResultResponse" : @"Error occured in UPC search Process."}];
                RcrPosVC * __weak myWeakReference = self;
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference processNextStepForItem];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Error occured in UPC search Process." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    else
    {
        [Appsee addEvent:@"ItemSearchListResultResponse" withProperties:@{@"ItemSearchListResultResponse" : @"No Item with UPC found."}];
        RcrPosVC * __weak myWeakReference = self;
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference processNextStepForItem];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@" No Item with UPC #%@ found.",stringBarcodeText] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        _barcodeScanTextField.text=@"";
        return;
    }
    _barcodeScanTextField.text=@"";
    
}


- (NSMutableArray * )barcodeArrayFromItemDetail:(Item*)anitem
{
    NSMutableArray *barcodeArray = [[NSMutableArray alloc]init];
    
    BOOL isCasePackAllow = FALSE;

    NSArray *itemToPriceSortedArray = [self sortArrayForBarcodeRingUpProcess:anitem];
    
    for (Item_Price_MD *price_md in itemToPriceSortedArray)
    {
        if ([price_md.priceqtytype isEqualToString:@"Case"])
        {
            if([anitem.pricescale isEqualToString:@"WSCALE"] && anitem.isPriceAtPOS.boolValue == TRUE)
            {
                continue;
            }
            
            if (price_md.isPackCaseAllow.boolValue == TRUE || [self numberOfBarcode_MD_ForBarcode:anitem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0)
            {
                if (isCasePackAllow == FALSE)
                {
                    isCasePackAllow = price_md.isPackCaseAllow.boolValue;
                }
                [barcodeArray addObject:price_md];
            }
        }
        else  if ([price_md.priceqtytype isEqualToString:@"Single item"] || [price_md.priceqtytype isEqualToString:@"Single Item"])
        {
            if([self numberOfBarcode_MD_ForSingleItemBarcode:anitem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0 || isCasePackAllow == TRUE )
            {
                [barcodeArray addObject:price_md];
            }
        }
        else if ([price_md.priceqtytype isEqualToString:@"Pack"] )
        {
            if([anitem.pricescale isEqualToString:@"WSCALE"] && anitem.isPriceAtPOS.boolValue == TRUE)
            {
                continue;
            }
            
            
            if (price_md.isPackCaseAllow.boolValue == TRUE ||  [self numberOfBarcode_MD_ForBarcode:anitem withItemBarcode:itemBarcode WithItemPriceType:price_md.priceqtytype].count > 0)
            {
                if (isCasePackAllow == FALSE)
                {
                    isCasePackAllow = price_md.isPackCaseAllow.boolValue;
                }
                [barcodeArray addObject:price_md];
            }
        }
    }
    return barcodeArray;
}


- (NSArray *)sortArrayForBarcodeRingUpProcess:(Item *)currentItem
{
    NSArray * itemToPriceArray = currentItem.itemToPriceMd.allObjects;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priceqtytype"
                                                                   ascending:YES ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *itemToPriceSortedArray = [itemToPriceArray sortedArrayUsingDescriptors:sortDescriptors];
    return itemToPriceSortedArray;
}






- (void)didRingUpItemWithItemBarcode :(NSString *)barcode
{
    //    NSArray *priceMD_list = [self fetchPrice_MD_WithItemBarcode:barcode];
    
    [self rigupProcessForItemBarcode:barcode];
    
    return;
}

#pragma mark Single - Case  - Pack Popup 

-(void)showPackegeTypePopupWithDetail :(NSMutableArray *)itemDetail withItemName:(NSString *)itemName
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    itemPackageTypeRingUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"ItemPackageTypeRingUpVC"];
    itemPackageTypeRingUpVC.modalPresentationStyle = UIModalPresentationFullScreen;
    itemPackageTypeRingUpVC.itemPackageTypeRingUpDelegate = self;
    itemPackageTypeRingUpVC.arrayItem = itemDetail;
    itemPackageTypeRingUpVC.strItemName = itemName;
    itemPackageTypeRingUpVC.view.frame =self.view.bounds;
    [self.view addSubview:itemPackageTypeRingUpVC.view];
    itemPackageTypeRingUpVC.view.frame = CGRectMake(255, 75, 515, 690);
    //   multipleItemBarcodeRingUpVC.view.center =self.view.center;
    // [self.view addSubview:multipleItemBarcodeRingUpVC.view];
    [self presentViewAsModal:itemPackageTypeRingUpVC];
}

-(void)didRingUpItemFormPackageTypeDetail :(Item *)item withItemQty:(NSNumber *)qty withPackageType:(NSString * )strPackageType
{
    itemRingUpQty = qty.stringValue;
    billAmountCalculator.packageType = strPackageType;
    billAmountCalculator.packageQty = qty;
    [self removePresentModalView];
    [itemPackageTypeRingUpVC.view removeFromSuperview ];
    [self didItemRingUpFromItemId:item.itemCode.stringValue];
}
-(void)didCancelPackageTypeCustomeVC
{
    [self removePresentModalView];
    [itemPackageTypeRingUpVC.view removeFromSuperview];
    [self processNextStepForItem];
}


#pragma mark-
#pragma mark - MultipleItemBarcodeRingUp



-(void)showMultipleItemForBarcodeWithDetail :(NSArray *)itemArray withItemBarcode:(NSString *)barcode
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    multipleItemBarcodeRingUpVC = [storyBoard instantiateViewControllerWithIdentifier:@"MultipleItemBarcodeRingUpVC"];
    multipleItemBarcodeRingUpVC.modalPresentationStyle = UIModalPresentationFullScreen;
    multipleItemBarcodeRingUpVC.multipleItemBarcodeRingUpDelegate = self;
    multipleItemBarcodeRingUpVC.itemBarcode = barcode;
    multipleItemBarcodeRingUpVC.multipleItemArray = [itemArray mutableCopy];
    multipleItemBarcodeRingUpVC.view.frame =self.view.bounds;
    [self.view addSubview:multipleItemBarcodeRingUpVC.view];
    multipleItemBarcodeRingUpVC.view.frame = CGRectMake(255, 75, 515, 690);
    //   multipleItemBarcodeRingUpVC.view.center =self.view.center;
    // [self.view addSubview:multipleItemBarcodeRingUpVC.view];
    [self presentViewAsModal:multipleItemBarcodeRingUpVC];
}
-(void)didRingUpItemFormMultipleItemForDuplicateBarcode :(Item *)item withItemQty:(NSNumber *)qty withPackageType:(NSString * )strPackageType
{
    itemRingUpQty = qty.stringValue;
    billAmountCalculator.packageType = strPackageType;
    billAmountCalculator.packageQty = qty;
    [self removePresentModalView];
    [multipleItemBarcodeRingUpVC.view removeFromSuperview ];
    [self didItemRingUpFromItemId:item.itemCode.stringValue];
}
-(void)didCanceMultipleItemBarcodeCustomerVC
{
    [self removePresentModalView];
    [multipleItemBarcodeRingUpVC.view removeFromSuperview];
    [self processNextStepForItem];
}




#pragma mark-
#pragma mark - MultipleItemBarcodeRingUp


-(void)showWieghtScalePriceAtPosVcWithDetail :(Item *)item
{
    NSString *itemQty = @"1";
    
    if (itemRingUpQty.length > 0)
    {
        itemQty= itemRingUpQty;
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    wieghtScalePriceAtPosVC = [storyBoard instantiateViewControllerWithIdentifier:@"WieghtScalePriceAtPosVC"];
    wieghtScalePriceAtPosVC.modalPresentationStyle = UIModalPresentationFullScreen;
    wieghtScalePriceAtPosVC.weightScalePriceAtPosDelegate = self;
    wieghtScalePriceAtPosVC.itemforWeightScale = item;
    wieghtScalePriceAtPosVC.qty = itemQty;
    wieghtScalePriceAtPosVC.view.frame = self.view.bounds;
    [self.view addSubview:wieghtScalePriceAtPosVC.view];
}

-(void)showVariationSelectionWithDetail :(Item *)item withBillAmountCalculator:(BillAmountCalculator *)superBillAmountCalculator
{
    billAmountCalculator = superBillAmountCalculator;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    variationSelectionVC = [storyBoard instantiateViewControllerWithIdentifier:@"VariationSelectionVC"];
    variationSelectionVC.modalPresentationStyle = UIModalPresentationFullScreen;
    variationSelectionVC.itemforVariation = item;
    variationSelectionVC.variationSelectionDelegate = self;
    variationSelectionVC.view.frame = self.view.bounds;
    [self.view addSubview:variationSelectionVC.view];
}
-(void)didSelectItemWithVariationDetail :(NSArray *)variationDetail withItem:(Item *)item
{
    billAmountCalculator.variationDetail = [variationDetail mutableCopy];
    [variationSelectionVC.view removeFromSuperview];
    
    if ( self.isDepartment == FALSE)
    {
        if (item.isPriceAtPOS.boolValue)
        {
            [self _launchPriceAtPos_Retail:item];
        }
        else
        {
            [self setItemDetail:item];
        }
    }
    else
    {
        if (item.isPriceAtPOS.boolValue) {
            [_enterDepartment setTitle:@"CANCEL" forState:UIControlStateNormal];
            _departmentAmountTextField.text = @"";
           _departmentNumpadView.hidden = NO;
            _departmentNumpadView.center = _popupContainerView.center;
            [self presentView:_departmentNumpadView];

        }
        else
        {
            [self setItemDetail:item];
        }
    }
}

-(void)didCancelVariationSelectionProcess
{
    [variationSelectionVC.view removeFromSuperview];
    [self processNextStepForItem];
}
-(void)didWeightScalePriceAtPosRingupItemWithItemUnitPrice :(NSString *)price withItemUnitQty:(CGFloat )qty withItemUnitType:(NSString *)itemunitType
{
    self.priceAtPOSAmount = price;
    itemUnitType = itemunitType;
    itemUnitQty = [NSString stringWithFormat:@"%f",qty];
    Item *anItem=[self fetchAllItems:[NSString stringWithFormat:@"%@",self.itemCodeId]];
    [self setItemDetail:anItem];
    [wieghtScalePriceAtPosVC.view removeFromSuperview];
}
-(void)didWeightScalePriceAtPosCancel{
    [wieghtScalePriceAtPosVC.view removeFromSuperview];
    [self processNextStepForItem];
}

#pragma mark-
#pragma mark Add Customer Flow

- (IBAction)btnCustomerClick:(id)sender
{
    self.posMenuContainer.userInteractionEnabled = NO;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    customerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomerViewController"];
    customerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    customerVC.customerSelectionDelegate = self;
//    customerVC.view.frame = self.view.bounds;
//    [self.view addSubview:customerVC.view];
    
    [self.navigationController pushViewController:customerVC animated:YES];
}

-(void)didCancelCustomerSelection
{
    self.posMenuContainer.userInteractionEnabled = YES;    
   // [customerVC.view removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];

}


-(void)didSelectCustomerWithDetail:(RapidCustomerLoyalty *)rapidCustomerLoyalty customerDictionary:(NSDictionary *)customerDictionary withIsCustomerFromHouseCharge:(BOOL)isCustomerFromHouseCharge withIscollectPay:(BOOL)isCollectPay
{
    rcrRapidCustomerLoayalty = rapidCustomerLoyalty;
    self.posMenuContainer.userInteractionEnabled = YES;
    self.selectedCustomerDetail = [customerDictionary mutableCopy];
    _lblCustomerName.text = rapidCustomerLoyalty.customerName;
    [_btnRemoveCustomer setHidden:NO];
    
    if (isCustomerFromHouseCharge)
    {
        isHouseChargeCollectPay = isCollectPay;

        Item *houseCharge = [self fetchAllItemForGiftCard:@"HouseCharge"];
        if(houseCharge)
        {
            NSMutableDictionary *dictHouseCharge = [[NSMutableDictionary alloc]init];
            
            houseCharge.salesPrice =  rapidCustomerLoyalty.balanceAmount;
            self.priceAtPOSAmount = [NSString stringWithFormat:@"$%.2f", rapidCustomerLoyalty.balanceAmount.floatValue];
            dictHouseCharge[@"HouseChargeAmount"] = rapidCustomerLoyalty.balanceAmount;
            dictHouseCharge[@"CardType"] = @"2";
            
            self.dictGiftCard = dictHouseCharge;
            houseChargeValue = rapidCustomerLoyalty.balanceAmount.floatValue;

            [self setItemDetail:houseCharge];
            
        }
        else
        {
            
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"House Charge item not available" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            
        }
    }
}

- (IBAction)RemoveCustomer:(id)sender
{

    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self hideCustomerView];
         self.selectedCustomerDetail = nil;
        rcrRapidCustomerLoayalty = nil;

    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to remove this customer?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];

}
-(void)hideCustomerView{
    _lblCustomerName.text = @"";
    [_btnRemoveCustomer setHidden:YES];
//    self.crmController.custName = @"";
//    self.crmController.custId = @"";

}

#pragma mark-
#pragma mark NO SALE

-(void)nosale
{
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:date];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    [param setValue:(self.rmsDbController.globalDict)[@"ZId"] forKey:@"ZId"];
    param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    param[@"Datetime"] = strDate;
    param[@"NoSaleType"] = noSaleType;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self NoSaleInsertResponse:response error:error];
        });
    };
    
    self.noSaleInsertWC = [self.noSaleInsertWC initWithRequest:KURL actionName:WSM_NO_SALE_INSERT params:param completionHandler:completionHandler];

}

-(void)NoSaleInsertResponse:(id)response error:(NSError *)error
{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] integerValue] == 0)
            {
                strPrintBarcode = [response valueForKey:@"Data"];
                [self KickCashDrawer];
            }
        }
    }
    else
    {
        [self insertNoSaleToOfflineTable];
    }
}

-(void)insertNoSaleToOfflineTable
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"RegisterId"];
    [param setValue:(self.rmsDbController.globalDict)[@"ZId"] forKey:@"ZId"];
    param[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    param[@"NoSaleType"] = noSaleType;
    
    NSInteger noSalecount = [self.updateManager fetchEntityObjectsCounts:@"NoSale" withManageObjectContext:privateContextObject] + 1 ;
    strPrintBarcode = [NSString stringWithFormat:@"NoSale %ld",(long)noSalecount];
    param[@"NoSaleID"] = strPrintBarcode;
    [self.updateManager insertNoSaleToLocalDatabase:param withContext:privateContextObject];
    [self KickCashDrawer];
}


-(void)KickCashDrawer
{
    [self SetPortInfo];
    NSString *portName     = [RcrController getPortName];
    NSString *portSettings = [RcrController getPortSettings];
    isNoSalesPrint = TRUE;
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if ([noSaleType isEqualToString:@"POS"]) {
        if (isBlueToothPrinter) {
            printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:self];
            [printJob enableSlashedZero:YES];
        }
        else
        {
            printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:self];
        }
        
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"PrintRecieptStatus"] isEqualToString:@"Yes"]) {
            [self printNoSalesReceipt];
            [self concludePrint];
        }
    }
    [self openCashDrawerWithPort:portName portSettings:portSettings];
}

- (void)concludePrint
{
    [printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [printJob firePrint];
    printJob = nil;
}

- (void)openCashDrawerWithPort:(NSString *)portName portSettings:(NSString *)portSettings
{
    PrintJob *_printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"CashDrawer" withDelegate:self];
    [_printJob openCashDrawer];
    [_printJob firePrint];

}

- (void)printNoSalesReceipt
{
    [self printStoreName];
    [self printAddressline1];
    [self printAddressline2];
    [self printReceiptName];
    [self printRegisterName];
    [self printCashierName];
    [self printDateAndTime];
    [self printComment];
    [self printSignature];
    [self printBarCode];
}

-(void)printStoreName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob printLine:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
}

-(void)printAddressline1 {
    [printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1 = [NSString stringWithFormat:@"%@  , %@", [[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]];
    [printJob printLine:addressLine1];
}

-(void)printAddressline2 {
    [printJob setTextAlignment:TA_CENTER];
    NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]];
    [printJob printLine:addressLine2];
    [printJob printLine:@""];
}

-(void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:@" No Sales "];
    [printJob enableInvertColor:NO];
}

-(void)printRegisterName {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Register Name: %@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
}

-(void)printCashierName {
    [printJob setTextAlignment:TA_LEFT];
    NSString *salesPersonName = [NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserName"]];
    
    [printJob printLine:[NSString stringWithFormat:@"Cashier Name: %@",salesPersonName]];
}

-(void)printDateAndTime {
    NSDate * date = [NSDate date];
    //Create the dateformatter object
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    //Create the timeformatter object
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    
    //Get the string date
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    [self defaultFormatForDateAndTime];
    [printJob printText1:[NSString stringWithFormat:@"Date: %@",printDate] text2:[NSString stringWithFormat:@"Time: %@",printTime]];
    [printJob printSeparator];
}

-(void)printComment {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:@"Comment: "];
    [printJob printLine:@""];
    [printJob printLine:@""];
    [printJob printLine:@""];
}

-(void)printSignature {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:@"Signature  _____________________________ \r\n"];
    [printJob printLine:@""];
}

-(void)printBarCode {
    [printJob setTextAlignment:TA_CENTER];
    if (strPrintBarcode != nil) {
        [printJob printBarCode:strPrintBarcode];
        [printJob printLine:@""];
    }
}

- (void)defaultFormatForDateAndTime
{
    columnWidths[0] = 24;
    columnWidths[1] = 23;
    columnAlignments[0] = CRAlignmentLeft;
    columnAlignments[1] = CRAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}


#pragma mark-
#pragma mark Customer Display

-(void)didSendDataToCustomerDisplay :(NSMutableArray *)dataArray
{
    NSMutableDictionary *dictAmoutInfo = [[self setSubTotalsToDictionaryForReciptArray:dataArray] mutableCopy];
    NSMutableArray *array=[dataArray mutableCopy];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@"Hide" forKey:@"Tender"];
    [dict setValue:dictAmoutInfo forKey:@"TenderSubTotals"];
    [dict setValue:array forKey:@"BillEntries"];

    [self.crmController writeDictionaryToCustomerDisplay:dict];
}

- (NSMutableDictionary *)setSubTotalsToDictionaryForReciptArray:(NSMutableArray *)dataArray
{
    NSMutableDictionary *dictAmoutInfo = [[NSMutableDictionary alloc]init];
    [dictAmoutInfo setValue:self.billAmountLabel.text forKey:@"InvoiceTotal"];
    [dictAmoutInfo setValue:self.subTotalLabel.text forKey:@"InvoiceSubTotal"];
    [dictAmoutInfo setValue:self.totalTaxLabel.text forKey:@"InvoiceTax"];
    [dictAmoutInfo setValue:self.totalDiscountLabel.text forKey:@"InvoiceDiscount"];
    if (dataArray.count > 0)
    {
        NSString *strCount = [NSString stringWithFormat:@"%ld",(long)[[dataArray valueForKeyPath:@"@sum.itemQty"] integerValue]];
        dictAmoutInfo[@"TotalItemCount"] = strCount;
    }
    else
    {
        dictAmoutInfo[@"TotalItemCount"] = @"0";
    }
    return dictAmoutInfo;
}
-(void)didClearCustomerDiplayUI
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@"ClearAllRecord" forKey:@"Tender"];
    [self.crmController writeDictionaryToCustomerDisplay:dict];
}


-(IBAction)btnLastPreviewClick:(id)sender
{
    NSArray * lastInvoiceArray = [self fetchLastInvoiceArray];
    if (lastInvoiceArray.count > 0)
    {
        LastInvoiceData *lastInvoiceData = lastInvoiceArray.firstObject;
        NSMutableArray * invoiceDetails = [NSKeyedUnarchiver unarchiveObjectWithData:lastInvoiceData.invoiceData];
        
        NSArray *itemDetails = [self itemDetailDictionary:[invoiceDetails.firstObject valueForKey:@"InvoiceItemDetail"]];
        NSArray *paymentArray = [invoiceDetails.firstObject valueForKey:@"InvoicePaymentDetail"];
        NSString *lastInvoiceDate = [self lastInvoiceRecieptDate:[[[invoiceDetails.firstObject valueForKey:@"InvoiceMst"] firstObject] valueForKey:@"Datetime"]];
    
        NSString *portName     = @"";
        NSString *portSettings = @"";
        [self SetPortInfo];
        
        portName     = [RcrController getPortName];
        portSettings = [RcrController getPortSettings];
        
        if([self.rmsDbController checkGasPumpisActive]){
            
//            NSManagedObjectContext *privateMOC = [UpdateManager privateConextFromParentContext:self.rmsDbController.rapidPetroPos.petroMOC];
            
//            NSMutableArray *arrayPumpCart = [[self.updateManager fetcPumpCartWithName:@"PumpCart" key:@"regInvNum" value:[[[invoiceDetails.firstObject valueForKey:@"InvoiceMst"] firstObject] valueForKey:@"RegisterInvNo"] moc:privateMOC] mutableCopy];
            
//            arrayPumpCart = [self createPumpCartArray:arrayPumpCart];
//            
//            if(arrayPumpCart.count > 0 && [self isPrepayTransaction:arrayPumpCart]){
//                
//                lastGasInvoiceRcptPrint = [[LastGasInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetails withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:lastInvoiceDate];
//                lastGasInvoiceRcptPrint.arrPumpCartArray = arrayPumpCart;
//                self.emailReciptHtml = [lastGasInvoiceRcptPrint generateHtmlForInvoiceNo:dictLastInvoiceInfo[@"LastInvoiceNo"] withChangeDue:dictLastInvoiceInfo[@"LastChangeDue"]];
//            }
//            else{
//                
//                lastPostPayGasInvoiceRcptPrint = [[LastPostpayGasInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetails withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:lastInvoiceDate];
//                lastGasInvoiceRcptPrint.arrPumpCartArray = arrayPumpCart;
//                self.emailReciptHtml = [lastPostPayGasInvoiceRcptPrint generateHtmlForInvoiceNo:dictLastInvoiceInfo[@"LastInvoiceNo"] withChangeDue:dictLastInvoiceInfo[@"LastChangeDue"]];
//            }
        }
        else{
            
            lastInvoiceRcptPrint = [[LastInvoiceReceiptPrint alloc] initWithPortName:portName portSetting:portSettings printData:itemDetails withPaymentDatail:paymentArray tipSetting:self.tipSetting tipsPercentArray:nil receiptDate:lastInvoiceDate];
            self.emailReciptHtml = [lastInvoiceRcptPrint generateHtmlForInvoiceNo:dictLastInvoiceInfo[@"LastInvoiceNo"] withChangeDue:dictLastInvoiceInfo[@"LastChangeDue"]];
        }
        
        
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emailReciptHtml]
                                         pathForPDF:@"~/Documents/previewLastInvoice.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    }
    
}
-(BOOL)isPrepayTransaction:(NSMutableArray *)gasArray{
    BOOL prepay = NO;
    if([gasArray[0][@"TransactionType"] isEqualToString:@"PRE-PAY"]){
        prepay = YES;
    }
    return prepay;
    
}

-(NSMutableArray *)createPumpCartArray:(NSArray *)pumpCarts{
    NSMutableArray *arrayDetail = [[NSMutableArray alloc]init];
    for (int i = 0 ; i<pumpCarts.count; i++) {
//        PumpCart *pumpCart = pumpCarts[i];
//        //NSLog(@"%@",pumpCart.getCartDictionary);
//        NSMutableDictionary *dict = [[pumpCart getCartDictionary] mutableCopy];
//        float amountLimit = [dict[@"ApprovedAmount"]floatValue];
//        dict[@"AmountLimit"] = [NSNumber numberWithFloat:amountLimit];
//        dict[@"FuelId"] = [NSNumber numberWithFloat:[dict[@"FuelIndex"] floatValue]];
//        dict[@"PumpId"] = [NSNumber numberWithFloat:[dict[@"PumpIndex"] floatValue]];
//
//        [arrayDetail addObject:dict];
    }

    return arrayDetail;
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    // present the preview
    [self.controller presentPreviewAnimated:YES];
    
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


- (IBAction)btnLastInvRcptClick:(UIButton *)sender
{
    NSArray * lastInvoiceArray = [self fetchLastInvoiceArray];
    
    LastInvoiceData *lastInvoiceData = lastInvoiceArray.firstObject;
    NSMutableArray * invoiceDetails = [NSKeyedUnarchiver unarchiveObjectWithData:lastInvoiceData.invoiceData];
    NSMutableArray *itemDetails = [invoiceDetails.firstObject valueForKey:@"InvoiceItemDetail"];
    NSMutableArray *paymentDetails = [invoiceDetails.firstObject valueForKey:@"InvoicePaymentDetail"];

    
    NSString *itemname = [NSString stringWithFormat:@"%@",[itemDetails.firstObject valueForKey:@"ItemName"]];
    NSString *paymentmode = [NSString stringWithFormat:@"%@",[paymentDetails.firstObject valueForKey:@"CardType"]];
    
    if([itemname isEqualToString:@"HouseCharge"] || [paymentmode isEqualToString:@"HouseCharge"])
    {
            [self creditLimitForHouseCharge];
    }
    else{
        
        if(![dictLastInvoiceInfo[@"LastInvoiceNo"] isEqualToString:@"-"])
        {
            [self.rmsDbController playButtonSound];
            
            RcrPosVC * __weak myWeakReference = self;
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [myWeakReference fetchAndPrintInvoiceData];
            };
            
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Do You Want To Print Last Receipt?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        }

    }
}
-(void)deviceButtonPressed:(int)which
{
	_barcodeScanTextField.text = @"";
}

-(void)deviceButtonReleased:(int)which
{
    [self.crmController UserTouchEnable];
    
    if(_barcodeScanTextField.text.length>0)
    {
        [self textFieldShouldReturn:_barcodeScanTextField];
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    [self.crmController UserTouchEnable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Scanner"])
    {
        _barcodeScanTextField.text = barcode;
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Change Type As Scanner" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    
    
}

- (NSFetchedResultsController *)offlineInvoiceCountResultController
{
    if (_offlineInvoiceCountResultController != nil) {
        return _offlineInvoiceCountResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InvoiceData_T" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *offlineDataDisplayPredicate = [NSPredicate predicateWithFormat:@"isUpload == %@ || isUpload == %@", nil, @(FALSE)];
    fetchRequest.predicate = offlineDataDisplayPredicate;

    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"isUpload" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _offlineInvoiceCountResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"isUpload" cacheName:nil];
    
    [_offlineInvoiceCountResultController performFetch:nil];
    _offlineInvoiceCountResultController.delegate = self;
    
    return _offlineInvoiceCountResultController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.offlineInvoiceCountResultController] && ![controller isEqual:self.itemRingUpResultController]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    if ([controller isEqual:self.itemRingUpResultController]) {
        [self.tenderItemTableView beginUpdates];
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.itemRingUpResultController]) {
        return;
    }
    
    UITableView *tableView = self.tenderItemTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}



- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.itemRingUpResultController]) {
        return;
    }
    [self.tenderItemTableView beginUpdates];
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tenderItemTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tenderItemTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tenderItemTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        default:
            break;
    }
    [self.tenderItemTableView endUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    if ([controller isEqual:_masterDataResultController]) {
//        [self checkMastersAndLaunchActivityIndicator];
//        return;
//    }
    if ([controller isEqual:self.itemRingUpResultController]) {
        [self.tenderItemTableView endUpdates];
    }
    if ([controller isEqual:self.offlineInvoiceCountResultController]) {
        [self updateOfflineInvoiceCount];
    }
    [self updateGasOfflineInvoiceCount:controller];
}
- (void)updateGasOfflineInvoiceCount:(NSFetchedResultsController *)controller{
    
}
- (void)updateOfflineInvoiceCount
{
    _offlineInvoiceCountResultController = nil;
    NSArray *sections = self.offlineInvoiceCountResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
    NSLog(@"offlineInvoiceCount = %lu",(unsigned long)sectionInfo.numberOfObjects);
    if (sections.count == 0 || sectionInfo.numberOfObjects == 0) {
        _offlineInvoiceCount.hidden = YES;
        _offlineInvoiceCountImage.hidden = YES;
        _buttonForOfflineInvoiceCount.hidden = YES;
        _btnAddCustomerLoyalty.frame = CGRectMake(_buttonForOfflineInvoiceCount.frame.origin.x, _btnAddCustomerLoyalty.frame.origin.y, _btnAddCustomerLoyalty.frame.size.width, _btnAddCustomerLoyalty.frame.size.height);
        _lblCustomerName.frame = CGRectMake(_btnAddCustomerLoyalty.frame.origin.x+_btnAddCustomerLoyalty.frame.size.width+10, _lblCustomerName.frame.origin.y, _lblCustomerName.frame.size.width, _lblCustomerName.frame.size.height);
        _btnRemoveCustomer.frame = CGRectMake(_lblCustomerName.frame.origin.x+_lblCustomerName.frame.size.width+10, _btnRemoveCustomer.frame.origin.y, _btnRemoveCustomer.frame.size.width, _btnRemoveCustomer.frame.size.height);
    }
    else
    {
        _offlineInvoiceCount.hidden = NO;
        _offlineInvoiceCountImage.hidden = NO;
        _buttonForOfflineInvoiceCount.hidden = NO;
        _btnAddCustomerLoyalty.frame = CGRectMake(_buttonForOfflineInvoiceCount.frame.origin.x+_buttonForOfflineInvoiceCount.frame.size.width+10, _btnAddCustomerLoyalty.frame.origin.y, _btnAddCustomerLoyalty.frame.size.width, _btnAddCustomerLoyalty.frame.size.height);
        _lblCustomerName.frame = CGRectMake(_btnAddCustomerLoyalty.frame.origin.x+_btnAddCustomerLoyalty.frame.size.width+10, _lblCustomerName.frame.origin.y, _lblCustomerName.frame.size.width, _lblCustomerName.frame.size.height);
        _btnRemoveCustomer.frame = CGRectMake(_lblCustomerName.frame.origin.x+_lblCustomerName.frame.size.width+10, _btnRemoveCustomer.frame.origin.y, _btnRemoveCustomer.frame.size.width, _btnRemoveCustomer.frame.size.height);

        _offlineInvoiceCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)sectionInfo.numberOfObjects];
    }
}
-(IBAction)IntercomMessageComposser:(id)sender
{
    [Intercom presentMessageComposer];
}

-(IBAction)IntercomConversionList:(id)sender
{
    [Intercom presentConversationList];
}

-(CGRect)popOverPostionForOfflineInvoiceDisplay
{
    CGRect buttonFrame = _buttonForOfflineInvoiceCount.frame;
    buttonFrame.origin.y += 20;
    return buttonFrame;
}

-(IBAction)offlineInvoiceCountButton:(id)sender
{
    NSArray *sections = self.offlineInvoiceCountResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
    if (sectionInfo.numberOfObjects == 0)
    {
        return;
    }
    offlineRecordVC = [[OfflineRecordVC alloc] initWithNibName:@"OfflineRecordVC" bundle:nil];
    
    // Present the view controller using the popover style.
    offlineRecordVC.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:offlineRecordVC animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    UIPopoverPresentationController *offlineInvoiceCountPopOver = [offlineRecordVC popoverPresentationController];
    offlineInvoiceCountPopOver.delegate = self;
    offlineRecordVC.preferredContentSize = CGSizeMake(500,456);
    offlineInvoiceCountPopOver.permittedArrowDirections = UIPopoverArrowDirectionAny;
    offlineInvoiceCountPopOver.sourceView = self.view;
    offlineInvoiceCountPopOver.sourceRect = [self popOverPostionForOfflineInvoiceDisplay];
}

- (void)dealloc
{
    NSLog(@"dealloc RcrPosVC");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Fetch Kitchen Printer Section
-(NSArray *)sortDiscriptorForItemRingUPResultController
{
    NSArray *array;

    NSSortDescriptor *guestDescriptor = [[NSSortDescriptor alloc] initWithKey:@"guestId" ascending:YES];
    NSSortDescriptor *itemindexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemIndex" ascending:YES];
    
    array = @[guestDescriptor, itemindexDescriptor];
    return array;
}

- (NSFetchedResultsController *)itemRingUpResultController
{
    
    if (_itemRingUpResultController != nil || self.restaurantOrderObjectId == nil) {
        return _itemRingUpResultController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RestaurantItem" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSArray *sortDescriptors = [self sortDiscriptorForItemRingUPResultController];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    
    NSPredicate *resturantPrintPredicate = [NSPredicate predicateWithFormat:@"isCanceled = %@ AND itemToOrderRestaurant = %@", @(FALSE),[self.managedObjectContext objectWithID:self.restaurantOrderObjectId]];
    fetchRequest.predicate = resturantPrintPredicate;
    
    _itemRingUpResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"guestId" cacheName:nil];
    
    [_itemRingUpResultController performFetch:nil];
    _itemRingUpResultController.delegate = self;
    
    return _itemRingUpResultController;
}
-(void)updateRestaurantItemIntoLocalDataBaseWithReciptArray:(NSMutableArray *)reciptArray
{
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantOrder * restaurantOrder;
    if (self.restaurantOrderObjectId != nil) {
        restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
    }
    for (RestaurantItem *restaurantItem in restaurantOrder.restaurantOrderItem.allObjects)
    {
        for (NSDictionary *restaurantItemDictionary in reciptArray) {
            if ([[restaurantItemDictionary valueForKey:@"itemIndex"] isEqualToNumber:restaurantItem.itemIndex]) {
                restaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:restaurantItemDictionary];
            }
        }
    }
    [UpdateManager saveContext:privateManageobjectContext];
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer*)gesture {
    //    NSLog(@"Long press detected in view controller ... %d", gesture.state);
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"Long press began");
            
            UILabel *guestFloatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            _guestFloatingLabel = guestFloatingLabel;
            _guestFloatingLabel.text = _guestLabelText;
            _guestFloatingLabel.textAlignment = NSTextAlignmentCenter;
            _guestFloatingLabel.font = [UIFont boldSystemFontOfSize:20];
            _guestFloatingLabel.backgroundColor = [UIColor magentaColor];
            _guestFloatingLabel.layer.cornerRadius = 25.0f;
            _guestFloatingLabel.layer.masksToBounds = YES;

            CGPoint hitPoint = [gesture locationInView:guestSelectionVC.view];
            _guestFloatingLabel.center = [guestSelectionVC centerForGuestAtPoint:hitPoint];
            [self.view addSubview:_guestFloatingLabel];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
            _guestFloatingLabel.center = [gesture locationInView:self.view];
            CGPoint hitPoint = [gesture locationInView:tenderItemTableView];
            CGRect testRegion = self.view.frame;
            // Check if in test region
            if (CGRectContainsPoint(testRegion, hitPoint)) {
                NSIndexPath *indexPath = [self.tenderItemTableView indexPathForRowAtPoint:hitPoint];
                if (indexPath) {
                    
                    _guestFloatingLabel.backgroundColor = [UIColor greenColor];
                }
                else
                {
                    _guestFloatingLabel.backgroundColor = [UIColor magentaColor];
                }
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint hitPoint = [gesture locationInView:tenderItemTableView];
            CGRect testRegion = self.view.frame;
            // Check if in test region
            if (CGRectContainsPoint(testRegion, hitPoint)) {
                // Drop it, it will handle
                [self dropGuest:_guestLabelText atPoint:hitPoint];
            }
            [_guestFloatingLabel removeFromSuperview];
        }
            break;
            
        default:
            [_guestFloatingLabel removeFromSuperview];
            break;
    }
}

- (void)dropGuest:(NSString*)guest atPoint:(CGPoint)point {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [self.tenderItemTableView indexPathForRowAtPoint:point];
        if (indexPath) {
            NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
            RestaurantItem *restaurantItem = [self.itemRingUpResultController objectAtIndexPath:indexPath];

            restaurantItem = (RestaurantItem *)[privateManageobjectContext objectWithID:restaurantItem.objectID];
            NSMutableDictionary *billDictionaryAtIndexPath  = [NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail];
            restaurantItem.guestId = @(guest.integerValue);
            billDictionaryAtIndexPath[@"guestId"] = @(guest.integerValue);
            restaurantItem.itemDetail = (NSData *)[NSKeyedArchiver archivedDataWithRootObject:billDictionaryAtIndexPath];
            [UpdateManager saveContext:privateManageobjectContext];
        }
    });
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _longPressGesture) {
        
        CGPoint hitPoint = [gestureRecognizer locationInView:guestSelectionVC.view];
        CGRect testRegion = guestSelectionVC.view.frame;
        // Check if in test region
        if (CGRectContainsPoint(testRegion, hitPoint)) {
            // Check if
            _guestLabelText = [guestSelectionVC labelTextForGuestAtPoint:hitPoint];
            
            if (_guestLabelText) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)checkMastersAndLaunchActivityIndicator {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *sections = self.masterDataResultController.sections;
        if (sections.count > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;

            NSLog(@"[sectionInfo numberOfObjects] = %@", @(sectionInfo.numberOfObjects));
            if (sectionInfo.numberOfObjects > 0) {
                [_activityIndicator hideActivityIndicator];
                _masterDataResultController = nil;
                return;
            } ;

        }

        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    });
}


- (NSFetchedResultsController *)masterDataResultController
{

    if (_masterDataResultController != nil) {
        return _masterDataResultController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;

    // Create the sort descriptors array.
    NSArray *sortDescriptors = @[];
    fetchRequest.sortDescriptors = sortDescriptors;

    _masterDataResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];

    [_masterDataResultController performFetch:nil];
    _masterDataResultController.delegate = self;

    return _masterDataResultController;
}

- (void)configureDiscountForBillDictionary:(NSMutableDictionary *)reciptBillDictionary
                   andWithReciptDictionary:(NSMutableDictionary *)reciptDictionary
{
    DiscountSubCategory  type = SalesItemPercentageDiscount;
    if ([reciptBillDictionary[@"DiscountType"] isEqualToString:@"Amount"])
    {
        type += 1;
    }
    
    if ([reciptBillDictionary[@"AppliedOn"] isEqualToString:@"Bill"])
    {
        type += 2;
    }
    
    if ([reciptDictionary[@"SalesManualDiscountType"] isEqualToString:@"Manual"]) {
        type += 4;
    }
    
    if ([reciptBillDictionary[@"AppliedOn"] isEqualToString:@"Swipe"])
    {
        type = SwipeItemDiscount;
    }
    if ([reciptBillDictionary[@"AppliedOn"] isEqualToString:@"Quantity"])
    {
        type = QtyItemDiscount;
    }
    if ([reciptBillDictionary[@"AppliedOn"] isEqualToString:@"Price_Md"])
    {
        type = PriceMdItemDiscount;
    }
    if  ([reciptBillDictionary[@"AppliedOn"] isEqualToString:@"MixAndMatch"]) {
        type = MixAndMatchDiscount;
    }
   
    DiscountCategory discountCategory;
    switch (type) {
        case    QtyItemDiscount:
            
        case MixAndMatchDiscount:
            
        case    PriceMdItemDiscount:
            discountCategory = DiscountCategoryPredefined;
            break;
            
        case   SalesItemPercentageDiscount:
        case   SalesItemAmountDiscount:
        case   SalesBillPercentageDiscount:
        case   SalesBillAmountDiscount:
            discountCategory = DiscountCategoryCustomized;

            break;
            
        case   ManualItemPercentageDiscount:
        case   ManualItemAmountDiscount:
        case   ManualBillPercentageDiscount:
        case   ManualBillAmountDiscount:
        case   SwipeItemDiscount:
            discountCategory = DiscountCategoryManual;
            break;

        default:
            discountCategory = DiscountCategoryInvalid;

            break;
    }
    reciptBillDictionary[@"DiscountCategory"] = @(discountCategory);
    reciptBillDictionary[@"DiscountSubCategory"] = @(type);
    reciptBillDictionary[@"DiscountId"] = reciptBillDictionary[@"DiscountId"];
  //  [reciptBillDictionary removeObjectForKey:@"AppliedOn"];
    
}

-(NSMutableArray *)configureDiscountArrayForBill
{
    NSMutableArray *reciptArray1 = self.reciptDataAryForBillOrder;
    
    NSSortDescriptor *sorting = [[NSSortDescriptor alloc]initWithKey:@"itemIndex" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sorting];
    NSArray *reciptArray = [reciptArray1 sortedArrayUsingDescriptors:sortDescriptors];
    
    int i =1;
    for (NSMutableDictionary *reciptDictionary in reciptArray) {
        NSMutableArray *discountArray = [reciptDictionary valueForKey:@"Discount"];
        for (NSMutableDictionary *reciptBillDictionary in discountArray) {
            reciptBillDictionary[@"ItemCode"] = [reciptDictionary valueForKey:@"itemId"];
            reciptBillDictionary[@"RowPosition"] = [NSString stringWithFormat:@"%d",i];
            [self configureDiscountForBillDictionary:reciptBillDictionary andWithReciptDictionary:reciptDictionary];
        }
        i++;
    }
    return [reciptArray mutableCopy];
}


#pragma mark - Ticket Validation

-(void)showTicketValidationScreen
{
    BOOL hasRights = [UserRights hasRights:UserRightTickets];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have tickets rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    [Appsee addEvent:kPosMenuRecall];
    [self.rmsDbController playButtonSound];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    itemTicketValidation = [storyBoard instantiateViewControllerWithIdentifier:@"ItemTicketValidation"];
    itemTicketValidation.itemTicketValidationDelegate = self;
    [self.view addSubview:itemTicketValidation.view];
}
-(void)hideItemTicketValidation
{
    [itemTicketValidation.view removeFromSuperview];
}
- (void)nextPassPrint
{
    if (locallastInvoiceTicketPassArray.count == 0) {
        [self nextPrint];
        return;
    }
    
    PassPrinting *passPrinting = [[PassPrinting alloc] init];
    passPrinting._printingData = locallastInvoiceTicketPassArray.lastObject;
    
    NSString *portName     = @"";
    NSString *portSettings = @"";
    [self SetPortInfo];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    [passPrinting printingWithPort:portName portSettings:portSettings withDelegate:self];
}


#pragma mark - Printer Function Delegate

-(void)actualDrawerStatus:(ActualDrawerStatus)actualDrawerStatus {
    [_activityIndicator hideActivityIndicator];;
    if (actualDrawerStatus == ActualDrawerStatusOpen) {
        [self displayDrawerAlertWithTitle:@"Drawer Open" message:@"Please close the drawer and then tap on Continue button.If drawer is closed, then tap on Already closed button."];
    }
    else {
        if ([noSaleType isEqualToString:@"DROP"]) {
            [self openDropAmountPopUpWithDrawerOpened:YES];
        }
    }
}

-(void)errorOccuredInGettingStatusWithTitle:(NSString *)title message:(NSString *)message {
    [_activityIndicator hideActivityIndicator];;
    [self displayDrawerAlertWhileGettingErrorWithTitle:title message:message];
}

- (void)displayDrawerAlertWithTitle:(NSString *)title message:(NSString *)message {
    RcrPosVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [myWeakReference checkDrawerStatus:YES];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [myWeakReference checkDrawerStatus:NO];
    };

    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:@[@"Already closed",@"Continue"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)displayDrawerAlertWhileGettingErrorWithTitle:(NSString *)title message:(NSString *)message {
    RcrPosVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [myWeakReference checkDrawerStatus:NO];
    };
    [self.rmsDbController popupAlertFromVC:self title:title message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

-(void)dropAmountPopUpOpenProcess {
    [_activityIndicator hideActivityIndicator];;
    if (needToCheckDrawerStatus) {
        [self displayDrawerAlertWithTitle:@"Drawer Open" message:@"Please close the drawer and then tap on Continue button.If drawer is closed, then tap on Already closed button."];
    }
    else {
        if ([noSaleType isEqualToString:@"DROP"]) {
            [self openDropAmountPopUpWithDrawerOpened:YES];
        }
    }
}

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
    if ([device isEqualToString:@"Printer"]) {
        if (!isNoSalesPrint) {
            if (currentPrintStep == LastInvoice_PassPrint) {
                [locallastInvoiceTicketPassArray removeLastObject];
                [self nextPassPrint];
            }
            else
            {
                [self nextPrint];
            }
        }
        else
        {
            isNoSalesPrint = FALSE;
        }
    }
    else
    {
        [self dropAmountPopUpOpenProcess];
    }
}

- (void)failToOpenDrawer {
    [_activityIndicator hideActivityIndicator];;
    [self displayOpenCashDrawerRetryAlert:@"Failed to open Cash Drawer. Would you like to retry.?"];
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp {
    if ([device isEqualToString:@"CashDrawer"]) {
        [self failToOpenDrawer];
    }
    else
    {
        NSString *retryMessage;
        if (!isNoSalesPrint) {
            if (currentPrintStep == LastInvoice_PassPrint) {
                retryMessage = @"Failed to pass print receipt. Would you like to retry.?";
                [self displayPassPrintRetryAlert:retryMessage];
            }
            else
            {
                if (currentPrintStep == LastInvoice_CardPrint) {
                    retryMessage = @"Failed to Card print receipt. Would you like to retry.?";
                }
                else
                {
                    retryMessage = @"Failed to Invoice print receipt. Would you like to retry.?";
                }
                [self displayLastInvoicePrintRetryAlert:retryMessage];
            }
        }
        else
        {
            retryMessage = @"Failed to No Sales print receipt. Would you like to retry.?";
            [self displayNoSalesPrintRetryAlert:retryMessage];
        }
    }
}

- (void)nextPrint
{

    BOOL isApplicable = FALSE;
    currentPrintStep++;

    switch (currentPrintStep) {
        case   LastInvoice_PrintBegin:
            break;
        case LastInvoice_PassPrint:
            if (locallastInvoiceTicketPassArray.count > 0) {
                isApplicable = TRUE;
                [self nextPassPrint];
            }
            break;
        case LastInvoice_CardPrint:
            [self printCardReciept];
            isApplicable = TRUE;

            break;
        case LastInvoice_InvoicePrint:
            [self printInvoiceReceipt];
            isApplicable = TRUE;
            break;
        case LastInvoice_PrintDone:
        case LastInvoice_PrintCancel:
            return;
            break;
        }
    if (isApplicable == FALSE) {
        [self nextPrint];
    }
}


-(void)displayLastInvoicePrintRetryAlert:(NSString *)message
{
    RcrPosVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep--;
        [myWeakReference nextPrint];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = LastInvoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
    
}

-(void)displayPassPrintRetryAlert:(NSString *)message
{
    RcrPosVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [self nextPassPrint];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        currentPrintStep = LastInvoice_PrintDone;
        [myWeakReference nextPrint];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)displayOpenCashDrawerRetryAlert:(NSString *)message
{
    RcrPosVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        [self SetPortInfo];
        NSString *portName     = [RcrController getPortName];
        NSString *portSettings = [RcrController getPortSettings];
        [myWeakReference openCashDrawerWithPort:portName portSettings:portSettings];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)displayNoSalesPrintRetryAlert:(NSString *)message
{
    RcrPosVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference KickCashDrawer];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        isNoSalesPrint = FALSE;
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)updateBillSummaryWithReceiptArray:(NSArray *)receiptArray
{
    self.subTotalLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:rcrBillSummary.totalSubTotalAmount]];
    self.totalTaxLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:rcrBillSummary.totalTaxAmount]];
    if (isEBTValid) {
        self.totalEBTLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:rcrBillSummary.totalEBTAmount]];
    }
    else
    {
        self.totalEBTLabel.text = @"";
        self.lblEBT.text = @"";
    }

    self.totalDiscountLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:rcrBillSummary.totalDiscountAmount]];
    float total = rcrBillSummary.totalSubTotalAmount.floatValue + rcrBillSummary.totalTaxAmount.floatValue;
    NSNumber *totalBillAmount= @(total);
    self.billAmountLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:totalBillAmount]];
  
    CGFloat qty = 0;
    for (int i = 0 ; i < receiptArray.count; i++) {
        CGFloat totalQty = [[receiptArray[i] valueForKeyPath:@"itemQty"] floatValue] / [[receiptArray[i] valueForKeyPath:@"PackageQty"] floatValue];
        qty += totalQty;
    }
    _itemCountLabel.text= [NSString stringWithFormat:@"%@",@(qty)];

}

#pragma mark - Restaurant Item Count Delegate Methods
-(void)didChangeFavouriteCount:(NSInteger)count
{
    _favouriteCountLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
}
-(void)didChangeDepartmentCount:(NSInteger )count
{
    _departmentCountLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
}
-(void)didChangeSubDepartmentItemCount:(NSInteger)subDepartmentItemCount
{
}

-(void)didChangeSubDepartmentCount:(NSInteger )count
{
}

-(IBAction)viewAllFavourite:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    CGFloat favouriteContainerHeight = _favouriteContainerView.frame.size.height;
    CGFloat favouriteContainerYPosition ;
    
    if (favouriteContainerHeight == DEPARTMENT_FAVORITE_CONTAINER_HEIGHT) {
        favouriteContainerHeight = DEPARTMENT_FAVORITE_CONTAINER_HEIGHT/2;
        favouriteContainerYPosition = 315.0;
        [button setImage:[UIImage imageNamed:@"rcr_viewall.png"] forState:UIControlStateNormal];
    }
    else
    {
        favouriteContainerHeight = DEPARTMENT_FAVORITE_CONTAINER_HEIGHT;
        favouriteContainerYPosition = 0.00;
        [button setImage:[UIImage imageNamed:@"rcr_back.png"] forState:UIControlStateNormal];

    }
    [_departmentFavouriteContainer bringSubviewToFront:_favouriteContainerView];
    
    [UIView animateWithDuration:0.4 animations:^{
        _favouriteContainerView.frame = CGRectMake(_favouriteContainerView.frame.origin.x, favouriteContainerYPosition, _favouriteContainerView.frame.size.width, favouriteContainerHeight);
        if (favouriteContainerHeight == DEPARTMENT_FAVORITE_CONTAINER_HEIGHT) {
            _departmentContainerView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        if (favouriteContainerHeight != DEPARTMENT_FAVORITE_CONTAINER_HEIGHT) {
            _departmentContainerView.alpha = 1.0;
        }
        [self.favourite updateFavouritePageControl];
    }];

}

-(IBAction)viewAllDepartment:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    CGFloat departmentContainerHeight = _departmentContainerView.frame.size.height;
    if (departmentContainerHeight == DEPARTMENT_FAVORITE_CONTAINER_HEIGHT) {
        departmentContainerHeight = DEPARTMENT_FAVORITE_CONTAINER_HEIGHT/2;
        [button setImage:[UIImage imageNamed:@"rcr_viewall.png"] forState:UIControlStateNormal];
    }
    else
    {
        departmentContainerHeight = DEPARTMENT_FAVORITE_CONTAINER_HEIGHT;
        [button setImage:[UIImage imageNamed:@"rcr_back.png"] forState:UIControlStateNormal];

    }
    [_departmentFavouriteContainer bringSubviewToFront:_departmentContainerView];


    [UIView animateWithDuration:0.4 animations:^{
        _departmentContainerView.frame = CGRectMake(_departmentContainerView.frame.origin.x, _departmentContainerView.frame.origin.y, _departmentContainerView.frame.size.width, departmentContainerHeight);
        if (departmentContainerHeight == DEPARTMENT_FAVORITE_CONTAINER_HEIGHT)
        {
            _favouriteContainerView.hidden = YES;
           // favouriteContainerView.alpha = 0.0;
        }
        
    } completion:^(BOOL finished) {
        if (departmentContainerHeight != DEPARTMENT_FAVORITE_CONTAINER_HEIGHT) {
            _favouriteContainerView.hidden = NO;

            _favouriteContainerView.alpha = 1.0;
        }
        [self.departments updateDepartmentPageControl];
    }];
}

-(IBAction)addDepartment:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to add new department. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    AddDepartmentVC *addDepartmentVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"AddDepartmentVC_sid"];
    addDepartmentVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:addDepartmentVC animated:TRUE completion:nil];
}

-(IBAction)addSubDepartment:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to add new subdepartment. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    AddSubDepartmentVC *addSubDepartmentVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"AddSubDepartmentVC_sid"];
    addSubDepartmentVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:addSubDepartmentVC animated:TRUE completion:nil];
}

-(IBAction)addItemVc:(id)sender
{
    {
        for (UIView *view in self.view.subviews)
        {
            if ([view isEqual:self.rcrRightSlideMenuVC.view]) {
                if (giftcardPopOverController)
                {
                    [giftcardPopup dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
        self.rcrRightSlideMenuVC = nil;
        if (self.rcrRightSlideMenuVC == nil)
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
            self.rcrRightSlideMenuVC = [storyBoard instantiateViewControllerWithIdentifier:@"RCRAddItemFavouriteMenu"];
            giftcardPopup = self.rcrRightSlideMenuVC;
            self.rcrRightSlideMenuVC.rcrSlideMenuVCDelegate = self;
            
            // Present the view controller using the popover style.
            giftcardPopup.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:giftcardPopup animated:YES completion:nil];
            
            // Get the popover presentation controller and configure it.
            giftcardPopOverController = [giftcardPopup popoverPresentationController];
            giftcardPopOverController.delegate = self;
            giftcardPopup.preferredContentSize = CGSizeMake(190, 110);
            if ([self.moduleIdentifierString isEqualToString:@"RcrPosGasVC"]){
                giftcardPopOverController.permittedArrowDirections = UIPopoverArrowDirectionLeft;
            }
            else{
                giftcardPopOverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            }

            giftcardPopOverController.sourceView = self.view;
            giftcardPopOverController.sourceRect = [self getRectForAddItemButtonPopup];
            
            self.rcrRightSlideMenuVC.rcrSlideMenuItemEnum = @[@(RCRAddItemMenu
                                                              ),@(RCRAddToFavouriteMenu)];
            self.rcrRightSlideMenuVC.isPresentAsPopOver = TRUE;
            self.rcrRightSlideMenuVC.rcrSlideMenuNames = @[@"ADD ITEM",@"ADD TO FAVOURITE ITEM"];
            self.rcrRightSlideMenuVC.rcrSlideMenuNormalImages = @[@"",@""];
            self.rcrRightSlideMenuVC.rcrSlideMenuSelectedImages = @[@"",@""];

        }
    }
  
}
- (CGRect)getRectForAddItemButtonPopup
{
    CGRect popRect;
    if ([self.moduleIdentifierString isEqualToString:@"RetailRestaurant"])
    {
        popRect = CGRectMake(875, 375, 170, 78);
    }
    else if ([self.moduleIdentifierString isEqualToString:@"RcrPosRestaurantVC"])
    {
        popRect =  CGRectMake(875, 375, 170, 78);
    }
    else if ([self.moduleIdentifierString isEqualToString:@"RcrPosVC"])
    {
        popRect =  CGRectMake(870, 355, 170, 78);
        if (_favouriteContainerView.frame.size.height == DEPARTMENT_FAVORITE_CONTAINER_HEIGHT)
        {
            popRect = CGRectMake(870, 40, 170, 78);
        }
    }
    else if ([self.moduleIdentifierString isEqualToString:@"RcrPosGasVC"])
    {
        popRect = CGRectMake(300, 220, 170, 78);
    }
    else
    {
        popRect =  CGRectMake(870, 355, 170, 78);
    }
    return popRect;
}

-(IBAction)addItem:(id)sender
{
    [giftcardPopup dismissViewControllerAnimated:YES completion:nil];
    BOOL hasRights = [UserRights hasRights:UserRightInventoryInfo];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to add new item. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    ItemDetailEditVC *addNewSplitterVC = (ItemDetailEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemDetailEditVC_sid"];
    addNewSplitterVC.selectedItemInfoDict = nil;
    addNewSplitterVC.isItemFavourite = TRUE;
    addNewSplitterVC.isItemCopy = FALSE;
    addNewSplitterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:addNewSplitterVC animated:TRUE completion:nil];

}
-(IBAction)addToFavouriteItem:(id)sender
{
    [giftcardPopup dismissViewControllerAnimated:YES completion:nil];

    [[self.view viewWithTag:252322]removeFromSuperview ];
    ItemDisplayViewController *objItemDisplay=[[ItemDisplayViewController alloc]initWithNibName:@"ItemDisplayViewController" bundle:nil];
    objItemDisplay.rcrPosVcDeleage = self;
    objItemDisplay.isItemForFavourite = YES;
    [self presentViewController:objItemDisplay animated:YES completion:^{
    }];
    [_activityIndicator hideActivityIndicator];

}
-(void)authorizedWithAmount:(CGFloat)amount basePrice:(CGFloat)basePrice
{
    
}
-(void)authorizedWithQuantity:(CGFloat)quantity basePrice:(CGFloat)basePrice
{
    
}

-(IBAction)btnShowGraph:(id)sender
{
    [self createDiscountGraph];
}

-(void)didCancelDiscountView
{
    discountBillDetailVC.view.hidden = YES;
    [discountBillDetailVC.view removeFromSuperview];
    discountBillDetailVC = nil;
}


-(void)createDiscountGraph
{
    [discountBillDetailVC.view removeFromSuperview];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RapidTest" bundle:nil];
    discountBillDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"DiscountBillDetailVC"];
    discountBillDetailVC.discountBillDetailDelegate = self;
    [self.view addSubview:discountBillDetailVC.view];
    
    [discountBillDetailVC plotGraph:[rdDiscountCalculator headNode] withPath:[rdDiscountCalculator pathForDiscount]];
}

-(void)didContinueCardTransactionRequestProcessWithPaymentArray:(NSMutableArray *) paymentArray
{
    [_activityIndicator hideActivityIndicator];
    [self removePresentModalView];
    [cardTransactionRequestVC.view removeFromSuperview ];
    if (paymentArray.count > 0) {
        [self tenderTransactionWithTenderType:@"" withPayId:0];
    }
    else
    {
        [self removeRestaurantOrderObject];
        [self updateBillUI];
    }
}

-(void) didComplateCardTransactionWithPaymentData:(PaymentData *)paymentData
{
    [_activityIndicator hideActivityIndicator];
    [self insertDataInLocalDataBaseWithPaymentData:paymentData];
    [cardTransactionRequestVC.view removeFromSuperview ];
    [self removeRestaurantOrderObject];
    [self removePresentModalView];
    
}

-(void)insertTenderPaymentDataToDatabase:(NSMutableDictionary *)tenderData WithPaymentData:(PaymentData *)paymentData
{
    NSManagedObjectContext *privateContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext ];
    invoiceData = [self.updateManager insertTenderPaymentDataFromDictionary:tenderData withContext:privateContext];
    invoiceData = (InvoiceData_T*)[self.managedObjectContext objectWithID:invoiceData.objectID];
    [self.crmController didInsertInvoiceDataToServerWithDetail:[self getPaymentProcessDataWithPaymentData:paymentData] withInvoiceObject:invoiceData.objectID];

    
    
}

-(void)didCancelCardTransactionRequestProcess
{
    [_activityIndicator hideActivityIndicator];
    [cardTransactionRequestVC.view removeFromSuperview ];
    [self removeRestaurantOrderObject];
    [self removePresentModalView];
    [self updateBillUI];
}

-(void)didUpdateCardTransactionWithPaymentData:(PaymentData *)paymentData
{
    if (self.restaurantOrderObjectId)
    {
        NSManagedObjectContext *privateManageobjectContext = self.managedObjectContext;
        RestaurantOrder * restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
        restaurantOrder.paymentData = [NSKeyedArchiver archivedDataWithRootObject:paymentData];
        restaurantOrder.orderStatus = @(TP_BEGIN);
        [UpdateManager saveContext:privateManageobjectContext];
    }
    
}

- (void)insertDataInLocalDataBaseWithPaymentData:(PaymentData *)paymentData
{
    NSMutableDictionary *databaseInsertDictionary = [self getPaymentProcessDataWithPaymentData:paymentData];
    databaseInsertDictionary[@"branchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    databaseInsertDictionary[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    databaseInsertDictionary[@"zId"] = [self.rmsDbController.globalDict valueForKey:@"ZId"];
    databaseInsertDictionary[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    databaseInsertDictionary[@"msgCode"] = @"-1";
    databaseInsertDictionary[@"message"] = @"Web services Connection Error. Try Again";
    [self insertTenderPaymentDataToDatabase:databaseInsertDictionary WithPaymentData:paymentData] ;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CardTransactionRequest"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

-(NSMutableDictionary *)getPaymentProcessDataWithPaymentData:(PaymentData *)paymentData
{
    NSMutableDictionary * invoiceDetailDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [paymentData tenderInvoiceMst];
    invoiceDetailDict[@"InvoiceItemDetail"] = [paymentData generateInvoiceItemDetailWith:[self reciptDataAryForBillOrder]];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [paymentData invoicePaymentdetail];
    if(self.crmController.reciptItemLogDataAry.count > 0)
    {
        invoiceDetailDict[@"InvoiceItemLog"] = self.crmController.reciptItemLogDataAry;
    }
    [invoiceDetail addObject:invoiceDetailDict];
    invoiceDetailDictionary[@"InvoiceDetail"] = invoiceDetail;
    
    return invoiceDetailDictionary;
}


@end

@implementation RcrPosVC (ForRcRGas)

-(NSManagedObjectID *)createRCRGasForBillDictionary:(NSMutableDictionary *)billDictionary {
    
    NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    RestaurantOrder *restaurantOrder;
    if (self.restaurantOrderObjectId == nil)
    {
        NSMutableDictionary *restaurantOrderDetail = [[NSMutableDictionary alloc]init];
        restaurantOrderDetail[@"noOfGuest"] = @"1";
        restaurantOrderDetail[@"tableName"] = @"Retail";
        restaurantOrderDetail[@"orderid"] = @(0);
        restaurantOrderDetail[@"orderState"] = @(OPEN_ORDER);
        restaurantOrderDetail[@"InvoiceNo"] = [self currentRegisterInvoiceNumber];
        restaurantOrder = [self.updateManager insertRestaurantOrderListInLocalDataBase:restaurantOrderDetail withContext:privateManageobjectContext];
        self.restaurantOrderObjectId = restaurantOrder.objectID;
    }
    else
    {
        restaurantOrder = (RestaurantOrder *)[privateManageobjectContext objectWithID:self.restaurantOrderObjectId];
    }
    
    NSMutableDictionary *restaurantItemList = [[NSMutableDictionary alloc]init];
    restaurantItemList[@"isCanceled"] = @(0);
    restaurantItemList[@"isNoPrint"] = @(0);
    restaurantItemList[@"isDineIn"] = @(restaurantOrder.isDineIn.boolValue);
    restaurantItemList[@"isPrinted"] = @(0);
    restaurantItemList[@"itemId"] = [billDictionary valueForKey:@"itemId"];
    restaurantItemList[@"itemIndex"] = @(restaurantOrder.restaurantOrderItem.allObjects.count);
    restaurantItemList[@"noteToChef"] = @"";
    restaurantItemList[@"orderId"] = @(0);
    restaurantItemList[@"orderItemId"] = @(0);
    restaurantItemList[@"previousQuantity"] = @(0);
    restaurantItemList[@"quantity"] = [billDictionary valueForKey:@"itemQty"];
    restaurantItemList[@"itemName"] = [billDictionary valueForKey:@"itemName"];
    restaurantItemList[@"guestId"] = @(guestSelectionVC.selectedGuestId);
    billDictionary[@"guestId"] = @(guestSelectionVC.selectedGuestId);
    billDictionary[@"isDineIn"] = @(restaurantOrder.isDineIn.boolValue);
    billDictionary[@"itemIndex"] = @(restaurantOrder.restaurantOrderItem.allObjects.count);
    restaurantItemList[@"itemDetail"] = billDictionary;
    
    RestaurantItem *resItem = [self.updateManager insertGasItemInLocalDataBase:restaurantItemList withContext:privateManageobjectContext withItemRestaurantOrder:restaurantOrder];
    
    return resItem.objectID;
}

- (void)updateBillUI
{
   NSMutableArray *reciptArray = [self reciptDataAryForBillOrder];
//    NSLog(@"Bill Amount Calculator :- %@",[self.rmsDbController jsonStringFromObject:reciptArray]);
    if(reciptArray.count > 0)
    {
//        [billAmountCalculator calculateBillAmountsWithBillReceiptArray:reciptArray];
        reciptArray = [rdDiscountCalculator calculateDiscountForReceiptArray:reciptArray withBillAmountCalculator:billAmountCalculator];

    }
//    [self TaxCalculateForReciptDataArray:reciptArray];
    [rcrBillSummary taxCalculateForReciptDataArray:reciptArray withManagedObjectContext:self.managedObjectContext];
    [rcrBillSummary updateBillSummrayWithDetail:reciptArray];
    [self updateBillSummaryWithReceiptArray:reciptArray];
   // [self calculateTotalForReciptArray:reciptArray];
    [self didSendDataToCustomerDisplay:reciptArray];
    [self updateRestaurantItemIntoLocalDataBaseWithReciptArray:reciptArray];
    _itemRingUpResultController = nil;
    [self.tenderItemTableView reloadData];
    [reciptArray removeAllObjects];
    [self processNextStepForItem];

}

-(IBAction)btnMixMatchClick:(id)sender
{
    
    NSMutableArray *reciptArray = [self reciptDataAryForBillOrder];
    if(reciptArray.count > 0)
    {
        [self setMixMatchBunch:_barcodeScanTextField.text withBillArray:reciptArray];
    }
}

-(void)setMixMatchBunch:(NSString *)stringBill withBillArray:(NSMutableArray *)billObject
{

        NSError *error;
        NSMutableArray *billArray = [[NSMutableArray alloc] init];
        
        
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MixMatch.txt"];
        NSLog(@"%@",filePath);
        
        NSMutableDictionary *billDictionary = [[NSMutableDictionary alloc] init];
        
        NSString *names = [[NSString alloc] initWithContentsOfFile: filePath
                                                          encoding: NSUTF8StringEncoding
                                                             error: &error];
        
        billDictionary = [self.rmsDbController objectFromJsonString:names] ;
        
        if (billDictionary) {
            billArray = [billDictionary valueForKey:@"MixMatchCase"] ;
        }
        else
        {
            billDictionary = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary *bill = [[NSMutableDictionary alloc] init];
        [bill setObject:stringBill forKey:@"Bill"];
        [bill setObject:billObject forKey:@"BillObject"];
        [bill setObject:[NSString stringWithFormat:@"%f",rdDiscountCalculator.totalDiscount] forKey:@"Discount"];
        [bill setObject:[NSString stringWithFormat:@"%f",(rdDiscountCalculator.billAmount-rdDiscountCalculator.totalDiscount)] forKey:@"TotalPrice"];
        [billArray addObject:bill];
        [billDictionary setObject:billArray forKey:@"MixMatchCase"];
        
        NSString *jsonStringToWrite = [self.rmsDbController jsonStringFromObject:billDictionary];
        [jsonStringToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}


@end
