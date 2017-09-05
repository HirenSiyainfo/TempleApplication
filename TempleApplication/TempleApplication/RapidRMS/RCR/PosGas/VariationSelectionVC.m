//
//  VariationSelectionVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 12/1/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "VariationSelectionVC.h"
#import "MultipleItemBarcodeRingUpCell.h"
#import "Item_Price_MD+Dictionary.h"
#import "Item+Dictionary.h"
#import "RmsDbController.h"
#import "Item_Discount_MD+Dictionary.h"
#import "ItemVariation_M+Dictionary.h"
#import "ItemVariation_Md+Dictionary.h"
#import "Variation_Master+Dictionary.h"
#import "VariationDisplayCustomCell.h"

#define FIRST_TABLE_IDENTIFIER      @"first_variationTableView"
#define SECOND_TABLE_IDENTIFIER     @"second_variationTableView"
#define THIRD_TABLE_IDENTIFIER      @"third_variationTableView"


typedef NS_ENUM(NSInteger, VARIATION_COUNT) {
    ONE_VARIATION = 1,
    TWO_VARIATION,
    THREE_VARIATION,
};

@interface VariationSelectionVC () <NSFetchedResultsControllerDelegate>
{
    NSMutableArray *first_VariationArray;
    NSMutableArray *second_VariationArray;
    NSMutableArray *third_VariationArray;
    NSMutableArray *totalVariationDetail;
}

@property (nonatomic, weak) IBOutlet UIButton *btnBtnDone;
@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@property (nonatomic, weak) IBOutlet UIView *viewVariationContainer;
@property (nonatomic, weak) IBOutlet UIView *variationButtonContainter;
@property (nonatomic, weak) IBOutlet UITableView *first_variationTableView;
@property (nonatomic, weak) IBOutlet UITableView *second_variationTableView;
@property (nonatomic, weak) IBOutlet UITableView *third_variationTableView;
@property (nonatomic, weak) IBOutlet UILabel *first_variationLabel;
@property (nonatomic, weak) IBOutlet UILabel *second_variationLabel;
@property (nonatomic, weak) IBOutlet UILabel *third_variationLabel;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation VariationSelectionVC

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    totalVariationDetail = [[NSMutableArray alloc]init];
    
    NSString  *variationSelectionCell;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        variationSelectionCell = @"VariationDisplayCustomCell_IPad";
    }
    else
    {
        variationSelectionCell = @"VariationDisplayCustomCell_IPad";
    }
    
    UINib *mixGenerateirderNib1 = [UINib nibWithNibName:variationSelectionCell bundle:nil];
    [_first_variationTableView registerNib:mixGenerateirderNib1 forCellReuseIdentifier:@"VariationDisplayCustomCell"];
    
    UINib *mixGenerateirderNib2 = [UINib nibWithNibName:variationSelectionCell bundle:nil];
    [_second_variationTableView registerNib:mixGenerateirderNib2 forCellReuseIdentifier:@"VariationDisplayCustomCell"];
    
    UINib *mixGenerateirderNib3 = [UINib nibWithNibName:variationSelectionCell bundle:nil];
    [_third_variationTableView registerNib:mixGenerateirderNib3 forCellReuseIdentifier:@"VariationDisplayCustomCell"];
    
    
    _btnBtnDone.layer.cornerRadius = 5;
    
    _btnBtnDone.layer.borderWidth = 1.0f;
    
    _btnBtnDone.layer.borderColor = [UIColor clearColor].CGColor;
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupVariation_MDForItem];
}
-(void)setupVariation_MDForItem
{
    NSArray *array = (NSArray *)self.itemforVariation.itemVariations.allObjects;

     _viewVariationContainer.frame=CGRectMake(self.view.frame.size.width/2-200*array.count/2, _viewVariationContainer.frame.origin.y, 200*array.count, _viewVariationContainer.frame.size.height);
    
     _variationButtonContainter.frame=CGRectMake(_viewVariationContainer.frame.origin.x+_viewVariationContainer.frame.size.width-130, _variationButtonContainter.frame.origin.y, _variationButtonContainter.frame.size.width, _variationButtonContainter.frame.size.height);
    
    
    NSArray *variationList = self.itemforVariation.itemVariations.allObjects;
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"colPosNo" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    NSArray *sortedVarArray = [variationList sortedArrayUsingDescriptors:sortDescriptors];
    [self configureVariationViewWithVariationDetail:sortedVarArray];
}

- (NSMutableArray *)variationMDSforVariation:(ItemVariation_M *)itemVariation_M withItemVariationCode:(NSNumber *)itemcode
{
    NSArray *variationList = itemVariation_M.variationMVariationMds.allObjects;
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowPosNo" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    NSArray *sortedVarArray = [variationList sortedArrayUsingDescriptors:sortDescriptors];

    return [sortedVarArray mutableCopy];
}

-(NSString *)getVariationName :(ItemVariation_M *)itemVariation_M
{
    return itemVariation_M.variationMMaster.name;
}

