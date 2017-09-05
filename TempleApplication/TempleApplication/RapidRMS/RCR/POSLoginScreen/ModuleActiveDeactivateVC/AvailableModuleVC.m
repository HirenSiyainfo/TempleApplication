//
//  DisplayModuleViewController.m
//  RapidRMS
//
//  Created by Siya on 17/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AvailableModuleVC.h"
#import "RmsDbController.h"
#import "DisplayModuleCell.h"
#import "DisplayModuleAlreadyActive.h"


@interface AvailableModuleVC ()
{
    NSIndexPath *clickedIndexpath;
}

@property (nonatomic, weak) IBOutlet UICollectionView *moduleCollection;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *sectionAvailbleHeader;
@property (nonatomic, strong) NSArray *sectionAvailbleImage;

@end

@implementation AvailableModuleVC

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
    self.sectionAvailbleHeader = [[NSMutableArray alloc]initWithObjects:@"CASH REGISTERS",@"MODULES", nil];
    if (IsPad()) {
        self.sectionAvailbleImage = @[@"registericon.png",@"moduleicon.png"];
    }
    else {
        self.sectionAvailbleImage = @[@"registericon_iphone.png",@"moduleicon_ihpone.png"];
    }
    // Do any additional setup after loading the view.
}

-(void)reloadAvailableModuleData
{
    [self.moduleCollection reloadData];
}

#pragma mark CollectionView Delegate Method

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        CGFloat xPositionOfLable;
        CGRect imageViewFrame;
        if (IsPad()) {
            xPositionOfLable = 60;
            imageViewFrame = CGRectMake(17, 9, 28, 28);
        }
        else {
            xPositionOfLable = 47;
            imageViewFrame = CGRectMake(15, 12, 20, 20);
        }
        if (reusableview == nil) {
            reusableview = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        }
        reusableview.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:34.0/255.0 blue:61.0/255.0 alpha:1.0];
        [[reusableview viewWithTag:400]removeFromSuperview];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPositionOfLable, 0, 320, 44)];
        label.text = (self.sectionAvailbleHeader)[indexPath.section];
        label.textColor = [UIColor whiteColor];
        label.tag = 400;
        [reusableview addSubview:label];
        
        [[reusableview viewWithTag:500]removeFromSuperview];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.image = [UIImage imageNamed:(self.sectionAvailbleImage)[indexPath.section]];
        imageView.tag = 500;
        [reusableview addSubview:imageView];
        reusableview.hidden = NO;
        if (indexPath.section == 0) {
            if (self.rcrModuleData == nil || self.rcrModuleData.count == 0) {
                reusableview.hidden = YES;
            }
        }
        else
        {
            if(self.otherModulData == nil || self.otherModulData.count == 0)
            {
                reusableview.hidden = YES;
            }
        }
        return reusableview;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IsPhone()) {
        return CGSizeMake(collectionView.frame.size.width, 55.0);
    }
    return CGSizeMake(collectionView.frame.size.width, 62.0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return self.rcrModuleData.count;
    }
    else
    {
        return self.otherModulData.count;
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if (self.isRcrActive) {
            DisplayModuleAlreadyActive *alreadyActiveCell = [self congigureAleradyActiveCell:collectionView forIndexPath:indexPath fromModuleArray:self.rcrModuleData];
            return alreadyActiveCell;
        }
        else {
            DisplayModuleCell *cell = [self congigureAvailableCell:collectionView forIndexPath:indexPath fromModuleArray:self.rcrModuleData];
            return cell;
        }
    }
    else
    {
        NSMutableDictionary *dictTemp = (self.otherModulData)[indexPath.row];
        
        NSPredicate *otherAlreadyActivePredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d",[[dictTemp valueForKey:@"ModuleId"] integerValue]];
        
        NSArray *otherActivatedModule = [self.activeModules filteredArrayUsingPredicate:otherAlreadyActivePredicate];
        
        if (otherActivatedModule != nil && otherActivatedModule.count > 0) {
            DisplayModuleAlreadyActive *alreadyActiveCell = [self congigureAleradyActiveCell:collectionView forIndexPath:indexPath fromModuleArray:self.otherModulData];
            return alreadyActiveCell;
        }
        else
        {
            DisplayModuleCell *cell = [self congigureAvailableCell:collectionView forIndexPath:indexPath fromModuleArray:self.otherModulData];
            return cell;
        }
    }
}

