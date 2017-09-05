//
//  AddTaxMasterVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 25/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddTaxMasterVC.h"
#import "NSString+Validation.h"
#import "RapidTaxMaster.h"
#import "RIMNumberPadPopupVC.h"
#import "RmsDbController.h"
#import "UpdateManager.h"


#define AMOUNT_CHARECTERS @"0123456789."

@interface AddTaxMasterVC ()<UpdateDelegate,UITextFieldDelegate>
{
    NSMutableArray *taxMasterArray;
    RapidTaxMaster *rapidTaxMaster;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * taxResultController;

@property (nonatomic, weak) RmsActivityIndicator * activityIndicator;
@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, strong) UpdateManager * updateManager;

@property (nonatomic, strong) RapidWebServiceConnection * taxInsertWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * taxUpdateWebserviceConnection;
@property (nonatomic, strong) RapidWebServiceConnection * taxDeleteWebserviceConnection;

@property (nonatomic, weak) IBOutlet UILabel *taxPercentageIndicator;
@property (nonatomic, weak) IBOutlet UIButton * btnSave;
@property (nonatomic, weak) IBOutlet UIButton * btnDelete;
@property (nonatomic, weak) IBOutlet UIButton * btnClose;
@property (nonatomic, weak) IBOutlet UIButton * btnDoller;
@property (nonatomic, weak) IBOutlet UIButton * btnPersentage;

@property (nonatomic, weak) IBOutlet UILabel * lblDelete;

@property (nonatomic, weak) IBOutlet UITextField * txtTax;
@property (nonatomic, weak) IBOutlet UITextField * txtAmount;

@property (nonatomic, strong) NSDictionary * taxMasterDict;
@property (nonatomic, strong) NSMutableDictionary *updateTaxMasterDict;


@end

@implementation AddTaxMasterVC
@synthesize taxMasterDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    self.taxInsertWebserviceConnection = [[RapidWebServiceConnection alloc] init];
    self.taxUpdateWebserviceConnection = [[RapidWebServiceConnection alloc] init];
    self.taxDeleteWebserviceConnection = [[RapidWebServiceConnection alloc] init];
    
    self.txtAmount.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.txtAmount.bounds.size.height)];
    self.txtAmount.leftViewMode = UITextFieldViewModeAlways;


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    rapidTaxMaster = [[RapidTaxMaster alloc] init];
    if (self.taxMaster)
    {
        taxMasterDict = self.taxMaster.taxMasterDictionary;
        [rapidTaxMaster  configureRapidTaxMasterFromDictionary:taxMasterDict];
        [self updateViewWithUpdateDetail:[taxMasterDict mutableCopy]];
    }
    else
    {
        self.btnDoller.selected = YES;
        rapidTaxMaster.Type = @"1";
        self.txtAmount.text = @"0.00";
        if (self.btnDoller.selected)
        {
            self.txtAmount.text = @"0.00";
            self.txtAmount.userInteractionEnabled = NO;
        }
        else
        {
            self.txtAmount.userInteractionEnabled = YES;

        }
    }
    [self setDeleteButtonEnableOrDisbleForTaxMaster];
}

- (void)setDeleteButtonEnableOrDisbleForTaxMaster
{
    if (rapidTaxMaster.TaxId.integerValue != 0) {
        self.btnDelete.enabled = YES;
        self.lblDelete.enabled = YES;
    }
    else
    {
        self.btnDelete.enabled = NO;
        self.lblDelete.enabled = NO;
    }
}

-(IBAction)btnDollerClicked:(id)sender
{
    [self.view endEditing:YES];
    self.btnDoller.selected = TRUE;
    if (self.btnDoller.selected)
    {
        self.btnPersentage.selected = NO;
        rapidTaxMaster.Type = @"1";
        self.txtAmount.text = @"0.00";
        self.txtAmount.userInteractionEnabled = NO;
        _taxPercentageIndicator.hidden = YES;
    }
    else
    {
        self.btnPersentage.selected = YES;
    }
}

