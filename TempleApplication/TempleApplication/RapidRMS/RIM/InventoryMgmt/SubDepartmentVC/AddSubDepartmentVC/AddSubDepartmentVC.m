//
//  AddDepartmentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 08/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AddDepartmentCell.h"
#import "AddSubDepartmentModel.h"
#import "AddSubDepartmentVC.h"
#import "Department+Dictionary.h"
#import "DepartmentMultiple.h"
#import "DisplaySubDepartmentInfoSideVC.h"
#import "ImagesCell.h"
#import "Item+Dictionary.h"
#import "ItemImageSelectionVC.h"
#import "ItemListCell.h"
#import "MultipleDepartmentSelectionVC.h"
#import "NSString+Validation.h"
#import "RimsController.h"
#import "RmsDbController.h"
#import "selectUserOptionVC.h"
#import "SubDepartment+Dictionary.h"
#import "UITableView+AddBorder.h"
#import "UpdateManager.h"


@interface AddSubDepartmentVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UpdateDelegate,UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate,AddDepartmentMultipleDelegate,ItemSelctionImageChangedVCDelegate>
{
    UIImagePickerController *controller;
    UIImagePickerController *pickerCamera;
    MultipleDepartmentSelectionVC *multipleDepartmentSelectionVC;

    BOOL isImageDeleted;

    
    UIButton *btnCameraClick;

    NSString *StrBrnSubDeptID;
    NSString *imagePath;
    
    UIImage *selectedImage;
    
    NSData *imageData;
    AddSubDepartmentModel * addSubDeptModel;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *subDeapartmentInsertDict;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) DisplaySubDepartmentInfoSideVC *objSubDepartmentInfo;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) SubDepartment *subdepartment;

@property (nonatomic) BOOL isImageSet;

@property (assign) NSInteger itemCode;

@property (nonatomic, weak) IBOutlet UIView *uvInfo;
@property (nonatomic, weak) IBOutlet UIView *uvItems;
@property (nonatomic, weak) IBOutlet UIView *uvDeaprtment;
@property (nonatomic, weak) IBOutlet UIView *viewSideInfoGB;

@property (nonatomic, weak) IBOutlet UITableView *tblItems;
@property (nonatomic, weak) IBOutlet UITableView *tblDepartment;

@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnDepartment;
@property (nonatomic, weak) IBOutlet UIButton *btnInfo;
@property (nonatomic, weak) IBOutlet UIButton *btnItems;
@property (nonatomic, weak) IBOutlet UIButton *btnSave;

@property (nonatomic, strong) NSMutableArray *arraysubDeptItems;
@property (nonatomic, strong) NSMutableArray *arrayDepartment;
@property (nonatomic, strong) NSMutableArray *arrSelectedDepartment;

@property (nonatomic, strong) RapidWebServiceConnection * getItemImageListByNameWC;
@property (nonatomic, strong) RapidWebServiceConnection * subDepartmentInsert;
@property (nonatomic, strong) RapidWebServiceConnection * subDepartmentUpdate;
@property (nonatomic, strong) RapidWebServiceConnection * subDepartmentDelete;


@end

@implementation AddSubDepartmentVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tblAddSubDepartment reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    _btnInfo.selected = YES;
    _uvInfo.hidden = NO;
    _uvItems.hidden = YES;
    _uvDeaprtment.hidden = YES;
    
    _btnItems.selected = NO;
    _btnDepartment.selected = NO;
    self.btnDepartment.hidden = YES;
    _btnItems.hidden = YES;
    
    
    [_tblAddSubDepartment reloadData];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.subDepartmentInsert = [[RapidWebServiceConnection alloc]init];
    self.subDepartmentUpdate = [[RapidWebServiceConnection alloc]init];
    self.subDepartmentDelete = [[RapidWebServiceConnection alloc]init];
    self.getItemImageListByNameWC = [[RapidWebServiceConnection alloc]init];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
//    [self allocAllFields];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self LoadDataFromDataBase];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)LoadDataFromDataBase{
    self.arrDepartment = [[NSMutableArray alloc]init];
    addSubDeptModel = [[AddSubDepartmentModel alloc]init];
    [addSubDeptModel updateViewWithsubDepartmentDetail:self.updateSubDepartmentDictionary];
    [self getSelectedDepartment:[self.updateSubDepartmentDictionary valueForKey:@"DeptId"]];