-(void)configureVariationTableArray :(NSArray *)variation
{
    switch (variation.count)
    {
        case ONE_VARIATION:
            _first_variationLabel.text = [NSString stringWithFormat:@"  %@",[self getVariationName:variation.firstObject]];
            [totalVariationDetail addObject:_first_variationTableView];
            _first_variationLabel.hidden = NO;
            break;
        case TWO_VARIATION:
            _first_variationLabel.text = [NSString stringWithFormat:@"  %@",[self getVariationName:variation.firstObject]];
            _second_variationLabel.text =[NSString stringWithFormat:@"  %@",[self getVariationName:variation[ONE_VARIATION]]] ;
            [totalVariationDetail addObject:_first_variationTableView];
            [totalVariationDetail addObject:_second_variationTableView];
            
            _first_variationLabel.hidden = NO;
            _second_variationLabel.hidden = NO;

            
            break;
        case THREE_VARIATION:

            _first_variationLabel.text = [NSString stringWithFormat:@"  %@",[self getVariationName:variation.firstObject]] ;
            _second_variationLabel.text = [NSString stringWithFormat:@"  %@",[self getVariationName:variation[ONE_VARIATION]]] ;
            _third_variationLabel.text = [NSString stringWithFormat:@"  %@",[self getVariationName:variation[TWO_VARIATION]] ];
            [totalVariationDetail addObject:_first_variationTableView];
            [totalVariationDetail addObject:_second_variationTableView];
            [totalVariationDetail addObject:_third_variationTableView];
         
            _first_variationLabel.hidden = NO;
            _second_variationLabel.hidden = NO;
            _third_variationLabel.hidden = NO;

            break;
        default:
            break;
    }
}

-(void)reloadAndShowTableview
{
    for (UITableView *tableview in totalVariationDetail) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        tableview.hidden = NO;
        [tableview reloadData];
    }
}


-(void)configureVariationViewWithVariationDetail :(NSArray *)variationDetail
{
    first_VariationArray = nil;
    second_VariationArray = nil;
    third_VariationArray = nil;
    
    [self configureVariationTableArray:variationDetail];
    
        switch (variationDetail.count)
    {
        case ONE_VARIATION:
            
            first_VariationArray = [self variationMDSforVariation:variationDetail.firstObject withItemVariationCode:self.itemforVariation.itemCode];
            
           
            break;
        case TWO_VARIATION:
         
            first_VariationArray = [self variationMDSforVariation:variationDetail.firstObject withItemVariationCode:self.itemforVariation.itemCode];
            second_VariationArray = [self variationMDSforVariation:variationDetail[ONE_VARIATION]withItemVariationCode:self.itemforVariation.itemCode];
           
            break;
        case THREE_VARIATION:
         
            first_VariationArray = [self variationMDSforVariation:variationDetail.firstObject withItemVariationCode:self.itemforVariation.itemCode];
            second_VariationArray = [self variationMDSforVariation:variationDetail[ONE_VARIATION]withItemVariationCode:self.itemforVariation.itemCode];
            third_VariationArray = [self variationMDSforVariation:variationDetail[TWO_VARIATION]withItemVariationCode:self.itemforVariation.itemCode];

            break;
        default:
            break;
    }
    [self reloadAndShowTableview];
}


