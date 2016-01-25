

#import <UIKit/UIKit.h>

@interface ChartNamesView : UIView

- (id)initWithFrame:(CGRect)frame orientation: (BOOL)isPortrait;
- (void)update: (NSInteger)technicalType;
@end
