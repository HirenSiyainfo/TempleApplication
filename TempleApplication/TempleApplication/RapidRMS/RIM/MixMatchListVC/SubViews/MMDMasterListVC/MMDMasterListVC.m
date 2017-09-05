//
//  MMDMasterListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDMasterListVC.h"
#import "RmsDbController.h"
#import "Department+Dictionary.h"
#import "SizeMaster+Dictionary.h"
#import "GroupMaster+Dictionary.h"

@interface MMDMasterListVC ()<NSFetchedResultsControllerDelegate> {
    NSArray * arrMasterTitle;
    NSArray * arrMasterEntity;
    NSArray * arrSortDescriptorKey;
    id selectedOblect;
}

@property (nonatomic, strong) NSFetchedResultsController * MMDMasterListRC;
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, weak) IBOutlet UITableView * tblMMDMasterList;
@property (nonatomic, weak) IBOutlet UILabel * lblMasterTitle;
@property (nonatomic, weak) IBOutlet UITextField * txtSearchText;
@property (nonatomic, weak) IBOutlet UIButton * btnAllItem;

@end

@implementation MMDMasterListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    arrMasterTitle = @[@"Department",@"Tag",@"Group"];
    arrMasterEntity = @[@"Department",@"SizeMaster",@"GroupMaster"];
    arrSortDescriptorKey = @[@"deptName",@"sizeName",@"groupName"];
    self.managedObjectContext = [RmsDbController sharedRmsDbController].managedObjectContext;
    self.tblMMDMasterList.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _lblMasterTitle.text = [arrMasterTitle[self.selectedMaster] uppercaseString];
    _txtSearchText.placeholder = [NSString stringWithFormat:@"SEARCH %@",[arrMasterTitle[self.selectedMaster] uppercaseString]];
    [_btnAllItem setTitle:[NSString stringWithFormat:@"All %@'s Items",arrMasterTitle[self.selectedMaster]] forState:UIControlStateNormal];
    if (!selectedOblect) {
        NSArray *sections = self.MMDMasterListRC.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
        if (sectionInfo.numberOfObjects > 0) {
            [self allMasterItems:nil];
        }
    }
    else {
        [self.Delegate didSelectMasterInfo:nil];
    }
}


#pragma mark - UITextFieldDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.MMDMasterListRC = nil;
    [self.tblMMDMasterList reloadData];
    return NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self searchContainText:nil];
    return YES;
}

#pragma mark - IBActions -
-(IBAction)allMasterItems:(id)sender {
    NSArray * masterAllTitle;
    _txtSearchText.text = @"";
    self.MMDMasterListRC = nil;
    NSArray * masterAllObject = self.MMDMasterListRC.fetchedObjects;
    NSPredicate * filterItem;
    switch (self.selectedMaster) {
        case MasterTypesDepartment: {
//            deptName
            masterAllTitle = [masterAllObject valueForKey:@"deptId"];
            filterItem = [NSPredicate predicateWithFormat:@"deptId IN %@",masterAllTitle];
            break;
        }
        case MasterTypesTAG: {
//            sizeName
            masterAllTitle = [masterAllObject valueForKey:@"sizeId"];
            filterItem = [NSPredicate predicateWithFormat:@"ANY itemTags.tagToSizeMaster.sizeId IN %@",masterAllTitle];
            break;
        }
        case MasterTypesGroup: {
//            groupName
            masterAllTitle = [masterAllObject valueForKey:@"groupId"];
            filterItem = [NSPredicate predicateWithFormat:@"itemGroupMaster.groupId IN %@",masterAllTitle];
            break;
        }
    }
    selectedOblect = nil;
    [self.Delegate didSelectMasterInfo:filterItem];
    [self.tblMMDMasterList reloadData];
}
-(IBAction)searchContainText:(id)sender {
    [_txtSearchText resignFirstResponder];
    self.MMDMasterListRC = nil;
    [self.tblMMDMasterList reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    NSArray *sections = self.MMDMasterListRC.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = self.MMDMasterListRC.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    switch (self.selectedMaster) {
        case MasterTypesDepartment: {
            [self setCellFroDepartment:cell atIndex:indexPath];
            break;
        }
        case MasterTypesTAG: {
            [self setCellFroTag:cell atIndex:indexPath];
            break;
        }
        case MasterTypesGroup: {
            [self setCellFroGroup:cell atIndex:indexPath];
            break;
        }
    }
    UIView * sb = [[UIView alloc]init];
    sb.backgroundColor = [UIColor colorWithRed:0.957 green:0.553 blue:0.004 alpha:1.000];
    cell.selectedBackgroundView = sb;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIFont * lato = [UIFont fontWithName:@"Lato-Regular" size:14];
    cell.textLabel.font = lato;
    cell.textLabel.textColor = [UIColor blackColor];
    if (selectedOblect && [[self.MMDMasterListRC objectAtIndexPath:indexPath] isEqual:selectedOblect]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:0.957 green:0.553 blue:0.004 alpha:1.000];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.957 green:0.553 blue:0.004 alpha:1.000];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)setCellFroDepartment:(UITableViewCell *)cell atIndex:(NSIndexPath *)indexPath {
    Department *deptlist = [self.MMDMasterListRC objectAtIndexPath:indexPath];
    cell.textLabel.text=deptlist.deptName;
}

