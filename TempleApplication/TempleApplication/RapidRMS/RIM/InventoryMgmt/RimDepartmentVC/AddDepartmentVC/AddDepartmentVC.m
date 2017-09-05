//
//  AddDepartmentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 08/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AddDepartmentCell.h"
#import "AddDepartmentModel.h"
#import "AddDepartmentVC.h"
#import "Department+Dictionary.h"
#import "DepartmentTax+Dictionary.h"
#import "DisplayDepartmentInfoSideVC.h"
#import "ImagesCell.h"
#import "Item+Dictionary.h"
#import "ItemImageSelectionVC.h"
#import "ItemListCell.h"
#import "NSString+Validation.h"
#import "RIMNumberPadPopupVC.h"
#import "RimTaxAddRemovePage.h"
#import "RmsDbController.h"
#import "SelectUserOptionVC.h"
#import "TaxMaster+Dictionary.h"
#import "UITableView+AddBorder.h"
#import "UpdateManager.h"


@interface AddDepartmentVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,RimTaxAddRemovePageDelegate,UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UpdateDelegate,UIPopoverPresentationControllerDelegate,ItemSelctionImageChangedVCDelegate> {
    
    UIImagePickerController *controller;
    UIImagePickerController *pickerCamera ;

    BOOL is_asItem;
    
    BOOL isPOS;
    BOOL isFreqPOS;
    BOOL isPos;
    
    UIView *taxview;
    UITableView *tbltaxlist;
    
    NSString *position;
    NSString *deptId;
    NSString *imagePath;

    NSMutableArray *taxArrayForUpdate;

    UIImage *selectedImage;
    NSData *imageData;
    
    NSInteger itemCode;
    
    
    AddDepartmentModel * deptModel;
    NSArray * arrInfoRows;
    
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) DisplayDepartmentInfoSideVC *objDepartmentInfo;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic) BOOL isImageSet;
@property (nonatomic, strong) Department *department;


@property (nonatomic, weak) IBOutlet UITableView *tblInfo;
@property (nonatomic, weak) IBOutlet UITableView *tblSetting;
@property (nonatomic, weak) IBOutlet UITableView *tblItems;

@property (nonatomic, weak) IBOutlet UIView *uvInfo;
@property (nonatomic, weak) IBOutlet UIView *uvSetting;
@property (nonatomic, weak) IBOutlet UIView *uvItems;
@property (nonatomic, weak) IBOutlet UIView *viewSideInfoGB;

@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnSave;
@property (nonatomic, weak) IBOutlet UIButton *btnInfo;
@property (nonatomic, weak) IBOutlet UIButton *btnSetting;
@property (nonatomic, weak) IBOutlet UIButton *btnItems;
@property (nonatomic, weak) IBOutlet UIButton *btnPickImage;

@property (nonatomic, weak) IBOutlet UILabel *lblDelete;
@property (nonatomic, weak) IBOutlet UILabel *lblSave;

@property (nonatomic, strong) NSMutableDictionary *deapartmentInsertDict;

@property (nonatomic, strong) NSMutableArray *arrChargeType;
@property (nonatomic, strong) NSMutableArray *arrayDeptItems;

@property (nonatomic, strong) RimTaxAddRemovePage *taxAddRemoveiPad;

@property (nonatomic, strong) RapidWebServiceConnection * getItemImageListByNameWC;
@property (nonatomic, strong) RapidWebServiceConnection * departmentInsertConnection;
@property (nonatomic, strong) RapidWebServiceConnection * departmentUpdateConnection;
@property (nonatomic, strong) RapidWebServiceConnection * departmentDeleteConnection;

@end

@implementation AddDepartmentVC

@synthesize tblInfo,tblSetting,deapartmentInsertDict,uvSetting,uvInfo,objDepartmentInfo;
@synthesize tblItems,uvItems;

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

    uvInfo.hidden = NO;
    uvSetting.hidden = YES;
    uvItems.hidden = YES;
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.departmentInsertConnection = [[RapidWebServiceConnection alloc]init];
    self.departmentUpdateConnection = [[RapidWebServiceConnection alloc]init];
    self.departmentDeleteConnection = [[RapidWebServiceConnection alloc]init];
    self.getItemImageListByNameWC = [[RapidWebServiceConnection alloc]init];
    
    deptModel = [[AddDepartmentModel alloc]init];
    taxArrayForUpdate = [[NSMutableArray alloc]init];
    
    if (self.viewSideInfoGB) {
        [self showSideDepartmentInfo:self.updateDepartmentDictioanry];
    }
    [self allocAllFields];
    
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    [self fetchDepartmentTaxFromCoreData];
    [self updateViewWithUpdateDetail:self.updateDepartmentDictioanry];
    [deptModel updateViewWithUpdateDetail:self.updateDepartmentDictioanry];

    if(self.updateDepartmentDictioanry != nil)
    {
        _btnItems.hidden = NO;
        self.btnDelete.enabled = YES;
        self.lblDelete.enabled = YES;
        self.department = (Department *)[self.updateManager __fetchEntityWithName:@"Department" key:@"deptId" value:@([[self.updateDepartmentDictioanry valueForKey:@"deptId"] integerValue]) shouldCreate:NO moc:self.managedObjectContext];
        
        _arrayDeptItems = [[NSMutableArray alloc]init];
        for (Item *item in self.department.departmentItems) {
            [_arrayDeptItems addObject:item.itemDictionary];
        }
        if(_arrayDeptItems.count>0){
            [self.tblItems reloadData];
        }
        else{
            [_btnItems setHidden:YES];
            [uvItems setHidden:YES];
        }
        
        if ([[self.updateDepartmentDictioanry valueForKey:@"deptId"] integerValue] == 0)
        {
            self.btnSave.enabled = NO;
            self.lblSave.enabled = NO;
            self.btnDelete.enabled = NO;
            self.lblDelete.enabled = NO;
        }
        else
        {
            self.btnSave.enabled = YES;
            self.lblSave.enabled = YES;
            self.btnDelete.enabled = YES;
            self.lblDelete.enabled = YES;
        }
    }
    else
    {
        self.btnDelete.enabled = NO;
        self.lblDelete.enabled = NO;
        [_btnItems setHidden:YES];
        [uvItems setHidden:YES];

    }

    imagePath = [[NSString alloc] init];
    
    
    arrInfoRows =[[NSArray alloc]initWithObjects:@(DepartmentInfoTabTypeRow),@(DepartmentInfoTabNameRow),@(DepartmentInfoTabCodeRow),@(DepartmentInfoTabProfitRow),@(DepartmentInfoTabNotApplyInItemRow),@(DepartmentInfoTabAgeRow),@(DepartmentInfoTabPayoutRow), nil];

    // Do any additional setup after loading the view from its nib.
}

-(void)updateViewWithUpdateDetail:(NSMutableDictionary *)departmentDictionary
{
    if(departmentDictionary != nil)
    {
        isPos = [[departmentDictionary valueForKey:@"isPOS"] boolValue ];
        
        itemCode = [[departmentDictionary valueForKey:@"itemcode"] integerValue ];
    }
}

#pragma mark - Alloc All Fields

