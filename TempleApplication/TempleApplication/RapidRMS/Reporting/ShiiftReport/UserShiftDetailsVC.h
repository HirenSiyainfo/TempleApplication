//
//  UserShiftDetailsVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 19/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserShiftDetailsVCDelegate
- (void)didHistoryButtonTapped;
- (void)didShiftCloseSuccessfully;
- (void)didGenerateHtml:(NSString *)html andPrintArray:(NSArray *)printArray forHistory:(BOOL)isForHistory emailHtmlPath:(NSString *)sourcePath;
- (void)didUserShiftServiceCall;
- (void)didGetResponseOfUserShiftServiceCall;
@end

@interface UserShiftDetailsVC : UIViewController
@property (nonatomic, weak) id <UserShiftDetailsVCDelegate> userShiftDetailsVCDelegate;

- (void)getCurrentShiftDetails;
- (void)accessShiftHistoryDetailsUsing:(NSDictionary *)shiftDetailsDictionary;
- (void)loadShiftReportEmail;
- (void)loadHtmlForUserShiftUsing:(NSString *)html;

@property (assign, nonatomic) BOOL isShifInOutFromReport;

@end