-(IBAction)btnPersentageClicked:(id)sender
{
    [self.view endEditing:YES];
    self.btnPersentage.selected = TRUE;
    if (self.btnPersentage.selected)
    {
        rapidTaxMaster.Type = @"0";
        self.txtAmount.userInteractionEnabled = YES;
        self.btnDoller.selected = NO;
        _taxPercentageIndicator.hidden = NO;
    }
    else
    {
        self.btnDoller.selected = YES;
    }
}

-(IBAction)btnCloseClicked:(id)sender
{
    [Appsee addEvent:kRIMTaxMasterClose];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)btnSaveClicked:(id)sender
{
    [self.view endEditing:YES];
    [Appsee addEvent:kRIMTaxMasterSave];
    if([NSString trimSpacesFromStartAndEnd:self.txtTax.text].length == 0)
    {
        [self showTaxAlertView:@"Please enter Tax name"];
        return;
    }
    else if([NSString trimSpacesFromStartAndEnd:self.txtAmount.text].length == 0)
    {
        [self showTaxAlertView:@"Please enter Amount"];
        return;
    }
    
    rapidTaxMaster.TAXNAME = [NSString trimSpacesFromStartAndEnd:self.txtTax.text];
    if ([rapidTaxMaster.Type isEqualToString:@"1"])
    {
        rapidTaxMaster.Amount = @(0);
        rapidTaxMaster.PERCENTAGE = @(0);
    }
    else
    {
        rapidTaxMaster.Amount = @(0);
        rapidTaxMaster.PERCENTAGE =@(self.txtAmount.text.floatValue);
    }

    if (![self isTaxNameIsValid]) {
        [self showAlertForUniqueTaxMaster];
        return;
    }
    
    [self.rmsDbController playButtonSound];

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];

    if (self.taxMaster)
    {
        [self updateTaxMasterMode];
    }
    else
    {
        [self insertTaxMasterMode];
    }
}

-(BOOL)isTaxNameIsValid{
    NSString *taxName = [rapidTaxMaster.TAXNAME stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate * predicate = [self createPradicateFor:@"taxNAME" withValue:taxName];
    return [self isValidTaxForPredicate:predicate];
}

-(NSPredicate *)createPradicateFor:(NSString *)strKey withValue:(NSString *)strValue {
    NSPredicate * predicate;
    if (self.taxMaster) {
        predicate  = [NSPredicate predicateWithFormat:@"%K == [cd]%@ && taxId != %@",strKey,strValue,self.taxMaster.taxId];
    }
    else {
        predicate  = [NSPredicate predicateWithFormat:@"%K == [cd]%@",strKey,strValue];
    }
    return predicate;
}
-(BOOL)isValidTaxForPredicate:(NSPredicate *) predicate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    if ([UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest] == 0) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}

- (void)showAlertForUniqueTaxMaster {
    [self showTaxAlertView:@"Please enter Unique Tax Name" forTextField:self.txtTax];
}
-(void)showTaxAlertView:(NSString *)alertMessage forTextField:(UITextField *)textField
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [textField becomeFirstResponder];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:alertMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

////Insert tax master
-(void)insertTaxMasterMode {
    
    NSMutableDictionary *taxMasterDictionary = [[NSMutableDictionary alloc] init];
    taxMasterDictionary[@"TaxData"] = rapidTaxMaster.rapidTaxMasterDictionary;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self insertTaxMasterModeResponse:response error:error];
        });
    };
    
    self.taxInsertWebserviceConnection = [self.taxInsertWebserviceConnection initWithRequest:KURL actionName:WSM_INSERT_TAX params:taxMasterDictionary completionHandler:completionHandler];
}


-(void)insertTaxMasterModeResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                [Appsee addEvent:@"RIMTaxInsertWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"Tax has been added successfully"}];
                
                NSArray *arrTaxMaster  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.updateManager updateTaxMaster:arrTaxMaster moc:privateContextObject];
                [UpdateManager saveContext:privateContextObject];
                
                AddTaxMasterVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Tax has been added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                [Appsee addEvent:@"RIMTaxInsertWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"Tax not added, try again."}];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Tax not added, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

//// Update Tax master
-(void)updateTaxMasterMode {
    
    NSMutableDictionary *taxMasterDictionary = [[NSMutableDictionary alloc] init];
    taxMasterDictionary[@"TaxData"] = rapidTaxMaster.rapidTaxMasterDictionary;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateTaxMasterModeResponse:response error:error];
        });
    };
    
    self.taxUpdateWebserviceConnection = [self.taxUpdateWebserviceConnection initWithRequest:KURL actionName:WSM_UPDATE_TAX params:taxMasterDictionary completionHandler:completionHandler];
}

