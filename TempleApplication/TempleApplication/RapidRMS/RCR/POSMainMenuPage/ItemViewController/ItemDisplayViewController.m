//
//  ItemDisplayViewController.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ItemDisplayViewController.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "RmsDbController.h"
#import "CustomItemDisplayCell.h"
#import "DisplayItemInfo.h"
#import "RcrController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NSString+Methods.h"
#import "ItemDisplayVCCustomCell.h"
#import "CameraScanVC.h"
#import "RapidItemFilterVC.h"
#import "Item_Price_MD+Dictionary.h"

@interface ItemDisplayViewController () <UpdateDelegate,CameraScanVCDelegate,RapidItemFilterVCDeledate,UIGestureRecognizerDelegate>
{
    bool isDiscripitionSortType;
    bool isDepartmentSortType;
    bool isQtySortType;
    bool isPriceSortType;
    
    UIView *dummyView;
    DisplayItemInfo *objItemInfo;
    NSMutableDictionary *itemtoPost;
    IntercomHandler *intercomHandler;
    NSMutableArray *selectedObjectIdArray;
    UITapGestureRecognizer *tapGestureRecognizer;
    RapidItemFilterVC * objRapidItemFilterVC;
    NSPredicate * preCoustomeFilter;
    
    Configuration *configuration;
}

@property (nonatomic, weak) IBOutlet UIImageView *img_qtyItem;
@property (nonatomic, weak) IBOutlet UIImageView *Imgitem_PriceBtn;
@property (nonatomic, weak) IBOutlet UIImageView *Imgitem_descriptBtn;
@property (nonatomic, weak) IBOutlet UIImageView *Imgitem_departBtn;
@property (nonatomic, weak) IBOutlet UIImageView *imgBG;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton *btnFavourite;
@property (nonatomic, weak) IBOutlet UIButton *btnOK;
@property (nonatomic, weak) IBOutlet UIButton *btnItemName;
@property (nonatomic, weak) IBOutlet UIButton *btnRapidFilterView;
@property (nonatomic, weak) IBOutlet UIView *itemView;

@property (nonatomic, weak) IBOutlet UIView *uvSearchTextBg;
@property (nonatomic, weak) IBOutlet UIView *viewFilterBG;
@property (nonatomic, weak) IBOutlet UITextField *txtItemKeyboard;
@property (nonatomic, weak) IBOutlet UITextField *txtBarcode;
@property (nonatomic, weak) IBOutlet UIButton *btnInfo;
@property (nonatomic, weak) IBOutlet UIButton *btnFilter;
@property (nonatomic, weak) IBOutlet UIButton *btnLoginLogout;
@property (nonatomic, weak) IBOutlet UITableView *filterTypeTable;
@property (nonatomic, weak) IBOutlet UIView *viewFacebookSetting;
@property (nonatomic, weak) IBOutlet FBProfilePictureView *profilePic;
@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UIView *viewComment;
@property (nonatomic, weak) IBOutlet UITextView *txtFacebookComment;
@property (nonatomic, weak) IBOutlet UIButton *btnItemKeYboard;
@property (nonatomic, weak) IBOutlet UITableView *tblGetItemData;

@property (strong, nonatomic) FBRequestConnection *requestConnection;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) BOOL isKeywordFilter;
@property (nonatomic) BOOL isContinuousFiltering;
@property (nonatomic) BOOL isAscending;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) CameraScanVC *cameraScanVC;
@property (nonatomic, strong) UpdateManager *itemUpdateManager;

@property (nonatomic, strong) NSFetchedResultsController *itemResultsController;
@property (nonatomic, strong) NSFetchedResultsController *previousItemResultsController;
@property (nonatomic, strong) NSMutableArray *filterTypeArray;
@property (nonatomic, strong) NSMutableDictionary *itemtoPost;
@property (nonatomic, strong) NSString *sortColumn;
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, strong) NSMutableArray *selectedItemArray;

@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSString *selectItemId;
@property (nonatomic, strong) NSIndexPath *indexPathforItem;
@property (nonatomic, strong) NSIndexPath *filterIndxPath;
@property (nonatomic, strong) NSFetchedResultsController *itemDisplayResultController;

@property (nonatomic, strong) NSLock *buttonLock;
@property (nonatomic, strong) NSDate *previousDate;


@end

@implementation ItemDisplayViewController
@synthesize managedObjectContext = __managedObjectContext;
@synthesize itemDisplayResultController = __itemDisplayResultController;

@synthesize itemtoPost;
@synthesize viewFacebookSetting,lblUserName,viewComment,txtFacebookComment;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _txtBarcode.inputView = dummyView;
    [_txtBarcode becomeFirstResponder];
    self.selectedItemArray = [[NSMutableArray alloc]init];
    
    selectedObjectIdArray = [[NSMutableArray alloc] init];
    viewFacebookSetting.hidden=YES;
    viewFacebookSetting.layer.borderWidth=1.0;
    viewFacebookSetting.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    viewComment.hidden=YES;
    viewComment.layer.borderWidth=1.0;
    viewComment.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _imgBG.layer.cornerRadius = 17.0;
    txtFacebookComment.layer.borderWidth=1.0;
    txtFacebookComment.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    self.sortColumn = @"item_Desc";
    self.sectionName = @"sectionLabel";
    
    self.selectItemId=@"";
    self.isAscending = YES;
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemUpdateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    _uvSearchTextBg.layer.cornerRadius = 2.0;
    self.tblGetItemData.allowsMultipleSelection = YES;
    [self.tblGetItemData reloadData];
    [self loadFirstRowData];
    
    self.filterTypeArray = [[NSMutableArray alloc] initWithObjects:@"ABC Shorting",@"Keyword",nil];
    
    self.filterTypeTable.hidden = YES;
    self.filterTypeTable.layer.borderWidth = 1;
    self.filterTypeTable.layer.borderColor = [UIColor whiteColor].CGColor;
    self.filterTypeTable.layer.cornerRadius = 8.0;

    if (self.isItemForFavourite == TRUE) {
        [self selectFavouriteItems];
    }
    
    // Discount Mix Match Cell
    NSString *itemDisplayVCNib = @"ItemDisplayVCCustomCell";
    UINib *itemDisplayNib = [UINib nibWithNibName:itemDisplayVCNib bundle:nil];
    [self.tblGetItemData registerNib:itemDisplayNib forCellReuseIdentifier:@"ItemDisplayVCCustomCell"];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isItemForFavourite == YES)
    {
        _btnFavourite.layer.borderWidth = 2.0;
        _btnFavourite.layer.borderColor = [UIColor whiteColor].CGColor;
        _btnFavourite.layer.cornerRadius = 18.0;
        _btnFavourite.hidden = NO;
        _btnOK.enabled = NO;
    }
    else{
        _btnFavourite.hidden = YES;
        _btnOK.enabled = YES;
    }
    [self checkItemFilterType];
    
    [self addFilterView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self btn_itemKeyboard:self.btnItemKeYboard];
}

-(IBAction)synchronize24HoursClickedFromRCRItemList:(id)sender
{
    [self.rmsDbController playButtonSound];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseCompleteSyncDataFromRCRItemList:) name:@"CompleteSyncData" object:nil];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    [self.rmsDbController startSynchronizeUpdate:3600*24];
}

