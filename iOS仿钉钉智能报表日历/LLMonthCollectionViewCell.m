//
//  LLMonthCollectionViewCell.m
//  demoTest
//
//  Created by 周尊贤 on 2018/5/22.
//  Copyright © 2018年 周尊贤. All rights reserved.
//

#import "LLMonthCollectionViewCell.h"
#import "Masonry.h"
#import "ViewController.h"
@implementation LLMonthCollectionViewCell
{
    UILabel * _monthLable;
    UIView * _seleteView;
}

-(void)setModel:(LLMonthModel *)model {
    _model = model;
    _monthLable.text = model.month;
    _seleteView.hidden = model.seleted ? false : true;
    _monthLable.highlighted =  model.seleted;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _seleteView = [UIView new];
        [self.contentView addSubview:_seleteView];
        _seleteView.backgroundColor = RGB(59, 177, 239);
        _seleteView.frame = self.contentView.bounds;
        
        _monthLable = [UILabel new];
        _monthLable.highlightedTextColor = [UIColor whiteColor];
        _monthLable.textColor = [UIColor blackColor];
        _monthLable.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_monthLable];
        [_monthLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
       
    }
    return self;
}
@end
