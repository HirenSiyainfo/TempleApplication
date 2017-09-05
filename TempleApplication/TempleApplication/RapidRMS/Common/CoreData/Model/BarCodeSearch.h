//
//  BarCodeSearch.h
//  RapidRMS
//
//  Created by Siya Infotech on 14/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BarCodeSearch : NSManagedObject

@property (nonatomic, retain) NSString * moduleName;
@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSString * modifiedBarCode;
@property (nonatomic, retain) NSNumber * resultCount;
@property (nonatomic, retain) NSNumber * serverLookup;
@property (nonatomic, retain) NSNumber * foundOnServer;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * searchText;
@property (nonatomic, retain) NSString * searchResult;


@end
