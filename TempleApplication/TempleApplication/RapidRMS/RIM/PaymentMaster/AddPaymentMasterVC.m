//
//  AddPaymentMasterVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddPaymentMasterButtonCell.h"
#import "AddPaymentMasterCommonCustomCell.h"
#import "AddPaymentMasterVC.h"
#import "Configuration.h"
#import "NSString+Validation.h"
#import "RapidPaymentMaster.h"
#import "RmsDbController.h"
#import "SelectUserOptionVC.h"
#import "UITableView+AddBorder.h"


@interface AddPaymentMasterVC ()<AddPaymentMasterButtonCellDelegate , AddPaymentMasterCommonCustomCellDelegate, UpdateDelegate,UITableViewDelegate , UITableViewDataSource>
{
    NSArray *addPaymentConfigureArray;
    RapidPaymentMaster *rapidPaymentMaster;
    NSArray *totalCardIntTypeArray;
    
}
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, strong) UpdateManager * updateManager;
@property (nonatomic, weak) RmsActivityIndicator * activityIndicator;
@property (nonatomic, strong) Configuration *objConfiguration;


@property (nonatomic, weak) IBOutlet UITableView *addAddPaymentMasterTableView;

@property (nonatomic, weak) IBOutlet UIButton *deletePaymentMasterButton;
@property (nonatomic, weak) IBOutlet UIButton * btnDelete;

@property (nonatomic, strong) RapidWebServiceConnection * paymentInsertWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * paymentUpdateWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * paymentDeleteWebserviceConnection;

@end

@implementation AddPaymentMasterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
        
    self.paymentInsertWebserviceConnection = [[RapidWebServiceConnection alloc] init];
    self.paymentUpdateWebserviceConnection = [[RapidWebServiceConnection alloc] init];
    self.paymentDeleteWebserviceConnection = [[RapidWebServiceConnection alloc] init];

    _objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    if (self.objConfiguration.houseCharge.boolValue)
    {
        totalCardIntTypeArray = @[@"Debit",@"Credit",@"Cash",@"Check",@"Account",@"Gift Card",@"EBT/Food Stamp",@"HouseCharge", @"RapidRMS Gift Card",@"Other"];
    }
    else
    {
        totalCardIntTypeArray = @[@"Debit",@"Credit",@"Cash",@"Check",@"Account",@"Gift Card",@"EBT/Food Stamp", @"RapidRMS Gift Card",@"Other"];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    rapidPaymentMaster = [[RapidPaymentMaster alloc] init];
    if (self.tenderPay) {
        [rapidPaymentMaster setupRapidPaymentMaster:self.tenderPay.tenderPayDictionary];
        if (rapidPaymentMaster.flgSurcharge)
        {
            addPaymentConfigureArray = @[@(PaymentNameField),@(PaymentCodeField),@(PaymentTypeField),@(SurchargeCheckBox),@( SurchargeDollorType),@(SurchargePercentageType),@(SurchargeAmount),@(DropCheckBox)];
  
        }
        else
        {
            addPaymentConfigureArray = @[@(PaymentNameField),@(PaymentCodeField),@(PaymentTypeField),@(SurchargeCheckBox),@(DropCheckBox)];
        }
    }
    else
    {
        addPaymentConfigureArray = @[@(PaymentNameField),@(PaymentCodeField),@(PaymentTypeField),@(SurchargeCheckBox),@(DropCheckBox)];

        _deletePaymentMasterButton.enabled = NO;
    }
//    [_addAddPaymentMasterTableView reloadData];
    [self setDeleteButtonEnableOrDisble];
}

