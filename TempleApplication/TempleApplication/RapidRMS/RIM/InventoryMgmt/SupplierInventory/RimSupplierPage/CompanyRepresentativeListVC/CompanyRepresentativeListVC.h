//
//  CompanyRepresentativeListVC.h
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CompanyRepresentativeDelegate

-(void)didSelectCompnayRepresentatives:(NSMutableArray *)selectedRerepsentative;

@end

@interface CompanyRepresentativeListVC : UIViewController


@property (nonatomic, weak) id<CompanyRepresentativeDelegate> companyRepresentativeDelegate;

@property (nonatomic, strong) NSMutableArray *selectedSalesRepresentative;
@property (nonatomic, strong) NSNumber *supplierRepresentativeId;
@property (nonatomic, strong) NSString *callingFunction;

@end
