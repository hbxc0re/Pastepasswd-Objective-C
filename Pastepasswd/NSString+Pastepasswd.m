//
//  NSString+Pastepasswd.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 4/17/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "NSString+Pastepasswd.h"

@implementation NSString (Pastepasswd)

+ (NSString *)scrambleString:(NSString *)toScramble
{
    for (int i = 0; i < [toScramble length] * 15; i++)
    {
        int pos = arc4random() % [toScramble length];
        int pos2 = arc4random() % ([toScramble length] - 1);
        char ch = [toScramble characterAtIndex:pos];
        
        NSString *before = [toScramble substringToIndex:pos];
        NSString *after = [toScramble substringFromIndex:pos + 1];
        
        NSString *temp = [before stringByAppendingString:after];
        before = [temp substringToIndex:pos2];
        after = [temp substringFromIndex:pos2];
        toScramble = [before stringByAppendingFormat:@"%c%@", ch, after];
    }
    return toScramble;
}

@end
