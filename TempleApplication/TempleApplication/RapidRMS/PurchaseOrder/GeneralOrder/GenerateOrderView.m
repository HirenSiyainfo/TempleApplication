//
//  PurchaseOrderView.m
//  I-RMS
//
//  Created by Siya Infotech on 03/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "GenerateOrderView.h"
#import "DepartmentMultiple.h"
#import "RimSupplierPagePO.h"
#import "RimPopOverVC.h"
#import "DepartmentPopover.h"
#import "GenerateOrderPoCell.h"
#import "RmsDbController.h"
//#import "POmenuListVC_iPhone.h"
#import "Item+Dictionary.h"
#import "EmailFromViewController.h"
#import "POMultipleItemSelectionVC.h"
#import "SideMenuPOViewController.h"
#import "POmenuListVC.h"
#import "PurchaseOrderFilterVC.h"
#import "OpenListVC.h"
#import "GroupSelectionVC.h"
#import "CameraScanVC.h"
#import "GenerateOrderTypePopUpVC.h"
#import "ItemInfoVC.h"
#import "TagSuggestionVC.h"
#import "MPTagList.h"


#define kCCEncrypt = 0
#define kCCDecrypt

@interface GenerateOrderView ()<CameraScanVCDelegate,GenerateOrderTypePopUpVCDelegate,AddDepartmentMultipleDelegate,RimSupplierPagePODelegate,TagSuggestionDelegate,GroupSelectionVCDelegate,POMultipleItemSelectionVCDelegate,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate , EmailFromViewControllerDelegate>
{
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
    
    RimSupplierPagePO *objSupplier;
    DepartmentMultiple *objDeptPop;
    GenerateOrderTypePopUpVC *generateOrderTypePopUpVC;
    PurchaseOrderFilterListDetail *objPList;
    ManualFilterOptionViewController *objManualOption;
    MPTagList *tagList;
    RimPopOverVC * popoverController;
    TagSuggestionVC *taglistPopupvc;
    EmailFromViewController *emailFromViewController;
    Configuration *configuration;

    
    NSString *searchText;
    NSMutableString *status;
    
    CGPoint infoButtonPosition;

    BOOL isPoUpdate;
    
    UITextField *activeField;
    UITextField *currentEditedTextField;
    
    UIPopoverPresentationController *generateOrderTypePopoverController;
    UIPopoverPresentationController *popOverController;
    UIPopoverPresentationController *infopopoverController;
    UIPopoverPresentationController *emailPdfPopOverController;

    UIViewController *tempviewController;
    UIViewController *itemInformationViewController;
    UIViewController *orderInfoViewController;
    UIViewController *emailPdfViewController;
    
    UISwitch *onOffSwitch;
    NSString * selectedTag;

    UIView *Deptsupplierview;
    UIView *supplierview;
    UIView *groupView;
    
    UITableView *tblGrouplist;
    UITableView *tblDeptsupplierlist;
    UITableView *tblsupplierlist;
    
    NSMutableArray *arrdepartmentList;
    NSMutableArray *arrsupplierlist;
    NSMutableArray *generateOrderTypeArray;
    NSMutableArray *arrayTagListToDisplay;

}

@property (nonatomic, weak) IBOutlet UITableView *tblOrderType;
@property (nonatomic, weak) IBOutlet UITableView *tblGenerateOrder;
@property (nonatomic, weak) IBOutlet UITableView *tblGenerateOdrData;

@property (nonatomic, weak) IBOutlet UIDatePicker *datePickerView;

@property (nonatomic, weak) IBOutlet UITextField *txtMinStock;
@property (nonatomic, weak) IBOutlet UITextField *txtMainBarcode;
@property (nonatomic, weak) IBOutlet UITextField *txtTagName;
@property (nonatomic, weak) IBOutlet UITextField *txtOrderNo;
@property (nonatomic, weak) IBOutlet UITextField *txtPOTitle;

@property (nonatomic, weak) IBOutlet UIView *uvGenerateOdrData;
@property (nonatomic, weak) IBOutlet UIView *uvSelectSupplier;
@property (nonatomic, weak) IBOutlet UIView *uvSelectDepartment;
@property (nonatomic, weak) IBOutlet UIView *uvOrderTypes;
@property (nonatomic, weak) IBOutlet UIView *uvHiddenDates;
@property (nonatomic, weak) IBOutlet UIView *uvNextToDates;
@property (nonatomic, weak) IBOutlet UIView *uvDatePicker;
@property (nonatomic, weak) IBOutlet UIView *uvItemInformation;
@property (nonatomic, weak) IBOutlet UIView *uvGenerateOrderInfo;
@property (nonatomic, weak) IBOutlet UIView *uvItemInfoTapped;
@property (nonatomic, weak) IBOutlet UIView *emailPdfView;
@property (nonatomic, weak) IBOutlet UIView *viewFooter;
@property (nonatomic, weak) IBOutlet UIView *viewGenerateOrderContainer;

@property (nonatomic, weak) IBOutlet UILabel *lblSelectedSupplier;
@property (nonatomic, weak) IBOutlet UILabel *lblSelectedDepartment;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpDepartment;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpSupplier;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpTags;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpFromDate;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpToDate;
@property (nonatomic, weak) IBOutlet UILabel *lblPopUpTimeDuration;
@property (nonatomic, weak) IBOutlet UILabel *toolbarDeliverylabel;
@property (nonatomic, weak) IBOutlet UILabel *lblAutoGenPO;
@property (nonatomic, weak) IBOutlet UILabel *lblPODate;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalItem;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalReOrderQTY;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalCost;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedCost;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedPrice;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedSoldDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTappedWeek;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped1Month;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped6Month;
@property (nonatomic, weak) IBOutlet UILabel *lblTapped1Year;
@property (nonatomic, weak) IBOutlet UILabel *lblOrderType;

@property (nonatomic, weak) IBOutlet UIButton *btnTotalItemInfo;
@property (nonatomic, weak) IBOutlet UIButton *btnGenereteOdrinfo;
@property (nonatomic, weak) IBOutlet UIButton *toolbarDelivery;
@property (nonatomic, weak) IBOutlet UIButton *pdfEmailBtn;
@property (nonatomic, weak) IBOutlet UIButton *btnFilter;
@property (nonatomic, weak) IBOutlet UIButton *btnIsMinOdr;
@property (nonatomic, weak) IBOutlet UIButton *btnSuppClicked;
@property (nonatomic, weak) IBOutlet UIButton *btnDepatClicked;
@property (nonatomic, weak) IBOutlet UIButton *btnDropDown;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) OpenListVC *objOpenListIpad;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) UpdateManager *updateManagerGenerateOrder;

@property (nonatomic, strong) RapidWebServiceConnection *activeItemWSC;
@property (nonatomic, strong) RapidWebServiceConnection *generatePurchaseOrderDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *insertOpenPoManualWC;
@property (nonatomic, strong) RapidWebServiceConnection *insertPoDetailNewWC;
@property (nonatomic, strong) RapidWebServiceConnection *updatePoDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *insertPoDetailWC;
@property (nonatomic, strong) RapidWebServiceConnection *pOItemInfoWC;
@property (nonatomic, strong) RapidWebServiceConnection *mgmtItemInsertWC;
@property (nonatomic, strong) RapidWebServiceConnection *getPurchaseBackOrderListWC;
@property (nonatomic, strong) RapidWebServiceConnection *pendingDeliveryDataWC;

@property (nonatomic, strong) NSString *tagString;
@property (nonatomic, strong) NSString *strFromDate;
@property (nonatomic, strong) NSString *strToDate;
@property (nonatomic, strong) NSString *strOrderTyp;
@property (nonatomic, strong) NSString *strPredicateDept;
@property (nonatomic, strong) NSString *strPredicateSupp;
@property (nonatomic, strong) NSString *isMinStock;
@property (nonatomic, strong) NSString *supplierString;
@property (nonatomic, strong) NSString *strGroupIds;
@property (nonatomic, strong) NSString *departmentString;
@property (nonatomic, strong) NSString *strNotificationName;
@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) NSMutableArray *arrGenerateOrderDataGlobal;
@property (nonatomic, strong) NSMutableArray *arrSelectedSupplier;
@property (nonatomic, strong) NSMutableArray *arrSelectedDepartment;
@property (nonatomic, strong) NSMutableArray *arrSelectedGroup;
@property (nonatomic, strong) NSMutableArray *arrGenerateOrderData;
@property (nonatomic, strong) NSMutableArray *arrTempSelectedData;
@property (nonatomic, strong) NSMutableArray *arrCheckedRecord;
@property (nonatomic, strong) NSMutableArray *arrayTagList;

@property (nonatomic, strong) NSMutableDictionary *emailTempDictionary;

@property (nonatomic, strong) UIDocumentInteractionController *controller;

@property (nonatomic, assign) BOOL boolInsertOpenOrder;
@property (nonatomic, assign) BOOL suspendDisplayInfo;
@property (nonatomic, strong) UIPopoverController * tagSuggestionController;
@property (nonatomic, strong) NSString *strSearchTagText;


@end

@implementation GenerateOrderView


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    emailPdfViewController = [[UIViewController alloc]init];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.generatePurchaseOrderDetailWC = [[RapidWebServiceConnection alloc] init];
    self.insertOpenPoManualWC = [[RapidWebServiceConnection alloc] init];
    self.insertPoDetailNewWC = [[RapidWebServiceConnection alloc] init];
    self.updatePoDetailWC = [[RapidWebServiceConnection alloc] init];
    self.insertPoDetailWC = [[RapidWebServiceConnection alloc] init];
    self.pOItemInfoWC = [[RapidWebServiceConnection alloc] init];
    self.mgmtItemInsertWC = [[RapidWebServiceConnection alloc] init];
    self.getPurchaseBackOrderListWC = [[RapidWebServiceConnection alloc] init];
    self.pendingDeliveryDataWC = [[RapidWebServiceConnection alloc] init];
    self.updateManagerGenerateOrder = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.activeItemWSC = [[RapidWebServiceConnection alloc] init];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    generateOrderTypeArray = [[NSMutableArray alloc]initWithObjects:@"None",@"Daily",@"Weekly",@"Monthly",@"Quarterly",@"Yearly",@"DateWise", nil];
   
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [_tblOrderType reloadData];
    }
    
    _lblOrderType.text = generateOrderTypeArray.firstObject;
    
    self.arrCheckedRecord=[[NSMutableArray alloc] init];
    self.arrayTagList = [[NSMutableArray alloc] init];
    self.isMinStock = @"No";
    
    self.title=@"Generate Order";
    selectedTag=@"";

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        onOffSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(252, 7, 79, 27)];
    }
    else{
        onOffSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(915, 7, 79, 27)];
    }
    [onOffSwitch setOn:NO];
    _uvOrderTypes.hidden = YES;
    _uvHiddenDates.hidden = YES;
    _uvDatePicker.hidden = YES;
    
    
    self.uvGenerateOdrData.hidden = YES;
    
    tempviewController = [[UIViewController alloc] init];
    itemInformationViewController = [[UIViewController alloc] init];
    orderInfoViewController = [[UIViewController alloc] init];
    self.arrGenerateOrderData = [[NSMutableArray alloc] init];
    
    //Dept and Supplier
    Deptsupplierview = [[UIView alloc] init];
    tblDeptsupplierlist = [[UITableView alloc] init ];
    
    //Supplier
    supplierview = [[UIView alloc] init];
    tblsupplierlist = [[UITableView alloc] init ];
    
    //Group
    groupView = [[UIView alloc] init];
    tblGrouplist = [[UITableView alloc] init ];
    self.strGroupIds = [[NSString alloc] init];

#ifdef LINEAPRO_SUPPORTED
    // Linea Barcode device connection
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
#endif
    self.suspendDisplayInfo=false;
    status=[[NSMutableString alloc] init];
    
    if([self.rimsController.scannerButtonCalled isEqualToString:@""])
    {
        self.rimsController.scannerButtonCalled=@"GenerateOdr";
    }
    
    isPoUpdate = FALSE;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        tagList = [[MPTagList alloc] initWithFrame:CGRectMake(105, 40, 210, 40)];
    }
    else
    {
        tagList = [[MPTagList alloc] initWithFrame:CGRectMake(50, 168, 420, 50)];
    }
    
    tagList.backgroundColor = [UIColor clearColor];
    [tagList setAutomaticResize:YES];
    [tagList setTags:self.arrayTagList];
    tagList.tagDelegate = self;
    
    if(self.arrUpdatePoData.count > 0)
    {
        isPoUpdate = TRUE;
        
        if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
        {
            [_txtMainBarcode becomeFirstResponder];
        }
        else
        {
            [_txtMainBarcode resignFirstResponder];
        }
        
        _txtOrderNo.text = self.arrUpdatePoData.firstObject[@"OrderNo"];
        _txtPOTitle.text = self.arrUpdatePoData.firstObject[@"POTitle"];
        
        _lblAutoGenPO.text = [NSString stringWithFormat:@"PO # : %@", self.arrUpdatePoData.firstObject[@"PO_No"]];
        _txtPOTitle.hidden=YES;
        self.supplierString = self.arrUpdatePoData.firstObject[@"SupplierIds"];
        self.departmentString = self.arrUpdatePoData.firstObject[@"DeptIds"];
        self.tagString = self.arrUpdatePoData.firstObject[@"Tags"];
        _txtMinStock.text = [NSString stringWithFormat:@"%ld",(long)[self.arrUpdatePoData.firstObject[@"MinStock"] integerValue]];
        _lblOrderType.text = self.arrUpdatePoData.firstObject[@"TimeDuration"];
        
        NSString *createdDate = self.arrUpdatePoData.firstObject[@"CreatedDate"];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        
        NSDate *convertedDate = [formatter dateFromString:createdDate];
        NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init];
        formatter2.dateFormat = @"MMMM,dd yyyy hh:mm a";
        NSString *dispCreatedDate = [formatter2 stringFromDate:convertedDate];
        _lblPODate.text = dispCreatedDate;
        
        self.arrGenerateOrderData = self.arrUpdatePoData.firstObject[@"lstItem"];
        
        self.arrGenerateOrderDataGlobal=[self.arrUpdatePoData.firstObject[@"lstItem"]mutableCopy];
        
        
        self.uvGenerateOdrData.hidden = NO;
        [self.tblGenerateOdrData reloadData];
        [self.tblGenerateOdrData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    // Filter Button Hide in Generate Order,Open Order
    if(self.pOmenuListVCDelegate.currentSelectedMenu != 1)
    {
        [_btnFilter setHidden:YES];
    }
    
    NSString  *generateorderCell;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        generateorderCell = @"GenerateOrderPoCell";
    }
    else{
        generateorderCell = @"GenerateOrderPoCell_iPad";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:generateorderCell bundle:nil];
    [self.tblGenerateOdrData registerNib:mixGenerateirderNib forCellReuseIdentifier:@"Generateorderpocell"];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        if(screenBounds.size.height == 568)
        {
            
        }
        else
        { self.tblGenerateOdrData.frame=CGRectMake(self.tblGenerateOdrData.frame.origin.x, self.tblGenerateOdrData.frame.origin.y, self.tblGenerateOdrData.frame.size.width, self.tblGenerateOdrData.frame.size.height-90);
            
            _viewFooter.frame=CGRectMake(_viewFooter.frame.origin.x, _viewFooter.frame.origin.y-90, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
        }
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    // {
    self.navigationController.navigationBarHidden = YES;
    // }
//    [self._RimsController.objPOMenuList.btnBackButtonClick removeTarget:nil
//                                                                action:NULL
//                                                      forControlEvents:UIControlEventAllEvents];
//    [self._RimsController.objPOMenuList.btnBackButtonClick addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.rimsController.scannerButtonCalled=@"GenerateOdr";
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _uvOrderTypes.hidden = YES;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        
        if((textField != _txtMainBarcode) && (textField != _txtOrderNo) && (textField != _txtPOTitle) && (textField != _txtMinStock))
        {
            activeField = textField;
            currentEditedTextField = textField;
            
            UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            numberToolbar.barStyle = UIBarStyleBlackTranslucent;
            numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton)]];
            textField.inputAccessoryView = numberToolbar;
        }
    }
    else
    {
        if(!self.uvGenerateOdrData.hidden)
        {
            if((textField != _txtMainBarcode) && (textField != _txtOrderNo) && (textField != _txtPOTitle) && (textField != _txtMinStock) && (textField != _txtTagName))
            {
                activeField = textField;
                [currentEditedTextField resignFirstResponder];
                [_txtPOTitle resignFirstResponder];
                [_txtOrderNo resignFirstResponder];
                [_txtMainBarcode resignFirstResponder];
                
                currentEditedTextField = textField;
                
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChangeReOrder:) name:@"ItemReOrder" object:nil];
//                
                
                if(popOverController)
                {
                    [popoverController dismissViewControllerAnimated:YES completion:nil];
                    popOverController=nil;
                }
                
                popoverController = [[RimPopOverVC alloc] initWithNibName:@"RimPopOverVC" bundle:nil];
                popoverController.notificationName = @"ItemReOrder";
                
                // Present the view controller using the popover style.
                popoverController.modalPresentationStyle = UIModalPresentationPopover;
                [self presentViewController:popoverController animated:YES completion:nil];
                
                // Get the popover presentation controller and configure it.
                popOverController = [popoverController popoverPresentationController];
                popOverController.delegate = self;
                popoverController.preferredContentSize = CGSizeMake(300, 456);
                popOverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                popOverController.sourceView = self.view;
                popOverController.sourceRect = [self.view convertRect:textField.frame fromView:textField.superview];
                
                
                
                
                __weak typeof(self) weakSelf = self;
                UITextField *__weak weakcurrentEditedTextField = currentEditedTextField;
                UITextField *__weak weakactiveField = activeField;
                RimPopOverVC *__weak weakpopOverController = popoverController;
                
                popoverController.didEnterAmountBlock = ^(NSString * strPrice, NSDictionary * userInfo){
                    if(strPrice.length>0 && strPrice.integerValue != 0){
                        weakcurrentEditedTextField.text = [strPrice stringByReplacingOccurrencesOfString:@"$" withString:@""];
                        weakcurrentEditedTextField.text = [NSString stringWithFormat:@"%d",strPrice.intValue];
                        NSMutableDictionary *dict = (weakSelf.arrGenerateOrderData)[weakactiveField.tag];
                        dict[@"ReOrder"] = weakcurrentEditedTextField.text;
                        (weakSelf.arrGenerateOrderData)[weakactiveField.tag] = dict;

                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                        
                    }
                    else if ([strPrice isEqualToString:@""])
                    {
                        [weakpopOverController dismissViewControllerAnimated:YES completion:nil];
                        popOverController = nil;
                        
                    }
                };
                
                return NO;
            }
        }
    }
    return YES;
}

- (void)doneButton
{
//    if(currentEditedTextField.text.length == 0) {
//        
//        NSMutableDictionary *dict = [self.arrGenerateOrderData objectAtIndex:activeField.tag];
//        [dict setObject:@"0" forKey:@"ReOrder"];
//        [self.arrGenerateOrderData replaceObjectAtIndex:activeField.tag withObject:dict];
//        currentEditedTextField.text = @"0";
//    }
//    else {
//        NSMutableDictionary *dict = [self.arrGenerateOrderData objectAtIndex:activeField.tag];
//        [dict setObject:currentEditedTextField.text forKey:@"ReOrder"];
//        [self.arrGenerateOrderData replaceObjectAtIndex:activeField.tag withObject:dict];
//    }
    [currentEditedTextField resignFirstResponder];
    [activeField resignFirstResponder];
}

