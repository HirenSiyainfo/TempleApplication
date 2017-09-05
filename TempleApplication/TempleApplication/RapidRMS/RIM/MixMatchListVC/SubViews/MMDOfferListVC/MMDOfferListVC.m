//
//  MMDOfferListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 19/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDOfferListVC.h"
#import "MMDOfferListCell.h"
#import "Discount_M.h"
#import "RmsDbController.h"

@interface MMDOfferListVC ()<NSFetchedResultsControllerDelegate> {
    NSMutableArray * sectionChanges;
    NSMutableArray * objectChanges;
    id selectedOffer;
}
@property (nonatomic, strong) NSFetchedResultsController * MMDiscountListRC;
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSMutableArray *departmentOperation;

@property (nonatomic, weak) IBOutlet UICollectionView * collOfferList;
@property (nonatomic, weak) IBOutlet UILabel * lblTitle;
@property (nonatomic, weak) IBOutlet UILabel * lblValidity;
@property (nonatomic, weak) IBOutlet UILabel * lblDetail;
@property (nonatomic, weak) IBOutlet UILabel * lblSDetail;

@end

@implementation MMDOfferListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.managedObjectContext = [RmsDbController sharedRmsDbController].managedObjectContext;
    sectionChanges = [[NSMutableArray alloc]init];
    objectChanges = [[NSMutableArray alloc]init];
//    [self setFackData];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (arrOfferList.count > 0) {
//        [self setFruntOfferDetail:[arrOfferList objectAtIndex:0]];
//    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSArray *sections = self.MMDiscountListRC.sections;
    return sections.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return arrOfferList.count;
    NSArray *sections = self.MMDiscountListRC.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMDOfferListCell *cell = (MMDOfferListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    Discount_M *objDiscount = [self.MMDiscountListRC objectAtIndexPath:indexPath];
    
    cell.lblOfferTitle.text = objDiscount.name;
    if (objDiscount.endDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy";
        cell.lblOfferValidity.text = [formatter stringFromDate:objDiscount.endDate];

    }
    else {
        cell.lblOfferValidity.text = @"Never Expires";
    }
    if (!selectedOffer && indexPath.row == 0) {
        [self setFruntOfferDetail:objDiscount];
    }
    if ([objDiscount isEqual:selectedOffer]) {
        cell.contentView.layer.borderColor = [UIColor colorWithRed:0.965 green:0.761 blue:0.471 alpha:1.000].CGColor;
        cell.contentView.layer.borderWidth = 8.0f;
    }
    else {
        cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        cell.contentView.layer.borderWidth = 0.0f;
    }
    int row = (int)indexPath.row;
    row= row%4;
    switch (row) {
        case 3:
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.969 green:0.110 blue:0.145 alpha:1.000];
            break;
        case 2:
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.843 green:0.486 blue:0.125 alpha:1.000];
            break;
        case 1:
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.890 green:0.514 blue:0.137 alpha:1.000];
            break;
        default:
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.988 green:0.584 blue:0.169 alpha:1.000];
            break;
    }
    return cell;
}

// Called after the user changes the selection.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self setFruntOfferDetail:[self.MMDiscountListRC objectAtIndexPath:indexPath]];
    [collectionView reloadData];
}
-(void)setFruntOfferDetail:(Discount_M *)newOffer {
    _lblTitle.text = newOffer.name;
    if (newOffer.endDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy";
        _lblValidity.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:newOffer.endDate]];
    }
    else {
        _lblValidity.text = @"Never Expires";
    }
    _lblDetail.text = newOffer.descriptionText;
    selectedOffer = newOffer;
}
-(void)setFackData {
    NSMutableArray * arrList = [[NSMutableArray alloc]init];
    NSMutableDictionary * dictItem = [[NSMutableDictionary alloc]init];
    dictItem[@"title"] = @"Title of offer1";
    dictItem[@"detail"] = @"buy 1 get 50 % off1";
    dictItem[@"sdetail"] = @"short note for offer1";
    [arrList addObject:[dictItem mutableCopy]];
    
    dictItem[@"title"] = @"Title of offer2";
    dictItem[@"detail"] = @"buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2";
    dictItem[@"sdetail"] = @"short note for offer2";
    [arrList addObject:[dictItem mutableCopy]];
    
    dictItem[@"title"] = @"Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3";
    dictItem[@"detail"] = @"buy 1 get 50 % off3";
    dictItem[@"sdetail"] = @"short note for offer3";
    [arrList addObject:[dictItem mutableCopy]];
    
    dictItem[@"title"] = @"Title of offer4";
    dictItem[@"detail"] = @"buy 1 get 50 % off4";
    dictItem[@"sdetail"] = @"short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4short note for offer4";
    [arrList addObject:[dictItem mutableCopy]];
    
    dictItem[@"title"] = @"Title of offer5";
    dictItem[@"detail"] = @"buy 1 get 50 % off5";
    dictItem[@"sdetail"] = @"short note for offer5";
    [arrList addObject:[dictItem mutableCopy]];
    
    dictItem[@"title"] = @"Title of offer1";
    dictItem[@"detail"] = @"buy 1 get 50 % off1";
    dictItem[@"sdetail"] = @"short note for offer1";
    [arrList addObject:[dictItem mutableCopy]];
    
    dictItem[@"title"] = @"Title of offer2";
    dictItem[@"detail"] = @"buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2buy 1 get 50 % off2";
    dictItem[@"sdetail"] = @"short note for offer2";
    [arrList addObject:[dictItem mutableCopy]];
    
    dictItem[@"title"] = @"Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3Title of offer3";
    dictItem[@"detail"] = @"buy 1 get 50 % off3";
    dictItem[@"sdetail"] = @"short note for offer3";
    [arrList addObject:[dictItem mutableCopy]];
    
//    arrOfferList = [[NSArray alloc]initWithArray:arrList];
}

#pragma mark - CoreData Methods -
- (NSFetchedResultsController *)MMDiscountListRC {
    
    if (_MMDiscountListRC != nil) {
        return _MMDiscountListRC;
    }
    
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Discount_M" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isDelete == %@ AND discountType != %d",@(0),4];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _MMDiscountListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_MMDiscountListRC performFetch:nil];
    _MMDiscountListRC.delegate = self;
    
    return _MMDiscountListRC;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger) sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @[@(sectionIndex)];
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @[@(sectionIndex)];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
    [sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [objectChanges addObject:change];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (sectionChanges.count > 0)
    {
        [_collOfferList performBatchUpdates:^{
            
            for (NSDictionary *change in sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = key.unsignedIntegerValue;
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [_collOfferList insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [_collOfferList deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [_collOfferList reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeMove: {
                            break;
                        }
                    }
                }];
            }
        } completion:nil];
    }
    
    if (objectChanges.count > 0 && sectionChanges.count == 0) {
        [_collOfferList performBatchUpdates:^{
            
            for (NSDictionary *change in objectChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = key.unsignedIntegerValue;
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [_collOfferList insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [_collOfferList deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [_collOfferList reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [_collOfferList moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    [sectionChanges removeAllObjects];
    [objectChanges removeAllObjects];
}

@end
