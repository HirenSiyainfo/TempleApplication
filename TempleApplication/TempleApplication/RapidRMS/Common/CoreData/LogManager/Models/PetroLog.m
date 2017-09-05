//
//  PetroLog.m
//  DebugLog
//
//  Created by Siya9 on 19/01/17.
//  Copyright © 2017 Siya9. All rights reserved.
//

#import "PetroLog.h"

@implementation PetroLog

// Insert code here to add functionality to your managed object subclass
-(void)updateLogObjectFrom:(NSDictionary *)dictLogInfo{
    if ([dictLogInfo objectForKey:@"registerId"]) {
        self.registerId = [dictLogInfo objectForKey:@"registerId"];
    }
    if ([dictLogInfo objectForKey:@"userId"]) {
        self.userId = [dictLogInfo objectForKey:@"userId"];
    }
    if ([dictLogInfo objectForKey:@"timeStamp"]) {
        self.timeStamp = [dictLogInfo objectForKey:@"timeStamp"];
    }
    if ([dictLogInfo objectForKey:@"uploadStatus"]) {
        self.uploadStatus = [dictLogInfo objectForKey:@"uploadStatus"];
    }
    if ([dictLogInfo objectForKey:@"direction"]) {
        self.direction = [dictLogInfo objectForKey:@"direction"];
    }
    if ([dictLogInfo objectForKey:@"type"]) {
        self.type = [dictLogInfo objectForKey:@"type"];
    }
    if ([dictLogInfo objectForKey:@"buildDetaild"]) {
        self.buildDetaild = [dictLogInfo objectForKey:@"buildDetaild"];
    }
    if ([dictLogInfo objectForKey:@"pumpIndex"]) {
        self.pumpIndex = [dictLogInfo objectForKey:@"pumpIndex"];
    }
    if ([dictLogInfo objectForKey:@"transactionType"]) {
        self.transactionType = [dictLogInfo objectForKey:@"transactionType"];
    }
    if ([dictLogInfo objectForKey:@"command"]) {
        self.command = [dictLogInfo objectForKey:@"command"];
    }
    if ([dictLogInfo objectForKey:@"parameters"]) {
        self.parameters = [dictLogInfo objectForKey:@"parameters"];
    }
    if ([dictLogInfo objectForKey:@"data"]) {
        self.data = [dictLogInfo objectForKey:@"data"];
    }
    if ([dictLogInfo objectForKey:@"cartID"]) {
        self.cartID = [dictLogInfo objectForKey:@"cartID"];
    }
    if ([dictLogInfo objectForKey:@"cartStatus"]) {
        self.cartStatus = [dictLogInfo objectForKey:@"cartStatus"];
    }
    if ([dictLogInfo objectForKey:@"regInvNumber"]) {
        self.regInvNumber = [dictLogInfo objectForKey:@"regInvNumber"];
    }
    if ([dictLogInfo objectForKey:@"invoiceNumber"]) {
        self.invoiceNumber = [dictLogInfo objectForKey:@"invoiceNumber"];
    }
    if ([dictLogInfo objectForKey:@"isPad"]) {
        self.isPad = [dictLogInfo objectForKey:@"isPad"];
    }
}
-(NSDictionary *)petroUploadDictionary{
    NSMutableDictionary * uploadData = [NSMutableDictionary dictionary];
    if (self.buildDetaild) {
        uploadData[@"BuildDetail"] = self.buildDetaild;
    }
    else{
        uploadData[@"BuildDetail"] = @"";
    }
    if (self.cartID) {
        uploadData[@"CartId"] = self.cartID;
    }
    else{
        uploadData[@"CartId"] = @"";
    }
    if (self.cartStatus) {
        uploadData[@"CartStatus"] = self.cartStatus;
    }
    else{
        uploadData[@"CartStatus"] = @(0);
    }
    if (self.command) {
        uploadData[@"Command"] = self.command;
    }
    else{
        uploadData[@"Command"] = @"";
    }
    if (self.data) {
        uploadData[@"Data"] = self.data;
    }
    else{
        uploadData[@"Data"] = @"";
    }
    if (self.direction) {
        uploadData[@"Direction"] = self.direction;
    }
    else{
        uploadData[@"Direction"] = @(0);
    }
    if (self.index) {
        uploadData[@"RegIndex"] = self.index;
    }
    else{
        uploadData[@"RegIndex"] = @(0);
    }
    if (self.invoiceNumber) {
        uploadData[@"InvoiceNumber"] = @(self.invoiceNumber.integerValue);
    }
    else{
        uploadData[@"InvoiceNumber"] = @(0);
    }
    
    if (self.isPad) {
        uploadData[@"IsPaid"] = self.isPad;
    }
    else{
        uploadData[@"IsPaid"] = @(0);
    }
    
    if (self.parameters) {
        uploadData[@"Parameters"] = self.parameters;
    }
    else{
        uploadData[@"Parameters"] = @"";
    }
    if (self.pumpIndex) {
        uploadData[@"PumpIndex"] = self.pumpIndex;
    }
    else{
        uploadData[@"PumpIndex"] = @(0);
    }
    if (self.regInvNumber) {
        uploadData[@"RegInvNumber"] = self.regInvNumber;
    }
    else{
        uploadData[@"RegInvNumber"] = @"";
    }
    if (self.registerId) {
        uploadData[@"RegisterId"] = self.registerId;
    }
    else{
        uploadData[@"RegisterId"] = @"";
    }
    
    if (self.timeStamp) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
        uploadData[@"TimeStamp"] = [formatter stringFromDate:self.timeStamp];
    }
    else{
        uploadData[@"TimeStamp"] = @"";
    }
    if (self.transactionType) {
        uploadData[@"TransactionType"] = self.transactionType;
    }
    else{
        uploadData[@"TransactionType"] = @(0);
    }
    
    if (self.type) {
        uploadData[@"Type"] = self.type;
    }
    else{
        uploadData[@"Type"] = @(0);
    }

    if (self.uploadStatus) {
        uploadData[@"Status"] = self.uploadStatus;
    }
    else{
        uploadData[@"Status"] =@(0);
    }
    if (self.userId) {
        uploadData[@"UserId"] = self.userId;
    }
    else{
        uploadData[@"UserId"] = @(0);
    }
    return uploadData;
}
@end
