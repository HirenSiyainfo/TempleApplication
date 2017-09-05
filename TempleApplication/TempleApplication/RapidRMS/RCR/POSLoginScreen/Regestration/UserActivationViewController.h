//
//  UserActivationViewController.h
//  RapidRMS
//
//  Created by Siya Infotech on 04/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TPKeyboardAvoidingScrollView;


@interface UserActivationViewController : UIViewController <UITextFieldDelegate> {
    
}

-(IBAction)btnSignInClicked:(id)sender;

@property(nonatomic,assign)BOOL bFromDashborad;

@property (nonatomic, strong) UpdateManager *updateManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