- (void)setDeleteButtonEnableOrDisble
{
    if (rapidPaymentMaster.payId.integerValue != 0) {
        self.btnDelete.enabled = YES;
    }
    else
    {
        self.btnDelete.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return addPaymentConfigureArray.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView defaultTableHeaderView:@"payment details"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (IsPad()) {
        return RIMHeaderHeight();
    }
    else {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:0];
        if ([cell isKindOfClass:[AddPaymentMasterCommonCustomCell class]]) {
            AddPaymentMasterCommonCustomCell * newCell = (AddPaymentMasterCommonCustomCell *)cell;
            [tableView arrangeHeightOfViews:@[newCell.txtValue] WillDisplayCell:cell forRowAtIndexPath:indexPath];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    enum AddPaymentField addPaymentField = [addPaymentConfigureArray[indexPath.row] integerValue];
    
    switch (addPaymentField) {
        case PaymentNameField:
            cell = [self configurePaymentCommonCell:indexPath withKeyName:@"PAYMENT NAME" withValue:@""  placeholder:@"Please Enter Payment Name" addPaymentField:PaymentNameField];
            break;
        case PaymentCodeField:
            cell = [self configurePaymentCommonCell:indexPath withKeyName:@"PAYMENT CODE" withValue:@"" placeholder:@"Please Enter Payment Code" addPaymentField:PaymentCodeField];
            break;
            
        case PaymentTypeField:
            cell = [self configurePaymentCommonCell:indexPath withKeyName:@"PAYMENT TYPE" withValue:@"" placeholder:@"Select" addPaymentField:PaymentTypeField];
            break;
            
        case SurchargeCheckBox:
            cell = [self configurePaymentButtonCell:indexPath withKeyName:@"SURCHARGE" withValue:@"" addPaymentField:SurchargeCheckBox];
            
            break;
            
        case SurchargeDollorType:
            cell = [self configurePaymentButtonCell:indexPath withKeyName:@"" withValue:@"$" addPaymentField:SurchargeDollorType];
            
            break;
            
        case SurchargePercentageType:
            cell = [self configurePaymentButtonCell:indexPath withKeyName:@"" withValue:@"%" addPaymentField:SurchargePercentageType];
            
            break;
            
        case SurchargeAmount:{
            cell = [self configurePaymentCommonCell:indexPath withKeyName:@"AMOUNT" withValue:@"" placeholder:@"Please Enter Amount" addPaymentField:SurchargeAmount];
            AddPaymentMasterCommonCustomCell *paymentMasterListCell = (AddPaymentMasterCommonCustomCell *)cell;
            paymentMasterListCell.pickerType = NumberPadPickerTypesPrice;
            if ([rapidPaymentMaster.surchargeType isEqualToString:@"0"]) {
                paymentMasterListCell.pickerType = NumberPadPickerTypesPercentage;
            }
            
            break;
        }
        case DropCheckBox:
            cell = [self configurePaymentButtonCell:indexPath withKeyName:@"DROP AMOUNT" withValue:@"" addPaymentField:DropCheckBox];
            break;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell* )configurePaymentCommonCell:(NSIndexPath *)indexPath  withKeyName:(NSString *)key withValue:(NSString *)value placeholder:(NSString *)strPlaceHolder addPaymentField :(AddPaymentField)addpaymentField
{
    static NSString *CellIdentifier = @"AddPaymentMasterCommonCustomCell";
    AddPaymentMasterCommonCustomCell *paymentMasterListCell = [_addAddPaymentMasterTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    paymentMasterListCell.backgroundColor = [UIColor clearColor];
    paymentMasterListCell.currentCellIndexpath = indexPath;
    paymentMasterListCell.addPaymentMasterCommonCustomCellDelegate = self;
    paymentMasterListCell.name.text = key;
    paymentMasterListCell.txtValue.text = value;
    paymentMasterListCell.txtValue.placeholder = strPlaceHolder;
    [paymentMasterListCell updatePaymentMasterCustomCell:rapidPaymentMaster addPaymentField:addpaymentField];

    return paymentMasterListCell;
}

- (UITableViewCell* )configurePaymentButtonCell:(NSIndexPath *)indexPath  withKeyName:(NSString *)key withValue:(NSString *)value addPaymentField :(AddPaymentField)addpaymentField
{
    static NSString *CellIdentifier = @"AddPaymentMasterButtonCell";
    AddPaymentMasterButtonCell *paymentMasterListCell = [_addAddPaymentMasterTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    paymentMasterListCell.backgroundColor = [UIColor clearColor];
    paymentMasterListCell.currentCellIndexpath = indexPath;
    paymentMasterListCell.addPaymentMasterButtonCellDelegate = self;
    
    paymentMasterListCell.lblName.text = key;

    [paymentMasterListCell.btnCheckBox setTitle:value forState:UIControlStateNormal];
    [paymentMasterListCell updatePaymentMasterButtonCell:rapidPaymentMaster addPaymentField:addpaymentField];
    
    return paymentMasterListCell;
}



-(void)addSurchargeAtIndexPath:(NSIndexPath *)indexPath
{
    enum AddPaymentField addPaymentField = [addPaymentConfigureArray[indexPath.row] integerValue];
    
    switch (addPaymentField) {
            
        case PaymentNameField:
            break;
        case PaymentCodeField:
            break;
            
        case PaymentTypeField:
            break;
            
        case SurchargeCheckBox:
            [self updateSurcahrgeValueInRapidPaymentMaster];
            break;
            
        case SurchargeDollorType:
            rapidPaymentMaster.surchargeType = @"1";

            break;
            
        case SurchargePercentageType:
            rapidPaymentMaster.surchargeType = @"0";
            break;
            
        case SurchargeAmount:
            break;
            
        case DropCheckBox:
            if (rapidPaymentMaster.chkDropAmt.boolValue == TRUE) {
                rapidPaymentMaster.chkDropAmt = @(0);
            }
            else
            {
                rapidPaymentMaster.chkDropAmt = @(1);
            }
            break;
            
        default:
            break;
    }
    [_addAddPaymentMasterTableView reloadData];

}
-(void)addTextFieldAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)strValue
{
    enum AddPaymentField addPaymentField = [addPaymentConfigureArray[indexPath.row] integerValue];
    
    switch (addPaymentField) {
            
        case PaymentNameField:
            rapidPaymentMaster.paymentName = strValue;
            break;
        case PaymentCodeField:
            rapidPaymentMaster.payCode = strValue;
            break;
            
        case PaymentTypeField:
        {
            [self.view endEditing:YES];
            SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:totalCardIntTypeArray SelectedObject:rapidPaymentMaster.cardIntType SelectionComplete:^(NSArray *arrSelection) {
                rapidPaymentMaster.cardIntType = arrSelection[0];
                [_addAddPaymentMasterTableView reloadData];
            } SelectionColse:^(UIViewController *popUpVC) {
                [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
            }];

            [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:nil ArrowDirection:(UIPopoverArrowDirection)nil];
        }
            break;
            
        case SurchargeCheckBox:
            break;
            
        case SurchargeDollorType:
            break;
            
        case SurchargePercentageType:
            break;
            
        case SurchargeAmount:
            rapidPaymentMaster.surchargeAmount = @(strValue.floatValue);
            break;
            
        case DropCheckBox:
            break;
            
        default:
            break;
    }
}

-(void)updateSurcahrgeValueInRapidPaymentMaster
{
    rapidPaymentMaster.flgSurcharge = !rapidPaymentMaster.flgSurcharge;
    if (rapidPaymentMaster.flgSurcharge == TRUE) {
        addPaymentConfigureArray = @[@(PaymentNameField),@(PaymentCodeField),@(PaymentTypeField),@(SurchargeCheckBox),@( SurchargeDollorType),@(SurchargePercentageType),@(SurchargeAmount),@(DropCheckBox)];
    }
    else
    {
        addPaymentConfigureArray = @[@(PaymentNameField),@(PaymentCodeField),@(PaymentTypeField),@(SurchargeCheckBox),@(DropCheckBox)];
    }
}
-(IBAction)btnCloseClicked:(id)sender
{
    [Appsee addEvent:kRIMPaymentMasterClose];
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)updateTenderPaymentMode {
    NSMutableDictionary *tenderPaymentDictionary = [[NSMutableDictionary alloc] init];
    tenderPaymentDictionary[@"PaymentData"] = rapidPaymentMaster.rapidPaymentMasterDictionary;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateTenderPaymentModeResponse:response error:error];
        });
    };
    
    self.paymentUpdateWebserviceConnection = [self.paymentUpdateWebserviceConnection initWithRequest:KURL actionName:WSM_UPDATE_PAYMENT params:tenderPaymentDictionary completionHandler:completionHandler];
}

