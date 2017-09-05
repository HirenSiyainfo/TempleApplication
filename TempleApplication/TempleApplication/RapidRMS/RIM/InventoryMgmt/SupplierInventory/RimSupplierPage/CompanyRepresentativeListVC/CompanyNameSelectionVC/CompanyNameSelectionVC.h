//
//  CompanyNameSelectionVC.h
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CompanyNameSelectionDelegate

-(void)didSelectedCompanyName:(NSString *)selectedCompanyName SelectedCompanyID:(NSInteger)companyID;

@end

@interface CompanyNameSelectionVC : UIViewController

@property (nonatomic,weak) id<CompanyNameSelectionDelegate> companyNameSelectionDelegate;

@property (nonatomic, strong) NSString *companyNameSelected;

@end