-(void)responseCompleteSyncDataFromRCRItemList:(NSNotification *)notification
{
    [_activityIndicator hideActivityIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteSyncData" object:nil];
}

- (void)checkItemFilterType
{
    self.rmsDbController.rcrSelectedFilterType = @"Keyword";
    self.isKeywordFilter = TRUE;
    self.isContinuousFiltering = FALSE;
    _txtBarcode.placeholder = @"UPC, ITEM, ITEM #, DEPARTMENT, SUPPLIER.....";
    self.filterTypeTable.hidden = YES;
    self.filterIndxPath = [NSIndexPath indexPathForRow:1 inSection:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.filterTypeTable.hidden = YES;
}

-(void)loadFirstRowData
{
    if (self.itemDisplayResultController.sections.count == 0) {
        return;
    }
    NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
    Item *anItem = [self.itemDisplayResultController objectAtIndexPath:firstRow];
        NSMutableDictionary *dictItem = [anItem.itemDictionary mutableCopy];
        if (anItem.itemDepartment.deptName==nil)
        {
            dictItem[@"DepartmentName"] = @"";
        }
        else
        {
            dictItem[@"DepartmentName"] = anItem.itemDepartment.deptName;
        }
        [self showItemInfo:dictItem];
    [self.tblGetItemData reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source methods
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView==self.tblGetItemData)
    {
        if ([title isEqualToString:@"All"])
        {
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.searchText = @"";
                _txtBarcode.text = @"";
                self.itemDisplayResultController=nil;
                [self.tblGetItemData reloadData];
            });
            return 0;
        }else{
            return [self.itemDisplayResultController sectionForSectionIndexTitle:title atIndex:index-1];
        }
    }else{
        return 0;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView==self.tblGetItemData)
    {
        if ([self.sortColumn isEqualToString:@"item_InStock"]||  [self.sortColumn isEqualToString:@"salesPrice"]) {
            return nil;
        }
        NSArray *array= @[@"All"];
        array = [array arrayByAddingObjectsFromArray:self.itemDisplayResultController.sectionIndexTitles];
        return array;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==self.tblGetItemData)
    {
        NSArray *sections = self.itemDisplayResultController.sections;
        return sections.count;
    }
    else if (tableView == self.filterTypeTable)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.tblGetItemData)
    {
        NSArray *sections = self.itemDisplayResultController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        return sectionInfo.numberOfObjects;
    }
    else if (tableView == self.filterTypeTable)
    {
        return self.filterTypeArray.count;
    }else{
        return 1;
    }
}

-(void)setUpCell :(UITableViewCell *)cell
{
    cell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
    cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.bounds];
    cell.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.941 green:0.933 blue:0.933 alpha:1.000];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tblGetItemData)
    {
        Item *anItem = [self.itemDisplayResultController objectAtIndexPath:indexPath];
        [self selectDeselectItem:anItem indexPath:indexPath];
    }
}

- (NSMutableDictionary *)itemInfoDictionary:(Item *)anItem
{
    NSMutableDictionary *dictItem = [anItem.itemDictionary mutableCopy];
    if (anItem.itemDepartment.deptName==nil)
    {
        dictItem[@"DepartmentName"] = @"";
    }else{
        dictItem[@"DepartmentName"] = anItem.itemDepartment.deptName;
    }
    
    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    for (Item_Discount_MD *idiscMd in anItem.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    Item_Discount_MD2 *idiscMd2=nil;
    
    if(itemDiscArray.count>0)
    {
        for (int idisc=0; idisc<itemDiscArray.count; idisc++)
        {
            idiscMd2=itemDiscArray[idisc];
            NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;
            
            if(idiscMd2.dayId.integerValue==-1 && iDiscqty==1)
            {
                NSNumber *numerPrice=@(idiscMd2.md2Tomd.dis_UnitPrice.floatValue);
                NSString *sPrice =[NSString stringWithFormat:@"%@",numerPrice];
                dictItem[@"Price"] = sPrice;
            }
        }
    }
    return dictItem;
}

- (void)selectDeselectItem:(Item *)anItem indexPath:(NSIndexPath *)indexPath
{
    
    self.indexPathforItem=indexPath;
    if (anItem.is_Selected.boolValue) {
        anItem.is_Selected = @(NO);
        [selectedObjectIdArray removeObject:anItem.objectID];
        
    }else{
        anItem.is_Selected = @(YES);
        [selectedObjectIdArray addObject:anItem.objectID];
    }
    
    self.selectItemId = anItem.itemCode.stringValue;
    NSMutableDictionary *dictItem;
    dictItem = [self itemInfoDictionary:anItem];
    [self showItemInfo:dictItem];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tblGetItemData)
    {
        Item *anItem = [self.itemDisplayResultController objectAtIndexPath:indexPath];
        [self selectDeselectItem:anItem indexPath:indexPath];
    }
    else if (tableView == self.filterTypeTable)
    {
        self.filterIndxPath = nil;
        self.filterIndxPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        self.filterIndxPath = indexPath;
        
        [self.rmsDbController playButtonSound];
        if(indexPath.row == 0)
        {
            self.rmsDbController.rcrSelectedFilterType = @"ABC Shorting";
            self.isKeywordFilter = FALSE;
            self.isContinuousFiltering = TRUE;
            _txtBarcode.placeholder = @"ABC Shorting";
            self.filterTypeTable.hidden = YES;
        }
        else if (indexPath.row == 1)
        {
            self.rmsDbController.rcrSelectedFilterType = @"Keyword";
            self.isKeywordFilter = TRUE;
            self.isContinuousFiltering = FALSE;
            _txtBarcode.placeholder = @"UPC, ITEM, ITEM #, DEPARTMENT.....";
            self.filterTypeTable.hidden = YES;
        }
        if((_txtBarcode.text.length > 0) || (self.searchText.length > 0))
        {
            _txtBarcode.text = @"";
            self.searchText = @"";
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tblGetItemData scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            [self reloadItemDataTable];
        }
        [tableView reloadRowsAtIndexPaths: @[self.filterIndxPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.filterTypeTable)
        return 44;
    else
        return 70;
}

-(void)reloadItemDataTable
{
    self.itemDisplayResultController = nil;
    [self.tblGetItemData reloadData];
    [_activityIndicator hideActivityIndicator];;
}

-(void)showItemInfo :(NSMutableDictionary *)itemDictionary
{
    self.itemtoPost = itemDictionary;
    [[self.view viewWithTag:252525]removeFromSuperview ];
    objItemInfo = [[DisplayItemInfo alloc]initWithNibName:@"DisplayItemInfo" bundle:nil];
    objItemInfo.itemInfoDictionary = [itemDictionary mutableCopy];
    objItemInfo.view.frame=CGRectMake(659,85, objItemInfo.view.frame.size.width, objItemInfo.view.frame.size.height);
    objItemInfo.view.tag = 252525;
    [self.view addSubview:objItemInfo.view];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(tableView == self.tblGetItemData)
    {
        cell=[self configureCellAtIndexPath:indexPath];
    }
    
    else if(tableView == self.filterTypeTable)
    {
        UITableViewCellStyle style =  UITableViewCellStyleDefault;
        UITableViewCell *filterCell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"filterCell"];
        filterCell.selectionStyle = UITableViewCellSelectionStyleNone;
        filterCell.backgroundColor = [UIColor clearColor];
        [[self.view viewWithTag:242424] removeFromSuperview];
        UILabel *lblFilterType = [[UILabel alloc]initWithFrame:CGRectMake(20,0, 120, 44)];
        lblFilterType.font = [UIFont fontWithName:@"Lato" size:13];
        lblFilterType.textColor = [UIColor whiteColor];
        lblFilterType.text = (self.filterTypeArray)[indexPath.row];


        if ([indexPath isEqual:self.filterIndxPath]) {
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(150, 14, 22, 16)];
            imgView.tag = 242424;
            imgView.image = [UIImage imageNamed:@"soundCheckMark.png"];
            [filterCell.contentView addSubview:imgView];
        }
        else{
            [filterCell.imageView setImage:nil];
        }
        [filterCell.contentView addSubview:lblFilterType];
        [filterCell addSubview:lblFilterType];

        cell = filterCell;
    }
    return cell;
}


