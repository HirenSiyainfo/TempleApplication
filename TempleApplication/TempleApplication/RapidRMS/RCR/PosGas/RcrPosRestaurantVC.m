//
//  RcrPosRestaurantVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 10/14/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RcrPosRestaurantVC.h"
#import "DepartmentCollectionCell.h"
#import "RmsDbController.h"
#import "RcrController.h"

#import "Department+Dictionary.h"
#import "SubDepartment+Dictionary.h"
#import "SubDepartmetCollectionVC.h"
#import "SubDeptItemCollectionVC.h"
#import "Item+Dictionary.h"
#import "VariationSelectionVC.h"
#import "BillAmountCalculator.h"
#import "FavouriteCollectionVC.h"
#import "CustomerViewController.h"
#import "RestaurantOrderList.h"
#import "RestaurantOrder+Dictionary.h"
#import "RestaurantItem+Dictionary.h"
#import "GusestSelectionVC.h"
#import "KitchenPrintDisplayVC.h"
#import  "AddRemoveGuestVC.h"
#import "KitchenPrinting.h"
#import "KitchenPrinter+Dictionary.h"
#import "Configuration+Dictionary.h"
#import "AddDepartmentVC.h"
#import "AddSubDepartmentVC.h"

@interface RcrPosRestaurantVC () <SubDepartmetCollectionVcDelegate,SubDepartmetItemsVcDelegate,VariationSelectionDelegate,FavouriteCollectionDelegate,AddRemoveGuestDelegate,PrinterFunctionsDelegate,UIPopoverPresentationControllerDelegate>
{
    VariationSelectionVC *variationSelectionVC;
    BillAmountCalculator *billAmountCalculator;
    Department *departmentOfSubDept;
    FavouriteCollectionVC *favouriteTemp;
    RestaurantOrderList *restaurantOrderList;
    AddRemoveGuestVC *addremoveguest;
   
    UIPopoverPresentationController *addremovePopoverview;
    UISwipeGestureRecognizer *swipeToChageItemViewGetureRecognizer;
    NSArray *array_port;
    NSInteger selectedPort;

}
@property (nonatomic, weak) IBOutlet UIView *guestSelectionView;
@property (nonatomic, weak) IBOutlet UIView *guestLabelView;
@property (nonatomic, weak) IBOutlet UIView *departmentButttonView;
@property (nonatomic, weak) IBOutlet UIView *subDepartmentButttonView;
@property (nonatomic, weak) IBOutlet UILabel *itemHeaderTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *itemHeaderTitleImage;
@property (nonatomic, weak) IBOutlet UIButton *departmentTabButton;
@property (nonatomic, weak) IBOutlet UIButton *addDepartmentBtn;
@property (nonatomic, weak) IBOutlet UIButton *subDepartmentTabButton;
@property (nonatomic, weak) IBOutlet UIView *swipeGestureRecognizerView;
@property (nonatomic, weak) IBOutlet UILabel *departmentCountValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *departmentCountNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *favouriteCountValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *subDepartmentCountValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *subDepartmentCountNameLabel;
@property (nonatomic, weak) IBOutlet UIView *restaurentTempfavoriteView;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *kitchenPrinting;
@property (nonatomic, strong) NSFetchedResultsController *kitchenprinterResultsetController;

@end

@implementation RcrPosRestaurantVC
//@synthesize managedObjectContext = __managedObjectContext;

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

    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    swipeToChageItemViewGetureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDisplayFavouriteView:)];
    swipeToChageItemViewGetureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [_swipeGestureRecognizerView addGestureRecognizer:swipeToChageItemViewGetureRecognizer];
    _swipeGestureRecognizerView.hidden = YES;
    
    
    
    _departmentTabButton.selected = YES;
    _subDepartmentTabButton.selected = NO;
    _addDepartmentBtn.selected = NO;


    _itemHeaderTitleLabel.text = @"FAVORITES";
    _itemHeaderTitleImage.image = [UIImage imageNamed:@"RetailResto-favoriteiconforpatch.png"];
    
    _departmentCountValueLabel.textColor = [UIColor whiteColor];
    _departmentCountNameLabel.textColor = [UIColor whiteColor];


//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self didRingupRestaurantOrderWithOrderId:self.orderId];
//    });
     self.btnGuestAdd.layer.cornerRadius = 30.0;
    self.btnGuestAdd.layer.masksToBounds=YES;
    
//    [self diplayGuestSelectionVC];
    
    array_port = @[@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109"];
    selectedPort = 0;

}


