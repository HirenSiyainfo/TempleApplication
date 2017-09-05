//
//  RapidItemFilterTypeItemVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidItemFilterVC.h"
@protocol RapidItemFilterTypeItemVCDeledate <NSObject>
-(void)willChangeSelectedFilterTypeItem:(NSArray *)arrFilterItemList withFilterType:(RapidItemFilterType) filterType;
-(void)willApplyFilter;
@end

@interface RapidItemFilterTypeItemVC : UIViewController {
    NSArray * arrMasterTitle;
}

@property (nonatomic, weak) id <RapidItemFilterTypeItemVCDeledate> deledate;
@property (nonatomic) RapidItemFilterType filterType;

@property (nonatomic, weak) IBOutlet UITableView * tblMasterList;
@property (nonatomic, weak) IBOutlet UITextField * txtSearchText;
@property (nonatomic, weak) IBOutlet UILabel * lblMasterTitle;
@property (nonatomic, weak) IBOutlet UILabel * lblMasterCount;


@property (nonatomic, strong) NSMutableArray * arrFilterTypesSelectedItems;

@end
