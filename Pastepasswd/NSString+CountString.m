//
//  NSString+CountString.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/24/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "NSString+CountString.h"

@implementation NSString (CountString)
- (NSInteger)countOccurencesOfString:(NSString*)searchString {
    int strCount = [self length] - [[self stringByReplacingOccurrencesOfString:searchString withString:@""] length];
    return strCount / [searchString length];
}
@end
