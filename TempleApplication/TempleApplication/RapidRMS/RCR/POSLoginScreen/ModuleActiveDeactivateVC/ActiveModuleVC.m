//
//  ActiveModuleVC.m
//  RapidRMS
//
//  Created by Siya on 18/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ActiveModuleVC.h"

#import "RmsDbController.h"
#import "DisplayModuleCell.h"
#import "UserActivationViewController.h"
#import "ReleaseRegisterCollectionCell.h"
#import "ReleaseReplaceRegisterCollectionCell.h"
#import "ReleaseWithoutReplaceRegisterCollectionCell.h"

typedef NS_ENUM(NSInteger, Section) {
    ActiveModuleSection,
    ReplaceReleaseSection,
};

typedef NS_ENUM(NSInteger, RegisterAction) {
    ReleaseRegister,
    ReplaceRegister,
};

@interface ActiveModuleVC ()
{
    NSIndexPath *clickedIndexpath;
}

@property (nonatomic, weak) IBOutlet UICollectionView *activeModule;

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) RapidWebServiceConnection *releaseRegisterConnection;
@property (nonatomic, strong) RapidWebServiceConnection *replaceRegisterConnection;

@property (nonatomic, strong) NSMutableArray *activeDevResult;
@property (nonatomic, strong) NSMutableArray *globalactiveDevResult;

@property (nonatomic, strong) NSString *strRegName;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RcrController *crmController;



@end

@implementation ActiveModuleVC

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

    self.activeModule.scrollEnabled=YES;
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    
    self.releaseRegisterConnection = [[RapidWebServiceConnection alloc] init];
    self.replaceRegisterConnection = [[RapidWebServiceConnection alloc] init];
    [self makeUserWiseActiveModule];
    
    // Do any additional setup after loading the view.
}

-(void)makeUserWiseActiveModule {
    self.activeDevResult = [[NSMutableArray alloc]init];
    NSMutableArray *uniqueRegisterArray = [self.activeDevices valueForKeyPath:@"@distinctUnionOfObjects.RegisterNo"];
    
    for(int i = 0 ; i < uniqueRegisterArray.count; i++){
        NSMutableDictionary *dictModule = [[NSMutableDictionary alloc]init];
        NSPredicate *registerNumberPredicate = [NSPredicate predicateWithFormat:@"RegisterNo == %@", uniqueRegisterArray[i]];
        NSMutableArray *arrayTemp = [[self.activeDevices filteredArrayUsingPredicate:registerNumberPredicate] mutableCopy];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"MacAdd =%@",[self.rmsDbController.globalDict valueForKey:@"DeviceId"]];
        NSArray *arrayReg = [arrayTemp filteredArrayUsingPredicate:predicate];
        
        dictModule[@"RegisterName"] = arrayTemp[0][@"RegisterName"];
        dictModule[@"RegisterNo"] = uniqueRegisterArray[i];
        dictModule[@"ActiveModule"] = arrayTemp;
        
        if(arrayReg.count>0){
            [self.activeDevResult insertObject:dictModule atIndex:0];
        }
        else{
            [self.activeDevResult addObject:dictModule];
        }
    }
    self.globalactiveDevResult = self.activeDevResult;
    self.activeModule.contentSize = CGSizeMake(self.view.frame.size.width, (uniqueRegisterArray.count *50) + (self.activeDevices.count*388));
}

-(void)loadAllUserModule{
    
    self.activeDevResult = self.globalactiveDevResult;
    [self.activeModule reloadData];
}

-(void)filterWithRegisterWise:(NSNumber *)registerNumber {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterNo == %@",registerNumber];
    self.activeDevResult = [[self.globalactiveDevResult filteredArrayUsingPredicate:predicate] mutableCopy];
    self.strRegName = self.activeDevResult[0][@"RegisterName"];
    [self.activeModule reloadData];
}

