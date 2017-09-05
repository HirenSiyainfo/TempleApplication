//
//  HGenerateOrderVC.m
//  RapidRMS
//
//  Created by Siya on 24/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HGenerateOrderVC.h"
#import "HItemCatalogVC.h"
#import "HPurchaseOrderVC.h"
#import "HReceiveOrderListVC.h"
#import "HOutStandingInvoiceVC.h"
#import "HOrderHistoryVC.h"
#import "HNewRelaseandPromoVC.h"
#import "HReportsVC.h"
#import "HOpenOrderVC.h"
#import "RmsDashboardVC.h"
#import "HItemProductVC.h"
#import "RmsDbController.h"
#import "HBackorderListView.h"
#import "RimsController.h"
#import "HConfigurationVC.h"

@interface HGenerateOrderVC ()
{
    
}

@property (nonatomic, weak) IBOutlet UITableView *tblHGenerateOrder;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *arrryMenulist;
@property (nonatomic, strong) NSMutableArray *arrayCatlogSub;
@property (nonatomic, strong) NSMutableArray *arrayPoSub;
@property (nonatomic, strong) NSMutableArray *arrayReportSub;
@property (nonatomic, strong) NSMutableArray *arrayImgCatlogSub;
@property (nonatomic, strong) NSMutableArray *arrayImgPoSub;
@property (nonatomic, strong) NSMutableArray *arrayImgReportSub;

