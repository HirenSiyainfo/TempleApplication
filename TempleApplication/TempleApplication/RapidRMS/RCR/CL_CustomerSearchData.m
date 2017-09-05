//
//  CL_CustomerSearchData.m
//  RapidRMS
//
//  Created by siya-IOS5 on 12/9/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CL_CustomerSearchData.h"

@implementation CL_CustomerSearchData


-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.cl_SelectedSerachType = -1;
         self.startDateRange = nil;
         self.endDateRange = nil;
    }
    return self;
}

-(NSString *)dateSearchString:(CS_SearchType)cs_SearchType
{
  NSString *dateSearchString = @"";
    
    switch (cs_SearchType) {
       
        case CS_SearchType_Today:
            dateSearchString = @"Today";
            break;
        case CS_SearchType_YesterDay:
            dateSearchString = @"Yesterday";
            break;

        case CS_SearchType_Monthly:
            dateSearchString = @"Monthly";
            break;
        
        case CS_SearchType_Weekly:
            dateSearchString = @"Weekly";
            break;
      
        case CS_SearchType_Quarterly:
            dateSearchString = @"Quarterly";

            break;
        case CS_SearchType_Yearly:
            dateSearchString = @"Yearly";
            break;
            
        case CS_SearchType_Nov2015:
            dateSearchString = [self displayCurrentMonthWithYear];
            break;
        
        case CS_SearchType_JanToDec2015:
            dateSearchString = [NSString stringWithFormat:@"Jan/%@",[self displayCurrentMonthWithYear]];
            break;
            
        case CS_SearchType_Nov2014:
            dateSearchString = [self displayPriviousYearWithCurrentMonth:[self monthWithYearFormatter]];
            break;

        case CS_SearchType_JanToDec2014:
            dateSearchString = [NSString stringWithFormat:@"Jan/%@",[self displayPriviousYearWithCurrentMonth:[self monthWithYearFormatter]]];
            break;
            
        case CS_SearchType_TillDateHistory:
            break;
            
        case CS_SearchType_DateRange:
            break;
            
        default:
            break;
    }
    return dateSearchString;
}

- (NSDateFormatter *)monthWithYearFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM yyyy";
    return dateFormatter;
}

-(NSString *)displayCurrentMonthWithYear
{
    NSDateFormatter * dateFormatter = [self monthWithYearFormatter];
    NSDate *today = [NSDate date];
   return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:today].capitalizedString];
}

-(NSString *)displayPriviousYearWithCurrentMonth:(NSDateFormatter *)formatter
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear fromDate:[[NSDate alloc] init]];
    NSDate *today = [[NSDate alloc] init];
    components.year = -1;
    NSDate *priviousYear = [cal dateByAddingComponents:components toDate: today options:0];

    return [NSString stringWithFormat:@"%@",[formatter stringFromDate:priviousYear].capitalizedString];
}
-(NSString *)displayCurrentYearWithCurrentMonth:(NSDateFormatter *)formatter
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear fromDate:[[NSDate alloc] init]];
    NSDate *today = [[NSDate alloc] init];
    components.year = 0;
    NSDate *priviousYear = [cal dateByAddingComponents:components toDate: today options:0];
    
    return [NSString stringWithFormat:@"%@",[formatter stringFromDate:priviousYear].capitalizedString];
}

-(NSString *)webserviceParameterStringFor:(CS_SearchType)cs_SearchType
{
    NSString *webserviceParameterString = @"";
    
    switch (cs_SearchType) {
            
        case CS_SearchType_Today:
            webserviceParameterString = @"Hourly";
            break;
        case CS_SearchType_YesterDay:
            webserviceParameterString = @"Daily";
            break;
            
        case CS_SearchType_Monthly:
            webserviceParameterString = @"Monthly";
            break;
            
        case CS_SearchType_Weekly:
            webserviceParameterString = @"Weekly";
            break;
            
        case CS_SearchType_Quarterly:
            webserviceParameterString = @"Quarterly";
            
            break;
        case CS_SearchType_Yearly:
            webserviceParameterString = @"Yearly";
            break;
            
        case CS_SearchType_Nov2015:
            webserviceParameterString = @"CurrentMonth";
            break;
            
        case CS_SearchType_JanToDec2015:
            webserviceParameterString = @"CurrentYear";
            break;
            
        case CS_SearchType_Nov2014:
            webserviceParameterString = @"lastmonth";
            break;
            
        case CS_SearchType_JanToDec2014:
            webserviceParameterString = @"LastYear";
            break;
            
        case CS_SearchType_TillDateHistory:
            break;
            
        case CS_SearchType_DateRange:
            webserviceParameterString = @"Custom";
            break;
            
        default:
            break;
    }
    return webserviceParameterString;
}


- (NSDateFormatter *)monthWithYearAndDateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM yyyy";
    return dateFormatter;
}
-(NSDateFormatter *)yearFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    return dateFormatter;
}

