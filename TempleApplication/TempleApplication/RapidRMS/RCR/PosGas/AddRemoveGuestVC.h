//
//  AddRemoveGuestVC.h
//  RapidRMS
//
//  Created by Siya on 07/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddRemoveGuestDelegate<NSObject>

-(void)updateGuestCount:(NSInteger)guestCount withtableName:(NSString *)strtblName;

@end

@interface AddRemoveGuestVC : UIViewController
{
    
}
@property (nonatomic, weak) IBOutlet UITextField *txtTableName;
@property (nonatomic, weak) id<AddRemoveGuestDelegate> addRemoveGuestDelegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *guestCount;
@property (strong, nonatomic) NSString *tableName;
@property (assign, nonatomic) BOOL isdescressGuest;
@end
