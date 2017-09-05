//
//  RapidItemFilterVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, RapidItemFilterType)
{
    RapidItemFilterTypeDepartment,
    RapidItemFilterTypeSubDepartment,
    RapidItemFilterTypeVendor,
    RapidItemFilterTypeGroup,
    RapidItemFilterTypeTag,
    RapidItemFilterTypeSearchedItem,
//    RapidItemFilterTypeSearchedkeyword,
    RapidItemFilterTypeCategories,
};
#define DEFAULT_FILTER_SAVED @"DEFAULT_CUSTOM_FILTER"
//#define IS_CLICK_TO_SEARCH
@protocol RapidItemFilterVCDeledate <NSObject>
@required
    -(void)willSetRapidItemFilterPredicate:(NSPredicate *) predicate withFilterDictionary:(NSDictionary *)dictFilterInfo;
    -(void)willChangeRapidFilterIsSlidein:(BOOL)isSlidein;
@end
@interface RapidItemFilterVC : UIViewController

@property (nonatomic, weak) id <RapidItemFilterVCDeledate> deledate;
@property (nonatomic, strong) NSMutableDictionary * dictFilterInfo;

-(void)filterViewSlideIn:(BOOL)isSlideIn;
@end
