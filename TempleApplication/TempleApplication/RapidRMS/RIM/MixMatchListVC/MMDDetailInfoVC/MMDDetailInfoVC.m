//
//  MMDDetailInfoVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 22/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDDetailInfoVC.h"
#import "MMDiscountListVC.h"
#import "MMDOfferListVC.h"
#import "RmsDbController.h"
#import "MMDNumberPickerVC.h"
#import "MMDAddDiscountTypeVC.h"

@interface MMDDetailInfoVC ()<MMDNumberPickerVCDelegate> {
    UIView * viewPopupView;
    NSString *letters;
    MMDOfferListVC * mMDOfferListVC;
    MMDNumberPickerVC * mMDDateTimePickerVC;
}

@property (nonatomic, weak) IBOutlet UIView * viewOfferDetail;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountTitle;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountCode;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountLimitQTY;
@property (nonatomic, weak) IBOutlet UITextView * txtVDiscountDescription;
@property (nonatomic, weak) IBOutlet UIButton * btnQTYNoLimit;
@property (nonatomic, weak) IBOutlet UIButton * btnQTYLimit;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RapidWebServiceConnection * itemUpdateWebServiceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * itemInserWebServiceConnection;
@property (nonatomic, strong) RmsDbController * rmsDbController;

@end

