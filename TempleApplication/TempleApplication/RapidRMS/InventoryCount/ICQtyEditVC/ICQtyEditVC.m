//
//  ICQtyEditVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ICQtyEditVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Item+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"

@interface ICQtyEditVC ()
{
    UITextField *currentQtyTextField;
    NSString *oldCaseValue;
    NSString *oldPackValue;

}

@property (nonatomic, weak) IBOutlet UILabel *itemName;
@property (nonatomic, weak) IBOutlet UILabel *lblSingleQty;
@property (nonatomic, weak) IBOutlet UILabel *lblCasePackQty;
@property (nonatomic, weak) IBOutlet UITextField *txtSingleQty;
@property (nonatomic, weak) IBOutlet UITextField *editSingleQty;
@property (nonatomic, weak) IBOutlet UITextField *txtCaseQty;
@property (nonatomic, weak) IBOutlet UITextField *editCaseQty;
@property (nonatomic, weak) IBOutlet UITextField *txtPackQty;
@property (nonatomic, weak) IBOutlet UITextField *editPackQty;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *updateCasePackQtyWC;

@property (nonatomic, strong) NSMutableDictionary *selectedScannedItem;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ICQtyEditVC
@synthesize managedObjectContext = __managedObjectContext;

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
    self.updateCasePackQtyWC = [[RapidWebServiceConnection alloc] init];
    //self.managedObjectContext = [UpdateManager privateConextFromParentContext:self.rmsDbController.managedObjectContext];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    [self setEditableTextboxProperty:_editSingleQty];
    [self setEditableTextboxProperty:_editCaseQty];
    [self setEditableTextboxProperty:_editPackQty];
    
//    [self setQtyTextboxProperty:_txtSingleQty];
    [self setEditableTextboxProperty:_txtCaseQty];
    [self setEditableTextboxProperty:_txtPackQty];
    
    [self setItemDetailsForView];
    
    [self textFieldShouldBeginEditing:_editSingleQty];

    [_roundedView.layer setCornerRadius:18.0f];
    _roundedView.clipsToBounds = YES;

    // Do any additional setup after loading the view.
}

-(void)setEditableTextboxProperty:(UITextField *)textField
{
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = [UIColor blackColor].CGColor;
}