-(void) allocAllFields
{
    taxview = [[UIView alloc]init];
    tbltaxlist = [[UITableView alloc] init];
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL isEdited = TRUE;
    NumberPadPickerTypes pickerType;
    switch (textField.tag) {
        case DepartmentInfoTabProfitRow:
            pickerType = NumberPadPickerTypesPercentage;
            isEdited = FALSE;
            break;
        case DepartmentSettingTabChequeCash:
            pickerType = NumberPadPickerTypesPrice;
            if ([deptModel.strCheckCashType.lowercaseString isEqualToString:@"percentage(%)"]) {
                pickerType = NumberPadPickerTypesPercentage;
            }
            isEdited = FALSE;
            break;
        case DepartmentSettingTabChargeType:
            pickerType = NumberPadPickerTypesPrice;
            if ([deptModel.strChargeTyp.lowercaseString isEqualToString:@"percentage(%)"]) {
                pickerType = NumberPadPickerTypesPercentage;
            }
            isEdited = FALSE;
            break;
        default:
            break;
    }
    if (!isEdited) {
        [self inputNumberValue:textField withType:pickerType];
    }
    return isEdited;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    UITableView * tblInput;
    switch (textField.tag) {
        case DepartmentInfoTabNameRow:
            deptModel.strDeptName = textField.text;
            tblInput = self.tblInfo;
            break;
        case DepartmentInfoTabCodeRow:
            deptModel.strDeptCode = textField.text;
            tblInput = self.tblInfo;
            break;
        case DepartmentInfoTabProfitRow:
            deptModel.strProfitMargin = textField.text;
            tblInput = self.tblInfo;
            break;
        case DepartmentSettingTabChequeCash:
            deptModel.strCheckCashAmt = textField.text;
            tblInput = self.tblSetting;
            break;
        case DepartmentSettingTabChargeType:
            deptModel.strChargeAmt = textField.text;
            tblInput = self.tblSetting;
            break;
        default:
            break;
    }
    [tblInput reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{               // called when clear button pressed. return NO to ignore (no notifications)
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)inputNumberValue:(UITextField *)txtInput withType:(NumberPadPickerTypes) pickerType {
    
    RIMNumberPadPopupVC * objRIMNumberPadPopupVC = [RIMNumberPadPopupVC getInputPopupWith:pickerType NumberPadCompleteInput:^(NSNumber *numInput, NSString *strInput, id inputView) {
        txtInput.text = numInput.stringValue;
        [self textFieldDidEndEditing:txtInput];
    } NumberPadColseInput:^(UIViewController *popUpVC) {
        [((RIMNumberPadPopupVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objRIMNumberPadPopupVC.inputView = txtInput;
    [objRIMNumberPadPopupVC presentVCForRightSide:self WithInputView:txtInput];
//    [objRIMNumberPadPopupVC presentViewControllerForviewConteroller:self sourceView:txtInput ArrowDirection:UIPopoverArrowDirectionLeft];
}

#pragma mark - Show Info In Side Menu

-(void)showSideDepartmentInfo:(NSMutableDictionary *)departmentDictionary
{
    [[self.view viewWithTag:252525] removeFromSuperview];
    objDepartmentInfo = [[DisplayDepartmentInfoSideVC alloc]initWithNibName:@"DisplayDepartmentInfoSideVC" bundle:nil];
    objDepartmentInfo.departmentInfoDictionary = [departmentDictionary mutableCopy];
    objDepartmentInfo.view.frame = self.viewSideInfoGB.bounds;
    objDepartmentInfo.view.tag = 252525;
    objDepartmentInfo.objAddDepartment = (AddDepartmentVC *)self;
    [self.viewSideInfoGB addSubview:objDepartmentInfo.view];
}

-(IBAction)btnSwitchTabClick:(UIButton *)sender {
    
    self.btnInfo.selected = FALSE;
    self.btnSetting.selected = FALSE;
    self.btnItems.selected = FALSE;
    
    uvInfo.hidden = TRUE;
    uvSetting.hidden = TRUE;
    uvItems.hidden = TRUE;
    sender.selected = TRUE;
    switch (sender.tag) {
        case 101:
            uvInfo.hidden = FALSE;
            break;
        case 102:
            uvSetting.hidden = FALSE;
            break;
        case 103:
            uvItems.hidden = FALSE;
            break;
    }
}

-(IBAction)btnCloseClicked:(id)sender
{
    [Appsee addEvent:kRIMDepartmentClose];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(int)countDepartmentItemHaveEBTforThisDepartment {

    if ((deptModel.isDeductChk || deptModel.isChkCheckCash || deptModel.isChkExtra) && self.updateDepartmentDictioanry) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSManagedObjectContext * privateMOC = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eBT == %d AND deptId == %d",TRUE,[[self.updateDepartmentDictioanry valueForKey:@"deptId"] integerValue]];
        fetchRequest.predicate = predicate;
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:privateMOC];
        fetchRequest.entity = entity;
        
        return (int)[UpdateManager countForContext:privateMOC FetchRequest:fetchRequest];
    }
    return 0;
}
-(int)countDepartmentItemHavePayoutforThisDepartment{

    if (self.deapartmentInsertDict) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSManagedObjectContext * privateMOC = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isItemPayout == %d AND deptId == %d",TRUE,[[self.updateDepartmentDictioanry valueForKey:@"deptId"] integerValue]];
        fetchRequest.predicate = predicate;
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:privateMOC];
        fetchRequest.entity = entity;
        
        return (int)[UpdateManager countForContext:privateMOC FetchRequest:fetchRequest];
    }
    else{
        return 0;
    }
}

#pragma mark - save Department -

-(IBAction)btnSaveClicked:(id)sender
{
    [Appsee addEvent:kRIMDepartmentSave];
    
    if ([self isValidDepartmentInfo]) {

        _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
        
        deapartmentInsertDict = [self getDeparmentProcessData];
        
        if (self.updateDepartmentDictioanry == nil) {
            [Appsee addEvent:kRIMDepartmentInsertWebServiceCall];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self doInsertProcessForDepartmentResponse:response error:error];
                });
            };
            
            self.departmentInsertConnection = [self.departmentInsertConnection initWithRequest:KURL actionName:WSM_INSERT_DEPARTMENT params:deapartmentInsertDict completionHandler:completionHandler];
        }
        else
        {
            
            NSDictionary *updateDict = @{kRIMDepartmentUpdateWebServiceCallKey : [[[[[deapartmentInsertDict valueForKey:@"DepartmentData"] firstObject] valueForKey:@"objDeptMaster"] firstObject] valueForKey:@"DeptId"]};
            [Appsee addEvent:kRIMDepartmentUpdateWebServiceCall withProperties:updateDict];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self doUpdateProcessForDepartmentResponse:response error:error];
                });
            };
            
            self.departmentUpdateConnection = [self.departmentUpdateConnection initWithRequest:KURL actionName:WSM_UPDATE_DEPARTMENT params:deapartmentInsertDict completionHandler:completionHandler];
        } 
    }
}

-(BOOL)isValidDepartmentInfo {
    [self.view endEditing:YES];
    if([NSString trimSpacesFromStartAndEnd:deptModel.strDeptName].length == 0) {
        [self showDeptAlertView:@"Please enter Department name" forTextField:nil];
        return FALSE;
    }
    else if(deptModel.isTaxFlg && deptModel.isDeductChk) {
        [self showDeptAlertView:@"Please remove department tax or payout." forTextField:nil];
        return FALSE;
    }
    else if([NSString trimSpacesFromStartAndEnd:deptModel.strDeptCode].length == 0) {
        [self showDeptAlertView:@"Please enter Department code" forTextField:nil];
        return FALSE;
    }
    else if (![self isValidTextWith:@"^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$" toMatchString:deptModel.strProfitMargin]) {
        [self showAlertMessage:nil alertMessage:@"Please enter valid Profit Margin value"];
        return FALSE;
    }
    else if (![self isValidTextWith:@"^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$" toMatchString:deptModel.strCheckCashAmt]) {
        [self showAlertMessage:nil alertMessage:@"Please enter valid Cheque Cash value"];
        return FALSE;
    }
    else if (![self isValidTextWith:@"^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$" toMatchString:deptModel.strChargeAmt]) {
        [self showAlertMessage:nil alertMessage:@"Please enter valid Chanrge Type value"];
        return FALSE;
    }
    if(self.updateDepartmentDictioanry) {
        int intEBTCount = [self countDepartmentItemHaveEBTforThisDepartment];
        if (intEBTCount > 0) {
            NSString * strEBTMessage = [NSString stringWithFormat:@"%d item have EBT,Please remove Cheque Cash, Charge Type OR Payout off",intEBTCount];
            [self showDeptAlertView:strEBTMessage forTextField:nil];
            return FALSE;
        }
        int intPayoutCount = [self countDepartmentItemHavePayoutforThisDepartment];
        if (intPayoutCount > 0 && deptModel.isTaxFlg) {
            NSString * strPayoutMessage = [NSString stringWithFormat:@"%d item have Payout,Please remove Department Tax",intPayoutCount];
            [self showDeptAlertView:strPayoutMessage forTextField:nil];
            return FALSE;
        }
    }
    if(deptModel.isChkApplyAge)
    {
        if (deptModel.strApplyAgeDesc == nil || !(deptModel.strApplyAgeDesc.length > 0) || [deptModel.strApplyAgeDesc isEqualToString:@"Select"]) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select age restriction type." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return FALSE;
        }
    }
    if(deptModel.isChkCheckCash)
    {
        if (deptModel.strCheckCashType  == nil || !(deptModel.strCheckCashType.length > 0)) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select check cash type." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return FALSE;
        }
    }
    if(deptModel.isChkExtra)
    {
        if (deptModel.strChargeTyp == nil || !(deptModel.strChargeTyp.length > 0) || [deptModel.strChargeTyp isEqualToString:@"Select"]) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select charge type." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return FALSE;
        }
    }
    
    if(deptModel.isTaxFlg)
    {
        if (deptModel.deptTaxArray == nil || !(deptModel.deptTaxArray.count > 0)) {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select at least one tax." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return FALSE;
        }
    }
    if (![self isDepartmentNameIsValid]) {
        [self showDeptAlertView:@"Please enter Unique Department Name" forTextField:nil];
        return FALSE;
    }
    if (![self isDepartmentCodeIsValid]) {
        [self showDeptAlertView:@"Please enter Unique Department Code" forTextField:nil];
        return FALSE;
    }
//    NSString *deptName = [deptModel.strDeptName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    BOOL isUniqueDepartment = FALSE;
//    NSPredicate *predicate;
//    if (self.updateDepartmentDictioanry) {
//       predicate  = [NSPredicate predicateWithFormat:@"deptName == %@",deptName];
//
//        BOOL isMultipleDepartment = [self isDepartmentNameAvailabelMultipleTimeInDb:deptName withpredicate:predicate];
//        if (isMultipleDepartment) {
//            [self showAlertForUniqueDepartment];
//            return FALSE;
//        }
//        else
//        {
//            if ([[self.updateDepartmentDictioanry valueForKey:@"deptName"] isEqualToString:deptName]) {
//                isUniqueDepartment = TRUE;
//            }
//            else
//            {
//                isUniqueDepartment = [self isDepartmentNameUnique:deptName withpredicate:predicate];
//            }
//        }
//    }
//    else
//    {
//        predicate  = [NSPredicate predicateWithFormat:@"deptName == [c]%@",deptName];
//
//        isUniqueDepartment = [self isDepartmentNameUnique:deptName withpredicate:predicate];
//    }
//    if (!isUniqueDepartment) {
//        [self showAlertForUniqueDepartment];
//        return FALSE;
//    }
    return true;
}

-(BOOL)isDepartmentNameIsValid{
    NSString *deptName = [deptModel.strDeptName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate * predicate = [self createPradicateFor:@"deptName" withValue:deptName];
    return [self isValidDepartmentForPredicate:predicate];
}

-(BOOL)isDepartmentCodeIsValid{
    NSString *deptCode = [deptModel.strDeptCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate * predicate = [self createPradicateFor:@"deptCode" withValue:deptCode];
    return [self isValidDepartmentForPredicate:predicate];
}

-(NSPredicate *)createPradicateFor:(NSString *)strKey withValue:(NSString *)strValue {
    NSPredicate * predicate;
    if (self.updateDepartmentDictioanry) {
        predicate  = [NSPredicate predicateWithFormat:@"%K == [cd]%@ && deptId != %@",strKey,strValue,[self.updateDepartmentDictioanry valueForKey:@"deptId"]];
    }
    else {
        predicate  = [NSPredicate predicateWithFormat:@"%K == [cd]%@",strKey,strValue];
    }
    return predicate;
}
-(BOOL)isValidDepartmentForPredicate:(NSPredicate *) predicate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    if ([UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest] == 0) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}
-(BOOL)isValidTextWith:(NSString *)expression toMatchString:(NSString *)strMatch {
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:strMatch
                                                        options:0
                                                          range:NSMakeRange(0, strMatch.length)];
    return numberOfMatches > 0;
}
-(void)showAlertMessage:(NSString *)strTitle alertMessage:(NSString *)strMessage {
    if (strTitle == nil || (strTitle != nil && strTitle.length == 0)) {
        strTitle = @"Inventory Management";
    }
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:strTitle message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    
}

- (void)doInsertProcessForDepartmentResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [Appsee addEvent:kRIMDepartmentInsertWebServiceResponse withProperties:@{kRIMDepartmentInsertWebServiceResponseKey : @"Department has been added successfully"}];
                NSMutableDictionary *responseDict  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString *imgpath = [NSString stringWithFormat:@"%@",[responseDict valueForKey:@"imgpath"]];
                
                NSString *strdepid = [responseDict valueForKey:@"DeptCode"];
                deptId = strdepid;
                [self  getDeptTaxParam];
                [self.updateManager updateDepartmentTaxForList:taxArrayForUpdate];
                NSString *strItemcode = [responseDict valueForKey:@"ItemCode"];
                int isPosLocal = [[responseDict valueForKey:@"ispos"]intValue];
                
                NSMutableDictionary *pDict = [[self dictionaryToUpdateDepartmentData] mutableCopy];
                pDict[@"ImagePath"] = imgpath;
                pDict[@"DeptId"] = strdepid;
                pDict[@"Itemcode"] = strItemcode;
                pDict[@"IsPOS"] = [NSString stringWithFormat:@"%d",isPosLocal];
                
                [self.updateManager insertDepartmentWithDictionary:pDict];
                [self.addDepartmentVCDelegate didAddedNewDepartment:pDict];
                AddDepartmentVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Department has been added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                [Appsee addEvent:kRIMDepartmentInsertWebServiceResponse withProperties:@{kRIMDepartmentInsertWebServiceResponseKey : @"Department not added, try again."}];
                NSString *message = [response valueForKey:@"Data"];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

- (void) doUpdateProcessForDepartmentResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [Appsee addEvent:kRIMDepartmentUpdateWebServiceResponse withProperties:@{kRIMDepartmentUpdateWebServiceResponseKey : @"Department has been Updated successfully"}];
                NSMutableDictionary *responseDict  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString *imgpath = [NSString stringWithFormat:@"%@",[responseDict valueForKey:@"imgpath"]];
                
                NSMutableDictionary *pDict = [self dictionaryToUpdateDepartmentData];
                
                if (taxArrayForUpdate.count > 0) {
                    [self.updateManager updateDepartmentTaxForList:taxArrayForUpdate];
                }
                else{
                    NSManagedObjectContext * moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:moc];
                    fetchRequest.entity = entity;
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%@",[pDict valueForKey:@"DeptId"]];
                    fetchRequest.predicate = predicate;
                    NSArray *taxArray = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];

                    for (NSManagedObject *product in taxArray)
                    {
                        [UpdateManager deleteFromContext:moc object:product];
                    }
                    [UpdateManager saveContext:moc];
                }
                
                pDict[@"IsPOS"] = @(isPos);
                if(![imgpath isEqualToString:@""])
                {
                    pDict[@"ImagePath"] = imgpath;
                }
                [self.updateManager updateDepartmentWithDictionary:pDict];
                
                AddDepartmentVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Department has been Updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                [Appsee addEvent:kRIMDepartmentUpdateWebServiceResponse withProperties:@{kRIMDepartmentUpdateWebServiceResponseKey : @"Department not Updated, try again."}];
                NSString *message = [response valueForKey:@"Data"];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}
- (NSMutableDictionary *) getDeparmentProcessData
{
    NSMutableDictionary * addDeptDataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray * deptDetail = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * deptDetailDict = [[NSMutableDictionary alloc] init];
    deptDetailDict[@"objDeptMaster"] = [self getDeptMasterParam];
    deptDetailDict[@"objDeptTax"] = [self getDeptTaxParam];
    [deptDetail addObject:deptDetailDict];
    addDeptDataDict[@"DepartmentData"] = deptDetail;
    return addDeptDataDict;
}

- (NSMutableDictionary *) departmentDeleteProcessData
{
    NSMutableDictionary * addDeptDataDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary * deptDetailDict = [[NSMutableDictionary alloc] init];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    deptDetailDict[@"LocalDate"] = currentDateTime;
    
    deptDetailDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    deptDetailDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    if(!(self.updateDepartmentDictioanry == nil))
    {
        deptId = [NSString stringWithFormat:@"%@",[self.updateDepartmentDictioanry valueForKey:@"deptId"]];
        deptDetailDict[@"DeptId"] = deptId;
    }

    addDeptDataDict[@"DepartmentData"] = deptDetailDict;
    return addDeptDataDict;
}


- (NSMutableArray *) getDeptMasterParam
{
    NSMutableArray * deptMaster = [[NSMutableArray alloc] init];
    NSMutableDictionary * deptMasterDict = [[NSMutableDictionary alloc] init];
    deptMasterDict[@"DeptName"] = deptModel.strDeptName;
    deptMasterDict[@"DeptCode"] = deptModel.strDeptCode;
    deptMasterDict[@"DeptTypeId"] = @(deptModel.deptTypeId);
    deptMasterDict[@"ItemCode"] = deptModel.strDeptCode;
    
    
    if(self.updateDepartmentDictioanry!=nil){
        
        if (isPos){
            deptMasterDict[@"POS"] = @"1";
        } else {
            deptMasterDict[@"POS"] = @"0";
        }
    }
    else{
         deptMasterDict[@"POS"] = @"1";
    }
    
    if (is_asItem) {
        deptMasterDict[@"Is_asItem"] = @"1";
    } else {
        deptMasterDict[@"Is_asItem"] = @"0";
    }

        deptMasterDict[@"ChargeTyp"] = deptModel.strChargeTyp;

    
    if (deptModel.strChargeAmt.length > 0) {
        deptMasterDict[@"ChargeAmt"] = deptModel.strChargeAmt;
    } else {
        deptMasterDict[@"ChargeAmt"] = @"0";
    }
    
    if (deptModel.strProfitMargin.length > 0) {
        deptMasterDict[@"ProfitMargin"] = deptModel.strProfitMargin;
    } else {
        deptMasterDict[@"ProfitMargin"] = @"0";
    }
    
    if (deptModel.isDeductChk) {
        deptMasterDict[@"DeductChk"] = @"1";
    } else {
        deptMasterDict[@"DeductChk"] = @"0";
    }
    
    if (position.length>0) {
        deptMasterDict[@"POSITION"] = position;
    } else {
        deptMasterDict[@"POSITION"] = @"0";
    }
    
    if (isFreqPOS) {
        deptMasterDict[@"FreqPOS"] = @"1";
    } else {
        deptMasterDict[@"FreqPOS"] = @"0";
    }
    
    if (deptModel.isChkExtra) {
        deptMasterDict[@"ChkExtra"] = @"1";
    } else {
        deptMasterDict[@"ChkExtra"] = @"0";
    }
    
    if (deptModel.isTaxFlg) {
        deptMasterDict[@"TaxFlg"] = @"1";
    } else {
        deptMasterDict[@"TaxFlg"] = @"0";
    }
    
    if (deptModel.isChkCheckCash) {
        deptMasterDict[@"ChkCheckCash"] = @"1";
    } else {
        deptMasterDict[@"ChkCheckCash"] = @"0";
    }

        deptMasterDict[@"CheckCashType"] = deptModel.strCheckCashType;
    
    if (deptModel.strCheckCashAmt.length > 0){
        deptMasterDict[@"CheckCashAmt"] = deptModel.strCheckCashAmt;
    } else {
        deptMasterDict[@"CheckCashAmt"] = @"0";
    }
    
    if (deptModel.isNotDisplayInventory) {
        deptMasterDict[@"IsNotDisplayInventory"] = @"1";
    } else {
        deptMasterDict[@"IsNotDisplayInventory"] = @"0";
    }

    if (deptModel.isChkApplyAge) {
        deptMasterDict[@"ChkApplyAge"] = @"1";
    } else {
        deptMasterDict[@"ChkApplyAge"] = @"0";
    }
    
    deptMasterDict[@"ApplyAgeDesc"] = deptModel.strApplyAgeDesc;
    
    deptMasterDict[@"GroupTyp"] = @"";
    
    if(deptModel.isImageSet)
    {
        imageData = UIImageJPEGRepresentation(selectedImage, 0);
        if(imageData)
        {
            deptMasterDict[@"ImagePath"] = [imageData base64EncodedStringWithOptions:0];
        }
        else
        {
            deptMasterDict[@"ImagePath"] = @"";
        }
    } else {
        if(!(self.updateDepartmentDictioanry == nil))
        {
            deptMasterDict[@"ImagePath"] = @"NoChange";
        }
        else
        {
            deptMasterDict[@"ImagePath"] = @"";
        }
    }
    
    deptMasterDict[@"IsImageDeleted"] = @(deptModel.isImageDeleted);
    
    if (itemCode != 0)
    {
        deptMasterDict[@"itemCode"] = [NSString stringWithFormat:@"%ld",(long)itemCode];
    }
    else
    {
        deptMasterDict[@"itemCode"] = @"";
    }
    
    deptMasterDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    deptMasterDict[@"CreatedBy"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    deptMasterDict[@"LocalDate"] = currentDateTime;
    deptMasterDict[@"TaxApplyIn"] = deptModel.strTaxApplyIn;
    
    if (deptModel.isNotApplyInItem) {
        deptMasterDict[@"IsNotApplyInItem"] = @"1";
    }
    else
    {
        deptMasterDict[@"IsNotApplyInItem"] = @"0";
    }
    
    if(!(self.updateDepartmentDictioanry == nil))
    {
        deptId = [NSString stringWithFormat:@"%@",[self.updateDepartmentDictioanry valueForKey:@"deptId"]];
        deptMasterDict[@"DeptId"] = deptId;
    }
    
    [deptMaster addObject:deptMasterDict];
    return deptMaster;
}


-(IBAction)btnDeleteDepartment:(id)sender
{
    [Appsee addEvent:kRIMSubDepartmentDelete];
    if (self.updateDepartmentDictioanry != nil) {
        [self.rmsDbController playButtonSound];
        
        if ([[self.updateDepartmentDictioanry valueForKey:@"deptId"] integerValue] == 0) {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Can not delete this department." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DepartId == %@",[[self.updateDepartmentDictioanry valueForKey:@"deptId"] stringValue]];
            NSArray *deptItem = [_arrayDeptItems filteredArrayUsingPredicate:predicate];
            
            if(deptItem.count == 1 && _arrayDeptItems.count == 1){
                
                AddDepartmentVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference deleteDepartment];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this Department?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
            }
            else if(_arrayDeptItems.count == 0){
                
                AddDepartmentVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference deleteDepartment];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this Department?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
            }
            else if(_arrayDeptItems.count > 1){
                
                NSString *strMsg = [NSString stringWithFormat:@"%@ cannot be deleted as it is assigned to %d items. Please check the ‘Items’ tab to check the list of items. Remove this department from all those items first. Then try deleting this department.",deptModel.strDeptName,(int)self.arrayDeptItems.count-1];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:strMsg buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                
            }
            
        }
    }
}

