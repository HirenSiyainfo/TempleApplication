//
//  AddSalesRepresentativeVC.m
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddSalesRepresentativeModel.h"
#import "AddSalesRepresentativeVC.h"
#import "CompanyNameSelectionVC.h"
#import "ItemInfoDisplayCell.h"
#import "ItemInfoTagCell.h"
#import "MPTagList.h"
#import "RapidFilterSelectedListCell.h"
#import "RmsDbController.h"
#import "StateSelectionVC.h"
#import "UITableView+AddBorder.h"
#import "UpdateManager.h"


@interface AddSalesRepresentativeVC () <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,StateSelectionDelegate,CompanyNameSelectionDelegate,UpdateDelegate,MPTagListDelegate>
{

    NSString *selectedCompanyID;
    IntercomHandler *intercomHandler;
    AddSalesRepresentativeModel * addSalesModel;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, weak) IBOutlet UITableView *addSalesRepTableView;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, strong) NSMutableArray *phoneNoArray;
@property (nonatomic, strong) NSMutableArray *salesRepArray;

@property (nonatomic, strong) RapidWebServiceConnection * insertSupplierWC;

@end

@implementation AddSalesRepresentativeVC
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];

    
    self.phoneNoArray = [[NSMutableArray alloc] init];
    addSalesModel = [[AddSalesRepresentativeModel alloc]init];
    [self setListOfCell];
    self.insertSupplierWC = [[RapidWebServiceConnection alloc] init];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    if(self.calledVenderName)
    {
        addSalesModel.strVanderName = self.calledVenderName;
    }
    if (self.calledVenderId) {
        selectedCompanyID = self.calledVenderId;
    }
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)setListOfCell{
    
    if (self.phoneNoArray.count > 0) {
        self.salesRepArray = [[NSMutableArray alloc] initWithObjects:@(AddVanderCellSelection),@(AddSalesCellName),@(AddSalesCellPosition),@(AddSalesCellAdd1),@(AddSalesCellAdd2),@(AddSalesCellCity),@(AddSalesCellState),@(AddSalesCellPin),@(AddSalesCellZone),@(AddSalesCellPhone),@(AddSalesCellPhoneList),@(AddSalesCellEmail), nil];
    }
    else{
        self.salesRepArray = [[NSMutableArray alloc] initWithObjects:@(AddVanderCellSelection),@(AddSalesCellName),@(AddSalesCellPosition),@(AddSalesCellAdd1),@(AddSalesCellAdd2),@(AddSalesCellCity),@(AddSalesCellState),@(AddSalesCellPin),@(AddSalesCellZone),@(AddSalesCellPhone),@(AddSalesCellEmail), nil];
    }
}

#pragma mark -
#pragma mark UITextField Delegate
#pragma mark - MPTagListDelegate -

- (void)selectedTag:(NSString *)tagName withTabView:(id) tagView
{
    [self.phoneNoArray removeObjectAtIndex:((MPTagView *)tagView).tag];
    [self setListOfCell];
    [self.addSalesRepTableView reloadData];
}

