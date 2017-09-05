//
//  CompanyRepresentativeListVC.m
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddVenderModel.h"
#import "AddVenderVC.h"
#import "ItemInfoDisplayCell.h"
#import "ItemInfoTagCell.h"
#import "MPTagList.h"
#import "RapidFilterSelectedListCell.h"
#import "RmsDbController.h"
#import "StateSelectionVC.h"
#import "UITableView+AddBorder.h"
#import "UpdateManager.h"


@interface AddVenderVC () <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,MPTagListDelegate,StateSelectionDelegate,UpdateDelegate>
{
    IntercomHandler *intercomHandler;
    AddVenderModel * addVendorModel;
}
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) UpdateManager * updateManager;
@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, weak) RmsActivityIndicator * activityIndicator;

@property (nonatomic, weak) IBOutlet UITableView * addVenderTableView;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, strong) NSMutableArray * phoneNoArray;
@property (nonatomic, strong) NSMutableArray * venderArray;

@property (nonatomic, strong) RapidWebServiceConnection * insertSupplierCompanyWC;

@end

@implementation AddVenderVC
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    self.insertSupplierCompanyWC = [[RapidWebServiceConnection alloc] init];
    
    
    addVendorModel = [[AddVenderModel alloc] init];
    
    self.phoneNoArray = [[NSMutableArray alloc] init];
    [self setListOfCell];
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)setListOfCell{
    if (self.phoneNoArray.count > 0) {
        self.venderArray = [[NSMutableArray alloc] initWithObjects:@(AddVenderCellName),@(AddVenderCellAdd1),@(AddVenderCellAdd2),@(AddVenderCellCity),@(AddVenderCellState),@(AddVenderCellPin),@(AddVenderCellZone),@(AddVenderCellPhone),@(AddVenderCellPhoneList),@(AddVenderCellEmail), nil];
    }
    else{
        self.venderArray = [[NSMutableArray alloc] initWithObjects:@(AddVenderCellName),@(AddVenderCellAdd1),@(AddVenderCellAdd2),@(AddVenderCellCity),@(AddVenderCellState),@(AddVenderCellPin),@(AddVenderCellZone),@(AddVenderCellPhone),@(AddVenderCellEmail), nil];
    }
}

#pragma mark - MPTagListDelegate -

- (void)selectedTag:(NSString *)tagName withTabView:(id) tagView
{
    [self.phoneNoArray removeObjectAtIndex:((MPTagView *)tagView).tag];
    [self setListOfCell];
    [self.addVenderTableView reloadData];
}

#pragma mark - UITextField Delegate -