//    [self updateViewWithsubDepartmentDetail:self.updateSubDepartmentDictionary];
    if(self.updateSubDepartmentDictionary != nil)
    {
        self.btnDepartment.hidden = NO;
        _btnItems.hidden = NO;
        self.btnDelete.enabled = YES;
        [self getItemAndDepartment];
        
    }
    else
    {
        self.btnDelete.enabled = NO;
    }
    isImageDeleted = FALSE;
    
    [self showSideSubDepartmentInfo:self.updateSubDepartmentDictionary];
    
    imagePath = [[NSString alloc] init];
    
    if ([self.subdepartment.brnSubDeptID isEqualToNumber:@0]) {
        [_btnSave setEnabled:FALSE];
        [self.btnDelete setEnabled:FALSE];
    }
    [_tblItems reloadData];
    [_tblDepartment reloadData];
    [_tblAddSubDepartment reloadData];
    [_activityIndicator hideActivityIndicator];
}
-(void)getItemAndDepartment{
    
    self.subdepartment = (SubDepartment *)[self.updateManager __fetchEntityWithName:@"SubDepartment" key:@"brnSubDeptID" value:@([[self.updateSubDepartmentDictionary valueForKey:@"BrnSubDeptID"] integerValue]) shouldCreate:NO moc:self.managedObjectContext];
    _arraysubDeptItems = [[NSMutableArray alloc]init];
    _arrayDepartment = [[NSMutableArray alloc]init];
    for (Item *item in self.subdepartment.subDepartmentItems) {
        NSMutableDictionary *dictItem = [item.itemDictionary mutableCopy];
        dictItem[@"BrnSubDeptID"] = [self.updateSubDepartmentDictionary valueForKey:@"BrnSubDeptID"];
        [_arraysubDeptItems addObject:dictItem];
    }
    
    
    for (NSMutableDictionary *dictitem in _arraysubDeptItems) {
        Department *dept = [self.updateManager fetchDepartmentWithDepartmentId:[dictitem valueForKey:@"DepartId"] moc:self.managedObjectContext];
        if (dept) {
            [_arrayDepartment addObject:dept.getdepartmentLoadDictionary];
        }
    }
    _arrayDepartment = [[NSMutableArray alloc] initWithArray:[NSSet setWithArray:_arrayDepartment].allObjects];
    if(_arraysubDeptItems.count>0){
        [self.tblItems reloadData];
    }
    else
    {
        [_btnItems setHidden:YES];
        [_uvItems setHidden:YES];
        
    }
    if(_arrayDepartment.count>0){
        [self.tblDepartment reloadData];
    }
    else{
        [_btnDepartment setHidden:YES];
        [_uvDeaprtment setHidden:YES];
    }
    [self.tblAddSubDepartment reloadData];
    [_activityIndicator hideActivityIndicator];
}

-(IBAction)btnInfoClick:(id)sender
{
    [Appsee addEvent:kRIMDepartmentInfo];
    _uvInfo.hidden = NO;
    _uvItems.hidden = YES;
    _uvDeaprtment.hidden = YES;
    _btnInfo.selected = TRUE;
    _btnDepartment.selected = FALSE;
    _btnItems.selected = FALSE;
}
-(IBAction)btnDepartmentClick:(id)sender
{
    _uvInfo.hidden = YES;
    _uvItems.hidden = YES;
    _uvDeaprtment.hidden = NO;
    _btnInfo.selected = FALSE;
    _btnDepartment.selected = TRUE;
    _btnItems.selected = FALSE;
}

-(IBAction)btnItemsClick:(id)sender
{
    _uvInfo.hidden = YES;
    _uvItems.hidden = NO;
    _uvDeaprtment.hidden = YES;
    _btnInfo.selected = FALSE;
    _btnDepartment.selected = FALSE;
    _btnItems.selected = TRUE;
}

- (void)getSelectedDepartment:(NSString *)strDepartmentId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    self.arrSelectedDepartment = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %@",strDepartmentId];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        for (Department *departmentmst in resultSet) {
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"DepartmentName"] = departmentmst.deptName;
            addSubDeptModel.strDepartmentID = [NSString stringWithFormat:@"%@",departmentmst.deptId];
            addSubDeptModel.strDepartment = [NSString stringWithFormat:@"%@",departmentmst.deptName];
            supplierDict[@"DeptId"] = departmentmst.deptId;
            supplierDict[@"isNotApplyInItem"] = departmentmst.isNotApplyInItem;
            [self.arrSelectedDepartment addObject:supplierDict];
        }
    }
}

#pragma mark - Show Info In Side Menu

