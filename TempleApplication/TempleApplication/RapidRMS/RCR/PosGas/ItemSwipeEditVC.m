//
//  ItemSwipeEditVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemSwipeEditVC.h"
#import "PopOverController.h"
#import "RcrController.h"
#import "RmsDbController.h"
#import "Department+Dictionary.h"
#import "TaxAddPage.h"
#import  "VariationSelectionVC.h"
#import "Item+Dictionary.h"
#import "ItemSwipeEditItemDetail.h"
#import "ItemSwipeEditPriceDetail.h"
#import "ItemSwipeEditRestaurantDetail.h"
#import "RestaurantItem+Dictionary.h"
#import "RemoveTaxMessageVC.h"
#import "RCR_MemoVC.h"

typedef NS_ENUM(NSInteger, RCR_EDIT_ITEM) {
    RCR_ITEM_EDIT,
    RCR_EDIT_ITEM_DETAIL,
    RCR_EDIT_RESTAURANT_VARIATION_DETAIL,
    RCR_EDIT_RESTAURANT_NOPRINT_DETAIL,
    RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL,
    RCR_EDIT_PRICING,
    RCR_EDIT_PRICE_DETAIL,
};

@interface ItemSwipeEditVC () <UIPopoverControllerDelegate,UITextFieldDelegate,ItemTaxEditDelegate,VariationSelectionDelegate,ItemSwipeEditItemDetailDelegate,ItemSwipeEditPriceDetailDelegate,PopOverControllerDelegate,ItemSwipeEditRestaurantDetailDelegate,RemoveTaxPopUpMessageDelegate,RCR_MemoDelegate>
{
    NSArray *editItemEnumArray;
    NSString *itemEditDiscount;
    NSString *itemEditQty;
    UIPopoverController *editPopoverController;

    PopOverController *popOverController;
    RemoveTaxMessageVC *removeTaxMessageVC;
    RCR_MemoVC *rcr_MemoVC;
    TaxAddPage *taxAddPage;
    VariationSelectionVC *variationSelectionVC;

    BOOL isEBTAppliedForItem;
    BOOL isNoPrintForItem;
}
@property (nonatomic,weak) IBOutlet UITableView *editItemTableView;

