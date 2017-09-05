//
//  BarCodeSearch+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 14/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "BarCodeSearch+Dictionary.h"

@implementation BarCodeSearch (Dictionary)

-(NSMutableDictionary *)barcodeSearchDictionary
{
    NSMutableDictionary *barcodeSearchDict= [[NSMutableDictionary alloc]init];
    barcodeSearchDict[@"moduleName"] = [NSString stringWithFormat:@"%@",self.moduleName];
    barcodeSearchDict[@"barcode"] = [NSString stringWithFormat:@"%@",self.barcode];
    barcodeSearchDict[@"modifiedBarCode"] = [NSString stringWithFormat:@"%@",self.modifiedBarCode];
    barcodeSearchDict[@"resultCount"] = [NSString stringWithFormat:@"%@",self.resultCount];
    barcodeSearchDict[@"serverLookup"] = [NSString stringWithFormat:@"%@",self.serverLookup];
    barcodeSearchDict[@"foundOnServer"] = [NSString stringWithFormat:@"%@",self.foundOnServer];
    barcodeSearchDict[@"date"] = [NSString stringWithFormat:@"%@",self.date];
    barcodeSearchDict[@"searchText"] = [NSString stringWithFormat:@"%@",self.searchText];
    barcodeSearchDict[@"searchResult"] = [NSString stringWithFormat:@"%@",self.searchResult];


    return barcodeSearchDict;
}

@end
