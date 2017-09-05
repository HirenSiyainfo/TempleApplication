//
//  DepartmetCollectionVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/30/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SubDepartmetCollectionVC.h"
#import "DepartmentCollectionCell.h"
#import "RmsDbController.h"
#import "RcrController.h"
#import "Item+Dictionary.h"

#import "Department+Dictionary.h"
#import "SubDepartment+Dictionary.h"
#import "SubDeptItemCollectionVC.h"
#import "SubDepartmentCollectionCell.h"

@interface SubDepartmetCollectionVC ()
{
    NSNumber *selectedDeptId;
    Department *departmentSelected;
}

@property (nonatomic, weak) IBOutlet UICollectionView *subDepartmentCollectionView;

@property (nonatomic, strong) NSFetchedResultsController *subDepartmentResultController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UIPageControl *departmentPageControl;

@end

@implementation SubDepartmetCollectionVC
@synthesize subDepartmentResultController = _subDepartmentResultController;
@synthesize managedObjectContext = __managedObjectContext;

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
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.subDepartmentCollectionView.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)loadSubDepartmentsOfDepartment:(Department *)selectedDepartment
{
    departmentSelected = selectedDepartment;
    selectedDeptId = selectedDepartment.deptId;
    self.subDepartmentResultController = nil;
    self.subDepartmentResultController;
    [self.subDepartmentCollectionView reloadData];
}

#pragma mark - Fetched Department results controller

-(NSMutableArray *)filterSubdepartmentArrayfor:(NSMutableArray *)subdepartmentArray
{
    NSMutableArray *removeSubDepartmentArray = [[NSMutableArray alloc]init];
    for (SubDepartment *subdepartment in subdepartmentArray) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDisplayInPos == %@", @(1)];
        NSArray *filterArray = [subdepartment.subDepartmentItems.allObjects filteredArrayUsingPredicate:predicate];
        if (filterArray.count == 0) {
            [removeSubDepartmentArray addObject:subdepartment];
        }
    }
     [subdepartmentArray removeObjectsInArray:[NSArray arrayWithArray:removeSubDepartmentArray]];
    return subdepartmentArray;
}

- (NSFetchedResultsController *)subDepartmentResultController {
    
    if (_subDepartmentResultController != nil) {
        return _subDepartmentResultController;
    }
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    
    if (departmentSelected == nil) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    
   // @"departmentSelected.departmentSubDepartments.departmentItems.isDisplayInPos == %@", @(1)
  //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@",[departmentSelected.departmentSubDepartments allObjects]];
    
  //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@",[self filterSubdepartmentArrayfor:[[departmentSelected.departmentSubDepartments allObjects] mutableCopy]]];
  //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY subDepartmentDepartments.deptId = %@ AND ANY subDepartmentItems.isDisplayInPos = %@", departmentSelected.deptId, @(1)];
  //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itm_Type  = %@ AND ANY itemDepartment.departmentItems.isDisplayInPos == %@", @"1", @(1)];

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itm_Type  = %@  AND ANY itemSubDepartment.deptId = %@ AND ANY itemSubDepartment.subDepartmentItems.isDisplayInPos = %@",@"2", departmentSelected.deptId, @(1)];

    fetchRequest.predicate = predicate;
    
 ///   NSArray *fetchDataForItem = [self fetchItem:predicate ];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptId == %@",selectedDeptId];
//    [fetchRequest setPredicate:predicate];
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemSubDepartment.subDeptName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _subDepartmentResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_subDepartmentResultController performFetch:nil];
    _subDepartmentResultController.delegate = self;
    
    return _subDepartmentResultController;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.subDepartmentCollectionView.frame.size.height;
    self.departmentPageControl.currentPage = (self.subDepartmentCollectionView.contentOffset.y + pageWidth / 2) / pageWidth;
}

