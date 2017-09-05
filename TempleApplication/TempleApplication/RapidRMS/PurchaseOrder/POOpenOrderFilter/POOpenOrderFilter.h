//
//  POOpenOrderFilter.h
//  RapidRMS
//
//  Created by Siya10 on 16/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,OpenOrderFilterType)
{
    OpenOrderFilterTypeDepartment,
    OpenOrderFilterTypeVendor,
    OpenOrderFilterTypeManual,
};

@protocol POOpenOrderFilteDelegate <NSObject>

-(void)didapplyFilterToItems:(NSMutableArray *)deptArray withSup:(NSMutableArray *)supArray;

-(void)didloadManuelFilterOption;

@end

#define DEFAULT_FILTER_SAVED @"DEFAULT_CUSTOM_FILTER"

@interface POOpenOrderFilter : UIViewController

@property (nonatomic, strong) NSMutableDictionary * dictFilterInfo;
@property (nonatomic, strong) NSMutableArray * suppArray;
@property (nonatomic, strong) NSMutableArray * deptArray;
@property (nonatomic, strong) id <POOpenOrderFilteDelegate> poOpenOrderFilterDelegate;
-(void)filterViewSlideIn:(BOOL)isSlideIn;
@end
