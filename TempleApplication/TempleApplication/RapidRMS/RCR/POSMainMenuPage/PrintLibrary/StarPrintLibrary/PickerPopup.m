//
//  PickerPopup.m
//  IOS_SDK
//
//  Created by Tzvi on 8/3/11.
//  Copyright 2011 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "PickerPopup.h"


@implementation PickerPopup

-(instancetype)init
{
    self = [super init];
    if(self != nil)
    {
        my_DataSource = nil;
        selectedIndex = 0;
        listener = nil;
        listenerObject = nil;
        cell = nil;
    }
    return self;
}

-(void)setListener:(SEL)selector :(NSObject*)object
{
    listener = selector;
    listenerObject = object;
}

-(void)setDataSource:(NSMutableArray *)dataSource
{
    if(my_DataSource != nil)
    {
        [my_DataSource release];
    }
    my_DataSource = dataSource;
    [dataSource retain];
    selectedIndex = 0;
}

-(void)dealloc
{
    if(my_DataSource != nil)
    {
        [my_DataSource release];
        [cell release];
    }
    if(cell != nil)
    {
        [cell release];
    }
    [super dealloc];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(my_DataSource == nil)
        return 0;
    return my_DataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(my_DataSource == nil)
        return @"";
	return my_DataSource[row];
}

-(void)showPicker
{
    //[uipickerview_narrowwide setFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    actionSheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [pickerView selectRow:selectedIndex inComponent:0 animated:NO];
    
    [actionSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:@[@"Done"]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0, 50.0, 30.0);
   // closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    [closeButton release];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    actionSheet.bounds = CGRectMake(0, 0, 320, 485);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedIndex = row;
}

-(void)dismissActionSheet:(id)sender
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [actionSheet release];
    if(listener != nil)
    {
        if([listenerObject respondsToSelector:listener] == TRUE)
        {
          [listenerObject performSelector:listener];
        }
    }
}

-(NSInteger)getSelectedIndex
{
    return selectedIndex;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if(cell != nil)
    {
        [cell release];
        cell = nil;
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if(my_DataSource != nil)
        {
            cell.textLabel.text = my_DataSource[selectedIndex];
        }
    }
    // Configure the cell...
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showPicker];
}

@end