-(NSString *)currentDayString
{
    NSDateFormatter * dateFormatter = [self monthWithYearAndDateFormatter];
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]].capitalizedString];
}
-(NSString *)yesterdayString
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
    NSDate *today = [[NSDate alloc] init];
    components.day = -1;
    NSDate *yesterDay = [cal dateByAddingComponents:components toDate: today options:0];
    NSDateFormatter * dateFormatter = [self monthWithYearAndDateFormatter];
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:yesterDay].capitalizedString];
}

-(NSString *)weeklyDateString
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
    NSDate *today = [[NSDate alloc] init];
    components.day = -7;
    NSDate *weekStartDate = [cal dateByAddingComponents:components toDate: today options:0];
    NSDateFormatter * dateFormatter = [self monthWithYearAndDateFormatter];
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:weekStartDate].capitalizedString];
}


-(NSString *)quarterlyDateString
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitMonth fromDate:[[NSDate alloc] init]];
    NSDate *today = [[NSDate alloc] init];
    components.month = -3;
    NSDate *weekStartDate = [cal dateByAddingComponents:components toDate: today options:0];
    NSDateFormatter * dateFormatter = [self monthWithYearAndDateFormatter];
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:weekStartDate].capitalizedString];
}

-(NSString *)monthlyDateString
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitMonth fromDate:[[NSDate alloc] init]];
    NSDate *today = [[NSDate alloc] init];
    components.month = -1;
    NSDate *weekStartDate = [cal dateByAddingComponents:components toDate: today options:0];
    NSDateFormatter * dateFormatter = [self monthWithYearAndDateFormatter];
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:weekStartDate].capitalizedString];
}

-(NSString *)fromDateToStartdateStringFor:(CS_SearchType)cs_SearchType
{
    NSString *fromToStartDateString = @"";
    
    NSString *fromDate = @"";
    
    NSString *toDate = @"";

    
    switch (cs_SearchType) {
            
        case CS_SearchType_Today:
        
            fromDate = [self currentDayString];
            toDate = [self currentDayString];
            
            break;
       
        case CS_SearchType_YesterDay:

            fromDate = [self yesterdayString];
            toDate = [self yesterdayString];
            
            break;
            
        case CS_SearchType_Monthly:
            fromDate = [self monthlyDateString];
            toDate = [self currentDayString];
            break;
            
        case CS_SearchType_Weekly:
            
            fromDate = [self weeklyDateString];
            toDate = [self currentDayString];

            break;
            
        case CS_SearchType_Quarterly:

            fromDate = [self quarterlyDateString];
            toDate = [self currentDayString];
            
            break;
        case CS_SearchType_Yearly:
            
            fromDate = [self displayPriviousYearWithCurrentMonth:[self monthWithYearAndDateFormatter]];
            toDate = [self currentDayString];

            break;
            
        case CS_SearchType_Nov2015:
//            fromToStartDateString = @"CurrentMonth";
            fromDate = [NSString stringWithFormat:@"01 %@",[self displayCurrentMonthWithYear]];
            toDate = [self currentDayString];


            break;
            
        case CS_SearchType_JanToDec2015:

            fromDate = [NSString stringWithFormat:@"01 January %@",[self displayCurrentYearWithCurrentMonth:[self yearFormatter]]];
            toDate = [self currentDayString];

            break;
            
        case CS_SearchType_Nov2014:
            fromDate = [NSString stringWithFormat:@" %@",[self displayPriviousYearWithCurrentMonth:[self monthWithYearFormatter]]];
            toDate = [NSString stringWithFormat:@" %@",[self displayPriviousYearWithCurrentMonth:[self monthWithYearFormatter]]];
            break;
            
        case CS_SearchType_JanToDec2014:
            
            fromDate = [NSString stringWithFormat:@"01 January %@",[self displayPriviousYearWithCurrentMonth:[self yearFormatter]]];
            toDate = [NSString stringWithFormat:@"31 December %@",[self displayPriviousYearWithCurrentMonth:[self yearFormatter]]];

            break;
            
        case CS_SearchType_TillDateHistory:
            break;
            
        case CS_SearchType_DateRange:
            
            fromDate = [NSString stringWithFormat:@" %@",[self selecteddateTimeFormat:self.startDateRange]];
            toDate = [NSString stringWithFormat:@"%@",[self selecteddateTimeFormat:self.endDateRange]];
            break;
            
        default:
            break;
    }
    fromToStartDateString = [NSString stringWithFormat:@"%@ - %@",fromDate,toDate];
    NSLog(@"fromToStartDateString = %@",fromToStartDateString);
    return fromToStartDateString;
}

- (NSString *)selecteddateTimeFormat:(NSDate *)DateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMM yyyy hh:mm a";
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:DateTime].capitalizedString];
}






@end
