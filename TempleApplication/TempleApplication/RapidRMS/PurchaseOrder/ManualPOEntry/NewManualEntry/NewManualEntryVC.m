//
//  NewManualEntryVC.m
//  RapidRMS
//
//  Created by Siya on 12/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "NewManualEntryVC.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "NewManualItemVC.h"
#import "RimSupplierPagePO.h"
#import "RmsDbController.h"
#import "UpdateManager.h"
#import "ManualPOSession+Dictionary.h"
#import "ManualEntryRecevieItemList.h"
#import "RimsController.h"
#import "MEReceivingDateVC.h"

@interface NewManualEntryVC () <RimSupplierPagePODelegate , MEReceivingDateVCDelegate>
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet TPKeyboardAvoidingScrollView *scrollview;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UIView *viewBG;
@property (nonatomic, weak) IBOutlet UITextField *txtinvoiceno;
@property (nonatomic, weak) IBOutlet UILabel *lblReceivingDate;
@property (nonatomic, weak) IBOutlet UILabel *lblSupplier;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) ManualPOSession *tempSession;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) RapidWebServiceConnection *addManualEntryWC;
@property (nonatomic, strong) MEReceivingDateVC *meReceivingDateVC;

@property (nonatomic, strong) NSMutableArray *arrSelectedSupplier;
@property (nonatomic, strong) NSString *strSupplierID;

@end

@implementation NewManualEntryVC
@synthesize arrSelectedSupplier;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _tempSession=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.addManualEntryWC = [[RapidWebServiceConnection alloc]init];
    self.scrollview.contentSize=CGSizeMake(self.scrollview.frame.size.width, self.scrollview.frame.size.height+50);
    self.arrSelectedSupplier=[[NSMutableArray alloc]init];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
  //  _viewBG.layer.cornerRadius = 10.0;
    _viewBG.layer.borderWidth = 1.0;
    _viewBG.layer.borderColor = [UIColor colorWithRed:197.0/255.0 green:197.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)datebuttonClick:(id)sender{
    [_txtinvoiceno resignFirstResponder];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
    _meReceivingDateVC = [storyBoard instantiateViewControllerWithIdentifier:@"MEReceivingDateVC"];
    _meReceivingDateVC.meReceivingDateVCDelegate = self;
    [self.view addSubview:_meReceivingDateVC.view];
   // [self.view bringSubviewToFront:_meReceivingDateVC.view];
}

-(void) didSelectDate:(NSString *)selectedDate
{
    self.lblReceivingDate.text = selectedDate;
    [_meReceivingDateVC.view removeFromSuperview];
}

-(void)didCloseReceivingDate
{
    [_meReceivingDateVC.view removeFromSuperview];
}

