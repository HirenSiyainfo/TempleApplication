//
//  MMDQTYMixAndMItemListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDQTYMixAndMItemListVC.h"
#import "MMDSlideItemListVC.h"
#import "MMDiscountListVC.h"
#import "MMDItemListVC.h"
#import "MMDMasterItemListVC.h"
#import "MMDMasterListVC.h"
#import "MMDDayTimeSelectionVC.h"
#import "MMDItemSectionVC.h"
#import "MMDSelectedItemListVC.h"
#import "MMDNumberPickerVC.h"
#import "MMDItemPreviewVC.h"
#import "MMDSlideItemListVC.h"
#import "RmsDbController.h"

@interface MMDQTYMixAndMItemListVC ()<DidSelectItemListDelegate,MMDSelectedItemListVCDelegate,MMDNumberPickerVCDelegate,MMDItemPreviewVCDelegate>{
    BOOL isXItemSelection;
    
    MMDSlideItemListVC * mMDSlideItemListVC;
    MMDSelectedItemListVC * mMDSelectedXItemListVC;
    MMDSelectedItemListVC * mMDSelectedYItemListVC;
    MMDNumberPickerVC * mMDDateTimePickerVC;
    UIView * viewPopupView;
}
@property (nonatomic, weak) IBOutlet UIView * viewSlideDetail;
@property (nonatomic, weak) IBOutlet UIView * viewSlideDetailSubview;
@property (nonatomic, weak) IBOutlet UIView * viewSelectedXYContainer;
@property (nonatomic, weak) IBOutlet UIView * viewSelectedXItemSubview;
@property (nonatomic, weak) IBOutlet UIView * viewSelectedYItemSubview;

@property (nonatomic, weak) IBOutlet UIButton * btnItemPriview;

@property (nonatomic, weak) IBOutlet UIButton * btnByAmount;
@property (nonatomic, weak) IBOutlet UIButton * btnByPercentage;
@property (nonatomic, weak) IBOutlet UIButton * btnByFree;
@property (nonatomic, weak) IBOutlet UIButton * btnByFor;
@property (nonatomic, weak) IBOutlet UIButton * btnUnitAmount;
@property (nonatomic, weak) IBOutlet UIButton * btnPriceWithTax;

//@property (nonatomic, weak) IBOutlet UIButton * btnExactQTY;
//@property (nonatomic, weak) IBOutlet UIButton * btnOddQTY;

@property (nonatomic, weak) IBOutlet UIButton * btnApplySingle;
@property (nonatomic, weak) IBOutlet UIButton * btnApplyCase;
@property (nonatomic, weak) IBOutlet UIButton * btnApplyPack;
@property (nonatomic, weak) IBOutlet UIButton * btnApplyAll;

@property (nonatomic, weak) IBOutlet UITextField * txtBuyXQTY;
@property (nonatomic, weak) IBOutlet UITextField * txtBuyYQTY;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountAmount;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountPercentage;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountFor;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountUnitAmount;
@property (nonatomic, weak) IBOutlet UITextField * txtDiscountPriceWithTax;

@end

@implementation MMDQTYMixAndMItemListVC

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
    [self addItemDetailView];
    [self addSelectedItemDetailView];
    [self reSetItemContainerTitle];
    _txtBuyXQTY.text = self.objMixMatch.secondaryItemQty.stringValue;
    _txtBuyYQTY.text = self.objMixMatch.primaryItemQty.stringValue;
    [self updateDiscountFreeType];
    [self didDeleteItemInContainer];
