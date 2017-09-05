//
//  TenderShortcutVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 10/31/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TenderShortCutDelegate <NSObject>

-(void)didTenderTransactionUsingTenderType :(NSString *)tenderType withPayId:(NSNumber*)payId;

@end

@interface TenderShortcutVC : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic ,weak)  id<TenderShortCutDelegate> tenderShortCutDelegate;

@end
