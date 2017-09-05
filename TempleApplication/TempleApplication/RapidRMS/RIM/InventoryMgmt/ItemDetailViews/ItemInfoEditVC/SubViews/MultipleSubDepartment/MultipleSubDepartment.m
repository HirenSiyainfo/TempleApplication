//
//  DepartmentMultiple.m
//

#import "MultipleSubDepartment.h"
#import "RmsDbController.h"
#import "SubDepartment+Dictionary.h"
#import "AddSubDepartmentVC.h"
#import "ItemInfoEditVC.h"
#import "DepartmentSelectionCell.h"
#import "UITableView+AddBorder.h"

@interface MultipleSubDepartment ()<UITableViewDataSource,UITableViewDelegate,AddSubDepartmentVCDelegate,NSFetchedResultsControllerDelegate> {

    NSInteger IndexSound;
    NSString * strSearchMaster;
    UIColor * colorDefault;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * subDeptResultsController;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView * aTableView;

@property (nonatomic, strong) NSString *selectedSubDeptId;
@property (nonatomic, strong) NSString *selectedSubDeptName;

@property (nonatomic, weak) IBOutlet UITextField * txtMasterName;

@end

@implementation MultipleSubDepartment



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    IndexSound = -1;
    colorDefault = [UIColor blackColor];
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioselected.png"];
    strSearchMaster = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectedSubDeptId = self.strSubDeptId;
    self.selectedSubDeptName = self.strSubDeptName;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


-(IBAction)backToItemView:(id)sender
{
    [self getSelectedDepartmentIds];
    if (IsPhone()) {
        for (UIViewController *viewController in self.navigationController.viewControllers) {
            if ([viewController isKindOfClass:[ItemInfoEditVC class]]) {
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)btnNewSubDeptClicked:(UIButton *)sender
{
     AddSubDepartmentVC *addSubDepartmentVC =
    [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"AddSubDepartmentVC_sid"];
    
    addSubDepartmentVC.addSubDepartmentVCDelegate = self;

    [self presentViewController:addSubDepartmentVC animated:YES completion:nil];
}

-(void)didAddedNewSubDepartment:(NSDictionary *)addedSubDepatmentDict
{
    [self.multipleSubDepartmentDelegate newSubDepartmentSelected:addedSubDepatmentDict];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[ItemInfoEditVC class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}

-(void)getSelectedDepartmentIds
{
    if(IndexSound == -1)
    {
        // set sub department id and name to global variable
        self.objAddDelegate.itemInfoDataObject.SubDepartId = @0;
        self.objAddDelegate.itemInfoDataObject.SubDepartmentName = @"";
        self.selectedSubDeptName = @"";
    }
    else
    {
        self.objAddDelegate.itemInfoDataObject.SubDepartId = @(self.selectedSubDeptId.intValue);
        self.objAddDelegate.itemInfoDataObject.SubDepartmentName = self.selectedSubDeptName;
        // set sub department names with main deparment
    }
}

- (IBAction)backToDepartmentView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate -

- (void)textFieldDidEndEditing:(UITextField *)textField {
    strSearchMaster = textField.text;
    [self reloadeMasterList];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    strSearchMaster = @"";
    [self reloadeMasterList];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    strSearchMaster = textField.text;
    [self reloadeMasterList];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {   // return NO to not change text
    if (_subDeptResultsController.fetchedObjects.count > 0) {
        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.aTableView scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
    strSearchMaster = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self reloadeMasterList];
    return YES;
}

-(IBAction)btnreloadeMasterList:(id)sender {
    [self.txtMasterName resignFirstResponder];
}
-(void)reloadeMasterList{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _subDeptResultsController = nil;
        [self.aTableView reloadData];
    });
}

-(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:messageTitle message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}


#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sections = self.subDeptResultsController.sections;
    return sections.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.subDeptResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DepartmentSelectionCell * cell=(DepartmentSelectionCell *)[self.aTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[DepartmentSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
		
    SubDepartment * subDeptInfo = [self.subDeptResultsController objectAtIndexPath:indexPath];
    NSDictionary * dictSubDeptInfo = [self getSubDeptDictFrom:subDeptInfo];
	cell.lblDeptName.text = [NSString stringWithFormat:@"%@",[dictSubDeptInfo valueForKey:@"SubDepartmentName"]];


    if (IndexSound == indexPath.row) {
        cell.imgIsSelected.image = imgSelected;
        cell.lblDeptName.textColor = colorSelected;
    }
    else {
        NSString *subDeptID = [NSString stringWithFormat:@"%@",[dictSubDeptInfo valueForKey:@"SubDeptId"]];
        if([subDeptID isEqualToString:self.selectedSubDeptId]) {
            IndexSound = indexPath.row;
            cell.imgIsSelected.image = imgSelected;
            cell.lblDeptName.textColor = colorSelected;
        }
        else {
            cell.imgIsSelected.image = imgDefault;
            cell.lblDeptName.textColor = colorDefault;
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IndexSound = indexPath.row;
    NSMutableDictionary * dictSubDeptInfo=[[NSMutableDictionary alloc]init];
    SubDepartment * subDeptInfo = [self.subDeptResultsController objectAtIndexPath:indexPath];
    NSDictionary * dictSelSubDeptInfo = [self getSubDeptDictFrom:subDeptInfo];
    if([[dictSelSubDeptInfo valueForKey:@"SubDeptId"] integerValue] == 0)
    {
        self.selectedSubDeptName = @"";
        self.selectedSubDeptId = @"";
        
        dictSubDeptInfo[@"SubDeptId"] = self.selectedSubDeptId;
        dictSubDeptInfo[@"SubDepartmentName"] = self.selectedSubDeptName;
    }
    else
    {
        IndexSound = indexPath.row;
        dictSubDeptInfo = [[NSMutableDictionary alloc]initWithDictionary:dictSelSubDeptInfo];
        self.selectedSubDeptName = [dictSelSubDeptInfo valueForKey:@"SubDepartmentName"];
        self.selectedSubDeptId = [NSString stringWithFormat:@"%@",[dictSelSubDeptInfo valueForKey:@"SubDeptId"]];
    }
    [self.multipleSubDepartmentDelegate didChangeSubSelectedDepartment:dictSubDeptInfo];
    [self.aTableView reloadData];}

#pragma mark -
#pragma mark Logic Implement

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
-(NSDictionary *)getSubDeptDictFrom:(SubDepartment *)objSubDept{
    NSMutableDictionary * dictSubDeptInfo = [[NSMutableDictionary alloc]init];
    dictSubDeptInfo[@"SubDeptId"] = objSubDept.brnSubDeptID;
    dictSubDeptInfo[@"SubDepartmentName"] = objSubDept.subDeptName;
    return dictSubDeptInfo;
}
- (NSFetchedResultsController *)subDeptResultsController {
    
    if (_subDeptResultsController != nil) {
        return _subDeptResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubDepartment" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"subDeptName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    if (strSearchMaster.length > 0) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"subDeptName LIKE[cd] %@",[NSString stringWithFormat:@"*%@*",strSearchMaster]];
    }
    
    if ([UpdateManager countForContext:_managedObjectContext FetchRequest:fetchRequest] == 0) {
        fetchRequest.predicate = nil;
        [self showMessageOfChangePriceTitle:@"Item Management" withMessage:[NSString stringWithFormat:@"No Record Found for %@",strSearchMaster]];
        strSearchMaster = @"";
        _txtMasterName.text = @"";
    }
    _subDeptResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [_subDeptResultsController performFetch:nil];
    _subDeptResultsController.delegate = self;
    return _subDeptResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.subDeptResultsController]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.aTableView beginUpdates];
}

#pragma mark - CoreData Delegate -
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.subDeptResultsController]) {
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
    if (![controller isEqual:self.subDeptResultsController]) {
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
    if (![controller isEqual:self.subDeptResultsController]) {
        return;
    }
    [self.aTableView endUpdates];
}
@end
