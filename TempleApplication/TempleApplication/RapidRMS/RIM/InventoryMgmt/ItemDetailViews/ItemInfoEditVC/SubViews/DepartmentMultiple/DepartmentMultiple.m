//
//  DepartmentMultiple.m
//

#import "Department+Dictionary.h"
#import "DepartmentMultiple.h"
#import "DepartmentSelectionCell.h"
#import "RmsDbController.h"
#import "UITableView+AddBorder.h"


@interface DepartmentMultiple ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIColor * colorDefault;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;

}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * deptResultsController;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView * aTableView;

@end

@implementation DepartmentMultiple
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    colorDefault = [UIColor blackColor];
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioselected.png"];

    
    if(self.checkedDepartment.count == 0){
        
        self.checkedDepartment = [[NSMutableArray alloc]init];
        NSMutableDictionary *checkDept=[[NSMutableDictionary alloc]init];
        checkDept[@"DepartmentName"] = @"None";
        checkDept[@"DeptId"] = @"0";
        checkDept[@"ItemCode"] = @"0";
        [self.checkedDepartment insertObject:checkDept atIndex:0];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction) toolBarActionHandler:(id)sender {
    NSMutableDictionary *checkDept=[[NSMutableDictionary alloc]init];
    checkDept[@"DepartmentName"] = @"None";
    checkDept[@"DeptId"] = @"0";
    checkDept[@"ItemCode"] = @"0";
    [self.checkedDepartment removeObject:checkDept];
    [self.addDepartmentMultipleDelegate didselectDepartment:[self.checkedDepartment mutableCopy]];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.view.superview){
        [self.view removeFromSuperview];
    }
}

#pragma mark - UITableView delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *sections = self.deptResultsController.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = self.deptResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DepartmentSelectionCell * cell=(DepartmentSelectionCell *)[self.aTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[DepartmentSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Department *dept = [self.deptResultsController objectAtIndexPath:indexPath];
    NSDictionary *departmentDictionary = [self getDeptDictFrom:dept];
    
    if([[departmentDictionary valueForKey:@"isNotApplyInItem"] integerValue ] == 1)
    {
        cell.userInteractionEnabled = NO;
        cell.lblDoNotApply.hidden = FALSE;
        cell.imgIsSelected.hidden = TRUE;
    }
    else
    {
        cell.userInteractionEnabled = YES;
        cell.lblDoNotApply.hidden = TRUE;
        cell.imgIsSelected.hidden = FALSE;
    }
    cell.lblDeptName.text = [NSString stringWithFormat:@"%@",[departmentDictionary valueForKey:@"DepartmentName"]];
    cell.lblDeptName.textColor = colorDefault;
    cell.imgIsSelected.image = imgDefault;
    
    if ([self.checkedDepartment containsObject:departmentDictionary]) {
        cell.lblDeptName.textColor = colorSelected;
        cell.imgIsSelected.image = imgSelected;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Department * objDeptInfo = [self.deptResultsController objectAtIndexPath:indexPath];
    NSDictionary * dictDeptInfo = [self getDeptDictFrom:objDeptInfo];
    if(!([[dictDeptInfo valueForKey:@"isNotApplyInItem"] integerValue ] == 1)) {
        if (!self.isMultipleAllow) {
            
            [self removeAllSelected];
        }
        Department * objDeptInfo = [self.deptResultsController objectAtIndexPath:indexPath];
        NSDictionary * dictDeptInfo = [self getDeptDictFrom:objDeptInfo];
        if ([self.checkedDepartment containsObject:dictDeptInfo]) {
            [self.checkedDepartment removeObject:dictDeptInfo];
        }
        else {
            [self.checkedDepartment addObject:dictDeptInfo];
        }
        [tableView reloadData];
    }
}
-(void)removeAllSelected {
    [self.checkedDepartment removeAllObjects];
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
#pragma mark - CoreData Methods
-(NSDictionary *)getDeptDictFrom:(Department *)objDept{
    NSMutableDictionary * dictDeptInfo = [[NSMutableDictionary alloc]init];
    dictDeptInfo[@"DepartmentName"] = objDept.deptName;
    dictDeptInfo[@"DeptId"] = objDept.deptId;
    dictDeptInfo[@"isNotApplyInItem"] = objDept.isNotApplyInItem;
    return dictDeptInfo;
}
- (NSFetchedResultsController *)deptResultsController {
    
    if (_deptResultsController != nil) {
        return _deptResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isNotDisplay != %@",@(1)];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deptName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _deptResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [_deptResultsController performFetch:nil];
    _deptResultsController.delegate = self;
    return _deptResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.deptResultsController]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.aTableView beginUpdates];
}

#pragma mark - CoreData Delegate -
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.deptResultsController]) {
        return;
    }
    
    UITableView *tableView = self.aTableView;
    
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
    if (![controller isEqual:self.deptResultsController]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.aTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.aTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.deptResultsController]) {
        return;
    }
    [self.aTableView endUpdates];
}
@end
