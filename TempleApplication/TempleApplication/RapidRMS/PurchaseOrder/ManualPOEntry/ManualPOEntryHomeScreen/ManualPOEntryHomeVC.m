//
//  ManualPOEntryHomeVC.m
//  RapidRMS
//
//  Created by Siya on 12/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ManualPOEntryHomeVC.h"
#import "StoreSelectionCell.h"
#import "NewManualEntryVC.h"
#import "ManualEntryRecevieItemList.h"
#import "RecallManualEntryVC.h"
#import "HistoryManualEntryVC.h"
#import "ManualEntryRecevieItemList.h"
#import "DashBoardSettingVC.h"
#import "RmsDbController.h"

@interface ManualPOEntryHomeVC ()
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UICollectionView *manualEntryHome;

@property (nonatomic, strong) NSMutableArray *arrayMenuList;
@property (nonatomic, strong) NSMutableArray *arrayImageList;
@property (nonatomic, strong) NSMutableArray *arraySelectedImageList;

@end

@implementation ManualPOEntryHomeVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arrayMenuList = [[NSMutableArray alloc]initWithObjects:@"NEW",@"RECALL",@"HISTORY",@"LOGOUT", nil];
    self.arrayImageList = [[NSMutableArray alloc]initWithObjects:@"me_new.png",@"me_recall.png",@"me_history.png",@"me_logout.png", nil];
    self.arraySelectedImageList = [[NSMutableArray alloc]initWithObjects:@"me_new_selected.png",@"me_recall_selected.png",@"me_history_selected.png",@"me_logout_selected.png", nil];


    [self.manualEntryHome reloadData];
    [self.manualEntryHome setScrollEnabled:NO];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    // Do any additional setup after loading the view.
}

#pragma mark CollectionView Delegate Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayMenuList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StoreSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StoreSelectionCell" forIndexPath:indexPath];

    cell.imgList.highlightedImage = [UIImage imageNamed:(self.arraySelectedImageList)[indexPath.row]];
    cell.imgList.image = [UIImage imageNamed:(self.arrayImageList)[indexPath.row]];
    cell.lblStoreName.text= (self.arrayMenuList)[indexPath.row];

    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        NewManualEntryVC *newManualEntry = [storyBoard instantiateViewControllerWithIdentifier:@"NewManualEntryVC"];
        
        [self.navigationController pushViewController:newManualEntry animated:YES];
    }
    if(indexPath.row==1){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        RecallManualEntryVC *recallManualEntryVC = [storyBoard instantiateViewControllerWithIdentifier:@"RecallManualEntryVC"];
        [self.navigationController pushViewController:recallManualEntryVC animated:YES];
    }
    
    if(indexPath.row==2){
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ManualEntry" bundle:nil];
        HistoryManualEntryVC *historyManualEntryVC = [storyBoard instantiateViewControllerWithIdentifier:@"HistoryManualEntryVC"];
        [self.navigationController pushViewController:historyManualEntryVC animated:YES];
    }
    
    if(indexPath.row==3){
        NSArray *arrayView = self.navigationController.viewControllers;
        for(UIViewController *viewcon in arrayView){
            if([viewcon isKindOfClass:[DashBoardSettingVC class]]){
                DashBoardSettingVC *dashboard = (DashBoardSettingVC *)viewcon;
                [self.navigationController popToViewController:dashboard animated:YES];
            }
        }
    }
    [self.manualEntryHome reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