-(void)showSideSubDepartmentInfo:(NSMutableDictionary *)subDepartmentDictionary
{
    [[self.view viewWithTag:252525] removeFromSuperview ];
    _objSubDepartmentInfo = [[DisplaySubDepartmentInfoSideVC alloc]initWithNibName:@"DisplaySubDepartmentInfoSideVC" bundle:nil];
    _objSubDepartmentInfo.subDepartmentInfoDictionary = [subDepartmentDictionary mutableCopy];
    _objSubDepartmentInfo.view.frame = self.viewSideInfoGB.bounds;
    _objSubDepartmentInfo.view.tag = 252525;
    _objSubDepartmentInfo.objAddSubDepartmentVC = (AddSubDepartmentVC *)self;
    [self.viewSideInfoGB addSubview:_objSubDepartmentInfo.view];
}

-(IBAction)btnCloseClicked:(id)sender
{
    [Appsee addEvent:kRIMSubDepartmentClose];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnSaveSubDepartment:(id)sender
{
    [self.view endEditing:YES];
    [Appsee addEvent:kRIMSubDepartmentSave];
    [self.rmsDbController playButtonSound];
    if([NSString trimSpacesFromStartAndEnd:addSubDeptModel.strSubDeptName].length == 0)
    {
        [self showSubDeptAlertView:@"Plaese enter Subdepartment Name" forTextField:nil];
        return;
    }
    else if([NSString trimSpacesFromStartAndEnd:addSubDeptModel.strSubDeptCode].length == 0)
    {
        [self showSubDeptAlertView:@"Please enter SubDepartment Code" forTextField:nil];
        return;
    }
    
    if (![self isSubDepartmentNameIsValid]) {
        [self showSubDeptAlertView:@"Please enter Unique SubDepartment Name" forTextField:nil];
        return;
    }
    if (![self isSubDepartmentCodeIsValid]) {
        [self showSubDeptAlertView:@"Please enter Unique SubDepartment Code" forTextField:nil];
        return ;
    }

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    
    _subDeapartmentInsertDict = [self getSubDeparmentProcessData];
    
    if (self.updateSubDepartmentDictionary == nil) {
        [Appsee addEvent:kRIMSubDepartmentInsertWebServiceCall];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doInsertProcessForSubDepartmentResponse:response error:error];
            });
        };
        
        self.subDepartmentInsert = [self.subDepartmentInsert initWithRequest:KURL actionName:WSM_INSERT_SUB_DEPARTMENT params:_subDeapartmentInsertDict completionHandler:completionHandler];
    }
    else {
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doUpdateProcessForSubDepartmentResponse:response error:error];
            });
        };
        
        self.subDepartmentUpdate = [self.subDepartmentUpdate initWithRequest:KURL actionName:WSM_UPDATE_SUB_DEPARTMENT params:_subDeapartmentInsertDict completionHandler:completionHandler];
    }
}

- (void)doInsertProcessForSubDepartmentResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                [Appsee addEvent:kRIMSubDepartmentInsertWebServiceResponse withProperties:@{kRIMSubDepartmentInsertWebServiceResponseKey : @"Sub Department has been added successfully"}];
                NSMutableDictionary *responseDict  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString *imgpath = [NSString stringWithFormat:@"%@",[responseDict valueForKey:@"imgpath"]];
                
                NSString *strsubdepid = [responseDict valueForKey:@"Answer"];
                NSString *strItemcode = [responseDict valueForKey:@"ItemCode"];
                
                NSMutableDictionary *pDict = [[self dictionaryToUpdateData] mutableCopy];
                pDict[@"SubDeptImagePath"] = imgpath;
                pDict[@"BrnSubDeptID"] = strsubdepid;
                pDict[@"ItemCode"] = strItemcode;
                
                if(addSubDeptModel.strDepartmentID.length >0){
                    pDict[@"DeptId"] = addSubDeptModel.strDepartmentID;
                    
                }
                else{
                    pDict[@"DeptId"] = @"0";
                }
                
                [self.updateManager insertSubDepartmentWithDictionary:pDict];
                [self.addSubDepartmentVCDelegate didAddedNewSubDepartment:pDict];
                AddSubDepartmentVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Sub Department has been added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                [Appsee addEvent:kRIMSubDepartmentInsertWebServiceResponse withProperties:@{kRIMSubDepartmentInsertWebServiceResponseKey : @"Sub Department not Added, try again."}];
                NSString *message = [response valueForKey:@"Data"];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

- (void)doUpdateProcessForSubDepartmentResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                [Appsee addEvent:kRIMSubDepartmentUpdateWebServiceResponse withProperties:@{kRIMSubDepartmentUpdateWebServiceResponseKey : @"Sub Department has been Updated successfully"}];
                NSMutableDictionary *responseDict  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSString *imgpath = [NSString stringWithFormat:@"%@",[responseDict valueForKey:@"imgpath"]];
                
                NSMutableDictionary *pDict = [self dictionaryToUpdateData];
                if(![imgpath isEqualToString:@""])
                {
                    pDict[@"SubDeptImagePath"] = imgpath;
                }
                pDict[@"ItemCode"] = @(self.itemCode);
                
                if(addSubDeptModel.strDepartmentID.length >0){
                    pDict[@"DeptId"] = addSubDeptModel.strDepartmentID;
                }
                else{
                    pDict[@"DeptId"] = @"0";
                }
                
                
                [self.updateManager updateSubDepartmentWithDictionary:pDict];
                
                AddSubDepartmentVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Sub Department has been Updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else {
                
                [Appsee addEvent:kRIMSubDepartmentUpdateWebServiceResponse withProperties:@{kRIMSubDepartmentUpdateWebServiceResponseKey : @"Sub Department not Updated, try again."}];
                NSString *message = [response valueForKey:@"Data"];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

-(BOOL)isSubDepartmentNameIsValid{
    NSString *subDeptName = [addSubDeptModel.strSubDeptName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate * predicate = [self createPradicateFor:@"subDeptName" withValue:subDeptName];
    return [self isValidSubDepartmentForPredicate:predicate];
}

-(BOOL)isSubDepartmentCodeIsValid{
    NSString *subDeptCode = [addSubDeptModel.strSubDeptCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate * predicate = [self createPradicateFor:@"subDepCode" withValue:subDeptCode];
    return [self isValidSubDepartmentForPredicate:predicate];
}

-(NSPredicate *)createPradicateFor:(NSString *)strKey withValue:(NSString *)strValue {
    NSPredicate * predicate;
    if (self.updateSubDepartmentDictionary) {
        predicate  = [NSPredicate predicateWithFormat:@"%K == [cd]%@ && brnSubDeptID != %@",strKey,strValue,self.updateSubDepartmentDictionary[@"BrnSubDeptID"]];
    }
    else {
        predicate  = [NSPredicate predicateWithFormat:@"%K == [cd]%@",strKey,strValue];
    }
    return predicate;
}
-(BOOL)isValidSubDepartmentForPredicate:(NSPredicate *) predicate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubDepartment" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    if ([UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest] == 0) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}

//- (void)showAlertForUniqueSubDepartment {
//    
//    [self showSubDeptAlertView:@"Please enter Unique SubDepartment Name" forTextField:nil];
//}

//-(BOOL)isSubDepartmentNameAvailabelMultipleTimeInDb:(NSString *)subDeptName {
//    BOOL isMultiSubDepartment = FALSE;
//    NSArray *uniqueSubDepartments = [self fetchSubDepartmentsForSubDepartmentName:subDeptName];
//    if (uniqueSubDepartments !=nil && uniqueSubDepartments.count > 1) {
//        isMultiSubDepartment = TRUE;
//    }
//    return isMultiSubDepartment;
//}

//-(BOOL)isSubDepartmentNameUnique:(NSString *)subDeptName
//{
//    BOOL isUniqueSubDepartment = TRUE;
//    NSArray *uniqueSubDepartments = [self fetchSubDepartmentsForSubDepartmentName:subDeptName];
//    if (uniqueSubDepartments !=nil && uniqueSubDepartments.count > 0) {
//        isUniqueSubDepartment = FALSE;
//    }
//    return isUniqueSubDepartment;
//}

- (NSArray *)fetchSubDepartmentsForSubDepartmentName:(NSString *)subDeptName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubDepartment" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subDeptName == [cd]%@",subDeptName];
    fetchRequest.predicate = predicate;
    NSArray *uniqueSubDepartments = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return uniqueSubDepartments;
}

- (NSMutableDictionary *) getSubDeparmentDeleteProcessData
{
    NSMutableDictionary * subDeptDataDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary * addSubDeptDataDict = [[NSMutableDictionary alloc] init];
    
    if(!(self.updateSubDepartmentDictionary == nil))
    {
        StrBrnSubDeptID = [NSString stringWithFormat:@"%@",[self.updateSubDepartmentDictionary valueForKey:@"BrnSubDeptID"]];
        addSubDeptDataDict[@"BrnSubDeptID"] = StrBrnSubDeptID;
    }
    
    addSubDeptDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    
    addSubDeptDataDict[@"LocalDate"] = currentDateTime;

    subDeptDataDict[@"pSubDepartmentData"] = addSubDeptDataDict;
    return subDeptDataDict;
}



- (NSMutableDictionary *) getSubDeparmentProcessData
{
    NSMutableDictionary * subDeptDataDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary * addSubDeptDataDict = [[NSMutableDictionary alloc] init];
    
    if(!(self.updateSubDepartmentDictionary == nil))
    {
        StrBrnSubDeptID = [NSString stringWithFormat:@"%@",[self.updateSubDepartmentDictionary valueForKey:@"BrnSubDeptID"]];
        addSubDeptDataDict[@"BrnSubDeptID"] = StrBrnSubDeptID;
    }
    
    addSubDeptDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    addSubDeptDataDict[@"SubDeptName"] = addSubDeptModel.strSubDeptName;
    addSubDeptDataDict[@"SubDepCode"] = addSubDeptModel.strSubDeptCode;
    addSubDeptDataDict[@"Remarks"] = addSubDeptModel.strSubRemarks;
    if (addSubDeptModel.isNotDisplayInventory) {
        addSubDeptDataDict[@"IsNotDisplayInventory"] = @"1";
    } else {
        addSubDeptDataDict[@"IsNotDisplayInventory"] = @"0";
    }
    addSubDeptDataDict[@"ImagePath"] = @"";
    
    if(_isImageSet)
    {
        imageData = UIImageJPEGRepresentation(selectedImage, 0);
        if(imageData)
        {
            addSubDeptDataDict[@"ImagePath"] = [imageData base64EncodedStringWithOptions:0];
        }
        else
        {
            addSubDeptDataDict[@"ImagePath"] = @"";
        }
        addSubDeptDataDict[@"IsImageDeleted"] = @(isImageDeleted);
    }
    
    else
    {
        if(!(self.updateSubDepartmentDictionary == nil))
        {
            addSubDeptDataDict[@"ImagePath"] = @"NoChange";
        }
        else
        {
            addSubDeptDataDict[@"ImagePath"] = @"";
        }
        addSubDeptDataDict[@"IsImageDeleted"] = @(isImageDeleted);
    }
    
    if(addSubDeptModel.strDepartmentID.length >0){
        addSubDeptDataDict[@"DeptId"] = addSubDeptModel.strDepartmentID;
    }
    else{
        addSubDeptDataDict[@"DeptId"] = @"0";
    }
    
    
    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];

    addSubDeptDataDict[@"CreatedDate"] = currentDateTime;
    addSubDeptDataDict[@"CreatedBy"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    subDeptDataDict[@"pSubDepartmentData"] = addSubDeptDataDict;
    return subDeptDataDict;
}

- (NSMutableDictionary *)dictionaryToUpdateData
{
    NSMutableDictionary *dictSubDepartmentData = [[NSMutableDictionary alloc] init];
    if ([[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"BrnSubDeptID"]) {
        dictSubDepartmentData[@"BrnSubDeptID"] = [[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"BrnSubDeptID"];
    }
    dictSubDepartmentData[@"BranchId"] = [[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"BranchId"];
    dictSubDepartmentData[@"CreatedBy"] = [[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"CreatedBy"];
    dictSubDepartmentData[@"CreatedDate"] = [[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"CreatedDate"];
    dictSubDepartmentData[@"IsNotDisplayInventory"] = [[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"IsNotDisplayInventory"];
    if(_isImageSet)
    {
        
    }
    else
    {
        if(self.updateSubDepartmentDictionary != nil)
        {
            imagePath = (self.updateSubDepartmentDictionary)[@"SubDeptImagePath"];
        }
        else
        {
            imagePath = @"";
        }
    }
    dictSubDepartmentData[@"SubDeptImagePath"] = imagePath;
    
    dictSubDepartmentData[@"Remarks"] = [[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"Remarks"];
    dictSubDepartmentData[@"SubDepCode"] = [[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"SubDepCode"];
    dictSubDepartmentData[@"SubDeptName"] = [[self.subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"SubDeptName"];
    return dictSubDepartmentData;
}

-(IBAction)btnDeleteSubDepartment:(id)sender
{
    [Appsee addEvent:kRIMSubDepartmentDelete];
    if (self.updateSubDepartmentDictionary != nil) {
          [self.rmsDbController playButtonSound];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"BrnSubDeptID == %d",[[self.updateSubDepartmentDictionary valueForKey:@"BrnSubDeptID"] integerValue]];
        NSArray *subdeptItem = [_arraysubDeptItems filteredArrayUsingPredicate:predicate];
        
        if(subdeptItem.count == 1 && _arraysubDeptItems.count == 1){
            
            AddSubDepartmentVC * __weak myWeakReference = self;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [myWeakReference deleteSubDepartment];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this Sub Department?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
            
        }
        else if(_arraysubDeptItems.count == 0){
            
            AddSubDepartmentVC * __weak myWeakReference = self;
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                [myWeakReference deleteSubDepartment];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this Sub Department?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
        }
        else if(_arraysubDeptItems.count > 1){
            
             NSString *strMsg = [NSString stringWithFormat:@"%@ cannot be deleted as it is assigned to %d items. Please check the ‘Items’ tab to check the list of items. Remove this sub department from all those items first. Then try deleting this sub department.",addSubDeptModel.strSubDeptName,(int)self.arraysubDeptItems.count-1];
            
            
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {};
            [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:strMsg buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            
        }
    }
}

- (void)deleteSubDepartment
{
    [self.rmsDbController playButtonSound];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    
    _subDeapartmentInsertDict = [self getSubDeparmentProcessData];
    
    NSDictionary *deleteSubDeptDict = @{kRIMSubDepartmentDeleteWebServiceCallKey : [[_subDeapartmentInsertDict valueForKey:@"pSubDepartmentData"] valueForKey:@"BrnSubDeptID"]};
    [Appsee addEvent:kRIMSubDepartmentDeleteWebServiceCall withProperties:deleteSubDeptDict];

    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doDeleteProcessForSubDepartmentResponse:response error:error];
        });
    };
    
    self.subDepartmentDelete = [self.subDepartmentDelete initWithRequest:KURL actionName:WSM_DELETE_SUB_DEPARTMENT params:_subDeapartmentInsertDict completionHandler:completionHandler];
}

- (void)doDeleteProcessForSubDepartmentResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response  valueForKey:@"IsError"] intValue] == 0) {

                [Appsee addEvent:kRIMSubDepartmentDeleteWebServiceResponse withProperties:@{kRIMSubDepartmentDeleteWebServiceResponseKey :@"Sub Department has been Deleted successfully" }];
                [self.updateManager deleteSubDepartmentWithSubDepartmentId:@(StrBrnSubDeptID.integerValue)];
                AddSubDepartmentVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Sub Department has been Deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
            else if ([[response valueForKey:@"IsError"] intValue] == -2) {
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
            else {

                [Appsee addEvent:kRIMSubDepartmentDeleteWebServiceResponse withProperties:@{kRIMSubDepartmentDeleteWebServiceResponseKey :@"Sub Department not Deleted, try again." }];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Sub Department not Deleted, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}


#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tblAddSubDepartment){
        return 5;
    }
    else if(tableView==_tblItems) // Items
    {
        return _arraysubDeptItems.count;
    }
    else if(tableView==_tblDepartment) // Items
    {
        return _arrayDepartment.count;
    }

    else
        return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tblAddSubDepartment)
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:0];
    else
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == _tblAddSubDepartment)
        return RIMHeaderHeight();
    else
        return 0;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == _tblAddSubDepartment)
    {
        return [tableView defaultTableHeaderView:@"DETAILS"];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
    
    if(tableView == _tblAddSubDepartment)
    {
        switch (indexPath.row) {
            case 0:
                cell = [self configureSubDepartmentName:tableView cellForRowAtIndexPath:indexPath];
                break;
            case 1:
                cell = [self configureSubDepartmentCode:tableView cellForRowAtIndexPath:indexPath];
                break;
            case 2:
                cell = [self configureSubDepartmentRemark:tableView cellForRowAtIndexPath:indexPath];
                break;
            case 3:
                cell = [self configureDoNotDisplayInInventory:tableView cellForRowAtIndexPath:indexPath];
                break;
            case 4:
                cell = [self configureDepartment:tableView cellForRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
    }
    else if(tableView == _tblItems)
    {
        cell = [self configureItemList:tableView cellForRowAtIndexPath:indexPath];
        
    }
    else if(tableView == _tblDepartment)
    {
        cell = [self configureDepartmentList:tableView cellForRowAtIndexPath:indexPath];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Department Info Tab -

- (UITableViewCell *)configureSubDepartmentName:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellTextField" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Sub Department Name";
    cell.txtInput.text = addSubDeptModel.strSubDeptName;
    cell.txtInput.placeholder = @"Enter Sub Department Name";
    cell.txtInput.tag = SubDepartmentInfoCellName;
    cell.txtInput.delegate = self;
    cell.rowType = DepartmentInfoTabNameRow;
    return cell;
}
- (UITableViewCell *)configureSubDepartmentCode:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellTextField" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Sub Department Code";
    cell.txtInput.text = addSubDeptModel.strSubDeptCode;
    cell.txtInput.placeholder = @"Enter Sub Department Code";
    cell.txtInput.tag = SubDepartmentInfoCellCode;
    cell.txtInput.delegate = self;
    return cell;
}
- (UITableViewCell *)configureSubDepartmentRemark:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellTextField" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Remarks";
    cell.txtInput.text = addSubDeptModel.strSubRemarks;
    cell.txtInput.placeholder = @"Enter Remarks";
    cell.txtInput.tag = SubDepartmentInfoCellRemark;
    cell.txtInput.delegate = self;
    return cell;
}
- (UITableViewCell *)configureDoNotDisplayInInventory:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSwitch" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Do Not Display In Inventory Item";
    cell.swiOnOff.on = addSubDeptModel.isNotDisplayInventory;
    [cell.swiOnOff addTarget:self action:@selector(btnDoNotDisplayInInventoryForSubDepClicked:) forControlEvents:UIControlEventValueChanged];
    return cell;
}
- (IBAction)btnDoNotDisplayInInventoryForSubDepClicked:(UISwitch *)sender
{
    addSubDeptModel.isNotDisplayInventory = sender.on;
}
- (UITableViewCell *)configureDepartment:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellDepartment" forIndexPath:indexPath];
    
    cell.lblTitle.text = @"Department";
    
    [cell.btnDropDown setTitle:addSubDeptModel.strDepartment forState:UIControlStateNormal];
    [cell.btnDropDown addTarget:self action:@selector(btnItemDeptClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
#pragma mark - ItemTableView Cell -

- (ItemListCell *)configureItemList:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ItemListCell *itemListCell = (ItemListCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemListCell"];
    itemListCell.backgroundColor = [UIColor clearColor];
    itemListCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dictIteminfo = _arraysubDeptItems[indexPath.row];
    itemListCell.lblBarcode.text = [dictIteminfo valueForKey:@"Barcode"];
    itemListCell.lblItemName.text = [dictIteminfo valueForKey:@"ItemName"];
    return itemListCell;
}

#pragma mark - DepartmentTableView Cell -

- (ItemListCell *)configureDepartmentList:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ItemListCell *itemListCell = (ItemListCell *)[tableView dequeueReusableCellWithIdentifier:@"DepartmentListCell"];
    itemListCell.backgroundColor = [UIColor clearColor];
    itemListCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dictIteminfo = _arrayDepartment[indexPath.row];
    itemListCell.lblBarcode.text = [dictIteminfo valueForKey:@"deptCode"];
    itemListCell.lblItemName.text = [dictIteminfo valueForKey:@"deptName"];
    return itemListCell;
}

-(void)didselectDepartment :(NSMutableArray *)selectedDepartment{
    
    self.arrSelectedDepartment = selectedDepartment;
    addSubDeptModel.strDepartment = [selectedDepartment.firstObject valueForKey:@"DepartmentName"];
    addSubDeptModel.strDepartmentID = [NSString stringWithFormat:@"%@",[selectedDepartment.firstObject valueForKey:@"DeptId"]];
    [self.tblAddSubDepartment reloadData];
}

- (IBAction)btnItemDeptClicked:(UIButton *)sender
{
    [Appsee addEvent:kPOGenerateOrderDepartmentSelection];
    
    DepartmentMultiple *objDeptPop = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"DepartmentMultiple_sid"];
    objDeptPop.addDepartmentMultipleDelegate = self;
    objDeptPop.checkedDepartment = [self.arrSelectedDepartment mutableCopy];
    objDeptPop.isMultipleAllow = NO;
    objDeptPop.strItemcode=@"1";
    objDeptPop.view.frame = CGRectMake(0,0,740 ,self.view.frame.size.height);
    [self.view addSubview:objDeptPop.view];
    [self addChildViewController:objDeptPop];
}