@property (nonatomic,strong) NSMutableArray *invoiceItemTaxDetail;
@property (nonatomic,strong) NSMutableArray *itemLogArray;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation ItemSwipeEditVC
@synthesize swipeDictionary,isNoPrintForItem;
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
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.editBillAmountCalculator = [[BillAmountCalculator alloc]initWithManageObjectcontext:self.managedObjectContext];

    _itemLogArray = [[NSMutableArray alloc]init];
    swipeDictionary[@"RCR_EDIT_TAX_PROCESS"] = @(RCR_TAX_INITIAL_STEP);
    swipeDictionary[@"TotalTaxPercentage"] = [self totalTaxPercentageForItem];
    swipeDictionary[@"editItemPriceDisplay"] = @([[swipeDictionary valueForKey:@"itemPrice"] floatValue] * [[swipeDictionary valueForKey:@"PackageQty"] floatValue] );
    itemEditQty= [swipeDictionary[@"itemQty"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    isEBTAppliedForItem = [[swipeDictionary valueForKey:@"EBTApplied"] boolValue];
    [self configureEditItemEnumArray];
    [self configureDiscountValueForEdit];
    [self configureEditTaxValue];
    [_editItemTableView reloadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)didEditRestaurantItemSectionAtIndexpath:(NSIndexPath *)indexpath
{
    NSString *editKey = @"";
    RCR_EDIT_ITEM rcrEditItem = [editItemEnumArray[indexpath.row] integerValue];
    switch (rcrEditItem) {
        case RCR_ITEM_EDIT:
            break;
        case RCR_EDIT_PRICE_DETAIL:
            break;
        case RCR_EDIT_PRICING:
            break;
        case RCR_EDIT_ITEM_DETAIL:
            break;
        case RCR_EDIT_RESTAURANT_VARIATION_DETAIL:
            break;
        case RCR_EDIT_RESTAURANT_NOPRINT_DETAIL:
            editKey = @"NoPrintStatus";
            break;
        case RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL:
            editKey = @"isDineIn";
            break;
    }
    [self didEditItemWithEditItemKey:editKey];
}

-(void)didEditItemWithEditItemKey:(NSString *)key;
{
    if ([swipeDictionary[key] boolValue] == TRUE)
    {
        swipeDictionary[key] = @(FALSE);
    }
    else
    {
        swipeDictionary[key] = @(TRUE);
    }
    [_editItemTableView reloadData];
}

-(void)setNoPrintStatus
{
    swipeDictionary[@"NoPrintStatus"] = @(self.isNoPrintForItem);
}

-(void)configureEditTaxValue
{
    NSMutableArray *reciptDataArray = [swipeDictionary valueForKey:@"item"];
    if ([[reciptDataArray valueForKey:@"isTax"] boolValue]==YES)
    {
        if ([self.invoiceItemTaxDetail isKindOfClass:[NSMutableArray class]]) {
            [self.invoiceItemTaxDetail removeAllObjects];
        }
        self.invoiceItemTaxDetail = [swipeDictionary[@"ItemTaxDetail"]mutableCopy];
    }
    else
    {
        if ([self.invoiceItemTaxDetail isKindOfClass:[NSMutableArray class]]) {
            [self.invoiceItemTaxDetail removeAllObjects];
        }
        self.invoiceItemTaxDetail = [swipeDictionary[@"ItemTaxDetail"]mutableCopy];
    }
}
-(void)configureDiscountValueForEdit
{
    NSString *seditDiscount =[NSString stringWithFormat:@"%@",swipeDictionary[@"ItemDiscount"]];
    if([seditDiscount isEqualToString:@"0"])
    {
        itemEditDiscount = @"-NA-";
    }
    else
    {
        if (swipeDictionary[@"PriceAtPos"])
        {
            if ([swipeDictionary[@"ItemBasicPrice"] floatValue]>[swipeDictionary[@"PriceAtPos"] floatValue])
            {
                itemEditDiscount = [NSString stringWithFormat:@"%.2f",[swipeDictionary[@"ItemExternalDiscount"] floatValue]];
            }
            else
            {
               itemEditDiscount = [NSString stringWithFormat:@"%.2f",[swipeDictionary[@"ItemExternalDiscount"] floatValue]];
            }
        }
        else
        {
            itemEditDiscount = [NSString stringWithFormat:@"%.2f",[swipeDictionary[@"ItemExternalDiscount"] floatValue]];
        }
    }
}

-(void)didEditItemWithItemTaxDetail :(NSMutableArray *)taxDetailArray
{
    if ([self.invoiceItemTaxDetail isKindOfClass:[NSMutableArray class]])
    {
        [self.invoiceItemTaxDetail removeAllObjects];
    }
    self.invoiceItemTaxDetail = taxDetailArray;
    NSString *totalTaxPercentage = [self taxPercentagecalculation];
    swipeDictionary[@"TotalTaxPercentage"] = totalTaxPercentage;
    swipeDictionary[@"RCR_EDIT_TAX_PROCESS"] = @(RCR_TAX_INITIAL_STEP);
    [self createInvoiceLogsArray:@"tax" withOperation:@"add" withOldValue:@"0.00%" andNewValue:totalTaxPercentage withMessage:@""];
    NSDictionary *taxDict = @{@"TaxCount" : @(taxDetailArray.count),
                              @"TaxPercentage" : [self taxPercentagecalculation]};
    [Appsee addEvent:kPosItemSwipeAddTaxes withProperties:taxDict];
    
    [self didRemoveViewWithAnimationFromSuperView:taxAddPage.view];
    taxAddPage = nil;
    [_editItemTableView reloadData];
}
-(void)didCancelItemTaxEdit
{
    [self didRemoveViewWithAnimationFromSuperView:taxAddPage.view];
     taxAddPage = nil;
    [_editItemTableView reloadData];
}

-(NSString *) taxPercentagecalculation
{
    float taxperc = 0.0;
    for (int i=0; i<self.invoiceItemTaxDetail.count; i++) {
        taxperc += [[(self.invoiceItemTaxDetail)[i] valueForKey:@"TaxPercentage"] floatValue];
    }
    NSString *staxTotper=[NSString stringWithFormat:@"%.2f%@",taxperc,@" %"];
    return staxTotper;
}

-(void)didCancelEditItemPopOver
{
    [self didRemoveViewWithAnimationFromSuperView:popOverController.view];
    popOverController = nil;
}


-(NSString *)totalTaxPercentageForItem
{
    NSMutableArray *recipttaxArray = [swipeDictionary valueForKey:@"ItemTaxDetail"];
    NSString *sTaxperc=@"0.00 %";
    if([recipttaxArray isKindOfClass:[NSMutableArray class]])
    {
        sTaxperc=[NSString stringWithFormat:@"%.2f%@",[[recipttaxArray valueForKeyPath:@"@sum.TaxPercentage"]floatValue],@" %"];
    }
    return sTaxperc;
}

-(BOOL)isVariationAvailableForItem
{
    BOOL isVariationAvailableForItem = FALSE;
    
    if (swipeDictionary[@"InvoiceVariationdetail"])
    {
        NSArray *variation = swipeDictionary[@"InvoiceVariationdetail"];
        if ([variation isKindOfClass:[NSArray class]] && variation.count > 0)
        {
            isVariationAvailableForItem = TRUE;
        }
    }
    return isVariationAvailableForItem;

}

- (void)configureRestaurantEditItemEnumArray
{
    if ([self isVariationAvailableForItem])
    {
        editItemEnumArray = @[@(RCR_ITEM_EDIT),@(RCR_EDIT_ITEM_DETAIL),@(RCR_EDIT_RESTAURANT_VARIATION_DETAIL),@(RCR_EDIT_RESTAURANT_NOPRINT_DETAIL),@(RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL),@(RCR_EDIT_PRICING),@(RCR_EDIT_PRICE_DETAIL)];
    }
    else
    {
        editItemEnumArray = @[@(RCR_ITEM_EDIT),@(RCR_EDIT_ITEM_DETAIL),@(RCR_EDIT_RESTAURANT_NOPRINT_DETAIL),@(RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL),@(RCR_EDIT_PRICING),@(RCR_EDIT_PRICE_DETAIL)];
    }
    [self setNoPrintStatus];
}

-(void)configureEditItemEnumArray
{
    if ([self.moduleIdentifier isEqualToString:@"RcrPosRestaurantVC"])
    {
        [self configureRestaurantEditItemEnumArray];
    }
    else
    {
        editItemEnumArray = @[@(RCR_ITEM_EDIT),@(RCR_EDIT_ITEM_DETAIL),@(RCR_EDIT_PRICING),@(RCR_EDIT_PRICE_DETAIL)];
    }
}

-(void)didUpdateStateOfTaxProcess
{
    BOOL hasRights = [UserRights hasRights:UserRightTax];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have tax rights. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    if ([[swipeDictionary valueForKey:@"HouseChargeAmount"] floatValue] > 0.00 || [[swipeDictionary valueForKey:@"Barcode"] isEqualToString:@"GAS"])
    {
        return;
    }
    
    if ([[swipeDictionary valueForKey:@"Barcode"] isEqualToString:@"GAS"] )
    {
        return;
    }
    
    if ([[[self.swipeDictionary valueForKey:@"item"] valueForKey:@"isDeduct"]boolValue] == YES )
    {
        return;
    }
    
    RCR_EDIT_TAX_PROCESS rcrEditNextTaxProcess ;
    RCR_EDIT_TAX_PROCESS rcrEditPriviousTaxProcess = [[swipeDictionary valueForKey:@"RCR_EDIT_TAX_PROCESS"] integerValue];
  
    switch (rcrEditPriviousTaxProcess)
    {
        case RCR_TAX_INITIAL_STEP:
            rcrEditNextTaxProcess = RCR_TAX_REMOVE_STEP;
        {
            if([[swipeDictionary valueForKey:@"ItemTaxDetail"] isKindOfClass:[NSMutableArray class]]){
                if (popOverController != nil)
                {
                    [self didRemoveViewFromSuperView:popOverController.view];
                    popOverController = nil;
                }
                
                if (taxAddPage != nil) {
                    [UIView transitionWithView:taxAddPage.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        taxAddPage.view.center = self.view.superview.center;
                    } completion:^(BOOL finished) {
                        [taxAddPage.view removeFromSuperview];
                    }];
                }
                if (rcr_MemoVC != nil)
                {
                    [self didRemoveViewFromSuperView:rcr_MemoVC.view];
                    rcr_MemoVC = nil;
                }
                
                if([[swipeDictionary valueForKey:@"ItemTaxDetail"] count]>0){
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
                    removeTaxMessageVC = [storyBoard instantiateViewControllerWithIdentifier:@"RemoveTaxMessageVC"];
                    removeTaxMessageVC.removeTaxPopUpMessageDelegate = self;
                    removeTaxMessageVC.view.center = self.view.superview.center;
                    [self.view.superview addSubview:removeTaxMessageVC.view];
                    [self.view.superview bringSubviewToFront:self.view];
                    [self didAddViewWithAnimationToSuperView:removeTaxMessageVC.view];
                }

            }
    
        }

        break;
        case RCR_TAX_REMOVE_STEP:
            rcrEditNextTaxProcess = RCR_TAX_ADD_STEP;
        {
            if (popOverController != nil)
            {
                [self didRemoveViewFromSuperView:popOverController.view];
                popOverController = nil;
            }
            if (removeTaxMessageVC != nil) {
                [self didRemoveViewFromSuperView:removeTaxMessageVC.view];
            }
            if (rcr_MemoVC != nil)
            {
                [self didRemoveViewFromSuperView:rcr_MemoVC.view];
                rcr_MemoVC = nil;
            }
                taxAddPage = [[TaxAddPage alloc] initWithNibName:@"TaxAddPage" bundle:nil];
                taxAddPage.itemTaxEditDelegate = self;
                taxAddPage.view.center = self.view.superview.center;
                [self.view.superview addSubview:taxAddPage.view];
                [self.view.superview bringSubviewToFront:self.view];
                [self didAddViewWithAnimationToSuperView:taxAddPage.view];

            
        }
            break;
        case RCR_TAX_ADD_STEP:
            rcrEditNextTaxProcess = RCR_TAX_INITIAL_STEP;
            break;
        default:
            break;
    }
    swipeDictionary[@"RCR_EDIT_TAX_PROCESS"] = @(rcrEditNextTaxProcess);
    [_editItemTableView reloadData];
}

-(void)didUpdateEBTStatus
{
    swipeDictionary[@"EBTApplied"] = [NSNumber numberWithBool:![[swipeDictionary valueForKey:@"EBTApplied"] boolValue]];
    
  if(  [[swipeDictionary valueForKey:@"HouseChargeAmount"] floatValue] > 0.00)
  {
      return;
  }
    
    if ([[swipeDictionary valueForKey:@"EBTApplied"] boolValue] == FALSE)
    {
        Item *anItem = [self fetchAllItems:swipeDictionary[@"itemId"]];
        NSMutableArray *taxDetail = [self.editBillAmountCalculator fetchTaxDetailForItem:anItem];
        if (taxDetail != nil) {
        swipeDictionary[@"ItemTaxDetail"] = taxDetail;
        self.invoiceItemTaxDetail = [swipeDictionary[@"ItemTaxDetail"]mutableCopy];

        }
    }
    else{
        swipeDictionary[@"ItemTaxDetail"] = @"";
        self.invoiceItemTaxDetail = nil;

    }
    [_editItemTableView reloadData];

}
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





-(void)didsendRemoveTaxMessage :(NSString *)message{
    [self removeTaxWithMessage:message];
    [self didRemoveViewWithAnimationFromSuperView:removeTaxMessageVC.view];
   // removeTaxMessageVC = nil;
}
-(void)didCancelRemoveTaxPopup
{
    [self didRemoveViewWithAnimationFromSuperView:removeTaxMessageVC.view];
   // removeTaxMessageVC = nil;
}

-(void)removeTaxWithMessage:(NSString *)message{
    
    [Appsee addEvent:kPosItemSwipeRemoveTaxes];
    NSString *strOldValue = [swipeDictionary valueForKey:@"TotalTaxPercentage"];
    if ([self.invoiceItemTaxDetail isKindOfClass:[NSMutableArray class]]) {
        [self.invoiceItemTaxDetail removeAllObjects];
    }
    
    swipeDictionary[@"TotalTaxPercentage"] = @"0.00";
    if(![strOldValue isEqualToString:@"0.00 %"]){
        [self createInvoiceLogsArray:@"tax" withOperation:@"remove" withOldValue:strOldValue andNewValue:@"0.00 %" withMessage:message];
    }
    
    swipeDictionary[@"RCR_EDIT_TAX_PROCESS"] = @(RCR_TAX_REMOVE_STEP);
    [_editItemTableView reloadData];

}

-(void)didEditItemWithItemPrice:(NSString *)itemPrice
{
    NSString *sAmount = [NSString stringWithFormat:@"%f",[self.rmsDbController removeCurrencyFomatter:itemPrice]];
    if (sAmount.length > 0)
    {
        NSString *strOldValue = [NSString stringWithFormat:@"%f",[swipeDictionary[@"itemPrice"] floatValue] *  [swipeDictionary[@"PackageQty"] floatValue]];
          NSNumber *itemUpdatedPrice = @(sAmount.floatValue);
       
        BOOL priceEdited =[self checkItemPriceEdited:self.swipeDictionary itemUpdatedPrice:itemUpdatedPrice];
        if (priceEdited)
        {
            [self createInvoiceLogsArray:@"price" withOperation:@"change" withOldValue:strOldValue andNewValue:itemUpdatedPrice.stringValue withMessage:@""];
        }
        BOOL isRest = FALSE;
        NSRange searchResult = [strOldValue rangeOfString:@"-"];
        if (searchResult.location != NSNotFound)
        {
            isRest = TRUE;
        }

        if((strOldValue.floatValue <= 0 && isRest == TRUE) || [[[self.swipeDictionary valueForKey:@"item"] valueForKey:@"isDeduct"]boolValue] == YES)
        {
            float entAmount = sAmount.floatValue * -1;
            NSString *tmpAmount = [NSString stringWithFormat:@"%f",entAmount];
            swipeDictionary[@"editItemPriceDisplay"] = @(tmpAmount.floatValue);
        }
        else
        {
            swipeDictionary[@"editItemPriceDisplay"] = @(sAmount.floatValue);
        }
    }
    [self didRemoveViewWithAnimationFromSuperView:popOverController.view];
    popOverController = nil;

    [_editItemTableView reloadData];
}
-(void)didRemoveItemDiscount
{
    BOOL hasRights = [UserRights hasRights:UserRightDiscount];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to remove discount. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    [Appsee addEvent:kPosItemSwipeRemoveDiscount];
    [self.rmsDbController playButtonSound];
    NSString *strDiscount = @"0";
    if ((self.swipeDictionary)[@"ItemWiseDiscountValue"]) {
        strDiscount = [self.swipeDictionary valueForKey:@"ItemWiseDiscountValue"];
    }
    
    itemEditDiscount = @"-NA-";
    if(! [itemEditDiscount isEqualToString:@"-NA-"])
    {
        [self createInvoiceLogsArray:@"discount" withOperation:@"remove" withOldValue:strDiscount andNewValue:@"0.00" withMessage:@""];
    }
}

-(void)didEditItemWithItemQty:(NSString *)itemQty
{
    NSNumber *qty = @([swipeDictionary[@"PackageQty"] intValue] * itemQty.intValue);
    
    NSString *oldQuantity = [swipeDictionary[@"itemQty"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *editedQuantity = [qty.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![oldQuantity isEqualToString:editedQuantity]) {
        swipeDictionary[@"itemQty"] = [NSString stringWithFormat:@"%@",qty.stringValue];
        itemEditQty = qty.stringValue;
    }
    
    [self didRemoveViewWithAnimationFromSuperView:popOverController.view];
    popOverController = nil;
    
    [_editItemTableView reloadData];
    
    
}

-(void)didRemoveViewWithAnimationFromSuperView:(UIView *)view
{
    [UIView transitionWithView:view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        view.center = self.view.superview.center;
        if ([self isViewPostionIsInCenter] == FALSE) {
            self.view.center = self.view.superview.center;
        }
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}


-(void)didRemoveViewFromSuperView:(UIView *)view
{
    [UIView transitionWithView:view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        view.center = self.view.superview.center;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

-(void)didAddViewWithAnimationToSuperView:(UIView *)view
{
      [UIView transitionWithView:view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        view.frame = CGRectMake(view.frame.origin.x + self.view.frame.size.width - 100 ,view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        if ([self isViewPostionIsInCenter] == TRUE) {
            self.view.frame = CGRectMake(self.view.frame.origin.x - 60 ,self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        }
    } completion:^(BOOL finished) {
    }];
}

-(BOOL)isViewPostionIsInCenter
{
    BOOL IsviewPostionIsInCenter = FALSE;
    CGFloat superViewWidth = self.view.superview.frame.size.width;
    
    CGFloat viewPostionIsInCenter = ((superViewWidth - self.view.frame.size.width )/ 2) - self.view.frame.origin.x;
    if (viewPostionIsInCenter > 1) {
        IsviewPostionIsInCenter = FALSE;
    }
    else
    {
        IsviewPostionIsInCenter = TRUE;
    }
    return IsviewPostionIsInCenter;
}


- (void)didPresentEditPriceQtyPopup:(RCR_EDIT_PRICE_DETAIL_TEXTFIELD)textField
{
    if (popOverController != nil)
    {
        NSString *popOverHeaderTitle = @"";
        if (textField == RCR_EDIT_PRICE_TEXTFIELD)
        {
            popOverController.isInvoice=YES;
            popOverController.invoiceString = @"Invoice";
            popOverController.isPriceEdited = YES;
            popOverHeaderTitle = @"ITEM PRICE";
        }
        else
        {
            popOverController.isInvoice = FALSE;
            popOverController.invoiceString = @"";
            popOverController.isPriceEdited = FALSE;
            popOverHeaderTitle = @"QUANTITY";
        }
        [popOverController updateHeaderTitleLabelWithText:popOverHeaderTitle];
    }
    else
    {
        popOverController = [[PopOverController alloc] initWithNibName:@"PopOverController" bundle:nil];
        NSString *popOverHeaderTitle = @"";
        
        if (textField == RCR_EDIT_PRICE_TEXTFIELD)
        {
            popOverController.isInvoice=YES;
            popOverController.invoiceString = @"Invoice";
            popOverController.isPriceEdited = YES;
            popOverHeaderTitle = @"ITEM PRICE";
        }
        else
        {
            if([[swipeDictionary valueForKey:@"Barcode"] isEqualToString:@"GAS"]){
                return;
            }
            popOverController.isInvoice = FALSE;
            popOverController.invoiceString = @"";
            popOverController.isPriceEdited = FALSE;
            popOverHeaderTitle = @"QUANTITY";
        }
        popOverController.itemHeaderTitle = popOverHeaderTitle;
        
        popOverController.popOverControllerDelegate = self;
        popOverController.view.center = self.view.superview.center;
        [self.view.superview addSubview:popOverController.view];
        [self.view.superview bringSubviewToFront:self.view];
        [self didAddViewWithAnimationToSuperView:popOverController.view];
    }
}

-(void)didShowPopOverControllerForTextField:(RCR_EDIT_PRICE_DETAIL_TEXTFIELD )textField withTextField:(UITextField *)editedTextField
{
    if (textField == RCR_EDIT_QTY_TEXTFIELD)
    {
        NSMutableArray *reciptDataArray = [swipeDictionary valueForKey:@"item"];
        
        if ([[reciptDataArray valueForKey:@"isCheckCash"] boolValue] == YES)
        {
            return;
        }
        
        if ([[swipeDictionary valueForKey:@"Barcode"] isEqualToString:@"GAS"])
        {
            return;
        }

        
        if ([[swipeDictionary valueForKey:@"HouseChargeAmount"] floatValue] > 0.00) {
            return;
        }
        
        
//        if ([[swipeDictionary valueForKey:@"IsRefundFromInvoice"]  isEqual: @(1)])
//        {
//            return;
//        }
    }
    
    if (textField == RCR_EDIT_PRICE_TEXTFIELD)
    {
        BOOL hasRights = [UserRights hasRights:UserRightChangePrice];
        if (!hasRights) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to change price. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        NSMutableArray *reciptDataArray = [swipeDictionary valueForKey:@"item"];
        
        if ([[reciptDataArray valueForKey:@"isCheckCash"] boolValue] == YES)
        {
            return;
        }
        if ([[swipeDictionary valueForKey:@"HouseChargeAmount"] floatValue] > 0.00) {
            return;
        }
        
//        if ([[swipeDictionary valueForKey:@"IsRefundFromInvoice"]  isEqual: @(1)])
//        {
//            return;
//        }
        
    }
    
    if (removeTaxMessageVC != nil) {
        [self didRemoveViewFromSuperView:removeTaxMessageVC.view];
    }

    if (taxAddPage != nil) {
        [self didRemoveViewFromSuperView:taxAddPage.view];
        taxAddPage = nil;
    }
    
    if (textField == RCR_EDIT_MEMO_TEXTFIELD) {
        if (rcr_MemoVC != nil)
        {
            [self didRemoveViewFromSuperView:rcr_MemoVC.view];
            rcr_MemoVC = nil;
        }
        
        if (popOverController != nil)
        {
            [self didRemoveViewFromSuperView:popOverController.view];
            popOverController = nil;
        }

        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
        rcr_MemoVC = [storyBoard instantiateViewControllerWithIdentifier:@"RCR_Edit_Item_MemoVC"];
        rcr_MemoVC.rcr_MemoDelegate = self;
        rcr_MemoVC.isMemoFromEditState = TRUE;
        rcr_MemoVC.view.center = self.view.superview.center;
        [self.view.superview addSubview:rcr_MemoVC.view];
        [self.view.superview bringSubviewToFront:self.view];
        [self didAddViewWithAnimationToSuperView:rcr_MemoVC.view];

    }
    else
    {
        if (rcr_MemoVC != nil)
        {
            [self didRemoveViewFromSuperView:rcr_MemoVC.view];
            rcr_MemoVC = nil;
        }
        
        [self didPresentEditPriceQtyPopup:textField];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return editItemEnumArray.count;
}

-(ItemSwipeEditItemDetail *)configureItemDetailWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemSwipeEditItemDetail *itemSwipeEditItemDetail = [tableView dequeueReusableCellWithIdentifier:@"ItemSwipeEditItemDetail"];
    itemSwipeEditItemDetail.itemSwipeEditItemDetailDelegate = self;
    [itemSwipeEditItemDetail configureItemDetailWithDictionary:swipeDictionary];
    itemSwipeEditItemDetail.backgroundColor = [UIColor clearColor];
    return itemSwipeEditItemDetail;
}
-(ItemSwipeEditPriceDetail *)configurePricingDetailWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strIdentifier = @"ItemSwipeEditPriceDetail";
    if (isEBTAppliedForItem ==TRUE)
    {
        strIdentifier = @"ItemSwipeEditPriceWithEBT";
    }
    ItemSwipeEditPriceDetail *itemSwipeEditPriceDetail = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    itemSwipeEditPriceDetail.backgroundColor = [UIColor clearColor];
    itemSwipeEditPriceDetail.itemSwipeEditPriceDetailDelegate = self;
    [itemSwipeEditPriceDetail configureItemPriceDetail:swipeDictionary];
    return itemSwipeEditPriceDetail;
}
-(ItemSwipeEditRestaurantDetail *)configureItemSwipeEditRestaurantDetailWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withCellLabelText:(NSString *)cellLabelText withCellType:(RCR_EDIT_ITEM )rcrEditItem
{
    ItemSwipeEditRestaurantDetail *itemSwipeEditRestaurantDetail = [tableView dequeueReusableCellWithIdentifier:@"ItemSwipeEditRestaurantDetail"];
    itemSwipeEditRestaurantDetail.cellLabelText.text = cellLabelText;
    itemSwipeEditRestaurantDetail.itemSwipeEditRestaurantDetailDelegate = self;
    itemSwipeEditRestaurantDetail.currentIndexpathForRestaurant = indexPath;
    itemSwipeEditRestaurantDetail.backgroundColor = [UIColor clearColor];
    BOOL displayPrintStatus = TRUE;
    if (rcrEditItem == RCR_EDIT_RESTAURANT_NOPRINT_DETAIL)
    {
        displayPrintStatus = FALSE;
        [itemSwipeEditRestaurantDetail updatePrintStatus:swipeDictionary diplayPrintButtonForCell:displayPrintStatus];
    }
    else if (rcrEditItem == RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL)
    {
        [itemSwipeEditRestaurantDetail updateDineInStatus:swipeDictionary];
    }
    
    return itemSwipeEditRestaurantDetail;
}

-(void)setUpCell:(UITableViewCell * )cell
{
    UIView *backGroundView = [[UIView alloc]initWithFrame:cell.bounds];
    cell.backgroundView = backGroundView;
    cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    UIImageView *selectedbackGroundView = [[UIImageView alloc]initWithFrame:cell.bounds];
    cell. selectedBackgroundView = selectedbackGroundView;
    cell.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float headerHeight = 60;
    RCR_EDIT_ITEM rcrEditItem = [editItemEnumArray[indexPath.row] integerValue];
    switch (rcrEditItem) {
        case RCR_ITEM_EDIT:
             headerHeight = 1;
            break;
        case RCR_EDIT_PRICE_DETAIL:
            headerHeight = 270;
            break;
        case RCR_EDIT_PRICING:
            headerHeight = 35;
            break;
        case RCR_EDIT_ITEM_DETAIL:
            headerHeight = 172;
            break;
        case RCR_EDIT_RESTAURANT_VARIATION_DETAIL:
            headerHeight = 50;
            break;
        case RCR_EDIT_RESTAURANT_NOPRINT_DETAIL:
            headerHeight = 50;
            break;
        case RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL:
            headerHeight = 50;
            break;
    }
       return headerHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BaseCell"];
   // cell.backgroundColor = [UIColor colorWithRed:194 green:204 blue:205 alpha:1.0];
    [self setUpCell:cell];

    RCR_EDIT_ITEM rcrEditItem = [editItemEnumArray[indexPath.row] integerValue];
    switch (rcrEditItem) {
        case RCR_ITEM_EDIT:
            cell.textLabel.text = @"";
            break;
        case RCR_EDIT_ITEM_DETAIL:
            return [self configureItemDetailWithTableView:tableView cellForRowAtIndexPath:indexPath];
            break;
        case RCR_EDIT_PRICING:
            cell.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:242.0/255.0 blue:243.0/255.0 alpha:1.0];
            cell.textLabel.text = @"PRICING";
            cell.textLabel.font = [UIFont fontWithName:@"Lato" size:17.0];
            break;
       
        case RCR_EDIT_PRICE_DETAIL:
            return [self configurePricingDetailWithTableView:tableView cellForRowAtIndexPath:indexPath];
            break;
        case RCR_EDIT_RESTAURANT_VARIATION_DETAIL:
            return [self configureItemSwipeEditRestaurantDetailWithTableView:tableView cellForRowAtIndexPath:indexPath withCellLabelText:@"Variation" withCellType:RCR_EDIT_RESTAURANT_VARIATION_DETAIL];
            break;
        case RCR_EDIT_RESTAURANT_NOPRINT_DETAIL:
            return [self configureItemSwipeEditRestaurantDetailWithTableView:tableView cellForRowAtIndexPath:indexPath withCellLabelText:@"No Print" withCellType:RCR_EDIT_RESTAURANT_NOPRINT_DETAIL];
            break;
        case RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL:
            return [self configureItemSwipeEditRestaurantDetailWithTableView:tableView cellForRowAtIndexPath:indexPath withCellLabelText:@"Dine In" withCellType:RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL];
            break;
            
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCR_EDIT_ITEM rcrEditItem = [editItemEnumArray[indexPath.row] integerValue];

    if (rcrEditItem == RCR_EDIT_RESTAURANT_VARIATION_DETAIL) {
        [self displayVariationView];
    }
    if (rcrEditItem == RCR_EDIT_RESTAURANT_NOPRINT_DETAIL) {
        [self didEditItemWithEditItemKey:@"NoPrintStatus"];
    }
    if (rcrEditItem == RCR_EDIT_RESTAURANT_DINE_IN_TO_GO_DETAIL) {
        [self didEditItemWithEditItemKey:@"isDineIn"];
    }
}

-(IBAction)deleteItem:(id)sender
{
    [self removeAllSubViews];

    [self.view removeFromSuperview];
    [self.itemSwipeEditDelegate didRemoveItem];
  
    NSString *strOldValue = [NSString stringWithFormat:@"%f",[swipeDictionary[@"itemPrice"] floatValue]];

    [self createInvoiceLogsArray:@"item" withOperation:@"remove" withOldValue:strOldValue andNewValue:strOldValue withMessage:@""];
    for(NSDictionary *dictInvLog in _itemLogArray){
        [self.crmController.reciptItemLogDataAry addObject:dictInvLog];
    }
    [_itemLogArray removeAllObjects];
}

-(void)removeAllSubViews
{
    for (UIView *view in self.view.superview.subviews) {
        [view removeFromSuperview];
    }
}

-(IBAction)cancelEditView:(id)sender
{
    [self removeAllSubViews];
    [self.view removeFromSuperview];
    [self.itemSwipeEditDelegate didCancelEditSwipe];
}
- (Item*)fetchItemForVariation :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
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


-(void)displayVariationView
{
    Item *item = [self fetchItemForVariation:[swipeDictionary valueForKey:@"itemId"]];
    [self showVariationSelectionWithDetail:item];
}
-(void)showVariationSelectionWithDetail :(Item *)item
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    variationSelectionVC = [storyBoard instantiateViewControllerWithIdentifier:@"VariationSelectionVC"];
    variationSelectionVC.modalPresentationStyle = UIModalPresentationFullScreen;
    variationSelectionVC.itemforVariation = item;
    variationSelectionVC.variationSelectionDelegate = self;
    variationSelectionVC.selectedVariance = [swipeDictionary valueForKey:@"InvoiceVariationdetail"];
    variationSelectionVC.view.frame = self.view.superview.bounds;
    [self.view.superview addSubview:variationSelectionVC.view];
}

-(void)didSelectItemWithVariationDetail :(NSArray *)variationDetail withItem:(Item *)item
{
    
   // [self createInvoiceLogsArray:@"tax" withOperation:@"remove" withOldValue:strOldValue andNewValue:@"0.00 %"];

    if (![self doArraysContainTheSameObjects:variationDetail withArray:[swipeDictionary valueForKey:@"InvoiceVariationdetail"]]) {
        
        [self createInvoiceLogsArray:@"variation" withOperation:@"change" withOldValue:[self getVariationValue:[swipeDictionary valueForKey:@"InvoiceVariationdetail"]] andNewValue:[self getVariationValue:variationDetail] withMessage:@""];
    }
    swipeDictionary[@"InvoiceVariationdetail"] = variationDetail;
    [variationSelectionVC.view removeFromSuperview];

}

-(NSString *)getVariationValue:(NSArray *)arrayVariation{
    
    NSString *strold = @"";
    NSMutableString *strResult = [NSMutableString string];
    if(arrayVariation.count>0)
    {
        for (int i=0; i<arrayVariation.count; i++)
        {
            NSMutableArray *variation = arrayVariation[i];
            NSString *ch = [NSString stringWithFormat:@"%@ - %.2f",[variation valueForKey:@"VariationItemName"],[[variation valueForKey:@"Price"]floatValue]];
            [strResult appendFormat:@"%@,", ch];
        }
        strold = [strResult substringToIndex:strResult.length-1];
    }
    else
    {
        strold = @"";
    }
    
    return strold;

}

-(BOOL)doArraysContainTheSameObjects:(NSArray *)firstArray withArray:(NSArray *)secondArray {
    BOOL arraysContainTheSameObjects = YES;
    
    for (id myObject in firstArray) {
        if (![secondArray containsObject:myObject]) {
            arraysContainTheSameObjects = NO;
            break;
        }
    }
    return arraysContainTheSameObjects;
}

-(void)didCancelVariationSelectionProcess
{
    [variationSelectionVC.view removeFromSuperview];
}
-(void)createInvoiceLogsArray:(NSString *)strfieldname withOperation:(NSString *)strOperation withOldValue:(NSString *)strOldValue andNewValue:(NSString *)strNewValue withMessage:(NSString *)reason{
    
    NSMutableDictionary *dictInvoiceLog = [[NSMutableDictionary alloc]init];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    dictInvoiceLog[@"Id"] = @"0";
    dictInvoiceLog[@"RegisterId"] = @"0";
    
    dictInvoiceLog[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    dictInvoiceLog[@"ZId"] = (self.rmsDbController.globalDict)[@"ZId"];
    
    dictInvoiceLog[@"InvoiceNo"] = @"0";
    
    dictInvoiceLog[@"TimeStamp"] = strDateTime;
    
    dictInvoiceLog[@"ItemCode"] = [self.swipeDictionary valueForKey:@"itemId"];
    dictInvoiceLog[@"FieldName"] = strfieldname;
    
    dictInvoiceLog[@"Operation"] = strOperation;

    dictInvoiceLog[@"OldValue"] = strOldValue;
    dictInvoiceLog[@"NewValue"] = strNewValue;
    dictInvoiceLog[@"Reason"] = reason;

    [_itemLogArray addObject:dictInvoiceLog];
 
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- ItemEdit Methods

- (BOOL)checkItemPriceEdited:(NSMutableDictionary *)tempDict itemUpdatedPrice:(NSNumber *)itemUpdatedPrice
{
    BOOL itemPriceEdited = FALSE;
    
    CGFloat itemUpdatedPriceFloatValue = itemUpdatedPrice.floatValue;
    CGFloat itemPriceFloatValue = [tempDict[@"itemPrice"] floatValue] * [tempDict[@"PackageQty"] floatValue];

    if (itemUpdatedPriceFloatValue != itemPriceFloatValue)
    {
        tempDict[@"IsPriceEdited"] = @"1";
        itemPriceEdited = TRUE;
        // Code for No discount is apply For edit price
        /*[tempDict setObject:@"0" forKey:@"ItemDiscount"];
         float discountPercetage = 0;
         [tempDict setValue:[NSString stringWithFormat:@"%.2f",discountPercetage] forKey:@"ItemDiscountPercentage"];*/
    }
    return itemPriceEdited;
}

-(CGFloat )calculateTotalForVariationDictionary :(NSDictionary *)dictionary
{
    CGFloat totalVarionCost = 0.0;
    
    if (dictionary[@"InvoiceVariationdetail"])
    {
        totalVarionCost = [[(NSArray *)dictionary[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.VariationBasicPrice"] floatValue] ;
    }
    return totalVarionCost;
}


-(void)removeVariationDiscountForDictionary :(NSMutableDictionary *)variationDictionary
{
    if (variationDictionary[@"InvoiceVariationdetail"])
    {
        NSMutableArray *variation = variationDictionary[@"InvoiceVariationdetail"];
        for (NSMutableDictionary *variationDictionary in variation)
        {
            [variationDictionary setValue:variationDictionary[@"VariationBasicPrice"] forKey:@"Price"];
        }
    }
}


- (void)edit_ItemDiscountDetail:(NSMutableDictionary *)tempDict itemprice:(float)itemprice itemTxtInvPrice:(NSNumber *)itemTxtInvPrice editDiscount:(NSString *)editDiscount
{
    if([editDiscount isEqualToString:@"-NA-"])
    {
        tempDict[@"ItemDiscount"] = @"0";
        tempDict[@"ItemDiscountPercentage"] = @(0);
        tempDict[@"ItemWiseDiscountValue"] = @"0";
        tempDict[@"ItemWiseDiscountType"] = @"Amount";
        [self removeVariationDiscountForDictionary:tempDict];
    }
    
    
//    if ([[tempDict objectForKey:@"IsPriceEdited"] isEqualToString:@"1"])
//    {
//        if ([[tempDict objectForKey:@"ItemBasicPrice"] floatValue] > [itemTxtInvPrice floatValue])
//        {
//            if (![[[tempDict  valueForKey:@"item"]objectForKey:@"isCheckCash"] boolValue]==YES)
//            {
//                [tempDict setObject:[NSString stringWithFormat:@"%f",[itemTxtInvPrice floatValue]] forKey:@"PriceAtPos"];
//                [tempDict setObject:@"0" forKey:@"IsQtyEdited"];
//                
//                float ItemDisCount=[[tempDict objectForKey:@"ItemBasicPrice"] floatValue]-[itemTxtInvPrice floatValue];
//                [tempDict setObject:[NSString stringWithFormat:@"%f",ItemDisCount] forKey:@"ItemDiscount"];
//                CGFloat totalVariationForItem = [self calculateTotalForVariationDictionary:tempDict];
//
//                float totalItemPrice = [[tempDict objectForKey:@"ItemBasicPrice"] floatValue] + totalVariationForItem;
//                
//                float  totalItemPercenatge = ItemDisCount / totalItemPrice *100;
//                
//                tempDict[@"ItemDiscountPercentage"] = @(totalItemPercenatge);
//            }
//        }
//        else if ([[tempDict objectForKey:@"ItemBasicPrice"] floatValue] < [itemTxtInvPrice floatValue])
//        {
//            [tempDict setObject:[NSString stringWithFormat:@"%f",[itemTxtInvPrice floatValue]] forKey:@"PriceAtPos"];
//            [tempDict setObject:@"0" forKey:@"IsQtyEdited"];
//            
//        }
//        else if ([[tempDict objectForKey:@"ItemBasicPrice"] floatValue] == [itemTxtInvPrice floatValue])
//        {
//            [tempDict removeObjectForKey:@"PriceAtPos"];
//        }
//    }
    
    
    if ([[tempDict objectForKey:@"IsPriceEdited"] isEqualToString:@"1"])
    {
        
        CGFloat itemBasicPrice = [[tempDict objectForKey:@"ItemBasicPrice"] floatValue] * [[tempDict objectForKey:@"PackageQty"] floatValue];
        
        if (![[[tempDict valueForKey:@"item"]objectForKey:@"isCheckCash"] boolValue]== YES)
        {
            if (itemBasicPrice == [itemTxtInvPrice floatValue])
            {
                [tempDict setObject:@"1" forKey:@"IsQtyEdited"];
                [tempDict removeObjectForKey:@"PriceAtPos"];
            }
            else
            {
                [tempDict setObject:[NSString stringWithFormat:@"%f",[itemTxtInvPrice floatValue]] forKey:@"PriceAtPos"];
                [tempDict setObject:@"0" forKey:@"IsQtyEdited"];
            }
        }
        else if (itemBasicPrice < itemTxtInvPrice.floatValue)
        {
            tempDict[@"PriceAtPos"] = [NSString stringWithFormat:@"%f",itemTxtInvPrice.floatValue];
            tempDict[@"IsQtyEdited"] = @"0";
            
        }
        else if (itemBasicPrice == itemTxtInvPrice.floatValue)
        {
            [tempDict removeObjectForKey:@"PriceAtPos"];
        }
    }
}

- (void)edit_CheckCashCalculation:(NSMutableDictionary *)tempDict
{
    NSString *sChargetype=[tempDict  valueForKey:@"item"][@"ChargeType"];
    float fChargeAmt=[[tempDict  valueForKey:@"item"][@"ChargeAmount"]floatValue];
    
    if([sChargetype isEqualToString:@"Percentage(%)"])
    {
        float fenterprice = [[swipeDictionary valueForKey:@"editItemPriceDisplay"] floatValue];
        float CheckCashAmount=fenterprice * fChargeAmt * 0.01;
        [tempDict  valueForKey:@"item"][@"CheckCashCharge"] = [NSString stringWithFormat:@"%f",CheckCashAmount];
    }
}

- (void)edit_ExtraCharge_Calculation:(NSMutableDictionary *)tempDict
{
    NSString *sChargetype=[tempDict  valueForKey:@"item"][@"ChargeType"];
    float fChargeAmt=[[tempDict  valueForKey:@"item"][@"ChargeAmount"]floatValue];
    
    if([sChargetype isEqualToString:@"Percentage(%)"])
    {
        float fenterprice = [[swipeDictionary valueForKey:@"editItemPriceDisplay"] floatValue];
        float CheckExtraAmount=fenterprice * fChargeAmt * 0.01;
        [tempDict  valueForKey:@"item"][@"ExtraCharge"] = [NSString stringWithFormat:@"%f",CheckExtraAmount];
    }
}

- (IBAction)btneditSaveClick:(UIButton *)sender
{
    for(NSDictionary *dictInvLog in _itemLogArray){
        [self.crmController.reciptItemLogDataAry addObject:dictInvLog];
    }
    [_itemLogArray removeAllObjects];
    [self.rmsDbController playButtonSound];
    NSMutableDictionary * tempDict = swipeDictionary;
    if (tempDict != nil)
    {
        BOOL itemPriceEdited = FALSE;
        BOOL isQtyEdited = FALSE;
        
        /// Edit Price Condition............
        NSNumber *itemUpdatedPrice = [swipeDictionary valueForKey:@"editItemPriceDisplay"];
        itemPriceEdited =[self checkItemPriceEdited:tempDict itemUpdatedPrice:itemUpdatedPrice];
        
        swipeDictionary[@"itemPrice"] = @([[swipeDictionary valueForKey:@"editItemPriceDisplay"] floatValue] / [[swipeDictionary valueForKey:@"PackageQty"] floatValue]) ;
        
        float itemprice = itemUpdatedPrice.floatValue;
        
        
        [self edit_itemTaxCalculation:tempDict];
        
        /// Item Tax calculation........
        
        tempDict[@"itemTax"] = @(0.0);
        
        
        ////  Item Discount Changes.........
        
        [self edit_ItemDiscountDetail:tempDict itemprice:itemprice itemTxtInvPrice:itemUpdatedPrice editDiscount:itemEditDiscount];
        
        
        NSString *oldQuantity = tempDict[@"itemQty"];
        
        if (![oldQuantity isEqualToString:itemEditQty]) {
            isQtyEdited= TRUE;
        }
        
        tempDict[@"itemQty"] = itemEditQty;
        ///// Item Extra charge and check cash Changes......
        BOOL isChargeCashvalue=[[tempDict  valueForKey:@"item"][@"isCheckCash"] boolValue];
        BOOL isExtrachargeValue=[[tempDict  valueForKey:@"item"][@"isExtraCharge"] boolValue];
        if (isChargeCashvalue)
        {
            [self edit_CheckCashCalculation:tempDict];
        }
        else if(isExtrachargeValue)
        {
            [self edit_ExtraCharge_Calculation:tempDict];
        }
        else
        {
            
        }
        tempDict[@"IsPriceEdited"] = @"0";
        
        [self removeAllSubViews];

            [self.itemSwipeEditDelegate didEditItemWithEditPrice:itemPriceEdited withEditedPrice:itemUpdatedPrice withEditQty:isQtyEdited withBillEntry:tempDict];
        
        /// Replace the updated object.......
    }
}

- (void)edit_itemTaxCalculation:(NSMutableDictionary *)tempDict
{
    if ([self.invoiceItemTaxDetail isKindOfClass:[NSMutableArray class]])
    {
        if(self.invoiceItemTaxDetail.count>0)
        {
            tempDict[@"ItemTaxDetail"] = self.invoiceItemTaxDetail;
            [tempDict valueForKey:@"item"][@"isTax"] = @"1";
        }
        else
        {
            if ([self.invoiceItemTaxDetail isKindOfClass:[NSMutableArray class]]) {
                [self.invoiceItemTaxDetail removeAllObjects];
            }
            tempDict[@"ItemTaxDetail"] = @"";
        }
    }
    else
    {
        if ([self.invoiceItemTaxDetail isKindOfClass:[NSMutableArray class]])
        {
            [self.invoiceItemTaxDetail removeAllObjects];
        }
        tempDict[@"ItemTaxDetail"] = @"";
    }
}
-(void)didAddMemo :(NSString *)message
{
    swipeDictionary[@"Memo"] = message;
    [self didRemoveViewWithAnimationFromSuperView:rcr_MemoVC.view];
    [_editItemTableView reloadData];
}
-(void)didCancelMemoVC
{
    [self didRemoveViewWithAnimationFromSuperView:rcr_MemoVC.view];
}

@end
