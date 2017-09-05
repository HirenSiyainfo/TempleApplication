//
//  AddCustomerVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AddCustomerVC.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "RmsDbController.h"
#import "AddCustomerCustomCellTableViewCell.h"
#import "RapidCustomerLoyalty.h"
#import "DatePickerVC.h"
#import "AddCustomerBillShippingAddressCommonCell.h"
#import "UpdateManager.h"

#define BillAddressTextView_Tag 501
#define ShippingAddressTextView_Tag 601

#define BillAddressFirstTextFieldValue_Tag 101
#define BillAddressSecondTextFieldValue_Tag 201

typedef struct {
    void *key;
    void *value;
    
}KeyValuePair;


typedef struct {
    void *firstKey;
    void *firstValue;

    void *secondKey;
    void *secondValue;
    
}MultipleKeyValuePair;

typedef NS_ENUM(NSUInteger, AddCustomerSection) {
    AddCustomerContactSection,
    AddCustomerPersonalInformationSection,
    AddCustomerBillingAddressSection,
    AddCustomerSameAsAddressSection,
    AddCustomerShippingAddressSection,
};

typedef NS_ENUM(NSInteger, ContactSection)
{
    ContactNo,
    Email,
    CustomerNo,
};

typedef NS_ENUM(NSInteger, PersonalInformationSection)
{
    FirstName,
    LastName,
    DrivingLicenceNo,
    DOB,
    CreditLimit,
};
typedef NS_ENUM(NSInteger, BillingAddress)
{
    Bill_Address1,
    Bill_Address2,
    Bill_City,
    Bill_State,
    Bill_ZipCode,
   // Bill_Country,
};
typedef NS_ENUM(NSInteger, SameAsAddress)
{
    SameAsBillingAddress,
};

typedef NS_ENUM(NSInteger, ShippingAddress)
{
    Shipping_Address1,
    Shipping_Address2,
    Shipping_City,
    Shipping_State,
    Shipping_ZipCode,
  //  Shipping_Country,
};

@interface AddCustomerVC ()<AddCustomerCustomCelldelegate,DatePickerDelegate,AddCustomerBillShippingAddressCommonCelldelegate , UpdateDelegate>
{
    NSArray *addCustomerSectionArray;
    NSArray *addCustomerRowArray;
    UITextField *currentEditableTextField;
    UITextView *currentEditableTextView;
    
    NSString *strOldCustomerNumber;
}
@property (nonatomic, weak) IBOutlet UITableView *addCustomerTableView;
@property (nonatomic, weak) IBOutlet UIView *datePickerView;
@property (nonatomic, weak) IBOutlet UIView *viewFooter;
@property (nonatomic, weak) IBOutlet UIView *viewheader;
@property (nonatomic, weak) IBOutlet UIView *viewDetail;
@property (nonatomic, weak) IBOutlet UIButton *btnDone;


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) DatePickerVC *datePickerVC;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *updateCustomerWC;
@property (nonatomic, strong) RapidWebServiceConnection *insertCustomerWC;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;



@end

@implementation AddCustomerVC

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
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];


    self.btnDone.layer.cornerRadius = 5.0;
    self.updateCustomerWC = [[RapidWebServiceConnection alloc]init];
    self.insertCustomerWC = [[RapidWebServiceConnection alloc]init];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _datePickerVC = [storyBoard instantiateViewControllerWithIdentifier:@"DatePickerVC"];
    _datePickerVC.datePickerDelegate = self;
    _datePickerVC.view.center = _datePickerView.center;
    [_datePickerView addSubview:_datePickerVC.view];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.rapidCustomerLoyalty == nil)
    {
        self.rapidCustomerLoyalty = [[RapidCustomerLoyalty alloc] init];
        self.viewheader.hidden = NO;
        strOldCustomerNumber = @"";
    }
    else
    {
        self.viewheader.hidden = YES;
        self.viewDetail.frame = CGRectMake(self.viewDetail.frame.origin.x, self.viewheader.frame.origin.x+5, self.viewDetail.frame.size.width, self.viewDetail.frame.size.height);
        _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, self.viewDetail.frame.size.height + self.viewDetail.frame.origin.x+5 , _viewFooter.frame.size.width, _viewFooter.frame.size.height);
        strOldCustomerNumber = self.rapidCustomerLoyalty.customerNo;
    }
    [self registerForKeyboardNotifications];

    addCustomerSectionArray = @[@(AddCustomerContactSection),@(AddCustomerPersonalInformationSection),@(AddCustomerSameAsAddressSection),@(AddCustomerBillingAddressSection)];
    addCustomerRowArray = @[@[@(ContactNo),@(Email),@(CustomerNo)],@[@(FirstName),@(LastName),@(DrivingLicenceNo),@(DOB), @(CreditLimit)],@[@(SameAsBillingAddress)],@[@(Bill_Address1),@(Bill_Address2),@(Bill_City),@(Bill_State),@(Bill_ZipCode)]];
  
    [_addCustomerTableView reloadData];
}


