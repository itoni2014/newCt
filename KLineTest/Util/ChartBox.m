#import "ChartBox.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIColor+hex.h"
#import "OhlcBean.h"
//#import "TechnicalSetting.h"


#define KEY_CHART_SETTING @"ChartSettingOptions"

@interface ChartBox()

- (id)initialize;

@end

@implementation ChartBox


+ (ChartBox *)sharedInstance{
    static ChartBox *sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(void) {
        sharedSingleton = [[self alloc] initialize];
    });
    
    return sharedSingleton;
}

- (id)initialize{
    if(self == [super init] ){

    }
    
    return self;

    
}

@end
