//
//  LLQuarterCalendarVc.m
//  iOS仿钉钉智能报表日历
//
//  Created by 周尊贤 on 2018/5/28.
//  Copyright © 2018年 周尊贤. All rights reserved.
//

#import "LLQuarterCalendarVc.h"
#import "LLMonthModel.h"
#import "HYCGetDateAttribute.h"
#import "Masonry.h"
#import "LLMonthCollectionViewCell.h"
@interface LLQuarterCalendarVc ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,copy) NSMutableArray <LLMonthModel*>* months;
@property (nonatomic,strong) HYCGetDateAttribute * dateAttribute;
@property (nonatomic,strong) UILabel * yearLable;
@end

@implementation LLQuarterCalendarVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dateAttribute = [HYCGetDateAttribute new];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.dateAttribute.HYC_GLTime = [formatter stringFromDate:[NSDate date]];
    for (int i = 0 ; i<4; i++) {
        LLMonthModel * model = [LLMonthModel new];
        model.month = [NSString stringWithFormat:@"第%d季度",i+1];
        [ self.months addObject:model];
    }
    UIView * seletedYearView = [self setupSeletedYearView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(seletedYearView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(300);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)setupSeletedYearView {
    UIView * view = [UIView new];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    self.yearLable = [UILabel new];
    self.yearLable.textAlignment = NSTextAlignmentCenter;
    self.yearLable.textColor = [UIColor darkGrayColor];
    self.yearLable.font = [UIFont systemFontOfSize:16];
    [view addSubview:self.yearLable];
    self.yearLable.text = self.dateAttribute.HYC_GLYears;
    [self.yearLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(25);
    }];
    
    UIButton * prevBtn = [UIButton new];
    [prevBtn addTarget:self action:@selector(prevBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:prevBtn];
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"icon_prev"] forState:UIControlStateNormal];
    [prevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.yearLable.mas_left).offset(-12);
        make.centerY.equalTo(view);
    }];
    
    UIButton * nextBtn = [UIButton new];
    [view addSubview:nextBtn];
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"icon_next"] forState:UIControlStateNormal];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.yearLable.mas_right).offset(12);
        make.centerY.equalTo(view);
    }];
    
    return view;
}

-(void)prevBtnClick {
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.dateAttribute.HYC_GLTime = [formatter stringFromDate:[self OneMothisUP:false]];
    self.yearLable.text = self.dateAttribute.HYC_GLYears;
}

-(void)nextBtnClick {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.dateAttribute.HYC_GLTime = [formatter stringFromDate:[self OneMothisUP:true]];
    self.yearLable.text = self.dateAttribute.HYC_GLYears;
}

- (NSDate*)OneMothisUP:(BOOL)isUP{
    
    static NSInteger indexYear = 0 ;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    [formatter1 setDateFormat:@"yyyy-MM-dd"];
    
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    //[adcomps setYear:0];
    if (isUP) [adcomps setYear:indexYear++];
    else      [adcomps setYear:indexYear--];
    [adcomps setMonth:0];
    [adcomps setDay:0];
    return [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:NSCalendarWrapComponents];
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.months.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLMonthCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LLMonthCollectionViewCell" forIndexPath:indexPath];
    cell.model = self.months[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.months enumerateObjectsUsingBlock:^(LLMonthModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.seleted = false;
        if (idx == indexPath.row) {
            obj.seleted = true;
        }
    }];
    [collectionView reloadData];
}

-(UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing  = 30;
        layout.minimumInteritemSpacing = 16;
        layout.itemSize = CGSizeMake(80, 35);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[LLMonthCollectionViewCell class] forCellWithReuseIdentifier:@"LLMonthCollectionViewCell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

-(NSMutableArray<LLMonthModel *> *)months {
    if (!_months) {
        _months = [NSMutableArray array];
    }
    return _months;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
