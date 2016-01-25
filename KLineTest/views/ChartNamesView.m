//
//  ChartNamesView.m
//  sec
//
//  Created by ias_sec on 2015/12/10.
//
//

#import "ChartNamesView.h"
#import "Chartbox.h"

@interface ChartNamesView()
{
    BOOL _isPortrait;
    CGFloat labelWidth;
}
@end

@implementation ChartNamesView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self){
        
    }
    return self;
    
}

//テクニカル名称
- (id)initWithFrame:(CGRect)frame orientation: (BOOL)isPortrait{

    self = [self initWithFrame:frame];
    _isPortrait = isPortrait;
    labelWidth = 300.f;
    self.userInteractionEnabled = NO;
    
    if(isPortrait){
        self.backgroundColor = [UIColor clearColor];
    }
    else{ //101 122 141
        self.backgroundColor = [UIColor colorWithRed:101/255.0 green:122/255.0 blue:141/255.0 alpha:0.85];
    }
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 3, labelWidth, 20)];
    label1.font = [UIFont systemFontOfSize:10.0];
    label1.tag = 1;
    [self addSubview: label1];
    
    UILabel *tech1Label = [[UILabel alloc]initWithFrame:CGRectMake(label1.frame.origin.x + label1.frame.size.width + 10, 0, labelWidth, 20)];
    tech1Label.font = label1.font;
    tech1Label.tag = 2;
    [self addSubview: tech1Label];
    
    UILabel *tech2Label = [[UILabel alloc]initWithFrame:CGRectMake(tech1Label.frame.origin.x + tech1Label.frame.size.width + 10, 0, labelWidth, 20)];
    tech2Label.font = label1.font;
    tech2Label.tag = 3;
    [self addSubview: tech2Label];
    
    UILabel *tech3Label = [[UILabel alloc]initWithFrame:CGRectMake(tech2Label.frame.origin.x + tech2Label.frame.size.width + 10, 0, labelWidth, 20)];
    tech3Label.font = label1.font;
    tech3Label.tag = 4;
    [self addSubview: tech3Label];

    UILabel *tech4Label = [[UILabel alloc]initWithFrame:CGRectMake(tech3Label.frame.origin.x + tech3Label.frame.size.width + 10, 0, labelWidth, 20)];
    tech4Label.font = label1.font;
    tech4Label.tag = 5;
    [self addSubview: tech4Label];

    UILabel *tech5Label = [[UILabel alloc]initWithFrame:CGRectMake(tech4Label.frame.origin.x + tech4Label.frame.size.width + 10, 0, labelWidth, 20)];
    tech5Label.font = label1.font;
    tech5Label.tag = 6;
    [self addSubview: tech5Label];

    return self;
}