- (void)deleteDepartment
{
    [self.rmsDbController playButtonSound];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    
    deapartmentInsertDict = [self departmentDeleteProcessData];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doDeleteProcessForDepartmentResponse:response error:error];
        });
    };
    
    self.departmentDeleteConnection = [self.departmentDeleteConnection initWithRequest:KURL actionName:WSM_DELETE_DEPARTMENT params:deapartmentInsertDict completionHandler:completionHandler];
}

- (void)doDeleteProcessForDepartmentResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                [self.updateManager deleteDepartmentWithSubDepartmentId:@(deptId.integerValue)];
                AddDepartmentVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Department has been Deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -2)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Department not Deleted, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

//-(BOOL)isDepartmentNameAvailabelMultipleTimeInDb:(NSString *)deptName withpredicate:(NSPredicate *)predicate
//{
//    BOOL isMultiDepartment = FALSE;
//    NSArray *uniqueDepartments = [self fetchDepartmentsForDepartmentName:deptName withpredicate:predicate];
//    if (uniqueDepartments !=nil && uniqueDepartments.count > 1) {
//        isMultiDepartment = TRUE;
//    }
//    return isMultiDepartment;
//}
//
//-(BOOL)isDepartmentNameUnique:(NSString *)deptName withpredicate:(NSPredicate *)predicate
//{
//    BOOL isUniqueDepartment = TRUE;
//    NSArray *uniqueDepartments = [self fetchDepartmentsForDepartmentName:deptName withpredicate:predicate];
//    if (uniqueDepartments !=nil && uniqueDepartments.count > 0) {
//        isUniqueDepartment = FALSE;
//    }
//    return isUniqueDepartment;
//}
//
//- (NSArray *)fetchDepartmentsForDepartmentName:(NSString *)deptName withpredicate:(NSPredicate *)predicate
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
//    fetchRequest.entity = entity;
//    fetchRequest.predicate = predicate;
//    NSArray *uniqueDepartments = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
//    return uniqueDepartments;
//}

