//
//  ItemOptionsVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 08/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "Configuration+Dictionary.h"
#import "DaySelectionOptionCell.h"
#import "Department+Dictionary.h"
#import "DepartmentTax+Dictionary.h"
#import "InventoryItemSelectionListVC.h"
#import "Item+Dictionary.h"
#import "ItemOptionStockCell.h"
#import "ItemOptionsVC.h"
#import "ItemOptionSwitchCell.h"
#import "ItemOptionValidDaysCell.h"
#import "ItemTicket_MD+Dictionary.h"
#import "MMDDayTimeSelectionVC.h"
#import "RcrController.h"
#import "RIMNumberPadPopupVC.h"
#import "RmsDbController.h"
#import "UITableView+AddBorder.h"
#import "UpdateManager.h"


typedef NS_ENUM(NSUInteger, OPTION_INFO) {
    OPTION_SWITCH,
    OPTION_TICKET,
    OPTIN_STOCK,
    OPTION_QTY,
};

typedef NS_ENUM(NSUInteger, OPTION_SWITCH_SUB) {
    SWITCH_SUB_ACTIVE,
    SWITCH_SUB_FAVOURITE,
    SWITCH_SUB_DISPLAY_POS,
    SWITCH_SUB_QTY_OH,
    SWITCH_SUB_PAYOUT,
    SWITCH_SUB_MEMO,
    SWITCH_SUB_EBT,
    SWITCH_SUB_PASS,
    SWITCH_SUB_EXPIRY,
    SWITCH_SUB_DAYS_OF_EXPIRY,
    SWITCH_SUB_VALID_DAYS,
    SWITCH_SUB_ALL_DAYS,
    SWITCH_SUB_SUNDAY,
    SWITCH_SUB_MONDAY,
    SWITCH_SUB_TUESDAY,
    SWITCH_SUB_WEDNEDAY,
    SWITCH_SUB_THUIRSDAY,
    SWITCH_SUB_FRIDAY,
    SWITCH_SUB_SATURDAY,
};

typedef NS_ENUM(NSUInteger, OPTION_TICKET_SUB) {
    OPTION_TICKET_PASS,
    OPTION_TICKET_EXPIRY,
    OPTION_TICKET_DAYS_OF_EXPIRY,
    OPTION_TICKET_VALID_DAYS,
    OPTION_TICKET_ALL_DAYS,
//    OPTION_TICKET_SUNDAY,
//    OPTION_TICKET_MONDAY,
//    OPTION_TICKET_TUESDAY,
//    OPTION_TICKET_WEDNEDAY,
//    OPTION_TICKET_THURISDAY,
//    OPTION_TICKET_FRIDAY,
//    OPTION_TICKET_SATURDAY,
};


typedef NS_ENUM(NSUInteger, OPTIN_STOCK_SUB) {
    OPTIN_STOCK_MINI,
    OPTIN_STOCK_MAX,
};

typedef NS_ENUM(NSUInteger, OPTION_QTY_SUB) {
    OPTION_QTY_PARENT_ITEM,
    OPTION_QTY_CHIELD_QTY,
};

@interface ItemOptionsVC ()<InventoryItemSelectionListVCDelegate>
{
    NSString *isActive;
    NSString *isFavourite;
    NSString *isDisplayInPos;
    NSString *isItemPayout;
    NSString *quantityManagementEnabled;
    NSString *isMemoApply;
    NSString *isEBTApply;
    NSString *CITM_Code;
    NSString *Child_Qty;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RmsDbController *rmsDbController;

//@property (nonatomic) BOOL boolExpiry;

@property (nonatomic, strong) NSString *strParentItem;
@property (nonatomic, strong) NSString *moduleCode;

@property (nonatomic, strong) NSMutableArray *switchSub;
@property (nonatomic, strong) NSMutableArray *swithTitleArray;
@property (nonatomic, strong) NSMutableArray *childQtyTitle;
@property (nonatomic, strong) NSMutableArray *ticketSub;
@property (nonatomic, strong) NSMutableArray *ticketSubArray;
@property (nonatomic, strong) NSMutableArray *optionSection;

@end

@implementation ItemOptionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    Configuration *config = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    
    [self setDefualtValueToFlag];
    [self setDefualtQuantityManagementEnabled];
   
    Item *item =  [self fetchItemWithItemID:(self.itemInfoDataObject.ItemId).stringValue];
    if(item.itemTicket){
        [self.itemInfoDataObject setItemTicketDataFrom:[item.itemTicket itemTicketDictionary]];
        self.itemInfoDataObject.isPass = item.isTicket.boolValue;
        self.itemInfoDataObject.IsExpiration = item.itemTicket.isExpiration.boolValue;
    }
    else{
        [self.itemInfoDataObject setItemTicketDataFrom:nil];
        self.itemInfoDataObject.isPass = item.isTicket.boolValue;
    }
    
    self.switchSub = [[NSMutableArray alloc] initWithObjects:@(SWITCH_SUB_ACTIVE),@(SWITCH_SUB_FAVOURITE),@(SWITCH_SUB_DISPLAY_POS),@(SWITCH_SUB_QTY_OH),@(SWITCH_SUB_PAYOUT),@(SWITCH_SUB_MEMO),@(SWITCH_SUB_EBT), nil];
    self.swithTitleArray = [[NSMutableArray alloc] initWithObjects:@"Active",@"Favorite",@"Display in POS",@"Remove Inventory Counter for Qty OH",@"Payout",@"Memo",@"EBT", nil];