//-(void)itemChangeReOrder:(NSNotification *)notification
//{
//    if (notification.object == nil)
//    {
//        [popoverController dismissViewControllerAnimated:YES completion:nil];
//        popOverController = nil;
//    }
//    else
//    {
//        currentEditedTextField.text = [notification.object stringByReplacingOccurrencesOfString:@"$" withString:@""];
//        NSMutableDictionary *dict = (self.arrGenerateOrderData)[activeField.tag];
//        dict[@"ReOrder"] = currentEditedTextField.text;
//        (self.arrGenerateOrderData)[activeField.tag] = dict;
//        [popoverController dismissViewControllerAnimated:YES completion:nil];
//        popOverController = nil;
//    }
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ItemReOrder" object:nil];
//}
-(NSInteger )getTagCounts{
    // Create and configure a fetch request with the GroupMaster entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SizeMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    if (self.strSearchTagText != nil && ![self.strSearchTagText isEqualToString:@""]) {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"sizeName CONTAINS[cd] %@", self.strSearchTagText];
        fetchRequest.predicate = predicate;
    }
    
    NSInteger resultSet = [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    return resultSet;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField==_txtOrderNo)
    {
        if (_txtOrderNo.text.length >= 25 && range.length == 0)
        {
            return NO; // return NO to not change text
        }
    }
    else if (textField.tag==ItemtextFieldsTagItemTag) {
        NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (textField.text.length == 1 && [string isEqualToString:@""]) {
            self.strSearchTagText = @"";
        }
        else if(searchString.length > 0)
        {
            self.strSearchTagText = searchString;
        }
        if ((self.tagSuggestionController).popoverVisible)
        {
            if([self getTagCounts]>0)
            {
                taglistPopupvc.strSearchTagText=searchString;
                [taglistPopupvc reloadTableWithSearchItem];
            }
            else{
                [self.tagSuggestionController dismissPopoverAnimated:YES];
                self.tagSuggestionController = nil;
            }
        }
        else{
            UITextField * tempText=[[UITextField alloc]initWithFrame:textField.frame];
            tempText.text=searchString;
            if(searchString.length>0){
                [self tagSelectView:textField];
            }
        }
        return YES;
    }

    return YES;
}
-(void)tagSelectView:(UITextField *)textField{
    if([self getTagCounts]>0 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        taglistPopupvc = [storyBoard instantiateViewControllerWithIdentifier:@"TagSuggestionVC"];
        taglistPopupvc.tagSuggestionDelegate=self;
        taglistPopupvc.strSearchTagText=textField.text;
        [self.tagSuggestionController dismissPopoverAnimated:YES];
        self.tagSuggestionController = nil;
        
        self.tagSuggestionController = [[UIPopoverController alloc] initWithContentViewController:taglistPopupvc];
        self.tagSuggestionController.delegate = self;
        (self.tagSuggestionController).popoverContentSize = CGSizeMake(400, 200);
        CGRect popoverRect = [self.view convertRect:textField.frame fromView:textField.superview];
        [self.tagSuggestionController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}

-(void)didSelectTagfromList:(NSString *)strSelectedTag{
    selectedTag=strSelectedTag;
    [self.tagSuggestionController dismissPopoverAnimated:YES];
    self.tagSuggestionController = nil;
    [self.tblGenerateOrder reloadData];
}

-(IBAction)searchBarcode:(id)sender{
    [self textFieldShouldReturn:_txtMainBarcode];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if((textField == _txtMainBarcode) && _txtMainBarcode.text.length > 0)
    {
        [self searchScannedBarcodeGenerate];
//        _txtMainBarcode.text = @"";
        if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
        {
            [_txtMainBarcode becomeFirstResponder];
        }
        else
        {
            [_txtMainBarcode resignFirstResponder];
        }
        return YES;
    }
    else if(textField==_txtTagName) // create tag
    {
        if(_txtTagName.text.length>0){
            
            if (![self.arrayTagList containsObject:_txtTagName.text])
            {
                [self.arrayTagList addObject:[NSString stringWithFormat:@"%@",_txtTagName.text]];
                [tagList setTags:self.arrayTagList];
                [_tblGenerateOrder reloadData];
            }
            else
            {
            }
            _txtTagName.text=@"";
            [textField resignFirstResponder];
        }
        [textField resignFirstResponder];
        return YES;
    }
    else
    {
        [textField resignFirstResponder];
        return YES;
    }
}

- (void)selectedTag:(NSString *)tagName withTabView:(id) tagView
{
    [self.arrayTagList removeObjectAtIndex:((MPTagView *)tagView).tag];
    [tagList setTags:self.arrayTagList];
    [_tblGenerateOrder reloadData];
}

#pragma mark - Button Clicked Methods

-(IBAction)btnOrderTypeClick:(id)sender
{
    [Appsee addEvent:kPOGenerateOrderSelectDate];
    [self.rmsDbController playButtonSound];
    _uvOrderTypes.hidden=NO;
    _tblGenerateOrder.scrollEnabled=NO;
    [self.view bringSubviewToFront:_uvOrderTypes];
}

-(IBAction)btnIsMinStockClick:(id)sender
{
    UISwitch *switchTemp = (UISwitch *)sender;
    NSDictionary *minStockDict = @{kPOGenerateOrderMinimumStokeKey : @(switchTemp.on)};
    [Appsee addEvent:kPOGenerateOrderMinimumStoke withProperties:minStockDict];
    [self.rmsDbController playButtonSound];
    //    btn_Checked.selected = !btn_Checked.selected;
    if(switchTemp.isOn==NO)
    {
        [_btnIsMinOdr setImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
        _btnIsMinOdr.selected = NO;
        self.isMinStock = @"No";
    }
    else
    {
        [_btnIsMinOdr setImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];
        _btnIsMinOdr.selected = YES;
        self.isMinStock = @"Yes";
    }
}

-(IBAction)btnFromDateClick:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]){
        UITableViewCell *cell = (UITableViewCell *)sender;
        _tblGenerateOrder.scrollEnabled=NO;
        [self.rmsDbController playButtonSound];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            _uvDatePicker.frame = CGRectMake(70, cell.frame.origin.y+106, _uvDatePicker.frame.size.width, _uvDatePicker.frame.size.height);
        }
        else{
            _uvDatePicker.frame = CGRectMake(754, cell.frame.origin.y+32, _uvDatePicker.frame.size.width, _uvDatePicker.frame.size.height);
        }
        [_datePickerView addTarget:self action:@selector(dueDateChanged:) forControlEvents:UIControlEventValueChanged];
        _datePickerView.tag = 1001;
        _uvDatePicker.hidden = NO;
        [self.view bringSubviewToFront:_uvDatePicker];
    }
    else{
        [self.rmsDbController playButtonSound];
        _uvDatePicker.frame = CGRectMake(48, 130, _uvDatePicker.frame.size.width, _uvDatePicker.frame.size.height);
        [_datePickerView addTarget:self action:@selector(dueDateChanged:) forControlEvents:UIControlEventValueChanged];
        _datePickerView.tag = 1001;
        _uvDatePicker.hidden = NO;
        [self.view bringSubviewToFront:_uvDatePicker];
    }
}

-(IBAction)btnToDateClick:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]){
        
        _tblGenerateOrder.scrollEnabled=NO;
        [self.rmsDbController playButtonSound];
        _uvDatePicker.hidden = NO;
        UITableViewCell *cell = (UITableViewCell *)sender;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            _uvDatePicker.frame = CGRectMake(70, cell.frame.origin.y+106, _uvDatePicker.frame.size.width, _uvDatePicker.frame.size.height);
        }
        else{
            _uvDatePicker.frame = CGRectMake(754, cell.frame.origin.y+32, _uvDatePicker.frame.size.   width, _uvDatePicker.frame.size.height);
        }
        [_datePickerView addTarget:self action:@selector(dueDateChanged:) forControlEvents:UIControlEventValueChanged];
        _datePickerView.tag = 1002;
    }
    else{
        [self.rmsDbController playButtonSound];
        _uvDatePicker.hidden = NO;
        _uvDatePicker.frame = CGRectMake(286, 130, _uvDatePicker.frame.size.width, _uvDatePicker.frame.size.height);
        [_datePickerView addTarget:self action:@selector(dueDateChanged:) forControlEvents:UIControlEventValueChanged];
        _datePickerView.tag = 1002;
    }
}

-(void) dueDateChanged:(UIDatePicker *)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    if(sender.tag == 1001)
        self.strFromDate = [dateFormatter stringFromDate:sender.date];
    else
        self.strToDate = [dateFormatter stringFromDate:sender.date];
    [_tblGenerateOrder reloadData];
}

- (IBAction) toolBarActionHandler:(id)sender {
    [self.rmsDbController playButtonSound];
    switch ([sender tag]) {
        case 102:
        {
            NSDictionary *dateDict;
            _tblGenerateOrder.scrollEnabled=YES;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MM/dd/yyyy";
            if(_datePickerView.tag == 1001){
                dateDict = @{kPOGenerateOrderFromDateSelectedKey : [dateFormatter stringFromDate:_datePickerView.date]};
                [Appsee addEvent:kPOGenerateOrderFromDateSelected withProperties:dateDict];
                self.strFromDate=[dateFormatter stringFromDate:_datePickerView.date];
                _datePickerView.minimumDate=_datePickerView.date;
                [_tblGenerateOrder reloadData];
            }
            else{
                dateDict = @{kPOGenerateOrderToDateSelectedKey : [dateFormatter stringFromDate:_datePickerView.date]};
                [Appsee addEvent:kPOGenerateOrderToDateSelected withProperties:dateDict];
                self.strToDate=[dateFormatter stringFromDate:_datePickerView.date];
                _datePickerView.maximumDate=_datePickerView.date;
                [_tblGenerateOrder reloadData];
            }
            
            self.strPopUpFromDate = self.strFromDate;
            self.strPopUpToDate = self.strToDate;
            _uvDatePicker.hidden = YES;
            break;
        }
        default:
            break;
    }
}

-(IBAction)btnSuppClick:(id)sender
{
    [self.rmsDbController playButtonSound];
    objSupplier = [[RimSupplierPagePO alloc] initWithNibName:@"RimSupplierPage" bundle:nil];
    objSupplier.checkedSupplier = [self.arrSelectedSupplier mutableCopy ];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
    {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if(screenBounds.size.height == 568)
        {
            objSupplier.view.frame=CGRectMake(10, 260, objSupplier.view.frame.size.width, objSupplier.view.frame.size.height);
        }
        else
        {
            objSupplier.view.frame=CGRectMake(10, 180, objSupplier.view.frame.size.width, objSupplier.view.frame.size.height);
        }
    }
    else
    {
        objSupplier.view.frame=CGRectMake(290, 250, objSupplier.view.frame.size.width, objSupplier.view.frame.size.height);
    }
//    objSupplier.objGenerateOdr = self;
    objSupplier.strItemcode=@"1";
    objSupplier.callingFunction=@"Generate";
    [self.view addSubview:objSupplier.view];
}

-(IBAction)btnDeptClick:(id)sender
{
    [self.rmsDbController playButtonSound];
    objDeptPop = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"DepartmentMultiple_sid"];
    objDeptPop.checkedDepartment = [self.arrSelectedDepartment mutableCopy];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
    {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if(screenBounds.size.height == 568)
        {
            objDeptPop.view.frame=CGRectMake(10, 260, objDeptPop.view.frame.size.width, objDeptPop.view.frame.size.height);
        }
        else
        {
            objDeptPop.view.frame=CGRectMake(10, 180, objDeptPop.view.frame.size.width, objDeptPop.view.frame.size.height);
        }
    }
    else
    {
        objDeptPop.view.frame=CGRectMake(50, 250, objDeptPop.view.frame.size.width, objDeptPop.view.frame.size.height);
    }
    objDeptPop.strItemcode=@"1";
//    objDeptPop.objGenerateOdr = self;
    [self.view addSubview:objDeptPop.view];
}

#pragma mark - selected Suppliers, Departments and Tag Methods
-(void)displaySelectedDepartment
{
    NSMutableString *strResult=[[NSMutableString alloc]init];
    //    NSMutableArray *itemDeptData = [[NSMutableArray alloc] init];
    if(self.arrSelectedDepartment.count>0)
    {
        if(self.arrSelectedSupplier.count>0){
            
            if(self.arrSelectedDepartment.count>0)
            {
                [self createDepartmentList];
            }
            
            [tblDeptsupplierlist reloadData];
            [_tblGenerateOrder reloadData];
        }
        else{
            [self createDepartmentList];
        }
        for (int isup=0; isup<self.arrSelectedDepartment.count; isup++)
        {
            NSMutableArray *itemDeptData  = (self.arrSelectedDepartment)[isup];
            NSString *ch = [itemDeptData valueForKey:@"DepartmentName"];
            [strResult appendFormat:@"%@, ", ch];
        }
        NSString *departmentname = [strResult substringToIndex:strResult.length-2];
        self.lblSelectedDepartment.text = [NSString stringWithFormat:@"Department : %@",departmentname];
    }
    else
    {
        [tblDeptsupplierlist reloadData];
        [_tblGenerateOrder reloadData];
    }
}

-(void)createDepartmentList
{
    for(UIView *subview in Deptsupplierview.subviews) {
        [subview removeFromSuperview];
    }
    if(self.arrSelectedDepartment.count > 0)
    {
        [_tblGenerateOrder reloadData];
        [tblDeptsupplierlist reloadData];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
        {
            Deptsupplierview.frame = CGRectMake(20, 0, 280,100);
        }
        else
        {
            Deptsupplierview.frame = CGRectMake(17, 0, 967,100);
        }
        Deptsupplierview.backgroundColor = [UIColor clearColor];
        Deptsupplierview.userInteractionEnabled=YES;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
        {
            tblDeptsupplierlist.frame = CGRectMake(0, 5, 280,95);
        }
        else{
            tblDeptsupplierlist.frame = CGRectMake(0, 5,947 ,95);
        }
        tblDeptsupplierlist.scrollEnabled = YES;
        tblDeptsupplierlist.userInteractionEnabled = YES;
        tblDeptsupplierlist.bounces = YES;
        tblDeptsupplierlist.delegate = self;
        tblDeptsupplierlist.dataSource = self;
        tblDeptsupplierlist.backgroundColor = [UIColor clearColor];
        tblDeptsupplierlist.separatorStyle = UITableViewCellSeparatorStyleNone;
        tblDeptsupplierlist.rowHeight=22;
        [Deptsupplierview addSubview:tblDeptsupplierlist];
    }
    else
    {
        [_tblGenerateOrder reloadData];
    }
}
-(void)createSupplierList{
    
    for(UIView *subview in supplierview.subviews) {
        [subview removeFromSuperview];
    }
    if(self.arrSelectedSupplier.count > 0)
    {
        [_tblGenerateOrder reloadData];
        [tblsupplierlist reloadData];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
        {
            supplierview.frame = CGRectMake(20, 0, 280,100);
        }
        else
        {
            supplierview.frame = CGRectMake(17, 0, 967,100);
        }
        
        supplierview.backgroundColor = [UIColor clearColor];
        supplierview.userInteractionEnabled=YES;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
        {
            tblsupplierlist.frame = CGRectMake(0, 5, 280,95);
        }
        else{
            tblsupplierlist.frame = CGRectMake(0, 5, 947,95);
        }
        
        tblsupplierlist.scrollEnabled = YES;
        tblsupplierlist.userInteractionEnabled = YES;
        tblsupplierlist.bounces = YES;
        tblsupplierlist.delegate = self;
        tblsupplierlist.dataSource = self;
        tblsupplierlist.backgroundColor = [UIColor clearColor];
        tblsupplierlist.separatorStyle = UITableViewCellSeparatorStyleNone;
        tblsupplierlist.rowHeight=22;
        [supplierview addSubview:tblsupplierlist];
    }
}

-(void)displaySelectedGroup
{
        [self createGroupList];
        [tblGrouplist reloadData];
        [_tblGenerateOrder reloadData];
}

-(void)createGroupList{
    
    for(UIView *subview in groupView.subviews) {
        [subview removeFromSuperview];
    }
    if(self.arrSelectedGroup.count > 0)
    {
        [_tblGenerateOrder reloadData];
        [tblGrouplist reloadData];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
        {
            groupView.frame = CGRectMake(20, 0, 280,80);
        }
        else
        {
            groupView.frame = CGRectMake(17, 0, 967,80);
        }
        
        groupView.backgroundColor = [UIColor clearColor];
        groupView.userInteractionEnabled=YES;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
        {
            tblGrouplist.frame = CGRectMake(0, 5, 280,75);
        }
        else{
            tblGrouplist.frame = CGRectMake(0, 5, 947,75);
        }
        
        tblGrouplist.scrollEnabled = YES;
        tblGrouplist.userInteractionEnabled = YES;
        tblGrouplist.bounces = YES;
        tblGrouplist.delegate = self;
        tblGrouplist.dataSource = self;
        tblGrouplist.backgroundColor = [UIColor clearColor];
        tblGrouplist.separatorStyle = UITableViewCellSeparatorStyleNone;
        tblGrouplist.rowHeight = 18;
        [groupView addSubview:tblGrouplist];
    }
}


-(void)getSelectedDepartmentIds
{
    NSMutableString *strResult = [NSMutableString string];
    if(self.arrSelectedDepartment.count>0)
    {
        for (int isup=0; isup<self.arrSelectedDepartment.count; isup++)
        {
            NSMutableArray *itemDeptData = (self.arrSelectedDepartment)[isup];
            NSString *ch = [itemDeptData valueForKey:@"DeptId"];
            [strResult appendFormat:@"%@,", ch];
        }
        self.departmentString = [strResult substringToIndex:strResult.length-1];
    }
    else
    {
        self.departmentString = @"";
    }
}

-(void)displaySelectedSupplier
{
    NSMutableString *strResult = [[NSMutableString alloc]init];
    if(self.arrSelectedSupplier.count>0)
    {
        if(self.arrSelectedDepartment.count>0){
            if(self.arrSelectedSupplier.count>0)
            {
                [self createSupplierList];
            }
            [tblsupplierlist reloadData];
            [_tblGenerateOrder reloadData];
        }
        else{
            [self createSupplierList];
        }
        
        for (int isup=0; isup<self.arrSelectedSupplier.count; isup++)
        {
            NSMutableDictionary *tmpSup=(self.arrSelectedSupplier)[isup];
            NSString *ch = tmpSup[@"SupplierName"];
            [strResult appendFormat:@"%@, ", ch];
        }
        NSString *supplierName = [strResult substringToIndex:strResult.length-2];
        self.lblSelectedSupplier.text = [NSString stringWithFormat:@"Suppliers : %@",supplierName];
    }
    else
    {
        self.uvSelectSupplier.hidden = YES;
        [tblsupplierlist reloadData];
        [_tblGenerateOrder reloadData];
    }
}

-(void)getSelectedSupplierIds
{
    NSMutableString *strResult = [[NSMutableString alloc]init];
    if(self.arrSelectedSupplier.count>0)
    {
        for (int isup=0; isup<self.arrSelectedSupplier.count; isup++)
        {
            NSMutableDictionary *tmpSup=(self.arrSelectedSupplier)[isup];
            NSString *ch = tmpSup[@"Id"];
            [strResult appendFormat:@"%@,", ch];
        }
        self.supplierString = [strResult substringToIndex:strResult.length-1];
    }
    else
    {
        self.supplierString = @"";
    }
}

-(void)getSelectedGroupIds
{
    NSMutableString *strResult = [[NSMutableString alloc]init];
    if(self.arrSelectedGroup.count>0)
    {
        for (int iGroup=0; iGroup<self.arrSelectedGroup.count; iGroup++)
        {
            NSMutableDictionary *tempGroup=(self.arrSelectedGroup)[iGroup];
            NSString *ch = tempGroup[@"groupId"];
            [strResult appendFormat:@"%@,", ch];
        }
        self.strGroupIds = [strResult substringToIndex:strResult.length-1];
    }
    else
    {
        self.strGroupIds = @"";
    }
}