-(void)updateTenderPaymentModeResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {

                [Appsee addEvent:@"RIMPaymentUpdateWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"Payment has been added successfully"}];
                NSArray *arrPaymentMaster  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.updateManager updatePaymentMaster:arrPaymentMaster moc:privateContextObject];
                [UpdateManager saveContext:privateContextObject];
                AddPaymentMasterVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Payment has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                [Appsee addEvent:@"RIMPaymentUpdateWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"payment not updated, try again."}];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Payment not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}
-(void)insertTenderPaymentMode {
    
    NSMutableDictionary *tenderPaymentDictionary = [[NSMutableDictionary alloc] init];
    tenderPaymentDictionary[@"PaymentData"] = rapidPaymentMaster.rapidPaymentMasterDictionary;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self insertTenderPaymentModeResponse:response error:error];
        });
    };
    
    self.paymentInsertWebserviceConnection = [self.paymentInsertWebserviceConnection initWithRequest:KURL actionName:WSM_INSERT_PAYMENT params:tenderPaymentDictionary completionHandler:completionHandler];
}
-(void)insertTenderPaymentModeResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                [Appsee addEvent:@"RIMPaymentInsertWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"Payment has been added successfully"}];
                
                NSArray *arrPaymentMaster  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.updateManager updatePaymentMaster:arrPaymentMaster moc:privateContextObject];
                [UpdateManager saveContext:privateContextObject];
                
                AddPaymentMasterVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    if (self.navigationController)
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else{
                        [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                    }
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Payment has been added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                [Appsee addEvent:@"RIMPaymentInsertWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"payment not added, try again."}];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Payment not added, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

-(IBAction)deletePaymentMaster:(id)sender
{
    [self.rmsDbController playButtonSound];
    
    AddPaymentMasterVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [myWeakReference deletePaymentMaster];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this Payment Master?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (void)deletePaymentMaster
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    
    NSMutableDictionary *tenderPaymentDataDictionary = [[NSMutableDictionary alloc] init];
    tenderPaymentDataDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    tenderPaymentDataDictionary[@"PayId"] = self.tenderPay.payId.stringValue;
    
    NSMutableDictionary *tenderPaymentDictionary = [[NSMutableDictionary alloc] init];
    tenderPaymentDictionary[@"PaymentData"] = tenderPaymentDataDictionary;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deletePaymentResponse:response error:error];
        });
    };
    
    self.paymentDeleteWebserviceConnection = [self.paymentDeleteWebserviceConnection initWithRequest:KURL actionName:WSM_DELETE_PAYMENT params:tenderPaymentDictionary completionHandler:completionHandler];
}

