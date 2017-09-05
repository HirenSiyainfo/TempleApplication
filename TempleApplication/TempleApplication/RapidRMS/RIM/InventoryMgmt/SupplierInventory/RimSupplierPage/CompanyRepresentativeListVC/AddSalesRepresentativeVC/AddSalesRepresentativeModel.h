//
//  AddSalesRepresentativeModel.h
//  RapidRMS
//
//  Created by Siya9 on 24/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, AddSalesCell)
{
    AddVanderCellSelection,
    AddSalesCellName,
    AddSalesCellPosition,
    AddSalesCellAdd1,
    AddSalesCellAdd2,
    AddSalesCellCity,
    AddSalesCellState,
    AddSalesCellPin,
    AddSalesCellZone,
    AddSalesCellPhone,
    AddSalesCellPhoneList,
    AddSalesCellEmail
};


@interface AddSalesRepresentativeModel : NSObject

@property (nonatomic, strong) NSString * strVanderName;
@property (nonatomic, strong) NSString * strSalesName;
@property (nonatomic, strong) NSString * strSalesPosition;
@property (nonatomic, strong) NSString * strSalesAdd1;
@property (nonatomic, strong) NSString * strSalesAdd2;
@property (nonatomic, strong) NSString * strSalesCity;
@property (nonatomic, strong) NSString * strSalesState;
@property (nonatomic, strong) NSString * strSalesPin;
@property (nonatomic, strong) NSString * strSalesZone;
@property (nonatomic, strong) NSString * strSalesPhone;
@property (nonatomic, strong) NSString * strSalesEmail;


@end