-(void)getSelectedTagNames
{
    NSMutableString *strResult = [[NSMutableString alloc]init];
    if(self.arrayTagList.count>0)
    {
        for (int isup=0; isup<self.arrayTagList.count; isup++)
        {
            NSString *ch = (self.arrayTagList)[isup];
            [strResult appendFormat:@"%@,", ch];
        }
        self.tagString = [strResult substringToIndex:strResult.length-1];
    }
    else
    {
        self.tagString = @"";
    }
}

-(IBAction)btnBackClicked:(id)sender
{
    [_txtMainBarcode resignFirstResponder];
    _txtPOTitle.text=@"";
    _txtOrderNo.text=@"";
    _txtTagName.text = @"";
    [self.rmsDbController playButtonSound];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        [self.arrGenerateOrderData removeAllObjects];
        _txtMinStock.text = @"";
        self.uvGenerateOdrData.hidden = YES;
//        self._RimsController.objPOMenuList.btnBackButtonClick.hidden=YES;
//        self._RimsController.objPOMenuList.objSideMenuMainPO.indPath=[NSIndexPath indexPathForRow:0 inSection:0];
//        [self._RimsController.objPOMenuList menuButtonOperationCell:self._rimController.objPOMenuList.objSideMenuMainPO.indPath.row];
        [self.tblGenerateOdrData reloadData];
    }
    else
    {
        NSArray *viewcon = self.navigationController.viewControllers;
        for(UIViewController *tempcon in viewcon){
            if([tempcon isKindOfClass:[POmenuListVC class]])
            {
                [self.navigationController popToViewController:tempcon animated:YES];
            }
        }
    }
}

#pragma mark - Method Generate Order Clicked

-(IBAction)btnGenerateOrderClick:(id)sender
{
    _uvOrderTypes.hidden=YES;
    [self.rmsDbController playButtonSound];
    if ([_lblOrderType.text isEqualToString:@"DateWise"])
    {
        if(self.strFromDate.length == 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please select From date for generating order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
        else if(self.strToDate.length == 0)
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please select To date for generating order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
        else if((self.strFromDate.length == 0) && (self.strToDate.length == 0))
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please select from date and to date for generating order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            return;
        }
    }
    
    [self getSelectedDepartmentIds];
    [self getSelectedSupplierIds];
    [self getSelectedGroupIds];
    [self getSelectedTagNames];
    //    long BranchId,string FromDate,string ToDate,string DeptIds,string SupIds,int MinStock,string TimeDuration,
    //    string ProfitType,string IsMinStock
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    
    if(self.strFromDate.length == 0)
        [param setValue:@"" forKey:@"FromDate"];
    else
        [param setValue:self.strFromDate forKey:@"FromDate"];
    
    if(self.strToDate.length == 0)
        [param setValue:@"" forKey:@"ToDate"];
    else
        [param setValue:self.strToDate forKey:@"ToDate"];
    
    [param setValue:self.departmentString forKey:@"DeptIds"];
    [param setValue:self.supplierString forKey:@"SupIds"];
    [param setValue:self.strGroupIds forKey:@"GroupIds"];
    [param setValue:self.tagString forKey:@"Tags"];
    
    if(_txtMinStock.text.length == 0)
        [param setValue:@"0" forKey:@"MinStock"];
    else
        [param setValue:_txtMinStock.text forKey:@"MinStock"];
    
    [param setValue:_lblOrderType.text forKey:@"TimeDuration"];
    [param setValue:@"undefined" forKey:@"ProfitType"];
    [param setValue:self.isMinStock forKey:@"IsMinStock"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    [param setValue:strDateTime forKey:@"LocalDate"];
    
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    param[@"UserId"] = userID;
    
    param[@"PoDetailxml"] = [self PoDetailxmlBackOrder];
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    if([[param valueForKey:@"DeptIds"] isEqualToString:@""] && [[param valueForKey:@"FromDate"] isEqualToString:@""] && [[param valueForKey:@"IsMinStock"] isEqualToString:@"Yes"] && [[param valueForKey:@"MinStock"] isEqualToString:@"0"] && [[param valueForKey:@"PoDetailxml"]count]==0 && [[param valueForKey:@"SupIds"] isEqualToString:@""] && [[param valueForKey:@"Tags"] isEqualToString:@""]  && [[param valueForKey:@"TimeDuration"] isEqualToString:@"None"] && [[param valueForKey:@"ToDate"] isEqualToString:@""]){
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getGenerateorderView];
        });
        
        
    }
    else if([[param valueForKey:@"DeptIds"] isEqualToString:@""] && [[param valueForKey:@"FromDate"] isEqualToString:@""] && [[param valueForKey:@"IsMinStock"] isEqualToString:@"No"] && [[param valueForKey:@"MinStock"] isEqualToString:@"0"] && [[param valueForKey:@"PoDetailxml"]count]==0 && [[param valueForKey:@"SupIds"] isEqualToString:@""] && [[param valueForKey:@"Tags"] isEqualToString:@""]  && [[param valueForKey:@"TimeDuration"] isEqualToString:@"None"] && [[param valueForKey:@"ToDate"] isEqualToString:@""]){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getGenerateorderView];
        });
        
        
    }
    else
    {
        
        NSDictionary *departmentDict = @{kPOGenerateOrderDepartmentsSelectedKey : @(self.arrSelectedDepartment.count)};
        [Appsee addEvent:kPOGenerateOrderDepartmentsSelected withProperties:departmentDict];
        NSDictionary *supplierDict = @{kPOGenerateOrderSuppliersSelectedKey : @(self.arrSelectedSupplier.count)};
        [Appsee addEvent:kPOGenerateOrderSuppliersSelected withProperties:supplierDict];
        NSDictionary *groupDict = @{kPOGenerateOrderGroupsSelectedKey : @(self.arrSelectedGroup.count)};
        [Appsee addEvent:kPOGenerateOrderGroupsSelected withProperties:groupDict];
        NSDictionary *tagDict = @{kPOGenerateOrderTagSelectedKey : @(self.arrayTagList.count)};
        [Appsee addEvent:kPOGenerateOrderTagSelected withProperties:tagDict];
        [Appsee addEvent:kPOGOOpenBackListDataWebServiceCall];
        
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self displayGeneratedOrderResponse:response error:error];
                 });
        };
        
        self.generatePurchaseOrderDetailWC = [self.generatePurchaseOrderDetailWC initWithRequest:KURL actionName:WSM_GENERATE_PURCHASE_ORDER_DEATIL_NEW params:param completionHandler:completionHandler];
        
    }
}
- (void)displayGeneratedOrderResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                NSDictionary *responseDict = @{kPOGenerateOrderWebServiceResponseKey : @"Response is successful"};
                [Appsee addEvent:kPOGenerateOrderWebServiceResponse withProperties:responseDict];
                
                NSMutableArray *arrtempPoData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                if(arrtempPoData.count > 0)
                {
                    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        objPList= [[PurchaseOrderFilterListDetail alloc]initWithNibName:@"PurchaseOrderFilterListDetail_iPhone" bundle:nil];
                    }
                    else{
                        objPList= [[PurchaseOrderFilterListDetail alloc]initWithNibName:@"PurchaseOrderFilterListDetail" bundle:nil];
                    }
                    objPList.arrUpdatePoData = [arrtempPoData mutableCopy];
                    
                    objPList.managedObjectContext = self.rmsDbController.managedObjectContext;
                    objPList.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
                    
                    [objPList supplierDepartmentArray:arrtempPoData];
                    
                    objPList.strPopUpTimeDuration = [arrtempPoData.firstObject valueForKey:@"TimeDuration"];
                    
                    
                    
                    if([objPList.strPopUpTimeDuration isEqualToString:@"DateWise"])
                    {
                        // from
                        objPList.strPopUpFromDate =[arrtempPoData.firstObject valueForKey:@"FromDate"] ;
                        // to Date
                        objPList.strPopUpToDate =[arrtempPoData.firstObject valueForKey:@"ToDate"] ;
                    }
                    
                    [self.navigationController pushViewController:objPList animated:NO];
                    //                if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    //                {
                    //
                    //                    [self.navigationController pushViewController:objPList animated:YES];
                    //                }
                    //                else
                    //                {
                    //                    self._rimController.objPOMenuList.btnBackButtonClick.hidden=NO;
                    //                    [self._rimController.objPOMenuList showViewFromViewController:objPList];
                    //                }
                }
                else
                {
                    //                self._rimController.objPOMenuList.btnBackButtonClick.hidden=NO;
                    [self.arrGenerateOrderData removeAllObjects];
                    self.uvGenerateOdrData.hidden = NO;
                }
            }
            else if([[response valueForKey:@"IsError"] intValue] == -1)
            {
                NSDictionary *responseDict = @{kPOGenerateOrderWebServiceResponseKey : @"Error -1"};
                [Appsee addEvent:kPOGenerateOrderWebServiceResponse withProperties:responseDict];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                NSDictionary *responseDict = @{kPOGenerateOrderWebServiceResponseKey : @"Search criteria is not match with item records."};
                [Appsee addEvent:kPOGenerateOrderWebServiceResponse withProperties:responseDict];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Search criteria is not match with item records." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Match Record not found." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

-(void)getGenerateorderView{
    
    self.boolInsertOpenOrder=YES;
    //_lblAutoGenPO.text=@"Work Order";
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM,dd yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    _lblPODate.text = strDateTime;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self.tblGenerateOdrData reloadData];
    }
    else{
        _lblPODate.frame=CGRectMake(20.0,15.0 ,_lblPODate.frame.size.width ,_lblPODate.frame.size.height );
        
    }
    
    [_activityIndicator hideActivityIndicator];
    self.uvGenerateOdrData.hidden=NO;
    _btnFilter.hidden=YES;
    self.toolbarDeliverylabel.hidden=YES;
    self.toolbarDelivery.hidden=YES;
}


#pragma mark - Footer Button Functions

-(IBAction)btnSearchClick:(id)sender {
    NSString * strNibName = @"POMultipleItemSelectionHeaderVC";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        strNibName = @"POMultipleItemSelectionVC";
    }

    POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:strNibName bundle:nil];
    
    itemMultipleVC.checkSearchRecord = TRUE;
    itemMultipleVC.flgRedirectToGenerateOdr = TRUE;
    itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:itemMultipleVC animated:TRUE];
    }
    else {
//        [self.navigationController pushViewController:itemMultipleVC animated:FALSE];
        [self presentViewController:itemMultipleVC animated:false completion:nil];

    }
    
    //hiten
//    self._rimController.objPOMenuList.btnBackButtonClick.hidden=YES;
//    NSArray *subViews = [self._rimController.objPOMenuList.generalOrderView  subviews];
    //self._rimController.objPOMenuList.generalOrderView.tag = 151515;
//    
//    for (int i = 0; i < subViews.count; i++) {
//        UIView *aView = subViews[i];
//        [aView removeFromSuperview];
//    }
//    
//    [self.rmsDbController playButtonSound];
//    self._rimController.objPoItemList.checkSearchRecord = TRUE;
//    self._rimController.objPoItemList.objGenerateOdr = self;
//    self._rimController.objPoItemList.flgRedirectToGenerateOdr = TRUE;
//    [self._rimController.objPoItemList resetTableViewData];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
//        NSArray *arryView = [self._rimController.objInvHome.navigationController viewControllers];
//        for(int i=0;i<[arryView count];i++)
//        {
//            UIViewController *viewCon = [arryView objectAtIndex:i];
//            if([viewCon isKindOfClass:[InventoryManagement class]]){
//                [self._rimController.objInvHome.navigationController popToViewController:viewCon animated:YES];
//                [self.view setHidden:YES];
//                return;
//            }
//        }
//        if(!self._rimController.objInvenMgmt)
//        {
//            POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionVC" bundle:nil];
//            
//            itemMultipleVC.checkSearchRecord = TRUE;
//            itemMultipleVC.objGenerateOdr = self;
//            itemMultipleVC.flgRedirectToOpenList = TRUE;
//            
//            [self._rimController.objInvHome.navigationController pushViewController:itemMultipleVC animated:YES];
//        }
//        else
//        {
//            UIViewController *viewcon2 = self._rimController.objInvenMgmt;
//            UIView  *viewFooter2 = (UIView *)[viewcon2.view viewWithTag:2222];
//            UIButton *btmAdd = (UIButton *)[viewFooter2 viewWithTag:1111];
//            [btmAdd setHidden:YES];
//            UILabel *lblAddNewItem = (UILabel *)[viewFooter2 viewWithTag:1212];
//            [lblAddNewItem setHidden:YES];
//            [self.navigationController pushViewController:self._rimController.objPoItemList animated:YES];
//        }
    }
    else
    {
//        [self._rimController.objPOMenuList showItemManagementView:itemMultipleVC];
    }
}
-(IBAction)btnCameraScanSearch:(id)sender
{
    self.cameraScanVC = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"CameraScanVC_sid"];
    
    [self presentViewController:self.cameraScanVC animated:YES completion:^{
        self.cameraScanVC.delegate = self;
    }];
}

#pragma mark - Camera Scan Delegate Methods

-(void)barcodeScanned:(NSString *)strBarcode
{
    _txtMainBarcode.text = strBarcode;
    searchText = strBarcode;
    [self searchBarcode:nil];
}

-(void)didSelectItems:(NSArray *) arrTempSelected
{
    for(int i=0;i<arrTempSelected.count;i++)
    {
        NSMutableDictionary *dictSelected = [arrTempSelected[i]mutableCopy];
        if([dictSelected  valueForKey:@"selected"])
        {
            [dictSelected removeObjectForKey:@"AddedQty"];
            // [dictSelected removeObjectForKey:@"CostPrice"];
            [dictSelected removeObjectForKey:@"DepartId"];
            [dictSelected removeObjectForKey:@"ItemDiscount"];
            [dictSelected removeObjectForKey:@"ItemImage"];
            [dictSelected removeObjectForKey:@"ItemSupplierData"];
            [dictSelected removeObjectForKey:@"ItemTag"];
            [dictSelected removeObjectForKey:@"ProfitAmt"];
            [dictSelected removeObjectForKey:@"ProfitType"];
            [dictSelected removeObjectForKey:@"Remark"];
            [dictSelected removeObjectForKey:@"SalesPrice"];
            [dictSelected removeObjectForKey:@"selected"];
            [dictSelected removeObjectForKey:@"ItemNo"];
            
            [dictSelected removeObjectForKey:@"EBT"];
            [dictSelected removeObjectForKey:@"NoDiscountFlg"];
            [dictSelected removeObjectForKey:@"POSDISCOUNT"];
            [dictSelected removeObjectForKey:@"TaxType"];
            [dictSelected removeObjectForKey:@"isTax"];
            
            [dictSelected setValue:@"0" forKey:@"ReOrder"];
            [dictSelected setValue:@"0" forKey:@"Sold"];
            
            [self.arrGenerateOrderData insertObject:dictSelected atIndex:0];
            self.arrTempSelectedData = [[NSMutableArray alloc]init];
            self.arrTempSelectedData = [arrTempSelected mutableCopy];
        }
    }
    [self.arrTempSelectedData removeAllObjects];
    //    checkSearchRecord=FALSE;
    //    flgRedirectToGenerateOdr = FALSE;
    [self.tblGenerateOdrData reloadData];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
//        [self._rimController.objPOMenuList showViewFromViewController:self];
    }
}

- (NSMutableArray *) PoDetailxml
{
    
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.arrGenerateOrderData.count>0)
    {
        for (int isup=0; isup<self.arrGenerateOrderData.count; isup++)
        {
            NSMutableDictionary *tmpSup = [(self.arrGenerateOrderData)[isup] mutableCopy ];
            
            NSMutableDictionary *speDict = [tmpSup mutableCopy];
            NSArray *removedKeys = @[@"ItemId",@"ReOrder",@"Sold",@"avaibleQty"];
            [speDict removeObjectsForKeys:removedKeys];
            NSArray *speKeys = speDict.allKeys;
            [tmpSup removeObjectsForKeys:speKeys];
            
            
          /*  // Barcode = 90;
            // DepartmentName = Mixes;
            // "ITEM_No" = "";
            // ItemName = "1800 Anejo Tequila 50ml";
            // Margin = 100;
            // MarkUp = 0;
            // MaxStockLevel = 0;
            // MinStockLevel = 0;
            // Suppliers = Kam;
            
            NSMutableDictionary *tmpOdrDict=[arrGenerateOrderData objectAtIndex:isup];
            [tmpOdrDict removeObjectForKey:@"Barcode"];
            [tmpOdrDict removeObjectForKey:@"DepartmentName"];
            [tmpOdrDict removeObjectForKey:@"ITEM_No"];
            [tmpOdrDict removeObjectForKey:@"ItemName"];
            [tmpOdrDict removeObjectForKey:@"Margin"];
            [tmpOdrDict removeObjectForKey:@"MarkUp"];
            [tmpOdrDict removeObjectForKey:@"MaxStockLevel"];
            [tmpOdrDict removeObjectForKey:@"MinStockLevel"];
            [tmpOdrDict removeObjectForKey:@"Suppliers"];
            
            // getting this field in edit/update mode
            
            [tmpOdrDict removeObjectForKey:@"ColumnNames"];
            [tmpOdrDict removeObjectForKey:@"Image"];
            [tmpOdrDict removeObjectForKey:@"ItemInfo"];
            [tmpOdrDict removeObjectForKey:@"Profit"];
            */
            
            // ItemId == ItemCode, Sold == SoldQty, avaibleQty == AvailQty
            // AvailQty,ItemCode,ReOrder,SoldQty -- need to send this parameter so other must be removed
            
            [tmpSup setValue:[tmpSup valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpSup setValue:[tmpSup valueForKey:@"Sold" ] forKey:@"SoldQty"];
            [tmpSup setValue:[tmpSup valueForKey:@"avaibleQty" ] forKey:@"AvailQty"];
            
            [tmpSup removeObjectForKey:@"ItemId"];
            [tmpSup removeObjectForKey:@"Sold"];
            [tmpSup removeObjectForKey:@"avaibleQty"];
            
            [itemSupplierData addObject:tmpSup];
        }
    }
    return itemSupplierData;
}

