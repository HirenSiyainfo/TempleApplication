//
//  DepartmentViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 29/11/14.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "ItemVariationRIM.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "ItemVariationRIMCell.h"
#import "SelectUserOptionVC.h"
#import "UserInputTextVC.h"

#import "Variation_Master.h"

//VariationOptionCustomCell remove

@interface ItemVariationRIM ()

@property (nonatomic, weak) IBOutlet UITableView *tblVariationsList;
@property (nonatomic, weak) IBOutlet UIButton *btnAddNewVariation;

@property (nonatomic, strong) NSMutableArray *arrayDeletedVeration;
@property (nonatomic, strong) NSMutableArray *variansArray;

@end

@implementation ItemVariationRIM

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - IBAction -

-(IBAction)backButtonTapped:(id)sender {
    [self.ItemVariationChangedDelegate didChangeItemVariationAdded:self.arraySelectionVeriation ItemVariationDeleted:self.arrayDeletedVeration ItemVariationDisplay:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.arraySelectionVeriation.count > 2) {
        self.btnAddNewVariation.userInteractionEnabled = FALSE;
    }
    else {
        self.btnAddNewVariation.userInteractionEnabled = TRUE;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.arraySelectionVeriation.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary * dictVariationInfo = self.arraySelectionVeriation[indexPath.row];
    NSMutableArray * arrVariationSub = dictVariationInfo[@"variationsubArray"];
    if (arrVariationSub.count == 0) {
        return 150;
    }
    else {
        float intNumItems = (float)arrVariationSub.count;
        float fltNumRows = ceil(intNumItems/3);
        float height = (fltNumRows*40)+20+50;//50 px cell and 20 px collection view header futter
        return (height <= 150)? 150 : height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemVariationRIMCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell confugareCell:self.arraySelectionVeriation[indexPath.row] withAddVariationItem:^(NSMutableArray * arrListVariationItems){
        [self addCoustomVariationItems:arrListVariationItems];
    }];
    
    if (self.arraySelectionVeriation.count - 1 == indexPath.row && indexPath.row < 2) {
        cell.btnVariationAddNew.hidden =FALSE;
    }
    else {
        cell.btnVariationAddNew.hidden =TRUE;
    }
    cell.colVariationValueList.delaysContentTouches = FALSE;
    cell.btnVariationDelete.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - add delete variations -
-(IBAction)addNewVariationSelectionPopup:(UIButton *)sender {
    if (!self.variansArray || self.variansArray.count ==0) {
        [self getVarianes];
    }
    SelectUserOptionVC * objSelectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:self.variansArray SelectedObject:nil SelectionComplete:^(NSArray *arrSelection) {
        NSDictionary * dictVariationInfo = arrSelection.firstObject;
        if ([dictVariationInfo[@"varianceId"] intValue] == -1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self addCoustomVariation];
            });
        }
        else {
            [self addVariationNewVariation:dictVariationInfo[@"variationName"] VariationID:dictVariationInfo[@"varianceId"] arrVariations:self.arraySelectionVeriation];
        }
    } SelectionColse:^(UIViewController *popUpVC) {
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objSelectUserOptionVC.arrDisableSelectionTitle =[self.arraySelectionVeriation valueForKey:@"variationName"];
//    [objSelectUserOptionVC presentViewControllerForviewConteroler:self];
    if (sender.tag == 963) {
        [objSelectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionDown];
    }
    else{
        [objSelectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionUp];
    }
}

