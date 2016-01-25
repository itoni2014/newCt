//
//  ChartNamesView.h
//  sec
//
//  Created by ias_sec on 2015/12/10.
//
//

#import <UIKit/UIKit.h>

@interface ChartNamesView : UIView

- (id)initWithFrame:(CGRect)frame orientation: (BOOL)isPortrait;
- (void)update: (NSInteger)technicalType;
@end