-(IBAction)btnSaveOrderClick:(id)sender {
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
    }
    else{
        
        if(self.pOmenuListVCDelegate.currentSelectedMenu==0)
        {
            // Add New Purchase order
            
            if(self.boolInsertOpenOrder){
                
                if(self.arrGenerateOrderData.count > 0)
                {
                    NSArray *arrOrder = [self.arrGenerateOrderData valueForKey:@"ReOrder"];
                    BOOL isWebService = FALSE;
                    for(NSString * strOrderValue in arrOrder)
                    {
                        if (strOrderValue.intValue > 0) {
                            isWebService = TRUE;
                            break;
                        }
                    }
                    if(isWebService)
                    {

//                    if (![arrOrder containsObject:@"0"])
//                    {
                        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                        
                        NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
                        dictPODetail[@"PoDetailxml"] = [self PoDetailxml];
                        
                        dictPODetail[@"PoId"] = @"0";
                        
                        dictPODetail[@"PO_No"] = @"";
                        dictPODetail[@"POTitle"] = _txtPOTitle.text;
                        dictPODetail[@"OrderNo"] = @"";
                        
                        [dictPODetail setValue:@"" forKey:@"FromDate"];
                        [dictPODetail setValue:@"" forKey:@"ToDate"];
                        
                        [dictPODetail setValue:@"" forKey:@"SupplierIds"];
                        [dictPODetail setValue:@"" forKey:@"DeptIds"];
                        [dictPODetail setValue:@"" forKey:@"Tags"];
                        
                        [dictPODetail setValue:@"-1" forKey:@"MinStock"];
                        
                        
                        [dictPODetail setValue:@"" forKey:@"TimeDuration"];
                        [dictPODetail setValue:@"Barcode,ITEM_Desc,SoldQty,AvailQty,ReOrder" forKey:@"ColumnsNames"];
                        
                        dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
                        NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
                        dictPODetail[@"UserId"] = userID;
                        
                        //hiten
                        
                        NSString *strDate =   [self getStringFormate:_lblPODate.text fromFormate:@"MMMM,dd yyyy hh:mm a" toFormate:@"MM/dd/yyyy hh:mm a"];
                        
                        [dictPODetail setValue:strDate forKey:@"DateTime"];
                        
                        CompletionHandler completionHandler = ^(id response, NSError *error) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                
                                [self responseInsertOpenPoNewManualResponse:response error:error];
                            });
                        };
                        
                        self.insertOpenPoManualWC = [self.insertOpenPoManualWC initWithRequest:KURL actionName:WSM_UPDATE_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
                        
                    }
                    
                    else{
                        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                        {
                            
                        };
                        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Add Reoder quantity." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                    }
                
                }
                else
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Add Item to Placed Order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
                
                
            }
            else{
                
                if(self.arrGenerateOrderData.count > 0)
                {
                    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

                    
                    NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
                    dictPODetail[@"PoDetailxml"] = [self PoDetailxml];
                    
                    // get logged in user branch id and user id.
                    
                    // string PO_No, string POTitle, string OrderNo, string FromDate, string ToDate, string SupplierIds, string DeptIds, int MinStock, long BranchId, long UserId, string TimeDuration, string ColumnsNames
                    
                    dictPODetail[@"PO_No"] = _lblAutoGenPO.text;
                    dictPODetail[@"POTitle"] = @"";
                    dictPODetail[@"OrderNo"] = @"";
                    
                    if(self.strFromDate.length == 0)
                        [dictPODetail setValue:@"" forKey:@"FromDate"];
                    else
                        [dictPODetail setValue:self.strFromDate forKey:@"FromDate"];
                    
                    if(self.strToDate.length == 0)
                        [dictPODetail setValue:@"" forKey:@"ToDate"];
                    else
                        [dictPODetail setValue:self.strToDate forKey:@"ToDate"];
                    
                    [dictPODetail setValue:self.supplierString forKey:@"SupplierIds"];
                    [dictPODetail setValue:self.departmentString forKey:@"DeptIds"];
                    [dictPODetail setValue:self.tagString forKey:@"Tags"];
                    
                    if(_txtMinStock.text.length == 0)
                        [dictPODetail setValue:@"-1" forKey:@"MinStock"];
                    else
                        [dictPODetail setValue:_txtMinStock.text forKey:@"MinStock"];
                    
                    [dictPODetail setValue:_lblOrderType.text forKey:@"TimeDuration"];
                    [dictPODetail setValue:@"Barcode,ITEM_Desc,SoldQty,AvailQty,ReOrder" forKey:@"ColumnsNames"];
                    
                    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
                    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
                    dictPODetail[@"UserId"] = userID;
                    
                    //hiten
                    
                    NSDate* date = [NSDate date];
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
                    NSString *strDateTime = [formatter stringFromDate:date];
                    
                    [dictPODetail setValue:strDateTime forKey:@"DateTime"];
                    
                    CompletionHandler completionHandler = ^(id response, NSError *error) {
                        [self responseInsertPoDetailResponse:response error:error];
                    };
                    
                    self.insertPoDetailNewWC = [self.insertPoDetailNewWC initWithRequest:KURL actionName:WSM_INSERT_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
                    
                }
                else
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Add Item to Placed Order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
                
                
            }
            
        }
        else if(self.pOmenuListVCDelegate.currentSelectedMenu ==2)
        {
            
            [self.rmsDbController playButtonSound];
            if(isPoUpdate) // Update existing Purchase order
            {
                _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
                
                NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
                dictPODetail[@"PoDetailxml"] = [self PoDetailxml];
                
                // long PoId, string PO_No, string POTitle, string OrderNo, string FromDate, string ToDate, string SupplierIds, string DeptIds, int MinStock, long BranchId, long UserId, string TimeDuration, string ColumnsNames
                
                dictPODetail[@"PoId"] = self.arrUpdatePoData.firstObject[@"PurchaseOrderId"];
                
                // hiten 20082014
                
                // [dictPODetail setObject:[[self.arrUpdatePoData firstObject] objectForKey:@"OrderN"] forKey:@"OrderNo"];
                
                //[dictPODetail setObject:_lblAutoGenPO.text forKey:@"PO_No"];
                dictPODetail[@"POTitle"] = @"";
                dictPODetail[@"OrderNo"] = @"";
                
                //[dictPODetail setValue:_lblOrderType.text forKey:@"TimeDuration"];
                [dictPODetail setValue:@"Barcode,ITEM_Desc,SoldQty,AvailQty,ReOrder" forKey:@"ColumnsNames"];
                
                dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
                NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
                dictPODetail[@"UserId"] = userID;
                
                
                //hiten
                
                NSDate* date = [NSDate date];
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
                NSString *strDateTime = [formatter stringFromDate:date];
                
                [dictPODetail setValue:strDateTime forKey:@"DateTime"];
            
                dictPODetail[@"OpenOrderId"] = self.arrUpdatePoData.firstObject[@"OpenOrderId"];
                
                CompletionHandler completionHandler = ^(id response, NSError *error) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                        [self responseUpdatePoDetailResponse:response error:error];
                         });
                };
                
                self.updatePoDetailWC = [self.updatePoDetailWC initWithRequest:KURL actionName:WSM_UPDATE_OPEN_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
                
            }
            else // Add New Purchase order
            {
                
                if(self.arrGenerateOrderData.count > 0)
                {
                    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];

                    
                    NSMutableDictionary * dictPODetail = [[NSMutableDictionary alloc] init];
                    dictPODetail[@"PoDetailxml"] = [self PoDetailxml];
                    
                    // get logged in user branch id and user id.
                    
                    // string PO_No, string POTitle, string OrderNo, string FromDate, string ToDate, string SupplierIds, string DeptIds, int MinStock, long BranchId, long UserId, string TimeDuration, string ColumnsNames
                    
                    dictPODetail[@"PO_No"] = _lblAutoGenPO.text;
                    dictPODetail[@"POTitle"] = _txtPOTitle.text;
                    dictPODetail[@"OrderNo"] = _txtOrderNo.text;
                    
                    if(self.strFromDate.length == 0)
                        [dictPODetail setValue:@"" forKey:@"FromDate"];
                    else
                        [dictPODetail setValue:self.strFromDate forKey:@"FromDate"];
                    
                    if(self.strToDate.length == 0)
                        [dictPODetail setValue:@"" forKey:@"ToDate"];
                    else
                        [dictPODetail setValue:self.strToDate forKey:@"ToDate"];
                    
                    [dictPODetail setValue:self.supplierString forKey:@"SupplierIds"];
                    [dictPODetail setValue:self.departmentString forKey:@"DeptIds"];
                    [dictPODetail setValue:self.tagString forKey:@"Tags"];
                    
                    if(_txtMinStock.text.length == 0)
                        [dictPODetail setValue:@"-1" forKey:@"MinStock"];
                    else
                        [dictPODetail setValue:_txtMinStock.text forKey:@"MinStock"];
                    
                    [dictPODetail setValue:_lblOrderType.text forKey:@"TimeDuration"];
                    [dictPODetail setValue:@"Barcode,ITEM_Desc,SoldQty,AvailQty,ReOrder" forKey:@"ColumnsNames"];
                    
                    dictPODetail[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
                    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
                    dictPODetail[@"UserId"] = userID;
                    
                    //hiten
                    
                    NSDate* date = [NSDate date];
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
                    NSString *strDateTime = [formatter stringFromDate:date];
                    
                    [dictPODetail setValue:strDateTime forKey:@"DateTime"];
                    
                    //
                    CompletionHandler completionHandler = ^(id response, NSError *error) {
                        [self responseInsertPoDetailResponse:response error:error];
                    };
                    
                    self.insertPoDetailWC = [self.insertPoDetailWC initWithRequest:KURL actionName:WSM_INSERT_PO_DETAIL_NEW params:dictPODetail completionHandler:completionHandler];
                    
                }
                else
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Add Item to Placed Order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
                
            }
            
        }
        
    }
}

//hiten
- (void)responseInsertOpenPoNewManualResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        _txtOrderNo.text=@"";
        _txtPOTitle.text=@"";
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Purchase order has been generated successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrGenerateOrderData removeAllObjects];
                [self btnBackClicked:nil];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}



- (void)responseInsertPoDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            _txtOrderNo.text=@"";
            _txtPOTitle.text=@"";
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Purchase order has been generated successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrGenerateOrderData removeAllObjects];
                [self btnBackClicked:nil];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
    
}

- (void)responseUpdatePoDetailResponse:(id)response error:(NSError *)error
{
    
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            _txtOrderNo.text=@"";
            _txtPOTitle.text=@"";
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Open Order" message:@"Purchase order has been updated successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                isPoUpdate = FALSE;
                [self.arrGenerateOrderData removeAllObjects];
                _txtMinStock.text = @"";
                [self btnBackClicked:nil];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}


//
// Insert Purchase order List Notificaiton method

- (void)responseInsertPoNewDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        _txtOrderNo.text=@"";
        _txtPOTitle.text=@"";
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Purchase order has been generated successfully." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                [self.arrGenerateOrderData removeAllObjects];
                [self btnBackClicked:nil];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}



-(IBAction)btnItemInfoClick:(id)sender
{
    _lblTotalItem.text = @"";
    _lblTotalReOrderQTY.text = @"";
    _lblTotalCost.text = @"";
    
    float totalQTYeach = 0.0;
    float totalCostPrice = 0.0;
    for( int iArr = 0 ; iArr < self.arrGenerateOrderData.count; iArr++)
    {
        // Calculate Total CostPrice
        int iQty = [(self.arrGenerateOrderData)[iArr][@"ReOrder"] intValue ];
        totalQTYeach = totalQTYeach + iQty;
        
        float iCost = [(self.arrGenerateOrderData)[iArr][@"CostPrice"] floatValue ];
        totalCostPrice = totalCostPrice + (iQty * iCost);
        
    }
    
    _lblTotalItem.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.arrGenerateOrderData.count];
    _lblTotalReOrderQTY.text = [NSString stringWithFormat:@"%.0f",totalQTYeach];
    _lblTotalCost.text = [NSString stringWithFormat:@"%.2f",totalCostPrice];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [_uvItemInformation setHidden:NO];
        _uvItemInformation.frame = CGRectMake(_uvItemInformation.frame.origin.x, _uvItemInformation.frame.origin.y, 320.0, 163.0);
        [self.view bringSubviewToFront:_uvItemInformation];
    }
    else
    {
        if (infopopoverController)
        {
            [itemInformationViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [_uvItemInformation removeFromSuperview];
        _uvItemInformation.hidden = NO;
        itemInformationViewController.view = _uvItemInformation;
        
        // Present the view controller using the popover style.
        itemInformationViewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:itemInformationViewController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        infopopoverController = [itemInformationViewController popoverPresentationController];
        infopopoverController.delegate = self;
        itemInformationViewController.preferredContentSize = CGSizeMake(itemInformationViewController.view.frame.size.width, itemInformationViewController.view.frame.size.height);
        infopopoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        infopopoverController.sourceView = self.view;
        infopopoverController.sourceRect = CGRectMake(self.btnTotalItemInfo.frame.origin.x,
                                                      653,
                                                      self.btnTotalItemInfo.frame.size.width,
                                                      self.btnTotalItemInfo.frame.size.height);
    }
}
-(IBAction)hideItemInfoview:(id)sender{
    [_uvItemInformation setHidden:YES];
}

-(IBAction)btnGenerateOdrInfoClick:(id)sender
{
    if(!isPoUpdate) // Update existing Purchase order
    {
        
        if(self.strPopUpFromDate.length > 0)
            self.lblPopUpFromDate.text = [NSString stringWithFormat:@"From Date: %@",self.strPopUpFromDate];
        else
            self.lblPopUpFromDate.text = @"";
        
        
        if(self.strPopUpToDate.length > 0)
            self.lblPopUpToDate.text = [NSString stringWithFormat:@"To Date: %@",self.strPopUpToDate];
        else
            self.lblPopUpToDate.text = @"";
        
        
        if(self.strPopUpTimeDuration.length > 0)
            self.lblPopUpTimeDuration.text = [NSString stringWithFormat:@"Time Duration: %@",self.strPopUpTimeDuration];
        else
            self.lblPopUpTimeDuration.text = @"Time Duration: None";
        
        
        self.lblPopUpDepartment.text = self.lblSelectedDepartment.text;
        self.lblPopUpSupplier.text = self.lblSelectedSupplier.text;
        
        if(self.tagString.length > 0)
            self.lblPopUpTags.text = [NSString stringWithFormat:@"Tags : %@",self.tagString];
        else
            self.lblPopUpTags.text = @"";
    }
    else
    {
        
        if(self.strPopUpFromDate.length > 0)
            self.lblPopUpFromDate.text = [NSString stringWithFormat:@"From Date: %@",self.strPopUpFromDate];
        else
            self.lblPopUpFromDate.text = @"";
        
        
        if(self.strPopUpToDate.length > 0)
            self.lblPopUpToDate.text = [NSString stringWithFormat:@"To Date: %@",self.strPopUpToDate];
        else
            self.lblPopUpToDate.text = @"";
        
        if(self.strPopUpTimeDuration.length > 0)
            self.lblPopUpTimeDuration.text = [NSString stringWithFormat:@"Time Duration: %@",self.strPopUpTimeDuration];
        else
            self.lblPopUpTimeDuration.text = @"None";
        
        
        if(self.strPopUpDepartment.length > 0)
            self.lblPopUpDepartment.text = [NSString stringWithFormat:@"Department: %@",self.strPopUpDepartment];
        else
            self.lblPopUpDepartment.text = @"";
        
        if(self.strPopUpSupplier.length > 0)
            self.lblPopUpSupplier.text = [NSString stringWithFormat:@"Supplier: %@",self.strPopUpSupplier];
        else
            self.lblPopUpSupplier.text = @"";
        
        if(self.strPopUpTags.length > 0)
            self.lblPopUpTags.text = [NSString stringWithFormat:@"Tags: %@",self.strPopUpTags];
        else
            self.lblPopUpTags.text = @"";
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [_uvGenerateOrderInfo setHidden:NO];
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if(screenBounds.size.height == 568)
            {
                _uvGenerateOrderInfo.frame = CGRectMake(0, 231, 320.0, 288.0);
            }
            else{
                _uvGenerateOrderInfo.frame = CGRectMake(0, 173, 320.0, 258.0);
                
            }
        }
        [self.view bringSubviewToFront:_uvGenerateOrderInfo];
    }
    else
    {
        if (infopopoverController)
        {
            [orderInfoViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [_uvGenerateOrderInfo removeFromSuperview];
        _uvGenerateOrderInfo.hidden = NO;
        orderInfoViewController.view = _uvGenerateOrderInfo;
        
        // Present the view controller using the popover style.
        orderInfoViewController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:orderInfoViewController animated:YES completion:nil];
        
        // Get the popover presentation controller and configure it.
        infopopoverController = [orderInfoViewController popoverPresentationController];
        infopopoverController.delegate = self;
        orderInfoViewController.preferredContentSize = CGSizeMake(orderInfoViewController.view.frame.size.width, orderInfoViewController.view.frame.size.height);
        infopopoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        infopopoverController.sourceView = self.view;
        infopopoverController.sourceRect = CGRectMake(self.btnGenereteOdrinfo.frame.origin.x,
                                                      653,
                                                      self.btnGenereteOdrinfo.frame.size.width,
                                                      self.btnGenereteOdrinfo.frame.size.height);
    }
}
-(IBAction)generateorderinfocancel:(id)sender{
    [_uvGenerateOrderInfo setHidden:YES];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _tblOrderType)
        return 1;
    else if(tableView == self.tblGenerateOdrData)
        return 1;
    else if(tableView == _tblGenerateOrder)
        return 6;
    
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tblOrderType)
    {
        return generateOrderTypeArray.count;
    }
    else if(tableView == self.tblGenerateOdrData)
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if(self.arrGenerateOrderData.count>0)
            {
                return self.arrGenerateOrderData.count+1;
            }
            else{
                return 1;
            }
        }
        else{
            
            return self.arrGenerateOrderData.count;
        }
        
    }
    else if(tableView == _tblGenerateOrder)
    {
        if (section == 0)  // Date Wise
        {
            if([self.strOrderTyp isEqualToString:@"DateWise"]){
                
                return 3;
            }
            else{
                return 1;
            }
            
        }
        else if (section == 1)  // Department , supplier & Group
        {
            if(self.arrSelectedDepartment.count>0 && self.arrSelectedSupplier.count>0 && self.arrSelectedGroup.count>0)
            {
                return 6;
            }
            else if(self.arrSelectedDepartment.count>0 && self.arrSelectedSupplier.count>0)
            {
                return 5;
            }
            else if(self.arrSelectedDepartment.count>0 && self.arrSelectedGroup.count>0)
            {
                return 5;
            }
            else if(self.arrSelectedSupplier.count>0 && self.arrSelectedGroup.count>0)
            {
                return 5;
            }
            else if(self.arrSelectedSupplier.count>0 || self.arrSelectedGroup.count>0 || self.arrSelectedDepartment.count>0)
            {
                return 4;
            }
            else
            {
                return 3;
            }
            
        }
        else if (section == 2)  // minimum Stock
        {
            return 2;
        }
        else if (section == 3)  //  Tag
        {
            if(self.arrayTagList.count>0)
            {
                return 2;
            }
            else{
                return 1;
            }
            
        }
        else if (section == 4)  //  Generate Order Button
        {
            return 1;
            
        }
        else
            
        {
            return 1;
        }
    }
    else if(tableView==tblDeptsupplierlist){
        
        if(self.arrSelectedDepartment.count)
        {
            return self.arrSelectedDepartment.count;
        }
        else{
            return 1;
        }
    }
    else if(tableView==tblsupplierlist){
        
        if(self.arrSelectedSupplier.count)
        {
            return self.arrSelectedSupplier.count;
        }
        else{
            return 1;
        }
    }
    else if(tableView==tblGrouplist){
        
        if(self.arrSelectedGroup.count)
        {
            return self.arrSelectedGroup.count;
        }
        else{
            return 1;
        }
    }
    
    else
        return 1;
    
}

-(void)ItemLabel:(UILabel *)sender
{
    sender.numberOfLines = 0;
    sender.textAlignment = NSTextAlignmentLeft;
    sender.backgroundColor = [UIColor clearColor];
    sender.textColor = [UIColor blackColor];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
}