-(void)deactiveModule:(id)sender {
    DisplayModuleCell *clickCell = (DisplayModuleCell *)[sender superview].superview.superview;
    NSIndexPath *indexPath = [self.activeModule indexPathForCell:clickCell];
    
    
    NSMutableArray *dictModule = [(self.activeDevResult)[indexPath.section]mutableCopy];
    
    NSMutableArray *arrayModuleList = [[dictModule valueForKey:@"ActiveModule"]mutableCopy];
    
    NSMutableDictionary *dictTemp = [arrayModuleList[indexPath.row]mutableCopy];
    
    if([[dictTemp valueForKey:@"IsActive"] integerValue ] == 0 ){
        dictTemp[@"IsActive"] = @"1";
        arrayModuleList[indexPath.row] = dictTemp;
        [dictModule setValue:arrayModuleList forKeyPath:@"ActiveModule"];
        (self.activeDevResult)[indexPath.section] = dictModule;
        [self moduleDeactivateInGlobalArray:self.strRegName withNewDict:self.activeDevResult];
        if (self.activeDevices != nil && self.activeDevices.count > 0) {
            NSPredicate *modulePredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d AND MacAdd == %@ AND IsRelease == 0 AND (IsActive == 0 OR IsActive == %@)",[[dictTemp valueForKey:@"ModuleId"] integerValue],[dictTemp valueForKey:@"MacAdd"],@"0"];
            NSDictionary *dict = [self.activeDevices filteredArrayUsingPredicate:modulePredicate].firstObject;
            NSUInteger index = [self.activeDevices indexOfObject:dict];
            NSMutableDictionary *deactiveDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            deactiveDict[@"IsActive"] = @"1";
            (self.activeDevices)[index] = deactiveDict;
        }
        [self.activeModule reloadItemsAtIndexPaths:@[indexPath]];
    }
    else
    {
        NSPredicate *allDeactivePedicate = [NSPredicate predicateWithFormat:@"IsRelease == 0 AND (IsActive == 1 OR IsActive == %@)",@"1"];
        NSArray *diactiveArray = [[self.activeDevResult.firstObject valueForKey:@"ActiveModule"] filteredArrayUsingPredicate:allDeactivePedicate];
        if(diactiveArray.count == 1)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
                [clickCell.moduleSwitch setOn:YES];
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Active Apps" message:@"You can't deactive all module" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
        
        clickedIndexpath = [indexPath copy];
        ActiveModuleVC * __weak myWeakReference = self;
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
            [clickCell.moduleSwitch setOn:YES];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
            
            NSMutableArray *dictModule = [(myWeakReference.activeDevResult)[clickedIndexpath.section]mutableCopy];
            
            NSMutableArray *arrayModuleList = [[dictModule valueForKey:@"ActiveModule"]mutableCopy];
            
            NSMutableDictionary *dictSelected= [arrayModuleList[clickedIndexpath.row]mutableCopy];
            
            dictSelected[@"IsActive"] = @"0";
            
            arrayModuleList[clickedIndexpath.row] = dictSelected;
            [dictModule setValue:arrayModuleList forKeyPath:@"ActiveModule"];
            
            (myWeakReference.activeDevResult)[clickedIndexpath.section] = dictModule;
            
            [self moduleDeactivateInGlobalArray:self.strRegName withNewDict:self.activeDevResult];
            if (self.activeDevices != nil && self.activeDevices.count > 0) {
                NSPredicate *modulePredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d AND MacAdd == %@ AND IsRelease == 0 AND (IsActive == 1 OR IsActive == %@)",[[dictTemp valueForKey:@"ModuleId"] integerValue],[dictTemp valueForKey:@"MacAdd"],@"1"];
                NSDictionary *dict = [self.activeDevices filteredArrayUsingPredicate:modulePredicate].firstObject;
                NSUInteger index = [self.activeDevices indexOfObject:dict];
                NSMutableDictionary *deactiveDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                deactiveDict[@"IsActive"] = @"0";
                (self.activeDevices)[index] = deactiveDict;
            }
            
            [self.activeModule reloadData];
            
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Active Apps" message:@"Are you sure you want to deactive this package?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
}

-(void)moduleDeactivateInGlobalArray:(NSString *)strRegName withNewDict:(NSMutableArray *)newModuleDict{
    
    for(int i = 0 ;i<self.globalactiveDevResult.count;i++){
        NSMutableDictionary *dict = (self.globalactiveDevResult)[i];
        if([strRegName isEqualToString:[dict valueForKey:@"RegisterName"]]){
            
            (self.globalactiveDevResult)[i] = newModuleDict.firstObject;
        }
    }
}

-(BOOL)isAlreadyActiveUser
{
    BOOL isAlreadyActive = FALSE;
    if (self.activeModules != nil && self.activeModules.count > 0) {
        NSPredicate *currentRegPredicte = [NSPredicate predicateWithFormat:@"RegisterNo == %@",[self.activeModules.firstObject valueForKey:@"RegisterNo"]];
        NSArray *selectedDeviceArray = [[[self.activeDevResult valueForKey:@"ActiveModule"] firstObject] copy];
        NSArray *currentReg = [selectedDeviceArray filteredArrayUsingPredicate:currentRegPredicte];
        if (currentReg != nil && currentReg.count > 0)
        {
            isAlreadyActive = TRUE;
        }
    }
    return isAlreadyActive;
}

#pragma mark CollectionView Delegate Method

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (IsPhone()) {
        if(section == ReplaceReleaseSection) {
            return CGSizeZero;
        }
    }
    return CGSizeMake(collectionView.frame.size.width, 44);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        CGFloat xPosition;
        if (IsPad()) {
            xPosition = 60;
        }
        else {
            xPosition = 15;
        }
        if (reusableview==nil) {
            reusableview=[[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        }
        reusableview.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:34.0/255.0 blue:61.0/255.0 alpha:1.0];
        [[reusableview viewWithTag:400]removeFromSuperview];
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(xPosition, 0, 320, 44)];
        
        if(indexPath.section == ReplaceReleaseSection){
            if (IsPad()) {
                label.text = @"Action on Active Register";
            }
            else {
                reusableview.frame = CGRectMake(reusableview.frame.origin.x, reusableview.frame.origin.y, reusableview.frame.size.width, 0);
                return reusableview;
            }
        }
        else {
            if (self.activeDevResult !=nil && self.activeDevResult.count > 0) {
                label.text=[(self.activeDevResult)[indexPath.section]valueForKey:@"RegisterName"];
            }
        }
        label.textColor = [UIColor whiteColor];
        label.tag = 400;
        [reusableview addSubview:label];
        return reusableview;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == ReplaceReleaseSection){
        if (IsPad()) {
            return CGSizeMake(collectionView.frame.size.width, 80.0);
        }
        else {
            return CGSizeMake(collectionView.frame.size.width, 73.0);
        }
    }
    else
    {
        if (IsPad()) {
            return CGSizeMake(collectionView.frame.size.width, 62.0);
        }
        else {
            return CGSizeMake(collectionView.frame.size.width, 55.0);
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.activeDevResult.count + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section == ReplaceReleaseSection){
            return 1;
    }
    else{
        if (self.activeDevResult !=nil && self.activeDevResult.count > 0) {
            NSMutableDictionary *dictTemp = (self.activeDevResult)[section];
            NSArray *arrayModule = [dictTemp valueForKey:@"ActiveModule"];
            if(arrayModule.count>0){
                return arrayModule.count;
            }
        }
        else
        {
            return 1;
        }
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier =  @"";
    if (IsPad()) {
        cellIdentifier = @"DisplayModuleCell";
    }
    else {
        cellIdentifier = @"DisplayModuleCell_iPhone";
    }

    DisplayModuleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIView *buttonSubView = [cell.contentView viewWithTag:202020];
    if (buttonSubView) {
        [buttonSubView removeFromSuperview];
        [[cell.contentView viewWithTag:212121] removeFromSuperview];
    }
    
    cell.backgroundColor=[UIColor clearColor];
    cell.lblRegName.hidden=NO;
    cell.lblCount.hidden=YES;
    cell.viewBorder.hidden=NO;
    [cell.moduleSwitch setHidden:NO];
    cell.lblRegName.textColor = [UIColor blackColor];
    
    if (self.activeDevResult == nil || self.activeDevResult.count == 0) {
        [cell.moduleSwitch setHidden:YES];
        [[cell.contentView viewWithTag:2020] removeFromSuperview];
        CGFloat xPosOfImageView;
        CGFloat yPosOfImageView;
        CGFloat xPosOfRegName;
        CGFloat imageSize;
        NSString *imageName = @"";
        if (IsPad()) {
            imageName = @"ExclamationIcon.png";
            xPosOfRegName = cell.lblRegName.frame.origin.x;
            xPosOfImageView = cell.lblRegName.frame.origin.x - 23.0;
            yPosOfImageView = 22.0;
            imageSize = 20.0;
        }
        else {
            imageName = @"infoicon_iphone.png";
            xPosOfRegName = cell.lblRegName.frame.origin.x + 20.0;
            xPosOfImageView = 15.0;
            yPosOfImageView = 23.0;
            imageSize = 15.0;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPosOfImageView , yPosOfImageView, imageSize, imageSize)];
        imageView.tag = 2020;
        imageView.image = [UIImage imageNamed:imageName];
        [cell.contentView addSubview:imageView];
        CGRect frame = cell.lblRegName.frame;
        frame.origin.x = xPosOfRegName;
        cell.lblRegName.frame = frame;
        cell.lblRegName.text = @"There is no active register";
        cell.lblRegName.textColor = [UIColor colorWithRed:132.0/255.0 green:154.0/255.0 blue:196.0/255.0 alpha:1.0];
        return cell;
    }
    
    if(indexPath.section == ReplaceReleaseSection) {
        if (IsPad()) {
            cell.viewBorder.hidden=YES;
            cell.lblRegName.hidden=YES;
            [cell.moduleSwitch setHidden:YES];
            cell.viewBg.backgroundColor = [UIColor clearColor];
            UIButton *btnReleaseRegister = [self buttonForCellWithNoramalImage:@"releasethisregister.png" selectedImage:@"releasethisregisterselected.png" withFrame:CGRectMake(60, 0, 259, 44)];
            btnReleaseRegister.tag = 202020;
            [btnReleaseRegister addTarget:self action:@selector(alertForReleaseRegister) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btnReleaseRegister];
            BOOL isAlreadyActive = [self isAlreadyActiveUser];
            if (!isAlreadyActive)
            {
                BOOL isRcdActive = [self isRcdActiveForActiveRegister];
                if (!self.isRcrActive && !isRcdActive) {
                    [[cell.contentView viewWithTag:212121] removeFromSuperview];
                    UIButton *btnReplaceRegister = [self buttonForCellWithNoramalImage:@"replacewiththisregister.png" selectedImage:@"replacewiththisregisterselected.png" withFrame:CGRectMake(339, 0, 259, 44)];
                    btnReplaceRegister.tag = 212121;
                    [btnReplaceRegister addTarget:self action:@selector(alertForReplaceRegister) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:btnReplaceRegister];
                }
            }
        }
        else {
            UICollectionViewCell *collectionViewCell = [self collectionViewCellForIndexPath:indexPath collectionView:collectionView];
            return collectionViewCell;
        }
    }
    else {
        [cell.moduleSwitch setOn:YES];
        cell.viewBg.backgroundColor = [UIColor whiteColor];
        
        NSMutableDictionary *dictUserModule = (self.activeDevResult)[indexPath.section];
        NSArray *arrayModule = [dictUserModule valueForKey:@"ActiveModule"];
        NSMutableDictionary *dictTemp = arrayModule[indexPath.row];
        
        if ([[dictTemp valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]]){
            cell.lblRegName.textColor = [UIColor colorWithRed:0.0/255 green:125.0/255 blue:255/255 alpha:1.0];
            
            if([[dictTemp valueForKey:@"IsActive"]integerValue]==0){
                cell.lblRegName.textColor = [UIColor redColor];
                [cell.moduleSwitch setOn:NO];
            }
        }
        else{
            
            if([[dictTemp valueForKey:@"IsActive"]integerValue]==0){
                cell.lblRegName.textColor = [UIColor redColor];
                [cell.moduleSwitch setOn:NO];
            }
        }
        [cell.moduleSwitch addTarget:self action:@selector(deactiveModule:) forControlEvents:UIControlEventValueChanged];
        cell.lblRegName.text=[dictTemp valueForKey:@"Name"];
        cell.lblCount.text=[NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"Count"]];
        
    }
    return cell;
}