-(NSString *)getApplyUnitPriceForItemVariation_Md :(ItemVariation_Md *)variation_md
{
    NSString *priceType = [NSString stringWithFormat:@"%@",variation_md.applyPrice];
    NSNumber *priceValue = 0;
    
    if ([priceType isEqualToString:@"PriceA"])
    {
        priceValue = variation_md.priceA;
    }
    else if ([priceType isEqualToString:@"PriceB"])
    {
        priceValue = variation_md.priceB;
        
    }
    else if ([priceType isEqualToString:@"PriceC"])
    {
        priceValue = variation_md.priceC;
    }
    else
    {
        priceValue = variation_md.unitPrice;
    }
    
    return priceValue.stringValue;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    if (tableView == _first_variationTableView)
    {
        return first_VariationArray.count;
    }
    else if (tableView == _second_variationTableView)
    {
        return second_VariationArray.count;

    }
    else if (tableView == _third_variationTableView)
    {
        return third_VariationArray.count;
    }
    return 1;
}
- (UITableViewCell *)configureCell:(NSString *)identifier style:(UITableViewCellStyle)style indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView withDetail :(NSMutableArray *)itemVariationDetail
{
    //UITableViewCell *first_VariationCell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
    
    NSString *cellIdentifier = @"VariationDisplayCustomCell";
    
    VariationDisplayCustomCell *variationDisplayCell = (VariationDisplayCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
    variationDisplayCell.selectedBackgroundView = selectionColor;
    
    UIView *backColor = [[UIView alloc] init];
    backColor.backgroundColor = [UIColor whiteColor];
    variationDisplayCell.backgroundView = backColor;
    
   // variationDisplayCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ItemVariation_Md *itemVariation_Md =itemVariationDetail[indexPath.row];
    variationDisplayCell.lblVariationName.text = itemVariation_Md.name;
    
    NSString *strPrice  = [self getApplyUnitPriceForItemVariation_Md:itemVariation_Md];
    
    variationDisplayCell.lblPrice.text=[NSString stringWithFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",strPrice.floatValue]]];
    
    if ([self isAlreadySelectedInRingupVariant:variationDisplayCell.lblVariationName.text])
    {
        [tableView selectRowAtIndexPath:indexPath animated:TRUE scrollPosition:UITableViewScrollPositionNone];
    }
    return variationDisplayCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    if(tableView == _first_variationTableView)
    {
        return [self configureCell:FIRST_TABLE_IDENTIFIER style:style indexPath:indexPath tableView:tableView withDetail:first_VariationArray];
    }
    
    else if(tableView == _second_variationTableView)
    {
        
        return [self configureCell:SECOND_TABLE_IDENTIFIER style:style indexPath:indexPath tableView:tableView withDetail:second_VariationArray];

    }
    else if(tableView == _third_variationTableView)
    {
        return [self configureCell:THIRD_TABLE_IDENTIFIER style:style indexPath:indexPath tableView:tableView withDetail:third_VariationArray];
    }

    return cell;
}
-(BOOL)isAlreadySelectedInRingupVariant :(NSString *)variant
{
    BOOL isAlreadySelectedInRingup = FALSE;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"VariationItemName == %@",variant];
    NSArray *isAlreadySelectedInRingupArray = [self.selectedVariance filteredArrayUsingPredicate:predicate];
    if (isAlreadySelectedInRingupArray.count > 0)
    {
        isAlreadySelectedInRingup = TRUE;
    }
    
    return isAlreadySelectedInRingup;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = tableView.indexPathsForSelectedRows;
    NSPredicate *filterSelectedRows = [NSPredicate predicateWithFormat:@"section==%d AND row!=%d",indexPath.section,indexPath.row];
    NSArray *selectedRowForSection = [selectedRows filteredArrayUsingPredicate:filterSelectedRows];
    
    for (NSIndexPath *selectedIndexpath in selectedRowForSection)
    {
        [tableView deselectRowAtIndexPath:selectedIndexpath animated:FALSE];
    }
}

-(BOOL)selectedRowForTableView :(UITableView *)tableview
{
    BOOL selectedRows = FALSE;
    if (tableview.indexPathsForSelectedRows.count > 0) {
        selectedRows = TRUE;
    }
    return selectedRows;
}



- (void)getSelectedVariantAtIndexpath:(NSIndexPath *)selectedIndexpath array:(NSMutableArray *)array selectedVariantArray:(NSMutableArray *)selectedVariantArray
{
    NSMutableDictionary *variantDictionary = [[NSMutableDictionary alloc]init];
    ItemVariation_Md *itemVariation_Md =array[selectedIndexpath.row];
    variantDictionary[@"VariationItemName"] = itemVariation_Md.name;
    variantDictionary[@"Price"] = [self getApplyUnitPriceForItemVariation_Md:itemVariation_Md];
    variantDictionary[@"VariationBasicPrice"] = [self getApplyUnitPriceForItemVariation_Md:itemVariation_Md];
    variantDictionary[@"VariationItemId"] = itemVariation_Md.varianceId;
    variantDictionary[@"RowPosition"] = [NSString stringWithFormat:@"%lu",(unsigned long)variantDictionary.count];
    variantDictionary[@"ItemCode"] = self.itemforVariation.itemCode;

    [selectedVariantArray addObject:variantDictionary];
}

-(NSArray *)getSelectedVariant
{
    NSMutableArray *selectedVariantArray = [[NSMutableArray alloc]init];
    for (UITableView *tableview in totalVariationDetail)
    {
        NSArray *selectedRow = tableview.indexPathsForSelectedRows;

        if (tableview == _first_variationTableView)
        {
            for (NSIndexPath *selectedIndexpath in selectedRow)
            {
                [self getSelectedVariantAtIndexpath:selectedIndexpath array:first_VariationArray selectedVariantArray:selectedVariantArray];
            }
        }
        else if  (tableview == _second_variationTableView)
        {
            for (NSIndexPath *selectedIndexpath in selectedRow)
            {
                [self getSelectedVariantAtIndexpath:selectedIndexpath array:second_VariationArray selectedVariantArray:selectedVariantArray];
            }
        }
        else if  (tableview == _third_variationTableView)
        {
            for (NSIndexPath *selectedIndexpath in selectedRow)
            {
                [self getSelectedVariantAtIndexpath:selectedIndexpath array:third_VariationArray selectedVariantArray:selectedVariantArray];

            }
        }
    }
    return selectedVariantArray;
}
-(IBAction)DoneMultipeBarcodeVC:(id)sender
{
    BOOL selectedRows = FALSE;
    for (UITableView *tableview in totalVariationDetail)
    {
        selectedRows = [self selectedRowForTableView:tableview];
        if (selectedRows == FALSE)
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"please select all variation" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            return;
        }
    }
    
    NSArray *selectedVariantArray = [self getSelectedVariant];
    [self.variationSelectionDelegate didSelectItemWithVariationDetail:selectedVariantArray withItem:self.itemforVariation];
}
-(IBAction)cancelMultipeBarcodeVC:(id)sender
{
    [self.variationSelectionDelegate didCancelVariationSelectionProcess];
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