- (void)OpenOrderItemList:(NSIndexPath *)indexPath generateOrdPocell:(GenerateOrderPoCell *)generateOrdPocell cell_p:(UITableViewCell **)cell_p
{
    generateOrdPocell.lblTitle.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"ItemName"]];
    
    if([[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Barcode"] isKindOfClass:[NSString class]])
    {
        if([[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@""] || [[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@"<null>"])
        {
            
            generateOrdPocell.lblBarcode.text=@"";
        }
        else
        {
            generateOrdPocell.lblBarcode.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Barcode"]];
            
        }
    }
    else
    {
        
        generateOrdPocell.lblBarcode.text=@"";
    }
    
    generateOrdPocell.lblsoldqty.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"Sold"]];
    
    generateOrdPocell.lblavailableqty.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"avaibleQty"]];
    
    
    generateOrdPocell.txtReorder.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"ReOrder"]];
    generateOrdPocell.txtReorder.delegate = self;
    generateOrdPocell.txtReorder.tag = indexPath.row;
    generateOrdPocell.txtReorder.keyboardType = UIKeyboardTypeNumberPad;
    generateOrdPocell.txtReorder.textAlignment = NSTextAlignmentCenter;
    generateOrdPocell.txtReorder.layer.borderWidth = 1.0;
    generateOrdPocell.txtReorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    generateOrdPocell.lblmax.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"MaxStockLevel"]];
    
    
    generateOrdPocell.lblmin.text=[NSString stringWithFormat:@"%@",[(self.arrGenerateOrderData)[indexPath.row] valueForKey:@"MinStockLevel"]];
    
    
    [generateOrdPocell.btnItemInfo addTarget:self
                                      action:@selector(itemInfoTapped:) forControlEvents:UIControlEventTouchDown];
    
    generateOrdPocell.btnItemInfo.tag = indexPath.row;
    *cell_p=generateOrdPocell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    if(tableView == _tblOrderType)
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            cell.textLabel.text=[NSString stringWithFormat: @"%@",generateOrderTypeArray[indexPath.row]];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        }
    }
    else if(tableView == self.tblGenerateOdrData)
    {
        if(self.arrGenerateOrderData.count > 0)
        {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ItemName" ascending:YES];
            [self.arrGenerateOrderData sortUsingDescriptors:@[sort]];
            
            //            if ([[UIDevice currentDevice]  userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            //            {
            //
            NSString *cellIdentifier = @"Generateorderpocell";
            
            GenerateOrderPoCell *generateOrdPocell = (GenerateOrderPoCell *)[self.tblGenerateOdrData dequeueReusableCellWithIdentifier:cellIdentifier];
            
            generateOrdPocell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                if(indexPath.row==0)
                {
                    UIView *viewborder = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1)];
                    viewborder.backgroundColor=[UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
                    _txtPOTitle.frame=CGRectMake(15.0, 4.0, 208.0, 20.0);
                    _lblPODate.frame=CGRectMake(15.0, 22.0, 209.0, 20.0);
                    
                    if(_txtPOTitle.text.length>0)
                    {
                        _txtPOTitle.text=_txtPOTitle.text;
                        
                    }
                    else{
                        _txtPOTitle.placeholder=@"Enter Work Order";
                    }
                    
                    if(isPoUpdate)
                    {
                        _lblAutoGenPO.frame=CGRectMake(15.0, 4.0, 208.0, 20.0);
                    }
                    
                    [cell addSubview:_txtPOTitle];
                    [cell addSubview:_lblPODate];
                    [cell addSubview:_lblAutoGenPO];
                    [cell addSubview:viewborder];
                    
                    return cell;
                }
                else{
                    
                    NSIndexPath *tempPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
                    [self OpenOrderItemList:tempPath generateOrdPocell:generateOrdPocell cell_p:&cell];
                    
                }
            }
            else{
                
                [self OpenOrderItemList:indexPath generateOrdPocell:generateOrdPocell cell_p:&cell];
                
            }
            return cell;
        }
        else{
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                
                if(indexPath.row==0)
                {
                    UIView *viewborder = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1)];
                    viewborder.backgroundColor=[UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
                    _txtPOTitle.frame=CGRectMake(15.0, 4.0, 208.0, 20.0);
                    _lblPODate.frame=CGRectMake(15.0, 22.0, 209.0, 20.0);
                    
                    if(_txtPOTitle.text.length>0)
                    {
                        _txtPOTitle.text=_txtPOTitle.text;
                        
                    }
                    else{
                        _txtPOTitle.placeholder=@"Enter Work Order";
                    }
                    
                    [cell addSubview:_txtPOTitle];
                    [cell addSubview:_lblPODate];
                    [cell addSubview:viewborder];
                    
                    return cell;
                }
                
                
            }
            
        }
    }
    else if(tableView==_tblGenerateOrder)
    {
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *cellGenerate = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
        cellGenerate.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cellGenerate.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl=nil;
        for(lbl in cellGenerate.subviews){
            if([lbl isKindOfClass:[UILabel class]]){
                [lbl removeFromSuperview];
            }
        }
        
        if(indexPath.section==0){
            
            if(indexPath.row==0){
                
                UIImageView* img;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                    img.frame = CGRectMake(0, 0, 684, 44);
                    cellGenerate.backgroundView = img;
                    
                }
                else
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                    img.frame = CGRectMake(0, 0, 984, 44);
                    [cellGenerate addSubview:img];
                }
                
                UILabel *lblName = [[UILabel alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    lblName.frame=CGRectMake(20, 7, 88, 30);
                }
                else{
                    lblName.frame=CGRectMake(20, 7, 100, 30);
                }
                lblName.text = @"Select Date";
                [self setLabelProperty:lblName fontSize:14];
                lblName.textAlignment=NSTextAlignmentLeft;
                [cellGenerate addSubview:lblName];
                
                
                UILabel *lblOrderTypeTemp = [[UILabel alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    lblOrderTypeTemp.frame=CGRectMake(175, 7, 100, 30);
                }
                else{
                    lblOrderTypeTemp.frame=CGRectMake(846, 7, 100, 30);
                }
                if(self.strOrderTyp)
                {
                    lblOrderTypeTemp.text = self.strOrderTyp;
                }
                else{
                    lblOrderTypeTemp.text = @"None";
                }
                
                lblOrderTypeTemp.tag=110;
                [self setLabelPropertyRight:lblOrderTypeTemp fontSize:14.0];
                [cellGenerate addSubview:lblOrderTypeTemp];
                
                UIImageView *imgArrow = [[UIImageView alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    imgArrow.frame=CGRectMake(295, 15, 8, 14);
                }
                else{
                    imgArrow.frame=CGRectMake(957, 15, 8, 14);
                }
                
                imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                
                [cellGenerate addSubview:imgArrow];
                
            }
            else if(indexPath.row==1){
                
                UIImageView* img;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                    img.frame = CGRectMake(0, 0, 684, 44);
                    cellGenerate.backgroundView = img;
                    
                }
                else
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBgWhite.png"]];
                    img.frame = CGRectMake(0, 0, 1024, 44);
                    [cellGenerate addSubview:img];
                }
                
                UILabel *lblFrom = [[UILabel alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    lblFrom.frame=CGRectMake(20, 7, 88, 30);
                }
                else{
                    lblFrom.frame=CGRectMake(20, 7, 100, 30);
                }
                lblFrom.text = @"From Date:";
                [self setLabelProperty:lblFrom fontSize:14.0];
                lblFrom.textAlignment=NSTextAlignmentLeft;
                [cellGenerate addSubview:lblFrom];
                
                
                UILabel *fromDateLabel = [[UILabel alloc] init];
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    fromDateLabel.frame=CGRectMake(175, 7, 100, 30);
                }
                else{
                    fromDateLabel.frame=CGRectMake(845, 7, 100, 30);
                }
                
                if(self.strFromDate){
                    fromDateLabel.text = self.strFromDate;
                }
                else{
                    fromDateLabel.text = @"Select Date";
                }
                
                
                [self setLabelProperty:fromDateLabel fontSize:14];
                fromDateLabel.textColor=[UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
                [cellGenerate addSubview:fromDateLabel];
                
                UIImageView *imgArrow = [[UIImageView alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    imgArrow.frame=CGRectMake(295, 15, 8, 14);
                }
                else{
                    imgArrow.frame=CGRectMake(957, 15, 8, 14);
                }
                
                imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                
                [cellGenerate addSubview:imgArrow];
                
            }
            else if(indexPath.row==2){
                
                UIImageView* img;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                    img.frame = CGRectMake(0, 0, 684, 44);
                    cellGenerate.backgroundView = img;
                    
                }
                else
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBgWhite.png"]];
                    img.frame = CGRectMake(0, 0, 1024, 44);
                    [cellGenerate addSubview:img];
                }
                
                UILabel *lblTo = [[UILabel alloc] init];
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    lblTo.frame=CGRectMake(20, 7, 88, 30);
                }
                else{
                    lblTo.frame=CGRectMake(20, 10, 100, 30);
                }
                lblTo.text = @"To Date:";
                [self setLabelProperty:lblTo fontSize:14];
                lblTo.textAlignment=NSTextAlignmentLeft;
                [cellGenerate addSubview:lblTo];
                
                
                UILabel *toDateLabel = [[UILabel alloc] init];
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    toDateLabel.frame=CGRectMake(175, 7, 100, 30);
                }
                else{
                    toDateLabel.frame=CGRectMake(845, 7, 100, 30);
                }
                
                
                if(self.strToDate){
                    toDateLabel.text = self.strToDate;
                }
                else{
                    toDateLabel.text = @"Select Date";
                }
                
                [self setLabelProperty:toDateLabel fontSize:14];
                toDateLabel.textColor=[UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
                [cellGenerate addSubview:toDateLabel];
                
                UIImageView *imgArrow = [[UIImageView alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    imgArrow.frame=CGRectMake(295, 15, 8, 14);
                }
                else{
                    imgArrow.frame=CGRectMake(957, 15, 8, 14);
                }
                
                imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                
                [cellGenerate addSubview:imgArrow];
                
            }
            
            
        }
        else if(indexPath.section==1){
            
            if(self.arrSelectedDepartment.count>0 && self.arrSelectedSupplier.count>0 && self.arrSelectedGroup.count>0)
            {
                if(indexPath.row==0){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 45);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblDept = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblDept.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblDept.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblDept.text = @"Department";
                    [self setLabelProperty:lblDept fontSize:14.0];
                    lblDept.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblDept];
                    
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                    
                    
                }
                else if(indexPath.row==1){
                    [cellGenerate addSubview:Deptsupplierview];
                    [cellGenerate bringSubviewToFront:Deptsupplierview];
                }
                else if(indexPath.row==2){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblSup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblSup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblSup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblSup.text = @"Supplier";
                    [self setLabelProperty:lblSup fontSize:14];
                    lblSup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblSup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if(indexPath.row==3){
                    [cellGenerate addSubview:supplierview];
                    [cellGenerate bringSubviewToFront:supplierview];
                }
                else if(indexPath.row==4){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblGroup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblGroup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblGroup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblGroup.text = @"Group";
                    [self setLabelProperty:lblGroup fontSize:14];
                    lblGroup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblGroup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if(indexPath.row==5){
                    [cellGenerate addSubview:groupView];
                    [cellGenerate bringSubviewToFront:groupView];
                }
            }

            else if(self.arrSelectedDepartment.count>0 && self.arrSelectedSupplier.count>0)
            {
                if(indexPath.row==0){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 45);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblDept = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblDept.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblDept.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblDept.text = @"Department";
                    [self setLabelProperty:lblDept fontSize:14.0];
                    lblDept.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblDept];
                    
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                    
                    
                }
                else if(indexPath.row==1){
                    [cellGenerate addSubview:Deptsupplierview];
                    [cellGenerate bringSubviewToFront:Deptsupplierview];
                }
                else if(indexPath.row==2){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblSup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblSup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblSup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblSup.text = @"Supplier";
                    [self setLabelProperty:lblSup fontSize:14];
                    lblSup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblSup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if(indexPath.row==3){
                    [cellGenerate addSubview:supplierview];
                    [cellGenerate bringSubviewToFront:supplierview];
                }
                else if (indexPath.row==4){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblGroup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblGroup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblGroup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblGroup.text = @"Group";
                    [self setLabelProperty:lblGroup fontSize:14];
                    lblGroup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblGroup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
            }
            
            else if(self.arrSelectedDepartment.count>0 && self.arrSelectedGroup.count>0)
            {
                if(indexPath.row==0){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 45);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblDept = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblDept.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblDept.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblDept.text = @"Department";
                    [self setLabelProperty:lblDept fontSize:14.0];
                    lblDept.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblDept];
                    
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                    
                    
                }
                else if(indexPath.row==1){
                    [cellGenerate addSubview:Deptsupplierview];
                    [cellGenerate bringSubviewToFront:Deptsupplierview];
                }
                else if(indexPath.row==2){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblSup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblSup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblSup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblSup.text = @"Supplier";
                    [self setLabelProperty:lblSup fontSize:14];
                    lblSup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblSup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if (indexPath.row==3){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblGroup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblGroup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblGroup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblGroup.text = @"Group";
                    [self setLabelProperty:lblGroup fontSize:14];
                    lblGroup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblGroup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if (indexPath.row==4){
                    [cellGenerate addSubview:groupView];
                    [cellGenerate bringSubviewToFront:groupView];
                }
            }

            else if(self.arrSelectedSupplier.count>0 && self.arrSelectedGroup.count>0)
            {
                if(indexPath.row==0){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 45);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblDept = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblDept.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblDept.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblDept.text = @"Department";
                    [self setLabelProperty:lblDept fontSize:14.0];
                    lblDept.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblDept];
                    
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                    
                    
                }
                else if(indexPath.row==1){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblSup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblSup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblSup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblSup.text = @"Supplier";
                    [self setLabelProperty:lblSup fontSize:14];
                    lblSup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblSup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if(indexPath.row==2){
                    [cellGenerate addSubview:supplierview];
                    [cellGenerate bringSubviewToFront:supplierview];
                }
                else if(indexPath.row==3){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblGroup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblGroup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblGroup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblGroup.text = @"Group";
                    [self setLabelProperty:lblGroup fontSize:14];
                    lblGroup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblGroup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if (indexPath.row==4){
                    [cellGenerate addSubview:groupView];
                    [cellGenerate bringSubviewToFront:groupView];
                }
            }
            
            else if(self.arrSelectedDepartment.count>0)
            {
                if(indexPath.row==0){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblDept = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblDept.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblDept.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblDept.text = @"Department";
                    [self setLabelProperty:lblDept fontSize:14.0];
                    lblDept.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblDept];
                    
                    
                    //               UILabel *lblDeptAdd = [[UILabel alloc] initWithFrame:CGRectMake(495, 7, 150, 30)];
                    //               [lblDeptAdd setText:@"Add Department"];
                    //               [self setLabelPropertyRight:lblDeptAdd fontSize:14.0];
                    //               [cellGenerate addSubview:lblDeptAdd];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                    
                    
                }
                else if(indexPath.row==1){
                    
                    [cellGenerate addSubview:Deptsupplierview];
                    [cellGenerate bringSubviewToFront:Deptsupplierview];
                    
                }
                else if(indexPath.row==2){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblSup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblSup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblSup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblSup.text = @"Supplier";
                    [self setLabelProperty:lblSup fontSize:14];
                    lblSup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblSup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if (indexPath.row == 3){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblGroup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblGroup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblGroup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblGroup.text = @"Group";
                    [self setLabelProperty:lblGroup fontSize:14];
                    lblGroup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblGroup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
            }
            
            else if(self.arrSelectedSupplier.count>0)
            {
                if(indexPath.row==0){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblDept = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblDept.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblDept.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblDept.text = @"Department";
                    [self setLabelProperty:lblDept fontSize:14.0];
                    lblDept.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblDept];
                    
                    
                    //               UILabel *lblDeptAdd = [[UILabel alloc] initWithFrame:CGRectMake(495, 7, 150, 30)];
                    //               [lblDeptAdd setText:@"Add Department"];
                    //               [self setLabelPropertyRight:lblDeptAdd fontSize:14.0];
                    //               [cellGenerate addSubview:lblDeptAdd];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                    
                    
                }
                else if(indexPath.row==1){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblSup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblSup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblSup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblSup.text = @"Supplier";
                    [self setLabelProperty:lblSup fontSize:14];
                    lblSup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblSup];
                    
                    
                    //               UILabel *lblSupAdd = [[UILabel alloc] initWithFrame:CGRectMake(545, 7, 100, 30)];
                    //               [lblSupAdd setText:@"Add Supplier"];
                    //               [self setLabelPropertyRight:lblSupAdd fontSize:14];
                    //               [cellGenerate addSubview:lblSupAdd];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if(indexPath.row==2){
                    
                    [cellGenerate addSubview:supplierview];
                    [cellGenerate bringSubviewToFront:supplierview];
                }
                
                else if (indexPath.row == 3){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblGroup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblGroup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblGroup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblGroup.text = @"Group";
                    [self setLabelProperty:lblGroup fontSize:14];
                    lblGroup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblGroup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                
            }
            
            else if(self.arrSelectedGroup.count>0)
            {
                if(indexPath.row==0){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblDept = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblDept.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblDept.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblDept.text = @"Department";
                    [self setLabelProperty:lblDept fontSize:14.0];
                    lblDept.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblDept];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if(indexPath.row==1){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblSup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblSup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblSup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblSup.text = @"Supplier";
                    [self setLabelProperty:lblSup fontSize:14];
                    lblSup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblSup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if(indexPath.row==2){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblGroup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblGroup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblGroup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblGroup.text = @"Group";
                    [self setLabelProperty:lblGroup fontSize:14];
                    lblGroup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblGroup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if (indexPath.row==3){
                    [cellGenerate addSubview:groupView];
                    [cellGenerate bringSubviewToFront:groupView];
                }
            }

            else{
                
                if(indexPath.row==0){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblDept = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblDept.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblDept.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblDept.text = @"Department";
                    [self setLabelProperty:lblDept fontSize:14.0];
                    lblDept.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblDept];
                    
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                    
                    
                }
                else if(indexPath.row==1){
                    
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, 0, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    
                    UILabel *lblSup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblSup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblSup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblSup.text = @"Supplier";
                    [self setLabelProperty:lblSup fontSize:14];
                    lblSup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblSup];
                    
                    
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                else if (indexPath.row == 2){
                    UIImageView* img;
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                        img.frame = CGRectMake(0, 0, 684, 44);
                        cellGenerate.backgroundView = img;
                        
                    }
                    else
                    {
                        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                        img.frame = CGRectMake(0, -1, 984, 44);
                        [cellGenerate addSubview:img];
                    }
                    
                    UILabel *lblGroup = [[UILabel alloc] init];
                    
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        lblGroup.frame=CGRectMake(20, 7, 88, 30);
                    }
                    else{
                        lblGroup.frame=CGRectMake(20, 7, 100, 30);
                    }
                    
                    lblGroup.text = @"Group";
                    [self setLabelProperty:lblGroup fontSize:14];
                    lblGroup.textAlignment=NSTextAlignmentLeft;
                    [cellGenerate addSubview:lblGroup];
                    
                    UIImageView *imgArrow = [[UIImageView alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        imgArrow.frame=CGRectMake(295, 15, 8, 14);
                    }
                    else{
                        imgArrow.frame=CGRectMake(957, 15, 8, 14);
                    }
                    
                    imgArrow.image = [UIImage imageNamed:@"ArrowRightNormal.png"];
                    
                    [cellGenerate addSubview:imgArrow];
                }
                
            }
            
        }
        else if(indexPath.section==2){
            
            if(indexPath.row==0){
                UIImageView* img;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                    img.frame = CGRectMake(0, 0, 684, 44);
                    cellGenerate.backgroundView = img;
                }
                else
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                    img.frame = CGRectMake(0, 0, 984, 44);
                    [cellGenerate addSubview:img];
                }
                
                UILabel *lblMinStock = [[UILabel alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    lblMinStock.frame=CGRectMake(20, 2, 88, 40);
                    lblMinStock.numberOfLines=2;
                }
                else{
                    lblMinStock.frame=CGRectMake(20, 7, 130, 30);
                }
                lblMinStock.text = @"Minimum Stock";
                [self setLabelProperty:lblMinStock fontSize:14];
                lblMinStock.textAlignment=NSTextAlignmentLeft;
                [cellGenerate addSubview:lblMinStock];
                
                [onOffSwitch addTarget:self action:@selector(btnIsMinStockClick:) forControlEvents:UIControlEventValueChanged];
                [cellGenerate addSubview:onOffSwitch];
            }
            else if(indexPath.row==1){
                UIImageView* img;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                    img.frame = CGRectMake(0, 0, 684, 44);
                    cellGenerate.backgroundView = img;
                }
                else
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                    img.frame = CGRectMake(0, 0, 984, 44);
                    [cellGenerate addSubview:img];
                }
                
                UILabel *lblMinQty = [[UILabel alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    lblMinQty.frame=CGRectMake(20, 2, 88, 40);
                    lblMinQty.numberOfLines=2;
                }
                else{
                    lblMinQty.frame=CGRectMake(20, 7, 140, 30);
                }
                lblMinQty.text = @"Minimum Quantity";
                [self setLabelProperty:lblMinQty fontSize:14];
                lblMinQty.textAlignment=NSTextAlignmentLeft;
                [cellGenerate addSubview:lblMinQty];
                
                UITextField *txtMinQty = [[UITextField alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    txtMinQty.frame=CGRectMake(120, 7, 180.0, 30);
                }
                else
                {
                    txtMinQty.frame=CGRectMake(280, 3, 680, 38);
                }
                txtMinQty.text = @"0";
                txtMinQty.textAlignment = NSTextAlignmentRight;
                [cellGenerate addSubview:txtMinQty];
            }
        }
        else if(indexPath.section==3){
            if(indexPath.row==0){
                UIImageView* img;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                    img.frame = CGRectMake(0, 0, 684, 44);
                    cellGenerate.backgroundView = img;
                }
                else
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purchase_Order_FormRowBg.png"]];
                    img.frame = CGRectMake(0, 0, 984, 44);
                    [cellGenerate addSubview:img];
                }
                
                UILabel *lblTag = [[UILabel alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    lblTag.frame=CGRectMake(20, 7, 88, 30);
                }
                else
                {
                    lblTag.frame=CGRectMake(20, 7, 130, 30);
                }
                lblTag.text = @"Tag";
                [self setLabelProperty:lblTag fontSize:14];
                lblTag.textAlignment=NSTextAlignmentLeft;
                [cellGenerate addSubview:lblTag];
                
                _txtTagName = [[UITextField alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    _txtTagName.frame=CGRectMake(120, 7, 500, 30);
                }
                else
                {
                    _txtTagName.frame=CGRectMake(220, 3, 680, 38);
                }
                
                _txtTagName.tag = ItemtextFieldsTagItemTag;
                _txtTagName.delegate = self;
                _txtTagName.text = selectedTag;
                [cellGenerate addSubview:_txtTagName];
            }
            if(indexPath.row==1){
                if(self.arrayTagList>0){
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        tagList.frame = CGRectMake(0, 5, 280, 50);
                    }
                    else{
                        tagList.frame = CGRectMake(10, 5, 650, 50);
                    }
                    [cellGenerate addSubview:tagList];
                }
            }
        }
        else if(indexPath.section==4){
            
            if(indexPath.row==0){
                
                
                UIImageView* img;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBg_iphone.png"]];
                    img.frame = CGRectMake(0, 0, 684, 44);
                    cellGenerate.backgroundView = img;
                    
                }
                else
                {
                    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FormRowBgWhite.png"]];
                    img.frame = CGRectMake(0, 0, 1024, 44);
                    [cellGenerate addSubview:img];
                }
                
                
                UILabel *lblBacktoOpenlist = [[UILabel alloc] init];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    lblBacktoOpenlist.frame=CGRectMake(20, 2, 88, 40);
                    lblBacktoOpenlist.numberOfLines=2;
                }
                else{
                    lblBacktoOpenlist.frame=CGRectMake(20, 7, 130, 30);
                }
                lblBacktoOpenlist.text = @"Open Back List Data";
                [self setLabelProperty:lblBacktoOpenlist fontSize:14];
                lblBacktoOpenlist.textAlignment=NSTextAlignmentLeft;
                [cellGenerate addSubview:lblBacktoOpenlist];
                
            }
        }
        else if(indexPath.section==5){
            
            if(indexPath.row==0){
                
                UIButton *btnGenerateOrdertCell = [UIButton buttonWithType:UIButtonTypeCustom];
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    btnGenerateOrdertCell.frame=CGRectMake(0.0, 0.0, 320, 44);
                    [btnGenerateOrdertCell setImage:[UIImage imageNamed:@"generateOrderBtn_po_iPhone_new.png"] forState:UIControlStateNormal];
                }
                else{
                    btnGenerateOrdertCell.frame=CGRectMake(0.0, 0.0, 1024, 44);
                    [btnGenerateOrdertCell setBackgroundImage:[UIImage imageNamed:@"globalgreen.png"] forState:UIControlStateNormal];
                    [btnGenerateOrdertCell setTitle:@"Generate Order" forState:UIControlStateNormal];
                }
                
                [btnGenerateOrdertCell addTarget:self action:@selector(btnGenerateOrderClick:) forControlEvents:UIControlEventTouchUpInside];
                [cellGenerate addSubview:btnGenerateOrdertCell];
                
            }
        }
        
        
        return cellGenerate;
    }
    
    else if(tableView==tblDeptsupplierlist)
    {
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *cellDeptSupplier = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"DeptSupplier"];
        cellDeptSupplier.selectionStyle = UITableViewCellSelectionStyleNone;
        cellDeptSupplier.backgroundColor = [UIColor clearColor];
        UILabel *lbl=nil;
        for(lbl in cellDeptSupplier.subviews){
            if([lbl isKindOfClass:[UILabel class]]){
                [lbl removeFromSuperview];
            }
        }
        NSMutableArray *itemarray=[self.arrSelectedDepartment mutableCopy];
        UILabel * suppname = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 220, 20)];
        suppname.text = itemarray[indexPath.row][@"DepartmentName"];
        suppname.backgroundColor = [UIColor clearColor];
        suppname.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        suppname.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        [cellDeptSupplier.contentView addSubview:suppname];
        
        return cellDeptSupplier;
    }
    
    else if(tableView==tblsupplierlist)
    {
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *cellDeptSupplier = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"DeptSupplier"];
        cellDeptSupplier.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cellDeptSupplier.backgroundColor = [UIColor clearColor];
        
        NSMutableArray *itemarraySup=[self.arrSelectedSupplier mutableCopy];
        UILabel * suppcomp = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 220, 20)];
        suppcomp.text = itemarraySup[indexPath.row][@"SupplierName"];
        suppcomp.backgroundColor = [UIColor clearColor];
        suppcomp.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        suppcomp.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        [cellDeptSupplier.contentView addSubview:suppcomp];
        
        return cellDeptSupplier;
    }
    else if(tableView==tblGrouplist)
    {
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *cellGrouplist = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"Grouplist"];
        cellGrouplist.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cellGrouplist.backgroundColor = [UIColor clearColor];
        
        NSMutableArray *itemGroupArray=[self.arrSelectedGroup mutableCopy];
        UILabel * lblGroup = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 220, 20)];
        lblGroup.text = itemGroupArray[indexPath.row][@"groupName"];
        lblGroup.backgroundColor = [UIColor clearColor];
        lblGroup.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:170.0/255.0 alpha:1.0];
        lblGroup.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        [cellGrouplist.contentView addSubview:lblGroup];
        
        return cellGrouplist;
    }

    
    return cell;
}