@implementation MMDDetailInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    letters = @"abcdefghi0123456789jklmnopqrstu0123456789vwxyzABCDE0123456789FGHIJKLMNO0123456789PQRSTUVWXYZ0123456789";
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemUpdateWebServiceConnection = [[RapidWebServiceConnection alloc] init];
    self.itemInserWebServiceConnection = [[RapidWebServiceConnection alloc] init];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!mMDOfferListVC) {
        mMDOfferListVC = [[UIStoryboard storyboardWithName:@"MMDiscount"
                                                    bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDOfferListVC_sid"];
        mMDOfferListVC.view.frame = _viewOfferDetail.bounds;
        [self addChildViewController:mMDOfferListVC];
        [_viewOfferDetail addSubview:mMDOfferListVC.view];
    }
    [self loadValueToView];
}
-(void)loadValueToView {
    _txtDiscountTitle.text = self.objMixMatch.name;
    _txtDiscountCode.text = self.objMixMatch.code;
    if (self.objMixMatch.descriptionText && self.objMixMatch.descriptionText.length > 0) {
        _txtVDiscountDescription.text = self.objMixMatch.descriptionText;
    }
    else {
        _txtVDiscountDescription.text = [self getDiscountDescription];
    }
    [self refreshQTYButtons];
}

-(NSString *)getDiscountDescription {
    NSString *desc = @"";
    MMDDiscountType discountType = self.objMixMatch.discountType.integerValue;
    switch (discountType) {
        case MMDDiscountTypeQuantity:
            desc = [self qtyTypeDiscountDescription];
            break;
            
        case MMDDiscountTypeMandM:
            desc = [self mixAndMatchDiscountDescription];
            break;

        default:
            break;
    }
    return desc;
}

-(NSString *)qtyTypeDiscountDescription {
    NSString *desc = @"";
    MMDQuantityType quantityType = self.objMixMatch.quantityType.integerValue;
    MMDFreeType mmdFreeType = self.objMixMatch.freeType.integerValue;
    if (quantityType == MMDQuantityTypeODD) {
        switch (mmdFreeType) {
            case MMDFreeTypeAmount:
                desc = [NSString stringWithFormat:@"Buy %ld or more and get $%@ off",(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
                break;
            case MMDFreeTypePercentage:
                desc = [NSString stringWithFormat:@"Buy %ld or more and get %@%% off",(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
                break;
            case MMDFreeTypeFor:
                desc = [NSString stringWithFormat:@"Buy %ld or more for $%@",(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
                break;
            case MMDFreeTypeUnitAmount:
                desc = [NSString stringWithFormat:@"Buy %ld or more at $%@",(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
                break;
            case MMDFreeTypePriceWithTax:
                
                break;
                
            default:
                break;
        }
    }
    else {
        switch (mmdFreeType) {
            case MMDFreeTypeAmount:
                desc = [NSString stringWithFormat:@"Buy %ld and get $%@ off",(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
                break;
            case MMDFreeTypePercentage:
                desc = [NSString stringWithFormat:@"Buy %ld and get %@%% off",(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
                break;
            case MMDFreeTypeFor:
                desc = [NSString stringWithFormat:@"Buy %ld for $%@",(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
                break;
            case MMDFreeTypeUnitAmount:
                desc = [NSString stringWithFormat:@"Buy %ld at $%@",(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
                break;
            case MMDFreeTypePriceWithTax:
                
                break;
                
            default:
                break;
        }
    }
    return desc;
}

-(NSString *)mixAndMatchDiscountDescription {
    NSString *desc = @"";
    MMDFreeType mmdFreeType = self.objMixMatch.freeType.integerValue;
    switch (mmdFreeType) {
        case MMDFreeTypeAmount:
            desc = [NSString stringWithFormat:@"Buy %ld and get $%@ off on other %ld",(long)self.objMixMatch.secondaryItemQty.integerValue,self.objMixMatch.free.stringValue,(long)self.objMixMatch.primaryItemQty.integerValue];
            break;
        case MMDFreeTypePercentage:
            desc = [NSString stringWithFormat:@"Buy %ld and get %@%% off on other %ld",(long)self.objMixMatch.secondaryItemQty.integerValue,self.objMixMatch.free.stringValue,(long)self.objMixMatch.primaryItemQty.integerValue];
            break;
        case MMDFreeTypeFree:
            desc = [NSString stringWithFormat:@"Buy %ld and get other %ld for free",(long)self.objMixMatch.secondaryItemQty.integerValue,(long)self.objMixMatch.primaryItemQty.integerValue];
            break;
        case MMDFreeTypeFor:
            desc = [NSString stringWithFormat:@"Buy %ld and get other %ld for $%@",(long)self.objMixMatch.secondaryItemQty.integerValue,(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
            break;
        case MMDFreeTypeUnitAmount:
            desc = [NSString stringWithFormat:@"Buy %ld and get other %ld at $%@",(long)self.objMixMatch.secondaryItemQty.integerValue,(long)self.objMixMatch.primaryItemQty.integerValue,self.objMixMatch.free.stringValue];
            break;
        case MMDFreeTypePriceWithTax:
            
            break;
            
        default:
            break;
    }
    return desc;
}

-(void)refreshQTYButtons {
    if (self.objMixMatch.qtyLimit.intValue > 0) {
        _btnQTYLimit.selected = TRUE;
        _txtDiscountLimitQTY.text = self.objMixMatch.qtyLimit.stringValue;
        _btnQTYNoLimit.selected = FALSE;
    }
    else {
        _btnQTYNoLimit.selected = TRUE;
        _btnQTYLimit.selected = FALSE;
    }
}
#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{        // return NO to disallow editing.
    if ([_txtDiscountLimitQTY isEqual:textField]) {
        [self editQtyForPackageType:textField];
        return NO;
    }
    else
        return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self refreshQTYButtons];
}
- (void)editQtyForPackageType:(UITextField *)textField{
    
    
    NSString * strTitle = @"QUANTITY";
    NumberPickerTypes pickerMode = NumberPickerTypesQTY;
    NSNumber * maxLenght = nil;
    [self showNumberPickerInputView:textField PickerType:pickerMode PickerTitle:strTitle maxLenght:maxLenght];
}

#pragma mark - IBActions -

-(IBAction)changeApplyTexType:(UIButton *)sender {
    [self.view endEditing:YES];
    sender.selected = TRUE;
}

-(IBAction)changeApplyLimitType:(UIButton *)sender {
    [self.view endEditing:YES];
    _btnQTYNoLimit.selected = FALSE;
    _btnQTYLimit.selected = FALSE;
    sender.selected = TRUE;
}

-(IBAction)btnSaveAndCloase:(id)sender {
    [self saveValueIntoMMDobject];
    if (self.objMixMatch.name.length == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please enter discount name"];
    }
//    else if (self.objMixMatch.descriptionText.length == 0) {
//        [self showMessageWithTitle:nil withMessage:@"Please enter discount description"];
//    }
    else if (self.objMixMatch.code.length == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please enter discount code"];
    }
    else if ((self.objMixMatch.qtyLimit).intValue == 0 && _btnQTYLimit.selected) {
        [self showMessageWithTitle:nil withMessage:@"Please input Quantity"];
    }
    else {
        [self addUpdateMMDDetail];
    }

}

-(IBAction)btnAutoGenrateCode:(id)sender {
    
    NSString * strCode = [self randomStringWithLength:8];
    while ([self isDiscountCodeInList:strCode]) {
        strCode = [self randomStringWithLength:8];
    }
    _txtDiscountCode.text = strCode;
}
-(BOOL)isDiscountCodeInList:(NSString *)strCode {
    BOOL isDuplicate = TRUE;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Discount_M" inManagedObjectContext:self.moc];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"code == %@",strCode];
    request.predicate = predicate;


    [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSInteger count = [self.moc countForFetchRequest:request error:nil];
    if (count == 0) {
        isDuplicate = FALSE;
    }
    return isDuplicate;
    
}
-(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)letters.length)]];
    }
    
    return randomString;
}
-(void)showMessageWithTitle:(NSString *)strTitle withMessage:(NSString *) strMessage{
    if (!strTitle) {
        strTitle = @"Discount";
    }
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
    };
    [[RmsDbController sharedRmsDbController] popupAlertFromVC:self title:strTitle message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    
}
-(void)saveValueIntoMMDobject{
    
    self.objMixMatch.name = _txtDiscountTitle.text;
    self.objMixMatch.code = _txtDiscountCode.text;
    self.objMixMatch.descriptionText = _txtVDiscountDescription.text;
    if (self.objMixMatch.discountType.integerValue == 1) {
        self.objMixMatch.secondaryItems = nil;
    }
    
    if (_btnQTYLimit.selected) {
        self.objMixMatch.qtyLimit = @(_txtDiscountLimitQTY.text.intValue);
    }
    if (_btnQTYLimit.selected) {
        self.objMixMatch.qtyLimit = @([_txtDiscountLimitQTY.text intValue]);
    }
    else {
        self.objMixMatch.qtyLimit = @(0);
    }
}
-(void)addUpdateMMDDetail{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictMMDInfo = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * dictDiscountInfo = [[NSMutableDictionary alloc]initWithDictionary:[self getMMDDetailInfo]];
    
//    if ((self.rmsDbController.globalDict)[@"UserInfo"]) {
//        NSString * userID = [[self.rmsDbController.globalDict objectForKey:@"UserInfo"] objectForKey:@"UserId"];
//        dictDiscountInfo[@"CreatedBy"] = userID;
//    }
    dictDiscountInfo[@"CreatedBy"] = @"1";

    dictDiscountInfo[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    dictMMDInfo[@"objDiscountMaster"] = dictDiscountInfo;
    dictMMDInfo[@"DiscountPrimaryArray"] = [self getMMDPrimaryItems];
    dictMMDInfo[@"DiscountSecondaryArray"] = [self getMMDSecondaryItems];
    
    NSDictionary * dictServer = @{@"DiscountData": dictMMDInfo};
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responceMMDItemInsertUpdateResponse:response error:error];
        });
    };
    
    if (self.objMixMatch.discountId.intValue == 0) {
        
        self.itemInserWebServiceConnection = [self.itemInserWebServiceConnection initWithRequest:KURL actionName:WSM_MMD_ITEM_INSERT params:dictServer completionHandler:completionHandler];
    }
    else {
        self.itemUpdateWebServiceConnection = [self.itemUpdateWebServiceConnection initWithRequest:KURL actionName:WSM_MMD_ITEM_UPDATE params:dictServer completionHandler:completionHandler];
    }
}
-(void)responceMMDItemInsertUpdateResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                [self updateDataInDataBase];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                    [self btnCloseMMD:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                if ([self.objMixMatch.discountId intValue] != 0) {
                    [UpdateManager saveContext:self.moc];
                }
            }
            else {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}
-(void)updateDataInDataBase {
    
    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
    [itemLiveUpdate setValue:@"Update" forKeyPath:@"Action"];
    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
    [itemLiveUpdate setValue:@"Item" forKey:@"Type"];
    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
    
}
-(NSDictionary *)getMMDDetailInfo{
    return self.objMixMatch.discountDetailDisctionary;
}
-(NSArray *)getMMDPrimaryItems{
    return self.objMixMatch.discountPrimaryArray;
}
-(NSArray *)getMMDSecondaryItems{
    return self.objMixMatch.discountSecondaryArray;
}
-(IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)btnCloseMMD:(id)sender {
    NSArray * arrViewC = self.navigationController.viewControllers;
    for (UIViewController *vc in arrViewC) {
        if ([vc isKindOfClass:[MMDiscountListVC class]]) {
            [self.navigationController popToViewController:vc animated:TRUE];
            return;
        }
    }
}
#pragma mark - picker -
-(void)showNumberPickerInputView:(id)inputView PickerType:(NumberPickerTypes)pickerType PickerTitle:(NSString *) strPickerTitle maxLenght:(NSNumber *)maxInput{
    
    mMDDateTimePickerVC = [[MMDNumberPickerVC alloc] initWithNibName:@"MMDNumberPickerVC" bundle:nil];
    viewPopupView = [[UIView alloc]initWithFrame:self.view.bounds];
    viewPopupView.backgroundColor =[UIColor colorWithWhite:0.000 alpha:0.500];
    mMDDateTimePickerVC.view.center = viewPopupView.center;
    [viewPopupView addSubview:mMDDateTimePickerVC.view];
    [self addChildViewController:mMDDateTimePickerVC];
    [self.view addSubview:viewPopupView];
    mMDDateTimePickerVC.view.layer.cornerRadius = 8.0f;
    mMDDateTimePickerVC.Delegate = self;
    mMDDateTimePickerVC.inputView = inputView;
    mMDDateTimePickerVC.maxInput = maxInput;
    mMDDateTimePickerVC.strTitle = strPickerTitle;
    mMDDateTimePickerVC.pickerType = pickerType;
}
-(void)didEnterNumber:(NSNumber *) number inputView:(id) inputView withPickerType:(NumberPickerTypes) pickerType {

    switch (pickerType) {
        case NumberPickerTypesQTY: {
            self.objMixMatch.qtyLimit = number;
            break;
        }
        case NumberPickerTypesPrice:
        case NumberPickerTypesPercentage: {
            self.objMixMatch.qtyLimit = number;
            break;
        }
    }
    [self refreshQTYButtons];
    [self didCancelEditItemPopOver];
}

-(void)didCancelEditItemPopOver {
    [UIView animateWithDuration:0.5 animations:^{
        viewPopupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        NSArray * arrView = viewPopupView.subviews;
        for (UIView * view in arrView) {
            [view removeFromSuperview];
        }
        [viewPopupView removeFromSuperview];
        [mMDDateTimePickerVC removeFromParentViewController];
        viewPopupView = nil;
    }];
}


@end