-(void)updateTaxMasterModeResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                [Appsee addEvent:@"RIMTaxUpdateWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"Tax has been updated successfully"}];
                
                NSArray *arrTaxMaster  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.updateManager updateTaxMaster:arrTaxMaster moc:privateContextObject];
                [UpdateManager saveContext:privateContextObject];
                
                AddTaxMasterVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Tax has been updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                [Appsee addEvent:@"RIMTaxInsertWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"payment not added, try again."}];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Tax not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(IBAction)btnDeleteClicked:(id)sender
{
    [self.view endEditing:YES];
    [self.rmsDbController playButtonSound];
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%@",self.taxMaster.taxId];
    fetchRequest.predicate = predicate;
    NSArray *taxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];

    if (taxListArray.count > 0) {
        [self showTaxAlertView:[NSString stringWithFormat:@"%@ cannot be deleted as it is assigned to %lu items. Remove this tax from all those items first. Then try deleting this tax",self.taxMaster.taxNAME,(unsigned long)taxListArray.count]];
    }
    else{
        AddTaxMasterVC * __weak myWeakReference = self;
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference deleteTax];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this Tax?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (void)deleteTax {
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    
    NSMutableDictionary *tenderTaxDataDictionary = [[NSMutableDictionary alloc] init];
    tenderTaxDataDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    tenderTaxDataDictionary[@"TaxId"] = self.taxMaster.taxId.stringValue;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self deleteTaxMasterResponse:response error:error];
        });
    };
    
    self.taxDeleteWebserviceConnection = [self.taxDeleteWebserviceConnection initWithRequest:KURL actionName:WSM_DELETE_TAX params:tenderTaxDataDictionary completionHandler:completionHandler];
}

-(void)deleteTaxMasterResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                [Appsee addEvent:@"RIMTaxDeleteWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"Tax has been deleted successfully"}];
                
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.updateManager deleteTaxMaster:self.taxMaster.taxId.stringValue moc:privateContextObject];
                [UpdateManager saveContext:privateContextObject];
                
                AddTaxMasterVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Tax has been deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                [Appsee addEvent:@"RIMTaxDeleteWebServiceResponse" withProperties:@{@"WebServiceResponse" : @"payment not deleted, try again."}];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Tax not deleted, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}


-(void)showTaxAlertView:(NSString *)alertMessage
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:alertMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

//// Update Tax Master
-(void)updateViewWithUpdateDetail:(NSMutableDictionary *)taxMasterDictionary
{
    if(taxMasterDictionary != nil)
    {
        self.txtTax.text = [taxMasterDictionary valueForKey:@"TAXNAME"];
        if([[[taxMasterDictionary valueForKey:@"Type"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"1"])
        {
            self.btnDoller.selected = YES;
            self.btnPersentage.selected = NO;
            self.txtAmount.text = [taxMasterDictionary valueForKey:@"Amount"];
            self.txtAmount.userInteractionEnabled = NO;
            _taxPercentageIndicator.hidden = YES;


        }
        else
        {
            self.btnPersentage.selected = YES;
            self.btnDoller.selected = NO;
            self.txtAmount.text = [taxMasterDictionary valueForKey:@"PERCENTAGE"];
            self.txtAmount.userInteractionEnabled = YES;
            _taxPercentageIndicator.hidden = NO;

        }
    }
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _txtAmount) {
        RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:NumberPadPickerTypesPercentage NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
            if(numInput.floatValue > 0) {
                textField.text = numInput.stringValue;
            }
        } NumberPadColseInput:^(UIViewController *popUpVC) {
            [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        }];
        objRIMNumberPadPopupVC.inputView = textField;
        [objRIMNumberPadPopupVC presentVCForRightSide:self WithInputView:textField];
//        [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:textField ArrowDirection:UIPopoverArrowDirectionLeft];
        [self.view endEditing:YES];
        return FALSE;
    }
    return TRUE;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