-(void)setLabelProperty:(UILabel *)sender fontSize:(int)psize;
{
    sender.textColor = [UIColor blackColor];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:psize];
    sender.backgroundColor = [UIColor clearColor];
    sender.tintColor = [UIColor blackColor];
    sender.textAlignment=NSTextAlignmentRight;
}

-(void)setLabelPropertyRight:(UILabel *)sender fontSize:(int)psize;
{
    sender.textColor = [UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:psize];
    sender.backgroundColor = [UIColor clearColor];
    sender.tintColor = [UIColor blackColor];
    sender.textAlignment=NSTextAlignmentRight;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == _tblGenerateOrder)
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if(section==0)
                return @"     Generate Order";
            
        }
        else{
            if(section==0)
                return @" Generate Order";
        }
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tblOrderType)
    {
        [self didSelectGenerateOrderTypeFromArray:generateOrderTypeArray withIndexPath:indexPath];
    }
    else if(tableView == _tblGenerateOrder){
        
        if(indexPath.section==0){
            
            if(indexPath.row==0){
                
                UITableViewCell *cell = (UITableViewCell *)[_tblGenerateOrder cellForRowAtIndexPath:indexPath];
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    if(_uvOrderTypes.hidden==YES)
                    {
                        _uvOrderTypes.frame=CGRectMake(170, cell.frame.origin.y+108, _uvOrderTypes.frame.size.width, _uvOrderTypes.frame.size.height);
                        _uvDatePicker.hidden = YES;
                        [self btnOrderTypeClick:nil];
                        
                        //[cell.contentView addSubview:_uvOrderTypes];
                    }
                    else{
                        _uvOrderTypes.hidden = YES;
                        _uvDatePicker.hidden = YES;
                        _tblGenerateOrder.scrollEnabled=YES;
                    }
                }
                else
                {
                    [self showGenerateOrderTypePopUpWithIndexPath:indexPath];
                }
            }
            else if(indexPath.row==1){
                UITableViewCell *cell = [_tblGenerateOrder cellForRowAtIndexPath:indexPath];
                _uvOrderTypes.hidden = YES;
                _datePickerView.minimumDate=nil;
                [self btnFromDateClick:cell];
            }
            else if(indexPath.row==2){
                _uvOrderTypes.hidden = YES;
                _datePickerView.maximumDate=nil;
                UITableViewCell *cell = [_tblGenerateOrder cellForRowAtIndexPath:indexPath];
                [self btnToDateClick:cell];
            }
            
        }
        else if(indexPath.section==1){
            
            if(self.arrSelectedDepartment.count>0 && self.arrSelectedSupplier.count>0 && self.arrSelectedGroup.count>0)
            {
                if(indexPath.row == 0){
                    [self openDepartmentSelectionView];
                }
                if(indexPath.row==2){
                    [self openSupplierSelectionView];
                }
                if(indexPath.row==4){
                    [self openGroupSelectionView];
                }
            }
            
            else if(self.arrSelectedDepartment.count>0 && self.arrSelectedSupplier.count>0)
            {
                if(indexPath.row == 0){
                    [self openDepartmentSelectionView];
                }
                if(indexPath.row==2){
                    [self openSupplierSelectionView];
                }
                if(indexPath.row==4){
                    [self openGroupSelectionView];
                }
            }
            
            else if(self.arrSelectedDepartment.count>0 && self.arrSelectedGroup.count>0)
            {
                if(indexPath.row == 0){
                    [self openDepartmentSelectionView];
                }
                if(indexPath.row==2){
                    [self openSupplierSelectionView];
                }
                if(indexPath.row==3){
                    [self openGroupSelectionView];
                }
            }
            
            else if(self.arrSelectedSupplier.count>0 && self.arrSelectedGroup.count>0)
            {
                if(indexPath.row == 0){
                    [self openDepartmentSelectionView];
                }
                if(indexPath.row==1){
                    [self openSupplierSelectionView];
                }
                if(indexPath.row==3){
                    [self openGroupSelectionView];
                }
            }
            
            else if(self.arrSelectedDepartment.count>0)
            {
                if(indexPath.row == 0){
                    [self openDepartmentSelectionView];
                }
                if(indexPath.row==2){
                    [self openSupplierSelectionView];
                }
                if(indexPath.row==3){
                    [self openGroupSelectionView];
                }
            }
            else if(self.arrSelectedSupplier.count>0)
            {
                if(indexPath.row == 0){
                    [self openDepartmentSelectionView];
                }
                if(indexPath.row==1){
                    [self openSupplierSelectionView];
                }
                if(indexPath.row==3){
                    [self openGroupSelectionView];
                }
            }
            else{
                
                if(indexPath.row == 0){
                    [self openDepartmentSelectionView];
                }
                if(indexPath.row==1){
                    [self openSupplierSelectionView];
                }
                if(indexPath.row==2){
                    [self openGroupSelectionView];
                }
            }
        }
        
        else if(indexPath.section==4){
            
            if(indexPath.row==0)
            {
                [self getOpenBackListData];
            }
        }
    }
}

#pragma mark - Generate Order Type

- (void)showGenerateOrderTypePopUpWithIndexPath:(NSIndexPath *)indexPath
{
    generateOrderTypePopUpVC = [[GenerateOrderTypePopUpVC alloc] initWithNibName:@"GenerateOrderTypePopUpVC" bundle:nil];
    generateOrderTypePopUpVC.delegate = self;
    
    // Present the view controller using the popover style.
    generateOrderTypePopUpVC.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:generateOrderTypePopUpVC animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    generateOrderTypePopoverController = [generateOrderTypePopUpVC popoverPresentationController];
    generateOrderTypePopoverController.delegate = self;
    generateOrderTypePopUpVC.preferredContentSize = CGSizeMake(145, 280);
    generateOrderTypePopoverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    generateOrderTypePopoverController.sourceView = self.view;
    CGRect frame =  [_tblGenerateOrder rectForRowAtIndexPath:indexPath];
    frame.origin.x += frame.size.width/2 - 40 ;
    frame.origin.y -= 10 ;
    generateOrderTypePopoverController.sourceRect = frame;
}

- (void)didSelectGenerateOrderTypeFromArray:(NSArray *)arrGenerateOrderType withIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *orderTypeDict = @{kPOGenerateOrderSelectedTypeKey : arrGenerateOrderType[indexPath.row]};
    [Appsee addEvent:kPOGenerateOrderSelectedType withProperties:orderTypeDict];
    _lblOrderType.text=arrGenerateOrderType[indexPath.row];
    _uvOrderTypes.hidden=YES;
    _tblGenerateOrder.scrollEnabled=YES;
    if(indexPath.row == (arrGenerateOrderType.count - 1))
    {
        _uvHiddenDates.hidden = NO;
        _uvNextToDates.frame = CGRectMake(_uvNextToDates.frame.origin.x, _uvNextToDates.frame.origin.y+79, _uvNextToDates.frame.size.width, _uvNextToDates.frame.size.height);
        self.strFromDate = @"";
        self.strToDate = @"";
        self.strPopUpTimeDuration=_lblOrderType.text;
        self.strFromDate=nil;
        self.strToDate=nil;
        self.strOrderTyp=arrGenerateOrderType[indexPath.row];
        [_tblGenerateOrder reloadData];
    }
    else
    {
        self.strPopUpTimeDuration=_lblOrderType.text;
        _uvHiddenDates.hidden = YES;
        _uvNextToDates.frame = CGRectMake(_uvNextToDates.frame.origin.x, 16, _uvNextToDates.frame.size.width, _uvNextToDates.frame.size.height);
        self.strFromDate = @"";
        self.strToDate = @"";
        self.strOrderTyp=arrGenerateOrderType[indexPath.row];
        [_tblGenerateOrder reloadData];
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [generateOrderTypePopUpVC dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)openDepartmentSelectionView{
    [Appsee addEvent:kPOGenerateOrderDepartmentSelection];

    objDeptPop = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"DepartmentMultiple_sid"];
    
    objDeptPop.checkedDepartment = [self.arrSelectedDepartment mutableCopy];
    objDeptPop.isMultipleAllow = YES;
    objDeptPop.strItemcode=@"1";
//    objDeptPop.objGenerateOdr = self;
    objDeptPop.addDepartmentMultipleDelegate = self;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController pushViewController:objDeptPop animated:YES];
    }
    else{
//        [self._rimController.objPOMenuList.navigationController pushViewController:objDeptPop animated:YES];;
        [self.pOmenuListVCDelegate willPushViewController:objDeptPop animated:YES];
    }
//    [self.navigationController pushViewController:objDeptPop animated:YES];
}
- (void)openSupplierSelectionView{
    [Appsee addEvent:kPOGenerateOrderSupplierSelection];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        objSupplier = [[RimSupplierPagePO alloc] initWithNibName:@"RimSupplierPagePO" bundle:nil];
    }
    else {
        objSupplier = [[RimSupplierPagePO alloc] initWithNibName:@"RimSupplierPagePO_iPad" bundle:nil];
    }
    objSupplier.checkedSupplier = [self.arrSelectedSupplier mutableCopy ];
//    objSupplier.objGenerateOdr = self;
    objSupplier.rimSupplierPagePODelegate = self;
    objSupplier.strItemcode=@"1";
    objSupplier.callingFunction=@"Generate";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController pushViewController:objSupplier animated:YES];
    }
    else{
//        [self._rimController.objPOMenuList.navigationController pushViewController:objSupplier animated:YES];
        [self.pOmenuListVCDelegate willPushViewController:objSupplier animated:YES];
    }
}
- (void)openGroupSelectionView
{
    [Appsee addEvent:kPOGenerateOrderGroupSelection];
    [self.rmsDbController playButtonSound];

    GroupSelectionVC *groupSelectionVC = [[GroupSelectionVC alloc] initWithNibName:@"GroupSelectionVC" bundle:nil];
//    groupSelectionVC.generateOrderView = self;
    groupSelectionVC.groupSelectionVCDelegate = self;
    groupSelectionVC.callingFunction = @"GenerateOrderView";
    groupSelectionVC.checkedGroup = [self.arrSelectedGroup mutableCopy];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController pushViewController:groupSelectionVC animated:YES];
    }
    else{
//        [self._rimController.objPOMenuList.navigationController pushViewController:groupSelectionVC animated:YES];
        [self.pOmenuListVCDelegate willPushViewController:groupSelectionVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        if(section==0){
            
            if(tableView==_tblGenerateOrder){
                return 44;
            }
            else{
                return 0;
            }
            
        }
        return 22;
    }
    else
    {
        if(section==0){
            if(tableView==_tblGenerateOrder){
                return 54;
            }
            else{
                return 0;
            }
        }
        return 22;
        
    }
    return 22;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tblOrderType)
    {
        return 40;
    }
    else if(tableView == self.tblGenerateOdrData)
    {
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if(indexPath.row==0)
            {
                return 44.0;
            }
            else{
                return 134;
            }
            
        }
        else{
            return 73;
        }
        
    }
    else if(tableView == _tblGenerateOrder)
    {
        if(indexPath.section==1){
            
            if(self.arrSelectedDepartment.count>0 && self.arrSelectedSupplier.count>0)
            {
                if(indexPath.row==1){
                    if(self.arrSelectedDepartment.count==1)
                    {
                        return 44;
                        
                    }
                    else if(self.arrSelectedDepartment.count==2)
                    {
                        return 88;
                        
                    }
                    else if(self.arrSelectedDepartment.count>=3)
                    {
                        return 132;
                        
                    }
                    else{
                        return 44;
                    }
                }
                else if(indexPath.row==3){
                    
                    if(self.arrSelectedSupplier.count==1)
                    {
                        return 44;
                        
                    }
                    else if(self.arrSelectedSupplier.count>=2)
                    {
                        return 88;
                    }
                    else{
                        return 44;
                    }
                }
                else{
                    return 45;
                    
                }
            }
            else if(self.arrSelectedDepartment.count>0 )
            {
                if(indexPath.row==1){
                    
                    if(self.arrSelectedDepartment.count==1)
                    {
                        return 44;
                        
                    }
                    else if(self.arrSelectedDepartment.count==2)
                    {
                        return 88;
                        
                    }
                    else if(self.arrSelectedDepartment.count>=3)
                    {
                        return 132;
                        
                    }
                    else{
                        return 44;
                    }
                }
                else{
                    return 44;
                    
                }
            }
            else if(self.arrSelectedSupplier.count>0 )
            {
                if(indexPath.row==2){
                    
                    if(self.arrSelectedSupplier.count==1)
                    {
                        return 44;
                        
                    }
                    else if(self.arrSelectedSupplier.count>=2)
                    {
                        return 88;
                    }
                    else{
                        return 44;
                    }
                }
                else{
                    return 44;
                    
                }
            }
            else{
                return 44;
                
            }
            
        }
        else{
            return 44;
            
        }
        
    }
    else if(tableView == tblDeptsupplierlist)
    {
        
        return 30;
        
    }
    else if(tableView == tblsupplierlist)
    {
        
        return 30;
        
    }
    
    else
        return 44;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    if(tableView == self.tblGenerateOdrData )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self.tblGenerateOdrData setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                [self.arrGenerateOrderData removeObjectAtIndex:indexPath.row];
            }
            else
            {
                [self.arrGenerateOrderData removeObjectAtIndex:indexPath.row-1];
            }
            [self.tblGenerateOdrData reloadData];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Are you sure you want to delete item in this order?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

