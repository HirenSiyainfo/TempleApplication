//
//  OfflineReportCalculation.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfflineReportCalculation : NSObject
{
    NSMutableArray *onlineReportArray;

}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (instancetype)initWithArray:(NSMutableArray *)onlineReportDetail withZid:(NSString *)Zid NS_DESIGNATED_INITIALIZER;
-(void)updateReportWithOfflineDetail;

@end