    if(config.localTicketSetting){
        self.optionSection = [[NSMutableArray alloc]initWithObjects:@(OPTION_SWITCH),@(OPTION_TICKET),@(OPTIN_STOCK),@(OPTION_QTY), nil];
    }
    else{
        self.optionSection = [[NSMutableArray alloc]initWithObjects:@(OPTION_SWITCH),@(OPTIN_STOCK),@(OPTION_QTY), nil];

    }
    [self optionValues];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)optionValues{
    
    self.childQtyTitle = [[NSMutableArray alloc] initWithObjects:@"Parent Item",@"Child Quantity", nil];
    
    if(self.itemInfoDataObject.isPass == NO && self.itemInfoDataObject.IsExpiration == NO){
        
        self.ticketSub = [[NSMutableArray alloc]initWithObjects:@(OPTION_TICKET_PASS), nil];
        self.ticketSubArray = [[NSMutableArray alloc]initWithObjects:@"Pass", nil];
        
    }
    else if(self.itemInfoDataObject.isPass && self.itemInfoDataObject.IsExpiration == NO){
        
        self.ticketSub = [[NSMutableArray alloc]initWithObjects:@(OPTION_TICKET_PASS),@(OPTION_TICKET_EXPIRY),@(OPTION_TICKET_VALID_DAYS),@(OPTION_TICKET_ALL_DAYS), nil];
        self.ticketSubArray = [[NSMutableArray alloc]initWithObjects:@"Pass",@"Expiry",@"Valid Days",@"All Days", nil];
        
        // self.ticketSub = [[NSMutableArray alloc]initWithObjects:@(OPTION_TICKET_PASS),@(OPTION_TICKET_EXPIRY), nil];
        // self.ticketSubArray = [[NSMutableArray alloc]initWithObjects:@"Pass",@"Expiry", nil];
        
    }
    else if(self.itemInfoDataObject.IsExpiration && self.itemInfoDataObject.isPass){
        
        self.ticketSub = [[NSMutableArray alloc]initWithObjects:@(OPTION_TICKET_PASS),@(OPTION_TICKET_EXPIRY),@(OPTION_TICKET_DAYS_OF_EXPIRY),@(OPTION_TICKET_VALID_DAYS),@(OPTION_TICKET_ALL_DAYS), nil];
        self.ticketSubArray = [[NSMutableArray alloc]initWithObjects:@"Pass",@"Expiry",@"Days to expiry",@"Valid Days",@"All Days", nil];
    }
    
    [self.tblOption reloadData];
}

#pragma mark - UITextField Delegate Methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag == 300)
    {
        if( textField.text.length == 0) {
            textField.text = @"0";
        }
        
        if ((self.itemInfoDataObject.MaxStockLevel).integerValue)
        {
            int intMaxLevel = (self.itemInfoDataObject.MaxStockLevel).intValue;
            
            if(intMaxLevel < (textField.text).intValue){
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
                    textField.text = [NSString stringWithFormat:@"%ld", (long)(self.itemInfoDataObject.MaxStockLevel).integerValue-1];
                    [textField resignFirstResponder];
                    [self.itemOptionsVCDelegate minStockLevel:@((textField.text).intValue)];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Minimum level should be less than Maximum Leval." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else {
                [self.itemOptionsVCDelegate minStockLevel:@((textField.text).intValue)];
            }
        }
        [self.itemOptionsVCDelegate minStockLevel:@((textField.text).intValue)];
    }
    else if(textField.tag == 301){
        if( textField.text.length == 0){
            textField.text = @"0";
        }
        if ((self.itemInfoDataObject.MinStockLevel).integerValue)
        {
            int intminLevel = (self.itemInfoDataObject.MinStockLevel).intValue;
            
            if(intminLevel > (textField.text).intValue){
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
                    textField.text = [NSString stringWithFormat:@"%ld", (long)(self.itemInfoDataObject.MinStockLevel).integerValue+1];
                    [textField resignFirstResponder];
                    [self.itemOptionsVCDelegate maxStockLevel:@((textField.text).intValue)];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Maximum level should be greater than Minimum Leval." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else {
                [self.itemOptionsVCDelegate maxStockLevel:@((textField.text).intValue)];
            }
        }
        [self.itemOptionsVCDelegate maxStockLevel:@((textField.text).intValue)];
    }
    if(textField.tag == 100){
        if (self.itemInfoDataObject.NoOfdays)
        {
            int intNoOfdays = (self.itemInfoDataObject.NoOfdays).intValue;
            
            if(intNoOfdays >= (textField.text).intValue){
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
                    textField.text = [NSString stringWithFormat:@"%ld", (long)(self.itemInfoDataObject.NoOfdays).integerValue+1];
                    [textField resignFirstResponder];
                    self.itemInfoDataObject.ExpirationDays = @((textField.text).intValue);
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Expire days should be greater than Valid days." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else {
                self.itemInfoDataObject.ExpirationDays = @((textField.text).intValue);
            }
        }
        
        self.itemInfoDataObject.ExpirationDays = @((textField.text).intValue);
    }
    else if(textField.tag == 101){
        
        if (self.itemInfoDataObject.IsExpiration) {
            int intdayofExpiry = (self.itemInfoDataObject.ExpirationDays).intValue;
            
            if(intdayofExpiry <= (textField.text).intValue){
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
                    if ((self.itemInfoDataObject.ExpirationDays).integerValue!= 0)
                    {
                        textField.text = [NSString stringWithFormat:@"%ld", (long)(self.itemInfoDataObject.ExpirationDays).integerValue - 1];
                    }
                    else{
                        textField.text = @"0";
                    }
                    
                    [textField resignFirstResponder];
                    self.itemInfoDataObject.NoOfdays = @((textField.text).intValue);
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Valid days should be less than expiry days." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else {
                self.itemInfoDataObject.NoOfdays = @((textField.text).intValue);
            }
        }
        else {
            self.itemInfoDataObject.NoOfdays = @((textField.text).intValue);
        }
    }
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    textField.text = @"";
    return NO;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSString *daysString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    
