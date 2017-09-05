//
//  POFilterOption.h
//  RapidRMS
//
//  Created by Siya10 on 15/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PORapidItemFilterType)
{
    PORapidItemFilterTypeDepartment,
    PORapidItemFilterTypeSubDepartment,
    PORapidItemFilterTypeVendor,
    PORapidItemFilterTypeGroup,
    PORapidItemFilterTypeTag,
    PORapidItemFilterTypeSearchedItem,
    PORapidItemFilterTypeCategories,
    
};
#define DEFAULT_FILTER_SAVED @"DEFAULT_CUSTOM_FILTER"
//#define IS_CLICK_TO_SEARCH
@protocol PORapidItemFilterVCDeledate <NSObject>
@required
-(void)willSetRapidItemFilterPredicate:(NSPredicate *) predicate withFilterDictionary:(NSDictionary *)dictFilterInfo;
-(void)willChangeRapidFilterIsSlidein:(BOOL)isSlidein;
@end
@interface POFilterOption : UIViewController

@property (nonatomic, weak) id <PORapidItemFilterVCDeledate> deledate;
@property (nonatomic, strong) NSMutableDictionary * dictFilterInfo;

-(void)filterViewSlideIn:(BOOL)isSlideIn;


@end