-(void)fetchDepartmentTaxFromCoreData
{
    NSMutableArray *taxDetail = [[NSMutableArray alloc]init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepartmentTax" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[[self.updateDepartmentDictioanry valueForKey:@"deptId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *departmentTaxListArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (int i=0; i<departmentTaxListArray.count; i++)
    {
        DepartmentTax *departmentTax=departmentTaxListArray[i];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taxId==%d",departmentTax.taxId.integerValue];
        fetchRequest.predicate = predicate;
        NSArray *itemTaxName = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if (itemTaxName.count>0)
        {
            TaxMaster *taxmaster=itemTaxName.firstObject;
            NSMutableDictionary *departmentTaxDictionary=[[NSMutableDictionary alloc]init];
            departmentTaxDictionary[@"PERCENTAGE"] = taxmaster.percentage;
            departmentTaxDictionary[@"Amount"] = taxmaster.amount;
            departmentTaxDictionary[@"TaxId"] = taxmaster.taxId;
            departmentTaxDictionary[@"TAXNAME"] = taxmaster.taxNAME;
            [taxDetail addObject:departmentTaxDictionary];
        }
    }
    deptModel.deptTaxArray = taxDetail;
    [self createtaxList];
}


- (NSMutableArray *)getDeptTaxParam
{
    NSMutableArray * deptTax = [[NSMutableArray alloc] init];
    if (deptModel.deptTaxArray.count > 0)
    {
        for (int iTax=0; iTax < deptModel.deptTaxArray.count; iTax++) {
            NSMutableDictionary * deptTaxDict = [[NSMutableDictionary alloc] init];
            
            deptTaxDict[@"TaxId"] = [deptModel.deptTaxArray[iTax] valueForKey:@"TaxId"];
            deptTaxDict[@"Amount"] = [deptModel.deptTaxArray[iTax] valueForKey:@"PERCENTAGE"];
            [deptTax addObject:deptTaxDict];
        }
    }
    [self setTaxDetailForDepartment:deptTax];
    return deptTax;
}

- (NSMutableDictionary *)dictionaryToUpdateDepartmentData
{
    NSMutableDictionary *dictDepartmentData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dictdeapartment = [[[[[self.deapartmentInsertDict valueForKey:@"DepartmentData"] firstObject] valueForKey:@"objDeptMaster"] firstObject] mutableCopy];
    
    if ([dictdeapartment valueForKey:@"DeptId"]) {
        dictDepartmentData[@"DeptId"] = [dictdeapartment valueForKey:@"DeptId"];
    }
    if(deptModel.isImageSet)
    {
        
    }
    else
    {
        if(self.updateDepartmentDictioanry != nil)
        {
            imagePath = (self.updateDepartmentDictioanry)[@"imagePath"];
        }
        else
        {
            imagePath = @"";
        }
    }
    
    dictDepartmentData[@"ImagePath"] = imagePath;
    dictDepartmentData[@"DeptName"] = [dictdeapartment  valueForKey:@"DeptName"];
    dictDepartmentData[@"DeptTypeId"] = @(deptModel.deptTypeId);
    dictDepartmentData[@"DeptCode"] = [dictdeapartment valueForKey:@"DeptCode"];
    dictDepartmentData[@"DeptTypeId"] = @(deptModel.deptTypeId);
    dictDepartmentData[@"ChkApplyAge"] = @([[dictdeapartment valueForKey:@"ChkApplyAge"] integerValue]);
    dictDepartmentData[@"ApplyAgeDesc"] = [dictdeapartment valueForKey:@"ApplyAgeDesc"];
    dictDepartmentData[@"ChkCheckCash"] = @([[dictdeapartment valueForKey:@"ChkCheckCash"] integerValue]);
    dictDepartmentData[@"CheckCashType"] = [dictdeapartment valueForKey:@"CheckCashType"];
    dictDepartmentData[@"CheckCashAmt"] = [dictdeapartment valueForKey:@"CheckCashAmt"];
    dictDepartmentData[@"ChkExtra"] = @([[dictdeapartment valueForKey:@"ChkExtra"] integerValue]);
    dictDepartmentData[@"ChargeTyp"] = [dictdeapartment valueForKey:@"ChargeTyp"];
    dictDepartmentData[@"ChargeAmt"] = [dictdeapartment valueForKey:@"ChargeAmt"];
    dictDepartmentData[@"TaxFlg"] = @([[dictdeapartment valueForKey:@"TaxFlg"] integerValue]);
    dictDepartmentData[@"TaxApplyIn"] = [dictdeapartment valueForKey:@"TaxApplyIn"];
    dictDepartmentData[@"Itemcode"] = @([[dictdeapartment valueForKey:@"itemCode"]integerValue]);
    dictDepartmentData[@"DeductChk"] = @([[dictdeapartment valueForKey:@"DeductChk"]integerValue]);
    dictDepartmentData[@"IsNotApplyInItem"] = @([[dictdeapartment valueForKey:@"IsNotApplyInItem"]integerValue]);
    dictDepartmentData[@"IsNotDisplayInventory"] = @([[dictdeapartment valueForKey:@"IsNotDisplayInventory"]integerValue]);
    return dictDepartmentData;
}

-(void)setTaxDetailForDepartment:(NSMutableArray *)taxArray
{
    for (NSMutableDictionary *deptTaxDict in taxArray)
    {
        if (deptId !=nil)
        {
            deptTaxDict[@"DeptId"] = deptId;
            [taxArrayForUpdate addObject:deptTaxDict];
        }
    }
}


#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tblInfo){
        return arrInfoRows.count;
    }
    else if (tableView == tblSetting){
        if (section == 0) {
            return 2;
        }
        else if (section == 1) {
            return 2;
        }
        
        else if (section == 2) {
            if (deptModel.deptTaxArray.count > 0) {
                return 2;
            }
        }
    }
    else if(tableView==tblItems) // Items
    {
        return _arrayDeptItems.count;
    }
    else if(tableView==tbltaxlist) // SELECTED TAX TABLE
    {
        if(deptModel.deptTaxArray.count > 0)
        {
            return deptModel.deptTaxArray.count;
        }
        else
        {
            return 0;
        }
    }
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == tblInfo)
        return 1;
    else if (tableView == tblSetting)
        return 3;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tbltaxlist) {
        return 30;
    }
    if(tableView == tblSetting)
    {
        if (indexPath.section == 2 && indexPath.row == 1) {
            return 150.0;
        }
        if (IsPhone()) {
            return 80;
        }
    }
    return 55.0;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        float borderSpace = 0;
        if (tableView == tblItems) {
            borderSpace = 20;
        }
        if (tableView != tbltaxlist) {
            [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:borderSpace];
            if ([cell isKindOfClass:[AddDepartmentCell class]]) {
                AddDepartmentCell * newCell = (AddDepartmentCell *)cell;
                if (newCell.txtInput) {
                    [tableView arrangeHeightOfViews:@[newCell.txtInput] WillDisplayCell:cell forRowAtIndexPath:indexPath];
                }
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == tblSetting || tableView == tblInfo) {
        return RIMHeaderHeight();
    }
    else
        return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == tblSetting || tableView == tblInfo)
    {
        NSString * strheader = @"";
        if (section == 0)
            strheader = @"DETAILS";
        else if (section == 1)
            strheader = @"DO NOT APPLY IN ITEM";
        else if (section == 2)
            strheader = @"DEPARTMENT TAX";
        return [tableView defaultTableHeaderView:strheader];
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
    
    if(tableView == tblInfo)
    {
        DepartmentInfoCell row = [arrInfoRows[indexPath.row] integerValue];
        switch (row) {
            case DepartmentInfoTabTypeRow:
                cell = [self configureDepartmentType:tableView cellForRowAtIndexPath:indexPath];
                break;
            case DepartmentInfoTabNameRow:
                cell = [self configureDepartment:tableView cellForRowAtIndexPath:indexPath];
                break;
            case DepartmentInfoTabCodeRow:
                cell = [self configureDepartmentCode:tableView cellForRowAtIndexPath:indexPath];
                break;
            case DepartmentInfoTabProfitRow:
                cell = [self configureProfitMargin:tableView cellForRowAtIndexPath:indexPath];
                break;
            case DepartmentInfoTabNotApplyInItemRow:
                cell = [self configureDoNotDisplayInInventory:tableView cellForRowAtIndexPath:indexPath];
                break;
            case DepartmentInfoTabAgeRow:
                cell = [self configureAgeRestriction:tableView cellForRowAtIndexPath:indexPath];
                break;
            case DepartmentInfoTabPayoutRow:
                cell = [self configurePayout:tableView cellForRowAtIndexPath:indexPath];
                break;
                
            default:
                break;
        }
    }
    else if(tableView == tblSetting)
    {
        
        if(indexPath.section == 0)
        {
            if (indexPath.row == 0) {//DepartmentSettingTabChequeCash
                cell = [self configureCheckCash:tableView cellForRowAtIndexPath:indexPath];
            }
            else
            if(indexPath.row == 1) {//DepartmentSettingTabChargeType
                cell = [self configureChargeType:tableView cellForRowAtIndexPath:indexPath];
            }
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                cell = [self configureDoNotApplyInItemOnOff:tableView cellForRowAtIndexPath:indexPath];
            }
            else if(indexPath.row == 1)
            {
                cell = [self configureTaxApplyIn:tableView cellForRowAtIndexPath:indexPath];
            }
        }
        else if(indexPath.section == 2)
        {
            if(indexPath.row == 0)
            {
                cell = [self configureDepartmentTax:tableView cellForRowAtIndexPath:indexPath];
            }
            if(deptModel.deptTaxArray.count > 0)
            {
                if(indexPath.row == 1)
                {
                    UITableViewCell *cellSetting = [[UITableViewCell alloc]init];
                    [cellSetting addSubview:taxview];
                    [cellSetting bringSubviewToFront:taxview];
                    cell = cellSetting;
                }
            }
        }
    }
    else if(tableView == tbltaxlist)
    {
        if(deptModel.deptTaxArray.count > 0)
        {
            tbltaxlist.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            NSMutableArray *deptTax = [deptModel.deptTaxArray mutableCopy];
            NSDictionary *deptTaxDict = deptTax[indexPath.row];
            
            UITableViewCell *cellTaxlist;
            cellTaxlist = [self selectedTaxForDepartment:deptTaxDict];
            cell = cellTaxlist;
        }
    }
    else if(tableView == tblItems)
    {
        cell = [self configureItemListCell:indexPath];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Department Info Tab -
- (UITableViewCell *)configureDepartmentType:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [self.tblInfo dequeueReusableCellWithIdentifier:@"DeptType" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Department Category";
    cell.swiOnOff.hidden = TRUE;
    cell.rowType = DepartmentInfoTabTypeRow;
    [cell.btnDropDown setTitle:[deptModel getStringDepartmentType] forState:UIControlStateNormal];
    cell.btnDropDown.tag = DepartmentTagDeptType;
//    [cell.btnDropDown addTarget:self action:@selector(showDepartmentTypePopup:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDropDown.imageEdgeInsets = UIEdgeInsetsMake(0, cell.btnDropDown.bounds.size.width - 30, 0, 0);
    return cell;
}

- (UITableViewCell *)configureDepartment:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [self.tblInfo dequeueReusableCellWithIdentifier:@"cellTextField" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Department Name";
    cell.txtInput.text = deptModel.strDeptName;
    cell.txtInput.placeholder = @"Enter Department Name";
    cell.txtInput.tag = DepartmentInfoTabNameRow;
    cell.rowType = DepartmentInfoTabNameRow;
    return cell;
}

- (UITableViewCell *)configureDepartmentCode:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [self.tblInfo dequeueReusableCellWithIdentifier:@"cellTextField" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Department Code";
    cell.txtInput.text = deptModel.strDeptCode;
    cell.txtInput.placeholder = @"Enter Department Code";
    cell.txtInput.tag = DepartmentInfoTabCodeRow;
    cell.rowType = DepartmentInfoTabCodeRow;
    return cell;
}

- (UITableViewCell *)configureProfitMargin:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellTextField" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Profit Margin";
    cell.txtInput.text = deptModel.strProfitMargin;
    cell.txtInput.placeholder = @"Enter Department Profit";
    cell.txtInput.tag = DepartmentInfoTabProfitRow;
    cell.rowType = DepartmentInfoTabProfitRow;
    return cell;
}

- (UITableViewCell *)configureDoNotDisplayInInventory:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [self.tblInfo dequeueReusableCellWithIdentifier:@"cellSwitch" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Do Not Display In Inventory Item";
    cell.swiOnOff.on = deptModel.isNotDisplayInventory;
    cell.rowType = DepartmentInfoTabNotApplyInItemRow;
    cell.swiOnOff.enabled = TRUE;
    cell.swiOnOff.tag = DepartmentTagDoNotDispRIM;
//    [cell.swiOnOff addTarget:self action:@selector(btnDoNotDisplayInInventoryClicked:) forControlEvents:UIControlEventValueChanged];
    return cell;
}
-(void)showDepartmentTypePopup:(UIView *)sender{
    
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"Default",@"Merchandise",@"Lottery",@"Gas",@"Money Order",@"Gift Card",@"Check Cash",@"Vendor Payout",@"House Charge",@"Other"] OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        deptModel.deptTypeId = [deptModel getDeptIdFromString:arrSelection[0]];
//        if ([@"Check Cash" isEqualToString:arrSelection[0]] && _arrayDeptItems.count > 1) {
//
//            [self showAlertMessage:nil alertMessage:@"Items are already added in this department, Please select another department type."];
//        }
//        else{
//
//            UIAlertActionHandler no = ^ (UIAlertAction *action)
//            {
//            };
//            UIAlertActionHandler confirm = ^ (UIAlertAction *action)
//            {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    deptModel.deptTypeId = [deptModel getDeptIdFromString:arrSelection[0]];
//                    [deptModel updateDepartmentType];
//                    [self.tblInfo reloadData];
//                    [self.tblSetting reloadData];
//                });
//            };
//            [self.rmsDbController popupAlertFromVC:self title:@"Confirmation" message:@"Age,Payout,Charge,Tax will be reset, Are you confirm to change department type ?" buttonTitles:@[@"No",@"Confirm"] buttonHandlers:@[no,confirm]];
//        }
    } SelectionColse:^(UIViewController * popUpVC){
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        [self.tblInfo reloadData];
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}
- (IBAction)btnDoNotDisplayInInventoryClicked:(UISwitch *)sender
{
    deptModel.isNotDisplayInventory = sender.on;
}

- (UITableViewCell *)configureAgeRestriction:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [self.tblInfo dequeueReusableCellWithIdentifier:@"cellAge" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Age Restriction";
    cell.swiOnOff.on = deptModel.isChkApplyAge;
    cell.swiOnOff.hidden = FALSE;
    cell.rowType = DepartmentInfoTabAgeRow;
    NSString * strAge = [NSString stringWithFormat:@"%@",deptModel.strApplyAgeDesc];
    
    cell.btnDropDown.tag = DepartmentTagAge;
    cell.swiOnOff.tag = DepartmentTagAge;
    [cell.btnDropDown setTitle:strAge forState:UIControlStateNormal];
//    [cell.btnDropDown addTarget:self action:@selector(btnAgeRestrictionPopup:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDropDown.imageEdgeInsets = UIEdgeInsetsMake(0, cell.btnDropDown.bounds.size.width - 30, 0, 0);
    
    cell.btnDropDown.enabled = deptModel.isChkApplyAge;
//    [cell.swiOnOff addTarget:self action:@selector(openAgeRestrictionDropDown:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (void)openAgeRestrictionDropDown:(UISwitch *)sender {
    deptModel.isChkApplyAge = sender.on;
    [self btnAgeRestrictionPopup:(UIButton *)sender];
}