-(void)diplayGuestSelectionVC
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    guestSelectionVC = [storyBoard instantiateViewControllerWithIdentifier:@"GusestSelectionVC"];
    RestaurantOrder *restaurantOrder = (RestaurantOrder *)[self.managedObjectContext objectWithID:self.restaurantOrderObjectId];
    guestSelectionVC.guestCount = restaurantOrder.noOfGuest.integerValue;
    guestSelectionVC.view.frame = _guestSelectionView.bounds;
    [_guestSelectionView addSubview:guestSelectionVC.view];
    
}

-(IBAction)addnewGuest:(id)sender{
    
    RestaurantOrder *restaurantOrder = (RestaurantOrder *)[self.managedObjectContext objectWithID:self.restaurantOrderObjectId];

    BOOL enableRemoveGuest = [self checkitemalreadyExitforOrder];
    
    addremoveguest = [self.storyboard instantiateViewControllerWithIdentifier:@"AddRemoveGuestVC"];
    addremoveguest.isdescressGuest = enableRemoveGuest;
    addremoveguest.addRemoveGuestDelegate = self;
    addremoveguest.guestCount = restaurantOrder.noOfGuest.stringValue;
    addremoveguest.tableName = restaurantOrder.tabelName;

    // Present the view controller using the popover style.
    addremoveguest.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:addremoveguest animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    addremovePopoverview = [addremoveguest popoverPresentationController];
    addremovePopoverview.delegate = self;
    addremovePopoverview.permittedArrowDirections = UIPopoverArrowDirectionLeft;
    addremovePopoverview.sourceView = self.view;
    addremovePopoverview.sourceRect = [self.view convertRect:CGRectMake(self.btnGuestAdd.frame.origin.x+10, self.btnGuestAdd.frame.origin.y-30, self.btnGuestAdd.frame.size.width, self.btnGuestAdd.frame.size.height) fromView:guestSelectionVC.view];
}

-(void)updateGuestCount:(NSInteger)guestCount withtableName:(NSString *)strtblName{
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
     
     RestaurantOrder  *restaurantOrder = (RestaurantOrder *)[privateContextObject objectWithID:self.restaurantOrderObjectId];
     restaurantOrder.noOfGuest = (NSNumber *)@(guestCount);
     restaurantOrder.tabelName = strtblName;
     [UpdateManager saveContext:privateContextObject];
     
     guestSelectionVC.guestCount = restaurantOrder.noOfGuest.integerValue;    
     [guestSelectionVC reloadGuestView];
}

-(BOOL)checkitemalreadyExitforOrder{
    
    BOOL isExits = YES;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RestaurantItem" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCanceled = %@ AND itemToOrderRestaurant = %@",@(FALSE), [self.managedObjectContext objectWithID:self.restaurantOrderObjectId]];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        isExits = NO;
    }
    else{
        isExits = YES;
    }
    return isExits;
}

-(NSString *)sectionNameForHeader:(NSString *)sectionName
{
    if([self.moduleIdentifierString isEqualToString:@"RetailRestaurant"])
    {
        return @"";
    }
    
    return [NSString stringWithFormat:@"Guest %@", sectionName];
}

-(void)diplayRestaurantOrderListView
{
    [self switchReastaurantOrder];
    [self.navigationController popViewControllerAnimated:TRUE];
}
-(void)didInsertRestaurantOrderListWithDictionary:(NSMutableDictionary *)restaurantOrderListDictionary
{
    self.restaurantOrderDictionary = restaurantOrderListDictionary;
    [restaurantOrderList.view removeFromSuperview];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.orderId = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadFavouriteItemForRestaurant];
}