-(IBAction)supplierClick:(id)sender{
    RimSupplierPagePO * objSupplier;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        objSupplier = [[RimSupplierPagePO alloc] initWithNibName:@"RimSupplierPagePO" bundle:nil];
    }
    else {
        objSupplier = [[RimSupplierPagePO alloc] initWithNibName:@"RimSupplierPagePO_iPad" bundle:nil];
    }
    objSupplier.checkedSupplier = [arrSelectedSupplier mutableCopy ];
    objSupplier.callingFunction=@"NewManualEntry";
    objSupplier.rimSupplierPagePODelegate = self;
    objSupplier.strItemcode=@"1";

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController pushViewController:objSupplier animated:YES];
    }
    else{
        [self.navigationController pushViewController:objSupplier animated:YES];
    }
}
- (void)didChangeSupplierPagePO:(NSMutableArray *)SupplierListArray withOtherData:(NSDictionary *) dictInfo {
    
    self.arrSelectedSupplier=[SupplierListArray mutableCopy];
    if (dictInfo) {
        self.lblSupplier.text= [dictInfo valueForKey:@"SupplierName"];
        self.strSupplierID=[dictInfo valueForKey:@"Id"];
    }
}
#pragma mark -
#pragma mark Required Method
-(BOOL)checkRequireFields{
    
    if([_lblReceivingDate.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Enter date" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return FALSE;
    }
    else if([_txtinvoiceno.text isEqualToString:@""]){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Manual Entry" message:@"Enter invoice no" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return FALSE;
    }
    else{
        return TRUE;
    }
}

-(IBAction)nextClick:(id)sender{
    [_txtinvoiceno resignFirstResponder];
    
    if([self checkRequireFields]){
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        [param setValue:@"" forKey:@"Remarks"];
        [param setValue:self.txtinvoiceno.text forKey:@"InvoiceNo"];
        [param setValue:(self.rmsDbController.globalDict)[@"RegisterId"] forKey:@"CreatedBy"];
        
        if(self.strSupplierID.intValue>0){
            param[@"SupplierId"] = self.strSupplierID;
        }
        else{
            [param setValue:@0 forKey:@"SupplierId"];
            
        }
        NSDate *currentDate = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *currentDateValue = [formatter stringFromDate:currentDate];
        [param setValue:currentDateValue forKey:@"LocalDate"];
        
        NSString *strDate = [self getStringFormate:self.lblReceivingDate.text fromFormate:@"MMMM dd, yyyy" toFormate:@"MM/dd/yyyy hh:mm a"];
        [param setValue:strDate forKeyPath:@"ReceiveDate"];
        [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        NSMutableDictionary *manualEntry = [[NSMutableDictionary alloc] init ];
        [manualEntry setValue:param forKey:@"objManualEntry"];
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self addManualEntryResponse:response error:error];
            });
        };
        self.addManualEntryWC = [self.addManualEntryWC initWithRequest:KURL actionName:WSM_ADD_MANUAL_ENTRY params:manualEntry completionHandler:completionHandler];
    }
}

- (void)addManualEntryResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSString *strID = response[@"Data"];
                
                _tempSession  = [self insertPOWithDictionary:strID];
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
                ManualEntryRecevieItemList *newmanualItemList = [storyBoard instantiateViewControllerWithIdentifier:@"ManualEntryRecevieItemList"];
                newmanualItemList.strManualPoID=strID;
                newmanualItemList.isHistory = NO;
                newmanualItemList.strInvoiceNo=self.txtinvoiceno.text;
                newmanualItemList.strTitle=@"";

                newmanualItemList.posession=_tempSession;
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                if(self.strSupplierID.intValue>0){
                    dict[@"Suppid"] = self.strSupplierID;
                }
                
                dict[@"SuppName"] = self.lblSupplier.text;
                dict[@"ReceiveDate"] = self.lblReceivingDate.text;
                newmanualItemList.dictSupplier =dict;
                [self.navigationController pushViewController:newmanualItemList animated:YES];
                
                self.txtinvoiceno.text=@"";
              //  self.txtRemark.text=@"";
                self.lblReceivingDate.text=@"";
                self.lblSupplier.text=@"";
                self.strSupplierID=@"";
            }
        }
    }
}

-(ManualPOSession *)insertPOWithDictionary:(NSString *)strPOID{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict[@"manualPoId"] = strPOID;
    dict[@"invoiceNumber"] = self.txtinvoiceno.text;
    dict[@"poRemark"] = @"";
    NSDate *localDate = [self getDateFromString:self.lblReceivingDate.text];
    dict[@"receivedDate"] = localDate;
    if(self.strSupplierID.intValue>0){
        dict[@"supplierId"] = self.strSupplierID;
    }
    else{
       dict[@"supplierId"] = @0;
    }
    _tempSession  = [self.updateManager insertManualPOWithDictionary:dict];
    return _tempSession;
}

-(NSDate *)getDateFromString:(NSString *)strDate{
    
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}

-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    return result;
}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.txtinvoiceno) {
        self.scrollview.contentOffset = CGPointMake(0.0, 0.0);
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

@end