- (void)btnAgeRestrictionPopup:(UIButton *)sender {
    if (deptModel.isChkApplyAge) {
        [self showAgePopup:sender];
    }
    else {
        deptModel.strApplyAgeDesc = @"Select";
        [self.tblInfo reloadData];
    }
}
-(void)showAgePopup:(UIView *)sender{
    
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"18+",@"21+"] OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        deptModel.strApplyAgeDesc = arrSelection[0];
        [self.tblInfo reloadData];
    } SelectionColse:^(UIViewController * popUpVC){
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        if ([deptModel.strApplyAgeDesc isEqualToString:@"Select"]) {
            deptModel.isChkApplyAge = FALSE;
            [self.tblInfo reloadData];
        }
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

- (UITableViewCell *)configurePayout:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [self.tblInfo dequeueReusableCellWithIdentifier:@"cellSwitch" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Payout";
    cell.swiOnOff.on = deptModel.isDeductChk;
    cell.rowType = DepartmentInfoTabNotApplyInItemRow;
    cell.swiOnOff.enabled = TRUE;
    if (deptModel.isChkCheckCash) {
        cell.swiOnOff.enabled = FALSE;
    }
    cell.swiOnOff.tag = DepartmentTagPayout;
//    [cell.swiOnOff addTarget:self action:@selector(payOutOnoff:) forControlEvents:UIControlEventValueChanged];
    return cell;
}
- (IBAction)payOutOnoff:(UISwitch *)sender
{
    
    BOOL isPayoutVal = deptModel.isDeductChk;
    deptModel.isDeductChk = TRUE;
    int intEBTCount = [self countDepartmentItemHaveEBTforThisDepartment];
    deptModel.isDeductChk = isPayoutVal;
    if (intEBTCount > 0 && sender.on) {
        [sender setOn:deptModel.isDeductChk animated:TRUE];
        NSString * strPayoutCount = [NSString stringWithFormat:@"%d items have a EBT",intEBTCount];
        [self showDeptAlertView:strPayoutCount forTextField:nil];
    }
    else if (deptModel.isChkCheckCash || deptModel.isChkExtra) {
        deptModel.isDeductChk = NO;
    }
    else
    {
        if(!deptModel.isTaxFlg || !sender.on){
            
            deptModel.isDeductChk = sender.on;
        }
        else {
            
            deptModel.isDeductChk = NO;
            sender.on = deptModel.isDeductChk;
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Please remove tax" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        [sender setOn:deptModel.isDeductChk animated:YES];
    }
    [self.tblInfo reloadData];
}


#pragma mark - Department Settings Cells -

- (UITableViewCell *)configureCheckCash:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSwitchTextField" forIndexPath:indexPath];
    
    cell.rowType = DepartmentSettingTabChequeCash;
    cell.lblTitle.text = @"Cheque Cash";
    
    [cell.btnDropDown setTitle:deptModel.strCheckCashType forState:UIControlStateNormal];

    cell.swiOnOff.on = deptModel.isChkCheckCash;
    cell.swiOnOff.tag = DepartmentTagChackCash;
//    [cell.swiOnOff addTarget:self action:@selector(btnCheckCashDropDownClicked:) forControlEvents:UIControlEventValueChanged];
//    
//    [cell.btnDropDown addTarget:self action:@selector(btnCheckCashPopup:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDropDown.imageEdgeInsets = UIEdgeInsetsMake(0, cell.btnDropDown.bounds.size.width - 30, 0, 0);
    cell.btnDropDown.tag = DepartmentTagChackCash;
    cell.txtInput.text = deptModel.strCheckCashAmt;
    cell.txtInput.placeholder = @"Cheque Amount";
    cell.txtInput.keyboardType = UIKeyboardTypeNumberPad;
    cell.txtInput.tag = DepartmentSettingTabChequeCash;

    cell.swiOnOff.userInteractionEnabled = TRUE;
    cell.txtInput.userInteractionEnabled = deptModel.isChkCheckCash;
    cell.btnDropDown.userInteractionEnabled = deptModel.isChkCheckCash;
    
    return cell;
}
- (IBAction)btnCheckCashDropDownClicked:(UISwitch *)sender {
    if (_arrayDeptItems.count > 1) {
        deptModel.isChkCheckCash = NO;
    }
    else {
        if (deptModel.isChkExtra == NO && deptModel.isDeductChk == NO) {
            if (sender.on == YES) {
                deptModel.isNotApplyInItem = YES;
                deptModel.isChkCheckCash = YES;
                [self btnCheckCashPopup:(UIButton *)sender];
            }
            else {
                deptModel.isNotApplyInItem = NO;
                deptModel.strCheckCashType = @"Select";
                deptModel.strCheckCashAmt = @"";
                deptModel.isChkCheckCash = NO;
            }
        }
        else {
            deptModel.isChkCheckCash = NO;
        }
    }
    //    [self validateCheckCashTextField];
    [self.tblSetting reloadData];
}

- (IBAction)btnCheckCashPopup:(UIButton *)sender
{
    if (deptModel.isChkCheckCash) {
        [self showCheckCashPopup:sender];
    }
}

-(void)showCheckCashPopup:(UIView *)sender{
    
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"Fix Charge",@"Percentage(%)"] OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        deptModel.strCheckCashType = arrSelection[0];
        [self.tblSetting reloadData];
    } SelectionColse:^(UIViewController * popUpVC){
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        if ([deptModel.strCheckCashType isEqualToString:@"Select"]) {
            deptModel.strCheckCashAmt = @"";
            deptModel.isChkCheckCash = FALSE;
            deptModel.isNotApplyInItem = FALSE;
            [self.tblSetting reloadData];
        }
    }];
    
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

- (UITableViewCell *)configureChargeType:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSwitchTextField" forIndexPath:indexPath];
    
    cell.rowType = DepartmentSettingTabChargeType;
    cell.lblTitle.text = @"Charge Type";
    
    [cell.btnDropDown setTitle:deptModel.strChargeTyp forState:UIControlStateNormal];

    cell.swiOnOff.on = deptModel.isChkExtra;
    
    cell.swiOnOff.tag = DepartmentTagChargeType;
    cell.btnDropDown.tag = DepartmentTagChargeType;
    
//    [cell.swiOnOff addTarget:self action:@selector(swiChargeTypeDropDownClicked:) forControlEvents:UIControlEventValueChanged];
//    
//    [cell.btnDropDown addTarget:self action:@selector(btnChargeTypePopup:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDropDown.imageEdgeInsets = UIEdgeInsetsMake(0, cell.btnDropDown.bounds.size.width - 30, 0, 0);
    
    cell.txtInput.text = deptModel.strChargeAmt;
    cell.txtInput.placeholder = @"Charge Amount";
    cell.txtInput.keyboardType = UIKeyboardTypeNumberPad;
    cell.txtInput.tag = DepartmentSettingTabChargeType;

    cell.swiOnOff.userInteractionEnabled = TRUE;
    cell.txtInput.userInteractionEnabled = deptModel.isChkExtra;
    cell.btnDropDown.userInteractionEnabled = deptModel.isChkExtra;
    
    return cell;
}

- (IBAction)swiChargeTypeDropDownClicked:(UISwitch *)sender
{
    if (deptModel.isChkCheckCash == NO && deptModel.isDeductChk == NO) {
        if (sender.on == YES) {
            deptModel.isChkExtra = YES;
            if (_arrayDeptItems.count > 1) {
                deptModel.isNotApplyInItem = NO;
            }
            else
            {
                deptModel.isNotApplyInItem = YES;
            }
            [self btnChargeTypePopup:(UIButton *)sender];
        }
        else
        {
            deptModel.strChargeTyp = @"Select";
            deptModel.strChargeAmt = @"";
            deptModel.isChkExtra = NO;
            deptModel.isNotApplyInItem = NO;
        }
    }
    else
    {
        deptModel.isChkExtra = NO;
    }
    //    [self validateChargeTypeTextField];
    [self.tblSetting reloadData];
}
- (IBAction)btnChargeTypePopup:(UIButton *)sender
{
    if (deptModel.isChkExtra) {
        [self showChargeTypePopup:sender];
    }
}
-(void)showChargeTypePopup:(UIView *)sender{
    
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"Fix Charge",@"Percentage(%)"] OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        deptModel.strChargeTyp = arrSelection[0];
        [self.tblSetting reloadData];
    } SelectionColse:^(UIViewController * popUpVC){
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        if ([deptModel.strChargeTyp isEqualToString:@"Select"]) {
            deptModel.strChargeAmt = @"";
            deptModel.isChkExtra = FALSE;
        }
        [self.tblSetting reloadData];
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}


- (UITableViewCell *)configureDoNotApplyInItemOnOff:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSwitch" forIndexPath:indexPath];
    
    cell.rowType = DepartmentSettingTabNotApplyItem;
    cell.lblTitle.text = @"Do Not Apply In Item";
    cell.swiOnOff.on = deptModel.isNotApplyInItem;
    cell.swiOnOff.enabled = TRUE;
    if (deptModel.isChkCheckCash) {
        cell.swiOnOff.enabled = FALSE;
    }
    cell.swiOnOff.tag = DepartmentTagNotApplyItem;
//    [cell.swiOnOff addTarget:self action:@selector(swiDoNotApplyInItemOnOffClicked:) forControlEvents:UIControlEventValueChanged];
    return cell;
}
- (void)swiDoNotApplyInItemOnOffClicked:(UISwitch *)sender
{
    if (_arrayDeptItems.count > 1) {
        if (deptModel.isChkCheckCash ==  YES) {
            deptModel.isChkCheckCash = NO;
            deptModel.strCheckCashAmt = @"Select";
            deptModel.strCheckCashAmt = @"0";
        }
        deptModel.isNotApplyInItem = NO;
    }
    else
    {
        if (deptModel.isChkCheckCash) {
            deptModel.isNotApplyInItem = YES;
        }
        else {
            deptModel.isNotApplyInItem = sender.on;
        }
    }
    [self.tblSetting reloadData];
}
- (UITableViewCell *)configureTaxApplyIn:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSwitchButton" forIndexPath:indexPath];
    
    cell.rowType = DepartmentSettingTabTaxApplyIn;
    cell.lblTitle.text = @"Tax Apply In";
    
    [cell.btnDropDown setTitle:deptModel.strTaxApplyIn forState:UIControlStateNormal];
    cell.swiOnOff.on = deptModel.isTaxApplyIn;
    
    cell.swiOnOff.tag = DepartmentTagTaxApplyIn;
    cell.btnDropDown.tag = DepartmentTagTaxApplyIn;
