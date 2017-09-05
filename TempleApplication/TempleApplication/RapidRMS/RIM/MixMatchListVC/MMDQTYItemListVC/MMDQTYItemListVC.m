//
//  MMDQTYItemListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDDayTimeSelectionVC.h"
#import "MMDiscountListVC.h"
#import "MMDItemListVC.h"
#import "MMDItemSectionVC.h"
#import "MMDMasterItemListVC.h"
#import "MMDMasterListVC.h"
#import "MMDNumberPickerVC.h"
#import "MMDQTYItemListVC.h"
#import "MMDSelectedItemListVC.h"
#import "MMDSlideItemListVC.h"
#import "RmsDbController.h"


@interface MMDQTYItemListVC () <DidSelectItemListDelegate,MMDNumberPickerVCDelegate>{
    MMDSlideItemListVC * mMDSlideItemListVC;
    MMDSelectedItemListVC * mMDSelectedItemListVC;
    MMDNumberPickerVC * mMDDateTimePickerVC;
    UIView * viewPopupView;
}
@property (nonatomic, weak) IBOutlet UIView * viewSlideDetail;
@property (nonatomic, weak) IBOutlet UIView * viewSlideDetailSubview;
@property (nonatomic, weak) IBOutlet UIView * viewSelectedItemSubview;

@property (nonatomic, weak) IBOutlet UIButton * btnExactQTY;
@property (nonatomic, weak) IBOutlet UIButton * btnOddQTY;

@property (nonatomic, weak) IBOutlet UIButton * btnByAmount;
@property (nonatomic, weak) IBOutlet UIButton * btnByPercentage;
@property (nonatomic, weak) IBOutlet UIButton * btnByFor;
@property (nonatomic, weak) IBOutlet UIButton * btnUnitAmount;
@property (nonatomic, weak) IBOutlet UIButton * btnPriceWithTax;

@property (nonatomic, weak) IBOutlet UIButton * btnApplySingle;
@property (nonatomic, weak) IBOutlet UIButton * btnApplyCase;
@property (nonatomic, weak) IBOutlet UIButton * btnApplyPack;
@property (nonatomic, weak) IBOutlet UIButton * btnApplyAll;

@property (nonatomic, weak) IBOutlet UITextField * txtBuyQTY;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountAmount;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountPercentage;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountFor;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountUnitAmount;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountPriceWithTax;

@end

@implementation MMDQTYItemListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateDiscountUnitView];
    [self updateDiscountFreeType];
    [self updateQuantityView];
    [self addItemDetailView];
    [self addSelectedItemDetailView];
    [self refreshSideInfoView];
}

-(void)updateQuantityView{
    _btnOddQTY.selected = FALSE;
    _btnExactQTY.selected = FALSE;
    if (self.objMixMatch.quantityType.intValue == MMDQuantityTypeODD) {
        _btnOddQTY.selected = TRUE;
    }
    else {
        _btnExactQTY.selected = TRUE;
    }
}

-(void)updateDiscountUnitView {

    _txtBuyQTY.text = self.objMixMatch.primaryItemQty.stringValue;
    
    if ([self.objMixMatch.isUnit boolValue] && [self.objMixMatch.isCase boolValue] && [self.objMixMatch.isPack boolValue]) {
        _btnApplyAll.selected = TRUE;
        _btnApplySingle.selected = FALSE;
        _btnApplyCase.selected = FALSE;
        _btnApplyPack.selected = FALSE;
    }
    else {
        _btnApplyAll.selected = FALSE;
        if ([_objMixMatch.isUnit boolValue]) {
            _btnApplySingle.selected = TRUE;
        }
        if ([_objMixMatch.isCase boolValue]) {
            _btnApplyCase.selected = TRUE;
        }
        if ([_objMixMatch.isPack boolValue]) {
            _btnApplyPack.selected = TRUE;
        }
    }
}
-(void)updateDiscountFreeType{
    if (self.objMixMatch.freeType.intValue == MMDFreeTypePriceWithTax) {
        _btnPriceWithTax.selected = TRUE;
        _txtDiscountPriceWithTax.text =self.objMixMatch.free.stringValue;
    }
    else if (self.objMixMatch.freeType.intValue == MMDFreeTypeUnitAmount) {
        _btnUnitAmount.selected = TRUE;
        _txtDiscountUnitAmount.text =self.objMixMatch.free.stringValue;
    }
    else if (self.objMixMatch.freeType.intValue == MMDFreeTypeFor) {
        _btnByFor.selected = TRUE;
        _txtDiscountFor.text =self.objMixMatch.free.stringValue;
    }
    else if (self.objMixMatch.freeType.intValue == MMDFreeTypePercentage) {
        _btnByPercentage.selected = TRUE;
        _txtDiscountPercentage.text = self.objMixMatch.free.stringValue;
    }
    else {
        _btnByAmount.selected = TRUE;
        _txtDiscountAmount.text = self.objMixMatch.free.stringValue;
    }
}