- (UICollectionViewCell *)collectionViewCellForIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView {
    UICollectionViewCell *cell;
    BOOL isAlreadyActive = [self isAlreadyActiveUser];
    if (!isAlreadyActive)
    {
        BOOL isRcdActive = [self isRcdActiveForActiveRegister];
        if (!self.isRcrActive && !isRcdActive) {
            BOOL isRCRActiveInSelectedReg =  [self isRCRActiveInSelectedRegister];
            if (!isRCRActiveInSelectedReg) {
                //Release & Replace Register
                cell = [self releaseReplaceRegisterCollectionCellForIndexPath:indexPath collectionView:collectionView];
            }
            else {
                //Release Without Replace Register
                cell = [self releaseWithoutReplaceRegisterCollectionCellForIndexPath:indexPath collectionView:collectionView];
            }
        }
        else {
            //Release Register
          cell = [self releaseRegisterCollectionCellForIndexPath:indexPath collectionView:collectionView];
        }
    }
    else {
        //Release Register
        cell = [self releaseRegisterCollectionCellForIndexPath:indexPath collectionView:collectionView];
    }
    return cell;
}

- (UICollectionViewCell *)releaseRegisterCollectionCellForIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView {
    ReleaseRegisterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReleaseRegisterCollectionCell_iPhone" forIndexPath:indexPath];
    [cell.btnReleaseRegister addTarget:self action:@selector(alertForReleaseRegister) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (UICollectionViewCell *)releaseReplaceRegisterCollectionCellForIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView {
    ReleaseReplaceRegisterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReleaseReplaceRegisterCollectionCell_iPhone" forIndexPath:indexPath];
    [cell.btnReleaseRegister addTarget:self action:@selector(alertForReleaseRegister) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnReplaceRegister addTarget:self action:@selector(alertForReplaceRegister) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (UICollectionViewCell *)releaseWithoutReplaceRegisterCollectionCellForIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView {
    ReleaseWithoutReplaceRegisterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReleaseWithoutReplaceRegisterCollectionCell_iPhone" forIndexPath:indexPath];
    [cell.btnReleaseRegister addTarget:self action:@selector(alertForReleaseRegister) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (BOOL)isRcdActiveForActiveRegister
{
    BOOL isRcdActive = FALSE;
    NSPredicate *rcdPredicate = [NSPredicate predicateWithFormat:@"ModuleCode = %@",@"RCD"];
    NSArray *rcdArray = (NSArray *)[[[self.activeDevResult valueForKey:@"ActiveModule"] firstObject] filteredArrayUsingPredicate:rcdPredicate];
    if (rcdArray != nil && rcdArray.count > 0) {
        isRcdActive = TRUE;
    }
    return isRcdActive;
}

-(BOOL)isRCRActiveInSelectedRegister
{
    BOOL isRCRActive = FALSE;
    NSPredicate *rcrPredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d OR ModuleId == %d OR ModuleId == %d OR ModuleId == %d",1,5,6,7];
    NSArray *rcrActiveArray = [[[self.activeDevResult valueForKey:@"ActiveModule"] firstObject] filteredArrayUsingPredicate:rcrPredicate];
    if (rcrActiveArray.count > 0)
    {
        isRCRActive = TRUE;
    }
    else
    {
        isRCRActive = FALSE;
    }
    return isRCRActive;
}

- (UIButton *)buttonForCellWithNoramalImage:(NSString *)noramalImage selectedImage:(NSString *)selectedImage withFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:[UIImage imageNamed:noramalImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    return button;
}

-(void)goTODeviceActivation{
    NSString *nibName = @"";
    if (IsPad()) {
        nibName = @"UserActivationViewController";
    }
    else {
        nibName = @"UserActivationVC_iPhone";
    }
    UserActivationViewController *objUser = [[UserActivationViewController alloc] initWithNibName:nibName  bundle:nil];
    objUser.bFromDashborad = NO;
    self.appDelegate.navigationController.viewControllers=@[objUser];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.section == ReplaceReleaseSection){
//        if (indexPath.row == ReleaseRegister) {
//            [self alertForReleaseRegister];
//        }
//        else
//        {
//            [self alertForReplaceRegister];
//        }
//    }
}

-(void)alertForReleaseRegister {
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
        [self releaseRegister];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Are you sure you want to release this register"] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)alertForReplaceRegister {

    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
        [self replaceRegister];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Are you sure you want to replace this register"] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (BOOL)isCurrentRegisterReleased
{
    BOOL isCurrentRegisterReleased = false;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"MacAdd =%@",[self.rmsDbController.globalDict valueForKey:@"DeviceId"]];
    NSArray *arrayReg = [[self.activeDevResult.firstObject valueForKey:@"ActiveModule"] filteredArrayUsingPredicate:predicate];
    if (arrayReg != nil && arrayReg.count > 0) {
        isCurrentRegisterReleased = true;
    }
    return isCurrentRegisterReleased;
}

-(void)releaseRegister {
    if (IsPad()) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    }
    else {
        [self.activeModuleVCDelegate startActivityIndicator];
    }
    
    NSMutableDictionary *dictReleaseRegister = [[NSMutableDictionary alloc] init];
    
    NSDictionary *dictActiveModule = [[self.activeDevResult.firstObject valueForKey:@"ActiveModule"] firstObject];
    dictReleaseRegister[@"RegisterNo"] = [dictActiveModule valueForKey:@"RegisterNo"];
    dictReleaseRegister[@"BranchId"] = self.strBranchId;
    dictReleaseRegister[@"MacAddress"] = [dictActiveModule valueForKey:@"MacAdd"];
    dictReleaseRegister[@"LocalDate"] = [self localeDate];
    
    NSString *buildVersion = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
    if ([buildVersion isKindOfClass:[NSString class]])
    {
        dictReleaseRegister[@"BuildVersion"] = buildVersion;
    }
    else
    {
        dictReleaseRegister[@"BuildVersion"] = @"";
    }
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self releaseRegisterResultResponse:response error:error];
    };
    
    self.releaseRegisterConnection = [self.releaseRegisterConnection initWithRequest:KURL actionName:WSM_RELEASE_REGISTER params:dictReleaseRegister completionHandler:completionHandler];
}

- (void)releaseRegisterResultResponse:(id)response error:(NSError *)error {
    if (IsPad()) {
        [_activityIndicator hideActivityIndicator];
    }
    else {
        [self.activeModuleVCDelegate stopActivityIndicator];
    }
    [self.rmsDbController.globalDict removeObjectForKey:@"STORENAME"];
    [self.rmsDbController.globalDict removeObjectForKey:@"LoginUserName"];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            int errorCode = [[response valueForKey:@"IsError"] intValue];
            if(errorCode == 0)
            {
                (self.rmsDbController.globalDict)[@"RegisterName"] = @"";
                (self.rmsDbController.globalDict)[@"DBName"] = @"";
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    BOOL needRemoveSetting = [self isCurrentRegisterReleased];
                    if (needRemoveSetting) {
                        [self.rmsDbController removeAppSettings];
                        if (self.crmController.globalArrTenderConfig && self.crmController.globalArrTenderConfig.count > 0) {
                            [self.crmController.globalArrTenderConfig removeAllObjects];
                        }
                    }
                    [self.updateManager deleteModuleInfoFromDatabaseWithContext:[UpdateManager privateConextFromParentContext:self.managedObjectContext]];
                    [self goTODeviceActivation];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Release Register" message:@"Successfully Release" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
            else
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Release Register" message:response[@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
    }
}

-(void)replaceRegister {
    if (IsPad()) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    }
    else {
        [self.activeModuleVCDelegate startActivityIndicator];
    }
    NSMutableDictionary *dictReplaceRegister = [[NSMutableDictionary alloc] init];
    dictReplaceRegister[@"BranchId"] = self.strBranchId;
    dictReplaceRegister[@"currentMacAddress"] = (self.rmsDbController.globalDict)[@"DeviceId"];
    if (self.activeDevResult.count > 0 && self.activeDevResult != nil) {
        NSDictionary *dictReleaseModule = [[self.activeDevResult.firstObject valueForKey:@"ActiveModule"] firstObject];
        dictReplaceRegister[@"OtherMacAddress"] = [dictReleaseModule valueForKey:@"MacAdd"];
        dictReplaceRegister[@"OtherRegId"] = @"0";
        dictReplaceRegister[@"OtherRegisterNo"] = [dictReleaseModule valueForKey:@"RegisterNo"];
    }
    dictReplaceRegister[@"RegId"] = @(0);
    if (self.activeModules != nil && self.activeModules.count > 0) {
        if((self.rmsDbController.globalDict)[@"RegisterId"]){
            dictReplaceRegister[@"RegId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
        }
    }
    dictReplaceRegister[@"CompanyId"] = self.strCOMCOD;
    dictReplaceRegister[@"ConfigurationId"] = (self.rmsDbController.globalDict)[@"CONFIGID"];

    dictReplaceRegister[@"LocalDate"] = [self localeDate];
    NSString *buildVersion = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
    if ([buildVersion isKindOfClass:[NSString class]])
    {
        dictReplaceRegister[@"BuildVersion"] = buildVersion;
    }
    else
    {
        dictReplaceRegister[@"BuildVersion"] = @"";
    }
    dictReplaceRegister[@"Activity"] = @(1);
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self replaceRegisterResponse:response error:error];
        });
    };
    
    self.replaceRegisterConnection = [self.replaceRegisterConnection initWithRequest:KURL actionName:WSM_REPLACE_REGISTER params:dictReplaceRegister completionHandler:completionHandler];
}

- (void)replaceRegisterResponse:(id)response error:(NSError *)error
{
    if (IsPad()) {
        [_activityIndicator hideActivityIndicator];
    }
    else {
        [self.activeModuleVCDelegate stopActivityIndicator];
    }
    [self.activeModuleVCDelegate replaceRegisterResponse:response error:error];
}

- (NSString *)localeDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    return currentDateTime;
}
//-(void)setActiveBunch:(NSMutableArray *)releaseArray
//{
//    NSError *error;
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ActiveDeactiveTest.txt"];
//    NSLog(@"%@",filePath);
//    
//    NSMutableDictionary *registerDictionary = [[NSMutableDictionary alloc] init];
//    
////    NSString *names = [[NSString alloc] initWithContentsOfFile: filePath
////                                                      encoding: NSUTF8StringEncoding
////                                                         error: &error];
//    
//   // registerDictionary = [self.rmsDbController objectFromJsonString:names] ;
//    
//    
//    [registerDictionary setObject:releaseArray forKey:@"Release"];
//    
//    NSString *jsonStringToWrite = [self.rmsDbController jsonStringFromObject:registerDictionary];
//    
//    [jsonStringToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
//}


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

@end
