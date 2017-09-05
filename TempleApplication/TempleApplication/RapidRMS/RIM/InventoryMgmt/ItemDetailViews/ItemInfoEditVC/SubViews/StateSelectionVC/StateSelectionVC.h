//
//  StateSelectionVC.h
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StateSelectionDelegate

-(void)selectedState:(NSString *)selectedState;

@end

@interface StateSelectionVC : UIViewController

@property (nonatomic, weak) id<StateSelectionDelegate> stateSelectionDelegate;
@property (nonatomic, strong) NSString *selectedState;

@end