//
//  HNewRelaseandPromoVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HNewRelaseandPromoVC.h"
#import "HItemProductCell.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Vendor_Item+Dictionary.h"

@interface HNewRelaseandPromoVC ()

@property (nonatomic, weak) IBOutlet UITableView *tblNewandPromo;

@property (nonatomic, weak) IBOutlet UIButton *btnProandNew;

@property (nonatomic, weak) IBOutlet UITextField *txtSearchField;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSString *searchText;

@property (nonatomic, assign) BOOL boolisNew;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *vendorItemResultSetController;

@end

@implementation HNewRelaseandPromoVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize boolisNew;

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
    
    self.btnProandNew.layer.cornerRadius=self.btnProandNew.frame.size.height/2;
    self.btnProandNew.layer.masksToBounds=YES;
    self.btnProandNew.layer.borderColor=[UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0].CGColor ;
    self.btnProandNew.layer.borderWidth= 1.0f;
    
    self.btnProandNew.selected=YES;
    self.btnProandNew.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
    
    NSString  *catalogCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        catalogCell = @"HItemProductCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:catalogCell bundle:nil];
    [self.tblNewandPromo registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HItemProductCell"];
    self.boolisNew=YES;
    [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : ON" forState:UIControlStateNormal];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
//    [self vendorItemResultSetController];
//    
//    [self.tblNewandPromo reloadData];
    
    // Do any additional setup after loading the view.
}

#pragma mark - Fetch All Vendor Item

- (NSFetchedResultsController *)vendorItemResultSetController {
    
    if (_vendorItemResultSetController != nil) {
        return _vendorItemResultSetController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
       // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryDesc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSPredicate *predicate;
    
    if(boolisNew)
    {
        predicate = [NSPredicate predicateWithFormat:@"isNew = %@",@(1)];
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"isNew = %@",@(0)];
    }
    
    NSPredicate *searchPredicate;
    if(self.searchText.length>0)
    {
        searchPredicate  = [NSPredicate predicateWithFormat:@"itemDescription contains[cd] %@",self.searchText];
        NSPredicate *newpredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate, searchPredicate]];
        fetchRequest.predicate = newpredicate;
    }
    else{
        
        NSPredicate *newpredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate]];
        fetchRequest.predicate = newpredicate;
    }
    
    // Create and initialize the fetch results controller.
    _vendorItemResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_vendorItemResultSetController performFetch:nil];
    _vendorItemResultSetController.delegate = self;
    
    return _vendorItemResultSetController;
}

-(IBAction)promotionItems:(id)sender{
    
    if(self.btnProandNew.selected){
        self.btnProandNew.selected=NO;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        boolisNew=NO;
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : OFF" forState:UIControlStateNormal];
        _vendorItemResultSetController=nil;
        [self.tblNewandPromo reloadData];

    }
    else{
        self.btnProandNew.selected=YES;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
        boolisNew=YES;
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : ON" forState:UIControlStateNormal];
        _vendorItemResultSetController=nil;
        [self.tblNewandPromo reloadData];

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.vendorItemResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 90.0;
    
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
    NSString *cellIdentifier = @"HItemProductCell";
    
    HItemProductCell *productCell = (HItemProductCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Vendor_Item *vitem = [self.vendorItemResultSetController objectAtIndexPath:indexPath];
    NSMutableDictionary *vendoritemDict = [vitem.getVendorItemDictionary mutableCopy];
    
    if([[vendoritemDict valueForKey:@"IsNew"]integerValue] == 1){
        
        if([self checkEffectiveDate:[vendoritemDict valueForKey:@"Effective_Date"]]){
         
            productCell.lblEffectiveDate.text = [NSString stringWithFormat:@"Released %@",[self getEffectiveDate:[vendoritemDict valueForKey:@"Effective_Date"]]];
        }

    }
    else{
    
        productCell.lblEffectiveDate.text=@"";
    }
    
    productCell.lblProductName.text=[NSString stringWithFormat:@"%@", [vendoritemDict valueForKey:@"ItemDescriptions"]];
    productCell.lblProducts.text=[NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Pack_UPC"]];
    
    productCell.lblPrice1.text = [self.rmsDbController applyCurrencyFomatter:[vendoritemDict valueForKey:@"Unit_Cost"]];
    
    float caseCost = [[vendoritemDict valueForKey:@"Unit_Cost"]floatValue]*[[vendoritemDict valueForKey:@"CaseUnits"]floatValue];
    
    NSString *strcaseCost = [NSString stringWithFormat:@"%.2f",caseCost];
    
    productCell.lblPrice2.text = [self.rmsDbController applyCurrencyFomatter:strcaseCost];
    
    productCell.lblCashQty.text=[NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"CaseUnits"]];
    productCell.lblUnitQty.text=[NSString stringWithFormat:@"%@",[vendoritemDict valueForKey:@"Size"]];
    
    productCell.lblProducts.text=[NSString stringWithFormat:@"%@ Available",[vendoritemDict valueForKey:@"CaseUnits"]];
    
    return productCell;
}

-(BOOL)checkEffectiveDate:(NSString *)strDate{
    
    BOOL isNew = NO;
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    dateFormatter2.dateFormat = @"dd/mm/yyyy";
    
    NSDate *today = [NSDate date]; // it will give you current date
    NSDate *newDate = [dateFormatter2 dateFromString:strDate]; // your date
    
    NSComparisonResult result;
        result = [today compare:newDate]; // comparing two dates
    
    if(result == NSOrderedAscending)
        isNew = NO;
    else if(result == NSOrderedDescending)

        isNew = YES;
    else
       isNew = YES;
    
    return isNew;
}


-(NSString *)getEffectiveDate:(NSDate *)pDate{

    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    dateFormatter2.dateFormat = @"dd/mm/yyyy";
    NSString *streffectiveDate = [dateFormatter2 stringFromDate:pDate];
    
    return streffectiveDate;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField == self.txtSearchField)
    {
        self.searchText=self.txtSearchField.text;
        [self searchItemwithPredicate:self.searchText];
    }
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.text.length == 1 && [string isEqualToString:@""]) {
        self.searchText = @"";
    }
    else{
        self.searchText =searchString;
    }
    [self searchItemwithPredicate:searchString];
    return YES;
}
-(void)searchItemwithPredicate:(NSString *)searchString{
    
    if(self.txtSearchField.text.length > 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            _vendorItemResultSetController = nil;
            [self.tblNewandPromo reloadData];
        });
    }
    else{
        _vendorItemResultSetController = nil;
        [self.tblNewandPromo reloadData];
    }
}

-(IBAction)gotoHome:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
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
