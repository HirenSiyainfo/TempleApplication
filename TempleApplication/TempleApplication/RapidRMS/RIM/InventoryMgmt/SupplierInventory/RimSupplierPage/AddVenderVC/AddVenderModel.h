//
//  AddVenderModel.h
//  RapidRMS
//
//  Created by Siya9 on 23/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, AddVenderCell)
{
    //    info
    AddVenderCellName,
    AddVenderCellAdd1,
    AddVenderCellAdd2,
    AddVenderCellCity,
    AddVenderCellState,
    AddVenderCellPin,
    AddVenderCellZone,
    AddVenderCellPhone,
    AddVenderCellPhoneList,
    AddVenderCellEmail
};
@interface AddVenderModel : NSObject

@property (nonatomic, strong) NSString * strVanderName;
@property (nonatomic, strong) NSString * strVanderAdd1;
@property (nonatomic, strong) NSString * strVanderAdd2;
@property (nonatomic, strong) NSString * strVanderCity;
@property (nonatomic, strong) NSString * strVanderState;
@property (nonatomic, strong) NSString * strVanderPin;
@property (nonatomic, strong) NSString * strVanderZone;
@property (nonatomic, strong) NSString * strVanderPhone;
@property (nonatomic, strong) NSString * strVanderEmail;

@end
