    //
//  StoreSelectionVC.m
//  RapidRMS
//
//  Created by Siya on 16/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "StoreSelectionVC.h"
#import "ModuleActivationVC.h"
#import "RmsDbController.h"
#import "UserActivationViewController.h"
#import "StoreSelectionCell.h"
#import "ModuleActiveDeactiveVC.h"

@interface StoreSelectionVC ()
{
    IntercomHandler *intercomHandler;
}
@property (nonatomic , weak) IBOutlet UICollectionView *storeList;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation StoreSelectionVC
@synthesize arrayStore,selectedDictTemp;

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
    
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
}

-(IBAction)cancelStoreSelection:(id)sender{
    
    [self.appDelegate.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.arrayStore.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    NSMutableDictionary *dictTemp = (self.arrayStore)[indexPath.row];
    cell.textLabel.text= [dictTemp valueForKey:@"STORENAME"];
	return cell;
}   

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictTemp = (self.arrayStore)[indexPath.row];
    
    ModuleActivationVC *objModuleActiveiPad = [[ModuleActivationVC alloc] initWithNibName:@"ModuleActivationVC" bundle:nil];
    
     (self.rmsDbController.globalDict)[@"DBName"] = [dictTemp valueForKey:@"DBNAME"];
    objModuleActiveiPad.arrDeviceAuthentication = [[NSMutableArray alloc]initWithObjects:dictTemp, nil];
    
     [self.navigationController pushViewController:objModuleActiveiPad animated:YES];

}

#pragma mark CollectionView Delegate Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayStore.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"";
    if (IsPad()) {
        cellIdentifier = @"StoreSelectionCell";
    }
    else {
        cellIdentifier = @"StoreSelectionCell_iPhone";
    }
    StoreSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.layer.cornerRadius=5.0;
    cell.layer.borderColor=[UIColor grayColor].CGColor;
    
    UIView *selectionColor = [[UIView alloc] init];
    if (IsPad()) {
        selectionColor.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    else {
        selectionColor.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    cell.selectedBackgroundView = selectionColor;
    
    if (IsPad()) {
        UIView *backColor = [[UIView alloc] init];
        backColor.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backColor;
    }
    
    NSMutableDictionary *dictTemp = (self.arrayStore)[indexPath.row];
   NSString *strStoreName = [dictTemp valueForKey:@"STORENAME"];
    cell.lblStoreName.text = [NSString stringWithFormat:@"%@", strStoreName.uppercaseString];

    
    NSMutableArray *arryBranchinfo = [dictTemp valueForKey:@"objBranchInfo"];
    
    if([arryBranchinfo isKindOfClass:[NSNull class]])
    {
        cell.lblAdd1.text=@"";
        cell.lblAdd2.text=@"";
    }
    else{
    
        if(arryBranchinfo.count>0)
        {
            [[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"Address1"];
            
            cell.lblAdd1.text= [[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"Address1"];
            
            if([[[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"Address2"] isEqualToString:@""])
                
            {
                
                NSString *strCityZipcode = [NSString stringWithFormat:@"%@,%@ - %@",[[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"City"],[[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"State"],[[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"ZipCode"]];
                
                cell.lblAdd2.text= strCityZipcode;
            }
            else{
                
                NSString *strCityZipcode = [NSString stringWithFormat:@" %@ ,%@,%@ - %@",[[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"Address2"] , [[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"City"],[[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"State"],[[[dictTemp valueForKey:@"objBranchInfo"]firstObject] valueForKey:@"ZipCode"]];
                
                cell.lblAdd2.text= strCityZipcode;
            }
        }
        else{
            
            cell.lblAdd1.text=@"";
            cell.lblAdd2.text=@"";
        }
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedDictTemp= [(self.arrayStore)[indexPath.row]mutableCopy];
    NSMutableArray *arryBranchinfo = [selectedDictTemp valueForKey:@"objBranchInfo"];
    if(![arryBranchinfo isKindOfClass:[NSNull class]])
    {
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please set up branch." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(IBAction)gotoModuleActivatDeactivate:(id)sender{
    
    if(selectedDictTemp==nil)
    {
        return;
    }
    
    NSMutableArray *arryBranchinfo = [selectedDictTemp valueForKey:@"objBranchInfo"];
    
    if(![arryBranchinfo isKindOfClass:[NSNull class]])
    {
        NSString *storyBoardName = @"";
        NSString *identifierForModuleActiveDeactive = @"";
        if (IsPad()) {
            storyBoardName = @"Main";
            identifierForModuleActiveDeactive = @"ModuleActiveDeactiveVC";
        }
        else {
            storyBoardName = @"ActiveDeactive_iPhone";
            identifierForModuleActiveDeactive = @"ModuleActiveDeactiveVC_iPhone";
        }
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
        NSMutableArray *arrayTemp = [[NSMutableArray alloc]initWithObjects:selectedDictTemp, nil];
        NSString *Dbnme = [selectedDictTemp valueForKey:@"DBNAME"];
        if(Dbnme==nil)
        {
            Dbnme = [selectedDictTemp valueForKey:@"DBName"];
        }
        (self.rmsDbController.globalDict)[@"DBName"] = Dbnme;
        NSString *configid = [selectedDictTemp valueForKey:@"ID"];
        if(configid==nil)
        {
            configid = [[[selectedDictTemp valueForKey:@"objDeviceInfo"]firstObject]valueForKey:@"ConfigurationId"];
        }
        (self.rmsDbController.globalDict)[@"CONFIGID"] = configid;
        (self.rmsDbController.globalDict)[@"STORENAME"] = [selectedDictTemp valueForKey:@"STORENAME"];
        (self.rmsDbController.globalDict)[@"LoginUserName"] = [selectedDictTemp valueForKey:@"USERNAME"];
        self.rmsDbController.appsActvDeactvSettingarray = [arrayTemp mutableCopy];
        [self goToModuleActivation:storyBoard identifier:identifierForModuleActiveDeactive storeArray:arrayTemp];
    }
}

- (void)goToModuleActivation:(UIStoryboard *)storyBoard identifier:(NSString *)identifier storeArray:(NSMutableArray *)storeArray {
    ModuleActiveDeactiveVC *objActiveDeactive = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    objActiveDeactive.arrDeviceAuthentication = [storeArray mutableCopy];
    objActiveDeactive.bFromDashborad = self.bFromDashborad;
    [self.appDelegate.navigationController pushViewController:objActiveDeactive animated:YES];
}

@end
