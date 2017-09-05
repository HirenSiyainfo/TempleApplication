//
//  MMDListCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MMDListCellDelegate<NSObject>
    -(void)willDeleteRowAtIndexPath:(NSIndexPath *)indexPath;
    -(void)willEditRowAtIndexPath:(NSIndexPath *)indexPath;
    -(void)willChangeStatusRowAtIndexPath:(NSIndexPath *)indexPath  withNewStatus:(BOOL) isStatus;
@end

@interface MMDListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * lbltitle;
@property (nonatomic, weak) IBOutlet UILabel * lblName;
@property (nonatomic, weak) IBOutlet UILabel * lblCategary;
@property (nonatomic, weak) IBOutlet UISwitch * swiStatus;
@property (nonatomic, weak) IBOutlet UILabel * lblEndDate;
@property (nonatomic, weak) IBOutlet UIButton * btnEdit;
@property (nonatomic, weak) IBOutlet UIButton * btnDelete;
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) id<MMDListCellDelegate> Delegate;
@end
