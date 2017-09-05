//
//  MMDiscountListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 19/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDiscountListVC.h"
#import "RmsDbController.h"
#import "MMDAddDiscountTypeVC.h"
#import "MMDListCell.h"
#import "Discount_M.h"

@interface MMDiscountListVC ()<NSFetchedResultsControllerDelegate,MMDListCellDelegate>


@property (nonatomic, strong) NSFetchedResultsController * MMDiscountListRC;
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) RapidWebServiceConnection * itemDeleteWSC;
@property (nonatomic, strong) RapidWebServiceConnection * itemStatusWSC;
@property (nonatomic, strong) RmsDbController * rmsDbController;


@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, weak) IBOutlet UITableView * tblMMDiscountList;
@end

@implementation MMDiscountListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.itemDeleteWSC = [[RapidWebServiceConnection alloc]init];
    self.itemStatusWSC = [[RapidWebServiceConnection alloc]init];
    self.tblMMDiscountList.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions -
-(IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnAddDiscounttapped:(id)sender {
    [self loadMMDDetailViews:nil];
}

-(void)loadMMDDetailViews:(Discount_M *)objMixMatch{
    NSManagedObjectContext * moc = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    
    MMDAddDiscountTypeVC * mMDAddDiscountTypeVC =
    [[UIStoryboard storyboardWithName:@"MMDiscount"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDAddDiscountTypeVC_sid"];
    
    mMDAddDiscountTypeVC.moc = moc;
    if (objMixMatch) {
        mMDAddDiscountTypeVC.objMixMatch = (Discount_M *)[moc objectWithID:objMixMatch.objectID];
    }
    else {
        mMDAddDiscountTypeVC.objMixMatch = [NSEntityDescription insertNewObjectForEntityForName:@"Discount_M" inManagedObjectContext:moc];
        [mMDAddDiscountTypeVC.objMixMatch updateDiscountFromDictionary:nil];
    }
    [self.navigationController pushViewController:mMDAddDiscountTypeVC animated:YES];
}
#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.

    NSArray *sections = self.MMDiscountListRC.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = self.MMDiscountListRC.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMDListCell *cell = (MMDListCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Discount_M *objDiscount = [self.MMDiscountListRC objectAtIndexPath:indexPath];
    cell.tableView = tableView;
    cell.Delegate = self;
    cell.lbltitle.text = objDiscount.name;
    cell.lblName.text = objDiscount.descriptionText;
    [cell.swiStatus setOn:objDiscount.isStatus.boolValue animated:YES];
    
    if (objDiscount.endDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy";
        cell.lblEndDate.text = [formatter stringFromDate:objDiscount.endDate];
    }
    else {
        cell.lblEndDate.text = @"Never Expires";
    }
    NSString * strCatagory;
    
    NSArray * arrPrimary = [objDiscount.primaryItems.allObjects valueForKey:@"itemType"];
    NSArray * arrSecondary = [objDiscount.secondaryItems.allObjects valueForKey:@"itemType"];
    
    if (objDiscount.discountType.integerValue == 1) {
        strCatagory = [NSString stringWithFormat:@"%@",[self genrateCatagoryStrinfFrom:arrPrimary]];
    }
    else {
        NSString *genrateCatagoryStrinfFrom = [NSString stringWithFormat:@"X %@ \n",[self genrateCatagoryStrinfFrom:arrPrimary]];
        genrateCatagoryStrinfFrom = [genrateCatagoryStrinfFrom stringByAppendingString:[NSString stringWithFormat:@"Y %@",[self genrateCatagoryStrinfFrom:arrSecondary]]];

        NSAttributedString * strAcatagory = [[NSAttributedString alloc]initWithString:genrateCatagoryStrinfFrom];
        strCatagory = strAcatagory.string;
    }
    cell.lblCategary.text = strCatagory;
    return cell;
}
-(NSString *)genrateCatagoryStrinfFrom:(NSArray *)arrList {
    arrList = [NSSet setWithArray:arrList].allObjects;
    NSMutableArray *sortedNumbers = [[arrList sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    NSArray * arrCatagary = @[@(1),@(2),@(3),@(4)];
    NSArray * arrCatagaryName = @[@"Item",@"Group",@"Tag",@"Department"];
        
    for (int i = 0; i < arrCatagary.count;i++) {
        NSString * strName = arrCatagary[i];
        if ([sortedNumbers containsObject:strName]) {
            int index = (int)[sortedNumbers indexOfObject:strName];
            sortedNumbers[index] = arrCatagaryName[i];
        }
    }
    return [sortedNumbers componentsJoinedByString:@", "];
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Discount_M *mmdItem = [self.MMDiscountListRC objectAtIndexPath:indexPath];
    [self loadMMDDetailViews:mmdItem];
}

#pragma mark - Change Status Edit Delete -

-(void)willEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Discount_M *mmdItem = [self.MMDiscountListRC objectAtIndexPath:indexPath];
    [self loadMMDDetailViews:mmdItem];
}

-(void)willDeleteRowAtIndexPath:(NSIndexPath *)indexPath {

    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action) {
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        Discount_M *mmdItem = [self.MMDiscountListRC objectAtIndexPath:indexPath];
        [self deleteDiscountInfo:mmdItem];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:@"Are you sure you want to delete this discount?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)deleteDiscountInfo:(Discount_M *)objDiscount{

    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    itemparam[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    itemparam[@"DiscountId"] = objDiscount.discountId.stringValue;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self itemDeleteResponce:response error:error withDiscount:objDiscount];
        });
    };
    self.itemDeleteWSC = [self.itemDeleteWSC initWithRequest:KURL actionName:WSM_MMD_ITEM_DELETE params:itemparam completionHandler:completionHandler];
    
}
-(void)itemDeleteResponce:(id)response error:(NSError *)error  withDiscount:(Discount_M *) discount {
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                NSManagedObjectContext * privateMOC = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                [privateMOC deleteObject:[privateMOC objectWithID:discount.objectID]];
                [UpdateManager saveContext:privateMOC];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(void)willChangeStatusRowAtIndexPath:(NSIndexPath *)indexPath  withNewStatus:(BOOL) isStatus {
    
    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action) {
        [self.tblMMDiscountList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        Discount_M *mmdItem = [self.MMDiscountListRC objectAtIndexPath:indexPath];
        [self changeStatusDiscountInfo:mmdItem withNewStatus:isStatus];
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:@"Are you sure you want to change status ?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
}

-(void)changeStatusDiscountInfo:(Discount_M *)objDiscount withNewStatus:(BOOL) isStatus{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam = [[NSMutableDictionary alloc]init];
    itemparam[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    itemparam[@"DiscountId"] = objDiscount.discountId.stringValue;
    itemparam[@"IsStatus"] = @(isStatus);
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self itemChangeStatusResponse:response error:error withDiscount:objDiscount newStatus:isStatus];
        });
    };
    
    self.itemStatusWSC = [self.itemStatusWSC initWithRequest:KURL actionName:WSM_MMD_ITEM_STATUS params:itemparam completionHandler:completionHandler];
    
}
-(void)itemChangeStatusResponse:(id)response error:(NSError *)error withDiscount:(Discount_M *) discount newStatus:(BOOL) isStatus{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                discount.isStatus = @(isStatus);
                
                NSManagedObjectContext * privateMOC = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
                Discount_M * privateDiscount = [privateMOC objectWithID:discount.objectID];
                privateDiscount.isStatus = @(isStatus);
                [UpdateManager saveContext:privateMOC];
            }
            else {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Discount" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

#pragma mark - CoreData Methods -
- (NSFetchedResultsController *)MMDiscountListRC {
    
    if (_MMDiscountListRC != nil) {
        return _MMDiscountListRC;
    }
    
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Discount_M" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isDelete == %@ AND discountType != %d",@(0),4];

    fetchRequest.predicate = predicate;

    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _MMDiscountListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_MMDiscountListRC performFetch:nil];
    _MMDiscountListRC.delegate = self;
    
    return _MMDiscountListRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.MMDiscountListRC]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblMMDiscountList beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.MMDiscountListRC]) {
        return;
    }
    
    UITableView *tableView = self.tblMMDiscountList;
    
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
    if (![controller isEqual:self.MMDiscountListRC]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblMMDiscountList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblMMDiscountList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.MMDiscountListRC]) {
        return;
    }
    [self.tblMMDiscountList endUpdates];
}

@end
