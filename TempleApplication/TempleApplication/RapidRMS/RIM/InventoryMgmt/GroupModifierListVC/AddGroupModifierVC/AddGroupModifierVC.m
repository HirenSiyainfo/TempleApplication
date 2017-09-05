//
//  AddDepartmentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 08/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AddGroupModifierVC.h"
#import "RmsDbController.h"
#import "DisplayItemInfoSideVC.h"


#define iPhoneTextboxXpos 20
#define iPhoneTextboxYpos 7
#define iPhoneTextboxWidth 88
#define iPhoneTextboxHeight 30

#define iPhoneLabelXpos 205
#define iPhoneLabelYpos 7
#define iPhoneLabelWidth 88
#define iPhoneLabelHeight 30


#define iPadLabelXpos 265
#define iPadLabelYpos 7
#define iPadLabelWidth 150
#define iPadLabelHeight 30

#define iPadTextboxXpos 185
#define iPadTextboxYpos 7
#define iPadTextboxWidth 490
#define iPadTextboxHeight 30


@interface AddGroupModifierVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,DisplayItemInfoSideVCDeledate> {
    
    UITextField *txtGroupModifierName;
    BOOL isDeleted;
    NSString *brnModifierId;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, weak) IBOutlet UIButton *btnDeleteGroupModifier;
@property (nonatomic, weak) IBOutlet UITableView *tblGroupModifier;
@property (nonatomic, weak) IBOutlet UIView * viewsideinfobg;


@property (nonatomic, strong) NSMutableDictionary *groupModifierInsertDict;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) DisplayItemInfoSideVC *objItemInfo;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, strong) RapidWebServiceConnection * itemModifierInsert;
@property (nonatomic, strong) RapidWebServiceConnection * itemModifierUpdate;
@property (nonatomic, strong) RapidWebServiceConnection * itemModifierDelete;


@end

@implementation AddGroupModifierVC

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
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.itemModifierInsert = [[RapidWebServiceConnection alloc]init];
    self.itemModifierUpdate = [[RapidWebServiceConnection alloc]init];
    self.itemModifierDelete = [[RapidWebServiceConnection alloc]init];

    [self allocAllFields];
    [self showSideItemInfo:nil];
    [self updateViewWithUpdateDetail:self.updateGroupModifierDictioanry];

    if(self.updateGroupModifierDictioanry != nil)
    {
        self.btnDeleteGroupModifier.enabled = YES;
    }
    else
    {
        self.btnDeleteGroupModifier.enabled = NO;
    }

    // Do any additional setup after loading the view from its nib.
}


-(void)updateViewWithUpdateDetail:(NSMutableDictionary *)groupModifierDictioanry
{
    if(groupModifierDictioanry != nil)
    {
        txtGroupModifierName.text = [groupModifierDictioanry valueForKey:@"Name"];
        isDeleted = [[groupModifierDictioanry valueForKey:@"IsDeleted"] boolValue];
    }

}

#pragma mark - Alloc All Fields

-(void) allocAllFields
{
    if (IsPhone())
    {
        txtGroupModifierName = [[UITextField alloc] initWithFrame:CGRectMake(iPhoneTextboxXpos, iPhoneTextboxYpos, iPhoneTextboxWidth, iPhoneTextboxHeight)];
    }
    else{

        txtGroupModifierName = [[UITextField alloc] initWithFrame:CGRectMake(iPadTextboxXpos, iPadTextboxYpos, iPadTextboxWidth, iPadTextboxHeight)];
    }
}

#pragma mark - Set Property To Lable & Textfield

-(void)setTxtBoxProperty:(UITextField *)sender
{
    sender.delegate = self;
    //sender.borderStyle = UITextBorderStyleLine;
    sender.textColor = [UIColor colorWithRed:82.0/256.0 green:82.0/256.0 blue:82.0/256.0 alpha:1.0];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:17];
    sender.backgroundColor = [UIColor clearColor];
    sender.tintColor = [UIColor blackColor];
    sender.clearButtonMode = UITextFieldViewModeAlways;
}

-(void)setLabelProperty:(UILabel *)sender fontSize:(int)psize;
{
    sender.textColor = [UIColor blackColor];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:psize];
    sender.backgroundColor = [UIColor clearColor];
    sender.tintColor = [UIColor blackColor];
    sender.textAlignment=NSTextAlignmentRight;
}

#pragma mark - Show Info In Side Menu

-(void)showSideItemInfo :(NSMutableDictionary *)itemDictionary
{
    [[self.view viewWithTag:252525] removeFromSuperview ];
    self.objItemInfo=(DisplayItemInfoSideVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard()
                                                                         bundle:NULL] instantiateViewControllerWithIdentifier:@"DisplayItemInfoSideVC_sid"];
    self.objItemInfo.itemInfoDictionary = [itemDictionary mutableCopy];
    self.objItemInfo.view.frame = _viewsideinfobg.bounds;
    self.objItemInfo.view.tag = 252525;
