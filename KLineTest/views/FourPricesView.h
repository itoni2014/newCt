//
//  FourPricesView.h
//  sec
//
//  Created by ias_sec on 2015/12/10.
//
//

#import <UIKit/UIKit.h>
#import "OhlcBean.h"

@interface FourPricesView : UIView

- (id)initWithFrame:(CGRect)frame orientation: (BOOL)isPortrait;

- (void)updateFourPriceLabels: (OhlcBean *)bean;
- (void)clearFourPrices;
@end