-(void)setQtyTextboxProperty:(UITextField *)textField
{
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (NSString *)getValueBeforeDecimal:(float)result
{
    NSNumber *numberValue = @(result);
    NSString *floatString = numberValue.stringValue;
    NSArray *floatStringComps = [floatString componentsSeparatedByString:@"."];
    NSString *cq = [NSString stringWithFormat:@"%@",floatStringComps.firstObject];
    return cq;
}

-(void)setItemDetailsForView
{
    NSMutableDictionary *dictItemClicked = [self.selectedItem.itemRMSDictionary mutableCopy];
    
    CGSize constraintSize;
    constraintSize.width = 175;
    constraintSize.height = 200;
    
    UIFont *nameFont = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    CGRect textRect = [self.selectedItem.item_Desc boundingRectWithSize:constraintSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:nameFont}
                                             context:nil];
    CGSize size = textRect.size;
    CGRect lblNameFrame = _itemName.frame;
    lblNameFrame.size.height = size.height;
    _itemName.frame = lblNameFrame;
    
    _itemName.text = self.selectedItem.item_Desc;
    
    NSInteger availableQty = [[dictItemClicked valueForKey:@"avaibleQty"] integerValue];
    _lblSingleQty.text = [NSString stringWithFormat:@"%ld",(long)availableQty];
    _txtSingleQty.text = @"1";
    
    NSString *itemCode = self.selectedItem.itemCode.stringValue;
    if(availableQty != 0)
    {
        Item *anItem = [self fetchAllItems:itemCode];
        NSMutableArray *itemPricingArray = [[NSMutableArray alloc]init];
        for (Item_Price_MD *pricing in anItem.itemToPriceMd)
        {
            NSMutableDictionary *pricingDict = [[NSMutableDictionary alloc]init];
            pricingDict[@"PriceQtyType"] = pricing.priceqtytype;
            pricingDict[@"Qty"] = pricing.qty;
            [itemPricingArray addObject:pricingDict];
        }
        
        NSPredicate *casePredicate = [NSPredicate predicateWithFormat:@"PriceQtyType = %@ AND Qty != 0" , @"Case"];
        NSArray *isCaseResult = [itemPricingArray filteredArrayUsingPredicate:casePredicate];
        NSString *caseValue;
        if(isCaseResult.count > 0)
        {
            NSString *caseQty  = [NSString stringWithFormat:@"%ld",(long)[[isCaseResult[0] valueForKey:@"Qty"] integerValue ]];
            _txtCaseQty.text = caseQty;
            oldCaseValue = caseQty;
            float result = _lblSingleQty.text.floatValue/caseQty.floatValue;
            NSString *cq = [self getValueBeforeDecimal:result];
            NSInteger y = _lblSingleQty.text.integerValue % caseQty.integerValue;
            y = labs(y);
            caseValue = [NSString stringWithFormat:@"%@.%ld",cq,(long)y];
        }
        else
        {
            [self setEditableTextboxProperty:_editCaseQty];
            _txtCaseQty.text = @"";
            oldCaseValue = @"";
            caseValue = @"-";
        }
        
        NSPredicate *packPredicate = [NSPredicate predicateWithFormat:@"PriceQtyType = %@ AND Qty != 0" , @"Pack"];
        NSArray *ispackResult = [itemPricingArray filteredArrayUsingPredicate:packPredicate];
        NSString *packValue;
        if(ispackResult.count > 0)
        {
            NSString *packQty  = [NSString stringWithFormat:@"%ld",(long)[[ispackResult[0] valueForKey:@"Qty"] integerValue ]];
            _txtPackQty.text = packQty;
            oldPackValue = packQty;
            float result = _lblSingleQty.text.floatValue/packQty.floatValue;
            NSString *pq = [self getValueBeforeDecimal:result];
            NSInteger x = _lblSingleQty.text.integerValue % packQty.integerValue;
            x = labs(x);
            packValue = [NSString stringWithFormat:@"%@.%ld",pq,(long)x];
        }
        else
        {
            [self setEditableTextboxProperty:_editPackQty];
            _txtPackQty.text = @"";
            oldPackValue = @"";
            packValue = @"-";
        }
        
        if(([caseValue isEqualToString:@"-"]) && ([packValue isEqualToString:@"-"]))
        {
            _lblCasePackQty.text = @"";
        }
        else if ([packValue isEqualToString:@"-"]) // Pack value not available
        {
            _lblCasePackQty.text = [NSString stringWithFormat:@"%@ / -",caseValue];
        }
        else if ([caseValue isEqualToString:@"-"]) // Case value not available
        {
            _lblCasePackQty.text = [NSString stringWithFormat:@"- / %@",packValue];
        }
        else
        {
            _lblCasePackQty.text = [NSString stringWithFormat:@"%@ / %@",caseValue , packValue];
        }
    }
    else
    {
        _lblCasePackQty.text = @"";
        oldCaseValue = @"";
        oldPackValue = @"";
    }
    if (self.selectedItemInventoryCount)
    {
        _editSingleQty.text = self.selectedItemInventoryCount.singleCount.stringValue;
        _editCaseQty.text = self.selectedItemInventoryCount.caseCount.stringValue;
        _editPackQty.text = self.selectedItemInventoryCount.packCount.stringValue;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == _editCaseQty && ![self isEligibleToChangeItemQtyOH:[_txtCaseQty.text intValue]]){
        [self displayAlertWithMessage:@"Please Enter No of Items for Case."];
        return NO;
    }
    else if (textField == _editPackQty && ![self isEligibleToChangeItemQtyOH:[_txtPackQty.text intValue]]){
        [self displayAlertWithMessage:@"Please Enter No of Items for Pack."];
        return NO;
    }
    _editSingleQty.backgroundColor = [UIColor clearColor];
    _editCaseQty.backgroundColor = [UIColor clearColor];
    _editPackQty.backgroundColor = [UIColor clearColor];
    
    _txtCaseQty.backgroundColor = [UIColor clearColor];
    _txtPackQty.backgroundColor = [UIColor clearColor];
    
    currentQtyTextField = textField;
    currentQtyTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:153.0/255.0 alpha:1.0];    return NO;
}

-(BOOL)isEligibleToChangeItemQtyOH:(int)qty{
    return (qty > 0?true : false);
    return true;
}