//    if ((textField.tag == 300) || (textField.tag == 301) || (textField.tag == 100) || (textField.tag == 101) || (textField.tag == 401)){
//        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
//                                                                               options:NSRegularExpressionCaseInsensitive error:nil];
//        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
//                                                            options:0 range:NSMakeRange(0, newString.length)];
//        if (numberOfMatches == 0)
//            return NO;
//    }
//    if ((textField.tag == 300) || (textField.tag == 301) || (textField.tag == 100) || (textField.tag == 101))
//    {
//        NSCharacterSet *nonNumberSet = [NSCharacterSet decimalDigitCharacterSet].invertedSet;
//        
//        if ([string rangeOfCharacterFromSet:nonNumberSet].location != NSNotFound)
//        {
//            return NO;
//        }
//    }
//    if(textField.tag == 300){
//        if( textField.text.length == 0) {
//            textField.text = @"";
//        }
//        [self.itemOptionsVCDelegate minStockLevel:@(daysString.intValue)];
//    }
//    else if(textField.tag == 301){
//        if( textField.text.length == 0){
//            textField.text = @"";
//        }
//        [self.itemOptionsVCDelegate maxStockLevel:@(daysString.intValue)];
//    }
//    else if(textField.tag == 401){
//        Child_Qty = textField.text;
//        [self.itemOptionsVCDelegate childQtyForItem:@(daysString.intValue)];
//    }
//    else if(textField.tag == 100){
//        self.itemInfoDataObject.ExpirationDays = @(daysString.intValue);
//        //        [self.dictOtherOption setObject:daysString forKey:@"DaysofExpiry"];
//    }
//    else if(textField.tag == 101){
//        if(self.itemInfoDataObject.IsExpiration){
//            
//            int intdayofExpiry = (self.itemInfoDataObject.ExpirationDays).intValue;
//            //            int intdayofExpiry = [[self.dictOtherOption valueForKey:@"DaysofExpiry"] intValue];
//            
//            if(intdayofExpiry < daysString.intValue){
//                
//                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
//                };
//                [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Valid days should be less then expiry days." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
//            }
//            else{
//                self.itemInfoDataObject.NoOfdays = @(daysString.intValue);
//                //                [self.dictOtherOption setObject:daysString forKey:@"ValidDays"];
//            }
//        }
//        else{
//            self.itemInfoDataObject.NoOfdays = @(daysString.intValue);
//            //             [self.dictOtherOption setObject:daysString forKey:@"ValidDays"];
//        }
//    }
//    return YES;
//}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    
    switch (textField.tag) {
        case 100:{
            RIMNumberPadCompleteInput completeBlock =^(NSNumber * numInput,NSString * strInput,id inputView){
                self.itemInfoDataObject.ExpirationDays = numInput;
                if (self.itemInfoDataObject.NoOfdays){
                    if(self.itemInfoDataObject.NoOfdays.intValue >= numInput.intValue && self.itemInfoDataObject.NoOfdays.intValue != 0){
                        [self showMessage:@"Expire days should be greater than Valid days."];
                        self.itemInfoDataObject.ExpirationDays = @(self.itemInfoDataObject.NoOfdays.intValue+1);
                    }
                }
                textField.text = [NSString stringWithFormat:@"%ld", (long)self.itemInfoDataObject.ExpirationDays.integerValue];
            };
            [self showInputNumpad:completeBlock sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
            break;
        }
        case 101:{
            RIMNumberPadCompleteInput completeBlock =^(NSNumber * numInput,NSString * strInput,id inputView){
                self.itemInfoDataObject.NoOfdays = numInput;
                if (self.itemInfoDataObject.IsExpiration) {
                    if(self.itemInfoDataObject.ExpirationDays.intValue <= numInput.intValue){
                        [self showMessage:@"Valid days should be less than expiry days."];
                        if (self.itemInfoDataObject.ExpirationDays.integerValue!= 0){
                            self.itemInfoDataObject.NoOfdays =@(self.itemInfoDataObject.ExpirationDays.integerValue - 1);
                        }
                        else{
                            self.itemInfoDataObject.NoOfdays =@(0);
                        }
                    }
                }
                textField.text = [NSString stringWithFormat:@"%ld", (long)self.itemInfoDataObject.NoOfdays.integerValue];
            };
            [self showInputNumpad:completeBlock sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
            break;
        }
        case 300:{
            RIMNumberPadCompleteInput completeBlock =^(NSNumber * numInput,NSString * strInput,id inputView){
                if (self.itemInfoDataObject.MaxStockLevel.integerValue)
                {
                    if(self.itemInfoDataObject.MaxStockLevel.intValue <= numInput.intValue && numInput.intValue != 0){
                        numInput = @(self.itemInfoDataObject.MaxStockLevel.integerValue-1);
                        [self showMessage:@"Minimum level should be less than Maximum Leval."];
                    }
                }
                textField.text = [NSString stringWithFormat:@"%ld", (long)numInput.integerValue];
                [self.itemOptionsVCDelegate minStockLevel:@((textField.text).intValue)];
            };
            [self showInputNumpad:completeBlock sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
            break;
        }
        case 301:{
            RIMNumberPadCompleteInput completeBlock =^(NSNumber * numInput,NSString * strInput,id inputView){
                if (self.itemInfoDataObject.MinStockLevel.integerValue)
                {
                    if(self.itemInfoDataObject.MinStockLevel.intValue >= numInput.intValue){
                        numInput = @(self.itemInfoDataObject.MinStockLevel.integerValue+1);
                        [self showMessage:@"Maximum level should be greater than Minimum Leval."];
                    }
                }
                textField.text = [NSString stringWithFormat:@"%ld", (long)numInput.integerValue];
                [self.itemOptionsVCDelegate maxStockLevel:@((textField.text).intValue)];
            };
            [self showInputNumpad:completeBlock sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
            break;
        }
        case 401:{
            RIMNumberPadCompleteInput completeBlock =^(NSNumber * numInput,NSString * strInput,id inputView){
                self.itemInfoDataObject.ChildQty = numInput;
                textField.text = [NSString stringWithFormat:@"%ld", (long)numInput.integerValue];
            };
            [self showInputNumpad:completeBlock sourceView:textField ArrowDirection:UIPopoverArrowDirectionDown];
            break;
        }
    }
    return FALSE;
}

-(void)showInputNumpad:(RIMNumberPadCompleteInput)completeBlock sourceView:(id)sender ArrowDirection:(UIPopoverArrowDirection)arrowDirection{
    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesQTY NumberPadCompleteInput:completeBlock NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.inputView = sender;
    [objRIMNumberPadPopupVC presentVCForRightSide:self WithInputView:sender];
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:arrowDirection];
}


#pragma mark - IBAction -


-(IBAction)swithValueChanged:(UISwitch *)sender {

    switch (sender.tag) {
        case SWITCH_SUB_ACTIVE: {
            [self buttonActiveClicked:sender];
            break;
        }
        case SWITCH_SUB_FAVOURITE: {
            [self buttonFavoriteClicked:sender];
            break;
        }
        case SWITCH_SUB_DISPLAY_POS: {
            [self displayInPosClicked:sender];
            break;
        }
        case SWITCH_SUB_QTY_OH: {
            [self quantityManagementEnabled:sender];
            break;
        }
        case SWITCH_SUB_PAYOUT: {
            [self isItemPayout:sender];
            break;
        }
        case SWITCH_SUB_MEMO: {
            [self isMemoApply:sender];
            break;
        }
        case SWITCH_SUB_EBT: {
            [self isEBTApply:sender];
            break;
        }
        case SWITCH_SUB_PASS: {
            [self passOnOff:sender];
            break;
        }
        case SWITCH_SUB_EXPIRY: {
            [self expiryOnOff:sender];
            break;
        }
        default:
            break;
    }
}

-(void)isMemoApply:(UISwitch *)sender{
    [self.rmsDbController playButtonSound];
    if(sender.isOn){
        isMemoApply = @"1";
    }
    else{
        isMemoApply = @"0";
    }
    [self.itemOptionsVCDelegate isMemoApplyToItem:sender.isOn];
    NSDictionary *isMemoApplyDict = @{kRIMItemMemoKey : @(isMemoApply.boolValue)};
    [Appsee addEvent:kRIMItemMemo withProperties:isMemoApplyDict];
}

-(void)isEBTApply:(UISwitch *)sender{
    [self.rmsDbController playButtonSound];
    NSString * strMessage = [self isDepartmentAllowToEBT];
    if (strMessage.length == 0) {
        if(sender.isOn){
            isEBTApply = @"1";
        }
        else{
            isEBTApply = @"0";
        }
    }
    else {
        if(sender.isOn){
            isEBTApply = @"0";
            [sender setOn:FALSE];
            [self showMessage:strMessage];
        }
    }
    [self.itemOptionsVCDelegate isEBTApplyToItem:sender.isOn];
}

- (void)buttonActiveClicked:(UISwitch *)sender{
    
    [self.rmsDbController playButtonSound];
    if(sender.isOn){
        isActive = @"1";
    }
    else{
        isActive = @"0";
    }
    [self.itemOptionsVCDelegate isActiveApply:sender.isOn];
    NSDictionary *favoriteDict = @{kRIMItemFavoriteKey : @(isActive.boolValue)};
    [Appsee addEvent:kRIMItemFavorite withProperties:favoriteDict];
}

- (void)buttonFavoriteClicked:(UISwitch *)sender{
    [self.rmsDbController playButtonSound];
    if(sender.isOn){
        isFavourite = @"1";
    }
    else{
        isFavourite = @"0";
    }
    [self.itemOptionsVCDelegate isFavoriteApply:sender.isOn];
    NSDictionary *favoriteDict = @{kRIMItemFavoriteKey : @(isFavourite.boolValue)};
    [Appsee addEvent:kRIMItemFavorite withProperties:favoriteDict];
}

-(void)displayInPosClicked:(UISwitch *)sender{
    [self.rmsDbController playButtonSound];
    if(sender.isOn){
        isDisplayInPos = @"1";
    }
    else{
        isDisplayInPos = @"0";
    }
    [self.itemOptionsVCDelegate isdisplayInPosApply:sender.isOn];
    NSDictionary *displayInPosDict = @{kRIMItemDisplayInPosKey : @(isDisplayInPos.boolValue)};
    [Appsee addEvent:kRIMItemDisplayInPos withProperties:displayInPosDict];
}

-(void)quantityManagementEnabled:(UISwitch *)sender{
    [self.rmsDbController playButtonSound];
    if(sender.isOn){
        quantityManagementEnabled = @"1";
    }
    else{
        quantityManagementEnabled = @"0";
    }
    [self.itemOptionsVCDelegate quantityManagementEnable:sender.isOn];
    NSDictionary *quantityManagementDict = @{kRIMItemRemoveICForQtyOHKey : @(quantityManagementEnabled.boolValue)};
    [Appsee addEvent:kRIMItemRemoveICForQtyOH withProperties:quantityManagementDict];
}

-(void)isItemPayout:(UISwitch *)sender{
    [self.rmsDbController playButtonSound];
    if(sender.isOn){
        if ([self checkItemHaveTax]) {
            isItemPayout = @"0";
            [sender setOn:FALSE animated:YES];
        }
        else if ((self.itemInfoDataObject.EBT).boolValue)
        {
            isItemPayout = @"0";
            [sender setOn:FALSE animated:YES];
            [self showMessage:@"Please remove EBT."];
            
        }
        else {
            isItemPayout = @"1";
        }
    }
    else{
        isItemPayout = @"0";
    }
    [self.itemOptionsVCDelegate isItemPayoutApply:sender.isOn];
    NSDictionary *isItemPayoutDict = @{kRIMItemPayoutKey : @(isItemPayout.boolValue)};
    [Appsee addEvent:kRIMItemPayout withProperties:isItemPayoutDict];
}

-(IBAction)parentItemClicked:(id)sender{
    [Appsee addEvent:kRIMParentItem];
    [self.rmsDbController playButtonSound];
    
    InventoryItemSelectionListVC * objInventoryItemSelectionListVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"InventoryItemSelectionListVC_sid"];
    objInventoryItemSelectionListVC.delegate = self;
    objInventoryItemSelectionListVC.arrNotSelectedItemCodes = @[@(0),self.itemInfoDataObject.ItemId];
    objInventoryItemSelectionListVC.isSingleSelection = TRUE;
    objInventoryItemSelectionListVC.isItemActive = TRUE;
    objInventoryItemSelectionListVC.isItemInSelectMode = TRUE;
    
    objInventoryItemSelectionListVC.strNotSelectionMsg = @"Parent item must not same as child item";
    [self presentViewController:objInventoryItemSelectionListVC animated:YES completion:nil];
}

-(IBAction)clearParentItemClicked:(id)sender{
    [self.rmsDbController playButtonSound];
    CITM_Code = @"";
    Child_Qty = @"0";
    self.strParentItem =  @"";
    [self.itemOptionsVCDelegate didRemoveParentItem];
}

#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.optionSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return RIMHeaderHeight();
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        OPTION_TICKET_SUB ticketrow = [self.ticketSub[indexPath.row] integerValue];
        if (ticketrow == OPTION_TICKET_ALL_DAYS) {
            if (IsPad()) {
                return 134.0f;
            }
            else {
                return 140.0f;
            }
        }
    }
    return 55.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:0];
        if ([cell isKindOfClass:[ItemOptionStockCell class]]) {
            ItemOptionStockCell * newCell = (ItemOptionStockCell *)cell;
            [tableView arrangeHeightOfViews:@[newCell.textValue1] WillDisplayCell:cell forRowAtIndexPath:indexPath];
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    OPTION_INFO InfoSection = [self.optionSection[section] integerValue];
    
    if (InfoSection == OPTION_SWITCH){
        
        return self.switchSub.count;
    }
    else if (InfoSection == OPTION_TICKET){

        return self.ticketSubArray.count;
    }
    else if (InfoSection == OPTIN_STOCK){
        return 2;
    }
    else if (InfoSection == OPTION_QTY){
     
        return self.childQtyTitle.count;
    }
    return 1;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = @"";
    OPTION_INFO InfoSection = [self.optionSection[section] integerValue];
    switch (InfoSection) {
        case OPTION_SWITCH:
            sectionTitle = @"CONTROL SETUP";
            break;
            
        case OPTION_TICKET:
            sectionTitle = @"TICKET";
            break;
            
        case OPTIN_STOCK:
            sectionTitle = @"STOCK LEVEL";
            break;
            
        case OPTION_QTY:
            sectionTitle = @"Parent Item";
            break;
    }
    return [tableView defaultTableHeaderView:sectionTitle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;

    OPTION_INFO InfoSection = [self.optionSection[indexPath.section] integerValue];
    
    switch (InfoSection) {
        case OPTION_SWITCH:
            cell = [self getOptionCell:tableView cellForRowAtIndexPath:indexPath];
            break;
        case OPTION_TICKET:
            cell = [self getTicketCell:tableView cellForRowAtIndexPath:indexPath];
            break;
        case OPTIN_STOCK:{
            cell = [self preparStockCell:tableView forIndexpath:indexPath];
            if (!self.itemInfoDataObject.oldActive) {
                cell.contentView.userInteractionEnabled = FALSE;
            }

            break;
        }
        case OPTION_QTY:{
            cell = [self preparParrentItemCell:tableView atIndex:indexPath];
            if (!self.itemInfoDataObject.oldActive) {
                cell.contentView.userInteractionEnabled = FALSE;
            }

            break;
        }
        default:
            break;
    }
//    if (!self.itemInfoDataObject.oldActive) {
//        cell.contentView.userInteractionEnabled = FALSE;
//    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Info Switch cells -
-(UITableViewCell *)getOptionCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ItemOptionSwitchCell *optionSwitchCell = (ItemOptionSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemOptionSwitchCell"];
    
    optionSwitchCell.lbltitle.text = [NSString stringWithFormat:@"%@",(self.swithTitleArray)[indexPath.row]].uppercaseString;
    optionSwitchCell.lbltitle.textColor = [UIColor colorWithRed:0.384 green:0.545 blue:0.682 alpha:1.000];
    OPTION_SWITCH_SUB InfoSection = [self.switchSub[indexPath.row] integerValue];
    if (!self.itemInfoDataObject.oldActive && InfoSection != SWITCH_SUB_ACTIVE) {
        optionSwitchCell.contentView.userInteractionEnabled = FALSE;
    }
    else {
        optionSwitchCell.contentView.userInteractionEnabled = TRUE;
    }
    optionSwitchCell.switchValue.tag = InfoSection;
    switch (InfoSection) {
            
        case SWITCH_SUB_ACTIVE:{
            [self prepareSwitchActive:optionSwitchCell];
            optionSwitchCell.contentView.userInteractionEnabled = TRUE;
            break;
        }
        case SWITCH_SUB_FAVOURITE:{
            [self prepareSwitchFavourite:optionSwitchCell];
            break;
        }
        case SWITCH_SUB_DISPLAY_POS:{
            [self prepareSwitchDisplayPOS:optionSwitchCell];
            break;
        }
        case SWITCH_SUB_QTY_OH:{
            [self prepareSwitchQTY_OH:optionSwitchCell];
            break;
        }
        case SWITCH_SUB_PAYOUT:{
            [self prepareSwitchPayOut:optionSwitchCell];
            break;
        }
        case SWITCH_SUB_MEMO:{
            [self prepareSwitchMemo:optionSwitchCell];
        }
            break;
            
        case SWITCH_SUB_EBT:{
            [self prepareSwitchEBT:optionSwitchCell];
            break;
        }
        default:
            break;
    }
    return optionSwitchCell;
}

- (void)prepareSwitchActive:(ItemOptionSwitchCell *)optionSwitchCell {
    if (self.itemInfoDataObject.Active){
        [optionSwitchCell.switchValue setOn:YES];
        isActive = @"1";
    }
    else{
        [optionSwitchCell.switchValue setOn:NO];
        isActive = @"0";
    }
//    [optionSwitchCell.switchValue addTarget:self action:@selector(buttonActiveClicked:) forControlEvents:UIControlEventValueChanged];
    if ([self.itemInfoDataObject.ITM_Type isEqualToNumber:@0] & self.isUpdateItem &!self.itemInfoDataObject.BlockActive) {
        optionSwitchCell.switchValue.userInteractionEnabled = TRUE;
        optionSwitchCell.switchValue.enabled = TRUE;
    }
    else {
        optionSwitchCell.switchValue.userInteractionEnabled = FALSE;
        optionSwitchCell.switchValue.enabled = FALSE;
    }
}

- (void)prepareSwitchFavourite:(ItemOptionSwitchCell *)optionSwitchCell {
    if (self.itemInfoDataObject.IsFavourite){
        [optionSwitchCell.switchValue setOn:YES];
        isFavourite = @"1";
    }
    else{
        [optionSwitchCell.switchValue setOn:NO];
        isFavourite = @"0";
    }
//    [optionSwitchCell.switchValue addTarget:self action:@selector(buttonFavoriteClicked:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareSwitchDisplayPOS:(ItemOptionSwitchCell *)optionSwitchCell {
    if (self.itemInfoDataObject.DisplayInPOS){
        [optionSwitchCell.switchValue setOn:YES];
        isDisplayInPos = @"1";
    }
    else{
        [optionSwitchCell.switchValue setOn:NO];
        isDisplayInPos = @"0";
    }
//    [optionSwitchCell.switchValue addTarget:self action:@selector(displayInPosClicked:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareSwitchQTY_OH:(ItemOptionSwitchCell *)optionSwitchCell {
    if (self.itemInfoDataObject.quantityManagementEnabled){
        [optionSwitchCell.switchValue setOn:YES];
        quantityManagementEnabled = @"1";
    }
    else{
        [optionSwitchCell.switchValue setOn:NO];
        quantityManagementEnabled = @"0";
    }
//    [optionSwitchCell.switchValue addTarget:self action:@selector(quantityManagementEnabled:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareSwitchPayOut:(ItemOptionSwitchCell *)optionSwitchCell {
    if (self.itemInfoDataObject.isItemPayout){
        [optionSwitchCell.switchValue setOn:YES];
        isItemPayout = @"1";
    }
    else{
        [optionSwitchCell.switchValue setOn:NO];
        isItemPayout = @"0";
    }
//    [optionSwitchCell.switchValue addTarget:self action:@selector(isItemPayout:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareSwitchMemo:(ItemOptionSwitchCell *)optionSwitchCell {
    if (self.itemInfoDataObject.Memo){
        [optionSwitchCell.switchValue setOn:YES];
        isMemoApply = @"1";
    }
    else{
        [optionSwitchCell.switchValue setOn:NO];
        isMemoApply = @"0";
    }
//    [optionSwitchCell.switchValue addTarget:self action:@selector(isMemoApply:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareSwitchEBT:(ItemOptionSwitchCell *)optionSwitchCell {
    if (self.itemInfoDataObject.EBT.boolValue){
        [optionSwitchCell.switchValue setOn:YES];
        isEBTApply = @"1";
    }
    else{
        [optionSwitchCell.switchValue setOn:NO];
        isEBTApply = @"0";
    }
//    [optionSwitchCell.switchValue addTarget:self action:@selector(isEBTApply:) forControlEvents:UIControlEventValueChanged];
    
}


#pragma mark - Ticket -
-(UITableViewCell *)getTicketCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    ItemOptionSwitchCell *optionPassCell = (ItemOptionSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemOptionSwitchCell"];
    
    optionPassCell.lbltitle.text = [NSString stringWithFormat:@"%@",(self.ticketSubArray)[indexPath.row]].uppercaseString;
    
//    optionPassCell.lbltitle.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    
    optionPassCell.switchValue.userInteractionEnabled = TRUE;
    
    OPTION_TICKET_SUB ticketrow = [self.ticketSub[indexPath.row] integerValue];
    optionPassCell.lbltitle.textColor = [UIColor colorWithRed:0.384 green:0.545 blue:0.682 alpha:1.000];
    switch (ticketrow) {
            
        case OPTION_TICKET_PASS:{
            [self prepareTicketPass:optionPassCell];
            cell = optionPassCell;
            break;
        }
            
        case OPTION_TICKET_EXPIRY:{
            [self prepareTicketExpiry:optionPassCell];
            cell = optionPassCell;
            break;
        }
        case OPTION_TICKET_DAYS_OF_EXPIRY:{
            cell = [self prepareTicketDaysOfExpiry:indexPath];
            break;
        }
            
        case OPTION_TICKET_VALID_DAYS:{
            cell = [self prepareTicketValidDays:indexPath];
            break;
        }
        case OPTION_TICKET_ALL_DAYS:{
            cell = [self prepareTicketDaysCell:indexPath withTag:200 isSelected:self.itemInfoDataObject.SelectedOption];
            break;
        }
    }
    if (!self.itemInfoDataObject.oldActive) {
        cell.contentView.userInteractionEnabled = FALSE;
    }
    return cell;
}
- (void)prepareTicketPass:(ItemOptionSwitchCell *)optionPassCell {
    [optionPassCell.switchValue setOn:self.itemInfoDataObject.isPass];
    optionPassCell.switchValue.tag = SWITCH_SUB_PASS;
//    [optionPassCell.switchValue addTarget:self action:@selector(passOnOff:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareTicketExpiry:(ItemOptionSwitchCell *)optionPassCell {
    (optionPassCell.lbltitle).textColor = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    
    [optionPassCell.switchValue setOn:self.itemInfoDataObject.IsExpiration];
    optionPassCell.switchValue.tag = SWITCH_SUB_EXPIRY;
//    [optionPassCell.switchValue addTarget:self action:@selector(expiryOnOff:) forControlEvents:UIControlEventValueChanged];
}

- (UITableViewCell *)prepareTicketDaysOfExpiry:(NSIndexPath *)indexPath {
    
    //    NSString *celloptionstockCell2 = [self getIdentifierForStockInfoCell];
    
    ItemOptionStockCell *optionPassCell = (ItemOptionStockCell *)[self.tblOption dequeueReusableCellWithIdentifier:@"ItemOptionStockCell"];
    optionPassCell.lbltitle1.text = [NSString stringWithFormat:@"%@",(self.ticketSubArray)[indexPath.row]].uppercaseString;
    
    optionPassCell.btnSearch.hidden = YES;
    optionPassCell.textValue1.tag = 100;
    if ((self.itemInfoDataObject.ExpirationDays).integerValue>0) {
        optionPassCell.textValue1.text = (self.itemInfoDataObject.ExpirationDays).stringValue;
        
    }
    else{
        optionPassCell.textValue1.placeholder = @"Days";
        optionPassCell.textValue1.text = @"";
    }
    optionPassCell.lbltitle2.hidden = TRUE;
    optionPassCell.textValue2.hidden = TRUE;
    [self.tblOption arrangeHeightOfViews:@[optionPassCell.textValue1] WillDisplayCell:optionPassCell forRowAtIndexPath:indexPath];
    return optionPassCell;
}

- (UITableViewCell *)prepareTicketValidDays:(NSIndexPath *)indexPath {
    
    ItemOptionStockCell *optionstockcell2 = (ItemOptionStockCell *)[self.tblOption dequeueReusableCellWithIdentifier:@"ItemOptionStockCell"];
    
    optionstockcell2.textValue1.clearButtonMode = UITextFieldViewModeNever;
    optionstockcell2.textValue1.tag = 101;
    optionstockcell2.lbltitle1.text = [NSString stringWithFormat:@"%@",(self.ticketSubArray)[indexPath.row]].uppercaseString;
    optionstockcell2.lbltitle2.hidden = TRUE;
    optionstockcell2.textValue2.hidden = TRUE;
    optionstockcell2.btnSearch.hidden = TRUE;
    if ((self.itemInfoDataObject.NoOfdays).integerValue>0) {
        optionstockcell2.textValue1.text = (self.itemInfoDataObject.NoOfdays).stringValue;
        
    }
    else{
        optionstockcell2.textValue1.placeholder = @"Days";
        optionstockcell2.textValue1.text = @"";
        
    }
    [self.tblOption arrangeHeightOfViews:@[optionstockcell2.textValue1] WillDisplayCell:optionstockcell2 forRowAtIndexPath:indexPath];
    return optionstockcell2;
}

- (UITableViewCell *)prepareTicketDaysCell:(NSIndexPath *)indexPath withTag:(NSInteger)tag isSelected:(BOOL)isSelected{
    DaySelectionOptionCell *optinvaliddays = (DaySelectionOptionCell *)[self.tblOption dequeueReusableCellWithIdentifier:@"DaySelectionOptionCell"];
    optinvaliddays.intValidDays = [self getDayValidationSum];
    optinvaliddays.daySelectionChanged = ^(NSInteger intValidDays){
        
        self.itemInfoDataObject.Sunday = FALSE;
        self.itemInfoDataObject.Monday = FALSE;
        self.itemInfoDataObject.Tuesday = FALSE;
        self.itemInfoDataObject.Wednesday = FALSE;
        self.itemInfoDataObject.Thursday = FALSE;
        self.itemInfoDataObject.Friday = FALSE;
        self.itemInfoDataObject.Saturday = FALSE;
        NSArray * arrAllDay =@[@(WeekDaySun),@(WeekDayMon),@(WeekDayTue),@(WeekDayWed),@(WeekDayThu),@(WeekDayFri),@(WeekDaySat)];
        for (NSNumber * numDay in arrAllDay) {
            WeekDay isWeekdaySelected = (WeekDay)numDay.intValue;
            if (isDaySelected(intValidDays, isWeekdaySelected)) {
                switch (isWeekdaySelected) {
                    case WeekDaySun:
                        self.itemInfoDataObject.Sunday = TRUE;
                        break;
                    case WeekDayMon:
                        self.itemInfoDataObject.Monday = TRUE;
                        break;
                    case WeekDayTue:
                        self.itemInfoDataObject.Tuesday = TRUE;
                        break;
                    case WeekDayWed:
                        self.itemInfoDataObject.Wednesday = TRUE;
                        break;
                    case WeekDayThu:
                        self.itemInfoDataObject.Thursday = TRUE;
                        break;
                    case WeekDayFri:
                        self.itemInfoDataObject.Friday = TRUE;
                        break;
                    case WeekDaySat:
                        self.itemInfoDataObject.Saturday = TRUE;
                        break;
                }
            }
        }
        [self.tblOption reloadData];
    };
    [optinvaliddays resetDaySelectionButtons];
    return optinvaliddays;
}
-(int)getDayValidationSum{
    int intValidDays = 0;
    if (self.itemInfoDataObject.Sunday) {
        applyOnDay(intValidDays, WeekDaySun);
    }
    if (self.itemInfoDataObject.Monday){
        applyOnDay(intValidDays, WeekDayMon);
    }
    if (self.itemInfoDataObject.Tuesday){
        applyOnDay(intValidDays, WeekDayTue);
    }
    if (self.itemInfoDataObject.Wednesday){
        applyOnDay(intValidDays, WeekDayWed);
    }
    if (self.itemInfoDataObject.Thursday){
        applyOnDay(intValidDays, WeekDayThu);
    }
    if (self.itemInfoDataObject.Friday){
        applyOnDay(intValidDays, WeekDayFri);
    }
    if (self.itemInfoDataObject.Saturday){
        applyOnDay(intValidDays, WeekDaySat);
    }
    return intValidDays;
}
#pragma mark - Stock and Parrent Cell -
-(UITableViewCell *)preparStockCell:(UITableView *)tableView forIndexpath:(NSIndexPath *) indexPath{
    
    ItemOptionStockCell *optionstockcell = (ItemOptionStockCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemOptionStockCell"];
    
    optionstockcell.selectionStyle = UITableViewCellSelectionStyleNone;
    optionstockcell.textValue1.clearButtonMode = UITextFieldViewModeNever;
    optionstockcell.textValue1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (indexPath.row == 0) {
        optionstockcell.lbltitle1.text = @"Minimum Inventory Level".uppercaseString;
        optionstockcell.textValue1.tag = 300;
        if (self.itemInfoDataObject.MinStockLevel > 0) {
            optionstockcell.textValue1.text = [NSString stringWithFormat:@"%@",(self.itemInfoDataObject.MinStockLevel).stringValue];
        }
        else {
            optionstockcell.textValue1.text = @"0";
        }
    }
    else{
        optionstockcell.lbltitle1.text = @"Maximum Inventory Level".uppercaseString;
        optionstockcell.textValue1.tag = 301;
        if (self.itemInfoDataObject.MaxStockLevel > 0) {
            optionstockcell.textValue1.text = [NSString stringWithFormat:@"%@",(self.itemInfoDataObject.MaxStockLevel).stringValue];
        }
        else {
            optionstockcell.textValue1.text = @"";
        }
    }
    [tableView arrangeHeightOfViews:@[optionstockcell.textValue1] WillDisplayCell:optionstockcell forRowAtIndexPath:indexPath];
    optionstockcell.btnSearch.hidden = YES;
    return optionstockcell;
}
-(UITableViewCell *)preparParrentItemCell:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        ItemOptionStockCell *optionstockcell2 = (ItemOptionStockCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemOptionParentCell"];
        
        optionstockcell2.selectionStyle = UITableViewCellSelectionStyleNone;
        
        optionstockcell2.lbltitle1.text = [NSString stringWithFormat:@"%@",(self.childQtyTitle)[indexPath.row]].uppercaseString;
        CITM_Code = [NSString stringWithFormat:@"%@",(self.itemInfoDataObject.CITM_Code).stringValue];
        
        NSManagedObjectContext *context = self.managedObjectContext;
        Item *getItem = [self fetchAllItems:CITM_Code moc:context];
        optionstockcell2.textValue1.clearButtonMode = UITextFieldViewModeAlways;
        optionstockcell2.textValue1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        
        optionstockcell2.textValue1.tag = 400;
        if(self.strParentItem){
            optionstockcell2.textValue1.text = self.strParentItem;
        }
        else{
            optionstockcell2.textValue1.text = getItem.item_Desc;
        }
        optionstockcell2.btnSearch.hidden = NO;
        [tableView arrangeHeightOfViews:@[optionstockcell2.textValue1] WillDisplayCell:optionstockcell2 forRowAtIndexPath:indexPath];
        return optionstockcell2;
    }
    else{
        ItemOptionStockCell *optionstockcell = (ItemOptionStockCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemOptionStockCell"];
        
        optionstockcell.selectionStyle = UITableViewCellSelectionStyleNone;
        optionstockcell.textValue1.clearButtonMode = UITextFieldViewModeNever;
        optionstockcell.textValue1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        
        if (self.itemInfoDataObject.ChildQty > 0) {
            Child_Qty = [NSString stringWithFormat:@"%@",(self.itemInfoDataObject.ChildQty).stringValue];
        }
        else{
            Child_Qty = @"0";
        }
        optionstockcell.btnSearch.hidden = YES;

        optionstockcell.lbltitle1.text = [NSString stringWithFormat:@"%@",(self.childQtyTitle)[indexPath.row]].uppercaseString;
        optionstockcell.textValue1.text = Child_Qty;
        optionstockcell.textValue1.tag = 401;
        [tableView arrangeHeightOfViews:@[optionstockcell.textValue1] WillDisplayCell:optionstockcell forRowAtIndexPath:indexPath];
        return optionstockcell;
    }
}
-(ItemOptionStockCell *)getSectionTableviewCell:(UITableView *)tblView{
    
     NSString *celloptionstockCell = [self getIdentifierForStockInfoCell];
    
    ItemOptionStockCell *optionstockcell = (ItemOptionStockCell *)[tblView dequeueReusableCellWithIdentifier:celloptionstockCell];
    optionstockcell.selectionStyle = UITableViewCellSelectionStyleNone;
    return optionstockcell;
}


-(NSString *)getIdentifierForStockInfoCell{
    NSString *identifier = @"";
    if(IsPad()){
        
        identifier = @"ItemOptionStockCell";
    }
    else{
        identifier = @"ItemOptionStockCell_iPhone";
    }
    return identifier;
}

-(void)passOnOff:(UISwitch *)sender{
    self.itemInfoDataObject.isPass = sender.on;
    if(!sender.on){
        self.itemInfoDataObject.IsExpiration = FALSE;
    }
    [self optionValues];
}

-(void)expiryOnOff:(UISwitch *)sender{
    self.itemInfoDataObject.IsExpiration = sender.on;
    [self optionValues];
}

- (void)setDefualtValueToFlag{
    isFavourite = @"0";
    isDisplayInPos = @"0";
    isItemPayout = @"0";
    isMemoApply = @"0";
    CITM_Code = @"";
    Child_Qty = @"0";
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
    if (resultSet.count>0){
        item=resultSet.firstObject;
    }
    return item;
}

- (void)setDefualtQuantityManagementEnabled{
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSArray *moduleCodes = @[@"RCR",@"RCRGAS",@"RRRCR",@"RRCR"];
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@" ModuleCode IN %@",moduleCodes];
    NSArray *moduleArray = [activeModulesArray filteredArrayUsingPredicate:rcrActive];
    if (moduleArray.count > 0){
        self.moduleCode = [moduleArray.firstObject valueForKey:@"ModuleCode"];
    }
    else{
        self.moduleCode = @"RCR";
    }
    
    if([self.moduleCode isEqualToString:@"RCRGAS"]){
        quantityManagementEnabled = @"0";
    }
    else{
        quantityManagementEnabled = @"0";
    }
}

#pragma mark - Tax -

-(BOOL)checkItemHaveTax {
    BOOL isItemTax = FALSE;
    if(self.itemInfoDataObject.itemtaxarray.count > 0) {
        [self showMessage:@"Please remove tax."];
        isItemTax = TRUE;
    }
    else if ([self getDepartmentTaxOfItemDepartment]) {
        [self showMessage:@"Department selected with tax."];
        isItemTax = TRUE;
    }
    return isItemTax;
}
-(void)showMessage:(NSString *)strMessage {
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}
- (BOOL)getDepartmentTaxOfItemDepartment {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",self.itemInfoDataObject.DepartId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *departmentTaxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (int i=0; i<departmentTaxListArray.count; i++){
        DepartmentTax *departmentTax=departmentTaxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",departmentTax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemTaxName.count>0){
            return TRUE;
        }
    }
    return FALSE;
}