- (UITableViewCell*)configureCellAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *casePackColor ;
    static NSString *CellIdentifier = @"ItemDisplayVCCustomCell";
    ItemDisplayVCCustomCell *cell = [self.tblGetItemData dequeueReusableCellWithIdentifier:CellIdentifier];
    [self setUpCell:cell];
    
    Item *anItem = [self.itemDisplayResultController objectAtIndexPath:indexPath];
    if (anItem.is_Selected.boolValue) {
        [self.tblGetItemData selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else
    {
    }
    NSDictionary *itemDictionary = anItem.itemDictionary;
    
    cell.itemname.text = itemDictionary[@"ItemName"];
    cell.itemUpc.text = itemDictionary[@"Barcode"];
    cell.itemNumber.text = itemDictionary[@"ItemNo"];
    
    NSNumber *numerPrice=@([itemDictionary[@"Price"] floatValue]);
    NSString *sPrice =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:numerPrice]];
    cell.itemSalesPrice.text = sPrice;
    cell.itemSalesPrice.textColor = [UIColor blackColor];
    casePackColor = [UIColor blackColor];
    if (anItem.primaryItemDetail.count > 0 && anItem.primaryItemDetail != nil) {
        cell.itemSalesPrice.textColor = [UIColor colorWithRed:(0.0/255.f) green:(115.0/255.f) blue:(170.0/255.f) alpha:1.0];
        casePackColor = [UIColor colorWithRed:(0.0/255.f) green:(115.0/255.f) blue:(170.0/255.f) alpha:1.0];
         cell.discountImage.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];
    }
    else{
        cell.discountImage.image = nil;
    }
    
    NSMutableArray *arrayItemOption = [NSMutableArray array];
    
    if (anItem.memo.boolValue) {
        [arrayItemOption addObject:@"MEMO"];
    }
    if (anItem.isFavourite.boolValue) {
        [arrayItemOption addObject:@"FV"];
    }
    if (anItem.eBT.boolValue) {
        [arrayItemOption addObject:@"EBT"];
    }
    
    cell.lblItemOption.text = [arrayItemOption componentsJoinedByString:@" | "];

    NSMutableArray * itemDiscArray = [[NSMutableArray alloc]init];
    for (Item_Discount_MD *idiscMd in anItem.itemToDisMd )
    {
        [itemDiscArray addObjectsFromArray:idiscMd.mdTomd2.allObjects];
    }
    
    Item_Discount_MD2 *idiscMd2=nil;
    
    if(itemDiscArray.count>0)
    {
        for (int idisc=0; idisc<itemDiscArray.count; idisc++)
        {
            idiscMd2=itemDiscArray[idisc];
            
            NSInteger iDiscqty = idiscMd2.md2Tomd.dis_Qty.integerValue;
            
            
            if(idiscMd2.dayId.integerValue==-1 && iDiscqty==1)
            {
                NSNumber *numerPrice=@(idiscMd2.md2Tomd.dis_UnitPrice.floatValue);
                NSString *sPrice =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:numerPrice]];
                cell.itemSalesPrice.text = sPrice;
                cell.itemSalesPrice.textColor = [UIColor blueColor];
                casePackColor = [UIColor blueColor];
                cell.discountImage.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];
            }
            
            else if(idiscMd2.dayId.integerValue==-1)
            {
                cell.itemSalesPrice.textColor = [UIColor colorWithRed:(0.0/255.f) green:(115.0/255.f) blue:(170.0/255.f) alpha:1.0];
                casePackColor = [UIColor colorWithRed:(0.0/255.f) green:(115.0/255.f) blue:(170.0/255.f) alpha:1.0];
                cell.discountImage.image = [UIImage imageNamed:@"RIM_Item_Discount_cell"];
                
            }
            else{
                cell.discountImage.image = nil;
                
            }
        }
    }
    else
    {
        NSString *sCostPrice =[NSString stringWithFormat:@"%.2f", [itemDictionary[@"CostPrice"] floatValue]];
        NSString *slesPrice =[NSString stringWithFormat:@"%.2f", [itemDictionary[@"Price"] floatValue]];
        
        float CostPrice=sCostPrice.floatValue;
        
        float Price=slesPrice.floatValue;
        if (CostPrice>Price)
        {
            cell.itemSalesPrice.textColor = [UIColor redColor];
            casePackColor = [UIColor redColor];
        }
    }
   
    cell.itemQty.hidden = NO;
    cell.itemQty.text=[NSString stringWithFormat:@"%@", itemDictionary[@"availableQty"]];
    cell.itemQty.textColor = [UIColor colorWithRed:(40/255.f) green:(40/255.f) blue:(40/255.f) alpha:1.0];
    
    NSInteger minLevel = [itemDictionary[@"MinStockLevel"] integerValue];
    NSInteger availableQty = [itemDictionary[@"availableQty"] integerValue];
    cell.itemQty.textColor = [UIColor blackColor];
    if (minLevel>0)
    {
        if (availableQty<minLevel)
        {
            cell.itemQty.layer.borderColor=[UIColor colorWithRed:(201.0 /255.f) green:(87.0/255.f) blue:(72.0/255.f) alpha:1.0].CGColor;
            cell.itemQty.textColor = [UIColor blackColor];
        }
    }
    
    if (anItem.quantityManagementEnabled .boolValue == TRUE ) {
        cell.itemQty.hidden = YES;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId==%d",[itemDictionary[@"DepartId"] integerValue]];
    fetchRequest.predicate = predicate;
    NSArray *departmentList = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (departmentList.count>0)
    {
        Department *department=departmentList.firstObject;
        cell.itemDepartment.text = department.deptName;
    }else{
        cell.itemDepartment.text = @"";
    }
    
    NSMutableArray *arrayPackagetype = [[NSMutableArray alloc] init];
    
    for (Item_Price_MD *priceMD in anItem.itemToPriceMd)
    {
        NSMutableDictionary *dictPriceValue = [[NSMutableDictionary alloc] init];
        if ([priceMD.priceqtytype isEqualToString:@"Case"])
        {
            if (priceMD.unitPrice.floatValue > 0) {
                [dictPriceValue setValue:priceMD.unitPrice forKey:@"PriceValue"];
                [dictPriceValue setValue:@"CASE" forKey:@"PackageType"];
                [arrayPackagetype addObject:dictPriceValue];
            }
        }
        else if ([priceMD.priceqtytype isEqualToString:@"Pack"])
        {
            if (priceMD.unitPrice.floatValue > 0) {
                [dictPriceValue setValue:priceMD.unitPrice forKey:@"PriceValue"];
                [dictPriceValue setValue:@"PACK" forKey:@"PackageType"];
                [arrayPackagetype addObject:dictPriceValue];
            }
        }
    }
    
    NSSortDescriptor *valueDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"PackageType" ascending:YES];
    arrayPackagetype= [[arrayPackagetype sortedArrayUsingDescriptors:@[valueDescriptor]] mutableCopy];

    if (arrayPackagetype.count > 0) {
        if (arrayPackagetype.count > 1) {
              cell.lblCase.text = [[arrayPackagetype objectAtIndex:0] valueForKey:@"PackageType"];
            NSString *priceCaseValue = [NSString stringWithFormat:@"%@" , [[arrayPackagetype objectAtIndex:0] valueForKey:@"PriceValue"]];
              cell.itemCasePrice.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:@(priceCaseValue.floatValue)]];
             cell.itemCasePrice.textColor = casePackColor;
            
            cell.lblPack.text = [[arrayPackagetype objectAtIndex:1] valueForKey:@"PackageType"];
            NSString *pricePackValue = [NSString stringWithFormat:@"%@" , [[arrayPackagetype objectAtIndex:1] valueForKey:@"PriceValue"]];
            cell.itemPackPrice.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:@(pricePackValue.floatValue)]];
            cell.itemPackPrice.textColor = casePackColor;
        }
        else if(arrayPackagetype.count == 1){
            cell.lblCase.text = [[arrayPackagetype objectAtIndex:0] valueForKey:@"PackageType"];
            NSString *priceCaseValue = [NSString stringWithFormat:@"%@" , [[arrayPackagetype objectAtIndex:0] valueForKey:@"PriceValue"]];
            cell.itemCasePrice.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:@(priceCaseValue.floatValue)]];
            cell.itemCasePrice.textColor = casePackColor;
            
            cell.lblPack.text = @"";
            cell.itemPackPrice.text = @"";
        }
    }
    else{
        cell.lblPack.text = @"";
        cell.itemPackPrice.text = @"";
        cell.lblCase.text = @"";
        cell.itemCasePrice.text = @"";
    }
    
    cell.clipsToBounds = YES;
    
    UISwipeGestureRecognizer *gestureItemRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeItemDispayInfoLeft:)];
    gestureItemRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell.contentView addGestureRecognizer:gestureItemRight];
    
    return cell;
}

