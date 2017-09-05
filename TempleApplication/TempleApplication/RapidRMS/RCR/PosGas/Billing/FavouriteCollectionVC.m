//
//  FavouriteCollectionVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/6/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "FavouriteCollectionVC.h"
#import "RmsDbController.h"
#import "RcrController.h"
#import "FavouriteItemCollectionCell.h"
#import "Item+Dictionary.h"

typedef NS_ENUM(NSUInteger, FavouriteOperation)
{
    INSERT_FAVOURITE,
    UPDATE_FAVOURITE,
    DELETE_FAVOURITE,
    MOVE_FAVOURITE,
    INSERT_FAVOURITE_SECTION,
    DELETE_FAVOURITE_SECTION,
};

@interface FavouriteCollectionVC ()
{
    NSIndexPath *indxpath;
    Configuration *configuration;
}
@property (nonatomic, weak) IBOutlet UICollectionView *favouriteItemCollectionView;
@property (nonatomic, weak) IBOutlet UIPageControl *favouritePageControl;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) NSFetchedResultsController *favouriteResultContoller;
@property (nonatomic, strong) NSRecursiveLock *favCollectionLock;
@property (nonatomic, strong) NSMutableArray *favouriteOperation;
@property (strong, nonatomic) NSDictionary *dictFavourite;

@end

@implementation FavouriteCollectionVC
@synthesize favouriteResultContoller = _favouriteResultContoller;
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
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
}

-(void)updateFavouritePageControl
{
    float pageH = self.favouriteItemCollectionView.bounds.size.height;
    float allPageH = self.favouriteItemCollectionView.contentSize.height;
    int numberOfPage= allPageH/pageH;
    self.favouritePageControl.numberOfPages = numberOfPage+1;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.favouriteItemCollectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateFavouritePageControl];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)scrollFavouriteCollectionViewToTop;
{
    NSArray *sections = self.favouriteResultContoller.sections;
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
    self.favouritePageControl.currentPage = 0;
    [self.favouriteItemCollectionView deselectItemAtIndexPath:indxpath animated:YES];
    [self.favouriteItemCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.favouriteItemCollectionView.frame.size.height;
    self.favouritePageControl.currentPage =  ceilf((self.favouriteItemCollectionView.contentOffset.y / pageWidth));
}

- (BOOL)isSubDepartmentEnableInBackOffice {
    BOOL isSubdepartment = false;
    if([configuration.subDepartment isEqual:@(1)]){
        isSubdepartment = true;
    }
    return isSubdepartment;
}

- (NSFetchedResultsController *)favouriteResultContoller {
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.favCollectionLock];
    if (_favouriteResultContoller != nil) {
        return _favouriteResultContoller;
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    int isFav = 1;
    NSPredicate *isFavourite;
    if ([self isSubDepartmentEnableInBackOffice]) {
        isFavourite = [NSPredicate predicateWithFormat:@"isFavourite == %d  AND active == %d AND itemDepartment.isNotApplyInItem == %@", isFav,TRUE , @(0)];
    }
    else {
        isFavourite = [NSPredicate predicateWithFormat:@"isFavourite == %d  AND active == %d AND itemDepartment.isNotApplyInItem == %@ AND itm_Type != %@", isFav,TRUE , @(0),@(2)];
    }
    fetchRequest.predicate = isFavourite;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item_Desc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _favouriteResultContoller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_favouriteResultContoller performFetch:nil];
    _favouriteResultContoller.delegate = self;
    [lock unlock];
    return _favouriteResultContoller;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sections = self.favouriteResultContoller.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    [self.favouriteCollectionCountDelegate didChangeFavouriteCount:sectionInfo.numberOfObjects];
//    if (self.numerOfItemPerPage > 0) {
//        float Pages = ceilf([sectionInfo numberOfObjects]/self.numerOfItemPerPage);
//        self.favouritePageControl.numberOfPages = Pages;
//    }
    return sectionInfo.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FavouriteItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FavouriteItemCollection" forIndexPath:indexPath];
    
   // cell.layer.borderWidth = 1.0;
  //  cell.layer.borderColor = [[UIColor lightGrayColor] CGColor ];
    cell.layer.cornerRadius = 10.0;

    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
    cell.selectedBackgroundView = selectionColor;
    
//    UIView *backColor = [[UIView alloc] init];
//    backColor.backgroundColor = [UIColor colorWithRed:(239.0/255.f) green:(234.0/255.f) blue:(234.0/255.f) alpha:1.0];
//    cell.backgroundView = backColor;
    
    Item *item = [self.favouriteResultContoller objectAtIndexPath:indexPath ];
    self.dictFavourite= item.itemDictionary;
    
    
    NSNumber *sPrice = @([(self.dictFavourite)[@"Price"] floatValue]);
//    if (sPrice.floatValue == 0)
//    {
//        cell.salesPriceLabel.hidden = YES;
//    }
//    else
//    {
//        cell.salesPriceLabel.hidden = NO;
//    }
    cell.salesPriceLabel.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:sPrice]];
    cell.salesPriceLabel.numberOfLines=0;
    