-(void)addCoustomVariation {
    UserInputTextVC * objUserInputTextVC = [UserInputTextVC setInputTextFieldViewitem:@"" InputTitle:@"Item Variation Group" InputSubTitle:@"Enter custom variation Group" InputSaved:^(NSString *strInput) {
        [self addVariationNewVariation:strInput VariationID:@(-1) arrVariations:self.variansArray];
    } InputClosed:^(UIViewController *popUpVC) {
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objUserInputTextVC.strImputPlaceHolder = @"Item Variation Group";
    objUserInputTextVC.strImputErrorMessage = @"Please Enter Custom Item Variation Group";
    objUserInputTextVC.isBlankInputSaved = FALSE;
    objUserInputTextVC.isKeybordShow = TRUE;
    [objUserInputTextVC presentViewControllerForViewController:self];

}

-(void)addCoustomVariationItems:(NSMutableArray *) arrVariationitems{
    UserInputTextVC * objUserInputTextVC = [UserInputTextVC setInputTextFieldViewitem:@"" InputTitle:@"Item Variation name" InputSubTitle:@"Enter custom variation name" InputSaved:^(NSString *strInput) {
        
        if ([self isDuplicateObject:@"Value" InputValue:strInput inList:arrVariationitems]) {
            [self showAlertForDuplicateVariation:@"Variation Item Name Already Exist. Please Enter Unique Variation item Name."];
        }
        else {
            NSMutableDictionary * dictVariationname = [NSMutableDictionary dictionary];
            dictVariationname[@"ApplyPrice"] = @"UnitPrice";
            dictVariationname[@"Cost"] = @"0.0";
            dictVariationname[@"PriceA"] = @"0.0";
            dictVariationname[@"PriceB"] = @"0.0";
            dictVariationname[@"PriceC"] = @"0.0";
            dictVariationname[@"Profit"] = @"0.0";
            dictVariationname[@"RowPosNo"] = [NSString stringWithFormat:@"%d",(int)arrVariationitems.count+1];
            dictVariationname[@"UnitPrice"] = @"0.0";
            dictVariationname[@"Value"] = strInput;
            [arrVariationitems addObject:dictVariationname];
            [self.tblVariationsList reloadData];

        }
    } InputClosed:^(UIViewController *popUpVC) {
        [((UserInputTextVC *)popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    objUserInputTextVC.strImputPlaceHolder = @"Item Variation name";
    objUserInputTextVC.strImputErrorMessage = @"Please Enter Custom Item Variation name";
    objUserInputTextVC.isBlankInputSaved = FALSE;
    
    [objUserInputTextVC presentViewControllerForviewConteroller:self sourceView:nil ArrowDirection:(UIPopoverArrowDirection)nil];
    self.popoverPresentationController.delegate = objUserInputTextVC;
    
}

-(void)addVariationNewVariation:(NSString *)strVariationType VariationID:(NSNumber *)strVariationID arrVariations:(NSMutableArray *)arrVariations{
    if ([self isDuplicateObject:@"variationName" InputValue:strVariationType inList:arrVariations]) {
        [self showAlertForDuplicateVariation:@"Variation Group Name Already Exist. Please Enter Unique Variation Group Name."];
    }
    else{
        NSMutableDictionary * dictVariationType = [NSMutableDictionary dictionary];
        dictVariationType[@"ColPosNo"] = [NSString stringWithFormat:@"%d",(int)self.arraySelectionVeriation.count + 1];
        dictVariationType[@"varianceId"] = strVariationID; //when new then -1
        dictVariationType[@"variationName"] = strVariationType;
        dictVariationType[@"variationsubArray"] = [@[] mutableCopy];
        [self.arraySelectionVeriation addObject:dictVariationType];
        [self.tblVariationsList reloadData];
    }
}
-(BOOL)isDuplicateObject:(NSString *)strKey InputValue:(NSString *)strVal inList:(NSMutableArray *)arrList {
    
    NSString *trimmedVariationGroup = [strVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate *variationGroupPredicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@",strKey,trimmedVariationGroup];
    NSArray * arrDuplicate = [arrList filteredArrayUsingPredicate:variationGroupPredicate];
    
    if(arrDuplicate.count > 0){
        return TRUE;
    }
    else{
        return FALSE;
    }

}
- (void)showAlertForDuplicateVariation:(NSString *)strMessage {
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
    };
    [[RmsDbController sharedRmsDbController] popupAlertFromVC:self title:@"Message" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

-(IBAction)deleteVariation:(UIButton *)sender {
    
    NSMutableDictionary * dictVariation = self.arraySelectionVeriation[sender.tag];
    if (!([dictVariation[@"varianceId"] intValue] == -1)) {
        [self.arrayDeletedVeration addObject:[dictVariation mutableCopy]];
    }
    [self.arraySelectionVeriation removeObjectAtIndex:sender.tag];
    [self.tblVariationsList reloadData];
}

#pragma mark - get variationList for popup -

-(void)getVarianes
{
    self.variansArray = [NSMutableArray array];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Variation_Master" inManagedObjectContext:[RmsDbController sharedRmsDbController].managedObjectContext];
    fetchRequest.entity = entity;
    NSArray *resultSet = [UpdateManager executeForContext:[RmsDbController sharedRmsDbController].managedObjectContext FetchRequest:fetchRequest];
    int customVariationId =-1;
    NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
    supplierDict[@"varianceId"] = @(customVariationId);
    supplierDict[@"variationName"] = @"Custom";
    supplierDict[@"name"] = @"Custom";
    [self.variansArray addObject:supplierDict];

    if (resultSet.count > 0)
    {
        for (Variation_Master *variansMaster in resultSet) {
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"varianceId"] = variansMaster.vid;
            supplierDict[@"variationName"] = variansMaster.name;
            supplierDict[@"name"] = variansMaster.name;
            [self.variansArray addObject:supplierDict];
        }
    }
    [self updateTheVariationListWithSelectedVariation];
}

-(void)updateTheVariationListWithSelectedVariation{
    
    for(int i=0;i<(self.variansArray).count;i++)
    {
        NSMutableDictionary *dictvariationM = (self.variansArray)[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"variationName = %@",[dictvariationM valueForKey:@"variationName"]];
        NSArray *arrayResult  = [self.arraySelectionVeriation filteredArrayUsingPredicate:predicate];
        if(arrayResult.count>0)
        {
            dictvariationM[@"index"] = [NSString stringWithFormat:@"%d",i];
        }
    }
}

@end