-(void)didSwipeItemDispayInfoLeft:(UISwipeGestureRecognizer *)gesture
{
    
}

-(NSInteger )selectedItemCountItemTable
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_Selected==%d",1];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return resultSet.count;
    
}

-(NSArray * )selectedItemOfItemTable
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_Selected==%@",@(YES)];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    return resultSet;
}
- (BOOL)isQuickTap {
    BOOL isQuickTap = NO;
    [_buttonLock lock];
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeLapsed = [currentDate timeIntervalSinceDate:_previousDate];
    if (timeLapsed < 1.0) {
        isQuickTap = YES;
    }
    _previousDate = currentDate;
    
    [_buttonLock unlock];
    
    return isQuickTap;
}


- (IBAction)itemOkClick:(id)sender {
    
    [self.rmsDbController playButtonSound];
    
    NSLog(@"Item Display Done button click date %@",[NSDate date]);
    if ([self isQuickTap]) {
        NSLog(@"You are too quick");
        return;
    }
    NSLog(@"block excute end date %@",[NSDate date]);
    
    
    NSArray *selectedItem = [self selectedItemOfItemTable];
    
    for (Item *itemObjectId in selectedItem)
    {
        //        Item anitem = (Item )[self.managedObjectContext objectWithID:itemObjectId];
        if (itemObjectId != nil)
        {
            NSMutableDictionary * itemDictionary = [[NSMutableDictionary alloc]init];
            itemDictionary[@"itemId"] = itemObjectId.itemCode.stringValue;
            itemDictionary[@"Type"] = @"Item";
            [self.selectedItemArray addObject:itemDictionary];
            itemObjectId.is_Selected = @(NO);
        }
        [UpdateManager saveContext:self.managedObjectContext];
    }
    
    if(self.selectedItemArray.count > 0)
    {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:_itemView];
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [_rcrPosVcDeleage didSelectwithMultipleItemArray:self.selectedItemArray];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            [_activityIndicator hideActivityIndicator];;
        });
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select an Item." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(IBAction)btnAddToFavouriteItem:(id)sender
{
    [self.rmsDbController playButtonSound];
    
    
    //    if(self.selectedItemArray.count > 0)
    //    {
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:_itemView];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [_rcrPosVcDeleage didselectFavouriteItem:[self selectedFavouriteItems] withUnfavouriteItem:[self selectedUnFavouriteItems]];
        [self dismissViewControllerAnimated:YES completion:^{
            
            NSArray *selectedItems = [self selectedItemOfItemTable];
            
            for (Item *itemObjectId in selectedItems)
            {
                //                    Item anitem = (Item )[self.managedObjectContext objectWithID:itemObjectId];
                if (itemObjectId != nil)
                {
                    NSMutableDictionary * itemDictionary = [[NSMutableDictionary alloc]init];
                    itemDictionary[@"itemId"] = itemObjectId.itemCode.stringValue;
                    [self.selectedItemArray addObject:itemDictionary];
                    itemObjectId.is_Selected = @(NO);
                }
            }
        }];
        [_activityIndicator hideActivityIndicator];;
    });
    
    //    }
    //    else
    //    {
    //        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    //        {
    //        };
    //        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please select an Item." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    //    }
    
}
- (IBAction)btn_ItemCancel:(id)sender
{
    [self.rmsDbController playButtonSound];
    
    NSArray *selectedItems = [self selectedItemOfItemTable];
    
    for (Item *itemObjectId in selectedItems)
    {
        //        Item anitem = (Item )[self.managedObjectContext objectWithID:itemObjectId];
        if (itemObjectId != nil)
        {
            itemObjectId.is_Selected = @(NO);
        }
    }
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:_itemView];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [_rcrPosVcDeleage didCancelItemRingup];
                       [self dismissViewControllerAnimated:YES completion:^{
                       }];
                       [_activityIndicator hideActivityIndicator];;
                   });
    
}
- (UILabel *)lblWithFrame:(CGRect)labelFrame lblText:(NSString *)lblText
{
    UILabel * itemName = [[UILabel alloc] initWithFrame:labelFrame];
    itemName.text = lblText;
    itemName.textAlignment = NSTextAlignmentLeft;
    itemName.backgroundColor = [UIColor clearColor];
    itemName.textColor = [UIColor colorWithRed:(40/255.f) green:(40/255.f) blue:(40/255.f) alpha:1.0];
    itemName.numberOfLines = 2;
    itemName.lineBreakMode = NSLineBreakByWordWrapping;
    [itemName sizeToFit];
    itemName.font = [UIFont fontWithName:@"Helvetica Neue" size:14.00];
    return itemName;
}

#pragma mark - RapidFilters -
-(void)addFilterView {
    if (!objRapidItemFilterVC) {
        objRapidItemFilterVC = [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"RapidItemFilterVC_sid"];
        objRapidItemFilterVC.view.frame = CGRectMake(355, 0, 355, self.viewFilterBG.bounds.size.height);
        [self addChildViewController:objRapidItemFilterVC];
        [self.viewFilterBG addSubview:objRapidItemFilterVC.view];
        [objRapidItemFilterVC didMoveToParentViewController:self];
        objRapidItemFilterVC.deledate = self;
    }
}
- (void)highlightLetter:(UITapGestureRecognizer*)sender {
    [objRapidItemFilterVC filterViewSlideIn:FALSE];
    self.btnRapidFilterView.selected = FALSE;
    [self.view removeGestureRecognizer:sender];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:objRapidItemFilterVC.view]){
        return NO;
    }
    else if (self.viewFilterBG.hidden) {
        self.btnRapidFilterView.selected = FALSE;
        [self.view removeGestureRecognizer:gestureRecognizer];
    }
    return YES;
}

-(IBAction)rapidFilterViewSlideInOutButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.view bringSubviewToFront:self.viewFilterBG];
    [objRapidItemFilterVC filterViewSlideIn:sender.selected];
    [self.view endEditing:YES];
    if (sender.selected) {
        UITapGestureRecognizer *letterTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(highlightLetter:)];
        letterTapRecognizer.numberOfTapsRequired = 1;
        letterTapRecognizer.delegate = self;
        [self.view addGestureRecognizer:letterTapRecognizer];
    }
}

-(void)willSetRapidItemFilterPredicate:(NSPredicate *) predicate withFilterDictionary:(NSDictionary *)dictFilterInfo {
#ifndef IS_CLICK_TO_SEARCH
    [objRapidItemFilterVC filterViewSlideIn:FALSE];
    self.btnRapidFilterView.selected = FALSE;
#endif
    preCoustomeFilter = predicate;
    self.itemDisplayResultController=nil;
    [self.tblGetItemData reloadData];
}
-(void)willChangeRapidFilterIsSlidein:(BOOL)isSlidein {
#ifdef IS_CLICK_TO_SEARCH
        self.btnRapidFilterView.selected = isSlidein;
        [objRapidItemFilterVC filterViewSlideIn:isSlidein];
#endif
}