#pragma mark - Textfield delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case SubDepartmentInfoCellName:
            addSubDeptModel.strSubDeptName = textField.text;
            break;
        case SubDepartmentInfoCellCode:
            addSubDeptModel.strSubDeptCode = textField.text;
            break;
        case SubDepartmentInfoCellRemark:
            addSubDeptModel.strSubRemarks= textField.text;
            break;
        default:
            break;
    }
    [self.tblAddSubDepartment reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField.tag == SubDepartmentInfoCellName)
    {
        addSubDeptModel.strSubDeptName = @"";
    }
    else if(textField.tag == SubDepartmentInfoCellCode)
    {
        addSubDeptModel.strSubDeptCode = @"";
    }
    else if(textField.tag == SubDepartmentInfoCellRemark)
    {
        addSubDeptModel.strSubRemarks = @"";
    }
    [self.tblAddSubDepartment reloadData];
    return YES;
}


#pragma mark - Drop-Down Events

- (IBAction)btnDepartmentDropDownClicked:(id)sender
{
    NSString *loadNibName;
    if (IsPhone())
    {
        loadNibName = @"DepartmentPopover";
    }
    else
    {
        loadNibName = @"DepartmentPopover_iPad";
    }
    multipleDepartmentSelectionVC = [[MultipleDepartmentSelectionVC alloc]initWithNibName:loadNibName bundle:nil];
    multipleDepartmentSelectionVC.objAddSubDepartment = self;
    multipleDepartmentSelectionVC.arrDeptSelected = self.arrDepartment;
    multipleDepartmentSelectionVC.view.frame = CGRectMake(301,64 ,multipleDepartmentSelectionVC.view.frame.size.width ,705);
    [self.view addSubview:multipleDepartmentSelectionVC.view];
}

