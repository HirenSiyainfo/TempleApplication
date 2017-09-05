//
//  HReportsVC.m
//  RapidRMS
//
//  Created by Siya on 26/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HReportsVC.h"
#import "SACalendar.h"
#import "DateUtil.h"
#import "HReportGraphsVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Vendor_Item+Dictionary.h"

@interface HReportsVC ()<SACalendarDelegate>

@property (nonatomic, weak) IBOutlet UIView *viewCategory;
@property (nonatomic, weak) IBOutlet UIView *viewDateView;
@property (nonatomic, weak) IBOutlet UIView *viewDateContainer;

@property (nonatomic, weak) IBOutlet UIButton *btnDateRange;
@property (nonatomic, weak) IBOutlet UIButton *btnCategory;

@property (nonatomic, weak) IBOutlet UITextField *txtFrom;
@property (nonatomic, weak) IBOutlet UITextField *txtTo;

@property (nonatomic, weak) IBOutlet UITableView *tblCategoryView;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSString *strDeptName;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *departmentResultSetController;

@end

@implementation HReportsVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize strDeptName;


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
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    
    self.btnCategory.layer.cornerRadius=5.0;
    self.btnCategory.layer.masksToBounds=YES;
    self.btnCategory.layer.borderColor=[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0].CGColor ;
    self.btnCategory.layer.borderWidth= 1.0f;
    
    
    self.btnDateRange.layer.cornerRadius=5.0;
    self.btnDateRange.layer.masksToBounds=YES;
    self.btnDateRange.layer.borderColor=[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0].CGColor ;
    self.btnDateRange.layer.borderWidth= 1.0f;
    
    [self.viewCategory setHidden:YES];
    [self.viewDateView setHidden:YES];
    
    
    [self loadDateView];
    
//    [self departmentResultSetController];
    // Do any additional setup after loading the view.
}

#pragma mark - Fetch Catalog Section

- (NSFetchedResultsController *)departmentResultSetController {
    
    if (_departmentResultSetController != nil) {
        return _departmentResultSetController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryDescription" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _departmentResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"categoryDescription" cacheName:nil];
    
    [_departmentResultSetController performFetch:nil];
    _departmentResultSetController.delegate = self;
    
    NSArray *sections = self.departmentResultSetController.sections;
    if(sections.count==0)
    {
        return nil;
    }
    return _departmentResultSetController;

}




-(void)loadDateView{

    SACalendar *calendar = [[SACalendar alloc]initWithFrame:CGRectMake(1.0, 29.0, 290, 340)
                                            scrollDirection:ScrollDirectionVertical
                                              pagingEnabled:YES];



    calendar.delegate = self;
    
    [self.viewDateContainer addSubview:calendar];

}
-(IBAction)gotoHome:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  Delegate method : get called when a date is selected
 */
-(void) SACalendar:(SACalendar*)calendar didSelectDate:(int)day month:(int)month year:(int)year
{
    if([self.txtFrom.text isEqualToString:@""]){
        NSString *strDate = [NSString stringWithFormat:@"%d/%d/%d",month,day,year];
        self.txtFrom.text=strDate;
        
    }
    else{
        NSString *strDate = [NSString stringWithFormat:@"%d/%d/%d",month,day,year];
        self.txtTo.text=strDate;
    }
}

/**
 *  Delegate method : get called user has scroll to a new month
 */
-(void) SACalendar:(SACalendar *)calendar didDisplayCalendarForMonth:(int)month year:(int)year{
}

-(IBAction)viewCategoryClick:(id)sender{
    
    [self.viewCategory setHidden:NO];
    [self.viewDateView setHidden:YES];
}
-(IBAction)viewDateRangeClick:(id)sender{
    
    [self.viewCategory setHidden:YES];
    [self.viewDateView setHidden:NO];
}
#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.departmentResultSetController.sections;
    return sections.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;

    cell.backgroundColor=[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
    NSArray *sections = self.departmentResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[indexPath.row];
     cell.textLabel.text=sectionInfo.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSArray *sections = self.departmentResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[indexPath.row];
    strDeptName=sectionInfo.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)hideCategoryView:(id)sender{
    
     [self.viewCategory setHidden:YES];
}

-(IBAction)hideDateView:(id)sender{
    
    [self.viewDateView setHidden:YES];
}

-(IBAction)categoryviewOk:(id)sender{
    
    if(strDeptName!=nil){
        [_btnCategory setTitle:strDeptName forState:UIControlStateNormal];
    }
    [_viewCategory setHidden:YES];

//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//    HReportGraphsVC *hreportGraph = [storyBoard instantiateViewControllerWithIdentifier:@"HReportGraphsVC"];
//    [self.navigationController pushViewController:hreportGraph animated:YES];
}

-(IBAction)dateviewviewOk:(id)sender{
    
    NSString *strFromdate = _txtFrom.text;
    NSString *strTodate = _txtTo.text;
    [_btnDateRange setTitle:[NSString stringWithFormat:@"%@ - %@",strFromdate,strTodate] forState:UIControlStateNormal];
    [_viewDateView setHidden:YES];
    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//    HReportGraphsVC *hreportGraph = [storyBoard instantiateViewControllerWithIdentifier:@"HReportGraphsVC"];
//    [self.navigationController pushViewController:hreportGraph animated:YES];
}
-(IBAction)btnOk:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HReportGraphsVC *hreportGraph = [storyBoard instantiateViewControllerWithIdentifier:@"HReportGraphsVC"];
    [self.navigationController pushViewController:hreportGraph animated:YES];
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
