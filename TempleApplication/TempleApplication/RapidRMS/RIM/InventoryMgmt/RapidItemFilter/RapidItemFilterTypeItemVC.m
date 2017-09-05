//
//  RapidItemFilterTypeItemVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 07/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RapidItemFilterTypeItemVC.h"
#import "RmsDbController.h"
#import "Department+Dictionary.h"
#import "SubDepartment+Dictionary.h"
#import "GroupMaster+Dictionary.h"
#import "SizeMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "RapidFilterMasterTypeCell.h"

@interface RapidItemFilterTypeItemVC ()<NSFetchedResultsControllerDelegate> {
    NSArray * arrMasterEntity;
    NSArray * arrSortDescriptorKey;
}

@property (nonatomic, strong) NSFetchedResultsController * masterListRC;
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

@end

@implementation RapidItemFilterTypeItemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    arrMasterTitle = @[@"Department",@"Sub-Department",@"Vendor",@"Group",@"Tag",@"Searched Items",@"Categories"];
    arrMasterEntity = @[@"Department",@"SubDepartment",@"SupplierCompany",@"GroupMaster",@"SizeMaster",@"",@"SizeMaster"];
    arrSortDescriptorKey = @[@"deptName",@"subDeptName",@"companyName",@"groupName",@"sizeName",@"",@"sizeName"];
    
    self.managedObjectContext = [RmsDbController sharedRmsDbController].managedObjectContext;
    if (!self.arrFilterTypesSelectedItems) {
        self.arrFilterTypesSelectedItems = [[NSMutableArray alloc]init];
    }
    [self.txtSearchText setValue:[UIColor whiteColor]
                    forKeyPath:@"_placeholderLabel.textColor"];

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lblMasterTitle.text = [NSString stringWithFormat:@"%@",[arrMasterTitle[self.filterType] uppercaseString]];
    self.lblMasterCount.text = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)self.arrFilterTypesSelectedItems.count,(unsigned long)self.masterListRC.fetchedObjects.count];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#ifdef IS_CLICK_TO_SEARCH
