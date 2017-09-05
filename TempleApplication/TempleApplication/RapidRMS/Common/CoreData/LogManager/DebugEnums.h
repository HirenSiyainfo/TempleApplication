//
//  DebugEnums.h
//  DebugLog
//
//  Created by Siya9 on 19/01/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#ifndef DebugEnums_h
#define DebugEnums_h

typedef NS_ENUM(NSInteger, UploadStatus)
{
    UpdateStatusNotSent = 1,
    UpdateStatusSent,
    UpdateStatusSentError
};

typedef NS_ENUM(NSInteger, Direction)
{
    DirectionSent = 1,
    DirectionReceive
};

typedef NS_ENUM(NSInteger, Type)
{
    TypeBroadcast = 1,
    TypeAdhoc,
    TypeCommands,
    TypeRapidServer,
    TypeLiveUpdate,
    TypeFusion
};

typedef NS_ENUM(NSInteger, TransactionType)
{
    TransactionTypePrePay = 1,
    TransactionTypePostPay,
    TransactionTypeOutSide,
    TransactionTypeNotAvailable
};

typedef NS_ENUM(NSInteger, CartStatus)
{
    CartStatusNew = 1,
    CartStatusShop,
    CartStatusFull,
    CartStatusDone,
    CartStatusNone
};

#endif /* DebugEnums_h */