-(IBAction)btnDoneClick:(id)sender
{
    [currentEditableTextField resignFirstResponder];
    
    if (self.rapidCustomerLoyalty.customerNo.length == 0) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"The Customer Number is required." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    
    if (self.rapidCustomerLoyalty.email.length > 0) {
        BOOL eV;
        eV=[self validateEmail:self.rapidCustomerLoyalty.email];
        if(eV==false)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Enter Valid Email Address" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        
    }
    if ((self.rapidCustomerLoyalty.contactNo.length > 0 && ![self.rapidCustomerLoyalty.contactNo isEqualToString:@" "]) || self.rapidCustomerLoyalty.email.length > 0 ) {
        
        if (![strOldCustomerNumber isEqualToString:@""] && ![self.rapidCustomerLoyalty.customerNo isEqualToString:strOldCustomerNumber]) {
            UIAlertActionHandler NoButtonTaped = ^ (UIAlertAction *action)
            {
                self.rapidCustomerLoyalty.customerNo = strOldCustomerNumber;
                [_addCustomerTableView reloadData];
            };
            UIAlertActionHandler YesButtonTaped = ^ (UIAlertAction *action)
            {
                [self updateCustomerInformations];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Are you sure you want to change the Customer Number?" buttonTitles:@[@"No", @"Yes"] buttonHandlers:@[NoButtonTaped,YesButtonTaped]];
            return;
        }else{
            [self updateCustomerInformations];
        }
        
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"The Contact Number or Email id is required." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
    }
}

-(void)updateCustomerInformations{
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    if (self.rapidCustomerLoyalty.custId.integerValue > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        itemparam[@"CustomerData"] = self.rapidCustomerLoyalty.customerDetailDictionary;
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self UpdateCustomerResponse:response error:error];
            });
        };
        
        self.updateCustomerWC = [self.updateCustomerWC initWithRequest:KURL actionName:WSM_UPDATE_CUSTOMER params:itemparam completionHandler:completionHandler];
        
    }
    else
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        itemparam[@"CustomerData"] = self.rapidCustomerLoyalty.customerDetailDictionary;
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self InsertCustomerResponse:response error:error];
            });
        };
        
        self.insertCustomerWC = [self.insertCustomerWC initWithRequest:KURL actionName:WSM_INSERT_CUSTOMER params:itemparam completionHandler:completionHandler];
    }
}

-(BOOL)validateEmail:(NSString *)email

{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}


- (void)InsertCustomerResponse:(id)response error:(NSError *)error {
    [_activityIndicator hideActivityIndicator];;
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self updateDataInDataBase];

                AddCustomerVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference.addCustomerVCdelegate didUpdateCustomerList];
                    [myWeakReference.view removeFromSuperview];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Successfully Inserted" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(void)updateDataInDataBase {
    
    NSMutableDictionary *itemLiveUpdate = [[NSMutableDictionary alloc]init];
    [itemLiveUpdate setValue:@"Update" forKeyPath:@"Action"];
    [itemLiveUpdate setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"EntityId"];
    [itemLiveUpdate setValue:@"Customer" forKey:@"Type"];
    [self.rmsDbController addItemListToLiveUpdateQueue:itemLiveUpdate];
    
}