//    AsyncImageView *oldImage = (AsyncImageView *)
//    [cell.contentView viewWithTag:999];
//    [oldImage removeFromSuperview];
    
    cell.itemImage.tag = 999;
    NSString *checkImageName = (self.dictFavourite)[@"ItemImage"];
    
    if ([checkImageName isEqualToString:@""])
    {
        cell.itemImageNoImg.image = [UIImage imageNamed:@"rcr_noimageforringeduplist.png"];
        cell.itemImage.image = nil;
        cell.itemNameLabelNoImg.text = [NSString stringWithFormat:@"%@",(self.dictFavourite)[@"ItemName"]];
        cell.itemNameLabel.text = @"";
    }
    else
    {
        [cell.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",(self.dictFavourite)[@"ItemImage"]]]];
        cell.itemImageNoImg.image = nil;
        cell.itemNameLabel.text = [NSString stringWithFormat:@"%@",(self.dictFavourite)[@"ItemName"]];
        cell.itemNameLabelNoImg.text = @"";

    }
    
    
    //cell.itemNameLabel.numberOfLines = 2;

   // [cell.contentView addSubview:cell.itemImage];

    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSArray *sections = self.favouriteResultContoller.sections;
    return sections.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    indxpath = indexPath;
    Item *item = [self.favouriteResultContoller objectAtIndexPath:indexPath ];
    [self.favouriteCollectionDelegate didAddItemFromFavouriteList:item.itemCode.stringValue];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if (![controller isEqual:self.favouriteResultContoller]) {
        [self unlockResultController];
        return;
    }
    else if (_favouriteResultContoller == nil){
        [self unlockResultController];
        return;
    }
    self.favouriteOperation = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.favouriteResultContoller]) {
        return;
    }
    else if (_favouriteResultContoller == nil){
        return;
    }
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.favouriteOperation addObject:@{@(INSERT_FAVOURITE):[newIndexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.favouriteOperation addObject:@{@(DELETE_FAVOURITE):[indexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            [self.favouriteOperation addObject:@{@(UPDATE_FAVOURITE):[indexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeMove:
        {
            [self.favouriteOperation addObject:@{@(MOVE_FAVOURITE):@[[indexPath copy],[newIndexPath copy]]}];
        }
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.favouriteResultContoller]) {
        return;
    }
    else if (_favouriteResultContoller == nil){
        return;
    }
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.favouriteOperation addObject:@{@(INSERT_FAVOURITE_SECTION):@(sectionIndex)}];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.favouriteOperation addObject:@{@(DELETE_FAVOURITE_SECTION):@(sectionIndex)}];
        }
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.favouriteResultContoller]) {
        return;
    }
    else if (_favouriteResultContoller == nil){
        return;
    }
    [self.favouriteItemCollectionView performBatchUpdates:^{
        for (int i = 0; i < self.favouriteOperation.count; i++)
        {
            NSDictionary *tenderDict = (self.favouriteOperation)[i];
            NSArray *tenderAllKey = tenderDict.allKeys;
            NSNumber *tenderType = tenderAllKey.firstObject;
            FavouriteOperation favSection = tenderType.integerValue;
            switch (favSection) {
                case INSERT_FAVOURITE:
                {
                    NSIndexPath *insertIndPath = tenderDict[tenderType];
                    [self.favouriteItemCollectionView insertItemsAtIndexPaths:@[insertIndPath]];
                }
                    break;
                    
                case DELETE_FAVOURITE:
                {
                    NSIndexPath *deleteIndPath = tenderDict[tenderType];
                    [self.favouriteItemCollectionView deleteItemsAtIndexPaths:@[deleteIndPath]];
                }
                    break;
                    
                case UPDATE_FAVOURITE:
                {
                    NSIndexPath *updateIndPath = tenderDict[tenderType];
                    [self.favouriteItemCollectionView reloadItemsAtIndexPaths:@[updateIndPath]];
                }
                    break;
                    
                case MOVE_FAVOURITE:
                {
                    NSArray *moveIndPath = tenderDict[tenderType];
                    NSIndexPath *delIndPath = moveIndPath.firstObject ;
                    NSIndexPath *insIndPath = moveIndPath[1];
                    [self.favouriteItemCollectionView moveItemAtIndexPath:delIndPath toIndexPath:insIndPath];
                }
                    break;
                    
                case INSERT_FAVOURITE_SECTION:
                {
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.favouriteItemCollectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                case DELETE_FAVOURITE_SECTION:
                {
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.favouriteItemCollectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                default:
                    break;
            }
        }
    } completion:^(BOOL finished){
        NSArray *sections = self.favouriteResultContoller.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections.firstObject;
        [self.favouriteCollectionCountDelegate didChangeFavouriteCount:sectionInfo.numberOfObjects];
        [self unlockResultController];
    }];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)favCollectionLock {
    if (_favCollectionLock == nil) {
        _favCollectionLock = [[NSRecursiveLock alloc] init];
    }
    return _favCollectionLock;
}

-(void)lockResultController
{
    [self.favCollectionLock lock];
}

-(void)unlockResultController
{
    [self.favCollectionLock unlock];
}

-(void)setFavouriteResultContoller:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.favCollectionLock];
    _favouriteResultContoller = resultController;
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
