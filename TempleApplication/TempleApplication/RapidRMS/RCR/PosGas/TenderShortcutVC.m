//
//  TenderShortcutVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 10/31/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TenderShortcutVC.h"
#import "TenderShortcutCell.h"
#import "RmsDbController.h"
#import "TenderPay+Dictionary.h"

typedef NS_ENUM(NSUInteger, TenderOperation)
{
    INSERT_TENDER_SHORTCUT,
    UPDATE_TENDER_SHORTCUT,
    DELETE_TENDER_SHORTCUT,
    MOVE_TENDER_SHORTCUT,
    INSERT_TENDER_SECTION,
    DELETE_TENDER_SECTION,
};

@interface TenderShortcutVC ()
{
    NSMutableArray *tenderCoreDataArray;
}

@property (nonatomic, weak) IBOutlet UICollectionView *tenderShortcutCollectionView;
@property (nonatomic, weak) IBOutlet UIPageControl *tenderShortcutPagecontrol;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) NSFetchedResultsController *tenderShortcutResultContoller;
@property (nonatomic, strong) NSMutableArray *tenderShortArray;
@property (nonatomic, strong) NSRecursiveLock *tenderLock;

@end

@implementation TenderShortcutVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize tenderShortcutResultContoller = _tenderShortcutResultContoller;

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
    NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"TendConfig" ];
    if(arrTemp.count > 0)
    {
        self.crmController.globalArrTenderConfig = [arrTemp mutableCopy];
    }
    [self filterTenderPaymentArrayWithSpecOption];
    self.tenderShortcutPagecontrol.transform = CGAffineTransformMakeRotation(-M_PI/2);
    // Do any additional setup after loading the view.
}

-(void)filterTenderPaymentArrayWithSpecOption
{
    tenderCoreDataArray = [[NSMutableArray alloc]init];
    NSPredicate *tenderPredicate = [NSPredicate predicateWithFormat:@"SpecOption == %@",@"10"];
    NSArray *filterPaymentArray = [self.crmController.globalArrTenderConfig filteredArrayUsingPredicate:tenderPredicate];
    if (filterPaymentArray.count > 0)
    {
        for (NSDictionary * dict in filterPaymentArray) {
            
            NSPredicate *tenderDisablePredicate = [NSPredicate predicateWithFormat:@"SpecOption == %@ AND PayId == %@",@"11",[dict valueForKey:@"PayId"]];
            NSArray *tenderDisableArray = [self.crmController.globalArrTenderConfig filteredArrayUsingPredicate:tenderDisablePredicate];
            if (tenderDisableArray.count > 0) {
                continue;
            }
           // TenderPay *pay = [self fetchPaymentObjectFromPaymentId:[dict valueForKey:@"PayId"]];
           // if(pay != nil)
            {
                [tenderCoreDataArray addObject:[dict valueForKey:@"PayId"]];
            }
        }
//        if (tenderCoreDataArray.count <= 3)
//        {
//            CGSize  tenderCollectionViewSize = self.tenderShortcutCollectionView.frame.size;
//            tenderCollectionViewSize.width = tenderCoreDataArray.count * 90 ;
//            self.tenderShortcutCollectionView.frame = CGRectMake(self.tenderShortcutCollectionView.frame.origin.x
//                                                                 +270- tenderCollectionViewSize.width
//                                                                 , self.tenderShortcutCollectionView.frame.origin.y
//                                                                 , tenderCollectionViewSize.width,
//                                                                 self.tenderShortcutCollectionView.frame.size.height);
//        }
        self.tenderShortcutResultContoller = nil;
    }
}

-(TenderPay *)fetchPaymentObjectFromPaymentId :(NSString *)paymentId
{
    TenderPay * tenderPay = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payId==%d", paymentId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        tenderPay=resultSet.firstObject;
    }
    return tenderPay;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.tenderShortcutCollectionView.frame.size.width;
    if(self.tenderShortcutCollectionView.contentOffset.x >0)
    {
        NSInteger pageNO = floor((self.tenderShortcutCollectionView.contentOffset.x + pageWidth ) * 2) / pageWidth;
        self.tenderShortcutPagecontrol.currentPage = pageNO;
    }
    else
    {
        self.tenderShortcutPagecontrol.currentPage = 0;
    }
}