-(void)itemInfoTapped:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    infoButtonPosition = [sender convertPoint:CGPointZero toView:self.tblGenerateOdrData];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[(self.arrGenerateOrderData)[[sender tag]] valueForKey:@"ItemId"] forKey:@"ItemId"];
    
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    [itemparam setValue:strDateTime forKey:@"LocalDateTime"];
    
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getItemInfoResponse:response error:error];
              });
    };
    
    self.pOItemInfoWC = [self.pOItemInfoWC initWithRequest:KURL actionName:WSM_PO_ITEM_INFO_NEW params:itemparam completionHandler:completionHandler];
}

-(void)getItemInfoResponse:(id)response error:(NSError *)error

{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                    NSMutableArray *arrSelectedItemInfo = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                    
                    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                    {
                        [_uvItemInfoTapped setHidden:NO];
                        CGRect screenBounds = [UIScreen mainScreen].bounds;
                        if(screenBounds.size.height == 568)
                        {
                            _uvItemInfoTapped.frame = CGRectMake(0, 240, 320.0, 283.0);
                        }
                        else
                        {
                            _uvItemInfoTapped.frame = CGRectMake(0, 152, 320.0, 283.0);
                        }
                        [self.view bringSubviewToFront:_uvItemInfoTapped];
                        
                    }
                    else
                    {
                        if (infopopoverController)
                        {
                            [tempviewController dismissViewControllerAnimated:YES completion:nil];
                        }
                        [_uvItemInfoTapped removeFromSuperview];
                        _uvItemInfoTapped.hidden = NO;
                        tempviewController.view = _uvItemInfoTapped;
                        
                        // Present the view controller using the popover style.
                        tempviewController.modalPresentationStyle = UIModalPresentationPopover;
                        [self presentViewController:tempviewController animated:YES completion:nil];
                        
                        // Get the popover presentation controller and configure it.
                        infopopoverController = [tempviewController popoverPresentationController];
                        infopopoverController.delegate = self;
                        tempviewController.preferredContentSize = CGSizeMake(tempviewController.view.frame.size.width, tempviewController.view.frame.size.height);
                        infopopoverController.permittedArrowDirections = UIPopoverArrowDirectionRight;
                        infopopoverController.sourceView = self.tblGenerateOdrData;
                        infopopoverController.sourceRect = CGRectMake(infoButtonPosition.x,infoButtonPosition.y-97,340,264);
                    }
                    _lblTappedCost.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"Cost"]];
                    _lblTappedPrice.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"Price"]];
                    
                    
                    NSString *strLastSoldDate = [arrSelectedItemInfo.firstObject valueForKey:@"LastSoldDate"];
                    
                    if([strLastSoldDate isKindOfClass:[NSString class]])
                    {
                        
                        _lblTappedSoldDate.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"LastSoldDate"]];
                    }
                    else{
                        _lblTappedSoldDate.text = @"-";
                    }
                    
                    
                    _lblTappedWeek.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"WeeklySoldQty"]];
                    _lblTapped1Month.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"MonthlySoldQty"]];
                    _lblTapped6Month.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"SixMonthlySoldQty"]];
                    _lblTapped1Year.text = [NSString stringWithFormat:@"%@",[arrSelectedItemInfo.firstObject valueForKey:@"YrarlySoldQty"]];

                
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}
-(IBAction)hideuvItemInfoTapped:(id)sender{
    
    [_uvItemInfoTapped setHidden:YES];
}

#pragma mark - Scanner Device Methods

-(void)deviceButtonPressed:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"GenerateOdr"])
        {
            [status setString:@""];
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"GenerateOdr"])
        {
            if(![status isEqualToString:@""])
            {
                [self searchScannedBarcodeGenerate];
            }
        }
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status setString:@""];
        _txtMainBarcode.text = barcode;
        searchText = barcode;
        [status appendFormat:@"%@", barcode];
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"Please set scanner type as scanner." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }

}

-(BOOL)checkItemisAlreadyExists:(NSString *)ItemCode{
    
    BOOL isExtisData=FALSE;
    
    if(self.arrGenerateOrderData.count>0)
    {
        for (int idata=0; idata<self.arrGenerateOrderData.count; idata++) {
            NSString *sItemId=[NSString stringWithFormat:@"%d",[[(self.arrGenerateOrderData)[idata]valueForKey:@"ItemId"]intValue]];
            if([sItemId isEqualToString:ItemCode])
            {
                isExtisData=TRUE;
                break;
            }
        }
    }
    return isExtisData;
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

- (void)searchScannedBarcodeGenerate
{
    BOOL isScanItemfound = FALSE;
    
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    searchText = _txtMainBarcode.text;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:searchText];
    BOOL isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
        searchText = [self.rmsDbController trimmedBarcode:searchText];
    }

    NSPredicate *predicate;
    if ([self isSubDepartmentEnableInBackOffice]) {
        predicate = [NSPredicate predicateWithFormat:@"barcode==%@ AND active == %d", searchText,TRUE];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"barcode==%@ AND active == %d AND itm_Type != %@", searchText,TRUE,@(2)];
    }

    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    
    NSMutableDictionary *dictTempGlobal = [item.itemRMSDictionary mutableCopy];
    
    if(dictTempGlobal != nil)
    {
        dictTempGlobal[@"AddedQty"] = @"1";
        
        NSString * strItemCode=[NSString stringWithFormat:@"%d",[[dictTempGlobal valueForKey:@"ItemId"]intValue]];
        
        if([self checkItemisAlreadyExists:strItemCode])
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"%@ item is already exist.",searchText] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else
        {
            [dictTempGlobal removeObjectForKey:@"DepartId"];
            [dictTempGlobal removeObjectForKey:@"ItemDiscount"];
            [dictTempGlobal removeObjectForKey:@"ItemImage"];
            [dictTempGlobal removeObjectForKey:@"ItemSupplierData"];
            [dictTempGlobal removeObjectForKey:@"ItemTag"];
            [dictTempGlobal removeObjectForKey:@"ProfitAmt"];
            [dictTempGlobal removeObjectForKey:@"ProfitType"];
            [dictTempGlobal removeObjectForKey:@"Remark"];
            [dictTempGlobal removeObjectForKey:@"SalesPrice"];
            [dictTempGlobal removeObjectForKey:@"selected"];
            [dictTempGlobal removeObjectForKey:@"ItemNo"];
            
            [dictTempGlobal removeObjectForKey:@"EBT"];
            [dictTempGlobal removeObjectForKey:@"NoDiscountFlg"];
            [dictTempGlobal removeObjectForKey:@"POSDISCOUNT"];
            [dictTempGlobal removeObjectForKey:@"TaxType"];
            [dictTempGlobal removeObjectForKey:@"isTax"];
            
            [dictTempGlobal setValue:@"0" forKey:@"ReOrder"];
            [dictTempGlobal setValue:@"0" forKey:@"Sold"];
            
            [self.arrGenerateOrderData insertObject:dictTempGlobal atIndex:0];
            [self.tblGenerateOdrData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self.tblGenerateOdrData reloadData];
        }
        isScanItemfound = TRUE;
        [_txtMainBarcode becomeFirstResponder];
    }
    if(!isScanItemfound)
    {
        
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
        [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
        
        [itemparam setValue:searchText forKey:@"Code"];
        [itemparam setValue:@"Barcode" forKey:@"Type"];
        
        CompletionHandler completionHandler = ^(id response, NSError *error) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseGenerateOrderDataResponse:response error:error];
                  });
        };
        
        self.mgmtItemInsertWC = [self.mgmtItemInsertWC initWithRequest:KURL actionName:WSM_ITEM_LIST params:itemparam completionHandler:completionHandler];
    
        
        // [appDelegate setAlert:@"Generate Order" withMessage:@"No Record Found." withDelegate:self withTag:501 andButtons:@"OK",nil];
    }
}

-(void)responseGenerateOrderDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if(response!=nil)
    {
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            
            NSDictionary *responseDictionary = [[self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]] firstObject];
            
            NSPredicate *inActiveItemPredicate = [NSPredicate predicateWithFormat:@"isDeleted == %d",FALSE];
            
            NSArray *itemResponseArray = [[responseDictionary valueForKey:@"ItemArray"] filteredArrayUsingPredicate:inActiveItemPredicate];
            if(itemResponseArray.count > 0)
            {
                NSDictionary * itemDict =itemResponseArray.firstObject;
                if ([[[itemDict valueForKey:@"Active"] stringValue] isEqualToString:@"0"]) // if not active item
                {
                    GenerateOrderView * __weak myWeakReference = self;
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                        
                    };
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                        NSString *strItemId = [NSString stringWithFormat:@"%@",[itemDict valueForKey:@"ITEMCode"]];
                        Item *currentItem = [self fetchAllItems:strItemId isCheckActiveFlag:NO];
                        [myWeakReference movePOInActiveItemToActiveItemList:currentItem];
                    };
                    
                    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"This item is inactive would you like to activate it?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                }
                else {
                    [self.updateManagerGenerateOrder updateObjectsFromResponseDictionary:responseDictionary];
                    [self.updateManagerGenerateOrder linkItemToDepartmentFromResponseDictionary:responseDictionary];
                    Item *anItem=[self fetchAllItems:[[[responseDictionary valueForKey:@"ItemArray"] firstObject ]valueForKey:@"ITEMCode"] isCheckActiveFlag:YES];
                    NSMutableDictionary *dictTempGlobal = [NSMutableDictionary dictionaryWithDictionary:[anItem.itemRMSDictionary mutableCopy]];
                   
                    if([self checkItemisAlreadyExists:[dictTempGlobal valueForKey:@"ItemId"]]){
                        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                        {
                            
                        };
                        [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"%@ item is already exist.",searchText] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                        return;
                    }
              
                    
                    [dictTempGlobal removeObjectForKey:@"DepartId"];
                    [dictTempGlobal removeObjectForKey:@"ItemDiscount"];
                    [dictTempGlobal removeObjectForKey:@"ItemImage"];
                    [dictTempGlobal removeObjectForKey:@"ItemSupplierData"];
                    [dictTempGlobal removeObjectForKey:@"ItemTag"];
                    [dictTempGlobal removeObjectForKey:@"ProfitAmt"];
                    [dictTempGlobal removeObjectForKey:@"ProfitType"];
                    [dictTempGlobal removeObjectForKey:@"Remark"];
                    [dictTempGlobal removeObjectForKey:@"SalesPrice"];
                    [dictTempGlobal removeObjectForKey:@"selected"];
                    [dictTempGlobal removeObjectForKey:@"ItemNo"];
                    
                    [dictTempGlobal removeObjectForKey:@"EBT"];
                    [dictTempGlobal removeObjectForKey:@"NoDiscountFlg"];
                    [dictTempGlobal removeObjectForKey:@"POSDISCOUNT"];
                    [dictTempGlobal removeObjectForKey:@"TaxType"];
                    [dictTempGlobal removeObjectForKey:@"isTax"];
                    
                    [dictTempGlobal setValue:@"0" forKey:@"ReOrder"];
                    [dictTempGlobal setValue:@"0" forKey:@"Sold"];
                    
                    [self.arrGenerateOrderData insertObject:dictTempGlobal atIndex:0];
                    [self.tblGenerateOdrData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    [self.tblGenerateOdrData reloadData];
                    
                    _txtMainBarcode.text = @"";
                    searchText = @"";
                }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"No Record Found for %@",searchText] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

- (void)movePOInActiveItemToActiveItemList:(Item *)anItem
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary * dictItemInfo;
    dictItemInfo = [self getParamToActiveItem:anItem isItemActive:@"1"];
   
    CompletionHandler completionHandler = ^(id response, NSError *error) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self responsePOForMoveItemToActiveListResponse:response error:error];
              });
    };
    
    self.activeItemWSC = [self.activeItemWSC initWithRequest:KURL actionName:WSM_INV_ITEM_UPDATE_PARCIAL params:dictItemInfo completionHandler:completionHandler];
}

-(void)responsePOForMoveItemToActiveListResponse:(id)response error:(NSError *)error {
    if (response != nil) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray *arrayRetString  = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
            
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSString * strItemId = [NSString stringWithFormat:@"%@",[arrayRetString.firstObject valueForKey:@"ItemCode"]];
                Item * currentItem = [self fetchAllItems:strItemId isCheckActiveFlag:NO];
                currentItem.active = @1;
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Item active inactive error is %@ %@", error, error.localizedDescription);
                }
                [self searchScannedBarcodeGenerate];
                _txtMainBarcode.text = @"";
                searchText = @"";
            }
            else{
                NSDictionary *updateDict = @{kRIMItemUpdateWebServiceResponseKey : @"Error code : 104 \n Item not updated, try again."};
                [Appsee addEvent:kRIMItemUpdateWebServiceResponse withProperties:updateDict];
                
                [_activityIndicator hideActivityIndicator];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"Item not updated, try again." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
    [_activityIndicator hideActivityIndicator];
}



- (NSMutableDictionary *)getParamToActiveItem:(Item *)anItem isItemActive:(NSString *)strIsAcite {
    NSMutableDictionary * addItemDataDic = [[NSMutableDictionary alloc] init];
    NSMutableArray * itemDetails = [[NSMutableArray alloc] init];
    NSMutableDictionary * itemDataDict = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
    
    NSString * strItemCode = [dictItemClicked valueForKey:@"ItemId"];
    BOOL isDuplicateUPC = [[dictItemClicked valueForKey:@"IsduplicateUPC"] boolValue];
    
    itemDataDict[@"ItemId"] = strItemCode;
    
    itemDataDict[@"ItemName"] = [NSString stringWithFormat:@"%@",[dictItemClicked valueForKey:@"ItemName"]];
    
    itemDataDict[@"Active"] = strIsAcite;
    
    if (isDuplicateUPC) {
        itemDataDict[@"IsduplicateUPC"] = @"1";
    }
    else {
        itemDataDict[@"IsduplicateUPC"] = @"0";
    }
    
    itemDataDict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    
    NSString *userID = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    itemDataDict[@"UserId"] = userID;
    NSArray * arrKeys = itemDataDict.allKeys;
    NSMutableArray *itemMain = [[NSMutableArray alloc] init];
    for (NSString * strKey in arrKeys) {
        [itemMain addObject:@{@"Key":strKey,@"Value":[itemDataDict valueForKey:strKey]}];
    }
    
    NSMutableDictionary * itemDetailDict = [[NSMutableDictionary alloc] init];
    //    NSMutableArray * arrItemMain = [self ItemMain];
    itemDetailDict[@"ItemMain"] = itemMain;
    
    itemDetailDict[@"ItemPriceSingle"] = [[NSArray alloc]init];
    itemDetailDict[@"ItemPriceCase"] = [[NSArray alloc]init];
    itemDetailDict[@"ItemPricePack"] = [[NSArray alloc]init];
    
    itemDetailDict[@"AddedBarcodesArray"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedBarcodesArray"] = [[NSArray alloc]init];
    
    itemDetailDict[@"VariationArray"] = [[NSArray alloc]init];
    itemDetailDict[@"VariationItemArray"] = [[NSArray alloc]init];
    
    itemDetailDict[@"addedItemTaxData"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemTaxIds"] = @"";
    
    itemDetailDict[@"addedItemSupplierData"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemSupplierData"] = [[NSArray alloc]init];
    
    itemDetailDict[@"addedItemTag"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemTagIds"] = @"";
    
    itemDetailDict[@"addedItemDiscount"] = [[NSArray alloc]init];
    itemDetailDict[@"DeletedItemDiscountIds"] = @"";
    
    itemDetailDict[@"ItemTicketArray"] = [[NSArray alloc]init];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    itemDetailDict[@"Updatedate"] = [formatter stringFromDate:date];
    
    [itemDetails addObject:itemDetailDict];
    addItemDataDic[@"ItemData"] = itemDetails;
    
    return addItemDataDic;
}

- (Item*)fetchAllItems :(NSString *)itemId isCheckActiveFlag:(BOOL)isCheckActiveFlag
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate;
    if (isCheckActiveFlag) {
        predicate = [NSPredicate predicateWithFormat:@"itemCode==%d AND active == %d", itemId.integerValue,TRUE];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    }
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}



#pragma mark -
#pragma mark Create Pdf
-(IBAction)btn_ExportClick:(id)sender{
    
    [self.rmsDbController playButtonSound];
    if (emailPdfPopOverController)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [_emailPdfView removeFromSuperview];
    _emailPdfView.hidden = NO;
    emailPdfViewController.view = _emailPdfView;
    
    // Present the view controller using the popover style.
    emailPdfViewController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:emailPdfViewController animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    emailPdfPopOverController = [emailPdfViewController popoverPresentationController];
    emailPdfPopOverController.delegate = self;
    emailPdfViewController.preferredContentSize = CGSizeMake(emailPdfViewController.view.frame.size.width, emailPdfViewController.view.frame.size.height);
    emailPdfPopOverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    emailPdfPopOverController.sourceView = self.view;
    emailPdfPopOverController.sourceRect = CGRectMake(_pdfEmailBtn.frame.origin.x,
                                                      653,
                                                      _pdfEmailBtn.frame.size.width,
                                                      _pdfEmailBtn.frame.size.height);
}

-(IBAction)sendEmail:(id)sender{
    
    if(self.arrUpdatePoData.count>0)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillText:self.arrUpdatePoData];
    }
    else if(self.arrGenerateOrderData.count>0){
        
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillText:self.arrGenerateOrderData];
        
    }
}

-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"purchaseorderitem" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
  
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    
    NSString *itemHtml;
    
    if([arryInvoice.firstObject valueForKey:@"lstItem"]){
        
        itemHtml= [self htmlBillTextForItem:self.arrGenerateOrderData];
    }
    else{
        itemHtml= [self htmlBillTextForItem:arryInvoice];
    }
    
    
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController_iPhone"];
    }
    else{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        emailFromViewController = [storyBoard instantiateViewControllerWithIdentifier:@"EmailFromViewController"];
    }
    
    
    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    NSString *strsubjectLine = @"";
   
    emailFromViewController.emailFromViewControllerDelegate = self;
    emailFromViewController.dictParameter =[[NSMutableDictionary alloc]init];
    (emailFromViewController.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (emailFromViewController.dictParameter)[@"Subject"] = strsubjectLine;
    (emailFromViewController.dictParameter)[@"postfile"] = myData;
    (emailFromViewController.dictParameter)[@"InvoiceNo"] = @"";
    (emailFromViewController.dictParameter)[@"HtmlString"] = stringHtml;
    
    [self.view addSubview:emailFromViewController.view];
    
    
}

-(void)didCancelEmail
{
    [emailFromViewController.view removeFromSuperview];
}

-(void)writeDataOnCacheDirectory :(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.emaiItemHtml])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.emaiItemHtml error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.emaiItemHtml = [documentsDirectory stringByAppendingPathComponent:@"ItemInfo.html"];
    [data writeToFile:self.emaiItemHtml atomically:YES];
}

