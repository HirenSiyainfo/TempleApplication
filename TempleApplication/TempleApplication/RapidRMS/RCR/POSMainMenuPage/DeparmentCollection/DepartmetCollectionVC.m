//
//  DepartmetCollectionVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/30/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DepartmetCollectionVC.h"
#import "DepartmentCollectionCell.h"
#import "RmsDbController.h"
#import "Item+Dictionary.h"
typedef NS_ENUM(NSUInteger, DepartmentOperation)
{
    INSERT_DEPARTMENT,
    UPDATE_DEPARTMENT,
    DELETE_DEPARTMENT,
    MOVE_DEPARTMENT,
    INSERT_DEPARTMENT_SECTION,
    DELETE_DEPARTMENT_SECTION,
};

@interface DepartmetCollectionVC ()
{
    NSIndexPath *indxpath;
}
@property (nonatomic, strong) NSFetchedResultsController *departmentResultController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UICollectionView *departmentCollectionView;
@property (nonatomic, weak) IBOutlet UIPageControl *departmentPageControl;
@property (nonatomic, strong) NSRecursiveLock *deptCollectionLock;
@property (nonatomic, strong) NSMutableArray *departmentOperation;

@end

@implementation DepartmetCollectionVC
@synthesize departmentResultController = _departmentResultController;
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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.departmentCollectionView.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)updateDepartmentPageControl {
    float pageH = self.departmentCollectionView.bounds.size.height;
    float allPageH = self.departmentCollectionView.contentSize.height;
    int numberOfPage= allPageH/pageH;
    if (numberOfPage < 10) {
        self.departmentPageControl.numberOfPages = numberOfPage+1;
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateDepartmentPageControl];
}


-(void)scrollDepartmentCollectionViewToTop
{
    NSArray *sections = self.departmentResultController.sections;
    if(sections.count == 0)
    {
        return;
    }
    else
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
        if(sectionInfo.numberOfObjects == 0)
        {
            return;
        }
    }
    self.departmentPageControl.currentPage = 0;
    [self.departmentCollectionView deselectItemAtIndexPath:indxpath animated:YES];
    [self.departmentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - Fetched Department results controller

- (NSFetchedResultsController *)departmentResultController {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.deptCollectionLock];
    
    if (_departmentResultController != nil) {
        return _departmentResultController;
    }

    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
//    fetchRequest.relationshipKeyPathsForPrefetching =
//    [NSArray arrayWithObject:@"Item"];

  //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itm_Type  = %@ AND ANY itemDepartment.departmentItems.isDisplayInPos == %@", @"1", @(1)];
    
  //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itm_Type  = %@ AND ANY itemDepartment.departmentItems.isDisplayInPos == %@ AND isNotDisplayInventory == %@ ", @"1", @(1),@(0)];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"active == %@ AND isDisplayInPos == %@ AND isNotDisplayInventory == %@",@(1), @(1), @(0)];
    fetchRequest.predicate = predicate;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item_Desc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    
    // Create and initialize the fetch results controller.
    _departmentResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_departmentResultController performFetch:nil];
    _departmentResultController.delegate = self;
    [lock unlock];
    return _departmentResultController;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.departmentCollectionView.frame.size.height;
    self.departmentPageControl.currentPage = ceilf((self.departmentCollectionView.contentOffset.y / pageWidth));
}
- (IBAction)changeDepartmentPage:(UIPageControl *)sender {
    float yPosCollectionView =self.departmentCollectionView.bounds.size.height*sender.currentPage;
    if (yPosCollectionView+self.departmentCollectionView.bounds.size.height>self.departmentCollectionView.contentSize.height) {
        yPosCollectionView=self.departmentCollectionView.contentSize.height-self.departmentCollectionView.bounds.size.height;
    }
    CGPoint setCurrentPage=CGPointMake(0,yPosCollectionView);
    [self.departmentCollectionView setContentOffset:setCurrentPage animated:YES];
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSArray *sections = self.departmentResultController.sections;
    return sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sections = self.departmentResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    [self.departmetCollectionCountDelegate didChangeDepartmentCount:sectionInfo.numberOfObjects];
//    if (self.numerOfItemPerPage > 0) {
//        float Pages = ceilf([sectionInfo numberOfObjects]/self.numerOfItemPerPage);
//        self.departmentPageControl.numberOfPages = Pages;
//    }
    return sectionInfo.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DepartmentCollectionCell *deptCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DepartmentCollectionCell" forIndexPath:indexPath];
    
    //deptCell.layer.borderWidth = 1.0;
    //deptCell.layer.borderColor = [[UIColor lightGrayColor] CGColor ];
    deptCell.layer.cornerRadius = 10.0;
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(20/255.f) green:(34/255.f) blue:(61/255.f) alpha:1.0];
    deptCell.selectedBackgroundView = selectionColor;
    