//hiten
#pragma mark - CoreData Methods
- (NSFetchedResultsController *)itemDisplayResultController :(NSString *)strSearchText{
    
    if (__itemDisplayResultController != nil) {
        return __itemDisplayResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.fetchBatchSize = 20;
    
    if (strSearchText != nil && ![strSearchText isEqualToString:@""]) {
        NSPredicate *searchPredicate = [self searchPredicateForText:strSearchText];
        fetchRequest.predicate = searchPredicate;
    }
    else{
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((itm_Type == %@ AND active == %d)OR itm_Type == %@ OR (itm_Type == %@ AND itemDepartment.isNotApplyInItem == %@)) AND isNotDisplayInventory == %@",@"0",TRUE,@"2",@"1",@(0),@(0)];
        
        NSMutableArray *fieldWisePredicates = [NSMutableArray array];
        [fieldWisePredicates addObject:predicate];
        if (preCoustomeFilter) {
            [fieldWisePredicates addObject:preCoustomeFilter];
        }
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];

        fetchRequest.predicate = finalPredicate;
    }
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor;
    if ([self.sortColumn isEqualToString:@"item_InStock"]  || [self.sortColumn isEqualToString:@"salesPrice"])
    {
        aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending];
        NSArray *sortDescriptors = @[aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    else
    {
        aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = @[aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    
    // Create and initialize the fetch results controller.
    __itemDisplayResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:self.sortColumn cacheName:nil];
    __itemDisplayResultController.delegate = self;
    [__itemDisplayResultController performFetch:nil];
    
    return __itemDisplayResultController;
}

#pragma mark - CoreData Methods
- (NSFetchedResultsController *)itemDisplayResultController {
    
    if (__itemDisplayResultController != nil) {
        return __itemDisplayResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.fetchBatchSize = 20;
    
    if (self.searchText != nil && ![self.searchText isEqualToString:@""]) {
        NSPredicate *searchPredicate = [self searchPredicateForText:self.searchText];
        fetchRequest.predicate = searchPredicate;
        
        NSInteger isRecordFound = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
        
        if(self.isKeywordFilter)
        {
            if(isRecordFound == 0)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    self.searchText = @"";
                    _txtBarcode.text = @"";
                    [_txtBarcode becomeFirstResponder];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:[NSString stringWithFormat:@"No record found for %@",self.searchText] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                [_txtBarcode becomeFirstResponder];
                __itemDisplayResultController = self.previousItemResultsController;
                return __itemDisplayResultController;
            }
        }
        else // for Alphabatic sorting
        {
            if(isRecordFound == 0)
            {
                __itemDisplayResultController = self.previousItemResultsController;
                return __itemDisplayResultController;
            }
        }
    }
    else{
        NSPredicate *isDisplayInPosPredicate;
        if ([self isSubDepartmentEnableInBackOffice]) {
            isDisplayInPosPredicate = [NSPredicate predicateWithFormat:@"((itm_Type == %@ AND active == %d)OR itm_Type == %@ OR (itm_Type == %@ AND itemDepartment.isNotApplyInItem == %@)) AND isNotDisplayInventory == %@",@"0",TRUE,@"2",@"1",@(0),@(0)];
        }
        else {
            isDisplayInPosPredicate = [NSPredicate predicateWithFormat:@"((itm_Type == %@ AND active == %d) OR (itm_Type == %@ AND itemDepartment.isNotApplyInItem == %@)) AND isNotDisplayInventory == %@ AND itm_Type != %@",@"0",TRUE,@"1",@(0),@(0),@(2)];
        }
        
        NSMutableArray *fieldWisePredicates = [NSMutableArray array];
        [fieldWisePredicates addObject:isDisplayInPosPredicate];
        if (preCoustomeFilter) {
            [fieldWisePredicates addObject:preCoustomeFilter];
        }
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
        
        fetchRequest.predicate = finalPredicate;
    }
    // Create the sort descriptors array.
    NSString *sectionLabel=nil;
    NSSortDescriptor *aSortDescriptor;
    if ([self.sortColumn isEqualToString:@"item_InStock"]  || [self.sortColumn isEqualToString:@"salesPrice"])
    {
        aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending];
        NSArray *sortDescriptors = @[aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    else if ([self.sortColumn isEqualToString:@"item_Desc"])
    {
        aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending];
        NSSortDescriptor *aSortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:self.sectionName ascending:self.isAscending];
        NSArray *sortDescriptors = @[aSortDescriptor1,aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
        sectionLabel = self.sectionName;
    }
    else
    {
        aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortColumn ascending:self.isAscending selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = @[aSortDescriptor];
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    // Create and initialize the fetch results controller.
    __itemDisplayResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:sectionLabel cacheName:nil];
    
    [__itemDisplayResultController performFetch:nil];
    __itemDisplayResultController.delegate = self;
    self.previousItemResultsController = __itemDisplayResultController;
    
    return __itemDisplayResultController;
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemDisplayResultController]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblGetItemData beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    if (![controller isEqual:self.itemDisplayResultController]) {
        return;
    }
    UITableView *tableView = self.tblGetItemData;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.itemDisplayResultController]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblGetItemData insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblGetItemData deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemDisplayResultController]) {
        return;
    }
    [self.tblGetItemData endUpdates];
}


#pragma mark - Button ItemSorting

- (IBAction)btn_ItemQty:(id)sender
{
    [self.rmsDbController playButtonSound];
    [_Imgitem_PriceBtn setImage:nil];
    [_Imgitem_descriptBtn setImage:nil];
    [_Imgitem_departBtn setImage:nil];
    self.sortColumn=@"item_InStock";
    
    if(isQtySortType==TRUE)
    {
        _img_qtyItem.image = [UIImage imageNamed:@"upyarrow_itemBtn.png"];
        self.isAscending=YES;
        isQtySortType=FALSE;
    }
    else
    {
        _img_qtyItem.image = [UIImage imageNamed:@"Downyarrow_itembtn.png"];
        self.isAscending=NO;
        isQtySortType=TRUE;
    }
    self.itemDisplayResultController=nil;
    [self.tblGetItemData reloadData];
}


- (IBAction)btn_itemPriceSorting:(id)sender
{
    [self.rmsDbController playButtonSound];
    [_img_qtyItem setImage:nil];
    [_Imgitem_descriptBtn setImage:nil];
    [_Imgitem_departBtn setImage:nil];
    
    self.sortColumn=@"salesPrice";
    
    if(isPriceSortType==TRUE)
    {
        _Imgitem_PriceBtn.image = [UIImage imageNamed:@"upyarrow_itemBtn.png"];
        self.isAscending=YES;
        isPriceSortType=FALSE;
    }
    else
    {
        _Imgitem_PriceBtn.image = [UIImage imageNamed:@"Downyarrow_itembtn.png"];
        self.isAscending=NO;
        isPriceSortType=true;
    }
    self.itemDisplayResultController=nil;
    [self.tblGetItemData reloadData];
}

- (IBAction)itemdescriptbtn:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];
    [_Imgitem_PriceBtn setImage:nil];
    [_img_qtyItem setImage:nil];
    [_Imgitem_departBtn setImage:nil];
    self.sortColumn=@"item_Desc";
    self.isAscending=YES;
    
    if(isDiscripitionSortType==TRUE)
    {
        _Imgitem_descriptBtn.image = [UIImage imageNamed:@"upyarrow_itemBtn.png"];
        self.isAscending=YES;
        isDiscripitionSortType=FALSE;
    }
    else
    {
        _Imgitem_descriptBtn.image = [UIImage imageNamed:@"Downyarrow_itembtn.png"];
        self.isAscending=NO;
        isDiscripitionSortType=TRUE;
    }
    self.itemDisplayResultController=nil;
    [self.tblGetItemData reloadData];
}

