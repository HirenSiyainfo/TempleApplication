//
//  RapidItemFilterTypeVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidItemFilterVC.h"

@protocol RapidItemFilterTypeVCDeledate <NSObject>
    -(void)willChangeSelectedFilterTypeItem:(NSArray *)arrFilterItemList withFilterType:(RapidItemFilterType) filterType isApply:(BOOL) isApply;
    -(NSArray *)getSelectedObjectForFilterType:(RapidItemFilterType) filterType;
    -(void)willSetRapidItemFilterPredicate:(NSPredicate *) predicate withFilterDictionary:(NSDictionary *)dictFilterInfo;
    -(void)willChangeRapidFilterIsSlidein:(BOOL)isSlidein;
@end
@interface RapidItemFilterTypeVC : UIViewController
@property (nonatomic, weak) id <RapidItemFilterTypeVCDeledate> deledate;
@property (nonatomic, strong) NSArray * arrFilterTypes;
@property (nonatomic, strong) NSDictionary * dictFilterInfo;

+(NSString *)getStringFromFilterType:(RapidItemFilterType )filtertype;
@end