- (void)UpdateCustomerResponse:(id)response error:(NSError *)error{
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self updateDataInDataBase];

                AddCustomerVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [myWeakReference.addCustomerVCdelegate didUpdateCustomerList];
                    [myWeakReference.view removeFromSuperview];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Successfully Updated" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];;
}


-(IBAction)btnCancelClick:(id)sender
{
    [self.view removeFromSuperview];
//    [self.addCustomerVCdelegate didCancelAddCustomer];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark-
#pragma TableView Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    AddCustomerSection addCustomerSection = [addCustomerSectionArray[section] integerValue];

    switch (addCustomerSection) {
        case AddCustomerContactSection:
            sectionName = @"";
            break;
            
        case  AddCustomerPersonalInformationSection:
            sectionName = @"";
            break;
            
        case  AddCustomerBillingAddressSection:
            sectionName = @"";
            break;
            
        case AddCustomerShippingAddressSection:
            sectionName = @"";
            break;
            
        case AddCustomerSameAsAddressSection:
            sectionName = @"";
            break;
        default:
            break;
    }
    return sectionName;
    
    
}

//-(BOOL)isAddressSectionAtIndexPath:(NSIndexPath *)indexpath
//{
//    BOOL isAddressRow = FALSE;
//    BillingAddress billAddress = [addCustomerRowArray[indexpath.section][indexpath.row] integerValue];
//    if (billAddress == Bill_Address1) {
//        isAddressRow = TRUE;
//    }
//    return isAddressRow;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return addCustomerSectionArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sectionHeight = 0.0;
    AddCustomerSection addCustomerSection = [addCustomerSectionArray[indexPath.section] integerValue];

    
    switch (addCustomerSection) {
        case AddCustomerContactSection:
            sectionHeight = 40;
            break;
            
        case  AddCustomerPersonalInformationSection:
            sectionHeight = 40;
            break;
            
        case  AddCustomerBillingAddressSection:
        {
            sectionHeight = 40;
            
//            if ([self isAddressSectionAtIndexPath:indexPath]) {
//                sectionHeight = 44;
//            }
        }
            break;
   
            
        case AddCustomerSameAsAddressSection:
            sectionHeight = 40;
            break;
        default:
            break;
    }
    return sectionHeight;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [addCustomerRowArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AddCustomerCustomCellTableViewCell";
    AddCustomerSection addCustomerSection = [addCustomerSectionArray[indexPath.section] integerValue];

    if (addCustomerSection == AddCustomerSameAsAddressSection)
    {
    cellIdentifier = @"AddCustomerSameAsAddressCell";
    AddCustomerCustomCellTableViewCell *addCustomerCustomCellTableViewCell  = (AddCustomerCustomCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    addCustomerCustomCellTableViewCell.addCustomerCustomCelldelegate = self;
    addCustomerCustomCellTableViewCell.currentIndexPath = indexPath;
    addCustomerCustomCellTableViewCell.backgroundColor = [UIColor clearColor];
    return addCustomerCustomCellTableViewCell;
   }
   else if (addCustomerSection == AddCustomerBillingAddressSection)
     {
        cellIdentifier = @"AddCustomerBillShippingAddressCommonCell";
//         if ([self isAddressSectionAtIndexPath:indexPath]) {
//             cellIdentifier = @"AddCustomerBillShippingAddressCell";
//         }
         AddCustomerBillShippingAddressCommonCell *addCustomerBillShippingAddressCommonCell  = (AddCustomerBillShippingAddressCommonCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
         addCustomerBillShippingAddressCommonCell.addCustomerBillShippingAddressCommonCelldelegate = self;
         addCustomerBillShippingAddressCommonCell.currentIndexPath = indexPath;
         
         MultipleKeyValuePair multipleKeyValuePair = [self customerBillingInformationAtRow:indexPath ];
         addCustomerBillShippingAddressCommonCell.firstKey.text = [NSString stringWithFormat:@"%@",multipleKeyValuePair.firstKey] ;
         addCustomerBillShippingAddressCommonCell.secondKey.text = [NSString stringWithFormat:@"%@",multipleKeyValuePair.secondKey] ;
         if ([addCustomerBillShippingAddressCommonCell.firstKey.text isEqualToString:@"Address 1" ] && [addCustomerBillShippingAddressCommonCell.firstKey.text isEqualToString:@"Address 2" ])
         {
             addCustomerBillShippingAddressCommonCell.firstValueTextView.text = [NSString stringWithFormat:@"%@",multipleKeyValuePair.firstValue] ;
             addCustomerBillShippingAddressCommonCell.secondValueTextView.text = [NSString stringWithFormat:@"%@",multipleKeyValuePair.secondValue] ;
         }
         else
         {
             addCustomerBillShippingAddressCommonCell.firstValue.text = [NSString stringWithFormat:@"%@",multipleKeyValuePair.firstValue] ;
             addCustomerBillShippingAddressCommonCell.secondValue.text = [NSString stringWithFormat:@"%@",multipleKeyValuePair.secondValue] ;
         }
         addCustomerBillShippingAddressCommonCell.backgroundColor = [UIColor clearColor];
         return addCustomerBillShippingAddressCommonCell;
    }
    else
    {
        cellIdentifier = @"AddCustomerCustomCellTableViewCell";
        AddCustomerCustomCellTableViewCell *addCustomerCustomCellTableViewCell  = (AddCustomerCustomCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        addCustomerCustomCellTableViewCell.addCustomerCustomCelldelegate = self;
        addCustomerCustomCellTableViewCell.currentIndexPath = indexPath;
        KeyValuePair keyValuePair = [self keyValuePairAtIndexPath:indexPath ];

        addCustomerCustomCellTableViewCell.key.text = [NSString stringWithFormat:@"%@",keyValuePair.key];
        addCustomerCustomCellTableViewCell.value.text = [NSString stringWithFormat:@"%@",keyValuePair.value];
        addCustomerCustomCellTableViewCell.backgroundColor = [UIColor clearColor];

        if (indexPath.section == AddCustomerContactSection && indexPath.row == CustomerNo) {
            //addCustomerCustomCellTableViewCell.value.enabled = false;
            if (self.rapidCustomerLoyalty.customerNo == nil || self.rapidCustomerLoyalty.customerNo.length == 0) {
                addCustomerCustomCellTableViewCell.value.placeholder = @"Enter a customer number to assign manually.";
                [addCustomerCustomCellTableViewCell.autoGenerateCustomerNumberButton setHidden:false];
                //addCustomerCustomCellTableViewCell.value.backgroundColor = [UIColor lightGrayColor];
            }
            else
            {
                if (addCustomerCustomCellTableViewCell.autoGenerateCustomerNumberButton.isHidden) {
                    addCustomerCustomCellTableViewCell.value.enabled = false;
                    addCustomerCustomCellTableViewCell.value.backgroundColor = [UIColor lightGrayColor];
                }
            }
        }
        else {
            addCustomerCustomCellTableViewCell.value.enabled = true;
            [addCustomerCustomCellTableViewCell.autoGenerateCustomerNumberButton setHidden:true];
        }
        
        [addCustomerCustomCellTableViewCell.value setFrame:[self setFrameToAddCutomerCellTextField:addCustomerCustomCellTableViewCell.value autoGenerateButton:addCustomerCustomCellTableViewCell.autoGenerateCustomerNumberButton]];

       // addCustomerCustomCellTableViewCell.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:35.0/255.0 blue:43.0/255.0 alpha:1.0];
        return addCustomerCustomCellTableViewCell;
    }

//    if (addCustomerSection == AddCustomerSameAsAddressSection) {
//        addCustomerCustomCellTableViewCell.backgroundColor = [UIColor clearColor];
//        if (rapidCustomerLoyalty.isSameAsAddesss) {
//            [addCustomerCustomCellTableViewCell.sameAsAddressButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
//        }
//        else
//        {
//            [addCustomerCustomCellTableViewCell.sameAsAddressButton setImage:[UIImage imageNamed:@"checkboxBlank.png"] forState:UIControlStateNormal];
//        }
//    }
//    else
//    {
//    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGRect)setFrameToAddCutomerCellTextField:(UITextField *)textField autoGenerateButton:(UIButton *)autoGenerateButton{
    
    CGRect rectOfTextField = textField.frame;
    CGFloat rectOfTextFieldX = textField.frame.origin.x;
    
    CGRect rectOfButton = autoGenerateButton.frame;
    if (autoGenerateButton.isHidden) {
        rectOfTextField.size.width = (rectOfButton.origin.x + rectOfButton.size.width) - rectOfTextField.origin.x;
    }
    else{
        rectOfTextField.size.width = (rectOfButton.origin.x + rectOfButton.size.width) - rectOfTextField.origin.x;
        rectOfTextField.size.width = rectOfTextField.size.width - rectOfButton.size.width - 10;
    }
    rectOfTextField.origin.x = rectOfTextFieldX;
    return rectOfTextField;
}

-(KeyValuePair)keyValuePairAtIndexPath:(NSIndexPath *)indexPath
{
    KeyValuePair keyValuePair = { @"", @""};
    AddCustomerSection addCustomerSection = [addCustomerSectionArray[indexPath.section] integerValue];
    switch (addCustomerSection) {
        case AddCustomerContactSection:
            keyValuePair = [self contactInformationAtRow:indexPath];
            break;
            
        case  AddCustomerPersonalInformationSection:
            keyValuePair = [self personalInformationAtRow:indexPath];
            break;
            
        case  AddCustomerBillingAddressSection:
            keyValuePair = [self billingInformationAtRow:indexPath];
            break;
            
        case AddCustomerShippingAddressSection:
            keyValuePair = [self shippingBillingInformationAtRow:indexPath];

            break;
            
        case AddCustomerSameAsAddressSection:
            break;
        default:
            break;
    }
    return keyValuePair;
}

-(MultipleKeyValuePair)multipleKeyValuePairAtIndexPath:(NSIndexPath *)indexPath
{
    MultipleKeyValuePair multipleKeyValuePair;
    AddCustomerSection addCustomerSection = [addCustomerSectionArray[indexPath.section] integerValue];
    switch (addCustomerSection) {
        case AddCustomerContactSection:
            break;
            
        case  AddCustomerPersonalInformationSection:
            break;
            
        case  AddCustomerBillingAddressSection:
            break;
            
        case AddCustomerShippingAddressSection:
            
            break;
            
        case AddCustomerSameAsAddressSection:
            break;
            
        default:
            break;
    }
    return multipleKeyValuePair;
}


-(MultipleKeyValuePair)customerBillingInformationAtRow:(NSIndexPath * )indexPath
{
    BillingAddress billingAddress = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    NSString *firstKey;
    NSString *firstValue;
    NSString *secondValue;
    switch (billingAddress) {
        case Bill_Address1:
            firstKey = @"Address 1";
            firstValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.address1];
            secondValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipAddress1];
            break;
        case Bill_Address2:
            firstKey = @"Address 2";
            firstValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.address2];
            secondValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipAddress2];
            break;
        case Bill_City:
            firstKey = @"City";
            firstValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.city];
            secondValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipCity];

            break;
        case Bill_State:
            firstKey = @"State";
            firstValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.state];
            secondValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipCountry];

            break;
        case Bill_ZipCode:
            firstKey = @"ZipCode";
            firstValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.zipCode];
            secondValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipZipCode];

            break;