//    objItemInfo.objAddItem = (ItemInfoEditVC *)self;
    self.objItemInfo.displayItemInfoSideVCDeledate = self;
    self.objItemInfo.view.userInteractionEnabled = NO;
    [_viewsideinfobg addSubview:self.objItemInfo.view];
}

-(IBAction)btnCloseGroupModifierClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnSaveGroupModifierClicked:(id)sender
{
    if(txtGroupModifierName.text.length == 0)
    {
        [self showDeptAlertView:@"Please enter Group Modifier name"];
        return;
    }

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];

    self.groupModifierInsertDict = [self getGroupModifierProcessData];

    if (self.updateGroupModifierDictioanry == nil) {

        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doInsertProcessForGroupModifierResponse:response error:error];
            });
        };
        
        self.itemModifierInsert = [self.itemModifierInsert initWithRequest:KURL actionName:WSM_INSERT_MODIFIER_GROUP params:self.groupModifierInsertDict completionHandler:completionHandler];
    }
    else {
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doUpdateProcessForGroupModifierResponse:response error:error];
            });
        };
        
        self.itemModifierUpdate = [self.itemModifierUpdate initWithRequest:KURL actionName:WSM_UPDATE_MODIFIER_GROUP params:self.groupModifierInsertDict completionHandler:completionHandler];
    }
    
}

- (void) doInsertProcessForGroupModifierResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                AddGroupModifierVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Group has been added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Group not added, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

- (void) doUpdateProcessForGroupModifierResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                AddGroupModifierVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Group has been Updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Group not Updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

- (NSMutableDictionary *) getGroupModifierProcessData
{
    NSMutableDictionary * groupModifierDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * groupModifierParam = [[NSMutableDictionary alloc] init];
	groupModifierParam[@"ModifireName"] = txtGroupModifierName.text;

    if (isDeleted) {
        groupModifierParam[@"IsDeleted"] = @"1";
    }
    else
    {
        groupModifierParam[@"IsDeleted"] = @"0";
    }

	groupModifierParam[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];

	groupModifierParam[@"CreatedBy"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];

    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];

	groupModifierParam[@"CreatedDateTime"] = currentDateTime;

    groupModifierParam[@"Delete"] = @"";
	groupModifierParam[@"Edit"] = @"";

    if(!(self.updateGroupModifierDictioanry == nil))
    {
        brnModifierId = [NSString stringWithFormat:@"%@",[self.updateGroupModifierDictioanry valueForKey:@"BrnModifierId"]];
        groupModifierParam[@"BrnModifierId"] = brnModifierId;
    }

    groupModifierDict[@"objModifier"] = groupModifierParam;
    
	return groupModifierDict;
}

-(IBAction)btnDeleteGroupModifier:(id)sender
{
    if (self.updateGroupModifierDictioanry != nil) {
        [self.rmsDbController playButtonSound];
        AddGroupModifierVC * __weak myWeakReference = self;
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference deleteGroupModifier];
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this Group Modifier?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (void)deleteGroupModifier
{
    [self.rmsDbController playButtonSound];

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];

    self.groupModifierInsertDict = [self getGroupModifierProcessData];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doDeleteProcessForGroupModifierResponse:response error:error];
        });
    };
    
    self.itemModifierDelete = [self.itemModifierDelete initWithRequest:KURL actionName:WSM_DELETE_MODIFIER_GROUP params:self.groupModifierInsertDict completionHandler:completionHandler];
}

- (void) doDeleteProcessForGroupModifierResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                AddGroupModifierVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Group has been Deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Group not Deleted, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }

        }
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblGroupModifier){
        return 1;
    }

    else
        return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblGroupModifier)
        return 1;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.backgroundColor = [UIColor clearColor];

    if(tableView == self.tblGroupModifier)
    {
        UITableViewCell *cellInfo = [[UITableViewCell alloc]init];

        if(indexPath.section == 0){

            if(indexPath.row == 0){

                UIImageView* img;
                if (IsPhone())
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                    img.frame = CGRectMake(0, 0, 320, 44);
                    cellInfo.backgroundView = img;

                }
                else
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg.png"]];
                    [cellInfo addSubview:img];
                }

                UILabel *lblName = [[UILabel alloc] init];
                if (IsPhone())
                {
                    lblName.frame=CGRectMake(20, 7, 88, 30);
                }
                else{
                    lblName.frame=CGRectMake(20, 7, 150, 30);
                }
                lblName.text = @"Modifier Group Name";
                [self setLabelProperty:lblName fontSize:14];
                lblName.textAlignment=NSTextAlignmentLeft;
                [cellInfo addSubview:lblName];

                txtGroupModifierName.textAlignment = NSTextAlignmentLeft;
                [self setTxtBoxProperty:txtGroupModifierName];
                [cellInfo addSubview:txtGroupModifierName];
                
            }
        }
        cell = cellInfo;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark - Textfield delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Show Dept AlertView

-(void)showDeptAlertView:(NSString *)alertMessage
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:alertMessage buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)willChangeItemSelectedImage:(UIButton *)sender{
    
}
@end