//    [cell.swiOnOff addTarget:self action:@selector(swiTaxApplyInDropDown:) forControlEvents:UIControlEventValueChanged];
//    
//    [cell.btnDropDown addTarget:self action:@selector(btnTaxApplyInPopup:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDropDown.imageEdgeInsets = UIEdgeInsetsMake(0, cell.btnDropDown.bounds.size.width - 30, 0, 0);
    
    cell.btnDropDown.userInteractionEnabled = deptModel.isTaxApplyIn;
    
    return cell;
}

- (IBAction)swiTaxApplyInDropDown:(UISwitch *)sender
{
    deptModel.isTaxApplyIn = sender.on;
    if (sender.on == YES) {
        [self btnTaxApplyInPopup:(UIButton *)sender];
    }
    else {
        deptModel.strTaxApplyIn = @"Select";
        [self.tblSetting reloadData];
    }
}
- (IBAction)btnTaxApplyInPopup:(UIButton *)sender
{
    if (deptModel.isTaxApplyIn) {
        [self showTaxApplyInPopup:sender];
    }
    
}
-(void)showTaxApplyInPopup:(UIView *)sender{
    
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"Price",@"Fee",@"Both"] OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        deptModel.strTaxApplyIn = arrSelection[0];
        [self.tblSetting reloadData];
    } SelectionColse:^(UIViewController * popUpVC){
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        if ([deptModel.strTaxApplyIn isEqualToString:@"Select"]) {
            deptModel.isTaxApplyIn = FALSE;
            [self.tblSetting reloadData];
        }
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}
- (UITableViewCell *)configureDepartmentTax:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSwitchButton" forIndexPath:indexPath];
    
    cell.rowType = DepartmentSettingTabDepartmentTax;
    cell.lblTitle.text = @"Department Tax";
    
    [cell.btnDropDown setTitle:deptModel.strDepartmentTax forState:UIControlStateNormal];
    
    cell.swiOnOff.on = deptModel.isTaxFlg;
    
    cell.swiOnOff.tag = DepartmentTagDeptTax;
    cell.btnDropDown.tag = DepartmentTagDeptTax;
    
//    [cell.swiOnOff addTarget:self action:@selector(swiDepartmentTax:) forControlEvents:UIControlEventValueChanged];
//    
//    [cell.btnDropDown addTarget:self action:@selector(btnDepartmentTaxpopup:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDropDown.imageEdgeInsets = UIEdgeInsetsMake(0, cell.btnDropDown.bounds.size.width - 30, 0, 0);
    
    cell.btnDropDown.userInteractionEnabled = deptModel.isTaxFlg;
    
    return cell;
}
- (IBAction)swiDepartmentTax:(UISwitch *)sender
{
    
    int intPayoutCount = [self countDepartmentItemHavePayoutforThisDepartment];
    if (intPayoutCount > 0 && sender.on) {
        NSString * strPayoutMessage = [NSString stringWithFormat:@"%d items have a Payout",intPayoutCount];
        [self showDeptAlertView:strPayoutMessage forTextField:nil];
        deptModel.isTaxFlg = NO;
        [taxview removeFromSuperview];
        deptModel.strDepartmentTax = @"Select";
    }
    else if(!deptModel.isDeductChk || !sender.on){
        
        if (sender.on == YES) {
            [self taxprocess];
            deptModel.isTaxFlg = YES;
        }
        else
        {
            deptModel.isTaxFlg = NO;
            [taxview removeFromSuperview];
            deptModel.strDepartmentTax = @"Select";
        }
    }
    else {
        
        deptModel.isTaxFlg = NO;
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please remove payout" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
    [deptModel.deptTaxArray removeAllObjects];
    [tbltaxlist reloadData];
    [tblSetting reloadData];
}

- (IBAction)btnDepartmentTaxpopup:(id)sender
{
    if (deptModel.isTaxFlg) {
        [self taxprocess];
    }
}
-(void) taxprocess
{
    if (_taxAddRemoveiPad) {
        [_taxAddRemoveiPad.view removeFromSuperview];
    }
    _taxAddRemoveiPad =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimTaxAddRemovePage_sid"];
    [self addChildViewController:_taxAddRemoveiPad];
    _taxAddRemoveiPad.checkedTaxItem = deptModel.deptTaxArray;
    _taxAddRemoveiPad.rimTaxAddRemovePageDelegate = self;
    if (IsPad()) {
        _taxAddRemoveiPad.view.frame = CGRectMake(0,0,740 ,self.view.frame.size.height);
    }
    else {
        _taxAddRemoveiPad.view.frame = self.view.bounds;
    }
    [self.view addSubview:_taxAddRemoveiPad.view];
}
#pragma Tax selection

- (void)didSelectTax:(NSMutableArray *)taxListArray {
    NSDictionary *taxDict = @{kRIMDepartmentTaxSelectedKey : @(taxListArray.count)};
    [Appsee addEvent:kRIMDepartmentTaxSelected withProperties:taxDict];
    
    if(taxListArray.count > 0)
    {
        deptModel.strDepartmentTax = @"Tax Type";
        deptModel.deptTaxArray = [taxListArray mutableCopy];
        [self createtaxList];
    }
    
    else
    {
        deptModel.deptTaxArray = [taxListArray mutableCopy];
        deptModel.strDepartmentTax = @"Select";
        [self createtaxList];
    }
    [self.taxAddRemoveiPad.view removeFromSuperview];
}

-(void)createtaxList
{
    for(UIView *subview in taxview.subviews) {
        [subview removeFromSuperview];
    }
    if(deptModel.deptTaxArray.count>0) {
        
        deptModel.strDepartmentTax = @"Tax Type";
        if (IsPhone()) {
            
            if(deptModel.deptTaxArray.count == 1) {
                
                taxview.frame = CGRectMake(15, 0, 305,50);
                tbltaxlist.frame = CGRectMake(0, 5, 305,50);
            }
            else {
                taxview.frame = CGRectMake(15, 0, 305,100);
                tbltaxlist.frame = CGRectMake(0, 5, 305,100);
            }
            tbltaxlist.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tbltaxlist.separatorInset = UIEdgeInsetsZero;
        }
        else {
            
            taxview.frame = CGRectMake(0, 0, 684,140);
            tbltaxlist.frame = CGRectMake(20, 25, 664,120);
            tbltaxlist.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        
        taxview.backgroundColor = [UIColor clearColor];
        
        tbltaxlist.scrollEnabled = YES;
        tbltaxlist.userInteractionEnabled = YES;
        tbltaxlist.bounces = YES;
        tbltaxlist.delegate = self;
        tbltaxlist.dataSource = self;
        tbltaxlist.backgroundColor = [UIColor clearColor];
        
        if (IsPad())
        {
            UILabel  * labelTax = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 250, 20)];
            labelTax.backgroundColor = [UIColor clearColor];
            labelTax.textAlignment = NSTextAlignmentLeft; // UITextAlignmentCenter, UITextAlignmentLeft
            labelTax.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            labelTax.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
            labelTax.numberOfLines=0;
            labelTax.text = @"Tax Name(s)";
            
            UILabel  * labelTaxPercentage = [[UILabel alloc] initWithFrame:CGRectMake(330, 5, 250, 20)];
            labelTaxPercentage.backgroundColor = [UIColor clearColor];
            labelTaxPercentage.textAlignment = NSTextAlignmentLeft;
            labelTaxPercentage.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            labelTaxPercentage.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
            labelTaxPercentage.numberOfLines=0;
            labelTaxPercentage.text = @"Tax %";
            
            [taxview addSubview:labelTax];
            [taxview addSubview:labelTaxPercentage];
        }
        else
        {
            
        }
        [taxview addSubview:tbltaxlist];
    }
    else
    {
        [self.tblSetting reloadData];
    }
    [self.tblSetting reloadData];
    [tbltaxlist reloadData];
}

-(IBAction)btnDropDownTapped:(UIButton *) sender {
    switch (sender.tag) {
        case DepartmentTagDeptType:
            [self showDepartmentTypePopup:sender];
            break;
        case DepartmentTagAge:
            [self btnAgeRestrictionPopup:sender];
            break;
        case DepartmentTagChargeType:
            [self btnChargeTypePopup:sender];
            break;
        case DepartmentTagChackCash:
            [self btnCheckCashPopup:sender];
            break;
        case DepartmentTagTaxApplyIn:
            [self btnTaxApplyInPopup:sender];
            break;
        case DepartmentTagDeptTax:
            [self btnDepartmentTaxpopup:sender];
            break;
            
        default:
            break;
    }
}

-(IBAction)btnSwitchTapped:(UISwitch *) sender {
    switch (sender.tag) {
        case DepartmentTagDoNotDispRIM:
            [self btnDoNotDisplayInInventoryClicked:sender];
            break;
        case DepartmentTagAge:
            [self openAgeRestrictionDropDown:sender];
            break;
        case DepartmentTagPayout:
            [self payOutOnoff:sender];
            break;
        case DepartmentTagChackCash:
            [self btnCheckCashDropDownClicked:sender];
            break;
        case DepartmentTagChargeType:
            [self swiChargeTypeDropDownClicked:sender];
            break;
        case DepartmentTagNotApplyItem:
            [self swiDoNotApplyInItemOnOffClicked:sender];
            break;
        case DepartmentTagTaxApplyIn:
            [self swiTaxApplyInDropDown:sender];
            break;
        case DepartmentTagDeptTax:
            [self swiDepartmentTax:sender];
            break;
        default:
            break;
    }
}
#pragma mark - Tax For Department Cell

