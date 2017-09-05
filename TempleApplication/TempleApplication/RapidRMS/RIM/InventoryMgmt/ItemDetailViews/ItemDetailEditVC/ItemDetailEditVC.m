//
//  InventoryAddNewSplitterVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemDetailEditVC.h"
#import "DisplayItemInfoSideVC.h"
#import "Department+Dictionary.h"
#import "GroupMaster+Dictionary.h"
#import "Mix_MatchDetail+Dictionary.h"

#import "ItemInfoEditVC.h"
#import "RmsDbController.h"

#import "CKOCalendarViewController.h"

@interface ItemDetailEditVC () <UIPopoverControllerDelegate,ItemInfoEditVCDelegate> {
    
    NSMutableDictionary *itemtoPost;
    IntercomHandler *intercomHandler;
}

@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) DisplayItemInfoSideVC * itemInfoSideVC;
@property (nonatomic, strong) ItemInfoEditVC *itemInfoEditVC;
@property (nonatomic, strong) UINavigationController *itemInfoNavigationController;

@property (nonatomic, strong) NSString * itemUrl;

@property (nonatomic, weak) IBOutlet UIView *itemSummaryView;
@property (nonatomic, weak) IBOutlet UIView *itemEditView;

@property (nonatomic, weak) IBOutlet UIButton *showCalendar;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@end

@implementation ItemDetailEditVC

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
    
    self.rimsController = [RimsController sharedrimController];
    self.navigationItem.hidesBackButton=NO;
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateDateLabels];
    [super viewWillAppear:animated];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self showItemInfoView:self.selectedItemInfoDict];
    [self showItemSummary:self.selectedItemInfoDict];
}

- (void)updateDateLabels
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"dd";
    [_showCalendar setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
}

-(IBAction)showCalendar:(id)sender
{
    CKOCalendarViewController *ckOCalendarViewController = [[CKOCalendarViewController alloc] init];
    [ckOCalendarViewController presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissInventoryAddNewSplitterVC];
}

- (void)dismissInventoryAddNewSplitterVC {
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}


-(void)showItemSummary:(NSDictionary*)itemDictionary
{
    if(self.itemInfoSideVC == nil)
    {
        
        self.itemInfoSideVC = (DisplayItemInfoSideVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard()
                                                                                  bundle:NULL] instantiateViewControllerWithIdentifier:@"DisplayItemInfoSideVC_sid"];
        self.itemInfoSideVC.itemInfoDictionary = [itemDictionary mutableCopy];
        itemtoPost = [itemDictionary mutableCopy];
        self.itemUrl = itemDictionary[@"ItemImage"];
        self.itemInfoSideVC.view.frame = self.itemSummaryView.bounds;
//        [self.itemInfoSideVC viewWillAppear:YES];
        self.itemInfoSideVC.displayItemInfoSideVCDeledate = self.itemInfoEditVC;
        [self addChildViewController:self.itemInfoSideVC];
        [self.itemSummaryView addSubview:self.itemInfoSideVC.view];
//        [self.itemInfoSideVC viewDidAppear:YES];
    }
}

