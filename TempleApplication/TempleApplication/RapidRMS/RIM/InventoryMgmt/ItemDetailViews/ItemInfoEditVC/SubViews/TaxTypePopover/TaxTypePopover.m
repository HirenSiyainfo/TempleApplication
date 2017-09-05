//
//  DepartmentViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 12/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "TaxTypePopover.h"

#define CancelButton 101
#define DoneButton 102


@interface TaxTypePopover () {
    
    NSInteger IndexSound;
    MICheckBox * taxCheckBox;
}
@property (nonatomic, weak) IBOutlet UITableView * aTableView;

@property (nonatomic) NSInteger objectIndex;
@property (nonatomic, strong) NSString *deptCalling;
@property (nonatomic, strong) NSString *strDeptName;
@property (nonatomic, strong) NSMutableArray *checkedDepartment;


@end



@implementation TaxTypePopover

@synthesize getTaxName;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    IndexSound = -1;
}

- (IBAction) toolBarActionHandler:(id)sender {
	switch ([sender tag]) {
		case CancelButton:
#if 1
            [self.taxTypePopoverDelegate didCancelTaxType];
#else
            if([self.objAddDelegate.lblItemtax.text isEqualToString:@""])
            {
                [self.objAddDelegate.onOffSwitch setOn:NO];
            }
#endif
//            [self.view removeFromSuperview];
			break;
		case DoneButton:
#if 1
            [self.taxTypePopoverDelegate didSelectTaxType:taxCheckBox.indexPath.row];
#else
            self.objAddDelegate.lblItemtax.text = self.selectedTaxType;
            [self.objAddDelegate CallTaxwise];
#endif
//            [self.view removeFromSuperview];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _resposeTaxArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
	taxTypeName.text = _resposeTaxArray[indexPath.row];
	taxTypeName.numberOfLines = 0;
	taxTypeName.textAlignment = NSTextAlignmentLeft;
	taxTypeName.backgroundColor = [UIColor clearColor];
	taxTypeName.textColor = [UIColor blackColor];
	taxTypeName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
	[cell.contentView addSubview:taxTypeName];
	
    if (IndexSound==indexPath.row)
    {
        [taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
        taxTypeName.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
    }
    
	[cell.contentView addSubview:taxCheckBox];
    if([taxTypeName.text isEqualToString:self.getTaxName])
    {
        IndexSound = indexPath.row;
        [taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
        self.selectedTaxType = self.getTaxName;
        taxTypeName.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    taxCheckBox.indexPath = [indexPath copy];
    [taxCheckBox checkBoxClicked];
    [tableView reloadData];
}

#pragma mark -
#pragma mark Logic Implement

- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath
{
    IndexSound=indexPath.row;
    [_aTableView reloadData];
    self.selectedTaxType = _resposeTaxArray[IndexSound];
    self.getTaxName = @"";
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

@end