#pragma mark - UICollectionView Delegate Methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSArray *sections = self.subDepartmentResultController.sections;
    return sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sections = self.subDepartmentResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    [self.subDepartmetCollectionCountDelegate didChangeSubDepartmentCount:sectionInfo.numberOfObjects];
    if(departmentSelected)
    {
        return sectionInfo.numberOfObjects+1;
    }
    return sectionInfo.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubDepartmentCollectionCell *deptCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubDepartmentCollectionCell" forIndexPath:indexPath];
    
  //  deptCell.layer.borderWidth = 1.0;
   // deptCell.layer.borderColor = [[UIColor colorWithRed:(145/255.f) green:(145/255.f) blue:(145/255.f) alpha:1.0] CGColor ];
    
    deptCell.layer.cornerRadius = 10.0;
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
    deptCell.selectedBackgroundView = selectionColor;
    
    UIView *backColor = [[UIView alloc] init];
    backColor.backgroundColor = [UIColor whiteColor];
    deptCell.backgroundView = backColor;
    

    if(indexPath.row == 0)
    {
        NSMutableDictionary *departmentDictionary = [departmentSelected.getdepartmentLoadDictionary mutableCopy];
        
        NSString *checkImageName = departmentDictionary[@"imagePath"];
        
        if ([checkImageName isEqualToString:@""])
        {
            deptCell.deptImage.image = nil;
            deptCell.departMentName.text = @"";
            deptCell.departMentNameNoImage.text = departmentDictionary[@"deptName"];
            deptCell.deptNoImage.image = [UIImage imageNamed:@"rcr_noimageforringeduplist.png"];
        }
        else
        {
            [deptCell.deptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",departmentDictionary[@"imagePath"]]]];
            deptCell.departMentName.text = departmentDictionary[@"deptName"];
            deptCell.deptNoImage.image = nil;
            deptCell.departMentNameNoImage.text = @"";
        }
        
        Item *item = [self fetchItemFromDepartment:departmentSelected];
        if (item != nil) {
            
            BOOL isPriceAtPOS = item.isPriceAtPOS.boolValue;
            if(isPriceAtPOS)
            {
                deptCell.price.text = @"";
                deptCell.bgPrice.hidden = YES;
            }
            else
            {
                NSNumber *salesAmt = @(item.salesPrice.floatValue);
                NSString *salesPrice =[NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:salesAmt]];
                deptCell.price.text = [NSString stringWithFormat:@"%@",salesPrice];
                deptCell.bgPrice.hidden = NO;
            }
        }
        else{
            deptCell.price.text = @"";
            deptCell.bgPrice.hidden = YES;
        }
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        
        Item *item = [self.subDepartmentResultController objectAtIndexPath:indexPath];
        SubDepartment *subDept = item.itemSubDepartment;
        NSMutableDictionary *departmentDictionary = [subDept.getSubDepartmentDictionary mutableCopy];
        
        deptCell.price.text = @"";
//        Item *item = [self fetchItemFromSubdepartment:subDept];
//        if (item != nil) {
//            deptCell.price.text = [NSString stringWithFormat:@"$ %.2f",item.salesPrice.floatValue];
//        }
        
        deptCell.bgPrice.hidden = YES;
        
                NSString *checkImageName = departmentDictionary[@"SubDeptImagePath"];
        
        if ([checkImageName isEqualToString:@""])
        {
            deptCell.deptImage.image = [UIImage imageNamed:@""];
            deptCell.departMentName.text = @"";

            deptCell.departMentNameNoImage.text = departmentDictionary[@"SubDeptName"];
            deptCell.deptNoImage.image = [UIImage imageNamed:@"rcr_noimageforringeduplist.png"];
        }
        else
        {
            [deptCell.deptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",departmentDictionary[@"SubDeptImagePath"]]]];
            deptCell.departMentName.text = departmentDictionary[@"SubDeptName"];
            deptCell.deptNoImage.image = nil;
            deptCell.departMentNameNoImage.text = @"";

        }
      //  deptCell.departMentName.text = [departmentDictionary objectForKey:@"SubDeptName"];
    }
    [deptCell.contentView addSubview:deptCell.deptImage];
    [deptCell.contentView addSubview:deptCell.departMentName];
    [deptCell.contentView addSubview:deptCell.deptNoImage];
    [deptCell.contentView addSubview:deptCell.departMentNameNoImage];
    

    return deptCell;
}

-(Item *)fetchItemFromDepartment :(Department *)department
{
    Item * item = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%@",department.itemcode ];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    
    return item;
}
-(NSArray *)fetchItem :(NSPredicate *)predicate
{
    predicate =  [NSPredicate predicateWithFormat:@"itm_Type  = %@",@"2"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    for (Item *item in resultSet) {
        if ([item.item_Desc isEqualToString:@"Sub Depart 1001"]) {
            NSLog(@"%@",item.itemSubDepartment);
        }
    }
    return resultSet;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        [self.subDepartmetCollectionVcDelegate didSelectDepartmentFromSubDepartment:departmentSelected];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        Item *item = [self.subDepartmentResultController objectAtIndexPath:indexPath];
        SubDepartment *subDept = item.itemSubDepartment;
        [self.subDepartmetCollectionVcDelegate didSelectSubDepartment:subDept];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