-(NSString *)isDepartmentAllowToEBT {
    NSString * strMessage = @"";
    
    Department * dept = [self fetchDepartmentWithDepartmentID:self.itemInfoDataObject.DepartId.stringValue];
    if (dept.deductChk.boolValue || dept.chkCheckCash.boolValue || dept.chargeAmt.floatValue > 0) {
        strMessage = @"Department have a Cheque Cash, Charge Type OR Payout";
    }
    if (self.itemInfoDataObject.isItemPayout) {
        if (strMessage.length>0) {
            strMessage = [NSString stringWithFormat:@"%@ and Item have a Payout",strMessage];
        }
        else {
            strMessage = [NSString stringWithFormat:@"Item have a Payout"];
        }
    }
    if (strMessage.length>0) {
        strMessage = [NSString stringWithFormat:@"%@ , you can't applied EBT.",strMessage];
    }
    return strMessage;
}

#pragma mark - Parent Item Delegate

-(void)didSelectedItems:(NSArray *) arrListOfitems {
    if (arrListOfitems.count > 0) {
        Item * anItem = arrListOfitems.firstObject;
        self.strParentItem =  anItem.item_Desc;
        CITM_Code = anItem.itemCode.stringValue;
        [self.itemOptionsVCDelegate parentItemSelected:anItem.itemCode];
        NSDictionary *selectedParentItemdict = @{kRIMParentItemSelectedKey : anItem.itemCode.stringValue};
        [Appsee addEvent:kRIMParentItemSelected withProperties:selectedParentItemdict];
        [self.tblOption reloadData];
    }
    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Core Data -

- (Item *)fetchItemWithItemID :(NSString *)itemId{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0){
        item=resultSet.firstObject;
    }
    return item;
}

- (Department *)fetchDepartmentWithDepartmentID :(NSString *)DepartmentId{
    Department *department=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d", DepartmentId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0){
        department=resultSet.firstObject;
    }
    return department;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