//    [self updateQuantityView];
    [self updateDiscountUnitView];
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
    else if (self.objMixMatch.freeType.intValue == MMDFreeTypeFree) {
        _btnByFree.selected = TRUE;
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

//-(void)updateQuantityView{
//    _btnOddQTY.selected = FALSE;
//    _btnExactQTY.selected = FALSE;
//    if (self.objMixMatch.quantityType.intValue == MMDQuantityTypeODD) {
//        _btnOddQTY.selected = TRUE;
//    }
//    else {
//        _btnExactQTY.selected = TRUE;
//    }
//}

-(void)updateDiscountUnitView {
    
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

-(void)addItemDetailView {
    if (!mMDSlideItemListVC) {
        mMDSlideItemListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDSlideItemListVC_sid"];
        
        mMDSlideItemListVC.view.frame = _viewSlideDetailSubview.bounds;
        mMDSlideItemListVC.delegate = self;
        mMDSlideItemListVC.isMandMDiscount = TRUE;
        mMDSlideItemListVC.moc = self.moc;
        [self addChildViewController:mMDSlideItemListVC];
        [_viewSlideDetailSubview addSubview:mMDSlideItemListVC.view];
    }
}
-(void)didSelectItemList:(NSMutableArray *) arrSelectedItems {
    if (isXItemSelection) {
        if (!mMDSelectedXItemListVC.arrSelectedItem) {
            mMDSelectedXItemListVC.arrSelectedItem = [[NSMutableArray alloc]init];
        }
        NSMutableArray * arrTempList = [[NSMutableArray alloc]initWithArray:mMDSelectedXItemListVC.arrSelectedItem];
        [arrTempList addObjectsFromArray:arrSelectedItems];
        NSSet * uniqeuObject = [NSSet setWithArray:arrTempList];
        
        mMDSelectedXItemListVC.arrSelectedItem = [[NSMutableArray alloc]initWithArray:uniqeuObject.allObjects];
    }
    else {
        if (!mMDSelectedYItemListVC.arrSelectedItem) {
            mMDSelectedYItemListVC.arrSelectedItem = [[NSMutableArray alloc]init];
        }
        NSMutableArray * arrTempList = [[NSMutableArray alloc]initWithArray:mMDSelectedYItemListVC.arrSelectedItem];
        [arrTempList addObjectsFromArray:arrSelectedItems];
        NSSet * uniqeuObject = [NSSet setWithArray:arrTempList];
        
        mMDSelectedYItemListVC.arrSelectedItem = [[NSMutableArray alloc]initWithArray:uniqeuObject.allObjects];
    }
    if (mMDSelectedYItemListVC.arrSelectedItem.count > 0 && mMDSelectedXItemListVC.arrSelectedItem.count > 0) {
        _btnItemPriview.hidden = FALSE;
    }
    else {
        _btnItemPriview.hidden = TRUE;
    }

}

-(NSMutableArray *)getSelectedItems {
    if (isXItemSelection) {
        return [[NSMutableArray alloc]initWithArray:mMDSelectedXItemListVC.arrSelectedItem];
    }
    else {
        return [[NSMutableArray alloc]initWithArray:mMDSelectedYItemListVC.arrSelectedItem];
    }
}

-(void)addSelectedItemDetailView {
    if (!mMDSelectedXItemListVC) {
        mMDSelectedXItemListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDSelectedItemListVC_sid"];
        
        mMDSelectedXItemListVC.view.frame = _viewSelectedXItemSubview.bounds;
        mMDSelectedXItemListVC.Delegate = self;
        mMDSelectedXItemListVC.view.tag = 500;
        mMDSelectedXItemListVC.isMandMDiscount = TRUE;
        mMDSelectedXItemListVC.moc = self.moc;
        mMDSelectedXItemListVC.isXitemList = true;
        mMDSelectedXItemListVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        [self addChildViewController:mMDSelectedXItemListVC];
        [_viewSelectedXItemSubview addSubview:mMDSelectedXItemListVC.view];
        mMDSelectedXItemListVC.arrSelectedItem = [[NSMutableArray alloc]initWithArray:(self.objMixMatch.secondaryItems).allObjects];
    }
    if (!mMDSelectedYItemListVC) {
        mMDSelectedYItemListVC =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDSelectedItemListVC_sid"];
        
        mMDSelectedYItemListVC.view.frame = _viewSelectedYItemSubview.bounds;
        mMDSelectedYItemListVC.Delegate = self;
        mMDSelectedYItemListVC.isMandMDiscount = TRUE;
        mMDSelectedYItemListVC.isXitemList = false;
        mMDSelectedYItemListVC.moc = self.moc;
        mMDSelectedYItemListVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        [self addChildViewController:mMDSelectedYItemListVC];
        [_viewSelectedYItemSubview addSubview:mMDSelectedYItemListVC.view];
        mMDSelectedYItemListVC.arrSelectedItem = [[NSMutableArray alloc]initWithArray:(self.objMixMatch.primaryItems).allObjects];
    }
}
-(void)reSetItemContainerTitle {
    NSString * strAmount = @"";
    if (_btnByAmount.selected) {
        strAmount = [NSString stringWithFormat:@"$ %@",_txtDiscountAmount.text];
    }
    else if (_btnByPercentage.selected) {
        strAmount = [NSString stringWithFormat:@"%@ %%",_txtDiscountPercentage.text];
    }
    else if (_btnByFor.selected) {
        strAmount = [NSString stringWithFormat:@"FOR $ %@",_txtDiscountFor.text];
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
    mMDSelectedXItemListVC.strTitleOfContainer = [NSString stringWithFormat:@"SELECTION | %@ QUANTITY | %@",_txtBuyXQTY.text,strAmount];
    mMDSelectedYItemListVC.strTitleOfContainer = [NSString stringWithFormat:@"SELECTION | %@ QUANTITY | %@",_txtBuyYQTY.text,strAmount];
}
-(void)isFullScreenView:(BOOL) isFullscreen isXitemContainer:(BOOL)isXContainer{
    UIView * viewToChange;
    CGRect frame = _viewSelectedXYContainer.bounds;
    if (isXContainer) {
        viewToChange = _viewSelectedXItemSubview;
        if (!isFullscreen) {
            frame.origin.y = 0;
            frame.size.height = _viewSelectedXYContainer.frame.size.height/2;
        }
    }
    else {
        viewToChange = _viewSelectedYItemSubview;
        if (!isFullscreen) {
            frame.origin.y = _viewSelectedXYContainer.frame.size.height/2;
            frame.size.height = _viewSelectedXYContainer.frame.size.height/2;
        }
    }
    [_viewSelectedXYContainer bringSubviewToFront:viewToChange];
    [UIView animateWithDuration:0.5 animations:^{
        viewToChange.frame = frame;
    }];
}

-(void)didDeleteItemInContainer {
    if (mMDSelectedYItemListVC.arrSelectedItem.count > 0 && mMDSelectedXItemListVC.arrSelectedItem.count > 0) {
        _btnItemPriview.hidden = FALSE;
    }
    else {
        _btnItemPriview.hidden = TRUE;
    }
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self editQtyForPackageType:textField];
    return NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self refreshSideInfoView];
    [self reSetItemContainerTitle];
}

- (void)editQtyForPackageType:(UITextField *)textField{
    
    
    NSString * strTitle;
    NumberPickerTypes pickerMode;
    NSNumber * maxLenght;
    switch (textField.tag) {
        case 10:{
            strTitle = @"X ITEM QUANTITY";
            pickerMode =NumberPickerTypesQTY;
            maxLenght = nil;
            break;
        }
        case 20:{
            strTitle = @"Y ITEM QUANTITY";
            pickerMode =NumberPickerTypesQTY;
            maxLenght = nil;
            break;
        }
        case 11:{
            strTitle = @"PRICE";
            pickerMode =NumberPickerTypesPrice;
            [self changeDiscountProfitType:_btnByAmount];
            maxLenght = @999.99f;
            break;
        }
        case 12:{
            strTitle = @"PERCENTAGE";
            pickerMode =NumberPickerTypesPercentage;
            maxLenght = @99.99f;
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

-(IBAction)changeDiscountProfitType:(UIButton *)sender {
    _btnByAmount.selected = FALSE;
    _btnByPercentage.selected = FALSE;
    _btnByFree.selected = FALSE;
    _btnByFor.selected = FALSE;
    _btnUnitAmount.selected = FALSE;
    _btnPriceWithTax.selected = FALSE;
    sender.selected = TRUE;
    [self refreshSideInfoView];
    [self reSetItemContainerTitle];
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
//-(IBAction)btnQuantityType:(UIButton *)sender {
//    self.objMixMatch.quantityType = @(sender.tag);
//    [self updateQuantityView];
//}
-(IBAction)changeApplyOnType:(UIButton *)sender {
    _btnApplyAll.selected = FALSE;
    _btnApplySingle.selected = FALSE;
    _btnApplyCase.selected = FALSE;
    _btnApplyPack.selected = FALSE;
    sender.selected = TRUE;
    
}
-(IBAction)btnEditItemTapped:(id)sender {
    MMDItemPreviewVC * mMDItemPreviewVC =
    [[UIStoryboard storyboardWithName:@"MMDiscount"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDItemPreviewVC_sid"];
    mMDItemPreviewVC.arrXitems = [[NSMutableArray alloc] initWithArray:mMDSelectedXItemListVC.arrSelectedItem];
    mMDItemPreviewVC.arrYitems = [[NSMutableArray alloc] initWithArray:mMDSelectedYItemListVC.arrSelectedItem];
    mMDItemPreviewVC.Delegate = self;
    [self.navigationController pushViewController:mMDItemPreviewVC animated:YES];
}
-(void)didSelectItemListEditWithNewXItems:(NSMutableArray *) arrSelectedXItems WithNewYItems:(NSMutableArray *) arrSelectedYItems {
    mMDSelectedXItemListVC.arrSelectedItem = arrSelectedXItems;
    [mMDSelectedXItemListVC.tblSelectedItemList reloadData];
    
    mMDSelectedYItemListVC.arrSelectedItem = arrSelectedYItems;
    [mMDSelectedYItemListVC.tblSelectedItemList reloadData];
}
-(void)willCloseItemSelectionView {
    CGRect frame = _viewSlideDetail.frame;
    if (!(frame.origin.x > 1000)) {
        [self showHideSlideView];
        [self deselectAllCategoryButton];
    }
}

-(IBAction)btnSaveOrNext:(id)sender {
    [self saveValueIntoMMDobject];
    if ((self.objMixMatch.secondaryItemQty).intValue == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please enter buy quantity"];
    }
    else if (self.objMixMatch.primaryItemQty.intValue == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please enter get quantity"];
    }
    else if (self.objMixMatch.free.floatValue == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please enter discount"];
    }
    else if (self.objMixMatch.secondaryItems.allObjects.count == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please select buy items"];
    }
    else if (self.objMixMatch.primaryItems.allObjects.count == 0) {
        [self showMessageWithTitle:nil withMessage:@"Please select get items"];
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
    
    self.objMixMatch.quantityType = @(MMDQuantityTypeExact);
    self.objMixMatch.secondaryItemQty = @(_txtBuyXQTY.text.intValue);
    self.objMixMatch.primaryItemQty = @(_txtBuyYQTY.text.intValue);
    
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
    else {
        self.objMixMatch.free = @(100.0f);
        self.objMixMatch.freeType = @(MMDFreeTypeFree);
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
    [self.objMixMatch removeSecondaryItems:self.objMixMatch.secondaryItems];
    [self.objMixMatch addPrimaryItems:[NSSet setWithArray:mMDSelectedYItemListVC.arrSelectedItem]];
    [self.objMixMatch addSecondaryItems:[NSSet setWithArray:mMDSelectedXItemListVC.arrSelectedItem]];
}
-(void)deselectAllCategoryButton {
    NSArray * arrButtonTag = @[@(100),@(101),@(102),@(103),@(200),@(201),@(202),@(203)];
    for (NSNumber * btnTag in arrButtonTag) {
        UIButton * btnCategory = [self.view viewWithTag:btnTag.integerValue];
        if ([btnCategory isKindOfClass:[UIButton class]]) {
            btnCategory.selected = FALSE;
        }
        else {
            NSLog(@"%@",btnCategory);
        }
    }
}


#pragma mark - SideView -

#pragma mark IBAction


-(IBAction)changeCategoryType:(UIButton *)sender {
    [self.view endEditing:YES];
    [self deselectAllCategoryButton];
    [self refreshSideInfoView];
    [self reSetItemContainerTitle];
    if (sender.tag < 200) {
        isXItemSelection = TRUE;
    }
    else {
        isXItemSelection = FALSE;
    }
    sender.selected = TRUE;
    CGRect frame = _viewSlideDetail.frame;
    ItemListViewTypes newList = ItemListViewTypesItem;
    switch (sender.tag) {
        case 100:
        case 200:
            newList = ItemListViewTypesItem;
            break;
        case 101:
        case 201:
            newList = ItemListViewTypesDepartment;
            break;
        case 102:
        case 202:
            newList = ItemListViewTypesTag;
            break;
        case 103:
        case 203:
            newList = ItemListViewTypesGroup;
            break;
    }
    mMDSlideItemListVC.selectedView = newList;
    
    if (frame.origin.x > 1000) {
        [self ShowSlideView:nil];
    }
    mMDSlideItemListVC.isXitemList = isXItemSelection;
}


-(void)showHideSlideView {
    CGRect frame = _viewSlideDetail.frame;
    if (frame.origin.x > 1000) {
        frame.origin.x = 289;
    }
    else {
        frame.origin.x = 1024;
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
    }
}

#pragma mark - search deletage

-(void)refreshSideInfoView {

    NSString * strAmount = @"";
    
    if (_btnByAmount.selected) {
        strAmount = [NSString stringWithFormat:@"$ %@",_txtDiscountAmount.text];
    }
    else if (_btnByPercentage.selected) {
        strAmount = [NSString stringWithFormat:@"%@ %%",_txtDiscountPercentage.text];
    }
    else if (_btnByFor.selected) {
        strAmount = [NSString stringWithFormat:@"FOR $ %@",_txtDiscountFor.text];
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

    NSDictionary * dictInfo = @{@"qty": _txtBuyXQTY.text,@"amount": strAmount};
    mMDSlideItemListVC.resetNewInfo = dictInfo;
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
    if (number.floatValue > 0) {
        UITextField * lblInputNumber = (UITextField *)inputView;
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
        [self reSetItemContainerTitle];
        
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