- (void)showItemInfoView:(NSDictionary*)itemDictionary
{
    if(self.itemInfoEditVC == nil)
    {

        self.itemInfoEditVC = (ItemInfoEditVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoEditVC_sid"];
        self.itemInfoEditVC.managedObjectContext = self.rimsController.managedObjectContext;
        if (self.itemInfoEditVC.itemInfoDataObject==nil) {
            self.itemInfoEditVC.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
        }
//        [self.itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:[itemDictionary mutableCopy]];
        [self.itemInfoEditVC.itemInfoDataObject setItemMainDataFrom:[itemDictionary mutableCopy]];
        if (self.predefineInfoItemInfoDict && [self.predefineInfoItemInfoDict objectForKey:@"ItemSupplierData"]) {
            self.itemInfoEditVC.itemInfoDataObject.itemsupplierarray = [self.predefineInfoItemInfoDict[@"ItemSupplierData"] mutableCopy];
            [self.itemInfoEditVC.itemInfoDataObject createDuplicateItemSupplierarray];
        }
        self.itemInfoEditVC.itemInfoEditVCDelegate = self;
        if(self.searchedBarcode.length > 0)
        {
            self.itemInfoEditVC.isInvenManageCalled = TRUE;
            self.itemInfoEditVC.strScanBarcode = self.searchedBarcode;
        }
        if(self.isItemCopy){
            self.itemInfoEditVC.isCopy = YES;
        }
        else{
            self.itemInfoEditVC.isCopy = NO;
        }
        if (self.isItemFavourite == TRUE) {
            self.itemInfoEditVC.itemInfoDataObject.IsFavourite = TRUE;
            self.itemInfoEditVC.itemInfoDataObject.oldIsFavourite = FALSE;

        }
        self.itemInfoEditVC.NewOrderCalled = [[self.navigationInfo valueForKey:@"NewOrderCalled"] boolValue ];
        self.itemInfoEditVC.isWaitForLiveUpdate = [[self.navigationInfo valueForKey:@"isWaitForLiveUpdate"] boolValue];
        
        if(!self.itemInfoEditVC.dictNewOrderData)
        {
            self.itemInfoEditVC.dictNewOrderData = [NSMutableDictionary dictionary];
        }
        [self.itemInfoEditVC.dictNewOrderData setValue:[self.navigationInfo valueForKey:@"swipedRecordID"]forKey:@"indexpath"];
//        self.itemInfoSideVC.objAddItem = self.itemInfoEditVC;
        self.itemInfoNavigationController = [[UINavigationController alloc] initWithRootViewController:self.itemInfoEditVC];
        self.itemInfoNavigationController.navigationBarHidden = TRUE;
        [self addChildViewController:self.itemInfoNavigationController];
        self.itemInfoNavigationController.view.frame = self.itemEditView.bounds;
        [self.itemEditView addSubview:self.itemInfoNavigationController.view];
        
    }
    [_activityIndicator hideActivityIndicator];
}

#pragma mark - FaceBook Integration

-(IBAction)itemPosttoFacebook:(id)sender{
    [self validatePostForServiceType:SLServiceTypeFacebook];
}
-(IBAction)itemPosttoTwitter:(id)sender{
    [self validatePostForServiceType:SLServiceTypeTwitter];
}

-(void)validatePostForServiceType:(NSString *)serviceType {
    NSString * strServiceType = @"";
    if (serviceType == SLServiceTypeFacebook) {
        strServiceType = @"Facebook";
    }
    else {
        strServiceType = @"Twitter";
    }
    if ([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        if (_activityIndicator) {
            [_activityIndicator hideActivityIndicator];
        }
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sharePostForServiceType:serviceType withServiceTypeName:strServiceType];
        });
    }
    else
    {
        if (serviceType == SLServiceTypeFacebook) {
            [self showMessage:[NSString stringWithFormat:@"You can't send a post right now, make sure your device has an internet connection and you have at least one %@ account setup.",strServiceType]];
        }
        else {
            [self showMessage:[NSString stringWithFormat:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one %@ account setup.",strServiceType]];
        }
    }
}
-(void)sharePostForServiceType:(NSString *)serviceType withServiceTypeName:(NSString *)strServiceType {
    SLComposeViewController *sharePost = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    
    NSString *strItemName = [NSString stringWithFormat:@"Item : %@\n",[itemtoPost valueForKey:@"ItemName"]];
    NSString *strItemBarcode = [NSString stringWithFormat:@"Barcode : %@\n",[itemtoPost valueForKey:@"Barcode"]];
    NSString *strItemPrice = [NSString stringWithFormat:@"Price : %@\n",[self.rmsDbController applyCurrencyFomatter:[itemtoPost valueForKey:@"SalesPrice"]]];
    NSString *strItemRemark = [NSString stringWithFormat:@"Remark : %@\n",[itemtoPost valueForKey:@"Remark"]];
    NSString *strComment = [NSString stringWithFormat:@"Comment : "];
    NSString * sttPostContain = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",strItemName,strItemBarcode,strItemPrice,strItemRemark,strComment];
    
    [sharePost setInitialText:sttPostContain];
    if (self.itemUrl && self.itemUrl.length > 0 && [NSURL URLWithString:self.itemUrl] != nil) {
        UIImage * imgItem = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.itemUrl]]];
        [sharePost addImage:imgItem];
//        [sharePost addURL:[NSURL URLWithString:self.itemUrl]];
    }
    
    [self presentViewController:sharePost animated:YES completion:^{
        [_activityIndicator hideActivityIndicator];
    }];
    
    sharePost.completionHandler = ^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultCancelled:{
                [self showMessage:[NSString stringWithFormat:@"Post canceled for %@.",strServiceType]];
                break;
            }
            case SLComposeViewControllerResultDone:{
                [self showMessage:[NSString stringWithFormat:@"Post successful for %@.",strServiceType]];
            }
            default:
                break;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
}

-(void)showMessage:(NSString *)strMessage{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
        
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

#pragma mark - ItemInfoEditVCDelegate
- (void)didUpdateItemInfo:(NSDictionary*)itemInfoData {
    [self.itemInfoSideVC didUpdateItemInfo:itemInfoData];
}

- (void)ItemInfornationChangeAt:(NSInteger )indexRow WithNewData:(id)newItemInfo{
    if (self.itemInfoEditRedirectionVCDelegate!=nil) {
        [self.itemInfoEditRedirectionVCDelegate ItemInfornationChangeAt:indexRow WithNewData:newItemInfo];
    }
}
@end
