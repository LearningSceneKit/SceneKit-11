//
//  ViewController.m
//  SceneKit-11
//
//  Created by ShiWen on 2017/6/27.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ViewController.h"

#import <SceneKit/SceneKit.h>

@interface ViewController ()
@property(nonatomic,strong) SCNView *mScenView;
@property (weak, nonatomic) IBOutlet UISwitch *showBone;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    获取资源
    SCNSceneSource *scneSoure = [SCNSceneSource sceneSourceWithURL:[[NSBundle mainBundle] URLForResource:@"skinning" withExtension:@"dae"] options:nil];
    self.mScenView.scene = [scneSoure sceneWithOptions:nil error:nil];
    [self.view addSubview:self.mScenView];
    [self.mScenView addSubview:self.showBone];
//    截取动画
    
//    获取动画
    NSArray *animationIDs = [scneSoure identifiersOfEntriesWithClass:[CAAnimation class]];
    NSLog(@"%@",animationIDs);
    NSInteger anmatinCount = animationIDs.count;
//    获取最后一个动画
    CFTimeInterval maxDuration = 0;

    NSMutableArray *longAnmations = [[NSMutableArray alloc] initWithCapacity:anmatinCount];
    for (NSInteger index = 0; index <anmatinCount; index ++) {
        CAAnimation *animation = [scneSoure entryWithIdentifier:animationIDs[index] withClass:[CAAnimation class]];
        if (animation) {
            maxDuration = MAX(maxDuration, animation.duration);
            [longAnmations addObject:animation];
        }
    }
    
    CAAnimationGroup *longAnimationGroup = [[CAAnimationGroup alloc] init];
    longAnimationGroup.animations = longAnmations;
    longAnimationGroup.duration = maxDuration;
    
    CAAnimationGroup *idleAnimationGroup = [longAnimationGroup copy];
    
//    截取前两秒，保留其余的
    idleAnimationGroup.timeOffset = 2;
    
    CAAnimationGroup *lastAnimationGroup= [CAAnimationGroup animation];
    lastAnimationGroup.animations = @[idleAnimationGroup];
//    动画总长为24.708；从其余的中，播放1s
    lastAnimationGroup.duration = 1;
    lastAnimationGroup.repeatCount = 10000;
    lastAnimationGroup.autoreverses = YES;
    SCNNode *personNode = [self.mScenView.scene.rootNode childNodeWithName:@"avatar_attach" recursively:YES];
    [personNode addAnimation:lastAnimationGroup forKey:@"animation"];
    

}
//查看骨骼
- (IBAction)showBone:(UISwitch *)sender {
    //    骨头
    SCNNode *skeletonNode = [self.mScenView.scene.rootNode childNodeWithName:@"skeleton" recursively:YES];
    [self visualizeBones:[self.showBone isOn] adNode:skeletonNode inheritedScale:1];
}


-(void)visualizeBones:(BOOL)show adNode:(SCNNode*)node inheritedScale:(CGFloat)scale{
    scale *= node.scale.x;
    if (show) {
        if ((node.geometry == nil)) {
            node.geometry = [SCNBox boxWithWidth:6.0 / scale height:6.0 / scale length:6.0 / scale chamferRadius:1];
            
        }
    }else{
        if ([node.geometry isKindOfClass:[SCNBox class]]) {
            node.geometry = nil;
        }
    }
    for (SCNNode *child in node.childNodes) {
        [self visualizeBones:show adNode:child inheritedScale:scale];
    }
}
-(SCNView *)mScenView{
    if (!_mScenView) {
        _mScenView = [[SCNView alloc] initWithFrame:self.view.bounds];
        _mScenView.backgroundColor = [UIColor blackColor];
        _mScenView.allowsCameraControl = YES;
    }
    return _mScenView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
