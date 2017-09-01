//
//  AppDelegate.h
//  TempleApplication
//
//  Created by Siya-ios5 on 9/1/17.
//  Copyright © 2017 Siya-ios5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

