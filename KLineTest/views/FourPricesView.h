

#import <UIKit/UIKit.h>
#import "OhlcBean.h"

@interface FourPricesView : UIView

- (id)initWithFrame:(CGRect)frame orientation: (BOOL)isPortrait;

- (void)updateFourPriceLabels: (OhlcBean *)bean;
- (void)clearFourPrices;
@end