-(IBAction)itemdepartbtn:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];
    [_Imgitem_PriceBtn setImage:nil];
    [_img_qtyItem setImage:nil];
    [_Imgitem_descriptBtn setImage:nil];
    self.sortColumn=@"itemDepartment.deptName";
    if(isDepartmentSortType==TRUE)
    {
        isDepartmentSortType=FALSE;
        _Imgitem_departBtn.image = [UIImage imageNamed:@"upyarrow_itemBtn.png"];
        self.isAscending=YES;
    }
    else
    {
        _Imgitem_departBtn.image = [UIImage imageNamed:@"Downyarrow_itembtn.png"];
        isDepartmentSortType=TRUE;
        self.isAscending=NO;
    }
    self.itemDisplayResultController=nil;
    [self.tblGetItemData reloadData];
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
    _txtBarcode.text = strBarcode;
    [self textFieldShouldReturn:_txtBarcode];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.isKeywordFilter)
    {
        if(textField==_txtBarcode)
        {
            if(_txtBarcode.text.length>0)
            {
                self.searchText=_txtBarcode.text;
                self.itemDisplayResultController=nil;
                NSArray *sections = self.itemDisplayResultController.sections;
                if(sections.count>0)
                {
                    [self.tblGetItemData reloadData];
                }
            }
        }
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(!self.isKeywordFilter)
    {
        if(self.isContinuousFiltering)
        {
            if(textField == _txtBarcode)
            {
                if([string isEqualToString:@","])
                {
                    self.rmsDbController.rcrSelectedFilterType = @"Keyword";
                    self.isKeywordFilter = TRUE;
                    self.isContinuousFiltering = FALSE;
                    _txtBarcode.placeholder = @"UPC, ITEM #, DESCRIPTION, DEPARTMENT, etc..";
                    self.filterIndxPath = nil;
                    self.filterIndxPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    [self.filterTypeTable reloadData];
                }
                else
                {
                    NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
                    if (textField.text.length == 1 && [string isEqualToString:@""]) {
                        self.searchText = @"";
                    }
                    else if(searchString.length > 0)
                    {
                        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self.tblGetItemData scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                        self.searchText = searchString;
                    }
                    else
                    {
                        self.searchText = @"";
                    }
                    self.itemDisplayResultController = nil;
                    NSArray *sections = self.itemDisplayResultController.sections;
                    if(sections.count > 0)
                    {
                        [self.tblGetItemData reloadData];
                    }
                    [_activityIndicator hideActivityIndicator];;
                }
            }
            return YES;
        }
        return YES;
    }
    else
    {
        if(range.location == 0 && ([string isEqualToString:@""]))
        {
            textField.text = @"";
            self.searchText = @"";
            [self.tblGetItemData scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self checkItemFilterType];
            self.itemDisplayResultController = nil;
            [self.tblGetItemData reloadData];
        }
        return YES;
    }
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.searchText=@"";
        self.itemDisplayResultController=nil;
        [self.tblGetItemData reloadData];
    });
    return YES;
}

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    BOOL isNumber;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:searchData];
    isNumber = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumber) // numeric
    {
        searchData = [self.rmsDbController trimmedBarcode:searchData];
    }
    NSMutableCharacterSet *separators = [[NSMutableCharacterSet alloc] init];
    [separators addCharactersInString:@","];
    NSMutableArray *textArray = [[searchData componentsSeparatedByCharactersInSet:separators] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;
    if(self.isKeywordFilter)
    {
        // For - Filter the when I click "return" or "search button" - Keyword
        dbFields = @[ @"item_Desc contains[cd] %@",@"item_No == %@", @"barcode == %@", @"item_Remarks BEGINSWITH[cd] %@",@"itemDepartment.deptName BEGINSWITH[cd] %@",@"ANY itemBarcodes.barCode == %@",@"ANY itemTags.tagToSizeMaster.sizeName contains[cd] %@"];
    }
    else
    {
        // For - Filter the item list as I type the keywords - ABC Shorting
        dbFields = @[ @"item_Desc BEGINSWITH[cd] %@"];
    }
    for (int i=0; i<textArray.count; i++)
    {
        NSString *str=textArray[i];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *searchTextPredicates = [NSMutableArray array];
        for (NSString *dbField in dbFields)
        {
            if (![str isEqualToString:@""])
            {
                [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, str]];
            }
        }
        NSPredicate *compoundpred = [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
        [fieldWisePredicates addObject:compoundpred];
    }
    if (preCoustomeFilter) {
        [fieldWisePredicates addObject:preCoustomeFilter];
    }
    NSPredicate *isDisplayInPosPredicate;
    if ([self isSubDepartmentEnableInBackOffice]) {
        isDisplayInPosPredicate = [NSPredicate predicateWithFormat:@"((itm_Type == %@ AND active == %d)OR itm_Type == %@ OR (itm_Type == %@ AND itemDepartment.isNotApplyInItem == %@)) AND isNotDisplayInventory == %@",@"0",TRUE,@"2",@"1",@(0),@(0)];
    }
    else {
        isDisplayInPosPredicate = [NSPredicate predicateWithFormat:@"((itm_Type == %@ AND active == %d) OR (itm_Type == %@ AND itemDepartment.isNotApplyInItem == %@)) AND isNotDisplayInventory == %@ AND itm_Type != %@",@"0",TRUE,@"1",@(0),@(0),@(2)];
    }

    
    [fieldWisePredicates addObject:isDisplayInPosPredicate];
    if (preCoustomeFilter) {
        [fieldWisePredicates addObject:preCoustomeFilter];
    }
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];

    return finalPredicate;
}

-(IBAction)filterButtonClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [_txtBarcode resignFirstResponder];
    self.filterTypeTable.hidden = NO;
}

- (IBAction)btnInfo_Clicked:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];
    _btnInfo.selected = YES;
    _btnFilter.selected = NO;
}

-(IBAction)btnFilter_Clicked:(UIButton *)sender
{
    [self.rmsDbController playButtonSound];
    _btnInfo.selected = NO;
    _btnFilter.selected = YES;
}

- (IBAction)btn_itemKeyboard:(id)sender
{
    [self.rmsDbController playButtonSound];
    if([sender tag]==0)
    {
        [_txtItemKeyboard becomeFirstResponder];
        [sender setTag:1];
        self.btnItemKeYboard.selected = YES;
    }
    else
    {
        [sender setTag:0];
        [_txtItemKeyboard resignFirstResponder];
        [_txtBarcode resignFirstResponder];
        _txtBarcode.inputView = dummyView;
        self.btnItemKeYboard.selected = NO;
    }
    [_txtBarcode becomeFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.filterTypeTable.hidden = YES;
    [objRapidItemFilterVC filterViewSlideIn:FALSE];
    self.btnRapidFilterView.selected = FALSE;

    if((textField == _txtBarcode) && (self.btnItemKeYboard.tag == 1))
    {
        _txtBarcode.inputView = nil;
        [_txtBarcode becomeFirstResponder];
    }
    else
    {
        _txtBarcode.inputView = dummyView;
    }
}

-(IBAction)logintoFacebok:(id)sender{
    
    viewFacebookSetting.hidden=YES;
    _itemView.userInteractionEnabled=YES;
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:_itemView];
    if (FBSession.activeSession.isOpen)
    {
        NSString *strUserID = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserID"];
        if(strUserID.length==0)
        {
            [self sendRequests];
        }
        else
        {
            [self facebookCommentView];
        }
    }
    else
    {
        if ([[FBSession activeSession].permissions indexOfObject:@"publish_actions"] == NSNotFound)
        {
            NSArray *permissions = @[@"publish_stream", @"publish_actions",@"public_profile"];
            FBSession.activeSession = [[FBSession alloc] initWithPermissions:permissions];
        }
        FBSessionLoginBehavior behavior = FBSessionLoginBehaviorForcingWebView;
        [FBSession.activeSession openWithBehavior:behavior
                                completionHandler:^(FBSession *innerSession,
                                                    FBSessionState status,
                                                    NSError *error) {
                                    if (error)
                                    {
                                        [_activityIndicator hideActivityIndicator];;
                                        [FBSession.activeSession close];
                                        [FBSession setActiveSession:nil];
                                    } else if (FB_ISSESSIONOPENWITHSTATE(status))
                                    {
                                        NSString *strUserID = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserID"];
                                        if(strUserID.length==0)                                        {
                                            [self sendRequests];
                                        }
                                        else{
                                            [self facebookCommentView];
                                        }
                                    }
                                }];
    }
}

