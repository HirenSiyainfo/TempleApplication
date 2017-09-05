//
//  DepartmentViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 12/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "GroupMasterPopover.h"
#import "UITableView+AddBorder.h"

#import "RmsDbController.h"
#import "GroupMaster+Dictionary.h"
#import "DepartmentSelectionCell.h"
#import "UserInputTextVC.h"

@interface GroupMasterPopover ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NSFetchedResultsControllerDelegate>
{
    UIAlertController *customerAlert;
    MICheckBox * taxCheckBox;
    NSString * strSearchString;
    UIColor * colorDefault;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;

}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITextField * txtSearchGroup;
@property (nonatomic, weak) IBOutlet UITableView * aTableView;

@property (nonatomic, strong) NSString *groupDiscID;
@property (nonatomic, strong) NSFetchedResultsController * itemGroupList;
@end

@implementation GroupMasterPopover


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    colorDefault = [UIColor blackColor];
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioselected.png"];
    strSearchString = @"";
}

- (IBAction) toolBarActionHandler:(id)sender {
	switch ([sender tag]) {
		case 101:
            [self.view removeFromSuperview];
			break;
		case 102:
            [self.view removeFromSuperview];
			break;
		default:
			break;
	}
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - UITextFieldDelegate -

- (void)textFieldDidEndEditing:(UITextField *)textField {
    strSearchString = textField.text;
    [self reloadeMasterList];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    strSearchString = @"";
    [self reloadeMasterList];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    strSearchString = textField.text;
    [self reloadeMasterList];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {   // return NO to not change text
    if (_itemGroupList.fetchedObjects.count > 0) {
        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.aTableView scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
    strSearchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self reloadeMasterList];
    return YES;
}

-(IBAction)btnreloadeMasterList:(id)sender {
    [self.txtSearchGroup resignFirstResponder];
}
-(void)reloadeMasterList{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _itemGroupList = nil;
        [self.aTableView reloadData];
    });
}

