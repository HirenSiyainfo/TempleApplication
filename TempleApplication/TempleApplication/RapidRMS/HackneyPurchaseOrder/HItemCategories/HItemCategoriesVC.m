//
//  HItemCategoriesVC.m
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "HItemCategoriesVC.h"
#import "HCatalogCustomCell.h"
#import "HItemProductVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Vendor_Item+Dictionary.h"

@interface HItemCategoriesVC ()

@property (nonatomic, weak) IBOutlet UIButton *btnProandNew;

@property (nonatomic, weak) IBOutlet UITextField *txtSearchField;

@property (nonatomic, weak) IBOutlet UITableView *tblItemCategories;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSString *searchText;

@property (nonatomic, strong) NSMutableArray *arrayItemCategoriesList;

@property (nonatomic, assign) BOOL boolisNew;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *itemcategoryResultSetController;

@end

@implementation HItemCategoriesVC
@synthesize managedObjectContext = __managedObjectContext;
@synthesize strCatalog,isfromItem,strPoID,indCategory,boolisNew,isFromNewRelease;

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
    _itemcategoryResultSetController=nil;
    [self.tblItemCategories reloadData];
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

    self.rmsDbController = [RmsDbController sharedRmsDbController];
       self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    self.arrayItemCategoriesList = [[NSMutableArray alloc]init];
    [self createDefaultArray];
    
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
    [self.tblItemCategories registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HCatalogCustomCell"];
    if(self.isFromNewRelease){
        
        self.btnProandNew.hidden = YES;
        
    }
    else{
        self.btnProandNew.hidden = NO;
    }
   // [self itemcategoryResultSetController];
    
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)promotionItems:(id)sender{
    
    if(self.btnProandNew.selected){
        self.btnProandNew.selected=NO;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        boolisNew=NO;
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : OFF" forState:UIControlStateNormal];
        _itemcategoryResultSetController=nil;
        [self.tblItemCategories reloadData];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"N" forKey:@"New"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        self.btnProandNew.selected=YES;
        self.btnProandNew.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:122.0/255.0 blue:253.0/255.0 alpha:1.0];
        boolisNew=YES;
        [self.btnProandNew setTitle:@"PROMOTIONS AND NEW RELEASES ONLY : ON" forState:UIControlStateNormal];
        _itemcategoryResultSetController=nil;
        [self.tblItemCategories reloadData];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"Y" forKey:@"New"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}


#pragma mark - Fetch All Vendor Item

- (NSFetchedResultsController *)itemcategoryResultSetController {
    
    if (_itemcategoryResultSetController != nil) {
        return _itemcategoryResultSetController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryDesc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
   // [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"categoryDesc"]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryDescription = %@",self.strCatalog];
    
    NSPredicate *predicateisNew;
    
    if(boolisNew)
    {
        predicateisNew = [NSPredicate predicateWithFormat:@"isNew = %@ && effectiveDate >= %@", @(1),[NSDate date]];
    }
    else{
       // predicateisNew = [NSPredicate predicateWithFormat:@"isNew = %@",@(0)];
    }

    NSPredicate *searchPredicate;
    if(self.searchText.length>0)
    {
        if(predicateisNew!=nil){
            
            searchPredicate  = [NSPredicate predicateWithFormat:@"categoryDesc contains[cd] %@",self.searchText];
            NSPredicate *newpredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate, searchPredicate,predicateisNew]];
            fetchRequest.predicate = newpredicate;
        }
        else{
            
            searchPredicate  = [NSPredicate predicateWithFormat:@"categoryDesc contains[cd] %@",self.searchText];
            NSPredicate *newpredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate, searchPredicate]];
            fetchRequest.predicate = newpredicate;
        }
      
    }
    else{
    
        if(predicateisNew!=nil){
            NSPredicate *newpredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate,predicateisNew]];
            fetchRequest.predicate = newpredicate;
            
        }
        else{
            NSPredicate *newpredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate]];
            fetchRequest.predicate = newpredicate;

        }
        
    }

    _itemcategoryResultSetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"categoryDesc" cacheName:nil];
    
    [_itemcategoryResultSetController performFetch:nil];
    _itemcategoryResultSetController.delegate = self;
    
    return _itemcategoryResultSetController;

}