-(void)addItemDetailView {
    if (!mMDSlideItemListVC) {
        mMDSlideItemListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDSlideItemListVC_sid"];
        
        mMDSlideItemListVC.view.frame = _viewSlideDetailSubview.bounds;
        mMDSlideItemListVC.delegate = self;
        mMDSlideItemListVC.moc = self.moc;
        mMDSlideItemListVC.isXitemList = true;
        mMDSlideItemListVC.isMandMDiscount = FALSE;
        [self addChildViewController:mMDSlideItemListVC];
        [_viewSlideDetailSubview addSubview:mMDSlideItemListVC.view];
        [mMDSlideItemListVC didMoveToParentViewController:self];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [mMDSlideItemListVC viewWillDisappear:YES];
        });
    }
}
-(void)didSelectItemList:(NSMutableArray *) arrSelectedItems {
    if (!mMDSelectedItemListVC.arrSelectedItem) {
        mMDSelectedItemListVC.arrSelectedItem = [[NSMutableArray alloc]init];
    }
//    NSMutableArray * arrTempList = [[NSMutableArray alloc]initWithArray:mMDSelectedItemListVC.arrSelectedItem];
//    [arrTempList addObjectsFromArray:arrSelectedItems];
//    NSSet * uniqeuObject = [NSSet setWithArray:arrTempList];
    
    mMDSelectedItemListVC.arrSelectedItem = [[NSMutableArray alloc]initWithArray:arrSelectedItems];
}

-(void)willCloseItemSelectionView {
    CGRect frame = _viewSlideDetail.frame;
    if (!(frame.origin.x > 1000)) {
        [self showHideSlideView];
        [self deselectAllCategoryButton];
    }
}
-(NSMutableArray *)getSelectedItems {
    return [[NSMutableArray alloc]initWithArray:mMDSelectedItemListVC.arrSelectedItem];
}

-(void)addSelectedItemDetailView {
    if (!mMDSelectedItemListVC) {
        mMDSelectedItemListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDSelectedItemListVC_sid"];
        
        mMDSelectedItemListVC.view.frame = _viewSelectedItemSubview.bounds;
        mMDSelectedItemListVC.view.tag = 100;
        mMDSelectedItemListVC.moc = self.moc;
        mMDSelectedItemListVC.isXitemList = TRUE;
        mMDSelectedItemListVC.isMandMDiscount = false;
        if (!mMDSelectedItemListVC.arrSelectedItem) {
            mMDSelectedItemListVC.arrSelectedItem = [[NSMutableArray alloc]init];
        }
        [self addChildViewController:mMDSelectedItemListVC];
        [_viewSelectedItemSubview addSubview:mMDSelectedItemListVC.view];
//        NSArray *primaryItems = [self.objMixMatch.primaryItems allObjects];
        mMDSelectedItemListVC.arrSelectedItem = [[NSMutableArray alloc]initWithArray:self.objMixMatch.primaryItems.allObjects];
    }
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{        // return NO to disallow editing.
    [self editQtyForPackageType:textField];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self refreshSideInfoView];
}
- (void)editQtyForPackageType:(UITextField *)textField{
    
    
    NSString * strTitle;
    NumberPickerTypes pickerMode;
    NSNumber * maxLenght;
    switch (textField.tag) {
        case 10:{
            strTitle = @"QUANTITY";
            pickerMode =NumberPickerTypesQTY;
            maxLenght = nil;
            break;
        }
        case 11:{
            strTitle = @"PRICE";
            pickerMode =NumberPickerTypesPrice;
            maxLenght = @999.99f;
            [self changeDiscountProfitType:_btnByAmount];
            break;
        }
        case 12:{
            strTitle = @"PERCENTAGE";
            pickerMode =NumberPickerTypesPercentage;
            maxLenght = [NSNumber numberWithFloat:100.00f];
            [self changeDiscountProfitType:_btnByPercentage];
            break;
        }
        case 13:{
            strTitle = @"FOR";
            pickerMode =NumberPickerTypesPrice;
            maxLenght = @999.99f;
            [self changeDiscountProfitType:_btnByFor];
            break;
        }
        case 14:{
            strTitle = @"UNIT PRICE";
            pickerMode =NumberPickerTypesPrice;
            [self changeDiscountProfitType:_btnUnitAmount];
            maxLenght = @99.99f;
            break;
        }
        case 15:{
            strTitle = @"PRICE WITH TAX";
            pickerMode =NumberPickerTypesPrice;
            [self changeDiscountProfitType:_btnPriceWithTax];
            maxLenght = @999.99f;
            break;
        }
        default:
            strTitle = @"";
            pickerMode = NumberPickerTypesPercentage;
            maxLenght = 0;
            break;
    }
    [self showNumberPickerInputView:textField PickerType:pickerMode PickerTitle:strTitle maxLenght:maxLenght];
}
#pragma mark - IBActions -