//        case Bill_Country:
//            firstKey = @"Country";
//            firstValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.country];
//            secondValue = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipCountry];
//
//            break;
        default:
            break;
    }
    MultipleKeyValuePair multipleKeyValuePair;
    multipleKeyValuePair.firstKey = (__bridge void *)(firstKey);
    multipleKeyValuePair.secondKey = (__bridge void *)(firstKey);
    multipleKeyValuePair.firstValue = (__bridge void *)(firstValue);
    multipleKeyValuePair.secondValue = (__bridge void *)(secondValue);
    return multipleKeyValuePair;
}




-(KeyValuePair)contactInformationAtRow:(NSIndexPath * )indexPath
{
    ContactSection contactSection = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    NSString *key;
    NSString *value;
    switch (contactSection) {
        case ContactNo:
        {
            key = @"Contact #";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.contactNo];
            break;
        }
        case Email:
            key = @"Email";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.email];
            break;
        case CustomerNo:
            key = @"Customer #";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.customerNo];
            break;
            
        default:
            break;
    }
    KeyValuePair keyvaluePair;
    keyvaluePair.key = (__bridge void *)(key);
    keyvaluePair.value = (__bridge void *)(value);
    return keyvaluePair;
}

-(void)setContactInformationAtRow:(NSIndexPath * )indexPath detail:(NSString *)contactDetail
{
    ContactSection contactSection = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    switch (contactSection) {
        case ContactNo:
        {
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmed = [contactDetail stringByTrimmingCharactersInSet:whitespace];
            if ([trimmed length] > 0)
            {
                self.rapidCustomerLoyalty.contactNo = [NSString stringWithFormat:@"%@",contactDetail];
            }
            else{
                 self.rapidCustomerLoyalty.contactNo = @"";
            }
            break;
        }
        case Email:
            self.rapidCustomerLoyalty.email = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case CustomerNo:
            self.rapidCustomerLoyalty.customerNo = [NSString stringWithFormat:@"%@",contactDetail];
        default:
            break;
    }
}


