//
//  NSString+Pastepasswd.h
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 4/17/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Pastepasswd)
+ (NSString *)scrambleString:(NSString *)toScramble;
@end
