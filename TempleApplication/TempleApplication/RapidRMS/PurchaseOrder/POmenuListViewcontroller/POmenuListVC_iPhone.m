//
//  POmenuListVC_iPhone.m
//  RapidRMS
//
//  Created by Siya on 04/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "POmenuListVC_iPhone.h"
#import "GenerateOrderView.h"
#import "OpenListVC.h"
#import "CloseListVC.h"
#import "DeliveryListVC.h"
#import  "POmenuListVC.h"
#import "RimsController.h"
#import "SideMenuPOViewController.h"
#import "OpenListFilterVC.h"

@interface POmenuListVC_iPhone ()

@property (nonatomic, weak) IBOutlet UITableView *tblMenuOperation;

@property (nonatomic, strong) RimsController *rimsController;

@property (nonatomic, strong) NSIndexPath *indPath;

@end

@implementation POmenuListVC_iPhone
@synthesize indPath;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.rimsController = [RimsController sharedrimController];
//    self._rimController.objPOMenuListIphone=self;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        indPath=[NSIndexPath indexPathForRow:-1 inSection:0];
    }
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imgTemp = (UIImageView *)[cell viewWithTag:500];
    [imgTemp removeFromSuperview];
    
    if(indexPath.row==0){
        
        UIImageView *imgGeneratorder = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        imgGeneratorder.tag=500;
        if(indPath.row==0)
        {
            imgGeneratorder.image = [UIImage imageNamed:@"generateOrderActive_po_iPhone_new.png"];
        }
        else{
            imgGeneratorder.image = [UIImage imageNamed:@"generateOrder_po_iPhone_new.png"];
        }
        [cell addSubview:imgGeneratorder];
        
    }
    else if(indexPath.row==1){
        
        UIImageView *imgOpenOrder = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        imgOpenOrder.tag=500;
        
        if(indPath.row==1)
        {
            imgOpenOrder.image = [UIImage imageNamed:@"PurchaseOrderListActive_iPhone.png"];
        }
        else{
            imgOpenOrder.image = [UIImage imageNamed:@"PurchaseOrderList_iPhone.png"];
        }
        [cell addSubview:imgOpenOrder];
        
        
    }
    else if(indexPath.row==2){
        
        UIImageView *imgOpenOrder = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        imgOpenOrder.tag=500;
        
        if(indPath.row==2)
        {
            imgOpenOrder.image = [UIImage imageNamed:@"openMenuActive_po_iPhone_new.png"];
        }
        else{
            imgOpenOrder.image = [UIImage imageNamed:@"openMenu_po_iPhone_new.png"];
        }
        [cell addSubview:imgOpenOrder];
        
        
    }
    else if(indexPath.row==3){
        
        UIImageView *imgDelivetyPanding = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        imgDelivetyPanding.tag=500;
        if(indPath.row==3)
        {
            imgDelivetyPanding.image = [UIImage imageNamed:@"DeliveryPendingActive_po_iPhone_new.png"];
        }
        else{
            imgDelivetyPanding.image = [UIImage imageNamed:@"DeliveryPending_po_iPhone_new.png"];
        }
        [cell addSubview:imgDelivetyPanding];
        
    }
    else if(indexPath.row==4){
        
        UIImageView *imgCloseorder = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        imgCloseorder.tag=500;
        if(indPath.row==4)
        {
            imgCloseorder.image = [UIImage imageNamed:@"closeMenuActive_po_iPhone_new.png"];
        }
        else{
            imgCloseorder.image = [UIImage imageNamed:@"closeMenu_po_iPhone_new.png"];
        }
        [cell addSubview:imgCloseorder];
        
        
    }
    
    return cell;
    
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    indPath=indexPath;
    
    if(indexPath.row==0)
    {
        [Appsee addEvent:kPOMenuGenerateOrder];
        GenerateOrderView *objGenerateOrder = [[GenerateOrderView alloc]initWithNibName:@"GenerateOrderView" bundle:nil];
        [self.navigationController pushViewController:objGenerateOrder animated:YES];
        
    }
    else if(indexPath.row==1)
    {
        [Appsee addEvent:kPOMenuPurchaseOrderList];
        OpenListFilterVC *objOrderFilter = [[OpenListFilterVC alloc]initWithNibName:@"OpenListFilterVC" bundle:nil];
        [self.navigationController pushViewController:objOrderFilter animated:YES];

    }

    else if(indexPath.row==2)
    {
        [Appsee addEvent:kPOMenuOpenOrder];
        OpenListVC *objOpenList = [[OpenListVC alloc]initWithNibName:@"OpenListVC" bundle:nil];
        [self.navigationController pushViewController:objOpenList animated:YES];
        
    }

    else if(indexPath.row==3)
    {
        [Appsee addEvent:kPOMenuDeliveryPending];
        DeliveryListVC *objDeliveryList = [[DeliveryListVC alloc]initWithNibName:@"DeliveryListVC" bundle:nil];
        [self.navigationController pushViewController:objDeliveryList animated:YES];

    }
    else if(indexPath.row==4)
    {
        [Appsee addEvent:kPOMenuCloseOrder];
        CloseListVC *objCloseList = [[CloseListVC alloc]initWithNibName:@"CloseListVC" bundle:nil];
        [self.navigationController pushViewController:objCloseList animated:YES];
    }
    [_tblMenuOperation reloadData];

}


-(IBAction)baktodashboard:(id)sender{
    [Appsee addEvent:kPOMenuDashboard];
    [self.navigationController popToViewController:(self.navigationController.viewControllers)[1] animated:YES];
}
-(IBAction)baktoLogin:(id)sender{
    [Appsee addEvent:kPOMenuLogout];
//    UIViewController *viewcon =(UIViewController *) self._rimController.objInvenMgmt;
//    UIView  *viewFooter = (UIView *)[viewcon.view viewWithTag:2222];
//    UIButton *btmAdd = (UIButton *)[viewFooter viewWithTag:1111];
//    [btmAdd setHidden:NO];
//    UILabel *lblAddNewItem = (UILabel *)[viewFooter viewWithTag:1212];
//    [lblAddNewItem setHidden:NO];
    [self.navigationController popToViewController:(self.navigationController.viewControllers)[2] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
