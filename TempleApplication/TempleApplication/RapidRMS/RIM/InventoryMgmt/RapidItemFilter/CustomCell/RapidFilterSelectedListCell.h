//
//  RapidFilterSelectedListCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 08/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPTagList.h"
#import "RapidItemFilterVC.h"

@protocol RapidFilterSelectedListCellDeledate <NSObject>
@required
    -(void)willCellChangeSelectedFilterTypeItemlist:(NSArray *)arrNewFilterItemList withFilterType:(RapidItemFilterType) filterType;
@end

@interface RapidFilterSelectedListCell : UITableViewCell

@property (nonatomic, weak) id <RapidFilterSelectedListCellDeledate> deledate;

@property (nonatomic, weak) IBOutlet MPTagList * itemList;
@property (nonatomic, weak) IBOutlet UILabel * lblTitle;

-(void)configureCellToItem:(NSArray *)arrItem withMasterType:(RapidItemFilterType) filter_Type withTitle:(NSString *) strTitle;
-(void)configureCellToPhone:(NSArray *)arrItem withTitle:(NSString *) strTitle;
@end
