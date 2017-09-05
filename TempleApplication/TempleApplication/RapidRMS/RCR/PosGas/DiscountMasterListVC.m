//
//  DiscountMasterListVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 5/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "DiscountMasterListVC.h"
#import "RmsDbController.h"
#import "DiscountMasterListCell.h"
#import "DiscountMaster+Dictionary.h"
#define DiscountBackGroundViewRadiusNormal 10.0

#define DiscountBackGroundViewRadiusAnimated 30.0


@interface DiscountMasterListVC ()<NSFetchedResultsControllerDelegate>
{
    NSIndexPath *currentSelectedRowIndexpath;
}

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) NSFetchedResultsController *discountMasterListResultContoller;
@end

@implementation DiscountMasterListVC

@synthesize discountMasterListResultContoller = _discountMasterListResultContoller;
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
   currentSelectedRowIndexpath = [NSIndexPath indexPathForRow:-1 inSection:0];
}


- (NSFetchedResultsController *)discountMasterListResultContoller {
    if (_discountMasterListResultContoller != nil) {
        return _discountMasterListResultContoller;
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiscountMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicatesalesDiscount = [NSPredicate predicateWithFormat:@"salesDiscount = %@", @(TRUE)];
    fetchRequest.predicate = predicatesalesDiscount;

    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _discountMasterListResultContoller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_discountMasterListResultContoller performFetch:nil];
    _discountMasterListResultContoller.delegate = self;
    
    return _discountMasterListResultContoller;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sections = self.discountMasterListResultContoller.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];

    return sectionInfo.numberOfObjects;
}

-(void)animateViewFromCornerRadius:(CGFloat )fromCornerRadius ToCornerRadius:(CGFloat)toCornerRadius forView:(UIView *)view withViewbackColor:(UIColor *)color
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = @(fromCornerRadius);
    animation.toValue = @(toCornerRadius);
    animation.duration = 0.2;
    view.layer.cornerRadius = toCornerRadius;
    view.backgroundColor = color;
    [view.layer addAnimation:animation forKey:@"cornerRadius"];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DiscountMasterListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DiscountMasterListCell" forIndexPath:indexPath];

    
    if (indexPath.row == currentSelectedRowIndexpath.row) {
        if (cell.discountRoundCornerView.layer.cornerRadius == DiscountBackGroundViewRadiusNormal) {
            [self animateViewFromCornerRadius:cell.discountRoundCornerView.layer.cornerRadius ToCornerRadius:DiscountBackGroundViewRadiusAnimated forView:cell.discountRoundCornerView withViewbackColor:[UIColor colorWithRed:22.0/255.0 green:19.0/255.0 blue:36.0/255.0 alpha:1.0]];
            cell.discountTitle.textColor = [UIColor whiteColor];
            cell.discountAmount.textColor = [UIColor whiteColor];
        }
    }
    else
    {
        if (cell.discountRoundCornerView.layer.cornerRadius == DiscountBackGroundViewRadiusAnimated) {
            [self animateViewFromCornerRadius:cell.discountRoundCornerView.layer.cornerRadius ToCornerRadius:DiscountBackGroundViewRadiusNormal forView:cell.discountRoundCornerView withViewbackColor:[UIColor colorWithRed:242.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
            cell.discountTitle.textColor = [UIColor blackColor];
            cell.discountAmount.textColor = [UIColor blackColor];
        }
        else
        {
            cell.discountRoundCornerView.layer.cornerRadius = DiscountBackGroundViewRadiusNormal;
            cell.discountTitle.textColor = [UIColor blackColor];
            cell.discountAmount.textColor = [UIColor blackColor];
            cell.discountRoundCornerView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        }
    }
    DiscountMaster *discountMaster = [self.discountMasterListResultContoller objectAtIndexPath:indexPath];
    cell.discountTitle.text = [discountMaster valueForKey:@"title"];
    if ([[NSString stringWithFormat:@"%ld",(long)[[discountMaster valueForKey:@"type"] integerValue]] isEqualToString:@"1"])
    {
        cell.discountAmount.text = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:discountMaster.amount]];

    }
    else
    {
        cell.discountAmount.text = [NSString stringWithFormat:@"%.2f%@",discountMaster.amount.floatValue,@"%"];
 
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSArray *sections = self.discountMasterListResultContoller.sections;
    return sections.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DiscountMaster *discountMaster = [self.discountMasterListResultContoller objectAtIndexPath:indexPath];
    NSString *discountType = @"";
    NSString *discountValue = @"";
    if (([[NSString stringWithFormat:@"%ld",(long)[[discountMaster valueForKey:@"type"] integerValue]] isEqualToString:@"1"]))
    {
       discountType = @"Amount";
       discountValue = [NSString stringWithFormat:@"%@",[self.crmController.currencyFormatter stringFromNumber:discountMaster.amount]];
    }
    else
    {
       discountType = @"Per";
       discountValue = [NSString stringWithFormat:@"%.2f",discountMaster.amount.floatValue];
    }
    
    NSDictionary *selectedDiscountDictionary = @{@"DiscountType": discountType,@"DiscountValue": discountValue,@"DiscountId": discountMaster.discountId};
    [self.discountMasterListDelegate didSelectSalesDiscount:selectedDiscountDictionary];
    currentSelectedRowIndexpath = indexPath;
    [collectionView reloadData];
}


@end