-(void)createDefaultArray{
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"Department"] = @"Bluk Foods";
    
    NSMutableArray *arraySubitem = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *dictTemp =[[NSMutableDictionary alloc]init];
    dictTemp[@"Category"] = @"BULK TEA";
    dictTemp[@"Products"] = @"759 Products";
    dictTemp[@"price1"] = @"$2.59";
    dictTemp[@"price2"] = @"$100";
    dictTemp[@"itemNumber"] = @"1234567";
    dictTemp[@"qtyinstock"] = @"12";
    dictTemp[@"unitpercase"] = @"24";
    dictTemp[@"margin"] = @"10%";
    
    [arraySubitem addObject:dictTemp];
    
    NSMutableDictionary *dictTemp1 =[[NSMutableDictionary alloc]init];
    dictTemp1[@"Category"] = @"BULK FROZEN";
    dictTemp1[@"Products"] = @"759 Products";
    dictTemp1[@"price1"] = @"$2.59";
    dictTemp1[@"price2"] = @"$100";
    dictTemp1[@"itemNumber"] = @"1234567";
    dictTemp1[@"qtyinstock"] = @"12";
    dictTemp1[@"unitpercase"] = @"24";
    dictTemp1[@"margin"] = @"10%";
    [arraySubitem addObject:dictTemp1];
    
    
    NSMutableDictionary *dictTemp2 =[[NSMutableDictionary alloc]init];
    dictTemp2[@"Category"] = @"BULK GRAINS";
    dictTemp2[@"Products"] = @"759 Products";
    dictTemp2[@"price1"] = @"$2.59";
    dictTemp2[@"price2"] = @"$100";
    dictTemp2[@"itemNumber"] = @"1234567";
    dictTemp2[@"qtyinstock"] = @"12";
    dictTemp2[@"unitpercase"] = @"24";
    dictTemp2[@"margin"] = @"10%";
    [arraySubitem addObject:dictTemp2];
    
    NSMutableDictionary *dictTemp3 =[[NSMutableDictionary alloc]init];
    dictTemp3[@"Category"] = @"BULK CONFECTION";
    dictTemp3[@"Products"] = @"759 Products";
    dictTemp3[@"price1"] = @"$2.59";
    dictTemp3[@"price2"] = @"$100";
    dictTemp3[@"itemNumber"] = @"1234567";
    dictTemp3[@"qtyinstock"] = @"12";
    dictTemp3[@"unitpercase"] = @"24";
    dictTemp3[@"margin"] = @"10%";
    [arraySubitem addObject:dictTemp3];
    
    
    NSMutableDictionary *dictTemp4 =[[NSMutableDictionary alloc]init];
    dictTemp4[@"Category"] = @"BULK SODA";
    dictTemp4[@"Products"] = @"759 Products";
    dictTemp4[@"price1"] = @"$2.59";
    dictTemp4[@"price2"] = @"$100";
    dictTemp4[@"itemNumber"] = @"1234567";
    dictTemp4[@"qtyinstock"] = @"12";
    dictTemp4[@"unitpercase"] = @"24";
    dictTemp4[@"margin"] = @"10%";
    [arraySubitem addObject:dictTemp4];
    
    NSMutableDictionary *dictTemp5 =[[NSMutableDictionary alloc]init];
    dictTemp5[@"Category"] = @"BULK GRAINS";
    dictTemp5[@"Products"] = @"759 Products";
    dictTemp5[@"price1"] = @"$2.59";
    dictTemp5[@"price2"] = @"$100";
    dictTemp5[@"itemNumber"] = @"1234567";
    dictTemp5[@"qtyinstock"] = @"12";
    dictTemp5[@"unitpercase"] = @"24";
    dictTemp5[@"margin"] = @"10%";
    [arraySubitem addObject:dictTemp5];
    
    NSMutableDictionary *dictTemp6 =[[NSMutableDictionary alloc]init];
    dictTemp6[@"Category"] = @"BULK CONFECTION";
    dictTemp6[@"Products"] = @"759 Products";
    dictTemp6[@"price1"] = @"$2.59";
    dictTemp6[@"price2"] = @"$100";
    dictTemp6[@"itemNumber"] = @"1234567";
    dictTemp6[@"qtyinstock"] = @"12";
    dictTemp6[@"unitpercase"] = @"24";
    dictTemp6[@"margin"] = @"10%";
    [arraySubitem addObject:dictTemp6];
    
    
    NSMutableDictionary *dictTemp7 =[[NSMutableDictionary alloc]init];
    dictTemp7[@"Category"] = @"BULK SODA";
    dictTemp7[@"Products"] = @"759 Products";
    dictTemp7[@"price1"] = @"$2.59";
    dictTemp7[@"price2"] = @"$100";
    dictTemp7[@"itemNumber"] = @"1234567";
    dictTemp7[@"qtyinstock"] = @"12";
    dictTemp7[@"unitpercase"] = @"24";
    dictTemp7[@"margin"] = @"10%";
    [arraySubitem addObject:dictTemp7];
    
    NSMutableDictionary *dictTemp8 =[[NSMutableDictionary alloc]init];
    dictTemp8[@"Category"] = @"BULK GRAINS";
    dictTemp8[@"Products"] = @"759 Products";
    dictTemp8[@"price1"] = @"$2.59";
    dictTemp8[@"price2"] = @"$100";
    dictTemp8[@"itemNumber"] = @"1234567";
    dictTemp8[@"qtyinstock"] = @"12";
    dictTemp8[@"unitpercase"] = @"24";
    dictTemp8[@"margin"] = @"10%";
    [arraySubitem addObject:dictTemp8];
    dict[@"SubItem"] = arraySubitem;
    
    [self.arrayItemCategoriesList addObject:[dict mutableCopy]];
    [self.arrayItemCategoriesList insertObject:self.arrayItemCategoriesList.firstObject atIndex:0];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 35.0;
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *viewTemp = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 35.0)];
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20.0, 8.0, 320.0, 23.0)];
    lblTitle.text=self.strCatalog;
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
    NSArray *sections = self.itemcategoryResultSetController.sections;
    return sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 58.0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"HCatalogCustomCell";
    
    HCatalogCustomCell *catalogCell = (HCatalogCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSArray *sections = self.itemcategoryResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[indexPath.row];
    if(indexPath.row == self.indCategory.row){
        catalogCell.backgroundColor = [UIColor lightGrayColor];
    }
    else{
        catalogCell.backgroundColor = [UIColor whiteColor];
    }
    catalogCell.lblSubName.text=sectionInfo.name;
    catalogCell.lblProducts.text=[NSString stringWithFormat:@"%lu Products", (unsigned long)sectionInfo.numberOfObjects];
    return catalogCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   /* UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HItemProductVC *hitemProduct = [storyBoard instantiateViewControllerWithIdentifier:@"HItemProductVC"];
    hitemProduct.arrayItemProductList=[[[self.arrayItemCategoriesList objectAtIndex:indexPath.section]valueForKey:@"SubItem"]mutableCopy];
    NSArray *sections = [self.itemcategoryResultSetController sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:indexPath.row];
    hitemProduct.strCategory=[sectionInfo name];
    hitemProduct.strCatelog=self.strCatalog;
    hitemProduct.isfromItem=self.isfromItem;
    hitemProduct.strPoId=self.strPoID;
    [self.navigationController pushViewController:hitemProduct animated:YES];*/
    
    NSArray *sections = self.itemcategoryResultSetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[indexPath.row];
    NSArray *arrayView = self.navigationController.viewControllers;
    for(UIViewController *viewcon in arrayView){
        if([viewcon isKindOfClass:[HItemProductVC class]]){
            HItemProductVC *hitemProduct =(HItemProductVC *)viewcon;
            hitemProduct.strCategory=sectionInfo.name;
            hitemProduct.strCatelog=self.strCatalog;
            hitemProduct.isfromItem=self.isfromItem;
            hitemProduct.indpathCategory=indexPath;
            hitemProduct.indpathCatalog=self.indCatalog;
            [self.navigationController popToViewController:viewcon animated:YES];
        }
    }
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
            
            _itemcategoryResultSetController = nil;
            [self.tblItemCategories reloadData];
        });
    }
    else{
        _itemcategoryResultSetController = nil;
        [self.tblItemCategories reloadData];
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


-(IBAction)gotoCatalog:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