-(void)deletePaymentResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                [Appsee addEvent:@"RIMPaymentDeleteWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"Payment has been deleted successfully"}];
                
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.updateManager deletePaymentMaster:self.tenderPay.payId.stringValue moc:privateContextObject];
                [UpdateManager saveContext:privateContextObject];
                
                AddPaymentMasterVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Payment has been deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                [Appsee addEvent:@"RIMPaymentDeleteWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"Payment not deleted, try again."}];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Payment not deleted, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

-(IBAction)btnSaveClicked:(id)sender
{
    rapidPaymentMaster.paymentName = [NSString trimSpacesFromStartAndEnd:rapidPaymentMaster.paymentName];
    rapidPaymentMaster.payCode = [NSString trimSpacesFromStartAndEnd:rapidPaymentMaster.payCode];
    if (rapidPaymentMaster.paymentName == nil || !(rapidPaymentMaster.paymentName.length > 0)) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please enter Payment Name" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    
    else if (rapidPaymentMaster.payCode == nil || !(rapidPaymentMaster.payCode.length > 0)) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please enter Payment Code" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    else if (rapidPaymentMaster.cardIntType == nil || !(rapidPaymentMaster.cardIntType.length > 0)) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please select Payment Type" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    if (![self isPaymentNameIsValid]) {
        [self showAlertForUniquePayment:@"Please enter Unique Payment Name"];
        return;
    }
    if (![self isPaymentCodeIsValid]) {
        [self showAlertForUniquePayment:@"Please enter Unique Payment Code"];
        return;
    }
    [self.rmsDbController playButtonSound];

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];

    if (self.tenderPay) {
        [self updateTenderPaymentMode];
    }
    else
    {
        [self insertTenderPaymentMode];
    }
}

-(BOOL)isPaymentNameIsValid{
    NSString *deptName = [rapidPaymentMaster.paymentName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate * predicate = [self createPradicateFor:@"paymentName" withValue:deptName];
    return [self isValidPaymentForPredicate:predicate];
}

-(BOOL)isPaymentCodeIsValid{
    NSString *deptCode = [rapidPaymentMaster.payCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate * predicate = [self createPradicateFor:@"payCode" withValue:deptCode];
    return [self isValidPaymentForPredicate:predicate];
}

-(NSPredicate *)createPradicateFor:(NSString *)strKey withValue:(NSString *)strValue {
    NSPredicate * predicate;
    if (self.tenderPay) {
        predicate  = [NSPredicate predicateWithFormat:@"%K == [cd]%@ && payId != %@",strKey,strValue,self.tenderPay.payId];
    }
    else {
        predicate  = [NSPredicate predicateWithFormat:@"%K == [cd]%@",strKey,strValue];
    }
    return predicate;
}
-(BOOL)isValidPaymentForPredicate:(NSPredicate *) predicate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    if ([UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest] == 0) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}

- (void)showAlertForUniquePayment:(NSString *)strMessage
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
      //  [textField becomeFirstResponder];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

@end
