//
//  MMDItemSelectionCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MMDItemSelectionCellDelegate<NSObject>
    -(void)didDeleteRowAtIndexPath:(NSIndexPath *)indexPath;
@end
@interface MMDItemSelectionCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * lblUPC;
@property (nonatomic, weak) IBOutlet UILabel * lblName;
@property (nonatomic, weak) IBOutlet UILabel * lblPrice;
@property (nonatomic, weak) IBOutlet UIButton * btnDelete;
@property (nonatomic, weak) IBOutlet UIImageView * imgSelected;
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) id<MMDItemSelectionCellDelegate> Delegate;
@end