@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HGenerateOrderVC
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
    
    self.arrryMenulist=[[NSMutableArray alloc]initWithObjects:@"Catalog",@"PO",@"Reports",nil];
    
    self.arrayCatlogSub = [[NSMutableArray alloc]initWithObjects:@"New Releases and Promotions",@"Catalog",nil];
    
     self.arrayPoSub = [[NSMutableArray alloc]initWithObjects:@"Generate Purchase Order",@"Open/Saved Purchase Orders",@"Receive Order",nil];
    
    self.arrayReportSub = [[NSMutableArray alloc]initWithObjects:@"Order History",@"Reports",@"BackOrderList",@"Settings",nil];
    
    //  for Image
    
    self.arrayImgCatlogSub = [[NSMutableArray alloc]initWithObjects:@"Hnew_release_icon.png",@"Hcatalog_icon.png",nil];
    
    self.arrayImgPoSub = [[NSMutableArray alloc]initWithObjects:@"Hpurchase_order_icon.png",@"Hopen_saved_icon.png",@"Hreceive_order_icon.png",nil];
    
    self.arrayImgReportSub = [[NSMutableArray alloc]initWithObjects:@"Horder_history_icon.png",@"Hreport_icon.png",@"Hback_order_icon.png",@"h_Setting.png",nil];
    
    [self countnewReleases];
    
    // Do any additional setup after loading the view.
}
-(void)countnewReleases{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Vendor_Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isNew==%@ && effectiveDate >= %@", @(1),[NSDate date]];
    fetchRequest.predicate = predicate;
    
    self.itemCount = [UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrryMenulist.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        
        return self.arrayCatlogSub.count;
    }
    else if(section==1){
        
        return self.arrayPoSub.count;
    }
    else if(section==2){
        
        return self.arrayReportSub.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 88.0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *viewTemp = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 35.0)];
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20.0, 8.0, 320.0, 23.0)];
    lblTitle.text=(self.arrryMenulist)[section];
    
    lblTitle.textColor =[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0];
    
    viewTemp.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    UIView *viewBorder = [[UIView alloc]initWithFrame:CGRectMake(0.0, 34.0, 320.0, 1.0)];
    viewBorder.backgroundColor = [UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0];
    [viewTemp addSubview:viewBorder];
    [viewTemp addSubview:lblTitle];
    
    return viewTemp;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    [[cell viewWithTag:400]removeFromSuperview];
    [[cell viewWithTag:500]removeFromSuperview];
    
    
    UILabel *lblTitle = [[UILabel alloc]init];
    lblTitle.frame=CGRectMake(60.0, 29.0, 255.0, 30.0);
    lblTitle.tag = 400;
    

    if(indexPath.section==0)
    {
        if(indexPath.row==0){
            
            lblTitle.frame=CGRectMake(60.0, 18.0, 255.0, 30.0);
            UILabel *lblitemcount = [[UILabel alloc]init];
            lblitemcount.frame=CGRectMake(60.0, 44.0, 255.0, 30.0);
            lblitemcount.text=[NSString stringWithFormat:@"%ld Items", (long)self.itemCount];
            lblitemcount.textColor=[UIColor grayColor];
            lblitemcount.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
            [cell addSubview:lblitemcount];

        }
        lblTitle.text = (self.arrayCatlogSub)[indexPath.row];
    }
    else if(indexPath.section==1){
        lblTitle.text = (self.arrayPoSub)[indexPath.row];
    }
    else if(indexPath.section==2){
        lblTitle.text = (self.arrayReportSub)[indexPath.row];
    }

    lblTitle.font = [UIFont fontWithName:@"Helvetica-Neue" size:14.0];
    [cell addSubview:lblTitle];
    
    UIImageView *imgIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15.0, 18.0, 28.0, 50.0)];
    
    if(indexPath.section == 0)
    {
        imgIcon.image = [UIImage imageNamed:(self.arrayImgCatlogSub)[indexPath.row]];

    }
    else if(indexPath.section == 1){
        imgIcon.image = [UIImage imageNamed:(self.arrayImgPoSub)[indexPath.row]];
    }
    else if(indexPath.section == 2){
        imgIcon.image = [UIImage imageNamed:(self.arrayImgReportSub)[indexPath.row]];
    }
    
    imgIcon.contentMode = UIViewContentModeScaleAspectFit;
    imgIcon.tag = 500;
    [cell addSubview:imgIcon];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section==0){
        
        if (indexPath.row==0) {

//            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//            HNewRelaseandPromoVC *newRelease = [storyBoard instantiateViewControllerWithIdentifier:@"HNewRelaseandPromoVC"];
//            [self.navigationController pushViewController:newRelease animated:YES];
            
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HItemProductVC *hproduct = [storyBoard instantiateViewControllerWithIdentifier:@"HItemProductVC"];
            hproduct.isFromNewRelease=YES;
            [[NSUserDefaults standardUserDefaults]setObject:@"Y" forKey:@"New"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self.navigationController pushViewController:hproduct animated:YES];
            
        }
        else if (indexPath.row==1) {
         
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HItemProductVC *hproduct = [storyBoard instantiateViewControllerWithIdentifier:@"HItemProductVC"];
            hproduct.isFromNewRelease=NO;
            [[NSUserDefaults standardUserDefaults]setObject:@"N" forKey:@"New"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self.navigationController pushViewController:hproduct animated:YES];
        }

    }
    else if(indexPath.section==1){
        
        if (indexPath.row==0) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HPurchaseOrderVC *hpurchase = [storyBoard instantiateViewControllerWithIdentifier:@"HPurchaseOrderVC"];
            hpurchase.fromHome=YES;
            [self.navigationController pushViewController:hpurchase animated:YES];
        }
        else if (indexPath.row==1) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HOpenOrderVC *hOpenOrder = [storyBoard instantiateViewControllerWithIdentifier:@"HOpenOrderVC"];
             hOpenOrder.fromHome=YES;
            [self.navigationController pushViewController:hOpenOrder animated:YES];
        }
        else if (indexPath.row==2) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HReceiveOrderListVC *hreceiveorder = [storyBoard instantiateViewControllerWithIdentifier:@"HReceiveOrderListVC"];
            [self.navigationController pushViewController:hreceiveorder animated:YES];
        }
    
    }
    else if(indexPath.section==2){
        
        if (indexPath.row==0) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HOrderHistoryVC *history = [storyBoard instantiateViewControllerWithIdentifier:@"HOrderHistoryVC"];
            [self.navigationController pushViewController:history animated:YES];
        }
        else if (indexPath.row==1) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HReportsVC *hreports = [storyBoard instantiateViewControllerWithIdentifier:@"HReportsVC"];
            [self.navigationController pushViewController:hreports animated:YES];
        }
        else if (indexPath.row==2) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HBackorderListView *hbackorder = [storyBoard instantiateViewControllerWithIdentifier:@"HBackorderListView"];
            [self.navigationController pushViewController:hbackorder animated:YES];
        }
        else if (indexPath.row==3) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            HConfigurationVC *hconfiguration = [storyBoard instantiateViewControllerWithIdentifier:@"HConfigurationVC"];
            
            NSMutableDictionary *dictStoreInfo = [[NSUserDefaults standardUserDefaults]valueForKey:@"HStoreInfo"];
            hconfiguration.alreadyActive=YES;
            
            hconfiguration.dictBranchInfo = dictStoreInfo;
            [self.navigationController pushViewController:hconfiguration animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)bakctoHome:(id)sender{
    
    NSArray *arrayView = self.navigationController.viewControllers;
    for(UIViewController *viewcon in arrayView){
        if([viewcon isKindOfClass:[RmsDashboardVC class]]){
            [self.navigationController popToViewController:viewcon animated:YES];
            
        }
    }
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