#pragma mark - AlertView Events

-(void)showSubDeptAlertView:(NSString *)alertMessage forTextField:(UITextField *)textField
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [textField becomeFirstResponder];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:alertMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

#pragma mark - Image Capture

-(void)selectImageCaptureForSubDepartment:(UIButton *)sender
{
    
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
    _isImageSet=TRUE;
    isImageDeleted = FALSE;
    
    NSMutableDictionary *departmentData = [NSMutableDictionary dictionary];
    [departmentData setValue:image forKey:@"SubDeptImagePath"];
    if ([departmentData valueForKey:@"SubDeptImagePath"] != nil) {
        (self.updateSubDepartmentDictionary)[@"SubDeptImagePath"] = [departmentData valueForKey:@"SubDeptImagePath"];
    }
    imagePath = [departmentData valueForKey:@"SubDeptImagePath"];
    [self.objSubDepartmentInfo didUpdateSubDepatmentInfo:departmentData];
    selectedImage = image;
    
    if (IsPad()) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -
#pragma mark UIImagePickerController Delegate Method

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
    itemImageSelectionVC.strSearchText = addSubDeptModel.strSubDeptName;
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
    AddSubDepartmentVC * __weak myWeakReference = self;
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        [Appsee addEvent:kRIMSubDepartmentRemoveImageCancel];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        [Appsee addEvent:kRIMSubDepartmentRemoveImageDone];
        selectedImage = nil;
        NSMutableDictionary *departmentData = [NSMutableDictionary dictionary];
        [departmentData setValue:@"" forKey:@"SubDeptImagePath"];
        (myWeakReference.updateSubDepartmentDictionary)[@"SubDeptImagePath"] = [departmentData valueForKey:@"SubDeptImagePath"];
        imagePath = [departmentData valueForKey:@"SubDeptImagePath"];
        _isImageSet = TRUE;
        isImageDeleted = TRUE;
        [myWeakReference.objSubDepartmentInfo didUpdateSubDepatmentInfo:departmentData];
    };
    
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to remove subdepartment image ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    selectedImage = info[UIImagePickerControllerOriginalImage];
    NSMutableDictionary *departmentData = [NSMutableDictionary dictionary];
    [departmentData setValue:selectedImage forKey:@"SubDeptImagePath"];
    if ([departmentData valueForKey:@"SubDeptImagePath"] != nil) {
        (self.updateSubDepartmentDictionary)[@"SubDeptImagePath"] = [departmentData valueForKey:@"SubDeptImagePath"];
    }
    imagePath = [departmentData valueForKey:@"SubDeptImagePath"];
    _isImageSet = TRUE;
    isImageDeleted = FALSE;
    [self.objSubDepartmentInfo didUpdateSubDepatmentInfo:departmentData];
    // [objDepartmentInfo didUpdateDepatmentInfo:departmentData];
    
    if (IsPad())
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    _isImageSet=TRUE;
    pickerCamera=nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
