/**
 ClassName:: UITableViewCell
 
 Superclass::  N?A
 
 Class Description::This category is used for implementation of custom cell.
 
 Version::  1.0
 
 Author:: Nilesh Patel
 
 Copy Right:: eStorage
 */

#import <UIKit/UIKit.h>


@interface UITableViewCell (NIB)

+ (NSString*)cellID;
+ (NSString*)nibName;

+ (id)dequeOrCreateInTable:(UITableView*)tableView;

@end
