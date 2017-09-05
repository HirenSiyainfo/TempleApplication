//
//  ReleaseModuleVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 07/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ReleaseModuleVC.h"
#import "RmsDbController.h"
#import "DisplayModuleCell.h"
#import "ReplaceRegisterCollectionCell.h"
#import "WithoutReplaceRegisterCollectionCell.h"

typedef NS_ENUM(NSInteger, Section) {
    ReleaseModuleSection,
    ReplaceReleaseSection,
};

typedef NS_ENUM(NSInteger, RegisterAction) {
    ReleaseRegister,
    ReplaceRegister,
};


@interface ReleaseModuleVC ()

@property (nonatomic, weak) IBOutlet UICollectionView *releaseModule;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *replaceRegisterConnection;

@property (nonatomic, strong) NSMutableArray *releaseMenu;
@property (nonatomic, strong) NSMutableArray *globalactiveDevResultRelease;

@property (nonatomic, strong) NSString *strRegName;

@end

@implementation ReleaseModuleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.releaseModule.scrollEnabled=YES;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.replaceRegisterConnection = [[RapidWebServiceConnection alloc] init];
    [self makeReleaseActiveModule];
    // Do any additional setup after loading the view.
}


-(void)makeReleaseActiveModule {
    self.globalactiveDevResultRelease = self.activeDevResultRelease;
    self.releaseModule.contentSize = CGSizeMake(self.view.frame.size.width, self.activeDevResultRelease.count *50 + self.activeDevResultRelease.count*388);
    
    if (self.activeDevResultRelease !=nil && self.activeDevResultRelease.count > 0) {
        self.releaseMenu = [[NSMutableArray alloc] initWithObjects:@(ReleaseModuleSection),@(ReplaceReleaseSection), nil];
    }
    else{
        self.releaseMenu = [[NSMutableArray alloc] initWithObjects:@(ReplaceReleaseSection), nil];
    }
    
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
        if (reusableview == nil) {
            reusableview = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        }
        reusableview.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:34.0/255.0 blue:61.0/255.0 alpha:1.0];
        [[reusableview viewWithTag:400]removeFromSuperview];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, 0, 320, 44)];
        
        Section InfoSection = [self.releaseMenu[indexPath.section] integerValue];
        if(InfoSection == ReplaceReleaseSection){
            if (IsPad()) {
                label.text = @"Action on Released Register";
            }
            else {
                reusableview.frame = CGRectMake(reusableview.frame.origin.x, reusableview.frame.origin.y, reusableview.frame.size.width, 0);
                return reusableview;
            }
        }
        else {
            if (self.activeDevResultRelease !=nil && self.activeDevResultRelease.count > 0) {
                label.text = [(self.activeDevResultRelease)[indexPath.section]valueForKey:@"RegisterName"];
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
    Section InfoSection = [self.releaseMenu[indexPath.section] integerValue];
    if(InfoSection == ReplaceReleaseSection){
        if (IsPad()) {
            return CGSizeMake(collectionView.frame.size.width, 80.0);
        }
        else {
            return CGSizeMake(collectionView.frame.size.width, 55.0);
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
    return self.releaseMenu.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    Section InfoSection = [self.releaseMenu[section] integerValue];
    if(InfoSection == ReplaceReleaseSection){
        return 1;
    }
    else{   
        if (self.activeDevResultRelease !=nil && self.activeDevResultRelease.count > 0) {
            NSMutableDictionary *dictTemp = (self.activeDevResultRelease)[section];
            NSArray *arrayModule = [dictTemp valueForKey:@"objModules"];
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
    
    UIView *buttonSubView = [cell.contentView viewWithTag:212121];

    if (buttonSubView) {
        [buttonSubView removeFromSuperview];
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.lblRegName.hidden=NO;
    cell.lblCount.hidden=YES;
    cell.viewBorder.hidden=NO;
    [cell.moduleSwitch setHidden:YES];
    
    Section InfoSection = [self.releaseMenu[indexPath.section] integerValue];
    
    if(InfoSection == ReplaceReleaseSection){
        cell.lblRegName.hidden=YES;
        cell.viewBorder.hidden=YES;
        if (self.activeDevResultRelease == nil || self.activeDevResultRelease.count == 0) {
            cell.viewBorder.hidden=NO;
            cell.lblRegName.hidden = NO;
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
            cell.lblRegName.text = @"There is no release register";
            cell.lblRegName.textColor = [UIColor colorWithRed:132.0/255.0 green:154.0/255.0 blue:196.0/255.0 alpha:1.0];
        }
        else
        {
            if (IsPad()) {
                cell.viewBg.backgroundColor = [UIColor clearColor];
                BOOL isRcdActive = [self isRcdActiveForRegister];
                if (!self.isRcrActive && !isRcdActive) {
                    [[cell.contentView viewWithTag:212121] removeFromSuperview];
                    UIButton *btnReplaceRegister = [self buttonForCellWithNoramalImage:@"replacewiththisregister.png" selectedImage:@"replacewiththisregisterselected.png" withFrame:CGRectMake(60, 0, 259, 44)];
                    btnReplaceRegister.tag = 212121;
                    [btnReplaceRegister addTarget:self action:@selector(alertForReplaceReleasedRegister) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:btnReplaceRegister];
                }
            }
            else {
                UICollectionViewCell *collectionViewCell = [self collectionViewCellForIndexPath:indexPath collectionView:collectionView];
                return collectionViewCell;
            }
        }
    }
    else{
        [[cell.contentView viewWithTag:2020] removeFromSuperview];
        cell.viewBg.backgroundColor = [UIColor whiteColor];
        NSMutableDictionary *dictUserModule = (self.activeDevResultRelease)[indexPath.section];
        NSArray *arrayModule = [dictUserModule valueForKey:@"objModules"];
        if([arrayModule isKindOfClass:[NSArray class]]){
            NSMutableDictionary *dictTemp = arrayModule[indexPath.row];
            cell.lblRegName.text=[dictTemp valueForKey:@"Name"];
            cell.lblRegName.textColor = [UIColor blackColor];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UICollectionViewCell *)collectionViewCellForIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView {
    UICollectionViewCell *cell;
    BOOL isRcdActive = [self isRcdActiveForRegister];
    if (!self.isRcrActive && !isRcdActive) {
        BOOL isRCRActiveInSelectedReg =  [self isRCRActiveInSelectedRegister];
        if (!isRCRActiveInSelectedReg) {
            //Replace Register
            cell = [self replaceRegisterCollectionCellForIndexPath:indexPath collectionView:collectionView needToHideButton:NO];
        }
        else {
            //Without Replace Register
            cell = [self withoutReplaceRegisterCollectionCellForIndexPath:indexPath collectionView:collectionView];
        }
    }
    else {
        //Display Nothing
        cell = [self replaceRegisterCollectionCellForIndexPath:indexPath collectionView:collectionView needToHideButton:YES];
    }
    return cell;
}

- (UICollectionViewCell *)replaceRegisterCollectionCellForIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView needToHideButton:(BOOL)needToHideButton{
    ReplaceRegisterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReplaceRegisterCollectionCell_iPhone" forIndexPath:indexPath];
    if (needToHideButton) {
        cell.btnReplaceRegister.hidden = YES;
    }
    else {
        cell.btnReplaceRegister.hidden = NO;
    }
    [cell.btnReplaceRegister addTarget:self action:@selector(alertForReplaceReleasedRegister) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (UICollectionViewCell *)withoutReplaceRegisterCollectionCellForIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView {
    WithoutReplaceRegisterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WithoutReplaceRegisterCollectionCell_iPhone" forIndexPath:indexPath];
    return cell;
}

- (BOOL)isRcdActiveForRegister
{
    BOOL isRcdActive = FALSE;
    NSPredicate *rcdPredicate = [NSPredicate predicateWithFormat:@"ModuleCode = %@",@"RCD"];
    NSArray *rcdArray = (NSArray *)[[[self.activeDevResultRelease valueForKey:@"objModules"] firstObject] filteredArrayUsingPredicate:rcdPredicate];
    if (rcdArray != nil && rcdArray.count > 0) {
        isRcdActive = TRUE;
    }
    return isRcdActive;
}

-(BOOL)isRCRActiveInSelectedRegister
{
    BOOL isRCRActive = FALSE;
    NSPredicate *rcrPredicate = [NSPredicate predicateWithFormat:@"ModuleId == %@ OR ModuleId == %@ OR ModuleId == %@ OR ModuleId == %@",@"1",@"5",@"6",@"7"];
    NSMutableArray *arrReleaseModuleId = [[NSMutableArray alloc] init];
    NSArray *arrayModuleIds;
    if (![[self.activeDevResultRelease firstObject] [@"ModuleIds"] isKindOfClass:[NSNull class]]) {
        if ([self.activeDevResultRelease firstObject] [@"ModuleIds"] && [[self.activeDevResultRelease firstObject] [@"ModuleIds"] length] > 0) {
            arrayModuleIds = [[self.activeDevResultRelease firstObject] [@"ModuleIds"] componentsSeparatedByString:@","];
        }
    }
    if (arrayModuleIds != nil && arrayModuleIds.count > 0) {
        for (NSString *moduleId in arrayModuleIds) {
            [arrReleaseModuleId addObject:@{@"ModuleId":[moduleId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]}];
        }
        NSArray *rcrActiveArray = [arrReleaseModuleId filteredArrayUsingPredicate:rcrPredicate];
        if (rcrActiveArray.count > 0)
        {
            isRCRActive = TRUE;
        }
        else
        {
            isRCRActive = FALSE;
        }
    }
    return isRCRActive;
}

- (void)alertForReplaceReleasedRegister
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action){
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
        [self replaceRegister];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"Are you sure you want to replace this register"] buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

- (UIButton *)buttonForCellWithNoramalImage:(NSString *)noramalImage selectedImage:(NSString *)selectedImage withFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:[UIImage imageNamed:noramalImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    return button;
}

-(void)replaceRegister{
    if (IsPad()) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    }
    else {
        [self.releaseModuleVCDelegate startActivityIndicator];
    }
    NSMutableDictionary *dictReplaceRegister = [[NSMutableDictionary alloc] init];
    dictReplaceRegister[@"BranchId"] = self.strBranchId;
    dictReplaceRegister[@"currentMacAddress"] = (self.rmsDbController.globalDict)[@"DeviceId"];
    if (self.activeDevResultRelease != nil && self.activeDevResultRelease.count > 0) {
        NSDictionary *dictReleaseModule = self.activeDevResultRelease.firstObject;
        dictReplaceRegister[@"OtherRegId"] = [dictReleaseModule valueForKey:@"RegisterId"];
        dictReplaceRegister[@"OtherMacAddress"] = [dictReleaseModule valueForKey:@"MacAddress"];
        dictReplaceRegister[@"OtherRegisterNo"] = [dictReleaseModule valueForKey:@"RegisterNo"];
    }
    dictReplaceRegister[@"LocalDate"] = [self localeDate];
    dictReplaceRegister[@"RegId"] = @(0);
    if (self.activeModules != nil && self.activeModules.count > 0) {
        if((self.rmsDbController.globalDict)[@"RegisterId"]){
            dictReplaceRegister[@"RegId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
        }
    }
    
    dictReplaceRegister[@"CompanyId"] = self.strCOMCOD;
    dictReplaceRegister[@"ConfigurationId"] = (self.rmsDbController.globalDict)[@"CONFIGID"];
    
    dictReplaceRegister[@"Activity"] = @(3);
    NSString *buildVersion = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
    if ([buildVersion isKindOfClass:[NSString class]])
    {
        dictReplaceRegister[@"BuildVersion"] = buildVersion;
    }
    else
    {
        dictReplaceRegister[@"BuildVersion"] = @"";
    }

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self replaceRegisterResultResponse:response error:error];
        });
    };
    
    self.replaceRegisterConnection = [self.replaceRegisterConnection initWithRequest:KURL actionName:WSM_REPLACE_REGISTER params:dictReplaceRegister completionHandler:completionHandler];
}

- (void)replaceRegisterResultResponse:(id)response error:(NSError *)error
{
    if (IsPad()) {
        [_activityIndicator hideActivityIndicator];
    }
    else {
        [self.releaseModuleVCDelegate stopActivityIndicator];
    }
    [self.releaseModuleVCDelegate replaceRegisterResponse:response error:response];
}

- (NSString *)localeDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *currentDateTime = [formatter stringFromDate:date];
    return currentDateTime;
}

-(void)filterWithUserWiseReleaseModule:(NSString *)strRegName{
    self.strRegName = strRegName;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"RegisterName == %@",strRegName];
    self.activeDevResultRelease = [[self.globalactiveDevResultRelease filteredArrayUsingPredicate:predicate] mutableCopy];
    
    if (self.activeDevResultRelease !=nil && self.activeDevResultRelease.count > 0) {
        self.releaseMenu = [[NSMutableArray alloc] initWithObjects:@(ReleaseModuleSection),@(ReplaceReleaseSection), nil];
    }
    else{
        self.releaseMenu = [[NSMutableArray alloc] initWithObjects:@(ReplaceReleaseSection), nil];
    }
    [self.releaseModule reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