- (void)displayAlertWithMessage:(NSString *)message {
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {
    };
    [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

- (IBAction) tenderNumPadButtonAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (currentQtyTextField.text == nil )
        {
            currentQtyTextField.text = @"";
        }
        NSString * displyValue = [currentQtyTextField.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        currentQtyTextField.text = displyValue;
	}
    else if ([sender tag] == -98)
    {
		if (currentQtyTextField.text.length > 0)
        {
            currentQtyTextField.text = [currentQtyTextField.text substringToIndex:currentQtyTextField.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (currentQtyTextField.text.length > 0)
        {
            currentQtyTextField.text = @"";
		}
	}
    else if ([sender tag] == 101)
    {
        NSString * displyValue = [currentQtyTextField.text stringByAppendingFormat:@"00"];
        currentQtyTextField.text = displyValue;
	}
    
//    if (currentQtyTextField.tag == 211) {
//        [self.selectedScannedItem setObject:currentQtyTextField.text forKey:@"addedSingleQty"];
//    }
//    else if (currentQtyTextField.tag == 212) {
//        [self.selectedScannedItem setObject:currentQtyTextField.text forKey:@"addedCaseQty"];
//    }
//    else if (currentQtyTextField.tag == 213) {
//        [self.selectedScannedItem setObject:currentQtyTextField.text forKey:@"addedPackQty"];
//    }
}

-(IBAction)addQty:(id)sender
{
    _editSingleQty.backgroundColor = [UIColor clearColor];
    _editCaseQty.backgroundColor = [UIColor clearColor];
    _editPackQty.backgroundColor = [UIColor clearColor];
    
    UIView *currentView = [self.view viewWithTag:[sender tag]];
    UITextField *currentTextField;
    for (UIView *subview in currentView.subviews)
    {
        if([subview isKindOfClass:[UITextField class]] && (subview.tag == [sender tag]))
        {
            currentTextField = (UITextField *)subview;
        }
    }
    currentQtyTextField = currentTextField;
    currentTextField.backgroundColor = [UIColor whiteColor];
    NSInteger addQty = currentTextField.text.integerValue;
    addQty += 1;
    currentTextField.text = [NSString stringWithFormat:@"%ld",(long)addQty];
}

-(IBAction)deductQty:(id)sender
{
    _editSingleQty.backgroundColor = [UIColor clearColor];
    _editCaseQty.backgroundColor = [UIColor clearColor];
    _editPackQty.backgroundColor = [UIColor clearColor];
    UIView *currentView = [self.view viewWithTag:[sender tag]];
    UITextField *currentTextField;
    for (UIView *subview in currentView.subviews)
    {
        if([subview isKindOfClass:[UITextField class]] && (subview.tag == [sender tag]))
        {
            currentTextField = (UITextField *)subview;
        }
    }
    currentTextField = currentTextField;
    currentTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:153.0/255.0 alpha:1.0];
    NSInteger addQty = currentTextField.text.integerValue;
    addQty -= 1;
    if(addQty < 0)
    {
//        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
//        {};
//        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Qty Must be 0 or greater than 0" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;
    }
    currentTextField.text = [NSString stringWithFormat:@"%ld",(long)addQty];
}

- (void)responseUpdateCasePackQtyResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self redirectToItemCountListVC];
            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {};
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Count" message:@"Error while updating case/pack quantity. Please contact RapidRMS or try again" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

- (void)redirectToItemCountListVC
{
    NSMutableDictionary *qtyCountInformationDictionary = [[NSMutableDictionary alloc]init];
    qtyCountInformationDictionary[@"addedSingleQty"] = _editSingleQty.text;
    qtyCountInformationDictionary[@"addedCaseQty"] = _editCaseQty.text;
    qtyCountInformationDictionary[@"addedPackQty"] = _editPackQty.text;
    qtyCountInformationDictionary[@"createDate"] = [NSDate date];
    qtyCountInformationDictionary[@"itemCode"] = self.selectedItem.itemCode;
    qtyCountInformationDictionary[@"userId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    qtyCountInformationDictionary[@"registerId"] = [self.rmsDbController.globalDict valueForKey:@"RegisterId"];
    [self.iCQtyEditDelegate didAddItemToInventoryCountListWith:self.selectedItemInventoryCount withItem:self.selectedItem withCountDetail:qtyCountInformationDictionary];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)backToItemCountVC:(id)sender
{
    if([sender tag ] == 1002) // Done
    {
        if (_txtCaseQty.text.integerValue == 1 || _txtPackQty.text.integerValue == 1) {
            [self displayAlertWithMessage:@"# of Qty of Cash or Pack could not be same as # of Qty of Single."];
            return;
        }

        if ((_txtCaseQty.text.integerValue > 1 && _txtPackQty.text.integerValue > 1) && (_txtCaseQty.text.integerValue == _txtPackQty.text.integerValue)) {
            [self displayAlertWithMessage:@"# of Qty of Cash,Pack could not be same."];
            return;
        }

        if(![oldCaseValue isEqualToString:_txtCaseQty.text] || ![oldPackValue isEqualToString:_txtPackQty.text])
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            //UpdateCasePackQty(long BranchId, long ItemCode,int CaseQty,int PackQty, string CurrentDate,string RegisterId)
            [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
            [param setValue:self.selectedItem.itemCode forKey:@"ItemCode"];
            
            if (_txtCaseQty.text.length == 0) {
                [param setValue:@"0" forKey:@"CaseQty"];
            } else {
                [param setValue:[NSString stringWithFormat:@"%@",_txtCaseQty.text] forKey:@"CaseQty"];
            }
            
            if (_txtPackQty.text.length == 0) {
                [param setValue:@"0" forKey:@"PackQty"];
            } else {
                [param setValue:[NSString stringWithFormat:@"%@",_txtPackQty.text] forKey:@"PackQty"];
            }
            
            param[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
            
            NSDate *currentDate = [NSDate date];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
            NSString *currentDateValue = [formatter stringFromDate:currentDate];
            [param setValue:currentDateValue forKey:@"CurrentDate"];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self responseUpdateCasePackQtyResponse:response error:error];
                });
            };
            
            self.updateCasePackQtyWC = [self.updateCasePackQtyWC initWithRequest:KURL actionName:WSM_UPDATE_CASE_PACK_QTY params:param completionHandler:completionHandler];

        }
        else
        {
            [self redirectToItemCountListVC];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([sender tag] == 1001) // Back
    {
        if(IsPad())
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Coredata table function

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
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
