
#import <UIKit/UIKit.h>

@interface SubChartNamesView : UIView

- (id)initWithFrame:(CGRect)frame orientation: (BOOL)isPortrait;
- (void)update: (NSInteger)technicalType;

@end