- (void)update: (NSInteger)technicalType{
    UILabel *label1 = (UILabel *)[self viewWithTag:1];
    UILabel *label2 = (UILabel *)[self viewWithTag:2];
    UILabel *label3 = (UILabel *)[self viewWithTag:3];
    UILabel *label4 = (UILabel *)[self viewWithTag:4];
    UILabel *label5 = (UILabel *)[self viewWithTag:5];
    UILabel *label6 = (UILabel *)[self viewWithTag:6];
    label1.frame = [self getOriginalSize:label1];
    label2.frame = [self getOriginalSize:label2];
    label3.frame = [self getOriginalSize:label3];
    label4.frame = [self getOriginalSize:label4];
    label5.frame = [self getOriginalSize:label5];
    label6.frame = [self getOriginalSize:label6];

    
    if(technicalType == 1){
        label1.text = @"移動平均";
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//            label2.text = [NSString stringWithFormat:@"短期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_1min_s"] intValue]];
//            label3.text = [NSString stringWithFormat:@"中期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_1min_m"] intValue]];
//            label4.text = [NSString stringWithFormat:@"長期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_1min_l"] intValue]];
//
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//            label2.text = [NSString stringWithFormat:@"短期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_10min_s"] intValue]];
//            label3.text = [NSString stringWithFormat:@"中期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_10min_m"] intValue]];
//            label4.text = [NSString stringWithFormat:@"長期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_10min_l"] intValue]];
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//            label2.text = [NSString stringWithFormat:@"短期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_hour_s"] intValue]];
//            label3.text = [NSString stringWithFormat:@"中期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_hour_m"] intValue]];
//            label4.text = [NSString stringWithFormat:@"長期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_hour_l"] intValue]];
//
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//            label2.text = [NSString stringWithFormat:@"短期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_day_s"] intValue]];
//            label3.text = [NSString stringWithFormat:@"中期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_day_m"] intValue]];
//            label4.text = [NSString stringWithFormat:@"長期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_day_l"] intValue]];
//
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//            label2.text = [NSString stringWithFormat:@"短期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_week_s"] intValue]];
//            label3.text = [NSString stringWithFormat:@"中期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_week_m"] intValue]];
//            label4.text = [NSString stringWithFormat:@"長期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_week_l"] intValue]];
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//            label2.text = [NSString stringWithFormat:@"短期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_month_s"] intValue]];
//            label3.text = [NSString stringWithFormat:@"中期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_month_m"] intValue]];
//            label4.text = [NSString stringWithFormat:@"長期(%d)", [[ChartBox sharedInstance].technicalValueDic[@"ma_month_l"] intValue]];
//
//        }
        
        label5.text = @"";
        label6.text = @"";
        
        label2.textColor = [UIColor colorWithRed:MOVAVG_SHORT_COLOR[0]/255.0 green:MOVAVG_SHORT_COLOR[1]/255.0 blue:MOVAVG_SHORT_COLOR[2]/255.0 alpha:1.0];
        label3.textColor = [UIColor colorWithRed:MOVAVG_MEDIUM_COLOR[0]/255.0 green:MOVAVG_MEDIUM_COLOR[1]/255.0 blue:MOVAVG_MEDIUM_COLOR[2]/255.0 alpha:1.0];
        label4.textColor = [UIColor colorWithRed:MOVAVG_LONG_COLOR[0]/255.0 green:MOVAVG_LONG_COLOR[1]/255.0 blue:MOVAVG_LONG_COLOR[2]/255.0 alpha:1.0];
        
    }
    else if(technicalType == 2){
        label1.text = @"ボリンジャー";
        
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//            label2.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_1min_ma"] intValue]];
//            
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//            label2.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_10min_ma"] intValue]];
//
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//            label2.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_hour_ma"] intValue]];
//
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//            label2.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_day_ma"] intValue]];
//
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//            label2.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_week_ma"] intValue]];
//
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//            label2.text = [NSString stringWithFormat:@"移動平均(%d)", [[ChartBox sharedInstance].technicalValueDic[@"bollinger_month_ma"] intValue]];
//
//        }
        
        
        label3.text = @"+1δ ";
        label4.text = @"-1δ ";
        label5.text = @"+2δ ";
        label6.text = @"-2δ ";
        
        label2.textColor = [UIColor colorWithRed:BOLLINGER_MOVE_AVG_COLOR[0]/255.0 green:BOLLINGER_MOVE_AVG_COLOR[1]/255.0 blue:BOLLINGER_MOVE_AVG_COLOR[2]/255.0 alpha:1.0];
        label3.textColor = [UIColor colorWithRed:BOLLINGER_TOP1_COLOR[0]/255.0 green:BOLLINGER_TOP1_COLOR[1]/255.0 blue:BOLLINGER_TOP1_COLOR[2]/255.0 alpha:1.0];
        label4.textColor = [UIColor colorWithRed:BOLLINGER_TOP2_COLOR[0]/255.0 green:BOLLINGER_TOP2_COLOR[1]/255.0 blue:BOLLINGER_TOP2_COLOR[2]/255.0 alpha:1.0];
        label5.textColor = [UIColor colorWithRed:BOLLINGER_LOW1_COLOR[0]/255.0 green:BOLLINGER_LOW1_COLOR[1]/255.0 blue:BOLLINGER_LOW1_COLOR[2]/255.0 alpha:1.0];
        label6.textColor = [UIColor colorWithRed:BOLLINGER_LOW2_COLOR[0]/255.0 green:BOLLINGER_LOW2_COLOR[1]/255.0 blue:BOLLINGER_LOW2_COLOR[2]/255.0 alpha:1.0];

    }
    else if(technicalType == 3){
        int itimoku_shortTerm;
        int itimoku_mediumTerm;
        int itimoku_longTerm;
        
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//            itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_1min_convert"] intValue];
//            itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_1min_base"] intValue];
//            itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_1min_span"] intValue];
//
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//            itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_10min_convert"] intValue];
//            itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_10min_base"] intValue];
//            itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_10min_span"] intValue];
//            
//        }
//        else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//            itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_hour_convert"] intValue];
//            itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_hour_base"] intValue];
//            itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_hour_span"] intValue];
//            
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//            itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_convert"] intValue];
//            itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_base"] intValue];
//            itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_day_span"] intValue];
//            
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//            itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_week_convert"] intValue];
//            itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_week_base"] intValue];
//            itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_week_span"] intValue];
//            
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//            itimoku_shortTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_month_convert"] intValue];
//            itimoku_mediumTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_month_base"] intValue];
//            itimoku_longTerm = [[ChartBox sharedInstance].technicalValueDic[@"itimoku_month_span"] intValue];
//            
//            
//        }

        
        label1.text = @"一目均衡表";
        label2.text = [NSString stringWithFormat:@"転換線(%d)", itimoku_shortTerm];
        label3.text = [NSString stringWithFormat: @"基準線(%d)", itimoku_mediumTerm];
        label4.text = [NSString stringWithFormat: @"先行スパン2(%d)", itimoku_longTerm];
        label5.text = @"";
        label6.text = @"";
        
        label2.textColor = [UIColor colorWithRed:ITIMOKU_CONVERSION_COLOR[0]/255.0 green:ITIMOKU_CONVERSION_COLOR[1]/255.0 blue:ITIMOKU_CONVERSION_COLOR[2]/255.0 alpha:1.0];
        label3.textColor = [UIColor colorWithRed:ITIMOKU_BASE_COLOR[0]/255.0 green:ITIMOKU_BASE_COLOR[1]/255.0 blue:ITIMOKU_BASE_COLOR[2]/255.0 alpha:1.0];
        label4.textColor = [UIColor colorWithRed:ITIMOKU_LEADING_SPAN2_COLOR[0]/255.0 green:ITIMOKU_LEADING_SPAN2_COLOR[1]/255.0 blue:ITIMOKU_LEADING_SPAN2_COLOR[2]/255.0 alpha:1.0];

    }
    else{
        label1.text = @"", label2.text = @"", label3.text = @"";
        label4.text = @"", label5.text = @"", label6.text = @"";
    }
    

    if(_isPortrait){
        [label1 sizeToFit];
        label2.frame = CGRectMake(label1.frame.origin.x + label1.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
        [label2 sizeToFit];
        label3.frame = CGRectMake(label2.frame.origin.x + label2.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
        [label3 sizeToFit];
        label4.frame = CGRectMake(label3.frame.origin.x + label3.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
        [label4 sizeToFit];
        label5.frame = CGRectMake(label4.frame.origin.x + label4.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
        [label5 sizeToFit];
        label6.frame = CGRectMake(label5.frame.origin.x + label5.frame.size.width*1.2, label1.frame.origin.y, labelWidth, 20);
        [label6 sizeToFit];
    }
    else{
        [label1 sizeToFit];
        label2.frame = CGRectMake(label1.frame.origin.x, label1.frame.origin.y + label1.frame.size.height * 1.5, labelWidth, 20);
        [label2 sizeToFit];
        label3.frame = CGRectMake(label2.frame.origin.x, label2.frame.origin.y + label2.frame.size.height * 1.5, labelWidth, 20);
        [label3 sizeToFit];
        label4.frame = CGRectMake(label3.frame.origin.x, label3.frame.origin.y + label3.frame.size.height * 1.5, labelWidth, 20);
        [label4 sizeToFit];
        label5.frame = CGRectMake(label4.frame.origin.x, label4.frame.origin.y + label4.frame.size.height * 1.5, labelWidth, 20);
        [label5 sizeToFit];
        label6.frame = CGRectMake(label5.frame.origin.x, label5.frame.origin.y + label5.frame.size.height * 1.5, labelWidth, 20);
        [label6 sizeToFit];

        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, label6.frame.origin.y + label6.frame.size.height + 3);
    }
    
}

- (CGRect)getOriginalSize: (UILabel *)label{
    return CGRectMake(label.frame.origin.x, label.frame.origin.y, labelWidth, 20);
}


@end