- (NSFetchedResultsController *)tenderShortcutResultContoller
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.tenderLock];
    if (_tenderShortcutResultContoller != nil) {
        return _tenderShortcutResultContoller;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TenderPay" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payId IN %@", tenderCoreDataArray];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"cardIntType" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _tenderShortcutResultContoller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_tenderShortcutResultContoller performFetch:nil];
    _tenderShortcutResultContoller.delegate = self;
    [lock unlock];
    return _tenderShortcutResultContoller;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sections = self.tenderShortcutResultContoller.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    float Pages = ceilf(sectionInfo.numberOfObjects/3.0);
    self.tenderShortcutPagecontrol.numberOfPages = Pages;
    return sectionInfo.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TenderShortcutCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TenderShortcutCell" forIndexPath:indexPath];
    cell.tenderPaymentName.text = [[self.tenderShortcutResultContoller objectAtIndexPath:indexPath] valueForKey:@"paymentName"];
    NSString *checkImageName = [[self.tenderShortcutResultContoller objectAtIndexPath:indexPath] valueForKey:@"payImage"];
    if ([checkImageName isEqualToString:@""])
    {
        cell.tenderShortcutImage.image = [UIImage imageNamed:@"noimage.png"];
    }
    else
    {
        [cell.tenderShortcutImage loadImageFromURL:[NSURL URLWithString:checkImageName]];
    }
    cell.btnTenderShortCut.tag = indexPath.row;
    [cell.btnTenderShortCut addTarget:self
                               action:@selector(btnTenderShortCutClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
    cell.selectedBackgroundView = selectionColor;
    
    UIView *backColor = [[UIView alloc] init];
    backColor.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backColor;
    //cell.tenderShortcutImage.layer.cornerRadius = cell.tenderShortcutImage.frame.size.width / 2;
    //cell.tenderShortcutImage.clipsToBounds = YES;
    return cell;
}

-(void)btnTenderShortCutClick:(UIButton*)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self.tenderShortcutCollectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.tenderShortCutDelegate didTenderTransactionUsingTenderType:[[self.tenderShortcutResultContoller objectAtIndexPath:indexPath] valueForKey:@"cardIntType"] withPayId:[[self.tenderShortcutResultContoller objectAtIndexPath:indexPath] valueForKey:@"payId"]];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSArray *sections = self.tenderShortcutResultContoller.sections;
    return sections.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.tenderShortCutDelegate didTenderTransactionUsingTenderType:[[self.tenderShortcutResultContoller objectAtIndexPath:indexPath] valueForKey:@"cardIntType"] withPayId:[[self.tenderShortcutResultContoller objectAtIndexPath:indexPath] valueForKey:@"payId"]];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self lockResultController];
    if (![controller isEqual:self.tenderShortcutResultContoller]) {
        [self unlockResultController];
        return;
    }
    else if (_tenderShortcutResultContoller == nil){
        [self unlockResultController];
        return;
    }

    self.tenderShortArray = [[NSMutableArray alloc] init];
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    // [self.tenderShortcutCollectionView ];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.tenderShortcutResultContoller]) {
        return;
    }
    else if (_tenderShortcutResultContoller == nil){
        return;
    }

    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.tenderShortArray addObject:@{@(INSERT_TENDER_SHORTCUT):[newIndexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.tenderShortArray addObject:@{@(DELETE_TENDER_SHORTCUT):[indexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            [self.tenderShortArray addObject:@{@(UPDATE_TENDER_SHORTCUT):[indexPath copy]}];
        }
            break;
            
        case NSFetchedResultsChangeMove:
        {
            [self.tenderShortArray addObject:@{@(MOVE_TENDER_SHORTCUT):@[[indexPath copy],[newIndexPath copy]]}];
        }
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.tenderShortcutResultContoller]) {
        return;
    }
    else if (_tenderShortcutResultContoller == nil){
        return;
    }

    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.tenderShortArray addObject:@{@(INSERT_TENDER_SECTION):@(sectionIndex)}];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.tenderShortArray addObject:@{@(DELETE_TENDER_SECTION):@(sectionIndex)}];
        }
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.tenderShortcutResultContoller]) {
        return;
    }
    else if (_tenderShortcutResultContoller == nil){
        return;
    }

    [self.tenderShortcutCollectionView performBatchUpdates:^{
        
        for (int i = 0; i < self.tenderShortArray.count; i++)
        {
            NSDictionary *tenderDict = (self.tenderShortArray)[i];
            NSArray *tenderAllKey = tenderDict.allKeys;
            NSNumber *tenderType = tenderAllKey.firstObject;
            TenderOperation InfoSection = tenderType.integerValue;
            switch (InfoSection) {
                case INSERT_TENDER_SHORTCUT:
                {
                    NSIndexPath *insertIndPath = tenderDict[tenderType];
                    [self.tenderShortcutCollectionView insertItemsAtIndexPaths:@[insertIndPath]];
                }
                    break;
                    
                case DELETE_TENDER_SHORTCUT:
                {
                    NSIndexPath *deleteIndPath = tenderDict[tenderType];
                    [self.tenderShortcutCollectionView deleteItemsAtIndexPaths:@[deleteIndPath]];
                }
                    break;
                    
                case UPDATE_TENDER_SHORTCUT:
                {
                    NSIndexPath *updateIndPath = tenderDict[tenderType];
                    //[self collectionView:self.tenderShortcutCollectionView cellForItemAtIndexPath:updateIndPath];
                    [self.tenderShortcutCollectionView reloadItemsAtIndexPaths:@[updateIndPath]];
                }
                    break;
                    
                case MOVE_TENDER_SHORTCUT:
                {
                    NSArray *moveIndPath = tenderDict[tenderType];
                    NSIndexPath *delIndPath = moveIndPath.firstObject ;
                    NSIndexPath *insIndPath = moveIndPath[1];
                    [self.tenderShortcutCollectionView moveItemAtIndexPath:delIndPath toIndexPath:insIndPath];
                }
                    break;
                    
                case INSERT_TENDER_SECTION:
                {
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.tenderShortcutCollectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                case DELETE_TENDER_SECTION:
                {
                    NSNumber *sectionIndex = tenderDict[tenderType];
                    [self.tenderShortcutCollectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue ]];
                }
                    break;
                    
                default:
                    break;
            }
        }
    } completion:^(BOOL finished){
       [self unlockResultController];
    }];
}

#pragma mark - NSRecursiveLock Methods

- (NSRecursiveLock *)tenderLock {
    if (_tenderLock == nil) {
        _tenderLock = [[NSRecursiveLock alloc] init];
    }
    return _tenderLock;
}

-(void)lockResultController
{
    [self.tenderLock lock];
}

-(void)unlockResultController
{
    [self.tenderLock unlock];
}

-(void)setTenderShortcutResultContoller:(NSFetchedResultsController *)resultController
{
    RapidAutoLock *lock  = [[RapidAutoLock alloc] initWithLock:self.tenderLock];
    _tenderShortcutResultContoller = resultController;
    [lock unlock];
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
