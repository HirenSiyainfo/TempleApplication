//
//  HItemCatalogVC.m
//  RapidRMS
//
//  Created by Siya on 24/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HItemCatalogVC.h"
#import "HCatalogCustomCell.h"
#import "HItemCategoriesVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Vendor_Item+Dictionary.h"

@interface HItemCatalogVC ()

@property (nonatomic, weak) IBOutlet UIButton *btnProandNew;

@property (nonatomic, weak) IBOutlet UITextField *txtSearchField;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSString *searchText;

@property (nonatomic, strong) NSMutableArray *arrayCatalogList;

@property (nonatomic, assign) BOOL boolisNew;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *catalogResultSetController;

@end

@implementation HItemCatalogVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize isfromItem,strPoID,boolisNew,isFromNewRelease;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *strIsNew = [[NSUserDefaults standardUserDefaults]valueForKey:@"New"];
    if([strIsNew isEqualToString:@"Y"]){
        self.boolisNew=YES;
    }
    else{
        self.boolisNew=NO;
    }
    [self changeNewRelaseButtonStatues];
    _catalogResultSetController=nil;
    [self.tblCatalog reloadData];
}


-(void)changeNewRelaseButtonStatues{
    
    if(self.boolisNew){
        
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : ON" forState:UIControlStateNormal];
        self.btnProandNew.selected=YES;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
    }
    else{
        self.btnProandNew.selected=NO;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : OFF" forState:UIControlStateNormal];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arrayCatalogList = [[NSMutableArray alloc]init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.btnProandNew.layer.cornerRadius=self.btnProandNew.frame.size.height/2;
    self.btnProandNew.layer.masksToBounds=YES;
    self.btnProandNew.layer.borderColor=[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0].CGColor ;
    self.btnProandNew.layer.borderWidth= 1.0f;
    
     NSString  *catalogCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        catalogCell = @"HCatalogCustomCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:catalogCell bundle:nil];
    [self.tblCatalog registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HCatalogCustomCell"];

    if(self.boolisNew){
        
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : ON" forState:UIControlStateNormal];
        self.btnProandNew.selected=YES;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
    }
    else{
        self.btnProandNew.selected=NO;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : OFF" forState:UIControlStateNormal];
    }
    if(self.isFromNewRelease){
        
        self.btnProandNew.hidden = YES;
        
    }
    else{
        self.btnProandNew.hidden = NO;
    }

}

-(IBAction)promotionItems:(id)sender{
    
    if(self.btnProandNew.selected){
        self.btnProandNew.selected=NO;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        boolisNew=NO;
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : OFF" forState:UIControlStateNormal];
        _catalogResultSetController=nil;
        [self.tblCatalog reloadData];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"N" forKey:@"New"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else{
        self.btnProandNew.selected=YES;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
        boolisNew=YES;
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : ON" forState:UIControlStateNormal];
        _catalogResultSetController=nil;
        [self.tblCatalog reloadData];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"Y" forKey:@"New"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}


#pragma mark - Fetch Catalog Section

- (NSFetchedResultsController *)catalogResultSetController {
    
    if (_catalogResultSetController != nil) {
        return _catalogResultSetController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryDescription" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSPredicate *predicate;
    if(self.searchText.length>0)
    {
        predicate = [NSPredicate predicateWithFormat:@"categoryDescription contains[cd] %@",self.searchText];
    }
    else{
        
    }
    fetchRequest.predicate = predicate;
    
    NSPredicate *predicate2;
    
    if(boolisNew)
    {
        predicate2 = [NSPredicate predicateWithFormat:@"isNew = %@ && effectiveDate >= %@", @(1),[NSDate date]];
    }
    else{
        //predicate2 = [NSPredicate predicateWithFormat:@"isNew = %@",@(0)];
    }
    
    if(predicate==nil){
        
        fetchRequest.predicate = predicate2;
    }
    else{
        if (predicate2 != nil) {
            NSPredicate *newpredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate, predicate2]];
            fetchRequest.predicate = newpredicate;
        }
    }
    
    _catalogResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"categoryDescription" cacheName:nil];
    
    [_catalogResultSetController performFetch:nil];
    _catalogResultSetController.delegate = self;
    
    NSArray *sections = self.catalogResultSetController.sections;
    if(sections.count==0)
    {
        return nil;
    }
    return _catalogResultSetController;
}


-(void)createDefaultArray{
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"Department"] = @"Categories";
    
    NSMutableArray *arraySubitem = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *dictTemp =[[NSMutableDictionary alloc]init];
    dictTemp[@"Category"] = @"BULK FOODS";
    dictTemp[@"Products"] = @"759 Products";
    [arraySubitem addObject:dictTemp];
    
    NSMutableDictionary *dictTemp1 =[[NSMutableDictionary alloc]init];
    dictTemp1[@"Category"] = @"DAIRY AND REFRIDGERATED";
    dictTemp1[@"Products"] = @"759 Products";
    [arraySubitem addObject:dictTemp1];

    
    NSMutableDictionary *dictTemp2 =[[NSMutableDictionary alloc]init];
    dictTemp2[@"Category"] = @"FORZON";
     dictTemp2[@"Products"] = @"759 Products";
    [arraySubitem addObject:dictTemp2];

    NSMutableDictionary *dictTemp3 =[[NSMutableDictionary alloc]init];
    dictTemp3[@"Category"] = @"GROSARY & BEVERAGES";
    dictTemp3[@"Products"] = @"759 Products";
    [arraySubitem addObject:dictTemp3];

    
    NSMutableDictionary *dictTemp4 =[[NSMutableDictionary alloc]init];
    dictTemp4[@"Category"] = @"PERSONAL CARE";
    dictTemp4[@"Products"] = @"759 Products";
    [arraySubitem addObject:dictTemp4];
    
    dict[@"SubItem"] = arraySubitem;
    [self.arrayCatalogList addObject:[dict mutableCopy]];
    
    
    NSMutableDictionary *dict1 =[[NSMutableDictionary alloc]init];
    dict1[@"Department"] = @"Brands";
    
    
    NSMutableArray *arraybrand = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *brand1 =[[NSMutableDictionary alloc]init];
    brand1[@"Category"] = @"BRAND 1";
    brand1[@"Products"] = @"759 Products";
    [arraybrand addObject:brand1];
    
    NSMutableDictionary *brand2 =[[NSMutableDictionary alloc]init];
    brand2[@"Category"] = @"BRAND 2";
    brand2[@"Products"] = @"759 Products";
    [arraybrand addObject:brand2];
    
    NSMutableDictionary *brand3 =[[NSMutableDictionary alloc]init];
    brand3[@"Category"] = @"BRAND 3";
    brand3[@"Products"] = @"759 Products";
    [arraybrand addObject:brand3];
    dict1[@"SubItem"] = arraybrand;
    
    [self.arrayCatalogList addObject:[dict1 mutableCopy]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *viewTemp = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 35.0)];
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20.0, 8.0, 320.0, 23.0)];
    lblTitle.text = @"Categories";
    lblTitle.textColor =[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0];
    
    viewTemp.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
     UIView *viewBorder = [[UIView alloc]initWithFrame:CGRectMake(0.0, 34.0, 320.0, 1.0)];
    viewBorder.backgroundColor = [UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0];
    [viewTemp addSubview:viewBorder];
    [viewTemp addSubview:lblTitle];

    return viewTemp;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.catalogResultSetController.sections;
    return sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 58.0;
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
    NSString *cellIdentifier = @"HCatalogCustomCell";
    
    HCatalogCustomCell *catalogCell = (HCatalogCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSArray *sections = self.catalogResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[indexPath.row];

    catalogCell.lblSubName.text=sectionInfo.name;
    catalogCell.lblProducts.text=[NSString stringWithFormat:@"%lu Products", (unsigned long)sectionInfo.numberOfObjects];

    return catalogCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HItemCategoriesVC *hcategories = [storyBoard instantiateViewControllerWithIdentifier:@"HItemCategoriesVC"];
   // hcategories.arrayItemCategoriesList=[[self.arrayCatalogList objectAtIndex:indexPath.row]mutableCopy];
    NSArray *sections = self.catalogResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[indexPath.row];
    hcategories.strCatalog=sectionInfo.name;
    hcategories.isfromItem=self.isfromItem;
    hcategories.strPoID=self.strPoID;
    [self.navigationController pushViewController:hcategories animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField == self.txtSearchField)
    {
        self.searchText=self.txtSearchField.text;
        [self searchCatalogwithPredicate:self.searchText];
    }
    [textField resignFirstResponder];
    return YES;
}
-(void)searchCatalogwithPredicate:(NSString *)searchString{
    
    if(self.txtSearchField.text.length > 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            _catalogResultSetController = nil;
            [self.tblCatalog reloadData];
        });
    }
    else{
        _catalogResultSetController = nil;
        [self.tblCatalog reloadData];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.text.length == 1 && [string isEqualToString:@""]) {
        self.searchText = @"";
    }
    else{
        self.searchText = searchString;
    }
    
    [self searchCatalogwithPredicate:self.searchText];
    
    return YES;
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)doneClick:(id)sender{
    
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
