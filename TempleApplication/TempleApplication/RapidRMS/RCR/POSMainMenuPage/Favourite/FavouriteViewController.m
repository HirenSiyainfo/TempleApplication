//
//  FavouriteViewController.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "FavouriteViewController.h"
#import "Item+Dictionary.h"
#import "RmsDbController.h"
#import "FavouriteViewCollectionCell.h"

typedef NS_ENUM(NSUInteger, FavouriteOperation)
{
    INSERT_FAVOURITE,
    UPDATE_FAVOURITE,
    DELETE_FAVOURITE,
    MOVE_FAVOURITE,
    INSERT_FAVOURITE_SECTION,
    DELETE_FAVOURITE_SECTION,
};


@interface FavouriteViewController ()
{
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSFetchedResultsController *favouriteResultContoller;
@property (nonatomic, strong) NSRecursiveLock *favCollectionLock;
@property (nonatomic, strong) NSMutableArray *favouriteOperation;
@property (nonatomic ,strong) NSString *selectedId;
@property (nonatomic ,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic ,strong) NSDictionary *dictFavourite;



@end

@implementation FavouriteViewController
@synthesize favouriteCollectionView;
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
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    [_activityIndicator hideActivityIndicator];
    UINib *cellNib = [UINib nibWithNibName:@"FavouriteViewCollectionCell" bundle:nil];
    [favouriteCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"FavouriteCell"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    NSPredicate *isFavourite = [NSPredicate predicateWithFormat:@"isFavourite == %d", isFav];
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSArray *sections = self.favouriteResultContoller.sections;
    return sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sections = self.favouriteResultContoller.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FavouriteViewCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FavouriteCell" forIndexPath:indexPath];
    Item *item = [self.favouriteResultContoller objectAtIndexPath:indexPath ];
    _dictFavourite= item.itemDictionary;
    cell.lblItemName.text = [NSString stringWithFormat:@"%@",_dictFavourite[@"ItemName"]];
    cell.lblItemName.numberOfLines=0;
    cell.lblSalesPrice.text = [NSString stringWithFormat:@"%@",_dictFavourite[@"Price"]];
    cell.lblSalesPrice.numberOfLines=0;

    AsyncImageView *oldImage = (AsyncImageView *)
    [cell.contentView viewWithTag:999];
    [oldImage removeFromSuperview];
    
    
    AsyncImageView * itemImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(2, 1, 65, 68)];
    itemImage.backgroundColor = [UIColor clearColor];
    itemImage.layer.borderColor = [UIColor whiteColor].CGColor;
    itemImage.tag = 999;
    NSString *checkImageName = _dictFavourite[@"ItemImage"];
    
    if ([checkImageName isEqualToString:@""])
    {
        itemImage.image = [UIImage imageNamed:@"favouriteNoImage.png"];

    }
    else
    {
        [itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_dictFavourite[@"ItemImage"]]]];
    }
    
    [cell.contentView addSubview:itemImage];
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.favouriteResultContoller objectAtIndexPath:indexPath ];
    _dictFavourite = item.itemDictionary;
    _selectedId = _dictFavourite[@"ItemId"];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if (![controller isEqual:self.favouriteResultContoller]) {
        [self unlockResultController];
        return;
    }
    else if (self.favouriteResultContoller == nil){
        [self unlockResultController];
        return;
    }
    self.favouriteOperation = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.favouriteResultContoller]) {
        return;
    }
    else if (self.favouriteResultContoller == nil){
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
    else if (self.favouriteResultContoller == nil){
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
    else if (self.favouriteResultContoller == nil){
        return;
    }

    [self.favouriteCollectionView performBatchUpdates:^{
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
                    [self.favouriteCollectionView insertItemsAtIndexPaths:@[insertIndPath]];
                }
                    break;
                    
                case DELETE_FAVOURITE:
                {
                    NSIndexPath *deleteIndPath = tenderDict[tenderType];
                    [self.favouriteCollectionView deleteItemsAtIndexPaths:@[deleteIndPath]];
                }
                    break;
                    
                case UPDATE_FAVOURITE:
                {
                    NSIndexPath *updateIndPath = tenderDict[tenderType];
                    [self.favouriteCollectionView reloadItemsAtIndexPaths:@[updateIndPath]];
                }
                    break;
                    
                case MOVE_FAVOURITE:
                {
                    NSArray *moveIndPath = tenderDict[tenderType];
                    NSIndexPath *delIndPath = moveIndPath.firstObject ;
                    NSIndexPath *insIndPath = moveIndPath[1];
                    [self.favouriteCollectionView moveItemAtIndexPath:delIndPath toIndexPath:insIndPath];
                }
                    break;
                    
                case INSERT_FAVOURITE_SECTION:
                {
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.favouriteCollectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                case DELETE_FAVOURITE_SECTION:
                {
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.favouriteCollectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                default:
                    break;
            }
        }
    } completion:^(BOOL finished){
        [self unlockResultController];
        //        NSLog(@"Department update - done");
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

@end