-(IBAction)btnQuantityType:(UIButton *)sender {
    self.objMixMatch.quantityType = @(sender.tag);
    [self updateQuantityView];
}

-(IBAction)changeDiscountProfitType:(UIButton *)sender {
    _btnByAmount.selected = FALSE;
    _btnByPercentage.selected = FALSE;
    _btnByFor.selected = FALSE;
    _btnUnitAmount.selected = FALSE;
    _btnPriceWithTax.selected = FALSE;
    sender.selected = TRUE;
    [self refreshSideInfoView];
}

-(IBAction)changeApplyOnType:(UIButton *)sender {
    _btnApplyAll.selected = FALSE;
    _btnApplySingle.selected = FALSE;
    _btnApplyCase.selected = FALSE;
    _btnApplyPack.selected = FALSE;
    sender.selected = TRUE;
    
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

-(IBAction)btnSaveOrNext:(id)sender {
    [self saveValueIntoMMDobject];
    if (self.objMixMatch.primaryItemQty.intValue == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please enter buy quantity"];
    }
    else if (self.objMixMatch.free.floatValue == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please enter discount"];
    }
    else if (self.objMixMatch.primaryItems.allObjects.count == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please select items"];
    }
    else {
        [self pushMMDDateAndTimeVC];
    }
}

- (void)pushMMDDateAndTimeVC {
    MMDDayTimeSelectionVC * mMDDetailInfoVC =
    [[UIStoryboard storyboardWithName:@"MMDiscount"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDDayTimeSelectionVC_sid"];
    
    mMDDetailInfoVC.moc = self.moc;
    mMDDetailInfoVC.objMixMatch = self.objMixMatch;
    [self.navigationController pushViewController:mMDDetailInfoVC animated:YES];
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
    
    self.objMixMatch.primaryItemQty = @(_txtBuyQTY.text.intValue);
    
    if (_btnByAmount.selected) {
        self.objMixMatch.free = @(_txtDiscountAmount.text.floatValue);
        self.objMixMatch.freeType = @(MMDFreeTypeAmount);
    }
    else if (_btnByPercentage.selected) {
        self.objMixMatch.free = @([_txtDiscountPercentage.text floatValue]);
        self.objMixMatch.freeType = @(MMDFreeTypePercentage);
    }
    else if (_btnByFor.selected) {
        self.objMixMatch.free = @([_txtDiscountFor.text floatValue]);
        self.objMixMatch.freeType = @(MMDFreeTypeFor);
    }
    else if (_btnUnitAmount.selected) {
        self.objMixMatch.free = @([_txtDiscountUnitAmount.text floatValue]);
        self.objMixMatch.freeType = @(MMDFreeTypeUnitAmount);
    }
    else if (_btnPriceWithTax.selected) {
        self.objMixMatch.free = @([_txtDiscountPriceWithTax.text floatValue]);
        self.objMixMatch.freeType = @(MMDFreeTypePriceWithTax);
    }
    if (self.btnApplyAll.selected) {
        self.objMixMatch.isUnit = @(TRUE);
        self.objMixMatch.isCase = @(TRUE);
        self.objMixMatch.isPack = @(TRUE);
        
    }
    else {
        self.objMixMatch.isUnit = @(self.btnApplySingle.selected);
        self.objMixMatch.isCase = @(self.btnApplyCase.selected);
        self.objMixMatch.isPack = @(self.btnApplyPack.selected);
    }
    
    [self.objMixMatch removePrimaryItems: self.objMixMatch.primaryItems];
    [self.objMixMatch addPrimaryItems:[NSSet setWithArray:mMDSelectedItemListVC.arrSelectedItem]];
}
-(void)deselectAllCategoryButton {
    NSArray * arrButtonTag = @[@(100),@(101),@(102),@(103),@(104),@(105)];
    for (NSNumber * btnTag in arrButtonTag) {
        UIButton * btnCategory = [self.view viewWithTag:btnTag.integerValue];
        if ([btnCategory isKindOfClass:[UIButton class]]) {
            btnCategory.selected = FALSE;
        }
    }
}


#pragma mark - SideView -

#pragma mark IBAction


-(IBAction)changeCategoryType:(UIButton *)sender {
    [self.view endEditing:YES];
    [self deselectAllCategoryButton];
    [self refreshSideInfoView];
    sender.selected = TRUE;
    CGRect frame = _viewSlideDetail.frame;
    ItemListViewTypes newList = ItemListViewTypesItem;
    switch (sender.tag) {
        case 100:
            newList = ItemListViewTypesItem;
            break;
        case 101:
            newList = ItemListViewTypesDepartment;
            break;
        case 102:
            newList = ItemListViewTypesTag;
            break;
        case 103:
            newList = ItemListViewTypesGroup;
            break;
    }
    mMDSlideItemListVC.selectedView = newList;

    if (frame.origin.x > 1000) {
        [self ShowSlideView:nil];
    }
}

-(void)showHideSlideView {
    CGRect frame = _viewSlideDetail.frame;
    if (frame.origin.x > 1000) {
        frame.origin.x = 289;
        [mMDSlideItemListVC viewWillAppear:YES];
    }
    else {
        frame.origin.x = 1024;
        [mMDSlideItemListVC viewWillDisappear:YES];
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         _viewSlideDetail.frame = frame;
                     }
                     completion:nil];
}
-(IBAction)ShowSlideView:(id)sender {
    [self showHideSlideView];
}
-(IBAction)HideSlideView:(id)sender {
    CGRect frame = _viewSlideDetail.frame;
    if (!(frame.origin.x > 1000)) {
        [self showHideSlideView];
        [self deselectAllCategoryButton];
        [mMDSlideItemListVC viewWillDisappear:YES];
    }
}

#pragma mark - search deletage

-(void)refreshSideInfoView {
    
//    lblDiscountQTY.text = txtBuyQTY.text;
    NSString * strAmount = @"";
    if (_btnByAmount.selected) {
        strAmount = [NSString stringWithFormat:@"$ %@",_txtDiscountAmount.text];
    }
    else if (_btnByPercentage.selected) {
        strAmount = [NSString stringWithFormat:@"%@ %%",_txtDiscountPercentage.text];
    }
    else if (_btnByFor.selected) {
        strAmount = [NSString stringWithFormat:@"$ %@",_txtDiscountFor.text];
    }
    else if (_btnUnitAmount.selected) {
        strAmount = [NSString stringWithFormat:@"@ %@ $",_txtDiscountUnitAmount.text];
    }
    else if (_btnPriceWithTax.selected) {
        strAmount = [NSString stringWithFormat:@"PRICE WITH TAX %@",_txtDiscountPriceWithTax.text];
    }
    else {
        strAmount = @"Free";
    }
    NSDictionary * dictInfo = @{@"qty": _txtBuyQTY.text,@"amount": strAmount};
    mMDSlideItemListVC.resetNewInfo = dictInfo;
    mMDSelectedItemListVC.strTitleOfContainer = [NSString stringWithFormat:@"%@ QUANTITY | %@",_txtBuyQTY.text,strAmount];
}
#pragma mark - picker -
-(void)showNumberPickerInputView:(id)inputView PickerType:(NumberPickerTypes)pickerType PickerTitle:(NSString *) strPickerTitle maxLenght:(NSNumber *)maxInput{
    
    mMDDateTimePickerVC = [[MMDNumberPickerVC alloc] initWithNibName:@"MMDNumberPickerVC" bundle:nil];
    viewPopupView = [[UIView alloc]initWithFrame:self.view.bounds];
    viewPopupView.backgroundColor =[UIColor colorWithWhite:0.000 alpha:0.500];
    mMDDateTimePickerVC.view.center = viewPopupView.center;
    [self addChildViewController:mMDDateTimePickerVC];
    [viewPopupView addSubview:mMDDateTimePickerVC.view];
    [self.view addSubview:viewPopupView];
    mMDDateTimePickerVC.view.layer.cornerRadius = 8.0f;
    mMDDateTimePickerVC.Delegate = self;
    mMDDateTimePickerVC.inputView = inputView;
    mMDDateTimePickerVC.maxInput = maxInput;
    mMDDateTimePickerVC.strTitle = strPickerTitle;
    mMDDateTimePickerVC.pickerType = pickerType;
}
-(void)didEnterNumber:(NSNumber *) number inputView:(id) inputView withPickerType:(NumberPickerTypes) pickerType {
    UITextField * lblInputNumber = (UITextField *)inputView;
    if (number.floatValue > 0) {
        switch (pickerType) {
            case NumberPickerTypesQTY: {
                lblInputNumber.text = [NSString stringWithFormat:@"%@",number.stringValue];
                break;
            }
            case NumberPickerTypesPrice:
            case NumberPickerTypesPercentage: {
                lblInputNumber.text = [NSString stringWithFormat:@"%.2f",number.floatValue];
                break;
            }
        }
        [self refreshSideInfoView];
        [self didCancelEditItemPopOver];
    }
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
