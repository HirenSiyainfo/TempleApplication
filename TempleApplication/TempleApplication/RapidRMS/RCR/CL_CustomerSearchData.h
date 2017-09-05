//
//  CL_CustomerSearchData.h
//  RapidRMS
//
//  Created by siya-IOS5 on 12/9/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CS_SearchType) {
    CS_SearchType_Today,
    CS_SearchType_YesterDay,
    CS_SearchType_Monthly,
    CS_SearchType_Weekly,
    CS_SearchType_Quarterly,
    CS_SearchType_Yearly,
    CS_SearchType_Nov2015,
    CS_SearchType_JanToDec2015,
    CS_SearchType_Nov2014,
    CS_SearchType_JanToDec2014,
    CS_SearchType_TillDateHistory,
    CS_SearchType_DateRange,
};

@interface CL_CustomerSearchData : NSObject

@property (assign) CS_SearchType cl_SelectedSerachType;

@property (nonatomic,strong) NSDate *startDateRange;
@property (nonatomic,strong) NSDate *endDateRange;

-(NSString *)dateSearchString:(CS_SearchType)cs_SearchType;
-(NSString *)webserviceParameterStringFor:(CS_SearchType)cs_SearchType;
-(NSString *)fromDateToStartdateStringFor:(CS_SearchType)cs_SearchType;

@end
