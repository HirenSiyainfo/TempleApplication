/**
 ClassName:: UITableViewCell
 
 Superclass::  N?A
 
 Class Description::This category is used for implementation of custom cell.
 
 Version::  1.0
 
 Author:: Nilesh Patel
 
 Copy Right:: eStorage
 */

#import "UITableViewCell+NIB.h"

@implementation UITableViewCell (NIB)

/**
 * loadCell()
 * @desc load uitableview view cell in run time
 * @return id is uitableview cell
 */

+ (id)loadCell 
{
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
	
	for (id object in objects)
	{
		if ([object isKindOfClass:self])
		{
			UITableViewCell *cell = object;
			[cell setValue:[self cellID] forKey:@"_reuseIdentifier"];	
			return cell;
		}
	}

	[NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one TableViewCell, and its class must be '%@'", [self nibName], [self class]];	
	
	return nil;
}

/**
 * cellID()
 * @desc giving the description of Uitableview cell 
 * @return NSString is uitableview cellID
 */

+ (NSString*)cellID
{
	return [self description]; 
}

/**
 * nibName()
 * @desc giving the description of nibName 
 * @return NSString is nibName of uitableview cell
 */

+ (NSString*)nibName { return [self description]; }

/**
 * dequeOrCreateInTable()
 * @desc getting the refernece of uitable view cell
 * @param UITableView tableView for get reference of UITableview
 * @return id is patricular cell where editing
 */

+ (id)dequeOrCreateInTable:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[self cellID]];
	return cell ? cell : [self loadCell];
}

@end
