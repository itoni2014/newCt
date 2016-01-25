//
//  UIColor+hex.h
//  Prototype2
//
//  Created by ias_sec on 2015/11/04.
//  Copyright © 2015年 TnsStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBA_COLOR(R, G, B, A) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:A]
#define RGB_COLOR(R, G, B) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:1.0f]

@interface UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)color;

//color:支持@“#123456”、 @“0X123456”、 @“123456”
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end