-(KeyValuePair)personalInformationAtRow:(NSIndexPath * )indexPath
{
    PersonalInformationSection personalInformationSection = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    NSString *key;
    NSString *value;
    switch (personalInformationSection) {
        case FirstName:
            key = @"First Name";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.firstName];
            break;
        case LastName:
            key = @"Last Name";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.lastName];
            break;
        case DrivingLicenceNo:
            key = @"DL Number";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.drivingLienceNo];
            break;
        case DOB:
            key = @"Date of Birth";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.dateOfBirth];
            break;
        case CreditLimit:
            key = @"Credit Limit";
            value = [NSString stringWithFormat:@"%.2f",self.rapidCustomerLoyalty.creditLimit.floatValue];
            break;
            
        default:
            break;
    }
    KeyValuePair keyvaluePair;
    keyvaluePair.key = (__bridge void *)(key);
    keyvaluePair.value = (__bridge void *)(value);
    return keyvaluePair;
}


-(void)setPersonalInformationAtRow:(NSIndexPath * )indexPath detail:(NSString *)contactDetail
{
    PersonalInformationSection personalInformationSection = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    switch (personalInformationSection) {
        case FirstName:
            self.rapidCustomerLoyalty.firstName = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case LastName:
            self.rapidCustomerLoyalty.lastName = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case DrivingLicenceNo:
            self.rapidCustomerLoyalty.drivingLienceNo = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case DOB:
            [self didShowDateAndTimePicker];
            break;
        case CreditLimit:
            self.rapidCustomerLoyalty.creditLimit = @(contactDetail.floatValue);
            break;
        default:
            break;
    }
}

