//
//  NSString+CountString.h
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/24/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CountString)
- (NSInteger)countOccurencesOfString:(NSString*)searchString;
@end
