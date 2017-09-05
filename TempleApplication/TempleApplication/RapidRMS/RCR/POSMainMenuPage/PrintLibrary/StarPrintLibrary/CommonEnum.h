//
//  CommonEnum.h
//  IOS_SDK
//
//  Created by u3237 on 13/04/09.
//
//

typedef NS_ENUM(unsigned int, CorrectionLevelOption)
{
    Low = 0,
    Middle = 1,
    Q = 2,
    High = 3
};

typedef NS_ENUM(unsigned int, Model)
{
    Model1 = 0,
    Model2 = 1
};

typedef NS_ENUM(unsigned int, CutType)
{
    FULL_CUT = 0,
    PARTIAL_CUT = 1,
    FULL_CUT_FEED = 2,
    PARTIAL_CUT_FEED = 3
};

typedef NS_ENUM(unsigned int, Alignment)
{
    Left = 0,
    Center = 1,
    Right = 2
};

typedef NS_ENUM(unsigned int, SensorActive)
{
    NoDrawer = 0,
    SensorActiveHigh = 1,
    SensorActiveLow = 2
};