//    UIView *backColor = [[UIView alloc] init];
//    backColor.backgroundColor = [UIColor colorWithRed:(239/255.f) green:(234/255.f) blue:(234/255.f) alpha:1.0];
//    deptCell.backgroundView = backColor;
    
//    Department *dept = [self.departmentResultController objectAtIndexPath:indexPath];
    Item *item = [self.departmentResultController objectAtIndexPath:indexPath];
    Department *dept = item.itemDepartment;
  //  NSLog(@"Item name = %@",item.item_Desc);
    
    NSMutableDictionary *departmentDictionary = [item.itemDictionary mutableCopy];
    
    //BOOL ispos = [[departmentDictionary valueForKey:@"isPOS"]boolValue];
    
   // if(ispos == YES){
    
//        AsyncImageView *oldImage = (AsyncImageView *)
//        [deptCell.contentView viewWithTag:999];
//        [oldImage removeFromSuperview];
//        
//        deptCell.deptImage.tag = 999;
        NSString *checkImageName = departmentDictionary[@"ItemImage"];
    
        if ([checkImageName isEqualToString:@""])
        {
            deptCell.deptImageNoImg.image = [UIImage imageNamed:@"rcr_noimageforringeduplist.png"];
            deptCell.departMentNameNoImg.text = [NSString stringWithFormat:@"%@",(departmentDictionary)[@"ItemName"]];

            deptCell.departMentName.text  = @"";
            deptCell.deptImage.image = nil;
        }
        else
        {
            [deptCell.deptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",departmentDictionary[@"ItemImage"]]]];
            deptCell.departMentName.text = [NSString stringWithFormat:@"%@",(departmentDictionary)[@"ItemName"]];
            
            deptCell.deptImageNoImg.image = nil;
            deptCell.departMentNameNoImg.text = @"";
        }
        [deptCell.contentView addSubview:deptCell.deptImage];
        [deptCell.contentView addSubview:deptCell.departMentName];
        [deptCell.contentView addSubview:deptCell.deptImageNoImg];
        [deptCell.contentView addSubview:deptCell.departMentNameNoImg];



       // deptCell.departMentName.text = [item.item_Desc capitalizedString];
   // }
    return deptCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    indxpath = indexPath;
    UICollectionViewCell *collectionCell = [collectionView cellForItemAtIndexPath:indexPath];
    Item *item = [self.departmentResultController objectAtIndexPath:indexPath];
    
    if ([item.itm_Type isEqualToString:@"1"]) {
        Department *selectedDept = item.itemDepartment;
        [self.departmetCollectionVcDelegate didSelectedDepartment:selectedDept withUICollectionViewCell:collectionCell];
    }
    else{
        [self.departmetCollectionVcDelegate didAddItemFromFavouriteList:item.itemCode.stringValue];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if (![controller isEqual:self.departmentResultController]) {
        [self unlockResultController];
        return;
    }
    else if (_departmentResultController == nil){
        [self unlockResultController];
        return;
    }
    self.departmentOperation = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.departmentResultController]) {
        return;
    }
    else if (_departmentResultController == nil){
        return;
    }
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.departmentOperation addObject:@{@(INSERT_DEPARTMENT):[newIndexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.departmentOperation addObject:@{@(DELETE_DEPARTMENT):[indexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            [self.departmentOperation addObject:@{@(UPDATE_DEPARTMENT):[indexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeMove:
        {
            [self.departmentOperation addObject:@{@(MOVE_DEPARTMENT):@[[indexPath copy],[newIndexPath copy]]}];
        }
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.departmentResultController]) {
        return;
    }
    else if (_departmentResultController == nil){
        return;
    }

    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.departmentOperation addObject:@{@(INSERT_DEPARTMENT_SECTION):@(sectionIndex)}];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.departmentOperation addObject:@{@(DELETE_DEPARTMENT_SECTION):@(sectionIndex)}];
        }
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.departmentResultController]) {
        return;
    }
    else if (_departmentResultController == nil){
        return;
    }

    //    NSLog(@"Will update Departments");
    [self.departmentCollectionView performBatchUpdates:^{
        //        NSLog(@"departmentOperation count = %d",[self.departmentOperation count]);
        for (int i = 0; i < self.departmentOperation.count; i++)
        {
            NSDictionary *tenderDict = (self.departmentOperation)[i];
            NSArray *tenderAllKey = tenderDict.allKeys;
            NSNumber *tenderType = tenderAllKey.firstObject;
            DepartmentOperation deptSection = tenderType.integerValue;
            switch (deptSection) {
                case INSERT_DEPARTMENT:
                {
                    //NSLog(@"INSERT_DEPARTMENT");
                    NSIndexPath *insertIndPath = tenderDict[tenderType];
                    [self.departmentCollectionView insertItemsAtIndexPaths:@[insertIndPath]];
                }
                    break;
                    
                case DELETE_DEPARTMENT:
                {
                    NSIndexPath *deleteIndPath = tenderDict[tenderType];
                    //NSLog(@"DELETE_DEPARTMENT %@",deleteIndPath);
                    [self.departmentCollectionView deleteItemsAtIndexPaths:@[deleteIndPath]];
                }
                    break;
                    
                case UPDATE_DEPARTMENT:
                {
                    //                    NSLog(@"UPDATE_DEPARTMENT");
                    NSIndexPath *updateIndPath = tenderDict[tenderType];
                    //[self collectionView:self.tenderShortcutCollectionView cellForItemAtIndexPath:updateIndPath];
                    [self.departmentCollectionView reloadItemsAtIndexPaths:@[updateIndPath]];
                }
                    break;
                    
                case MOVE_DEPARTMENT:
                {
                    //                    NSLog(@"MOVE_DEPARTMENT");
                    NSArray *moveIndPath = tenderDict[tenderType];
                    NSIndexPath *delIndPath = moveIndPath.firstObject ;
                    NSIndexPath *insIndPath = moveIndPath[1];
                    [self.departmentCollectionView moveItemAtIndexPath:delIndPath toIndexPath:insIndPath];
                }
                    break;
                    
                case INSERT_DEPARTMENT_SECTION:
                {
                    //                    NSLog(@"INSERT_DEPARTMENT_SECTION");
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.departmentCollectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                case DELETE_DEPARTMENT_SECTION:
                {
                    //                    NSLog(@"DELETE_DEPARTMENT_SECTION");
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.departmentCollectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                default:
                    break;
            }
        }
    } completion:^(BOOL finished){
        [self unlockResultController];
        //        NSLog(@"Department update - done");
        float pageH = self.departmentCollectionView.bounds.size.height;
        float allPageH = self.departmentCollectionView.contentSize.height;
        int numberOfPage= allPageH/pageH;
        if (numberOfPage < 10) {
            self.departmentPageControl.numberOfPages = numberOfPage+1;
        }
        NSArray *sections = self.departmentResultController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
        [self.departmetCollectionCountDelegate didChangeDepartmentCount:sectionInfo.numberOfObjects];

    }];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)deptCollectionLock {
    if (_deptCollectionLock == nil) {
        _deptCollectionLock = [[NSRecursiveLock alloc] init];
    }
    return _deptCollectionLock;
}

-(void)lockResultController
{
    [self.deptCollectionLock lock];
}

-(void)unlockResultController
{
    [self.deptCollectionLock unlock];
}

-(void)setDepartmentResultController:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.deptCollectionLock];
    _departmentResultController = resultController;
    [lock unlock];
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
