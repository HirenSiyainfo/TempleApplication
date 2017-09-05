//
//  AddDepartmentVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 08/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AddGroupItemModifierVC.h"
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

@interface AddGroupItemModifierVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    
    UITextField *txtItemModifierName;
    BOOL isDeleted;
    BOOL isCalcInPOS;
    NSString *brnModifierItemId;
}
@property (nonatomic, weak) RmsActivityIndicator * activityIndicator;

@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, strong) DisplayItemInfoSideVC * objItemInfo;

@property (nonatomic, weak) IBOutlet UIView * viewsideinfobg;
@property (nonatomic, weak) IBOutlet UIButton * btnDeleteItemModifier;
@property (nonatomic, weak) IBOutlet UITableView * tblItemModifier;

@property (nonatomic, strong) NSMutableDictionary *itemModifierInsertDict;

@property (nonatomic, strong) RapidWebServiceConnection * itemModifierInsert;
@property (nonatomic, strong) RapidWebServiceConnection * itemModifierUpdate;
@property (nonatomic, strong) RapidWebServiceConnection * itemModifierDelete;

@end

@implementation AddGroupItemModifierVC


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

    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.itemModifierInsert = [[RapidWebServiceConnection alloc]init];
    self.itemModifierUpdate = [[RapidWebServiceConnection alloc]init];
    self.itemModifierDelete = [[RapidWebServiceConnection alloc]init];

    [self allocAllFields];
    [self showSideItemInfo:nil];
    [self updateViewWithUpdateDetail:self.updateItemModifierDictioanry];

    if(self.updateItemModifierDictioanry != nil)
    {
        self.btnDeleteItemModifier.enabled = YES;
    }
    else
    {
        self.btnDeleteItemModifier.enabled = NO;
    }

        // Do any additional setup after loading the view from its nib.
}


-(void)updateViewWithUpdateDetail:(NSMutableDictionary *)itemModifierDictioanry
{
    if(itemModifierDictioanry != nil)
    {
        txtItemModifierName.text = [itemModifierDictioanry valueForKey:@"ModifireItem"];
        isCalcInPOS = [[itemModifierDictioanry valueForKey:@"CalcInPOS"] boolValue];
        isDeleted = [[itemModifierDictioanry valueForKey:@"IsDeleted"] boolValue];
    }
}

#pragma mark - Alloc All Fields

-(void) allocAllFields
{
    if (IsPhone())
    {
        txtItemModifierName = [[UITextField alloc] initWithFrame:CGRectMake(iPhoneTextboxXpos, iPhoneTextboxYpos, iPhoneTextboxWidth, iPhoneTextboxHeight)];
    }
    else
    {
        txtItemModifierName = [[UITextField alloc] initWithFrame:CGRectMake(iPadTextboxXpos, iPadTextboxYpos, iPadTextboxWidth, iPadTextboxHeight)];
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
    self.objItemInfo.view.userInteractionEnabled = NO;
    [_viewsideinfobg addSubview:self.objItemInfo.view];
}

-(IBAction)btnCloseItemModifierClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnSaveItemModifierClicked:(id)sender
{
    if(txtItemModifierName.text.length == 0)
    {
        [self showDeptAlertView:@"Please enter Item Modifier Name"];
        return;
    }

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];

    self.itemModifierInsertDict = [self getItemModifierProcessData];



    if (self.updateItemModifierDictioanry == nil) {

        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doInsertProcessForItemModifierResponse:response error:error];
            });
        };
        
        self.itemModifierInsert = [self.itemModifierInsert initWithRequest:KURL actionName:WSM_INSERT_MODIFIER_LIST params:self.itemModifierInsertDict completionHandler:completionHandler];
    }
    else {
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doUpdateProcessForDepartmentResponse:response error:error];
            });
        };
        self.itemModifierUpdate = [self.itemModifierUpdate initWithRequest:KURL actionName:WSM_UPDATE_MODIFIER_LIST params:self.itemModifierInsertDict completionHandler:completionHandler];
    }
}

- (void) doInsertProcessForItemModifierResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                AddGroupItemModifierVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Item has been added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Item not added, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

- (void) doUpdateProcessForDepartmentResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                AddGroupItemModifierVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Item has been Updated successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Item not Updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

- (NSMutableDictionary *) getItemModifierProcessData
{
    NSMutableDictionary *itemModifierDict = [[NSMutableDictionary alloc] init];

    NSMutableDictionary *itemModifierParam = [[NSMutableDictionary alloc] init];
    
    if (txtItemModifierName.text.length > 0) {
        itemModifierParam[@"ModifireListName"] = txtItemModifierName.text;
    }
    else
    {
        itemModifierParam[@"ModifireListName"] = @"";
    }

    itemModifierParam[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    itemModifierParam[@"CreatedBy"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];

    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];

    itemModifierParam[@"CreatedDate"] = currentDateTime;

    if (isDeleted) {
        itemModifierParam[@"IsDeleted"] = @"1";
    }
    else
    {
        itemModifierParam[@"IsDeleted"] = @"0";
    }
//    if (isCalcInPOS) {
//        [itemModifierParam setObject:@"1" forKey:@"CalcInPOS"];
//    }
//    else
//    {
//        [itemModifierParam setObject:@"0" forKey:@"CalcInPOS"];
//    }

    itemModifierParam[@"Delete"] = @"";
    itemModifierParam[@"Edit"] = @"";

    if(!(self.updateItemModifierDictioanry == nil))
    {
        brnModifierItemId = [NSString stringWithFormat:@"%@",[self.updateItemModifierDictioanry valueForKey:@"BrnModifierItemId"]];
        itemModifierParam[@"BrnModifierItemId"] = brnModifierItemId;

    }

    itemModifierDict[@"pModifireListData"] = itemModifierParam;
	return itemModifierDict;
}

-(IBAction)btnDeleteItemModifier:(id)sender
{
    if (self.updateItemModifierDictioanry != nil) {
        [self.rmsDbController playButtonSound];
        AddGroupItemModifierVC * __weak myWeakReference = self;
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            [myWeakReference deleteItemModifier];
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Are you sure you want to delete this Item Modifier?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

- (void)deleteItemModifier
{
    [self.rmsDbController playButtonSound];

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];

    self.itemModifierInsertDict = [self getItemModifierProcessData];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doDeleteProcessForItemModifierResponse:response error:error];
        });
    };
    
    self.itemModifierDelete = [self.itemModifierDelete initWithRequest:KURL actionName:WSM_DELETE_MODIFIER_LIST params:self.itemModifierInsertDict completionHandler:completionHandler];
}

- (void) doDeleteProcessForItemModifierResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];

    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                AddGroupItemModifierVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference dismissViewControllerAnimated:YES completion:nil];
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Item has been Deleted successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Modifier Item not Deleted, try again." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}


#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblItemModifier){
        return 1;
    }
    else
        return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblItemModifier)
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

    if(tableView == self.tblItemModifier)
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
                lblName.text = @"Modifier Item Name";
                [self setLabelProperty:lblName fontSize:14];
                lblName.textAlignment=NSTextAlignmentLeft;
                [cellInfo addSubview:lblName];

                txtItemModifierName.textAlignment = NSTextAlignmentLeft;
                [self setTxtBoxProperty:txtItemModifierName];
                [cellInfo addSubview:txtItemModifierName];
                
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

@end
