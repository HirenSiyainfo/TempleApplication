//
//  NewManualItemVC.m
//  RapidRMS
//
//  Created by Siya on 12/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "NewManualItemVC.h"
#import "POMultipleItemSelectionVC.h"
#import "ManualEntryCustomCell.h"
#import "RmsDbController.h"
#import "Item+Dictionary.h"
#import "Item_Discount_MD2+Dictionary.h"
#import "Item_Discount_MD+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "ManualItemReceiveVC.h"
#import "SubDepartment+Dictionary.h"

@interface NewManualItemVC () <POMultipleItemSelectionVCDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tblManulItemList;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSString *strManualPoID;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *meItemResultSetController;


@end

@implementation NewManualItemVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize strManualPoID;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _meItemResultSetController=nil;
    [self.tblManulItemList reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString  *itemListCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        itemListCell = @"ReceivedItemListCell_iPad";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:itemListCell bundle:nil];
    [self.tblManulItemList registerNib:mixGenerateirderNib forCellReuseIdentifier:@"ReceivedItemListCell"];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
//    self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    // Do any additional setup after loading the view.
}

-(void)getReceiveItemList{
    
    _meItemResultSetController=nil;
    [self.tblManulItemList reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch All Vendor Item

- (NSFetchedResultsController *)meItemResultSetController {
    
    if (_meItemResultSetController != nil) {
        return _meItemResultSetController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualReceivedItem" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatePO = [NSPredicate predicateWithFormat:@"supplierIDitems.manualPoId = %d",self.strManualPoID.integerValue];
    
    fetchRequest.predicate = predicatePO;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    //
    
    // Create and initialize the fetch results controller.
    _meItemResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_meItemResultSetController performFetch:nil];
    _meItemResultSetController.delegate = self;
    
    return _meItemResultSetController;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sections = self.meItemResultSetController.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.meItemResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 73.0;
    
}


- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}


- (NSString *)getValueBeforeDecimal:(float)result
{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}



- (void)setCellDefaultBackGroundImage:(ManualEntryCustomCell *)cellmanualItem
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        cellmanualItem.imgBackGround.image = [UIImage imageNamed:@"ListBg_iphone.png"];
    }
    else
    {
        cellmanualItem.imgBackGround.image = [UIImage imageNamed:@"ListBg_ipad.png"];
    }
}

-(IBAction)searchButtonClick:(id)sender
{
    POMultipleItemSelectionVC *itemMultipleVC = [[POMultipleItemSelectionVC alloc] initWithNibName:@"POMultipleItemSelectionVC" bundle:nil];
    
//    itemMultipleVC.view.frame=CGRectMake(itemMultipleVC.view.frame.origin.x, 64, itemMultipleVC.view.frame.size.width, itemMultipleVC.view.frame.size.height-64);
    
    itemMultipleVC.checkSearchRecord = TRUE;
//    itemMultipleVC.objNewManualitem = self;
    itemMultipleVC.pOMultipleItemSelectionVCDelegate = self;
    itemMultipleVC.flgRedirectToOpenList = false;
    [self presentViewController:itemMultipleVC animated:false completion:nil];

//    [self.view addSubview:itemMultipleVC.view];
}
-(void)didSelectionChangeInPOMultipleItemSelectionVC:(NSMutableArray *) selectedObject{
    
}


-(IBAction)back:(id)sender{
    
    
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