-(void)setCellFroTag:(UITableViewCell *)cell atIndex:(NSIndexPath *)indexPath {
    SizeMaster *taglist = [self.MMDMasterListRC objectAtIndexPath:indexPath];
    cell.textLabel.text=taglist.sizeName;
}

-(void)setCellFroGroup:(UITableViewCell *)cell atIndex:(NSIndexPath *)indexPath {
    GroupMaster *groupMst = [self.MMDMasterListRC objectAtIndexPath:indexPath];
    cell.textLabel.text=groupMst.groupName;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedOblect =[self.MMDMasterListRC objectAtIndexPath:indexPath];
    [tableView reloadData];
     NSPredicate * filterItem;
    switch (self.selectedMaster) {
        case MasterTypesDepartment: {
            Department *deptlist = [self.MMDMasterListRC objectAtIndexPath:indexPath];
            filterItem = [NSPredicate predicateWithFormat:@"deptId == %@",deptlist.deptId];
            break;
        }
        case MasterTypesTAG: {
            SizeMaster *taglist = [self.MMDMasterListRC objectAtIndexPath:indexPath];
            filterItem = [NSPredicate predicateWithFormat:@"ANY itemTags.sizeId == %@",taglist.sizeId];
            break;
        }
        case MasterTypesGroup: {
            GroupMaster *groupMst = [self.MMDMasterListRC objectAtIndexPath:indexPath];
            filterItem = [NSPredicate predicateWithFormat:@"itemGroupMaster.groupId == %@",groupMst.groupId];
            break;
        }
    }
    [self.Delegate didSelectMasterInfo:filterItem];
}
#pragma mark - CoreData Methods
- (NSFetchedResultsController *)MMDMasterListRC {
    
    if (_MMDMasterListRC != nil) {
        return _MMDMasterListRC;
    }
    
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:arrMasterEntity[self.selectedMaster] inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    if (_txtSearchText.text.length > 0) {
        NSPredicate * predicate = nil;
        switch (self.selectedMaster) {
            case MasterTypesDepartment: {
                predicate = [NSPredicate predicateWithFormat:@"deptName contains[cd] %@",_txtSearchText.text];
                break;
            }
            case MasterTypesTAG: {
                predicate = [NSPredicate predicateWithFormat:@"sizeName contains[cd] %@",_txtSearchText.text];
                break;
            }
            case MasterTypesGroup: {
                predicate = [NSPredicate predicateWithFormat:@"groupName contains[cd] %@",_txtSearchText.text];
                break;
            }
        }
        if (predicate) {
            fetchRequest.predicate = predicate;
        }
    }
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:arrSortDescriptorKey[self.selectedMaster] ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _MMDMasterListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_MMDMasterListRC performFetch:nil];
    _MMDMasterListRC.delegate = self;
    
    return _MMDMasterListRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.MMDMasterListRC]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblMMDMasterList beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.MMDMasterListRC]) {
        return;
    }
    
    UITableView *tableView = self.tblMMDMasterList;
    
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
    if (![controller isEqual:self.MMDMasterListRC]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblMMDMasterList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblMMDMasterList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.MMDMasterListRC]) {
        return;
    }
    [self.tblMMDMasterList endUpdates];
}
@end