- (UITableViewCell *)selectedTaxForDepartment:(NSDictionary *)deptTaxDict
{
    UITableViewCell *cellTaxlist = [[UITableViewCell alloc]init];
    cellTaxlist.backgroundColor = [UIColor clearColor];
    cellTaxlist.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect taxNameFrame;
    CGRect taxPercentageFrame;
    if(IsPhone())
    {
        taxNameFrame = CGRectMake(5, 5, 200, 20);
        taxPercentageFrame = CGRectMake(210, 5, 200, 20);
    }
    else
    {
        taxNameFrame = CGRectMake(40, 5, 250, 20);
        taxPercentageFrame = CGRectMake(315, 5, 250, 20);
    }
    
    
    UILabel * taxname = [[UILabel alloc] initWithFrame:taxNameFrame];
    taxname.text = [deptTaxDict valueForKey:@"TAXNAME"];
    taxname.backgroundColor = [UIColor clearColor];
    taxname.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
    taxname.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    [cellTaxlist.contentView addSubview:taxname];
    
    UILabel * tax = [[UILabel alloc] initWithFrame:taxPercentageFrame];
    tax.textAlignment =  NSTextAlignmentLeft;
    tax.text = [NSString stringWithFormat:@"%.2f",[[deptTaxDict valueForKey:@"PERCENTAGE" ] floatValue]];
    tax.backgroundColor = [UIColor clearColor];
    tax.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
    tax.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    [cellTaxlist.contentView addSubview:tax];
    return cellTaxlist;
}

#pragma mark - ItemTableView Cell -

- (ItemListCell *)configureItemListCell:(NSIndexPath *)indexPath
{

    ItemListCell *itemListCell = (ItemListCell *)[self.tblItems dequeueReusableCellWithIdentifier:@"ItemListCell"];
    itemListCell.backgroundColor = [UIColor clearColor];
    itemListCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dictIteminfo = _arrayDeptItems[indexPath.row];
    itemListCell.lblBarcode.text = [dictIteminfo valueForKey:@"Barcode"];
    itemListCell.lblItemName.text = [dictIteminfo valueForKey:@"ItemName"];

    return itemListCell;
}

#pragma mark - Show Dept AlertView

-(void)showDeptAlertView:(NSString *)alertMessage forTextField:(UITextField *)textField
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        if (textField) {
            [textField becomeFirstResponder];
        }
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:alertMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}


#pragma mark - Department Image Capture -

-(void)selectImageCaptureForDepartment:(UIButton *)sender {
    
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
            [self removeItemImage];
        }
        
    } SelectionColse:^(UIViewController * popUpVC){
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
        
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}


-(void)itemImageChangeNewImage:(UIImage *)image withImageUrl:(NSString *)imageUrl {
    deptModel.isImageSet = TRUE;
    deptModel.isImageDeleted = FALSE;
    
    NSMutableDictionary *departmentData = [NSMutableDictionary dictionary];
    [departmentData setValue:image forKey:@"imagePath"];
    imagePath = [departmentData valueForKey:@"imagePath"];
    if ([departmentData valueForKey:@"imagePath"] != nil)
    {
        (self.updateDepartmentDictioanry)[@"imagePath"] = [departmentData valueForKey:@"imagePath"];
    }
    [objDepartmentInfo didUpdateDepatmentInfo:departmentData];
    selectedImage = image;
    if (IsPad()) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIImagePickerController Delegate Method

-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if (IsPhone())
        {
            pickerCamera = [[UIImagePickerController alloc] init];
            pickerCamera.delegate = self;
            pickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerCamera animated:YES completion:NULL];
        }
        else
        {
            pickerCamera = [[UIImagePickerController alloc] init];
            pickerCamera.delegate = self;
            pickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerCamera animated:YES completion:nil];
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Camera not available" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}
-(void)ChooseExisting:(UIView *)sender {
    if(IsPad()) {
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
    [[UIStoryboard storyboardWithName:@"Main"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemImageSelectionVC_sid"];
    
    itemImageSelectionVC.itemSelctionImageChangedVCDelegate = self;
    itemImageSelectionVC.strSearchText = deptModel.strDeptName;
    if (IsPad()) {
        [itemImageSelectionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
    }
    else {
        UIViewController * view = [[UIViewController alloc]init];
        CGRect frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-self.navigationController.navigationBar.frame.size.height-20);
        itemImageSelectionVC.view.frame = frame;
        [view.view addSubview:itemImageSelectionVC.view];
        view.view.backgroundColor = [UIColor redColor];
        [view addChildViewController:itemImageSelectionVC];
        [self.navigationController pushViewController:view animated:YES];
    }
}
-(void)removeItemImage {
    [Appsee addEvent:kRIMDepartmentRemoveImage];
    AddDepartmentVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [Appsee addEvent:kRIMDepartmentRemoveImageCancel];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [Appsee addEvent:kRIMDepartmentRemoveImageDone];
        selectedImage = nil;
        NSMutableDictionary *departmentData = [NSMutableDictionary dictionary];
        [departmentData setValue:@"" forKey:@"imagePath"];
        imagePath = [departmentData valueForKey:@"imagePath"];
        (myWeakReference.updateDepartmentDictioanry)[@"imagePath"] = [departmentData valueForKey:@"imagePath"];
        deptModel.isImageSet = TRUE;
        deptModel.isImageDeleted = TRUE;
        [objDepartmentInfo didUpdateDepatmentInfo:departmentData];
    };
    
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to remove department image ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    selectedImage = info[UIImagePickerControllerOriginalImage];
    NSMutableDictionary *departmentData = [NSMutableDictionary dictionary];
    [departmentData setValue:selectedImage forKey:@"imagePath"];
    imagePath = [departmentData valueForKey:@"imagePath"];
    if ([departmentData valueForKey:@"imagePath"] != nil)
    {
        (self.updateDepartmentDictioanry)[@"imagePath"] = [departmentData valueForKey:@"imagePath"];
    }
    deptModel.isImageSet=TRUE;
    deptModel.isImageDeleted = FALSE;
    [objDepartmentInfo didUpdateDepatmentInfo:departmentData];
    if (IsPad())
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    deptModel.isImageSet=TRUE;
    pickerCamera=nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//
//#pragma mark - Collectionview Delegate
//// IMAGE SEARCH FUNCTIONS
//-(IBAction)btnHideImageViewClicked:(id)sender
//{
//    _imageView.hidden = YES;
//}
//
//-(IBAction)btnImageSearchClicked:(id)sender
//{
//    self.searchImageResult = [[NSMutableArray alloc] init];
//    [self.imageCollectionView reloadData];
//    
//    if(self.txtImageName.text.length > 0)
//    {
//        _activityIndicator = [RmsActivityIndicator showActivityIndicator:_imageView];
//                
//        NSMutableDictionary *searchImageName = [[NSMutableDictionary alloc] init];
//        searchImageName[@"Item_Name"] = self.txtImageName.text;
//        
//        NSDictionary *imageDict = @{kRIMDepartmentImageSearchWebServiceCallKey : self.txtImageName.text};
//        [Appsee addEvent:kRIMDepartmentImageSearchWebServiceCall withProperties:imageDict];
//        
//        CompletionHandler completionHandler = ^(id response, NSError *error) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self responseSearchImageResponse:response error:error];
//            });
//        };
//        
//        self.getItemImageListByNameWC = [self.getItemImageListByNameWC initWithRequest:KURL actionName:WSM_GET_ITEM_IMAGE_LIST_BY_NAME params:searchImageName completionHandler:completionHandler];
//    }
//    else {
//        
//        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//        {
//        };
//        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please enter department name" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
//    }
//}
//
//- (void)responseSearchImageResponse:(id)response error:(NSError *)error {
//
//    [_activityIndicator hideActivityIndicator];
//    
//    if (response != nil) {
//        if ([response isKindOfClass:[NSDictionary class]]) {
//            if ([[response valueForKey:@"IsError"] intValue] == 0) {
//                
//                self.searchImageResult = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
//                
//                NSDictionary *imageResponseDict = @{kRIMDepartmentImageSearchWebServiceResponseKey : @(self.searchImageResult.count)};
//                [Appsee addEvent:kRIMDepartmentImageSearchWebServiceResponse withProperties:imageResponseDict];
//                
//                [self.imageCollectionView reloadData];
//            }
//
//        }
//    }
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return self.searchImageResult.count;
//}
//
//- (ImagesCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ImagesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
//    if(self.searchImageResult.count > 0)
//    {
//        NSString *imgString = [NSString stringWithFormat:@"%@",[(self.searchImageResult)[indexPath.row] valueForKey:@"Image"]];
//        [cell.itemImages loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imgString]]];
//    }
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    isImageSet = TRUE;
//    IsImageDeleted = FALSE;
//    ImagesCell *cell = (ImagesCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    
//    NSMutableDictionary *departmentData = [NSMutableDictionary dictionary];
//    [departmentData setValue:[(self.searchImageResult)[indexPath.row] valueForKey:@"Image"] forKey:@"imagePath"];
//    imagePath = [departmentData valueForKey:@"imagePath"];
//    if ([departmentData valueForKey:@"imagePath"] != nil)
//    {
//        (self.updateDepartmentDictioanry)[@"imagePath"] = [departmentData valueForKey:@"imagePath"];
//    }
//    [objDepartmentInfo didUpdateDepatmentInfo:departmentData];
//    selectedImage = cell.itemImages.image;
//    
//    if(IsPad())
//    {
//        [popover dismissPopoverAnimated:YES];
//    }
//    else
//    {
//        _imageView.hidden = YES;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