-(KeyValuePair)billingInformationAtRow:(NSIndexPath * )indexPath
{
    BillingAddress billingAddress = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    NSString *key;
    NSString *value;
    switch (billingAddress) {
        case Bill_Address1:
            key = @"Address 1";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.address1];
            break;
        case Bill_Address2:
            key = @"Address 2";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.address2];
            break;
        case Bill_City:
            key = @"City";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.city];
            break;
        case Bill_State:
            key = @"State";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.state];
            break;
        case Bill_ZipCode:
            key = @"ZipCode";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.zipCode];
            break;
//        case Bill_Country:
//            key = @"Country";
//            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.country];
//            break;
        default:
            break;
    }
    KeyValuePair keyvaluePair;
    keyvaluePair.key = (__bridge void *)(key);
    keyvaluePair.value = (__bridge void *)(value);
    return keyvaluePair;
}

-(void)setBillingInformationAtRow:(NSIndexPath * )indexPath detail:(NSString *)contactDetail
{
    BillingAddress billingAddress = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    switch (billingAddress) {
        case Bill_Address1:
            self.rapidCustomerLoyalty.address1 = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case Bill_Address2:
            self.rapidCustomerLoyalty.address2 = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case Bill_City:
            self.rapidCustomerLoyalty.city = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case Bill_State:
            self.rapidCustomerLoyalty.state = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case Bill_ZipCode:
            self.rapidCustomerLoyalty.zipCode = @(contactDetail.integerValue);
            break;
//        case Bill_Country:
//            self.rapidCustomerLoyalty.country = [NSString stringWithFormat:@"%@",contactDetail];
//            break;
        default:
            break;
    }
//    if (rapidCustomerLoyalty.isSameAsAddesss == TRUE) {
//        rapidCustomerLoyalty.isSameAsAddesss = FALSE;
//        [self didSetSameAddressOfShippingAddress];
//    }
}
-(void)setShippingInformationAtRow:(NSIndexPath * )indexPath detail:(NSString *)contactDetail
{
    ShippingAddress shippingAddress = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    switch (shippingAddress) {
        case Shipping_Address1:
            self.rapidCustomerLoyalty.shipAddress1 = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case Shipping_Address2:
            self.rapidCustomerLoyalty.shipAddress2 = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case   Shipping_City:
            self.rapidCustomerLoyalty.shipCity = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case Shipping_State:
            self.rapidCustomerLoyalty.shipCountry = [NSString stringWithFormat:@"%@",contactDetail];
            break;
        case Shipping_ZipCode:
            self.rapidCustomerLoyalty.shipZipCode = @(contactDetail.integerValue);
            break;
              default:
            break;
    }
}


