//
//  ICHomeVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 31/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ICHomeVC.h"
#import "ICHomeCustomCell.h"
#import "RmsDbController.h"
#import "RmsDashboardVC.h"

#import "ICNewVC.h"
#import "ICJoinCountVC.h"
#import "ICReconcileStatusVC.h"
#import "ICRecallSessionListVC.h"
#import "ICHistorySessionListVC.h"
#import "ICHomeCollectionCell.h"
#import "IntercomHandler.h"
@interface ICHomeVC () <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *listOfViewController;
    IBOutlet UICollectionView *homeCollectionVC;
    NSMutableArray *listOfViewControllerNormalImages;
    NSMutableArray *listOfViewControllerSelectedImages;
    IntercomHandler *intercomHandler;

}

@property (nonatomic, weak) IBOutlet UITableView *viewControllerList;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@end

@implementation ICHomeVC

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
    listOfViewController = [[NSMutableArray alloc] initWithObjects:@"NEW",@"RECALL",@"JOIN COUNT",@"RECONCILE",@"HISTORY",@"LOGOUT", nil];
    // Do any additional setup after loading the view from its nib.
    listOfViewControllerNormalImages = [[NSMutableArray alloc] initWithObjects:@"IC_menu_new",@"IC_menu_recall",@"IC_menu_joincount",@"IC_menu_reconcile",@"IC_menu_history",@"IC_menu_logout", nil];
    
    listOfViewControllerSelectedImages  = [[NSMutableArray alloc] initWithObjects:@"IC_menu_newselected",@"IC_menu_recallselected",@"IC_menu_joincountselected",@"IC_menu_reconcileselected",@"IC_menu_historyselected",@"IC_menu_logoutselected", nil];
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn.png" selectedImage:@"helpbtnselected.png" withViewController:self];

    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return listOfViewController.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ICHomeCollectionCell";
    ICHomeCollectionCell * viewCell = (ICHomeCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    viewCell.viewControllerName.text = listOfViewController[indexPath.row];
    [viewCell.selectedVCBg setImage:[UIImage imageNamed:listOfViewControllerNormalImages[indexPath.row]]];
    [viewCell.selectedVCBg setHighlightedImage:[UIImage imageNamed:listOfViewControllerSelectedImages[indexPath.row]]];
    return viewCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushToViewContollerAtIndexpath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (IsPad())
    {
        return UIEdgeInsetsMake(0, 175, 0, 175);
    }
    else
    {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IsPad())
    {
        return CGSizeMake(123, 150);
    }
    else
    {
        return CGSizeMake(99, 125);
    }
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (IsPad())
    {
        return 30.0f;
    }
    else
    {
        return 1.0f;
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    if (IsPad())
    {
        return 30.0f;
    }
    else
    {
        return 15.0f;
    }
}
-(IBAction)backToRootView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegate Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listOfViewController.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ICHomeCustomCell";
    ICHomeCustomCell *viewCell = (ICHomeCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIView *viewBG = [[UIView alloc] initWithFrame:viewCell.bounds];
    viewBG.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    viewCell.selectedBackgroundView = viewBG;
    
    viewCell.viewControllerName.text = listOfViewController[indexPath.row];
    if (indexPath.row == 0) {
        viewCell.selectedVCBg.image = [UIImage imageNamed:@"menu_newicon.png"];
        
    }
    else if (indexPath.row == 1)
    {
        viewCell.selectedVCBg.image = [UIImage imageNamed:@"menu_recallicon.png"];

    }
    else if (indexPath.row == 2)
    {
        viewCell.selectedVCBg.image = [UIImage imageNamed:@"menu_joincounticon.png"];

    }
    else if(indexPath.row == 3)
    {
        viewCell.selectedVCBg.image = [UIImage imageNamed:@"menu_reconcileicon.png"];

    }
    else if(indexPath.row == 4)
    {
        viewCell.selectedVCBg.image = [UIImage imageNamed:@"menu_historyicon.png"];
        
    }
//    else if(indexPath.row == 5)
//    {
//        viewCell.selectedVCBg.image = [UIImage imageNamed:@"menu_dashboardicon.png"];
//        
//    }
    else if(indexPath.row == 5)
    {
        viewCell.selectedVCBg.image = [UIImage imageNamed:@"menu_logouticon.png"];
        
    }

    return viewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushToViewContollerAtIndexpath:indexPath];
}

-(void)pushToViewContollerAtIndexpath :(NSIndexPath *)indexpath
{
    switch (indexpath.row) {
        case 0:
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
            ICNewVC *objNew = [storyBoard instantiateViewControllerWithIdentifier:@"ICNewVC_sid"];
            [self.navigationController pushViewController:objNew animated:YES];
        }
            break;
            
        case 1: // RECALL
            
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
            ICRecallSessionListVC *objRecallSession = [storyBoard instantiateViewControllerWithIdentifier:@"ICRecallSessionListVC_sid"];
            [self.navigationController pushViewController:objRecallSession animated:YES];
        }
            break;
            
        case 2: // JOINT COUNT
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
            ICJoinCountVC *objICNew = [storyBoard instantiateViewControllerWithIdentifier:@"ICJoinCountVC_sid"];
            [self.navigationController pushViewController:objICNew animated:YES];
        }
            break;
            
        case 3:
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
            ICReconcileStatusVC *objRecList = [storyBoard instantiateViewControllerWithIdentifier:@"ICReconcileStatusVC_sid"];
            [self.navigationController pushViewController:objRecList animated:YES];
        }
            break;
            
        case 4:
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:ICStoryBoard() bundle:nil];
            ICHistorySessionListVC *objHistory = [storyBoard instantiateViewControllerWithIdentifier:@"ICHistorySessionListVC_sid"];
            [self.navigationController pushViewController:objHistory animated:YES];
        }
            break;
            
//        case 5:
//        {
//            NSArray *viewControllerArray = self.navigationController.viewControllers;
//            for (UIViewController *vc in viewControllerArray)
//            {
//                if ([vc isKindOfClass:[RmsDashboardVC class]] || [vc isKindOfClass:[DashBoardSettingVC class]])
//                {
//                    [self.navigationController popToViewController:vc animated:TRUE];
//                }
//            }
//        }
//            break;
            
        case 5:
        {
            NSArray *viewControllerArray = self.navigationController.viewControllers;
            for (UIViewController *vc in viewControllerArray)
            {
                if ([vc isKindOfClass:[RmsDashboardVC class]] || [vc isKindOfClass:[DashBoardSettingVC class]])
                {
                    DashBoardSettingVC *dashboard = (DashBoardSettingVC *)vc;
                    [self.navigationController popToViewController:dashboard animated:YES];
                }
            }
        }
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