-(void)facebookCommentView
{
    _itemView.userInteractionEnabled=NO;
    [_activityIndicator hideActivityIndicator];;
    [self.viewComment setHidden:NO];
}


-(NSString *)selectedFavouriteItems
{
    NSString *itemCode = @"";
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite == %d AND is_Selected == %d",0,1];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0) {
        NSArray *itemCodes = [resultSet valueForKey:@"itemCode"];
        itemCode = [itemCodes componentsJoinedByString:@","];
    }
    return itemCode;
}


-(NSString *)selectedUnFavouriteItems
{
    NSString *itemCode = @"";
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite == %d AND is_Selected == %d",1,0];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0) {
        NSArray *itemCodes = [resultSet valueForKey:@"itemCode"];
        itemCode = [itemCodes componentsJoinedByString:@","];
    }
    return itemCode;
}

-(void)selectFavouriteItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite==%@",@(YES)];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (Item *item in resultSet) {
        item.is_Selected = @(YES);
    }
}

-(IBAction)postComment:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:_itemView];
    [self postitemDetails];
    [self.viewComment setHidden:YES];
}

-(IBAction)cancelCommentview:(id)sender
{
    [self.viewComment setHidden:YES];
    _itemView.userInteractionEnabled=YES;
    self.txtFacebookComment.text=@"";
}

-(IBAction)logoutfromFacebok:(id)sender
{
    viewFacebookSetting.hidden=YES;
    _itemView.userInteractionEnabled=YES;
    self.profilePic.profileID=nil;
    [FBSession.activeSession close];
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"UserID"];
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"name"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in storage.cookies)
    {
        NSString * domainName = cookie.domain;
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    [_btnLoginLogout setHidden:YES];
}

-(IBAction)cancelfacebook:(id)sender{
    
    [FBSession.activeSession close];
    
    [FBSession setActiveSession:nil];
    self.profilePic.profileID=nil;
    [viewFacebookSetting setHidden:YES];
    _itemView.userInteractionEnabled=YES;
}

-(IBAction)itemPosttoTwitter:(id)sender{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *strItemName = [NSString stringWithFormat:@"Item : %@\n",[self.itemtoPost valueForKey:@"ItemName"]];
        NSString *strItemBarcode = [NSString stringWithFormat:@"Barcode : %@\n",[self.itemtoPost valueForKey:@"Barcode"]];
        NSString *strItemPrice = [NSString stringWithFormat:@"Price : %@\n",[self.rmsDbController applyCurrencyFomatter:[self.itemtoPost valueForKey:@"Price"]]];
        NSString *strItemRemark = [NSString stringWithFormat:@"Remark : %@\n",[self.itemtoPost valueForKey:@"Remark"]];
        NSString *strComment = [NSString stringWithFormat:@"Comment : %@\n",self.txtFacebookComment.text];
        NSString *strPost = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",strItemName,strItemBarcode,strItemPrice,strItemRemark,strComment];
        
        self.txtFacebookComment.text=@"";
        
        AsyncImageView *img = (AsyncImageView *)objItemInfo.itemImage_Item;
        if(img.image == nil){
            UIImage *img=[UIImage imageNamed:@"noimage.png"];
            
            [tweetSheet addImage:img];
        }
        else{
            
            [tweetSheet addImage:img.image];
        }
        
        [tweetSheet setInitialText:strPost];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:{
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Twitter" message:@"Post Canceled" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    break;
                }
                case SLComposeViewControllerResultDone:{
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Twitter" message:@"Post Successful" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    break;
                }
                default:
                    break;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        };
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"You can't send a tweet right now, make suren your device has an internet connection and you have at least one Twitter account setup" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}


-(IBAction)itemPosttoFacebook:(id)sender{
    
    viewFacebookSetting.hidden=NO;
    _itemView.userInteractionEnabled=NO;
    self.profilePic.layer.borderWidth=1.0;
    self.profilePic.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    NSString *strUserID = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserID"];
    
    if(strUserID.length>0){
        self.profilePic.profileID = strUserID;
        [_btnLoginLogout setHidden:NO];
    }
    else{
        [_btnLoginLogout setHidden:YES];
    }
    lblUserName.text=[[NSUserDefaults standardUserDefaults]valueForKey:@"name"];
    
}

- (void)sendRequests {
    // extract the id's for which we will request the profile
    NSArray *fbids = @[@"me"];
    
    
    // create the connection object
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    // for each fbid in the array, we create a request object to fetch
    // the profile, along with a handler to respond to the results of the request
    for (NSString *fbid in fbids) {
        
        // create a handler block to handle the results of the request for fbid's profile
        FBRequestHandler handler =
        ^(FBRequestConnection *connection, id result, NSError *error) {
            // output the results of the request
            [self requestCompleted:connection forFbID:fbid result:result error:error];
        };
        
        // create the request object, using the fbid as the graph path
        // as an alternative the request* static methods of the FBRequest class could
        // be used to fetch common requests, such as /me and /me/friends
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                      graphPath:fbid];
        
        // add the request to the connection object, if more than one request is added
        // the connection object will compose the requests as a batch request; whether or
        // not the request is a batch or a singleton, the handler behavior is the same,
        // allowing the application to be dynamic in regards to whether a single or multiple
        // requests are occuring
        [newConnection addRequest:request completionHandler:handler];
    }
    
    // if there's an outstanding connection, just cancel
    [self.requestConnection cancel];
    
    // keep track of our connection, and start it
    self.requestConnection = newConnection;
    [newConnection start];
}