-(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:messageTitle message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *sections = self.itemGroupList.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
    return sectionInfo.numberOfObjects + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DepartmentSelectionCell * cell=(DepartmentSelectionCell *)[self.aTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[DepartmentSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    NSMutableDictionary * dictGroupInfo;

    cell.imgIsSelected.image = imgDefault;
    cell.lblDeptName.textColor = colorDefault;

    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.lblDeptName.text = @"None";
    }
    else if (indexPath.row == self.itemGroupList.fetchedObjects.count + 1) {
        cell.lblDeptName.text = @"Custom";
    }
    else{
        dictGroupInfo = [self getGroupDictInfoAt:indexPath];
        cell.lblDeptName.text = [NSString stringWithFormat:@"%@",[dictGroupInfo valueForKey:@"groupName"]];
    }
    if ((self.strGroupID == nil || [self.strGroupID isEqualToString:@"0"] || [self.strGroupID isEqualToString:@""]) && indexPath.row == 0) {
        cell.imgIsSelected.image = imgSelected;
        cell.lblDeptName.textColor = colorSelected;
    }
    else if (dictGroupInfo !=nil && [dictGroupInfo[@"groupId"] integerValue] == self.strGroupName.integerValue ) {
        cell.imgIsSelected.image = imgSelected;
        cell.lblDeptName.textColor = colorSelected;

    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.GroupMasterChangeDelegate didChangeGroupMaster:@"" GroupId:@""];
        self.groupDiscID = @"";
        self.strGroupID = @"0";
        self.strGroupName = @"";
    }
    else if (indexPath.row == self.itemGroupList.fetchedObjects.count + 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self customCategoryName:nil];
        });
    }
    else {
        NSMutableDictionary *dictTemp = [self getGroupDictInfoAt:indexPath];
        [self.GroupMasterChangeDelegate didChangeGroupMaster:[dictTemp valueForKey:@"groupName"] GroupId:[dictTemp valueForKey:@"groupId"]];
        
        self.groupDiscID = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"Disc_Id"]];
        self.strGroupName = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"groupId"]];
        self.strGroupID = [NSString stringWithFormat:@"%@",[dictTemp valueForKey:@"groupId"]];
    }
    [self.aTableView reloadData];
}
-(IBAction)customCategoryName:(UIButton *)sender
{
    UserInputTextVC * objUserInputTextVC = [UserInputTextVC setInputTextFieldViewitem:@"" InputTitle:@"Group Master" InputSubTitle:@"Enter custom group name" InputSaved:^(NSString *strInput) {
        [self sendGroupInfoAfterCheckingGroupIsUnique:strInput];
        [self.navigationController popViewControllerAnimated:YES];

    } InputClosed:^(UIViewController *popUpVC) {
        [((UserInputTextVC *)popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objUserInputTextVC.strImputPlaceHolder = @"Group Name";
    objUserInputTextVC.strImputErrorMessage = @"Please Enter Custom Group Name";
    objUserInputTextVC.isBlankInputSaved = FALSE;
    objUserInputTextVC.isKeybordShow = TRUE;
    [objUserInputTextVC presentViewControllerForviewConteroller:self sourceView:nil ArrowDirection:(UIPopoverArrowDirection)nil];
    self.popoverPresentationController.delegate = objUserInputTextVC;
}
- (void)sendGroupInfoAfterCheckingGroupIsUnique:(NSString *)groupName
{
    groupName = [groupName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
     NSPredicate *groupTredicate = [NSPredicate predicateWithFormat:@"groupName == [c]%@",groupName];
    fetchRequest.predicate = groupTredicate;
    
    NSArray *matchedGroups = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];

    NSString *group = @"";
    NSString *groupId = @"";
    
    if (matchedGroups != nil && matchedGroups.count > 0) {
        group = [matchedGroups.firstObject valueForKey:@"groupName"];
        groupId = [NSString stringWithFormat:@"%@",[matchedGroups.firstObject valueForKey:@"groupId"]];
    }
    else {
        group = groupName;
        groupId = @"-1";
    }
    [self.GroupMasterChangeDelegate didChangeGroupMaster:group GroupId:groupId];
}
-(IBAction)btnDoneClicked:(id)sender
{
//    [self.GroupMasterChangeDelegate didChangeGroupMaster:(customerAlert.textFields[0]).text GroupId:@"0"];
    [self.view removeFromSuperview];
}

-(IBAction)btnCancelClicked:(id)sender
{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.itemGroupList = nil;
//        [self.aTableView reloadData];
//    });
}

#pragma mark -
#pragma mark Mamory Management

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)backToItemView:(id)sender
{
    [self exitTimerViewController];
}

- (void)exitTimerViewController {
    if (self.navigationController) {
        [self.GroupMasterChangeDelegate checkMixMatchGroupDiscount:self.groupDiscID];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.view removeFromSuperview];
    }
}

-(NSMutableDictionary *)getGroupDictInfoAt:(NSIndexPath *)indexPath{
    NSIndexPath * tempIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
    GroupMaster *supplier = [self.itemGroupList objectAtIndexPath:tempIndexPath];
    return [self getGroupDictInfo:supplier];
}

-(NSMutableDictionary *)getGroupDictInfo:(GroupMaster *)groupmst {
    NSMutableDictionary *groupDict=[[NSMutableDictionary alloc]init];
    groupDict[@"groupName"] = groupmst.groupName;
    groupDict[@"groupId"] = groupmst.groupId;
    groupDict[@"Disc_Id"] = groupmst.disc_Id;
    return groupDict;
}
#pragma mark - CoreData Methods
- (NSFetchedResultsController *)itemGroupList {
    
    if (_itemGroupList != nil) {
        return _itemGroupList;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;

    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"groupName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    if (strSearchString.length > 0) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"groupName LIKE[cd] %@",[NSString stringWithFormat:@"*%@*",strSearchString]];
    }
    if ([UpdateManager countForContext:_managedObjectContext FetchRequest:fetchRequest] == 0) {
        fetchRequest.predicate = nil;
        [self showMessageOfChangePriceTitle:@"Item Management" withMessage:[NSString stringWithFormat:@"No Record Found for %@",strSearchString]];
        strSearchString = @"";
        _txtSearchGroup.text = @"";
    }
    
    // Create and initialize the fetch results controller.
    _itemGroupList = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_itemGroupList performFetch:nil];
    _itemGroupList.delegate = self;
    
    return _itemGroupList;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemGroupList]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.aTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.itemGroupList]) {
        return;
    }
    
    UITableView *tableView = self.aTableView;
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:1];
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.itemGroupList]) {
        return;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemGroupList]) {
        return;
    }
    [self.aTableView endUpdates];
}
@end