- (void)addPhoneNumber {
    [self.view endEditing:YES];
    if(addVendorModel.strVanderPhone.length > 0) {
        
        [self.phoneNoArray addObject:[NSString stringWithFormat:@"%@",addVendorModel.strVanderPhone]];
        NSLog(@"%@",addVendorModel.strVanderPhone);
        addVendorModel.strVanderPhone = @"";
        
        [self setListOfCell];
        [self.addVenderTableView reloadData];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    AddVenderCell rowType ;
    
    if (!(self.phoneNoArray.count > 0) && (textField.tag == AddVenderCellEmail)){
        rowType = AddVenderCellEmail;
    }
    else{
        rowType = [self.venderArray[textField.tag] integerValue];
    }
    switch (rowType) {
            
        case AddVenderCellName: {
            addVendorModel.strVanderName = textField.text;
            break;
        }
        case AddVenderCellAdd1:{
            addVendorModel.strVanderAdd1 = textField.text;
            break;
        }
        case AddVenderCellAdd2:{
            addVendorModel.strVanderAdd2 = textField.text;
            break;
        }
        case AddVenderCellCity:{
            addVendorModel.strVanderCity = textField.text;
            break;
        }
        case AddVenderCellState:{
            addVendorModel.strVanderState = textField.text;
            break;
        }
        case AddVenderCellPin:{
            addVendorModel.strVanderPin = textField.text;
            break;
        }
        case AddVenderCellZone:{
            addVendorModel.strVanderZone = textField.text;
            break;
        }
        case AddVenderCellPhone:{
            addVendorModel.strVanderPhone = textField.text;
            [self addPhoneNumber];
            break;
        }
        case AddVenderCellPhoneList:{
            break;
        }
        case AddVenderCellEmail:{
            addVendorModel.strVanderEmail = textField.text;
            break;
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark TableView Delegate & Data Source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat headerHeight = 55.0;
    
    AddVenderCell rowType = [self.venderArray[indexPath.row] integerValue];
    switch (rowType)
    {
        case AddVenderCellPhoneList:
        {
            if (self.phoneNoArray.count > 0) {
                RapidFilterSelectedListCell *cell = (RapidFilterSelectedListCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneNumberListcell"];
                
                [cell.itemList setAutomaticResize:YES];
                [cell.itemList setTags:self.phoneNoArray];
                
                headerHeight = cell.itemList.frame.size.height + 10;
            }
        }
            break;
            
        default:
            break;
    }
    return headerHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor= [UIColor clearColor];
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg.png"]];
    [cell addSubview:img];
    
    AddVenderCell rowType = [self.venderArray[indexPath.row] integerValue];
    switch (rowType)
    {
        case AddVenderCellName: {
            cell = [self configurVandername:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellAdd1:{
            cell = [self configurVanderAdd1:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellAdd2:{
            cell = [self configurVanderAdd2:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellCity:{
            cell = [self configurVanderCity:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellState:{
            cell = [self configurStateCell:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellPin:{
            cell = [self configurVanderPin:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellZone:{
            cell = [self configurVanderZone:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellPhone:{
            cell = [self configurMobileCell:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellPhoneList:{
            cell = [self configurPhoneNumberListCell:tableView atIndex:indexPath];
            break;
        }
        case AddVenderCellEmail:{
            cell = [self configurVanderEmail:tableView atIndex:indexPath];
            break;
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - configurCells  -

-(UITableViewCell *)configurVandername:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Vendor(Company) Name";
    cell.txtInputValue.text = addVendorModel.strVanderName;
    cell.txtInputValue.tag = AddVenderCellName;
    cell.txtInputValue.placeholder = @"Enter Vendor(Company) Name";
    return cell;
}

-(UITableViewCell *)configurVanderAdd1:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Address";
    cell.txtInputValue.text = addVendorModel.strVanderAdd1;
    cell.txtInputValue.tag = AddVenderCellAdd1;
    cell.txtInputValue.placeholder = @"Enter Address Line 1";
    return cell;
}

-(UITableViewCell *)configurVanderAdd2:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"";
    cell.txtInputValue.text = addVendorModel.strVanderAdd2;
    cell.txtInputValue.tag = AddVenderCellAdd2;
    cell.txtInputValue.placeholder = @"Enter Address Line 2";
    return cell;
}

-(UITableViewCell *)configurVanderCity:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"City";
    cell.txtInputValue.text = addVendorModel.strVanderCity;
    cell.txtInputValue.tag = AddVenderCellCity;
    cell.txtInputValue.placeholder = @"Enter City";

    return cell;
}

-(UITableViewCell *)configurStateCell:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    NSString * identifier=@"ItemInfoTagCell";
    ItemInfoTagCell *cell=(ItemInfoTagCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.lblCellName.text = @"State";
    cell.txtTagName.placeholder = @"Select State";
    cell.txtTagName.text = addVendorModel.strVanderState;
    cell.txtTagName.tag = AddVenderCellPhone;
    cell.txtTagName.userInteractionEnabled = FALSE;
    [cell.btnAddTag setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail"] forState:UIControlStateNormal];
    [cell.btnAddTag setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail_sel"] forState:UIControlStateHighlighted];
    cell.txtTagName.keyboardType = UIKeyboardTypePhonePad;
    [cell.btnAddTag removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
    [cell.btnAddTag addTarget:self action:@selector(stateSelectionClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(UITableViewCell *)configurVanderPin:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Zipcode";
    cell.txtInputValue.text = addVendorModel.strVanderPin;
    cell.txtInputValue.tag = AddVenderCellPin;
    cell.txtInputValue.placeholder = @"Enter Zipcode";
    return cell;
}

-(UITableViewCell *)configurVanderZone:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Zone";
    cell.txtInputValue.text = addVendorModel.strVanderZone;
    cell.txtInputValue.tag = AddVenderCellZone;
    cell.txtInputValue.placeholder = @"Enter Zone";
    return cell;
}

-(UITableViewCell *)configurMobileCell:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    NSString * identifier=@"ItemInfoTagCell";
    ItemInfoTagCell *cell=(ItemInfoTagCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.lblCellName.text = @"Phone";
    cell.txtTagName.placeholder = @"Enter Phone";
    cell.txtTagName.tag = AddVenderCellPhone;
    cell.txtTagName.keyboardType = UIKeyboardTypePhonePad;
    cell.txtTagName.userInteractionEnabled = TRUE;
    cell.txtTagName.text = addVendorModel.strVanderPhone;
    [cell.btnAddTag setImage:[UIImage imageNamed:@"RIM_Add_Icon_20px"] forState:UIControlStateNormal];
    [cell.btnAddTag setImage:[UIImage imageNamed:@"RIM_Add_Icon_20px_sel"] forState:UIControlStateHighlighted];
    [cell.btnAddTag removeTarget:nil
                       action:NULL
             forControlEvents:UIControlEventAllEvents];
    [cell.btnAddTag addTarget:self action:@selector(addPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(UITableViewCell *)configurPhoneNumberListCell:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{

    RapidFilterSelectedListCell *cell=(RapidFilterSelectedListCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneNumberListcell"];
    
    cell.itemList.tagDelegate = self;
    [cell configureCellToPhone:self.phoneNoArray withTitle:@""];
    return cell;
}


-(UITableViewCell *)configurVanderEmail:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Email";
    cell.txtInputValue.text = addVendorModel.strVanderEmail;
    cell.txtInputValue.tag = AddVenderCellEmail;
    cell.txtInputValue.placeholder = @"Enter Email";
    return cell;
}

-(IBAction)stateSelectionClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    StateSelectionVC *stateSelectionVC = [storyBoard instantiateViewControllerWithIdentifier:@"StateSelectionVC_sid"];
    stateSelectionVC.stateSelectionDelegate = self;
    stateSelectionVC.selectedState = addVendorModel.strVanderState;
    [self.navigationController pushViewController:stateSelectionVC animated:YES];
}
-(BOOL)validateEmail:(NSString *)email

{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}

#pragma mark -
#pragma mark Save Vender Methods

- (IBAction)saveVenderClicked:(id)sender
{
    [self.view endEditing:YES];
    if(!(addVendorModel.strVanderName.length > 0))
    {
        [self showAlertWithMessage:@"Please enter companyname" forTextField:nil];
        return;
    }
    else if (self.phoneNoArray.count == 0)
    {
        [self showAlertWithMessage:@"Please enter phone number(s)" forTextField:nil];
        return;
    }
    
    BOOL isUniqueVendor = [self isVendorNameUnique:addVendorModel.strVanderName];
    if (!isUniqueVendor) {
        [self showAlertWithMessage:@"Please enter Unique Vendor(Company) Name" forTextField:nil];
        return;
    }
    
    BOOL eV;
    eV=[self validateEmail:addVendorModel.strVanderEmail];
    if(eV==false)
        
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Enter Valid Email Address" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
    
    NSMutableDictionary * venderDetailsDict = [[NSMutableDictionary alloc] init];
    venderDetailsDict[@"supplierdata"] = [self getVenderMasterParam];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getInsertedVenderResponse:response error:error];
        });
    };
    
    self.insertSupplierCompanyWC = [self.insertSupplierCompanyWC initWithRequest:KURL actionName:WSM_INSERT_SUPPLIER_COMPAPNY params:venderDetailsDict completionHandler:completionHandler];
}

- (void) getInsertedVenderResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *supId = [NSString stringWithFormat:@"%@",[response valueForKey:@"Data"]];
                
                NSMutableDictionary *pDict = [[self getSupplierCompanyData] mutableCopy];
                pDict[@"Id"] = supId;
                [self.updateManager insertSupplierCompanyWithDictionary:pDict];
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Vender has been added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                NSString *message = [response valueForKey:@"Data"];
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }

        }
    }
}

-(BOOL)isVendorNameUnique:(NSString *)vendorName
{
    vendorName = [vendorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL isUniqueVendor = TRUE;
    NSArray *uniqueVendors = [self fetchVendorsForVendorName:vendorName];
    if (uniqueVendors !=nil && uniqueVendors.count > 0) {
        isUniqueVendor = FALSE;
    }
    return isUniqueVendor;
}

- (NSArray *)fetchVendorsForVendorName:(NSString *)vendorName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyName == [c]%@",vendorName];
    fetchRequest.predicate = predicate;
    NSArray *uniqueVendors = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return uniqueVendors;
}

- (NSString *)getPhoneNumbers
{
    NSString *phoneNoString = @"";
    NSMutableString *strResult = [NSMutableString string];
    if(self.phoneNoArray.count > 0)
    {
        for (int isup=0; isup<self.phoneNoArray.count; isup++)
        {
            NSString *ch = (self.phoneNoArray)[isup];
            [strResult appendFormat:@"%@,", ch];
        }
        phoneNoString = [strResult substringToIndex:strResult.length - 1];
    }
    else
    {
        phoneNoString = @"";
    }
    return phoneNoString;
}

- (void)setValueToVenderDictionary:(NSMutableDictionary *)salesRepMasterDict textField:(UITextField *)inputTextField forKey:(NSString *)keyName
{
    if (inputTextField.text.length == 0) {
        salesRepMasterDict[keyName] = @"";
    } else {
        salesRepMasterDict[keyName] = inputTextField.text;
    }
}

- (NSMutableDictionary *)getVenderMasterParam
{
    NSMutableDictionary *venderMasterDict = [[NSMutableDictionary alloc] init];
    
    venderMasterDict[@"CompanyName"] = addVendorModel.strVanderName;
    venderMasterDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    NSString *address = [addVendorModel.strVanderAdd1 stringByAppendingString:addVendorModel.strVanderAdd2];
    if (address.length == 0) {
        venderMasterDict[@"Address"] = @"";
    } else {
        venderMasterDict[@"Address"] = address;
    }
    
    venderMasterDict[@"City"] = addVendorModel.strVanderCity;
    venderMasterDict[@"State"] = addVendorModel.strVanderState;
    venderMasterDict[@"ZipCode"] = addVendorModel.strVanderPin;
    
    NSString *phoneNoString = [self getPhoneNumbers];
    venderMasterDict[@"PhoneNo"] = phoneNoString;
    
    venderMasterDict[@"Email"] = addVendorModel.strVanderEmail;
    venderMasterDict[@"Zone"] = addVendorModel.strVanderZone;
    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    venderMasterDict[@"DateCreated"] = currentDateTime;
    
    venderMasterDict[@"CreatedBy"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    venderMasterDict[@"VenderId"] = @"0";
    venderMasterDict[@"SupplierZone"] = @"";
    venderMasterDict[@"SupplierDatabase"] = @"";
    venderMasterDict[@"FTPURL"] = @"";
    venderMasterDict[@"FTPUserName"] = @"";
    venderMasterDict[@"FTPPassword"] = @"";
    venderMasterDict[@"Warehouse"] = @"";
    
    return venderMasterDict;
}

- (NSMutableDictionary *)getSupplierCompanyData
{
    NSMutableDictionary *venderMasterDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *venderDict = [self getVenderMasterParam];
    
    venderMasterDict[@"CompanyName"] = venderDict[@"CompanyName"];
    venderMasterDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    venderMasterDict[@"Address"] = venderDict[@"Address"];
    
    venderMasterDict[@"City"] = venderDict[@"City"];
    venderMasterDict[@"State"] = venderDict[@"State"];
    venderMasterDict[@"ZipCode"] = venderDict[@"ZipCode"];
    
    venderMasterDict[@"PhoneNo"] = venderDict[@"PhoneNo"];
    
    venderMasterDict[@"Email"] = venderDict[@"Email"];
    venderMasterDict[@"CompanyZone"] = venderDict[@"Zone"];
    venderMasterDict[@"IsDeleted"] = @(0);
    venderMasterDict[@"CreatedDate"] = venderDict[@"DateCreated"];
    
    venderMasterDict[@"CreatedBy"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    venderMasterDict[@"VenderId"] = @(0);
    venderMasterDict[@"SupplierZone"] = @"";
    venderMasterDict[@"SupplierDatabase"] = @"";
    venderMasterDict[@"FTPURL"] = @"";
    venderMasterDict[@"FTPUserName"] = @"";
    venderMasterDict[@"FTPPassword"] = @"";
    venderMasterDict[@"Warehouse"] = @"";
    
    return venderMasterDict;
}

- (IBAction)backToVenderView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertWithMessage:(NSString *)message forTextField:(UITextField *)textField
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        if (textField) {
            [textField becomeFirstResponder];
        }
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

#pragma mark -
#pragma mark For StateSelectionDelegate Method

-(void)selectedState:(NSString *)selectedState
{
    if(![selectedState isEqualToString:@""])
    {
        addVendorModel.strVanderState = selectedState;
    }
    else
    {
        addVendorModel.strVanderState = @"";
    }
    [self setListOfCell];
    [self.addVenderTableView reloadData];
}

@end
