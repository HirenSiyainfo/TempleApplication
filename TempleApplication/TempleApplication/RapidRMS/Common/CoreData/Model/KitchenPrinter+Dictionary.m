//
//  KitchenPrinter+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "KitchenPrinter+Dictionary.h"

@implementation KitchenPrinter (Dictionary)

-(NSDictionary *)getprinterDictionary
{
    NSMutableDictionary *printerDictionary=[[NSMutableDictionary alloc]init];
    
    printerDictionary[@"printer_ip"] = self.printer_ip;
    printerDictionary[@"printer_Name"] = self.printer_Name;
    
    return printerDictionary;
}

-(void)updatePrinterDictionary :(NSDictionary *)printerDictionary
{
    self.printer_ip =  [printerDictionary valueForKey:@"printer_ip"];
    self.printer_Name =  [printerDictionary valueForKey:@"printer_Name"];

}
@end