- (void)addPhoneNumber
{
    [self.view endEditing:YES];
    if(addSalesModel.strSalesPhone.length > 0)
    {
        [self.phoneNoArray addObject:addSalesModel.strSalesPhone];
        [self setListOfCell];
        addSalesModel.strSalesPhone = @"";
        [self.addSalesRepTableView reloadData];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    AddSalesCell rowType = textField.tag;
    switch (rowType) {
        case AddVanderCellSelection: {
            break;
        }
        case AddSalesCellName: {
            addSalesModel.strSalesName = textField.text;
            break;
        }
        case AddSalesCellPosition: {
            addSalesModel.strSalesPosition = textField.text;
            break;
        }
        case AddSalesCellAdd1:{
            addSalesModel.strSalesAdd1 = textField.text;
            break;
        }
        case AddSalesCellAdd2:{
            addSalesModel.strSalesAdd2 = textField.text;
            break;
        }
        case AddSalesCellCity:{
            addSalesModel.strSalesCity = textField.text;
            break;
        }
        case AddSalesCellState:{
            break;
        }
        case AddSalesCellPin:{
            addSalesModel.strSalesPin = textField.text;
            break;
        }
        case AddSalesCellZone:{
            addSalesModel.strSalesZone = textField.text;
            break;
        }
        case AddSalesCellPhone:{
            addSalesModel.strSalesPhone = textField.text;
            [self addPhoneNumber];
            break;
        }
        case AddSalesCellPhoneList:{
            break;
        }
        case AddSalesCellEmail:{
            addSalesModel.strSalesEmail = textField.text;
            break;
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TableView Delegate & Data Source -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat headerHeight = 55.0;
    AddSalesCell rowType = [self.salesRepArray[indexPath.row] integerValue];
    if (rowType == AddSalesCellPhoneList && self.phoneNoArray.count > 0) {
        RapidFilterSelectedListCell *cell = (RapidFilterSelectedListCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneNumberListcell"];
        
        [cell.itemList setAutomaticResize:YES];
        [cell.itemList setTags:self.phoneNoArray];
        return cell.itemList.frame.size.height + 10;
    }
    return headerHeight;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.salesRepArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    AddSalesCell rowType = [self.salesRepArray[indexPath.row] integerValue];
    switch (rowType)
    {
        case AddVanderCellSelection: {
            cell = [self configurVandername:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellName: {
            cell = [self configurSalesname:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellPosition: {
            cell = [self configurSalesPosition:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellAdd1: {
            cell = [self configurSalesAdd1:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellAdd2:{
            cell = [self configurSalesAdd2:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellCity: {
            cell = [self configurSalesCity:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellState: {
            cell = [self configurStateCell:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellPin: {
            cell = [self configurSalesPin:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellZone: {
            cell = [self configurSalesZone:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellPhone: {
            cell = [self configurSalesMobileCell:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellPhoneList: {
            cell = [self configurPhoneNumberListCell:tableView atIndex:indexPath];
            break;
        }
        case AddSalesCellEmail:{
            cell = [self configurSalesEmail:tableView atIndex:indexPath];
            break;
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}



#pragma mark - configurCells  -

-(UITableViewCell *)configurVandername:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath {
    
    ItemInfoTagCell *cell=(ItemInfoTagCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoTagCell"];
    
    cell.lblCellName.text = @"Vendor(Company) Name";
    cell.txtTagName.placeholder = @"Select Vendor(Company) Name";
    cell.txtTagName.text = addSalesModel.strVanderName;
    cell.txtTagName.tag = AddVanderCellSelection;
    cell.txtTagName.userInteractionEnabled = FALSE;
    [cell.btnAddTag setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail"] forState:UIControlStateNormal];
    [cell.btnAddTag setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail_sel"] forState:UIControlStateHighlighted];
    cell.txtTagName.keyboardType = UIKeyboardTypePhonePad;
    [cell.btnAddTag removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
    [cell.btnAddTag addTarget:self action:@selector(salesCompanyNameClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
-(UITableViewCell *)configurSalesname:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath {
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Name";
    cell.txtInputValue.text = addSalesModel.strSalesName;
    cell.txtInputValue.tag = AddSalesCellName;
    cell.txtInputValue.placeholder = @"Enter Name";
    return cell;
}

-(UITableViewCell *)configurSalesPosition:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Position";
    cell.txtInputValue.text = addSalesModel.strSalesPosition;
    cell.txtInputValue.tag = AddSalesCellPosition;
    cell.txtInputValue.placeholder = @"Enter Position";
    return cell;
}

-(UITableViewCell *)configurSalesAdd1:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Address";
    cell.txtInputValue.text = addSalesModel.strSalesAdd1;
    cell.txtInputValue.tag = AddSalesCellAdd1;
    cell.txtInputValue.placeholder = @"Enter Address Line 1";
    return cell;
}

-(UITableViewCell *)configurSalesAdd2:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"";
    cell.txtInputValue.text = addSalesModel.strSalesAdd2;
    cell.txtInputValue.tag = AddSalesCellAdd2;
    cell.txtInputValue.placeholder = @"Enter Address Line 2";
    return cell;
}

-(UITableViewCell *)configurSalesCity:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"City";
    cell.txtInputValue.text = addSalesModel.strSalesCity;
    cell.txtInputValue.tag = AddSalesCellCity;
    cell.txtInputValue.placeholder = @"Enter City";
    return cell;
}

-(UITableViewCell *)configurStateCell:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    NSString * identifier=@"ItemInfoTagCell";
    ItemInfoTagCell *cell=(ItemInfoTagCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.lblCellName.text = @"State";
    cell.txtTagName.placeholder = @"Select State";
    cell.txtTagName.text = addSalesModel.strSalesState;
    cell.txtTagName.tag = AddSalesCellState;
    cell.txtTagName.userInteractionEnabled = FALSE;
    [cell.btnAddTag setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail"] forState:UIControlStateNormal];
    [cell.btnAddTag setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail_sel"] forState:UIControlStateHighlighted];
    cell.txtTagName.keyboardType = UIKeyboardTypePhonePad;
    [cell.btnAddTag removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
    [cell.btnAddTag addTarget:self action:@selector(stateSelectionForSalesClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(UITableViewCell *)configurSalesPin:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Zipcode";
    cell.txtInputValue.text = addSalesModel.strSalesPin;
    cell.txtInputValue.tag = AddSalesCellPin;
    cell.txtInputValue.placeholder = @"Enter Zipcode";
    return cell;
}

-(UITableViewCell *)configurSalesZone:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Zone";
    cell.txtInputValue.text = addSalesModel.strSalesZone;
    cell.txtInputValue.tag = AddSalesCellZone;
    cell.txtInputValue.placeholder = @"Enter Zone";
    return cell;
}

-(UITableViewCell *)configurSalesMobileCell:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    NSString * identifier=@"ItemInfoTagCell";
    ItemInfoTagCell *cell=(ItemInfoTagCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.lblCellName.text = @"Phone";
    cell.txtTagName.placeholder = @"Enter Phone";
    cell.txtTagName.tag = AddSalesCellPhone;
    cell.txtTagName.keyboardType = UIKeyboardTypePhonePad;
    cell.txtTagName.userInteractionEnabled = TRUE;
    cell.txtTagName.text = addSalesModel.strSalesPhone;
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

-(UITableViewCell *)configurSalesEmail:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath{
    ItemInfoDisplayCell *cell=(ItemInfoDisplayCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemInfoDisplayCell"];
    cell.lblCellName.text = @"Email";
    cell.txtInputValue.text = addSalesModel.strSalesEmail;
    cell.txtInputValue.tag = AddSalesCellEmail;
    cell.txtInputValue.placeholder = @"Enter Email";
    return cell;
}

-(IBAction)salesCompanyNameClicked:(id)sender {
    [self.view endEditing:YES];
    [self.rmsDbController playButtonSound];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    CompanyNameSelectionVC *companyNmSelectionVC = [storyBoard instantiateViewControllerWithIdentifier:@"CompanyNameSelectionVC_sid"];
    companyNmSelectionVC.companyNameSelectionDelegate = self;
    companyNmSelectionVC.companyNameSelected = addSalesModel.strVanderName;
    [self.navigationController pushViewController:companyNmSelectionVC animated:YES];
}

-(IBAction)stateSelectionForSalesClicked:(id)sender {
    [self.view endEditing:YES];
    [self.rmsDbController playButtonSound];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    StateSelectionVC *stateSelectionVC = [storyBoard instantiateViewControllerWithIdentifier:@"StateSelectionVC_sid"];
    stateSelectionVC.stateSelectionDelegate = self;
    stateSelectionVC.selectedState = addSalesModel.strSalesState;
    [self.navigationController pushViewController:stateSelectionVC animated:YES];
}

-(BOOL)validateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}

#pragma mark - Save SalesRepresentative Methods -

- (IBAction)saveSalesRepresentativeClicked:(id)sender {
    
    [self.view endEditing:YES];
    BOOL isUniqueSalesRepresentative = [self isSalesRepresentativeNameUnique:addSalesModel.strSalesName];
    if(!(addSalesModel.strVanderName.length > 0)) {
        [self showAlertForSalesRepresentativeWithMessage:@"Please select company" forTextField:nil];
    }
    else if(!(addSalesModel.strSalesName.length > 0)) {
        [self showAlertForSalesRepresentativeWithMessage:@"Please enter sales representative name" forTextField:nil];
    }
    else if (self.phoneNoArray.count == 0 && addSalesModel.strSalesEmail.length == 0) {
        [self showAlertForSalesRepresentativeWithMessage:@"Please enter phone number(s) or Email Address" forTextField:nil];
    }
    else if (addSalesModel.strSalesEmail.length > 0 && ![self validateEmail:addSalesModel.strSalesEmail]) {
        [self showAlertForSalesRepresentativeWithMessage:@"Enter Valid Email Address" forTextField:nil];
    }
    else if (!isUniqueSalesRepresentative) {
        [self showAlertForSalesRepresentativeWithMessage:@"Please enter Unique Sales Representative Name" forTextField:nil];
    }
    else {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:[UIApplication sharedApplication].keyWindow];
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getInsertedSalesRepResponse:response error:error];
            });
        };
        NSMutableDictionary * venderDetailsDict = [[NSMutableDictionary alloc] init];
        venderDetailsDict[@"SupplierData"] = [self getSalesRepMasterParam];
        
        self.insertSupplierWC = [self.insertSupplierWC initWithRequest:KURL actionName:WSM_INSERT_SUPPLIER params:venderDetailsDict completionHandler:completionHandler];
    }
}

- (void) getInsertedSalesRepResponse:(id)response error:(NSError *)error {
    
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *salesRepArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [self.updateManager insertSupplierRepresentativelist:salesRepArray moc:privateContextObject];
                
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Sales Representative has been added successfully" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
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

-(BOOL)isSalesRepresentativeNameUnique:(NSString *)salesRepresentativeName
{
    salesRepresentativeName = [salesRepresentativeName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL isUniqueSalesRepresentative = TRUE;
    NSArray *uniqueSalesRepresentatives = [self fetchSalesRepresentativeForSalesRepresentativeName:salesRepresentativeName];
    if (uniqueSalesRepresentatives !=nil && uniqueSalesRepresentatives.count > 0) {
        isUniqueSalesRepresentative = FALSE;
    }
    return isUniqueSalesRepresentative;
}

- (NSArray *)fetchSalesRepresentativeForSalesRepresentativeName:(NSString *)salesRepresentativeName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierRepresentative" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName == [c]%@",salesRepresentativeName];
    fetchRequest.predicate = predicate;
    NSArray *uniqueSalesRepresentatives = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return uniqueSalesRepresentatives;
}

- (NSString *)getPhoneNumbers
{
    NSString *phoneNoString = @"";
    NSMutableString *strResult = [NSMutableString string];
    if(self.self.phoneNoArray.count > 0)
    {
        for (int isup=0; isup<self.self.phoneNoArray.count; isup++)
        {
            NSString *ch = (self.self.phoneNoArray)[isup];
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

- (void)setValueToSalesRepDictionary:(NSMutableDictionary *)salesRepMasterDict textField:(UITextField *)inputTextField forKey:(NSString *)keyName
{
    if (inputTextField.text.length == 0) {
        salesRepMasterDict[keyName] = @"";
    } else {
        salesRepMasterDict[keyName] = inputTextField.text;
    }
}

- (NSMutableDictionary *)getSalesRepMasterParam
{
    NSMutableDictionary *salesRepMasterDict = [[NSMutableDictionary alloc] init];
    
    salesRepMasterDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    salesRepMasterDict[@"CompanyName"] = addSalesModel.strVanderName;
    salesRepMasterDict[@"FirstName"] = addSalesModel.strSalesName;
    salesRepMasterDict[@"LastName"] = @"";
    salesRepMasterDict[@"Position"] = addSalesModel.strSalesPosition;
    
    
    salesRepMasterDict[@"Address1"] = addSalesModel.strSalesAdd1;
    salesRepMasterDict[@"Address2"] = addSalesModel.strSalesAdd2;
    salesRepMasterDict[@"City"] = addSalesModel.strSalesCity;
    salesRepMasterDict[@"State"] = addSalesModel.strSalesState;
    salesRepMasterDict[@"ZipCode"] = addSalesModel.strSalesPin;
    salesRepMasterDict[@"Email"] = addSalesModel.strSalesEmail;
    salesRepMasterDict[@"Zone"] = addSalesModel.strSalesZone;
    NSString *phoneNoString = [self getPhoneNumbers];
    salesRepMasterDict[@"ContactNo"] = phoneNoString;
    
    salesRepMasterDict[@"CreatedBy"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    // Pass system date and time while insert
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    salesRepMasterDict[@"DateCreated"] = currentDateTime;
    
    if (self.phoneNoArray.count == 0)
    {
        NSString *selectedPhoneNo = @"";
        salesRepMasterDict[@"SelectedPhoneNo"] = selectedPhoneNo;
    }
    else
    {
        NSString *selectedPhoneNo = self.phoneNoArray.firstObject;
        salesRepMasterDict[@"SelectedPhoneNo"] = selectedPhoneNo;
    }
    
    salesRepMasterDict[@"CompanyId"] = selectedCompanyID;
    salesRepMasterDict[@"ItemCodes"] = @"";
    
    return salesRepMasterDict;
}


- (IBAction)backToSalesRepresentativeView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertForSalesRepresentativeWithMessage:(NSString *)message forTextField:(UITextField *)textField
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
        if (textField) {
            [textField becomeFirstResponder];
        }
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:message buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

#pragma mark - For StateSelection Delegate Method -

-(void)selectedState:(NSString *)selectedState
{
    if(![selectedState isEqualToString:@""]) {
        addSalesModel.strSalesState = selectedState;
    }
    else {
        addSalesModel.strSalesState = @"";
    }
    [self.addSalesRepTableView reloadData];
}

#pragma mark - For CompanyName Delegate Method -

-(void)didSelectedCompanyName:(NSString *)selectedCompanyName SelectedCompanyID:(NSInteger)companyID
{
    if(![selectedCompanyName isEqualToString:@""])
    {
        addSalesModel.strVanderName = selectedCompanyName;
        selectedCompanyID = [NSString stringWithFormat:@"%ld",(long)companyID];
    }
    else
    {
        addSalesModel.strVanderName = @"";
        selectedCompanyID = @"0";
    }
    [self.addSalesRepTableView reloadData];
}
@end