-(void)postitemDetails{
    
    /*NSArray *fbids = [[NSArray alloc]initWithObjects:@"me/photos", nil];
     
     // create the connection object
     FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
     
     // for each fbid in the array, we create a request object to fetch
     // the profile, along with a handler to respond to the results of the request
     for (NSString *fbid in fbids) {
     
     // create a handler block to handle the results of the request for fbid's profile
     FBRequestHandler handler =
     ^(FBRequestConnection *connection, id result, NSError *error) {
     // output the results of the request
     [self requestCompleted:connection forFbID:fbid result:result error:error];
     };
     
     NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
     
     NSString *strItemName = [NSString stringWithFormat:@"Item : %@\n",[self.itemtoPost valueForKey:@"ItemName"]];
     NSString *strItemBarcode = [NSString stringWithFormat:@"Barcode : %@\n",[self.itemtoPost valueForKey:@"Barcode"]];
     NSString *strItemPrice = [NSString stringWithFormat:@"Price : %@\n",[self.itemtoPost valueForKey:@"Price"]];
     NSString *strItemRemark = [NSString stringWithFormat:@"Remark : %@\n",[self.itemtoPost valueForKey:@"Remark"]];
     
     NSString *strComment = [NSString stringWithFormat:@"Comment : %@\n",self.txtFacebookComment.text];
     
     
     NSString *strPost = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",strItemName,strItemBarcode,strItemPrice,strItemRemark,strComment];
     
     self.txtFacebookComment.text=@"";
     
     AsyncImageView *img = (AsyncImageView *)objItemInfo.itemImage_Item;
     if(img.image==nil){
     UIImage *img=[UIImage imageNamed:@"noimage.png"];
     [dict setObject:img forKey:@"file"];
     }
     else{
     [dict setObject:img.image forKey:@"file"];
     }
     
     
     [dict setObject:strPost forKey:@"name"];
     
     FBRequest *request = [[FBRequest alloc]initWithSession:FBSession.activeSession graphPath:fbid parameters:dict HTTPMethod:@"POST"];
     
     [newConnection addRequest:request completionHandler:handler];
     }
     
     // if there's an outstanding connection, just cancel
     [self.requestConnection cancel];
     // keep track of our connection, and start it
     self.requestConnection = newConnection;
     [newConnection start];*/
    
    
    NSArray *fbids = @[@"/me/feed"];
    
    // create the connection object
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    // for each fbid in the array, we create a request object to fetch
    // the profile, along with a handler to respond to the results of the request
    for (NSString *fbid in fbids) {
        
        // create a handler block to handle the results of the request for fbid's profile
        FBRequestHandler handler =
        ^(FBRequestConnection *connection, id result, NSError *error) {
            // output the results of the request
            [self requestCompleted:connection forFbID:fbid result:result error:error];
        };
        
        /* NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
         
         NSString *strItemName = [NSString stringWithFormat:@"Item : %@\n",[self.itemtoPost valueForKey:@"ItemName"]];
         NSString *strItemBarcode = [NSString stringWithFormat:@"Barcode : %@\n",[self.itemtoPost valueForKey:@"Barcode"]];
         NSString *strItemPrice = [NSString stringWithFormat:@"Price : %@\n",[self.itemtoPost valueForKey:@"Price"]];
         NSString *strItemRemark = [NSString stringWithFormat:@"Remark : %@\n",[self.itemtoPost valueForKey:@"Remark"]];
         
         NSString *strComment = [NSString stringWithFormat:@"Comment : %@\n",self.txtFacebookComment.text];
         
         
         NSString *strPost = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",strItemName,strItemBarcode,strItemPrice,strItemRemark,strComment];
         
         self.txtFacebookComment.text=@"";
         
         AsyncImageView *img = (AsyncImageView *)objItemInfo.itemImage_Item;
         if(img.image==nil){
         UIImage *img=[UIImage imageNamed:@"noimage.png"];
         [dict setObject:img forKey:@"file"];
         }
         else{
         [dict setObject:img.image forKey:@"file"];
         }
         
         [dict setObject:strPost forKey:@"name"];*/
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        params[@"message"] = txtFacebookComment.text;
        params[@"title"] = @"";
        params[@"name"] = [self.itemtoPost valueForKey:@"ItemName"];
        params[@"caption"] = [NSString stringWithFormat:@"%@ / %@",[self.itemtoPost valueForKey:@"Barcode"],[self.rmsDbController applyCurrencyFomatter:[self.itemtoPost valueForKey:@"Price"]]];
        params[@"description"] = [self.itemtoPost valueForKey:@"Remark"];
        params[@"link"] = @"";
        
        if([[self.itemtoPost valueForKey:@"ItemImage"] isEqualToString:@""]){
            params[@"picture"] = @"http://www.italiasquisita.net/wp-content/uploads/2010/09/birra-artigianale-in-lombardia1.jpg";
        }
        else{
            params[@"picture"] = [self.itemtoPost valueForKey:@"ItemImage"];
        }
        
        self.txtFacebookComment.text=@"";
        
        FBRequest *request = [[FBRequest alloc]initWithSession:FBSession.activeSession graphPath:fbid parameters:params HTTPMethod:@"POST"];
        
        [newConnection addRequest:request completionHandler:handler];
    }
    
    // if there's an outstanding connection, just cancel
    [self.requestConnection cancel];
    // keep track of our connection, and start it
    self.requestConnection = newConnection;
    [newConnection start];
    
    
}

// Report any results.  Invoked once for each request we make.
- (void)requestCompleted:(FBRequestConnection *)connection
                 forFbID:fbID
                  result:(id)result
                   error:(NSError *)error {
    // not the completion we were looking for...
    if (self.requestConnection &&
        connection != self.requestConnection) {
        return;
    }
    
    [_activityIndicator hideActivityIndicator];
    
    self.requestConnection = nil;
    
    NSString *text;
    if (error) {
        // error contains details about why the request failed
        //text = error.localizedDescription;
    } else {
        // result is the json response from a successful request
        NSDictionary *dictionary = (NSDictionary *)result;
        // we pull the name property out, if there is one, and display it
        text = (NSString *)dictionary[@"name"];
        
        if(text.length>0){
            
            NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=name",dictionary[@"id"]];
            
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            
            NSHTTPURLResponse *response;
            NSError *error;
            NSData *responseData;
            
            responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *json =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            NSMutableDictionary *dictinfo = [self.rmsDbController objectFromJsonString:json];
            
            // FOR GETTING FACEBOOK USER NAME
            
            [[NSUserDefaults standardUserDefaults]setObject:dictionary[@"id"] forKey:@"UserID"];
            [[NSUserDefaults standardUserDefaults]setObject:[dictinfo valueForKey:@"name"] forKey:@"name"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [_btnLoginLogout setHidden:NO];
            
            [self facebookCommentView];
            
        }
        else{
            
            
            NSString *strpostid = dictionary[@"id"];
            NSArray *arruserid = [strpostid componentsSeparatedByString:@"_"];
            
            // FOR GETTING FACEBOOK USER NAME
            
            NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=name",arruserid.firstObject];
            
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            
            NSHTTPURLResponse *response;
            NSError *error;
            NSData *responseData;
            
            responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *json =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSMutableDictionary *dictinfo = [self.rmsDbController objectFromJsonString:json];
            
            // FOR GETTING FACEBOOK USER NAME
            [[NSUserDefaults standardUserDefaults]setObject:arruserid.firstObject forKey:@"UserID"];
            [[NSUserDefaults standardUserDefaults]setObject:[dictinfo valueForKey:@"name"] forKey:@"name"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_btnLoginLogout setHidden:NO];
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Facebook" message:@"Post Successful" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
    _itemView.userInteractionEnabled=YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
-(void)tapToCellView:(UITapGestureRecognizer *)tapGetureRecognizer
{
    CGPoint locationInView = [tapGestureRecognizer locationInView:self.view];
    CGPoint locationInTableView =  [self.tblGetItemData convertPoint:locationInView fromView:self.view];
    NSIndexPath *indexPathForTable = [self.tblGetItemData indexPathForRowAtPoint:locationInTableView];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIView class]] && view.tag == 111) {
            [view removeFromSuperview];
        }
    }
    
    UIView *snapShotView ;
    UITableViewCell *cell = [self.tblGetItemData cellForRowAtIndexPath:indexPathForTable];
    CGPoint locationInTableViewCell = [cell.contentView convertPoint:locationInTableView fromView:self.tblGetItemData];
   
    NSLog(@"locationInTableViewCell = %@",NSStringFromCGPoint(locationInTableViewCell));

    
    for (UIView *view in cell.contentView.subviews) {
        CGRect subviewFrame = view.frame;
        NSLog(@"subviewFrame = %@",NSStringFromCGRect(subviewFrame));
        if (CGRectContainsPoint(subviewFrame, locationInTableViewCell)) {
            snapShotView = [cell.contentView resizableSnapshotViewFromRect:subviewFrame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            snapShotView.frame = CGRectMake(locationInView.x, locationInView.y, snapShotView.frame.size.width, snapShotView.frame.size.height);
            snapShotView.backgroundColor = [UIColor clearColor];
            snapShotView.alpha = 0.5;
            snapShotView.tag = 111;
            snapShotView.center = self.view.center;
            snapShotView.contentMode = UIViewContentModeScaleAspectFill;
            [self.view addSubview:snapShotView];
            
            [UIView animateWithDuration:1.0 animations:^{
                if (view.tag == 1199) {
                    snapShotView.center = _btnIntercom.center;
                }
                if (view.tag == 1198) {
                    snapShotView.center = _btnItemName.center;

                }
            }];
        }
    }
}

@end