-(NSString *)htmlBillHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"%@",@"Open Order"]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ORDER_TYPE$$" withString:[NSString stringWithFormat:@"%@",_txtOrderNo.text]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ORDER_TITLE$$" withString:[NSString stringWithFormat:@"%@",_txtPOTitle.text]];
    
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    if([arrayInvoice.firstObject valueForKey:@"lstItem"]){
        
        NSString *CreatedDate = [arrayInvoice.firstObject valueForKey:@"CreatedDate"];
        
        NSString *strDate = [self getStringFormate:CreatedDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MM/dd/yyyy"];
        
        NSString *strTime = [self getStringFormate:CreatedDate fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
        
        html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    }
    else{
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy";
        NSString* strDate = [formatter stringFromDate:date];
        
        NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init];
        formatter2.dateFormat = @"hh:mm a";
        NSString* strTime = [formatter2 stringFromDate:date];
        
        
        
        html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strDate];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    }
    
    
    
    return html;
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

// Modified by Hitendra
-(NSString *)htmlBillTextForItem:(NSMutableArray *)arrayInvoice
{
    NSString *itemHtml = @"";
    
    self.emailTempDictionary = [[NSMutableDictionary alloc]init];
    
    for (int i=0; i<arrayInvoice.count; i++)
    {
        
        // set Item Detail with only 1 qty....
        NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:arrayInvoice[i]];
        itemHtml = [itemHtml stringByAppendingFormat:@"%@",strHTML];
        
        
    }
    
    return itemHtml;
}
-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td>&nbsp</td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></td><td align=\"center\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%.0f</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td><td align=\"center\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"Sold"],[itemDictionary[@"avaibleQty"]floatValue],[itemDictionary[@"ReOrder"]floatValue],itemDictionary[@"MaxStockLevel"],itemDictionary[@"MinStockLevel"]];
    
    return htmldata;
    
}

-(IBAction)iphoneBack:(id)sender{
    
    [self.navigationController popViewControllerAnimated:NO];
}

-(IBAction)filterButtonClick:(id)sender{
    
    PurchaseOrderFilterVC *objPurFilter = [[PurchaseOrderFilterVC alloc]initWithNibName:@"PurchaseOrderFilterVC" bundle:nil];
    objPurFilter.arrayDepartment=arrdepartmentList;
    objPurFilter.arraySupplier=arrsupplierlist;
//    objPurFilter.objGen=self;
//    [self._rimController.objPOMenuList.navigationController pushViewController:objPurFilter animated:YES];
}
-(void)supplierDepartmentArray:(NSMutableArray *)pArrayTemp{
    
    
    if([pArrayTemp.firstObject valueForKey:@"lstItem"])
    {
        NSMutableArray *supplierListArray = [[[pArrayTemp.firstObject valueForKey:@"lstItem"]valueForKeyPath:@"@distinctUnionOfObjects.Suppliers"]mutableCopy];
        
        
        for(int i=0;i<supplierListArray.count;i++){
            
            if ([supplierListArray[i] isKindOfClass:[NSNull class]]) {
                [supplierListArray removeObjectAtIndex:i];
            }
        }
        
        NSMutableArray *departmentListArray = [[[pArrayTemp.firstObject valueForKey:@"lstItem"]valueForKeyPath:@"@distinctUnionOfObjects.DepartmentName"]mutableCopy];
        
        for(int i=0;i<departmentListArray.count;i++){
            
            if ([departmentListArray[i] isKindOfClass:[NSNull class]]) {
                [departmentListArray removeObjectAtIndex:i];
            }
        }
        arrdepartmentList=departmentListArray;
        arrsupplierlist=supplierListArray;
        
    }
    else if([pArrayTemp.firstObject valueForKey:@"lstPendingItems"])
    {
        NSMutableArray *supplierListArray = [[[pArrayTemp.firstObject valueForKey:@"lstPendingItems"]valueForKeyPath:@"@distinctUnionOfObjects.Suppliers"]mutableCopy];
        
        
        for(int i=0;i<supplierListArray.count;i++){
            
            if ([supplierListArray[i] isKindOfClass:[NSNull class]]) {
                [supplierListArray removeObjectAtIndex:i];
            }
        }
        
        NSMutableArray *departmentListArray = [[[pArrayTemp.firstObject valueForKey:@"lstPendingItems"]valueForKeyPath:@"@distinctUnionOfObjects.Department"]mutableCopy];
        
        for(int i=0;i<departmentListArray.count;i++){
            
            if ([departmentListArray[i] isKindOfClass:[NSNull class]]) {
                [departmentListArray removeObjectAtIndex:i];
            }
        }
        arrdepartmentList=departmentListArray;
        arrsupplierlist=supplierListArray;
        
    }
    
    for(int i=0;i<arrdepartmentList.count;i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"Dept"] = arrdepartmentList[i];
        dict[@"selection"] = @"0";
        arrdepartmentList[i] = dict;
        
    }
    for(int i=0;i<arrsupplierlist.count;i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"Supp"] = arrsupplierlist[i];
        dict[@"selection"] = @"0";
        arrsupplierlist[i] = dict;
        
    }
    
    NSMutableString *strResult = [NSMutableString string];
    for(int i=0;i<arrsupplierlist.count;i++){
        
        NSMutableDictionary *dict = arrsupplierlist[i];
        
        NSString *ch = [dict valueForKey:@"Supp"];
        [strResult appendFormat:@"%@,", ch];
    }
    
    NSArray *arrayTemp;
    if(strResult.length>0)
    {
        NSString *strList = [strResult substringToIndex:strResult.length-1];
        arrayTemp = [strList componentsSeparatedByString:@","];
        
    }
    
    NSArray *newArray =  [NSSet setWithArray:arrayTemp].allObjects;
    
    [arrsupplierlist removeAllObjects];
    
    for(int i=0;i<newArray.count;i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"Supp"] = newArray[i];
        dict[@"selection"] = @"0";
        [arrsupplierlist addObject:dict];
        
    }
}
-(void)filterDepartmentamdSupplier{
    
    if(self.strPredicateDept.length>0 && self.strPredicateSupp.length==0)
    {
        [self.arrGenerateOrderData removeAllObjects];
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@",self.strPredicateDept]];
        
        self.arrGenerateOrderData = [[self.arrGenerateOrderDataGlobal filteredArrayUsingPredicate:datePredicate] mutableCopy];
        [self.tblGenerateOdrData reloadData];
    }
    else if(self.strPredicateSupp.length>0 && self.strPredicateDept.length==0){
        
        [self.arrGenerateOrderData removeAllObjects];
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:self.strPredicateSupp];
        self.arrGenerateOrderData = [[self.arrGenerateOrderDataGlobal filteredArrayUsingPredicate:datePredicate] mutableCopy ];
        [self.tblGenerateOdrData reloadData];
    }
    else if(self.strPredicateDept.length>0 && self.strPredicateSupp.length>0){
        
        [self.arrGenerateOrderData removeAllObjects];
        NSString *strPredicate=[NSString stringWithFormat:@"%@ AND %@",self.strPredicateDept,self.strPredicateSupp];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:strPredicate];
        self.arrGenerateOrderData = [[self.arrGenerateOrderDataGlobal filteredArrayUsingPredicate:datePredicate] mutableCopy ];
        [self.tblGenerateOdrData reloadData];
    }
    else if(self.strPredicateSupp.length==0 && self.strPredicateDept.length==0){
        
        [self.arrGenerateOrderData removeAllObjects];
        self.arrGenerateOrderData= [self.arrGenerateOrderDataGlobal mutableCopy];
        [self.tblGenerateOdrData reloadData];
    }
}

// Insert Po detail Filter Result notification method



-(void)getOpenBackListData{
    [Appsee addEvent:kPOGenerateOrderOpenBackListData];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [Appsee addEvent:kPOGOOpenBackListDataWebServiceCall];
  
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getPurchaseBackOrderDetailResponse:response error:error];
        });
    };
    
    self.getPurchaseBackOrderListWC = [self.getPurchaseBackOrderListWC initWithRequest:KURL actionName:WSM_GET_PURCHASE_BACK_ORDER_LIST params:itemparam completionHandler:completionHandler];

}

- (void)getPurchaseBackOrderDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSDictionary *responseDict = @{kPOGOOpenBackListDataWebServiceResponseKey : @"Response is successful"};
                [Appsee addEvent:kPOGOOpenBackListDataWebServiceResponse withProperties:responseDict];
                
                NSMutableArray *ArrayTemp = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                if(ArrayTemp.count == 0)
                {
                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No item available in back order list." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                }
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                    objManualOption  = [[ManualFilterOptionViewController alloc]initWithNibName:@"ManualFilterOptionViewController_iPhone2" bundle:nil];
                }
                else{
                    objManualOption  = [[ManualFilterOptionViewController alloc]initWithNibName:@"ManualFilterOptionViewController2" bundle:nil];
                    objManualOption.view.frame=CGRectMake(0.0, 768.0, 1024.0, 768.0);
                }
                objManualOption.objGOrder=self;
                objManualOption.arrayMainPurchaseOrderList=[ArrayTemp mutableCopy];
                objManualOption.manualOption=NO;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                    [self presentViewController:objManualOption animated:YES completion:nil];
                }
                else{
                    [UIView animateWithDuration:0.5 animations:^{
                        UINavigationController * objNav = self.pOmenuListVCDelegate.POmenuListNavigationController;
                        UIViewController * topVC=objNav.topViewController;
                        [topVC.view addSubview:objManualOption.view];
                        
                        objManualOption.view.frame=CGRectMake(0.0, 0.0, 1024.0, 768.0);
                        
                    } completion:^(BOOL finished) {
                    }];
                }
            }
        }
        else if([[response  valueForKey:@"IsError"] intValue] == 1)
        {
            NSDictionary *responseDict = @{kPOGOOpenBackListDataWebServiceResponseKey : @"IsError 1"};
            [Appsee addEvent:kPOGOOpenBackListDataWebServiceResponse withProperties:responseDict];
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response  valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
    
}

-(void)hideBackOrderListWithAnimation{
    
    [UIView animateWithDuration:0.5 animations:^{
        objManualOption.view.frame=CGRectMake(0.0, 768.0, 1024.0, 768.0);
    } completion:^(BOOL finished) {
        [objManualOption.view removeFromSuperview];
    }];
}

- (NSMutableArray *) PoDetailxmlBackOrder
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.arrBackorderSelected.count>0)
    {
        for (int isup=0; isup<self.arrBackorderSelected.count; isup++)
        {
            
            // Barcode = 90;
            // DepartmentName = Mixes;
            // "ITEM_No" = "";
            // ItemName = "1800 Anejo Tequila 50ml";
            // Margin = 100;
            // MarkUp = 0;
            // MaxStockLevel = 0;
            // MinStockLevel = 0;
            // Suppliers = Kam;
            
            NSMutableDictionary *tmpOdrDict=(self.arrBackorderSelected)[isup];
            [tmpOdrDict removeObjectForKey:@"Barcode"];
            [tmpOdrDict removeObjectForKey:@"DepartmentName"];
            [tmpOdrDict removeObjectForKey:@"ITEM_No"];
            [tmpOdrDict removeObjectForKey:@"ItemName"];
            [tmpOdrDict removeObjectForKey:@"Margin"];
            [tmpOdrDict removeObjectForKey:@"MarkUp"];
            [tmpOdrDict removeObjectForKey:@"MaxStockLevel"];
            [tmpOdrDict removeObjectForKey:@"MinStockLevel"];
            [tmpOdrDict removeObjectForKey:@"Suppliers"];
            
            // getting this field in edit/update mode
            
            [tmpOdrDict removeObjectForKey:@"ColumnNames"];
            [tmpOdrDict removeObjectForKey:@"Image"];
            [tmpOdrDict removeObjectForKey:@"ItemInfo"];
            [tmpOdrDict removeObjectForKey:@"Profit"];
            
            // ItemId == ItemCode, Sold == SoldQty, avaibleQty == AvailQty
            // AvailQty,ItemCode,ReOrder,SoldQty -- need to send this parameter so other must be removed
            
            //[tmpOdrDict setValue:[tmpOdrDict valueForKey:@"ItemId" ] forKey:@"ItemCode"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"Sold" ] forKey:@"SoldQty"];
            [tmpOdrDict setValue:[tmpOdrDict valueForKey:@"AvailableQty" ] forKey:@"AvailQty"];
            
            //[tmpOdrDict removeObjectForKey:@"ItemId"];
            [tmpOdrDict removeObjectForKey:@"Sold"];
            [tmpOdrDict removeObjectForKey:@"AvailableQty"];
            
            [itemSupplierData addObject:tmpOdrDict];
        }
    }
    return itemSupplierData;
}


#pragma mark -
#pragma mark Action Sheet

-(IBAction)openActionSheet:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"More"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Order Info",@"Send Email",@"Delivery", nil];
    actionSheet.tag=111;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag==111){
        if(buttonIndex == 0){
            
            [self btnGenerateOdrInfoClick:nil];
        }
        else if(buttonIndex == 1){
            
            [self sendEmail:nil];
        }
        else if(buttonIndex == 2){
            
            [self toolbarDeliveryclick:nil];
        }
    }
}

- (void)insertDidFinish {
}

-(IBAction)toolbarDeliveryclick:(id)sender{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[self.arrUpdatePoData.firstObject valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
    [itemparam setValue:@"Pending" forKey:@"DeliveryStatus"];
    
    [itemparam setValue:[self.arrUpdatePoData.firstObject valueForKey:@"OpenOrderId"] forKey:@"OpenOrderId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self toolbarPendingDeliveryDataResponse:response error:error];
        });
    };
    
    self.pendingDeliveryDataWC = [self.pendingDeliveryDataWC initWithRequest:KURL actionName:WSM_GET_PENDING_DELIVERY_DATA_NEW params:itemparam completionHandler:completionHandler];

}

- (void)toolbarPendingDeliveryDataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        // Barcode wise search result data
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *arrtempDeliveryDataTemp = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
                {
                    _objOpenListIpad = [[OpenListVC alloc] initWithNibName:@"OpenListVC" bundle:nil];
                }
                else{
                    _objOpenListIpad = [[OpenListVC alloc] initWithNibName:@"OpenListVC" bundle:nil];
                }
                _objOpenListIpad.booltoolbardelivery=YES;
                _objOpenListIpad.arrayGlobalPandingList=arrtempDeliveryDataTemp;
                
                NSMutableArray *arrtempDeliveryData = [arrtempDeliveryDataTemp.firstObject valueForKey:@"lstPendingItems"];
                _objOpenListIpad.pOmenuListVCDelegate = self.pOmenuListVCDelegate;
                
                if(arrtempDeliveryData.count>0)
                {
                    _objOpenListIpad.strPopUpDepartment  =  self.strPopUpDepartment;
                    _objOpenListIpad.strPopUpSupplier = self.strPopUpSupplier;
                    _objOpenListIpad.strPopUpTags = self.strPopUpTags;
                    _objOpenListIpad.strPopUpTimeDuration = self.strPopUpTimeDuration;
                    // from
                    
                    if([self.strPopUpTimeDuration isEqualToString:@"DateWise"])
                    {
                        _objOpenListIpad.strPopUpFromDate =self.strPopUpFromDate ;
                        // to Date
                        _objOpenListIpad.strPopUpToDate =self.strPopUpToDate ;
                    }
                    
                    [_objOpenListIpad.arrPendingDeliveryData removeAllObjects];
                    _objOpenListIpad.arrPendingDeliveryData=[arrtempDeliveryData mutableCopy];
                    
                    _objOpenListIpad.uvPendingDeliveryList.hidden = NO;
                    
                    _objOpenListIpad.btnDeliveryIn.hidden=YES;
                    //                        self._rimController.objPOMenuList.btnBackButtonClick.hidden=NO;
                    
                    [_objOpenListIpad.tblPendingDeliveryData reloadData];
                    [_objOpenListIpad.tblPendingDeliveryData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
                    {
                        [_txtMainBarcode becomeFirstResponder];
                    }
                    else
                    {
                        [_txtMainBarcode resignFirstResponder];
                    }
                }
                [self.navigationController pushViewController:_objOpenListIpad animated:YES];
                //                    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                //                    {
                //                        [self.navigationController pushViewController:_objOpenListIpad animated:YES];
                //                    }
                //                    else
                //                    {
                //                        [self._rimController.objPOMenuList showViewFromViewController:_objOpenListIpad];
                //                    }
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response  valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

-(IBAction)previewandPrint:(id)sender{
    
    if(self.arrGenerateOrderData.count>0)
    {
        [emailPdfViewController dismissViewControllerAnimated:YES completion:nil];
        [self htmlBillTextForPreview:self.arrGenerateOrderData];
    }
}

-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"purchaseorderitem" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
   
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"zigzag" withExtension:@"png"] absoluteString];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    // set Html itemDetail
    NSString *itemHtml;
    
    if([arryInvoice.firstObject valueForKey:@"lstItem"]){
        
        itemHtml= [self htmlBillTextForItem:self.arrGenerateOrderData];
    }
    else{
        itemHtml= [self htmlBillTextForItem:arryInvoice];
    }
    
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceipt.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    
    
    
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    
    // present the preview
    [self.controller presentPreviewAnimated:YES];
    
}

- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}

#pragma mark - didChange PushView Value -
-(void)didSelectionChangeInPOMultipleItemSelectionVC:(NSMutableArray *) selectedObject{
    for(int i=0;i<selectedObject.count;i++) {
        
        NSMutableDictionary *dictSelected = [selectedObject[i]mutableCopy];
        
        if([self checkItemisAlreadyExists:dictSelected[@"ItemId"]])
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[NSString stringWithFormat:@"%@ item is already exist.",searchText] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
        else if([dictSelected  valueForKey:@"selected"]) {
            
            [dictSelected removeObjectForKey:@"AddedQty"];
            [dictSelected removeObjectForKey:@"DepartId"];
            [dictSelected removeObjectForKey:@"ItemDiscount"];
            [dictSelected removeObjectForKey:@"ItemImage"];
            [dictSelected removeObjectForKey:@"ItemSupplierData"];
            [dictSelected removeObjectForKey:@"ItemTag"];
            [dictSelected removeObjectForKey:@"ProfitAmt"];
            [dictSelected removeObjectForKey:@"ProfitType"];
            [dictSelected removeObjectForKey:@"Remark"];
            [dictSelected removeObjectForKey:@"SalesPrice"];
            [dictSelected removeObjectForKey:@"selected"];
            [dictSelected removeObjectForKey:@"ItemNo"];
            
            [dictSelected removeObjectForKey:@"EBT"];
            [dictSelected removeObjectForKey:@"NoDiscountFlg"];
            [dictSelected removeObjectForKey:@"POSDISCOUNT"];
            [dictSelected removeObjectForKey:@"TaxType"];
            [dictSelected removeObjectForKey:@"isTax"];
            
            [dictSelected setValue:@"0" forKey:@"ReOrder"];
            [dictSelected setValue:@"0" forKey:@"Sold"];
            
            [self.arrGenerateOrderData insertObject:dictSelected atIndex:0];
        }
    }
    [self.tblGenerateOdrData reloadData];
}

-(void)didselectDepartment :(NSMutableArray *)selectedDepartment{
    
    if (selectedDepartment.count>0) {
        self.arrSelectedDepartment = [selectedDepartment mutableCopy];
        self.uvSelectDepartment.hidden = NO;
        [self displaySelectedDepartment];
    }
    else{
        self.arrSelectedDepartment = [selectedDepartment mutableCopy];
        self.uvSelectDepartment.hidden = YES;
        [self displaySelectedDepartment];
    }
}

- (void)didChangeSupplierPagePO:(NSMutableArray *)SupplierListArray withOtherData:(NSDictionary *) dictInfo{
    self.arrSelectedSupplier =[SupplierListArray mutableCopy];
    self.uvSelectSupplier.hidden = NO;
    [self displaySelectedSupplier];
}
-(void)didselectGroupSelection :(NSMutableArray *)selectedGroupSelection{
    if (self.arrSelectedGroup == nil) {
        self.arrSelectedGroup = [[NSMutableArray alloc] init];
    }

    self.arrSelectedGroup = [selectedGroupSelection mutableCopy];
    [self displaySelectedGroup];

}
#pragma mark - Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