-(KeyValuePair)shippingBillingInformationAtRow:(NSIndexPath * )indexPath
{
    ShippingAddress shippingAddress = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    NSString *key;
    NSString *value;
    switch (shippingAddress) {
        case Shipping_Address1:
            key = @"Address 1";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipAddress1];
            break;
        case Shipping_Address2:
            key = @"Address 2";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipAddress2];
            break;
        case Shipping_City:
            key = @"City";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipCity];
            break;
        case Shipping_State:
            key = @"State";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.shipCountry];
            break;
            
        case Shipping_ZipCode:
            key = @"ZipCode";
            value = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyalty.zipCode];
            break;
      
        default:
            break;
    }
    KeyValuePair keyvaluePair;
    keyvaluePair.key = (__bridge void *)(key);
    keyvaluePair.value = (__bridge void *)(value);
    return keyvaluePair;
}

- (void)didUpdateCustomerValueAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)customerDetail
{
    AddCustomerSection addCustomerSection = [addCustomerSectionArray[indexPath.section] integerValue];
    switch (addCustomerSection) {
        case AddCustomerContactSection:
            [self setContactInformationAtRow:indexPath detail:customerDetail];
            break;
            
        case  AddCustomerPersonalInformationSection:
            [self setPersonalInformationAtRow:indexPath detail:customerDetail];
            break;
            
        case  AddCustomerBillingAddressSection:
            [self setBillingInformationAtRow:indexPath detail:customerDetail];
            break;
            
        case AddCustomerShippingAddressSection:
            break;
            
        case AddCustomerSameAsAddressSection:
            break;
        default:
            break;
    }

}
-(BOOL)didStartEditingInTextField:(UITextField *)textField withIndexPath:(NSIndexPath *)indexPath;
{
    //        AddCustomerSection addCustomerSection = [addCustomerSectionArray[indexPath.section] integerValue];
    //        if (addCustomerSection == AddCustomerPersonalInformationSection) {
    //            PersonalInformationSection personalInformationSection = [addCustomerRowArray[indexPath.section][indexPath.row] integerValue];
    //            if (personalInformationSection == DOB ) {
    //                [self didShowDateAndTimePicker];
    //                return NO;
    //            }
    //        }
    currentEditableTextField = textField;
    return YES;
}

-(void)didSetSameAddressOfShippingAddress
{
    self.rapidCustomerLoyalty.isSameAsAddesss = !self.rapidCustomerLoyalty.isSameAsAddesss;
    self.rapidCustomerLoyalty.shipAddress1 =  self.rapidCustomerLoyalty.address1;
    self.rapidCustomerLoyalty.shipCity = self.rapidCustomerLoyalty.city;
    self.rapidCustomerLoyalty.shipCountry = self.rapidCustomerLoyalty.state;
//    self.rapidCustomerLoyalty.shipCountry = self.rapidCustomerLoyalty.country;
    self.rapidCustomerLoyalty.shipZipCode = self.rapidCustomerLoyalty.zipCode;
    [_addCustomerTableView reloadData];
}

