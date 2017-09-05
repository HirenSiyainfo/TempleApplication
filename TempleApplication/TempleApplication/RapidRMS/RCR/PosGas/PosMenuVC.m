//
//  PosMenuVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 12/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PosMenuVC.h"
#import "PosMenuCell.h"
#import "BillAmountCalculator.h"
#import "RmsDbController.h"
#import "PosMenuItem.h"

@interface PosMenuVC () <UICollectionViewDataSource, UICollectionViewDelegate>
{

}

@property (nonatomic, assign) NSInteger recallIndex;
@property (nonatomic, assign) NSInteger recallCount;

@property (nonatomic, weak) IBOutlet UIPageControl *posMenuVCPagecontrol;
@property (nonatomic, weak) IBOutlet UICollectionView *menuCollectionView;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation PosMenuVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize alphaOpasity;
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

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
- (void)setRecallCount:(NSInteger)recallCount AtIndex:(NSInteger)index
{
    if (index >= self.posMenuVCarray.count) {
//        NSLog(@"RESOLVE THIS. THIS CONDITION SHOULD NOT HAVE OCCURED.");
        return;
    }
    self.recallIndex = index;
    self.recallCount = recallCount;
    [self.menuCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}
-(void)clearSelection
{
    NSArray *indexPaths = [self.menuCollectionView indexPathsForSelectedItems];
    for (NSIndexPath *selectedIndexpath in indexPaths)
    {
        [self.menuCollectionView deselectItemAtIndexPath:selectedIndexpath animated:NO];
    }
    [self.menuCollectionView reloadData];
}

-(void)setOpasityForCollectionview :(float)opasity
{
    self.alphaOpasity = opasity;
    [self.menuCollectionView reloadData];
}


- (void)setMenuTitles:(NSArray*)menuTitles
{
    self.posMenuVCarray = [[NSMutableArray alloc]init];
    for (int i = 0; i < menuTitles.count; i++)
    {
        NSDictionary *posMenuItemDictionary = menuTitles[i];
        PosMenuItem *posMenuItem = [[PosMenuItem alloc]initWithTitle:[posMenuItemDictionary valueForKey:@"menuTitle"] menuId:[[posMenuItemDictionary valueForKey:@"menuId"] integerValue] normalImages:[posMenuItemDictionary valueForKey:@"normalImage"] selectedImages:[posMenuItemDictionary valueForKey:@"selectedImage"]];
        [self.posMenuVCarray addObject:posMenuItem];
    }
    float Pages = ceilf(menuTitles.count/8.0);
    self.posMenuVCPagecontrol.numberOfPages = Pages;
    if(self.menuCollectionView.frame.size.height < self.menuCollectionView.frame.size.width)
    {
        self.posMenuVCPagecontrol.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    [self.menuCollectionView reloadData];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.menuCollectionView.frame.size.height < self.menuCollectionView.frame.size.width)
    {
        CGFloat pageWidth = self.menuCollectionView.frame.size.width;
        if(self.menuCollectionView.contentOffset.x >0)
        {
            NSInteger pageNO = floor((self.menuCollectionView.contentOffset.x + pageWidth ) * 2) / pageWidth;
            self.posMenuVCPagecontrol.currentPage = pageNO;
        }
        else
        {
            self.posMenuVCPagecontrol.currentPage = 0;
        }
    }
    else
    {
        CGFloat pageWidth = self.menuCollectionView.frame.size.height;
        if(self.menuCollectionView.contentOffset.y >0)
        {
            NSInteger pageNO = floor((self.menuCollectionView.contentOffset.y + pageWidth ) * 2) / pageWidth;
            self.posMenuVCPagecontrol.currentPage = pageNO;
        }
        else
        {
            self.posMenuVCPagecontrol.currentPage = 0;
        }
    }
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posMenuVCarray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.rmsDbController.isInternetRechable)
    {
        if (indexPath.row == 3 ||  indexPath.row == 9)
        {
            [self.menuCollectionView deselectItemAtIndexPath:indexPath animated:NO];
            return;
        }
    }
    PosMenuItem *posMenuItemAtIndexPath = (self.posMenuVCarray)[indexPath.row];
    [self.menuDelegate didSelectMenu:self menuId:posMenuItemAtIndexPath.menuId];
}

- (CGPoint)centerForMenuAtPoint:(NSIndexPath *)selectedMenuIndexpath {
    CGPoint centerPoint = CGPointZero;
    NSIndexPath *indexPath = selectedMenuIndexpath;
    if (indexPath) {
        UICollectionViewCell *cell = [self.menuCollectionView cellForItemAtIndexPath:indexPath];
        centerPoint = cell.center;
        centerPoint = [self.menuCollectionView convertPoint:centerPoint toView:self.parentViewController.view];
    }
    
    return centerPoint;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PosMenuCell *cell = (PosMenuCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PosMenuCell" forIndexPath:indexPath];

    PosMenuItem *posMenuItemAtIndexPath = (self.posMenuVCarray)[indexPath.row];
    NSString *title = posMenuItemAtIndexPath.title;
    NSString *normalImage = posMenuItemAtIndexPath.normalImage;
    NSString *selectedImage = posMenuItemAtIndexPath.selectedImage;

    [cell setMenuItemTitle:title normalImage:normalImage selectedImage:selectedImage withOpasity:self.alphaOpasity];
    if (indexPath.row == self.recallIndex &&  self.recallCount > 0)
    {
        cell.recallCountLabel.hidden = NO;
        cell.recallNotificationImage.hidden = NO;
        cell.recallCountLabel.text = [NSString stringWithFormat:@"%ld",(long)self.recallCount];
    }
    else
    {
        cell.recallCountLabel.hidden = YES;
        cell.recallNotificationImage.hidden = YES;
    }
    
    if (posMenuItemAtIndexPath.menuId == REFUND_POS_MENU)
    {
        if (self.billAmountCalculator.itemRefund)
        {
            [cell setMenuItemTitle:title normalImage:selectedImage selectedImage:selectedImage withOpasity:self.alphaOpasity ];
        }
        else
        {
            [cell setMenuItemTitle:title normalImage:normalImage selectedImage:selectedImage withOpasity:self.alphaOpasity];
        }
    }
    if ( indexPath.row == 3 || indexPath.row == 9)
    {
        [cell setOpasityforCell:self.alphaOpasity];
    }

    return cell;
}
@end
