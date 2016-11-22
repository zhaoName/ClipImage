# ClipImage
图片裁剪

支持矩形和圆形两种方式：ClipAreaViewType

已知bug：在iOS8.1模拟器下，由于-(void)layoutSubviews被调用两次导致KVO监测加载两次，而KVO只remove一次，从而导致crash。
暂时解决方案：判断版本，iOS9之前的版本KVO释放两次。 或者有那啥大的 给我提点提点。。。。

![image](https://github.com/zhaoName/ClipImage/blob/master/ClipRectImage.gif)


但是在加载相册中的图片内存会增加很多，有知道的可以给我说一下。。。
