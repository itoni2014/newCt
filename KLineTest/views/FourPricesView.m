//
//  FourPricesView.m
//  sec
//
//  Created by ias_sec on 2015/12/10.
//
//

#import "FourPricesView.h"
#import "ChartBox.h"

@implementation FourPricesView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame orientation: (BOOL)isPortrait{
    self = [self initWithFrame:frame];
    
    self.layer.cornerRadius = 5;


//        ttlView = [[UIView alloc]initWithFrame:CGRectMake(5, 0, chartWidth, rect.size.height / 14.0)];
//        [self addSubview:ttlView];
    
    UILabel *datetimeLabel = [[UILabel alloc]init];
    if(isPortrait){
        datetimeLabel.frame = CGRectMake(5, frame.size.height/4.0, frame.size.width/2.3, frame.size.height/2.0);
        self.backgroundColor = [UIColor colorWithRed:102/255.0 green:171/255.0 blue:215/255.0 alpha:1.0];

    }
    else{
        datetimeLabel.frame = CGRectMake(/*frame.size.width*0.1*/4, 4, frame.size.width/**0.8*/ - 8, frame.size.height*0.4-5);
        self.backgroundColor = [UIColor colorWithRed:102/255.0 green:171/255.0 blue:215/255.0 alpha:0.7];
        [self.layer setBorderColor:[UIColor colorWithRed:48/255.0 green:89/255.0 blue:141/255.0 alpha:1.0].CGColor];
        [self.layer setBorderWidth:1.0];

    }
    datetimeLabel.text = @"";
    datetimeLabel.textColor = [UIColor whiteColor];
    datetimeLabel.backgroundColor = [UIColor clearColor];
    datetimeLabel.font = [UIFont systemFontOfSize:10];
    datetimeLabel.layer.cornerRadius = 5;
    datetimeLabel.textAlignment = NSTextAlignmentCenter;
    datetimeLabel.text = @"";
    datetimeLabel.tag = 1;
    UIView *cornerView = [[UIView alloc]initWithFrame:datetimeLabel.frame];
    cornerView.layer.cornerRadius = 5;
    cornerView.backgroundColor = [UIColor blackColor];
    [self addSubview: cornerView];
    [self addSubview: datetimeLabel];
    
    
    UIView *ohlcView = [[UIView alloc]init];
    ohlcView.backgroundColor = [UIColor clearColor];
    [self addSubview:ohlcView];
    if(isPortrait){
        ohlcView.frame = CGRectMake(frame.size.width/2.0, 0, frame.size.width/2.0, frame.size.height);
    }
    else{
        ohlcView.frame = CGRectMake(0, frame.size.height*0.4, frame.size.width, frame.size.height*0.6);
    }

    
    UILabel *openLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ohlcView.frame.size.width/2, ohlcView.frame.size.height/2)];
    openLabel.textColor = [UIColor whiteColor];
    openLabel.font = [UIFont systemFontOfSize:11];
    openLabel.text = @"";
    openLabel.tag = 2;
    openLabel.textAlignment = NSTextAlignmentCenter;
    [ohlcView addSubview:openLabel];
    
    UILabel *closeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, ohlcView.frame.size.height*0.5, ohlcView.frame.size.width/2, ohlcView.frame.size.height/2)];
    closeLabel.textColor = [UIColor whiteColor];
    closeLabel.font = openLabel.font;
    closeLabel.text = @"";
    closeLabel.tag = 3;
    closeLabel.textAlignment = NSTextAlignmentCenter;
    [ohlcView addSubview:closeLabel];
    
    UILabel *highLabel = [[UILabel alloc]initWithFrame:CGRectMake(ohlcView.frame.size.width/2, 0, ohlcView.frame.size.width/2, ohlcView.frame.size.height/2)];
    highLabel.textColor = openLabel.textColor;
    highLabel.font = openLabel.font;
    highLabel.text = @"";
    highLabel.tag = 4;
    highLabel.textAlignment = NSTextAlignmentCenter;
    [ohlcView addSubview:highLabel];
    
    UILabel *lowLabel = [[UILabel alloc]initWithFrame:CGRectMake(ohlcView.frame.size.width/2, ohlcView.frame.size.height/2, ohlcView.frame.size.width/2, ohlcView.frame.size.height/2)];
    lowLabel.textColor = openLabel.textColor;
    lowLabel.font = openLabel.font;
    lowLabel.text = @"";
    lowLabel.tag = 5;
    lowLabel.textAlignment = NSTextAlignmentCenter;
    [ohlcView addSubview:lowLabel];
        
    
    return self;
}

- (void)updateFourPriceLabels: (OhlcBean *)bean{
    
    //日付・時刻
    NSString *date = bean.fourValuesDate;
    if(date.length == 8){
        date = [NSString stringWithFormat:@"%@/%@/%@",[bean.fourValuesDate substringToIndex:4], [bean.fourValuesDate substringWithRange:NSMakeRange(4, 2)], [bean.fourValuesDate substringFromIndex:6]];
    }
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MINUTES1] || [[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MINUTES10] || [[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_TIME]){
//        
//        NSString *time = bean.fourValuesTime;
//        if(time.length == 0){
//            time = @"00:00:00";
//        }
//        else{
//            time = [NSString stringWithFormat:@"%@:%@:%@", [time substringToIndex:2], [time substringWithRange:NSMakeRange(2, 2)], [time substringFromIndex:4]];
//        }
//        
//        [((UILabel *) [self viewWithTag:1]) setText:[NSString stringWithFormat:@"%@ %@", date, time]];
//    }
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_DAY] || [[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_WEEK] || [[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MONTH]){
//        [((UILabel *) [self viewWithTag:1]) setText:date];
//    }

    [((UILabel *) [self viewWithTag:2]) setText:[NSString stringWithFormat:@"O: %.2f",bean.openPrice.floatValue]];//始値
    [((UILabel *) [self viewWithTag:3]) setText:[NSString stringWithFormat:@"C: %.2f",bean.closePrice.floatValue]];//終値
    [((UILabel *) [self viewWithTag:4]) setText:[NSString stringWithFormat:@"H: %.2f",bean.highPrice.floatValue]];//高値
    [((UILabel *) [self viewWithTag:5]) setText:[NSString stringWithFormat:@"L: %.2f",bean.lowPrice.floatValue]];//安値

}

- (void)clearFourPrices{
    [((UILabel *) [self viewWithTag:1]) setText:@""];//日付・時刻
    [((UILabel *) [self viewWithTag:2]) setText:@""];//始値
    [((UILabel *) [self viewWithTag:3]) setText:@""];//終値
    [((UILabel *) [self viewWithTag:4]) setText:@""];//高値
    [((UILabel *) [self viewWithTag:5]) setText:@""];//安値
    
}

@end
