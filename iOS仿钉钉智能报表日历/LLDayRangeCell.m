//
//  RangePickerCell.m
//  FSCalendar
//
//  Created by dingwenchao on 02/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "LLDayRangeCell.h"
#import "FSCalendarExtensions.h"
#import "Masonry.h"
#import "ViewController.h"
@implementation LLDayRangeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CALayer *selectionLayer = [[CALayer alloc] init];
        selectionLayer.backgroundColor = RGB(59, 177, 239).CGColor;
        selectionLayer.actions = @{@"hidden":[NSNull null]}; // Remove hiding animation
        [self.contentView.layer insertSublayer:selectionLayer below:self.titleLabel.layer];
        self.selectionLayer = selectionLayer;
        
        CALayer *middleLayer = [[CALayer alloc] init];
        middleLayer.backgroundColor = [RGB(59, 177, 239) colorWithAlphaComponent:0.9].CGColor;
        middleLayer.actions = @{@"hidden":[NSNull null]}; // Remove hiding animation
        [self.contentView.layer insertSublayer:middleLayer below:self.titleLabel.layer];
        self.middleLayer = middleLayer;
        
        // Hide the default selection layer
        self.shapeLayer.hidden = YES;
        
        self.markLable = [UILabel new];
        [self.contentView addSubview:self.markLable];
        self.markLable.text = @"开始";
        self.markLable.font = [UIFont systemFontOfSize:10];
        self.markLable.hidden = false;
        self.markLable.textAlignment = NSTextAlignmentCenter;
        self.markLable.textColor = [UIColor whiteColor];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(3);
            make.centerX.equalTo(self.contentView);
        }];
        
        [self.markLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-3);
            make.centerX.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    self.selectionLayer.frame = CGRectMake(3, 3, CGRectGetWidth(self.contentView.bounds)-6, CGRectGetHeight(self.contentView.bounds)-6);
    self.middleLayer.frame = CGRectMake(3, 3, CGRectGetWidth(self.contentView.bounds)-6, CGRectGetHeight(self.contentView.bounds)-6);
}

@end