-(void)autoGenerateCustomerNumber{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyMMddHHmmss";
    NSString *strCustomerNumber = [formatter stringFromDate:[NSDate date]];
    self.rapidCustomerLoyalty.customerNo = strCustomerNumber;
    [_addCustomerTableView reloadData];
}

- (void)didUpdateCustomerAddressTextFieldAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)customerDetail inTextField:(UITextField *)textField
{
    if (textField.tag == BillAddressFirstTextFieldValue_Tag)
    {
        [self setBillingInformationAtRow:indexPath detail:customerDetail];
    }
    else if (textField.tag == BillAddressSecondTextFieldValue_Tag)
    {
        [self setShippingInformationAtRow:indexPath detail:customerDetail];
    }
}
-(void)didStartEditingInAddressTextField:(UITextField *)textField withIndexPath:(NSIndexPath *)indexpath
{
    currentEditableTextField = textField;
}


- (void)didUpdateCustomerAddressTextViewAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)customerDetail inTextView:(UITextView *)textView
{
    if (textView.tag == BillAddressTextView_Tag) {
        self.rapidCustomerLoyalty.address1 = [NSString stringWithFormat:@"%@",customerDetail];
        self.rapidCustomerLoyalty.address2 = [NSString stringWithFormat:@"%@",customerDetail];

    }
    else if (textView.tag == ShippingAddressTextView_Tag)
    {
        self.rapidCustomerLoyalty.shipAddress1 = [NSString stringWithFormat:@"%@",customerDetail];
        self.rapidCustomerLoyalty.shipAddress2 = [NSString stringWithFormat:@"%@",customerDetail];

    }
    [_addCustomerTableView reloadData];
}
-(void)didStartEditingInAddressTextView:(UITextView *)textView withIndexPath:(NSIndexPath *)indexpath
{
    currentEditableTextView = textView;
}

-(void)didShowDateAndTimePicker
{
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 380, 430)];
    _datePickerVC.view.center = _datePickerView.center;
    _datePickerVC.view.frame = CGRectZero;
    _datePickerView.frame = CGRectZero;
    _datePickerView.hidden = NO;
    _datePickerVC.view.hidden  = NO;
    [UIView animateWithDuration:1.0 animations:^{
        _datePickerView.bounds = self.view.bounds;
        _datePickerView.center = self.view.center;
        _datePickerVC.view.bounds = tempView.bounds;
    } completion:^(BOOL finished) {
    }];
    
    
}
-(void)didSelectDate:(NSString *)selectedDate
{
    [UIView animateWithDuration:1.0 animations:^{
        _datePickerView.hidden  = YES;
      //  _datePickerVC.view.bounds  = CGRectZero;
    } completion:^(BOOL finished) {
        _datePickerVC.view.hidden  = YES;
    }];
    self.rapidCustomerLoyalty.dateOfBirth = selectedDate;
    [_addCustomerTableView reloadData];
}

-(void)didCancelDatePicker
{
    [UIView animateWithDuration:1.0 animations:^{
        _datePickerView.hidden  = YES;
       // _datePickerVC.view.bounds  = CGRectZero;
    } completion:^(BOOL finished) {
        _datePickerVC.view.hidden  = YES;
    }];
    [_addCustomerTableView reloadData];
}

-(void)didClearDatePicker
{
    [UIView animateWithDuration:1.0 animations:^{
        _datePickerView.hidden  = YES;
       // _datePickerVC.view.bounds  = CGRectZero;
    } completion:^(BOOL finished) {
        _datePickerVC.view.hidden  = YES;
    }];
    self.rapidCustomerLoyalty.dateOfBirth = @"";
    [_addCustomerTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}



// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)notification
{
    return;
    NSDictionary* info = notification.userInfo;
    CGSize kbSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect rect = _addCustomerTableView.frame;
    rect.size.height = _addCustomerTableView.frame.size.height - kbSize.height;
    _addCustomerTableView.frame = rect;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    return;
    
    NSDictionary* info = notification.userInfo;
    CGSize kbSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect rect = _addCustomerTableView.frame;
    rect.size.height = _addCustomerTableView.frame.size.height + kbSize.height;
    _addCustomerTableView.frame = rect;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