-(void)setArrFilterTypesSelectedItems:(NSMutableArray *)arrFilterTypesSelectedItems {
    _arrFilterTypesSelectedItems = arrFilterTypesSelectedItems;
    if (arrMasterEntity && arrSortDescriptorKey) {
        self.lblMasterCount.text = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)self.arrFilterTypesSelectedItems.count,(unsigned long)[self.masterListRC fetchedObjects].count];
        [self.tblMasterList reloadData];
    }
}
#endif
//-(void)setFilterType:(RapidItemFilterType)filterType {
//    _filterType = filterType;
//    self.masterListRC = nil;
//}
#pragma mark - IBAction -
-(IBAction)btnSearchTapped:(UIButton *)sender {
    [self.txtSearchText resignFirstResponder];
}
-(IBAction)btnBackTapped:(UIButton *)sender {
#ifndef IS_CLICK_TO_SEARCH
    if ([self.deledate respondsToSelector:@selector(willChangeSelectedFilterTypeItem:withFilterType:)]) {
        [self.deledate willChangeSelectedFilterTypeItem:self.arrFilterTypesSelectedItems withFilterType:self.filterType];
    }

#endif
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnApplyTapped:(UIButton *)sender {
    if ([self.deledate respondsToSelector:@selector(willChangeSelectedFilterTypeItem:withFilterType:)]) {
        [self.deledate willChangeSelectedFilterTypeItem:self.arrFilterTypesSelectedItems withFilterType:self.filterType];
    }
    if ([self.deledate respondsToSelector:@selector(willApplyFilter)]) {
        [self.deledate willApplyFilter];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITextFieldDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.masterListRC = nil;
    [self.tblMasterList reloadData];
    return NO;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    NSArray *sections = self.masterListRC.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = self.masterListRC.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RapidFilterMasterTypeCell *cell = (RapidFilterMasterTypeCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    switch (self.filterType) {
        case RapidItemFilterTypeDepartment: {
            [self configureDepartmentCell:cell rowAtIndexPath:indexPath];
            break;
        }
        case RapidItemFilterTypeSubDepartment: {
            [self configureSubDepartmentCell:cell rowAtIndexPath:indexPath];
            break;
        }
        case RapidItemFilterTypeVendor: {
            [self configureVendorCell:cell rowAtIndexPath:indexPath];
            break;
        }
        case RapidItemFilterTypeGroup: {
            [self configureGroupCell:cell rowAtIndexPath:indexPath];
            break;
        }
        case RapidItemFilterTypeTag: {
            [self configureTagCell:cell rowAtIndexPath:indexPath];
            break;
        }
        case RapidItemFilterTypeSearchedItem: {
            
            break;
        }
        case RapidItemFilterTypeCategories: {
            [self configureTagCell:cell rowAtIndexPath:indexPath];

            break;
        }
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    id objMasterInfo = [self getDictionaryFrom:[self.masterListRC objectAtIndexPath:indexPath]];
    if ([self.arrFilterTypesSelectedItems containsObject:objMasterInfo]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];
        cell.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];
    }
    return cell;
}
-(void)configureDepartmentCell:(RapidFilterMasterTypeCell *)cell rowAtIndexPath:(NSIndexPath *)indexPath {
    Department * objDeptInfo = [self.masterListRC objectAtIndexPath:indexPath];
    cell.lblTitle.text = objDeptInfo.deptName;
}
-(void)configureSubDepartmentCell:(RapidFilterMasterTypeCell *)cell rowAtIndexPath:(NSIndexPath *)indexPath {
    SubDepartment * objDeptInfo = [self.masterListRC objectAtIndexPath:indexPath];
    cell.lblTitle.text = objDeptInfo.subDeptName;
}
-(void)configureVendorCell:(RapidFilterMasterTypeCell *)cell rowAtIndexPath:(NSIndexPath *)indexPath {
    SupplierCompany * objVendorInfo = [self.masterListRC objectAtIndexPath:indexPath];
    cell.lblTitle.text = objVendorInfo.companyName;
}
-(void)configureGroupCell:(RapidFilterMasterTypeCell *)cell rowAtIndexPath:(NSIndexPath *)indexPath {
    GroupMaster * objGroupInfo = [self.masterListRC objectAtIndexPath:indexPath];
    cell.lblTitle.text = objGroupInfo.groupName;
}
-(void)configureTagCell:(RapidFilterMasterTypeCell *)cell rowAtIndexPath:(NSIndexPath *)indexPath {
    SizeMaster * objSizeInfo = [self.masterListRC objectAtIndexPath:indexPath];
    cell.lblTitle.text = objSizeInfo.sizeName;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    id objMasterInfo = [self getDictionaryFrom:[self.masterListRC objectAtIndexPath:indexPath]];
    if ([self.arrFilterTypesSelectedItems containsObject:objMasterInfo]) {
        [self.arrFilterTypesSelectedItems removeObject:objMasterInfo];
    }
    else {
        [self.arrFilterTypesSelectedItems addObject:objMasterInfo];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.lblMasterCount.text = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)self.arrFilterTypesSelectedItems.count,(unsigned long)self.masterListRC.fetchedObjects.count];
#ifdef IS_CLICK_TO_SEARCH
    if ([self.deledate respondsToSelector:@selector(willChangeSelectedFilterTypeItem:withFilterType:)]) {
        [self.deledate willChangeSelectedFilterTypeItem:self.arrFilterTypesSelectedItems withFilterType:self.filterType];
    }
#endif
}
-(NSDictionary *)getDictionaryFrom:(id)object {
    NSMutableDictionary * dictObjectInfo = [[NSMutableDictionary alloc]init];
    NSString * strName = @"";
    id objectToSet = nil;
    
    switch (self.filterType) {
        case RapidItemFilterTypeDepartment: {
            Department * objInfo = (Department *)object;
            strName = objInfo.deptName;
            objectToSet = objInfo.deptId;
            break;
        }
        case RapidItemFilterTypeSubDepartment: {
            SubDepartment * objSubInfo = (SubDepartment *)object;
            strName = objSubInfo.subDeptName;
            objectToSet = objSubInfo.brnSubDeptID;
            break;
        }
        case RapidItemFilterTypeVendor: {
            SupplierCompany * objSuppInfo = (SupplierCompany *)object;
            strName = objSuppInfo.companyName;
            objectToSet = objSuppInfo.companyId;
            break;
        }
        case RapidItemFilterTypeGroup: {
            GroupMaster * objGroupInfo = (GroupMaster *)object;
            strName = objGroupInfo.groupName;
            objectToSet = objGroupInfo.groupId;
            break;
        }
        case RapidItemFilterTypeTag: {
            SizeMaster * objTagInfo = (SizeMaster *)object;
            strName = objTagInfo.sizeName;
            objectToSet = objTagInfo.sizeId;

            break;
        }
        case RapidItemFilterTypeSearchedItem: {
            
            break;
        }
        case RapidItemFilterTypeCategories: {
            SizeMaster * objTagInfo = (SizeMaster *)object;
            strName = objTagInfo.sizeName;
            objectToSet = objTagInfo.sizeId;

            break;
        }
    }
    dictObjectInfo[@"name"] = strName;
//    if (!objectToSet) {
        dictObjectInfo[@"object"] = objectToSet;
//    }
    return dictObjectInfo;
}
#pragma mark - CoreData Methods
- (NSFetchedResultsController *) masterListRC {
    
    if (_masterListRC != nil) {
        return _masterListRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:arrMasterEntity[self.filterType] inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];

    if (self.txtSearchText.text.length > 0) {
        NSPredicate * predicate = nil;
        switch (self.filterType) {
            case RapidItemFilterTypeDepartment: {
                predicate = [NSPredicate predicateWithFormat:@"deptName contains[cd] %@",self.txtSearchText.text];
                break;
            }
            case RapidItemFilterTypeSubDepartment: {
                predicate = [NSPredicate predicateWithFormat:@"subDeptName contains[cd] %@",self.txtSearchText.text];

                break;
            }
            case RapidItemFilterTypeVendor: {
                predicate = [NSPredicate predicateWithFormat:@"companyName contains[cd] %@",self.txtSearchText.text];
                break;
            }
            case RapidItemFilterTypeGroup: {
                predicate = [NSPredicate predicateWithFormat:@"groupName contains[cd] %@",self.txtSearchText.text];
                break;
            }
            case RapidItemFilterTypeTag: {
                predicate = [NSPredicate predicateWithFormat:@"sizeName contains[cd] %@",self.txtSearchText.text];
                break;
            }
            case RapidItemFilterTypeSearchedItem: {
                
                break;
            }
            case RapidItemFilterTypeCategories: {
                predicate = [NSPredicate predicateWithFormat:@"sizeName contains[cd] %@",self.txtSearchText.text];
                break;
            }
        }
        if (predicate) {
            [fieldWisePredicates addObject:predicate];
        }
    }
//    if (self.filterType == RapidItemFilterTypeTag) {
//        NSPredicate * subpredicate = [NSPredicate predicateWithFormat:@"sizeName BEGINSWITH[cd] %@",@"#"];
//        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
//        [fieldWisePredicates addObject:[NSCompoundPredicate notPredicateWithSubpredicate:subpredicate]];
//        
//        finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
//        [fetchRequest setPredicate:finalPredicate];
//    }
//    else if (self.filterType == RapidItemFilterTypeCategories){
//        NSPredicate * subpredicate = [NSPredicate predicateWithFormat:@"sizeName BEGINSWITH[cd] %@",@"#"];
//        [fieldWisePredicates addObject:subpredicate];
//        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
//        [fetchRequest setPredicate:finalPredicate];
//
//    }
    if (self.filterType == RapidItemFilterTypeDepartment) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isNotDisplay != %@",@(1)];
        [fieldWisePredicates addObject:predicate];
    }
    
    if (fieldWisePredicates.count > 0) {
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
        fetchRequest.predicate = finalPredicate;
    }
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:arrSortDescriptorKey[self.filterType] ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _masterListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_masterListRC performFetch:nil];
    _masterListRC.delegate = self;
    
    return _masterListRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.masterListRC]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblMasterList beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.masterListRC]) {
        return;
    }
    
    UITableView *tableView = self.tblMasterList;
    
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
    if (![controller isEqual:self.masterListRC]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblMasterList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblMasterList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.masterListRC]) {
        return;
    }
    [self.tblMasterList endUpdates];
}
@end
