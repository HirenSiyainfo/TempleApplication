//
//  popOverController.m
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "WeightScalePopOverDelegate.h"
#import "RmsDbController.h"
//#import "WeightScalePopup.h"

@interface WeightScalePopOverDelegate () {
    NSNumberFormatter *currencyFormat;
    NSInteger IndexSound;
    MICheckBox * taxCheckBox;
}

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UILabel *lblMeasurement;
@property (nonatomic, weak) IBOutlet UIButton *measurementClicked;
@property (nonatomic, weak) IBOutlet UITableView *tblMeasurement;
@property (nonatomic, weak) IBOutlet UITextField * topinPrice;

@property (nonatomic, strong) NSString *getselectedUnitType;
@property (nonatomic, strong) NSString *selectedUnitType;

@property (nonatomic, strong) NSMutableArray *weightScaleArray;
@end

@implementation WeightScalePopOverDelegate

@synthesize topinPrice;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.weightScaleArray = [[NSMutableArray alloc] initWithObjects:@"gr",@"kg",@"lb",@"oz" ,nil ];
    
    self.tblMeasurement.hidden = YES;
    self.tblMeasurement.layer.borderColor = [UIColor lightGrayColor].CGColor ;
    self.tblMeasurement.layer.borderWidth = 0.5f;
    
    UITextField *inputTextField = (UITextField *)self.inputControl;
    inputTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:153.0/255.0 alpha:1.0];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
}

// tender keypad action
- (IBAction) tenderNumPadButtonAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 2;
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (topinPrice.text==nil )
        {
            topinPrice.text=@"";
        }
        topinPrice.text = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        NSString * displyValue = [topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        topinPrice.text = displyValue;
	}
    else if ([sender tag] == -98)
    {
		if (topinPrice.text.length > 0)
        {
            topinPrice.text = [topinPrice.text substringToIndex:topinPrice.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (topinPrice.text.length > 0)
        {
            topinPrice.text = @"";
		}
	}
    else if ([sender tag] == 101)
    {
        topinPrice.text = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        NSString * displyValue = [topinPrice.text stringByAppendingFormat:@"00"];
        topinPrice.text = displyValue;
	}
}

- (IBAction)enterClicked:(id)sender
{
    NSInteger qty = topinPrice.text.integerValue;
    if(qty == 0)
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Unit qty should be 1 or greater than 1" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        topinPrice.text = @"";
        return;
    }
    if([self.topinPrice.text isEqualToString:@""])
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please enter unit Qty" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        topinPrice.text = @"";
        return;
    }
    if([self.lblMeasurement.text isEqualToString:@""])
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please select weight scale type" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;
    }
    UITextField *inputTextField = (UITextField *)self.inputControl;
    inputTextField.backgroundColor = [UIColor clearColor];
    NSString *inputValue = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    [self.weightScaleDelegate didEnterWeightScale:self.inputControl inputValue:inputValue.floatValue unitType:self.lblMeasurement.text];
}

- (IBAction)cancelClicked:(id)sender
{
    UITextField *inputTextField = (UITextField *)self.inputControl;
    inputTextField.backgroundColor = [UIColor clearColor];
	[self.weightScaleDelegate didCancelWeightScale];
}

-(IBAction)weightScaleClicked:(id)sender
{
//    [self.rmsDbController playButtonSound];
//    objWeightScalePopup = [[WeightScalePopup alloc] initWithNibName:@"WeightScalePopup" bundle:nil];
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) // iPhone tableview frame set
//    {
//        CGRect screenBounds = [[UIScreen mainScreen] bounds];
//        if(screenBounds.size.height == 568)
//        {
//            objWeightScalePopup.view.frame=CGRectMake(10, 260, objWeightScalePopup.view.frame.size.width, objWeightScalePopup.view.frame.size.height);
//        }
//        else
//        {
//            objWeightScalePopup.view.frame=CGRectMake(10, 180, objWeightScalePopup.view.frame.size.width, objWeightScalePopup.view.frame.size.height);
//        }
//    }
//    else
//    {
//        objWeightScalePopup.view.frame=CGRectMake(10, 250, objWeightScalePopup.view.frame.size.width, objWeightScalePopup.view.frame.size.height);
//    }
//    objWeightScalePopup.resposeTaxArray = [[NSMutableArray alloc] initWithObjects:@"gm",@"kg",@"lb",@"oz" ,nil ];
//    objWeightScalePopup.getTaxName = self.lblMeasurement.text;
//    objWeightScalePopup.objWeightPopup = self;
//    [self.view addSubview:objWeightScalePopup.view];
    
    
    self.tblMeasurement.hidden = NO;
    IndexSound = -1;
    self.getselectedUnitType = self.lblMeasurement.text;
    [self.view bringSubviewToFront:self.tblMeasurement];
    [self.tblMeasurement reloadData];
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.weightScaleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
	taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
	[taxCheckBox setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[taxCheckBox setTitle:@"" forState:UIControlStateNormal];
	taxCheckBox.tag = indexPath.row;
	taxCheckBox.indexPath = [indexPath copy];
	taxCheckBox.delegate = self;
    taxCheckBox.userInteractionEnabled = NO;
    taxCheckBox.isChecked = NO;
	[taxCheckBox setDefault];
    
    UILabel * taxTypeName = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 150, 30)];
	taxTypeName.text = (self.weightScaleArray)[indexPath.row];
	taxTypeName.textAlignment = NSTextAlignmentLeft;
	//taxTypeName.backgroundColor = [UIColor clearColor];
	taxTypeName.textColor = [UIColor blackColor];
	taxTypeName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
	[cell.contentView addSubview:taxTypeName];
	
    if (IndexSound==indexPath.row)
    {
        [taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
        taxTypeName.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
    }
    
	[cell.contentView addSubview:taxCheckBox];
    if([taxTypeName.text isEqualToString:self.getselectedUnitType])
    {
        IndexSound = indexPath.row;
        [taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
        self.selectedUnitType = self.getselectedUnitType;
        taxTypeName.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    taxCheckBox.indexPath = [indexPath copy];
    [taxCheckBox checkBoxClicked];
    [tableView reloadData];
    self.lblMeasurement.text = (self.weightScaleArray)[indexPath.row];
    self.tblMeasurement.hidden = YES;
}

#pragma mark -
#pragma mark Logic Implement

- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath
{
    IndexSound=indexPath.row;
    [self.tblMeasurement reloadData];
    self.selectedUnitType = (self.weightScaleArray)[IndexSound];
    self.getselectedUnitType = @"";
}

-(void)setWeightScaleType:(NSString *)scaleType
{
    self.lblMeasurement.text = scaleType;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UITextField *inputTextField = (UITextField *)self.inputControl;
    inputTextField.backgroundColor = [UIColor clearColor];
}

@end