-(NSMutableArray *)posmenuItemsForRetailRestaurant
{
    
    Item *giftCarditem = [self fetchAllItemForGiftCard:@"RapidRMS Gift Card"];
    NSArray  *menuTitles;
    NSArray  *selectedImages;
    NSArray *normalImages;
    
    if(giftCarditem){
        
        menuTitles = @[@"Hold",@"Recall",@"Discount",@"Cancel Tnx.",@"Refund",@"Gift Card"];
        selectedImages = @[@"RCR_holdselected.png",@"RCR_recallselected.png",@"RCR_discountselected.png",@"cancletnxselected.png",@"RCR_refundselected.png",@"RCR_giftcardselected"];
        normalImages = @[@"RCR_hold.png",@"RCR_recall.png",@"RCR_discount.png",@"cancletnx.png",@"RCR_refund.png",@"RCR_giftcard.png"];
        menuId = @[@(HOLD_POS_MENU),@(RECALL_POS_MENU),
                   @(DISCOUNT_POS_MENU),
                   @(CANCEL_POS_MENU),
                   @(REFUND_POS_MENU),
                   @(GIFT_CARD_POS_MENU),
                   ];
    }
    else{
        menuTitles = @[@"Hold",@"Recall",@"Discount",@"Cancel Tnx.",@"Refund"];
        selectedImages = @[@"RCR_holdselected.png",@"RCR_recallselected.png",@"RCR_discountselected.png",@"cancletnxselected.png",@"RCR_refundselected.png",@"RCR_giftcardselected"];
        normalImages = @[@"RCR_hold.png",@"RCR_recall.png",@"RCR_discount.png",@"cancletnx.png",@"RCR_refund.png",@"RCR_giftcard.png"];

        menuId = @[@(HOLD_POS_MENU),@(RECALL_POS_MENU),
                   @(DISCOUNT_POS_MENU),
                   @(CANCEL_POS_MENU),
                   @(REFUND_POS_MENU),
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

-(NSString *)logOutMessage
{
    if ([self.moduleIdentifierString isEqualToString:@"RetailRestaurant"])
    {
        return @"please complete or void this transcation.";
    }
    return @"please confirm or void this transcation.";
}


-(NSMutableArray *)posMenuItems
{
    if ([self.moduleIdentifierString isEqualToString:@"RcrPosRestaurantVC"])
    {
        return [self posMenuItemsForRestaurant];
    }
    else if ([self.moduleIdentifierString isEqualToString:@"RetailRestaurant"])
    {
        return [self posmenuItemsForRetailRestaurant];
    }
    return nil;
}

- (Item*)fetchAllItemForGiftCard :(NSString *)strGiftCard
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
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

- (NSMutableArray *)posMenuItemsForRestaurant
{
    Item *giftCarditem = [self fetchAllItemForGiftCard:@"RapidRMS Gift Card"];
    NSArray  *menuTitles;
    NSArray  *selectedImages;
    NSArray *normalImages;
    
    if(giftCarditem){
        
        menuTitles = @[@"Send Order",@"Switch",@"Discount",@"Cancel Tnx.",@"Refund",@"Gift Card"];
        selectedImages = @[@"sendorderselected.png",@"switchorderselected.png",@"RCR_discountselected.png",@"cancletnxselected.png",@"RCR_refundselected.png",@"RCR_giftcardselected.png"];
        normalImages = @[@"sendorder_new.png",@"switchorder.png",@"RCR_discount.png",@"cancletnx.png",@"RCR_refund.png",@"RCR_giftcard.png"];
        
        menuId = @[@(SEND_ORDER_POS_MENU),@(SWITCH_TABLE_POS_MENU),
                   @(DISCOUNT_POS_MENU),
                   @(CANCEL_POS_MENU),
                   @(REFUND_POS_MENU),
                   @(GIFT_CARD_POS_MENU),
                   ];
    }
    else{
        
        menuTitles = @[@"Send Order",@"Switch",@"Discount",@"Cancel Tnx.",@"Refund"];
        selectedImages = @[@"sendorderselected.png",@"switchorderselected.png",@"RCR_discountselected.png",@"cancletnxselected.png",@"RCR_refundselected.png"];
        normalImages = @[@"sendorder_new.png",@"switchorder.png",@"RCR_discount.png",@"cancletnx.png",@"Refund_pump.png"];
        
        menuId = @[@(SEND_ORDER_POS_MENU),@(SWITCH_TABLE_POS_MENU),
                   @(DISCOUNT_POS_MENU),
                   @(CANCEL_POS_MENU),
                   @(REFUND_POS_MENU),
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

-(CGFloat)RemoveSymbolFromString:(NSString *)stringToRemoveSymbol
{
    NSString *sAmount=[stringToRemoveSymbol stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    CGFloat fsAmount = [self.crmController.currencyFormatter numberFromString:sAmount].floatValue;
    return fsAmount;
}

-(NSString *)htmlForKitchenPrintItemFrom:(NSArray *)kitchenPrintItemArray withRestaurantOrder:(RestaurantOrder *)restaurantOrder
{
    NSString *kitchenPrintItemHtml = [[NSBundle mainBundle] pathForResource:@"food" ofType:@"html"];
    kitchenPrintItemHtml = [NSString stringWithContentsOfFile:kitchenPrintItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$Table NO$$" withString:[NSString stringWithFormat:@"Table No :%@",restaurantOrder.tabelName]];
    
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
    
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"Date: %@",printDate]];
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:[NSString stringWithFormat:@"Time: %@",printTime]];
    
    NSString  *itemHtml = @"";
    NSInteger totalItemQty = 0;
    for (RestaurantItem *restaurantItem in kitchenPrintItemArray)
    {
        NSInteger restaurantItemQty = restaurantItem.quantity.integerValue - restaurantItem.previousQuantity.integerValue;
        
        itemHtml = [itemHtml stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td align=\"left\" valign=\"top\" style=\"width:40;text-align:center; word-break:break-all; padding-right:10px;\" >%ld </td></tr>",restaurantItem.itemName,(long)restaurantItemQty];
        totalItemQty+= restaurantItemQty;
    }
    
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_LIST$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$TOTAL_ITEM$$" withString:[NSString stringWithFormat:@"Total Items :%ld",(long)totalItemQty]];
    
    return kitchenPrintItemHtml;
}

- (void)switchReastaurantOrderWithOrderID:(NSInteger)orderid privateContextObject:(NSManagedObjectContext *)privateContextObject withRestaurantOrderDictionary:(NSDictionary *)restaurantOrderDictionary
{
    if (self.restaurantOrderObjectId == nil) {
        return;
    }
    RestaurantOrder *restaurantOrder = (RestaurantOrder *)[privateContextObject objectWithID:self.restaurantOrderObjectId];
    restaurantOrder.order_id = @(orderid);
    restaurantOrder.totalAmount = @([[restaurantOrderDictionary valueForKey:@"InvoiceTotal"] floatValue]);
    restaurantOrder.totalDiscount = @([[restaurantOrderDictionary valueForKey:@"InvoiceDiscount"] floatValue]);
    restaurantOrder.totalTax = @([[restaurantOrderDictionary valueForKey:@"InvoiceTax"] floatValue]);
    [UpdateManager saveContext:privateContextObject];
}

-(void)switchReastaurantOrder
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSInteger orderid = 0;
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;

    if (reciptArray.count > 0) {
        NSDictionary *dictionaryForInvoice = [self setSubTotalsToDictionaryForReciptArray:reciptArray];
        self.restaurantOrderDictionary = [[NSMutableDictionary alloc]init];
        (self.restaurantOrderDictionary)[@"InvoiceTotal"] = @([self RemoveSymbolFromString:dictionaryForInvoice[@"InvoiceTotal"]]);
        (self.restaurantOrderDictionary)[@"InvoiceSubtotal"] = @([self RemoveSymbolFromString:dictionaryForInvoice[@"InvoiceSubtotal"]]);
        (self.restaurantOrderDictionary)[@"InvoiceDiscount"] = @([self RemoveSymbolFromString:dictionaryForInvoice[@"InvoiceDiscount"]]);
        (self.restaurantOrderDictionary)[@"InvoiceTax"] = @([self RemoveSymbolFromString:dictionaryForInvoice[@"InvoiceTax"]]);
    }

    [self switchReastaurantOrderWithOrderID:orderid privateContextObject:privateContextObject withRestaurantOrderDictionary:self.restaurantOrderDictionary];
}

- (void)fireKitchenPrintsForOrder:(RestaurantOrder *)restaurantOrder
{
    _kitchenprinterResultsetController = nil;
    NSArray *kitchenPrintersections = self.kitchenprinterResultsetController.sections;
    self.kitchenPrinting = [NSMutableArray array];
    NSArray *restaurantItems;
    for(int i = 0 ;i<kitchenPrintersections.count;i++){
        id <NSFetchedResultsSectionInfo> sectionInfo = kitchenPrintersections[i];
        restaurantItems = sectionInfo.objects;
        if (restaurantItems.count == 0) {
            continue;
        }
        RestaurantItem *restaurantItem = restaurantItems.firstObject;
        if (restaurantItem.restaurantItemToItem.itemDepartment.departmentPrinter == nil){
            continue;
        }
        [self printReceiptFromItemList:restaurantItems withRestaurantOrder:restaurantOrder];
    }
}

- (void)updateRestaurantOrderWithOrderID:(NSInteger)orderid privateContextObject:(NSManagedObjectContext *)privateContextObject withRestaurantOrderDictionary:(NSDictionary *)restaurantOrderDictionary
{
    RestaurantOrder *restaurantOrder = (RestaurantOrder *)[privateContextObject objectWithID:self.restaurantOrderObjectId];
    restaurantOrder.order_id = @(orderid);
    restaurantOrder.totalAmount = @([[restaurantOrderDictionary valueForKey:@"InvoiceTotal"] floatValue]);
    restaurantOrder.totalDiscount = @([[restaurantOrderDictionary valueForKey:@"InvoiceDiscount"] floatValue]);
    restaurantOrder.totalTax = @([[restaurantOrderDictionary valueForKey:@"InvoiceTax"] floatValue]);
    
    for (RestaurantItem *restaurantItem in restaurantOrder.restaurantOrderItem.allObjects) {
        if (restaurantItem.isNoPrint.boolValue == TRUE) {
            continue;
        }
        restaurantItem.orderId = @(orderid);
        restaurantItem.isPrinted = @(YES);
        restaurantItem.previousQuantity = @(restaurantItem.quantity.integerValue);
    }
    [UpdateManager saveContext:privateContextObject];
}

-(void)printReceiptFromItemList:(NSArray *)itemList withRestaurantOrder:(RestaurantOrder *)restaurantOrder
{
    NSString *portName     = @"";
    NSString *portSettings = @"";
    [self setPortInfoFromArray:itemList];
    portName     = [RcrController getPortName];
    portSettings = [RcrController getPortSettings];
    KitchenPrinting *kitchenPrinting = [[KitchenPrinting alloc] initWithPortName:portName portSetting:portSettings itemList:itemList restaurantOrder:restaurantOrder withDelegate:self];
    [kitchenPrinting printKitchenReceipt];
    [self.kitchenPrinting addObject:kitchenPrinting];
}

- (void)setPortInfoFromArray:(NSArray *)kitchenPrintItemArray
{
    RestaurantItem *restaurantItem = kitchenPrintItemArray.firstObject;
    NSString *portName = restaurantItem.restaurantItemToItem.itemDepartment.departmentPrinter.printer_ip;
    [RcrPosRestaurantVC setPortName:portName];
    [RcrPosRestaurantVC setPortSettings:array_port[selectedPort]];
}

+ (void)setPortName:(NSString *)m_portName
{
    [RcrController setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [RcrController setPortSettings:m_portSettings];
}

#pragma mark - Printer Function Delegate

-(void)printerTaskDidSuccessWithDevice:(NSString *)device {
    if ([device isEqualToString:@"Printer"]) {
        NSInteger orderid = 0;
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
       
        if (self.restaurantOrderObjectId != nil)
        {
            [self updateRestaurantOrderWithOrderID:orderid privateContextObject:privateContextObject withRestaurantOrderDictionary:self.restaurantOrderDictionary];
        }
        
    }
    else
    {
        [self dropAmountPopUpOpenProcess];
    }
}

-(void)printerTaskDidFailWithDevice:(NSString *)device statusCode:(NSInteger)statusCode message:(NSString *)message timeStamp:(NSDate *)timeStamp {
    if ([device isEqualToString:@"Printer"]) {
        NSString *retryMessage = @"Failed to Kitchen print receipt. Would you like to retry.?";
        [self displayKitchenPrintRetryAlert:retryMessage];
    }
    else {
        [self failToOpenDrawer];
    }
}

-(void)displayKitchenPrintRetryAlert:(NSString *)message
{
    RcrPosRestaurantVC * __weak myWeakReference = self;
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        RestaurantOrder *restaurantOrder = (RestaurantOrder *)[privateContextObject objectWithID:self.restaurantOrderObjectId];
        [myWeakReference fireKitchenPrintsForOrder:restaurantOrder];
    };
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:message buttonTitles:@[@"Cancel",@"Retry"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(NSArray *)filterRestaurantItemForPrintDiplay :(RestaurantOrder *)restaurantOrder
{
    NSPredicate *resturantPrintPredicate = [NSPredicate predicateWithFormat:@"isPrinted = %@ AND isNoPrint = %@ ",@(FALSE),@(FALSE)];
    NSArray *filterRestaurantPrintArray = [restaurantOrder.restaurantOrderItem.allObjects filteredArrayUsingPredicate:resturantPrintPredicate];
    return filterRestaurantPrintArray;
}

#pragma mark - Fetch Kitchen Printer Section

- (NSFetchedResultsController *)kitchenprinterResultsetController {
    
    if (_kitchenprinterResultsetController != nil) {
        return _kitchenprinterResultsetController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RestaurantItem" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"restaurantItemToItem.itemDepartment.departmentPrinter.printer_ip" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSPredicate *resturantPrintPredicate = [NSPredicate predicateWithFormat:@"isPrinted = %@ AND isNoPrint = %@ AND isCanceled = %@ AND itemToOrderRestaurant = %@",@(FALSE),@(FALSE),@(FALSE), [self.managedObjectContext objectWithID:self.restaurantOrderObjectId]];
    fetchRequest.predicate = resturantPrintPredicate;
    
    _kitchenprinterResultsetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"restaurantItemToItem.itemDepartment.departmentPrinter.printer_ip" cacheName:nil];
    
    [_kitchenprinterResultsetController performFetch:nil];
    _kitchenprinterResultsetController.delegate = self;
    
    return _kitchenprinterResultsetController;
}


-(IBAction)sendOrder:(id)sender
{
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
   //NSInteger orderid = [self.updateManager fetchEntityObjectsCounts:@"RestaurantOrder" withManageObjectContext:privateContextObject] + 1 ;
    NSMutableArray *reciptArray = self.reciptDataAryForBillOrder;
    NSDictionary *dictionaryForInvoice = [self setSubTotalsToDictionaryForReciptArray:reciptArray];
    self.restaurantOrderDictionary = [[NSMutableDictionary alloc]init];
    (self.restaurantOrderDictionary)[@"InvoiceTotal"] = @([self RemoveSymbolFromString:dictionaryForInvoice[@"InvoiceTotal"]]);
    (self.restaurantOrderDictionary)[@"InvoiceSubtotal"] = @([self RemoveSymbolFromString:dictionaryForInvoice[@"InvoiceSubtotal"]]);
    (self.restaurantOrderDictionary)[@"InvoiceDiscount"] = @([self RemoveSymbolFromString:dictionaryForInvoice[@"InvoiceDiscount"]]);
    (self.restaurantOrderDictionary)[@"InvoiceTax"] = @([self RemoveSymbolFromString:dictionaryForInvoice[@"InvoiceTax"]]);
   
    RestaurantOrder *restaurantOrder = (RestaurantOrder *)[privateContextObject objectWithID:self.restaurantOrderObjectId];

    [self fireKitchenPrintsForOrder:restaurantOrder];
}

-(void)didRingupRestaurantOrderWithOrderId:(NSNumber *)orderId
{
    //    if (orderId != nil)
    //    {
    //NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //NSEntityDescription *entity = [NSEntityDescription entityForName:@"RestaurantItem" inManagedObjectContext:self.managedObjectContext];
    //[fetchRequest setEntity:entity];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderId == %d", orderId.integerValue];
    //[fetchRequest setPredicate:predicate];
    //NSArray *restaurantItems = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    RestaurantOrder * restaurantOrder = (RestaurantOrder *)[self.managedObjectContext objectWithID:self.restaurantOrderObjectId];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemIndex"
                                                                   ascending:YES ];
    NSArray *sortDescriptors = [@[sortDescriptor]mutableCopy];
    NSArray *restaurantItemSortedArray = [restaurantOrder.restaurantOrderItem.allObjects sortedArrayUsingDescriptors:sortDescriptors];
    for (RestaurantItem *restaurantItem in restaurantItemSortedArray)
    {
        if (restaurantItem.isCanceled.boolValue == FALSE) {
            
            NSMutableDictionary *tempDictionary = [[NSKeyedUnarchiver unarchiveObjectWithData:restaurantItem.itemDetail] mutableCopy];
            tempDictionary[@"RestaurantItemObjectId"] = restaurantItem.objectID;
            [self.reciptDataAry addObject:tempDictionary];
        }
    }
    [self updateBillUI];
    //    }
}

-(IBAction)switchTable:(id)sender
{
    [self diplayRestaurantOrderListView];
}
-(NSString *)setupPosIdentifier
{
    NSString *posIdentifier = @"PosGasMenuVC";
    return posIdentifier;
}

-(NSString *)ItemSwipeEditIdentifier
{
    return @"ItemSwipeEditRestaurantVC";
}

-(NSString *)tempFavouriteViewIdentifierForModule
{
    if ([self.moduleIdentifierString isEqualToString:@"RcrPosRestaurantVC"])
    {
        return @"RestaurantFavouriteCollectionVC";
    }
    else if ([self.moduleIdentifierString isEqualToString:@"RetailRestaurant"])
    {
        return @"RetailRestaurantCollection";
    }
   return @"RetailRestaurantCollection";
}

-(void)loadFavouriteItemForRestaurant
{
    self.restaurentTempfavoriteView.hidden = NO;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    if(favouriteTemp == nil)
    {
        favouriteTemp = [storyBoard instantiateViewControllerWithIdentifier:[self tempFavouriteViewIdentifierForModule]];
        favouriteTemp.favouriteCollectionDelegate = self;
        favouriteTemp.view.frame = self.restaurentTempfavoriteView.bounds;
        [self.restaurentTempfavoriteView addSubview:favouriteTemp.view];
    }
    else
    {
        [favouriteTemp scrollFavouriteCollectionViewToTop];
    }
}

-(CGRect)frameForSwipeEditView
{
    CGRect frameForSwipeEditView = CGRectMake(421, 64, 405,645);
    return frameForSwipeEditView;
}

-(void)didSelectedDepartment:(Department *)selectedDepartment withUICollectionViewCell:(UICollectionViewCell *)collectionCell
{
    self.subDeptCollectionVC.view.hidden = NO;
    self.departments.view.hidden = YES;
    [self animateDepartmentSubDepartmentButton];
    [UIView transitionFromView:self.departments.view toView:self.subDeptCollectionVC.view duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
    }];
    [self.subDeptCollectionVC loadSubDepartmentsOfDepartment:selectedDepartment];
    
    
    [self animateText:@"ITEMS" forLabel:_itemHeaderTitleLabel];
    [self animateImage:@"RetailResto-itemsicon.png" forImageView:_itemHeaderTitleImage];

    if (self.favourite.view.hidden == NO)
    {
        self.subDeptItemCollectionVC.view.hidden = NO;
        [self animateView:_swipeGestureRecognizerView withHideShowFlag:NO];
        [UIView transitionFromView:self.favourite.view toView:self.subDeptItemCollectionVC.view duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            self.favourite.view.hidden = YES;
        }];
    }
    [self.subDeptItemCollectionVC loadItemsOfDepartment:selectedDepartment];
}


-(void)didSelectSubDepartment:(SubDepartment *)selectedSubDepartment
{
    if (self.favourite.view.hidden == NO)
    {
        self.subDeptItemCollectionVC.view.hidden = NO;
        [UIView transitionFromView:self.favourite.view toView:self.subDeptItemCollectionVC.view duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            self.favourite.view.hidden = YES;
            [self animateView:_swipeGestureRecognizerView withHideShowFlag:NO];

        }];
    }

    
    [self.subDeptItemCollectionVC loadItemsOfSubDepartment:selectedSubDepartment];
}
-(void)didChangeFavouriteCount:(NSInteger)count
{
    [self animateText:[NSString stringWithFormat:@"%ld",(long)count] forLabel:_favouriteCountValueLabel];
}
-(void)didChangeDepartmentCount:(NSInteger )count
{
    [self animateText:[NSString stringWithFormat:@"%ld",(long)count] forLabel:_departmentCountValueLabel];
}
-(void)didChangeSubDepartmentItemCount:(NSInteger)subDepartmentItemCount
{
    [self animateText:[NSString stringWithFormat:@"%ld",(long)subDepartmentItemCount] forLabel:_favouriteCountValueLabel];
}

-(void)didChangeSubDepartmentCount:(NSInteger )count
{
    [self animateText:[NSString stringWithFormat:@"%ld",(long)count] forLabel:_subDepartmentCountValueLabel];
}

-(void)didSelectDepartmentFromSubDepartment:(Department *)selectedDepartment // Department selected From SubDepartment view
{
    [super didSelectedDepartment:selectedDepartment withUICollectionViewCell:nil]; // Call method of RcrPosVC
}

-(void)didSelectSubDeptFromItem:(SubDepartment *)selectedSubDepartment department:(Department *)selectedDepartment
{
    departmentOfSubDept = selectedDepartment;
    [super didSelectedSubDepartment:selectedSubDepartment department:selectedDepartment]; // Call method of RcrPosVC
}

- (BOOL)ageVarificationRequiredForItem:(Item *)anItem
{
    BOOL ageVreificationRequired = NO;
    switch (anItem.itm_Type.integerValue ) {
        case 1: // Department
        case 0:
            ageVreificationRequired = anItem.itemDepartment.isAgeApply.integerValue;
            break;
        case 2:
            ageVreificationRequired = departmentOfSubDept.isAgeApply.integerValue;
            break;
        default:
            break;
    }
    return ageVreificationRequired;
}

- (NSString *)ageLimitForItem:(Item *)anItem
{
    NSString *ageValue;
    switch (anItem.itm_Type.integerValue ) {
        case 1: // Department
        case 0:
            ageValue = anItem.itemDepartment.applyAgeDesc;
            break;
        case 2:
            ageValue = departmentOfSubDept.applyAgeDesc;
            break;
        default:
            break;
    }
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"+"];
    NSString *ageLimit = [ageValue stringByTrimmingCharactersInSet:chs];
    return ageLimit;
}

-(void)setReceiptArrayDataWithId :(NSString *)dataId withSalesPrice:(NSString *)salesPrice
{
    if( self.isDepartment==TRUE)
    {
        [self addDepartmentWithId:dataId];
    }
    else if(self.isDepartment == FALSE)
    {
        [super addItemWithItemId:dataId withSalesPrice:salesPrice];
    }
}

#pragma mark- Set Item and Department Detail

- (void)addDepartmentWithId:(NSString *)departmentId
{
    Department *aDepartment;
    if(departmentOfSubDept)
    {
        aDepartment = [self fetchAllDepartments:departmentOfSubDept.deptId.stringValue];
    }
    else
    {
        Item *anItem = [self fetchAllItems:departmentId];
        aDepartment=[self fetchAllDepartments:anItem.deptId.stringValue];
    }
    
    NSMutableDictionary *departmentDictionary = [aDepartment.departmentDictionary mutableCopy];
    if (aDepartment !=nil && departmentDictionary!=nil)
    {
        departmentDictionary[@"ExtraCharge"] = @"0";
        departmentDictionary[@"CheckCashCharge"] = @"0";
        
        BOOL isChargeCashvalue=[departmentDictionary[@"isCheckCash"] boolValue];
        BOOL isExtrachargeValue=[departmentDictionary[@"isExtraCharge"]boolValue];
        
        if (isChargeCashvalue )
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

-(void)didSelectSubDeptItem:(Item *)selectedItem
{
    NSMutableDictionary * itemDictionary = [[NSMutableDictionary alloc]init];
    itemDictionary[@"itemId"] = selectedItem.itemCode.stringValue;
    itemDictionary[@"Type"] = @"Item";
    [self didSelectwithMultipleItemArray:[@[itemDictionary] mutableCopy]];
}

-(CGFloat)tableHeaderHeight
{
    return 75.0;
}

-(NSString *)moduleIdentifier
{
    return self.moduleIdentifierString;
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
            /*[self.enterDepartment setTitle:@"CANCEL" forState:UIControlStateNormal];
            self.departmentAmountTextField.text = @"";
            self.departmentNumpadView.hidden = NO;*/
            
            [self _launchPriceAtPos_Retail:item];

        //    self.departmentNumpadView.center = self.posMenuContainer.center;
         //   [self presentView:self.departmentNumpadView];

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
-(CGRect)popOverPostionForOfflineInvoiceDisplay
{
    CGRect buttonFrame = self.buttonForOfflineInvoiceCount.frame;
    buttonFrame.origin.y += 20;
   // buttonFrame.origin.x += 80;
    return buttonFrame;
}

- (void)animateDepartmentSubDepartmentButton
{
    if (self.departments.view.hidden == NO) {
        return;
    }
    
    CGFloat departmentHeight ;
    CGFloat subDepartmentHeight ;
    if (_departmentButttonView.frame.size.height == 173) {
        departmentHeight = 346;
        subDepartmentHeight = 0;
        
        _subDepartmentTabButton.selected = NO;
        self.departments.view.hidden = NO;
        _departmentTabButton.selected = YES;
        _addDepartmentBtn.selected = NO;

        
        _departmentCountValueLabel.textColor = [UIColor whiteColor];
        _departmentCountNameLabel.textColor = [UIColor whiteColor];
        
        [UIView transitionFromView:self.subDeptCollectionVC.view toView:self.departments.view duration:0.7 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            self.subDeptCollectionVC.view.hidden = YES;

        }];
        
        
        self.favourite.view.hidden = NO;
        [UIView transitionFromView:self.subDeptItemCollectionVC.view toView:self.favourite.view duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            [self animateView:_swipeGestureRecognizerView withHideShowFlag:YES];
            self.subDeptItemCollectionVC.view.hidden = YES;
        }];
        
        [self animateText:@"FAVORITES" forLabel:_itemHeaderTitleLabel];
        [self animateImage:@"RetailResto-favoriteiconforpatch.png" forImageView:_itemHeaderTitleImage];
    }
    else
    {
        _departmentTabButton.selected = NO;
        _subDepartmentTabButton.selected = YES;
        _addDepartmentBtn.selected = YES;
        
        _departmentCountValueLabel.textColor = [UIColor blackColor];
        _departmentCountNameLabel.textColor = [UIColor blackColor];
        
        departmentHeight = 173;
        subDepartmentHeight = 173;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _departmentButttonView.frame = CGRectMake(_departmentButttonView.frame.origin.x, _departmentButttonView.frame.origin.y, _departmentButttonView.frame.size.width, departmentHeight);
        _subDepartmentButttonView.frame = CGRectMake(_subDepartmentButttonView.frame.origin.x,_departmentButttonView.frame.origin.y +departmentHeight, _subDepartmentButttonView.frame.size.width, subDepartmentHeight);
    }];
}

-(IBAction)departmentSubdepartmentButtonAction:(id)sender
{
    [self animateDepartmentSubDepartmentButton];
}

-(void)swipeToDisplayFavouriteView:(UISwipeGestureRecognizer *)swipeGetureRecognizer
{
    [self animateText:@"FAVORITES" forLabel:_itemHeaderTitleLabel];
    [self animateImage:@"RetailResto-favoriteiconforpatch.png" forImageView:_itemHeaderTitleImage];
    self.favourite.view.hidden = NO;
    [UIView transitionFromView:self.subDeptItemCollectionVC.view toView:self.favourite.view duration:0.3 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        [self animateView:_swipeGestureRecognizerView withHideShowFlag:YES];

        self.subDeptItemCollectionVC.view.hidden = YES;
    }];
}
-(void)animateText:(NSString *)text forLabel:(UILabel *)label
{
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [label.layer addAnimation:animation forKey:@"changeTextTransition"];
    label.text = text;
}

-(void)animateImage:(NSString *)imageName forImageView:(UIImageView *)imageView
{
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [imageView.layer addAnimation:animation forKey:@"changeTextTransition"];
    imageView.image = [UIImage imageNamed:imageName];
}
-(void)animateView:(UIView *)view withHideShowFlag:(BOOL)ishide
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:animation forKey:@"ViewHideShowTranstion"];
    view.hidden = ishide;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