- (DisplayModuleAlreadyActive *)congigureAleradyActiveCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath fromModuleArray:(NSMutableArray *)moduleArray
{
    NSString *cellIdentifier =  @"";
    if (IsPad()) {
        cellIdentifier = @"DisplayModuleAlreadyActive";
    }
    else {
        cellIdentifier = @"DisplayModuleAlreadyActive_iPhone";
    }
    DisplayModuleAlreadyActive *alreadyActiveCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    alreadyActiveCell.backgroundColor = [UIColor clearColor];
    alreadyActiveCell.lblCount.layer.cornerRadius = 15.0;
    NSMutableDictionary *dictTemp = moduleArray[indexPath.row];
    alreadyActiveCell.lblRegName.text = [dictTemp valueForKey:@"Name"];
    alreadyActiveCell.lblCount.text = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"Count"]];
    return alreadyActiveCell;
}

- (DisplayModuleCell *)congigureAvailableCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath fromModuleArray:(NSMutableArray *)moduleArray
{
    NSString *cellIdentifier =  @"";
    if (IsPad()) {
        cellIdentifier = @"DisplayModuleCell";
    }
    else {
        cellIdentifier = @"DisplayModuleCell_iPhone";
    }
    DisplayModuleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    cell.lblCount.layer.cornerRadius = 15.0;
    [cell.moduleSwitch addTarget:self action:@selector(activeDeactiveModule:) forControlEvents:UIControlEventValueChanged];
    [cell.moduleSwitch setOn:NO];
    
    NSMutableDictionary *dictTemp = moduleArray[indexPath.row];
    cell.lblRegName.text = [dictTemp valueForKey:@"Name"];
    cell.lblCount.text = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"Count"]];
    
    if (IsPhone()) {
        if (indexPath.section == 0) {
            cell.moduleSwitch.enabled = NO;
        }
        else
        {
            NSInteger moduleId = [[dictTemp valueForKey:@"ModuleId"] integerValue];
            if (moduleId != 4) {
                cell.moduleSwitch.enabled = YES;
            }
            else {
                cell.moduleSwitch.enabled = NO;
            }
        }
    }
    
    if ([[dictTemp valueForKey:@"MacAdd"] isEqualToString:(self.rmsDbController.globalDict)[@"DeviceId"]])
    {
        if([[dictTemp valueForKey:@"IsActive"]integerValue] == 1)
        {
            [cell.moduleSwitch setOn:YES];
        }
        else
        {
            [cell.moduleSwitch setOn:NO];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

-(void)activeDeactiveModule:(id)sender {
    DisplayModuleCell *clickCell = (DisplayModuleCell *)[sender superview].superview.superview;
    NSIndexPath *indexPath = [self.moduleCollection indexPathForCell:clickCell];
    if(self.activationDisable)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        
        [self.rmsDbController popupAlertFromVC:self title:@"Active Application" message:@"You cannot active other store's module" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    else
    {
        NSMutableDictionary *dictSelected;
        if(indexPath.section == 0)
        {
            dictSelected = (self.rcrModuleData)[indexPath.row];
        }
        else
        {
            dictSelected = (self.otherModulData)[indexPath.row];
        }
        
        if (self.activeModules != nil && self.activeModules.count > 0) {
            NSInteger moduleId = [[dictSelected valueForKey:@"ModuleId"] integerValue];
            NSMutableArray *isFoundArray = [self filterArrayForAlreadyActiveModule:self.activeModules withModuleId:moduleId];
            if(isFoundArray.count > 0 )
            {
                [self showAlertForAlreadyActiveModule:[dictSelected valueForKey:@"Name"]];
                [clickCell.moduleSwitch setOn:NO];
                return;
            }
        }
        
        if (self.isRcrActive) {
            if(([[dictSelected valueForKey:@"ModuleId"] integerValue] == 1) || ([[dictSelected valueForKey:@"ModuleId"] integerValue] == 5) || ([[dictSelected valueForKey:@"ModuleId"] integerValue] == 6) || ([[dictSelected valueForKey:@"ModuleId"] integerValue] == 7) )
            {
                if(self.activeModules != nil && self.activeModules.count > 0)
                {
                    NSMutableArray *isFoundArray = [self filterArrayForRCRActivation:self.activeModules];
                    
                    if(isFoundArray.count > 0)
                    {
                        [self showAlertToRestrictRCRActivation];
                        [clickCell.moduleSwitch setOn:NO];
                        return;
                    }
                }
            }
        }
        
        
        if([[dictSelected valueForKey:@"IsActive"] integerValue ] == 0 )
        {
            clickedIndexpath = [indexPath copy];
            int temp2 = 0;
            NSInteger moduleId = [[dictSelected valueForKey:@"ModuleId"] integerValue];
            NSMutableArray *isFoundArray = [self filterArrayForAlreadyActiveModule:self.deactiveDeviceArray withModuleId:moduleId];
            
            if(isFoundArray.count > 0 )
            {
                [self showAlertForAlreadyActiveModule:[dictSelected valueForKey:@"Name"]];
                [clickCell.moduleSwitch setOn:NO];
                return;
            }
            
//            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
//            {
//                if([[(self.rcrModuleData)[indexPath.row] valueForKey:@"ModuleId"] integerValue ] == 2)
//                {
//                    AvailableModuleVC * __weak myWeakReference = self;
//                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
//                    {
//                        [clickCell.moduleSwitch setOn:NO];
//                        [myWeakReference.moduleCollection deselectItemAtIndexPath:clickedIndexpath animated:NO];
//                    };
//                    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
//                    {
//                        NSMutableDictionary *dictSelected;
//                        if(clickedIndexpath.section==0){
//                            dictSelected = (myWeakReference.rcrModuleData)[clickedIndexpath.row];
//                        }
//                        else{
//                            dictSelected = (myWeakReference.otherModulData)[clickedIndexpath.row];
//                        }
//                        dictSelected[@"IsActive"] = @"1";
//                        dictSelected[@"MacAdd"] = (myWeakReference.rmsDbController.globalDict)[@"DeviceId"];
//                        NSInteger recordCount = [[dictSelected valueForKey:@"Count"] integerValue ];
//                        dictSelected[@"Count"] = @(recordCount - 1);
//                        (myWeakReference.displayModuleData)[clickedIndexpath.row] = dictSelected;
//                        [myWeakReference.moduleCollection reloadItemsAtIndexPaths:@[clickedIndexpath]];
//                        [myWeakReference.moduleCollection selectItemAtIndexPath:clickedIndexpath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//                    };
//                    [self.rmsDbController popupAlertFromVC:self title:@"Active Application" message:@"Are you sure you want to active this package?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
//                }
//            }
//            else
//            {
                if(([[dictSelected valueForKey:@"ModuleId"] integerValue] == 1) || ([[dictSelected valueForKey:@"ModuleId"] integerValue] == 5) || ([[dictSelected valueForKey:@"ModuleId"] integerValue] == 6) || ([[dictSelected valueForKey:@"ModuleId"] integerValue] == 7) )
                {
                    if(self.deactiveDeviceArray.count > 0)
                    {
                        NSMutableArray *isFoundArray = [self filterArrayForRCRActivation:self.deactiveDeviceArray];
                        
                        if(isFoundArray.count > 0)
                        {
                            [self showAlertToRestrictRCRActivation];
                            [clickCell.moduleSwitch setOn:NO];
                            return;
                        }
                    }
                }
                
                AvailableModuleVC * __weak myWeakReference = self;
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    [clickCell.moduleSwitch setOn:NO];
                    [myWeakReference.moduleCollection deselectItemAtIndexPath:clickedIndexpath animated:NO];
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    NSMutableDictionary *dictSelected;
                    if(clickedIndexpath.section==0){
                        dictSelected = (myWeakReference.rcrModuleData)[clickedIndexpath.row];
                    }
                    else{
                        dictSelected = (myWeakReference.otherModulData)[clickedIndexpath.row];
                    }
                    dictSelected[@"IsActive"] = @"1";
                    dictSelected[@"MacAdd"] = (myWeakReference.rmsDbController.globalDict)[@"DeviceId"];
                    NSInteger recordCount = [[dictSelected valueForKey:@"Count"] integerValue ];
                    dictSelected[@"Count"] = @(recordCount - 1);
                  
                    NSPredicate *modulePredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d AND (IsActive == %d OR IsActive == %@ OR IsRelease == 1)", moduleId,temp2,@"0"];
                   
                    NSDictionary *dict = [self.deactiveDeviceArray filteredArrayUsingPredicate:modulePredicate].firstObject;
                    NSUInteger index = [self.deactiveDeviceArray indexOfObject:dict];
                  
                    NSMutableDictionary *deactiveDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                    
                    deactiveDict[@"IsActive"] = @"1";
                    deactiveDict[@"MacAdd"] = (myWeakReference.rmsDbController.globalDict)[@"DeviceId"];
                    (self.deactiveDeviceArray)[index] = deactiveDict;
                    
                    (myWeakReference.displayModuleData)[clickedIndexpath.row] = dictSelected;
                    [myWeakReference.moduleCollection reloadItemsAtIndexPaths:@[clickedIndexpath]];
                    [myWeakReference.moduleCollection selectItemAtIndexPath:clickedIndexpath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                };
                
                [self.rmsDbController popupAlertFromVC:self title:@"Active Application" message:@"Are you sure you want to active this package?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
                return;
//            }
        }
        else
        {
            dictSelected[@"IsActive"] = @"0";
            NSInteger recordCount = [[dictSelected valueForKey:@"Count"] integerValue];
            dictSelected[@"Count"] = @(recordCount + 1);
            
            NSPredicate *modulePredicate = [NSPredicate predicateWithFormat:@"ModuleId == %d AND (IsActive == 1 OR IsActive == %@ OR IsRelease == 1)", [[dictSelected valueForKey:@"ModuleId"] integerValue],@"1"];
            NSDictionary *dict = [self.deactiveDeviceArray filteredArrayUsingPredicate:modulePredicate].firstObject;
            NSUInteger index = [self.deactiveDeviceArray indexOfObject:dict];
            NSMutableDictionary *deactiveDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            deactiveDict[@"IsActive"] = @"0";
            deactiveDict[@"MacAdd"] = @"";
            (self.deactiveDeviceArray)[index] = deactiveDict;
            
        }
        if(indexPath.section==0)
        {
            (self.rcrModuleData)[indexPath.row] = dictSelected;
        }
        else{
            (self.otherModulData)[indexPath.row] = dictSelected;
        }
        if(clickCell.moduleSwitch.isOn == NO){
            NSArray *arrayIndexpath = @[indexPath];
            [self.moduleCollection reloadItemsAtIndexPaths:arrayIndexpath];
        }
    }
}

- (NSMutableArray *)filterArrayForRCRActivation:(NSArray *)array
{
    int ModuleAccessId = 1;
    NSPredicate *rcrActive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND ModuleAccessId == %d AND (IsActive == 1 OR IsActive == %@)", (self.rmsDbController.globalDict)[@"DeviceId"],ModuleAccessId,@"1"];
    return [[array filteredArrayUsingPredicate:rcrActive] mutableCopy];
}

- (NSMutableArray *)filterArrayForAlreadyActiveModule:(NSArray *)array withModuleId:(NSInteger)moduleId
{
    NSPredicate *alreadyActive = [NSPredicate predicateWithFormat:@"MacAdd == %@ AND ModuleId == %d AND (IsActive == 1 OR IsActive == %@)", (self.rmsDbController.globalDict)[@"DeviceId"],moduleId,@"1"];
    return [[array filteredArrayUsingPredicate:alreadyActive] mutableCopy];
}

- (void)showAlertToRestrictRCRActivation
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Active Application" message:@"You can select Either RCR or RCR + Gas or Restaurant or Restaurant + Retail Module, you can't active both module at a time" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
}

- (void)showAlertForAlreadyActiveModule:(NSString *)moduleName
{
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Active Application" message:[NSString stringWithFormat:@"%@ module is already active",moduleName] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
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

@end
