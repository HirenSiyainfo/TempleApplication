//
//  POFilterType.h
//  RapidRMS
//
//  Created by Siya10 on 18/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol POFilterTypeDelegate <NSObject>

-(void)applyFilterButton:(NSMutableArray *)deptArray withSup:(NSMutableArray *)supArray;

-(void)didloadManualFilterOption;

@end

@interface POFilterType : UIViewController

@property (nonatomic, strong) NSMutableArray *suppArray;
@property (nonatomic, strong) NSMutableArray *deptArray;
@property (nonatomic, weak) id <POFilterTypeDelegate> filterTypedelegate;

@end
