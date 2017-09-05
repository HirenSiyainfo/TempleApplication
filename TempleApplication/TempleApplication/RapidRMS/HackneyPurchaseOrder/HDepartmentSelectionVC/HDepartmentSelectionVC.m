//
//  HDepartmentSelectionVC.m
//  RapidRMS
//
//  Created by Siya on 04/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HDepartmentSelectionVC.h"
#import "HCatalogCustomCell.h"
#import "HItemCategoriesVC.h"

@interface HDepartmentSelectionVC ()

@property (nonatomic, strong) NSString *strCatlog;

@end

@implementation HDepartmentSelectionVC
@synthesize departmentSelectionDelegate,strCatlog,indcatalog,indCategory;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tblCatalog reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.row==self.indcatalog.row){
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    UIButton *btnSubCat = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubCat.frame = CGRectMake(250.0, 0.0, 70.0, 58.0);
    btnSubCat.backgroundColor = [UIColor clearColor];
    [btnSubCat addTarget:self action:@selector(openCategory:) forControlEvents:UIControlEventTouchUpInside];
    btnSubCat.tag = indexPath.row;
    [cell addSubview:btnSubCat];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HCatalogCustomCell *catalogCell = (HCatalogCustomCell *)[tableView cellForRowAtIndexPath:indexPath];
    //[departmentSelectionDelegate didselectinoDeparment:catalogCell.lblSubName.text];
    [departmentSelectionDelegate didselectinoDeparment:catalogCell.lblSubName.text withIndexpath:indexPath];
    [self performSegueWithIdentifier:@"exitfromDepartment" sender:nil];
}

-(void)openCategory:(id)sender{
    
    NSIndexPath *indpath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    HCatalogCustomCell *catalogCell = (HCatalogCustomCell *)[self.tblCatalog cellForRowAtIndexPath:indpath];
    self.strCatlog=catalogCell.lblSubName.text;
    self.indcatalog= indpath;
    [self performSegueWithIdentifier:@"gotoCategory" sender:nil];
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"gotoCategory"]){
        HItemCategoriesVC *objItemCat = segue.destinationViewController;
        objItemCat.strCatalog=self.strCatlog;
        objItemCat.isFromNewRelease = self.isFromNewRelease;
        objItemCat.indCategory=self.indCategory;
        objItemCat.indCatalog=self.indcatalog;
        self.indcatalog=[NSIndexPath indexPathForRow:-1 inSection:-1];
        objItemCat.isfromItem=self.isfromItem;
        objItemCat.strPoID=self.strPoID;
    }
}

@end
