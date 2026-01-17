# Flexbox

中文文档 | [English](README.md)

<div align="center">
  <img src="statics/logo.png" alt="Flexbox Logo" width="120" height="120">

  一个用于 CSS Flexbox 布局的 Flutter 库。此包提供了使用 CSS Flexbox 布局模型创建布局的组件，将 flexbox 的强大功能和灵活性带到了 Flutter。

  [![Pub Version](https://img.shields.io/pub/v/flexbox_layout)](https://pub.dev/packages/flexbox_layout)
  [![Publisher](https://img.shields.io/pub/publisher/flexbox_layout)](https://pub.dev/packages/flexbox_layout)
  [![Likes](https://img.shields.io/pub/likes/flexbox_layout)](https://pub.dev/packages/flexbox_layout/score)
  [![Pub Dev](https://img.shields.io/badge/dart-docs-blue.svg)](https://pub.dev/documentation/flexbox_layout/latest/)
  [![Live Demo](https://img.shields.io/badge/Live%20Demo-GitHub%20Pages-blue)](https://fluttercandies.github.io/flexbox_layout/)
</div>

## 在线演示

试一试交互式演示：**[https://fluttercandies.github.io/flexbox_layout/](https://fluttercandies.github.io/flexbox_layout/)**

## 截图

| | |
|:---:|:---:|
| ![基础 Flexbox](statics/01.png) | ![FlexboxList](statics/02.png) |
| ![动态画廊](statics/03.png) | ![Sliver 动态](statics/04.png) |

## 功能特性

- **Flexbox 组件**：类似 Flutter 的 `Wrap`，但具有完整的 flexbox 布局支持，包括 `flex-grow`、`flex-shrink`、`justify-content`、`align-items` 等。
- **FlexItem 组件**：用 flex 项属性包裹子组件，如 `order`、`flexGrow`、`flexShrink`、`alignSelf` 和 `flexBasisPercent`。
- **SliverFlexbox**：用于 `CustomScrollView` 的 sliver 版本，支持项回收和基于视口的渲染。
- **FlexboxList**：类似 `GridView` 的便捷组件，但具有 flexbox 布局功能。
- **DynamicFlexbox**：动态 flexbox 布局，根据纵横比自动调整项目大小。
- **DimensionResolver**：用于异步解析尺寸（如图片尺寸）的工具。

## 安装

将以下内容添加到包的 `pubspec.yaml` 文件中：

```yaml
dependencies:
  flexbox_layout: any
```

## 使用方法

### 基础 Flexbox

```dart
import 'package:flexbox_layout/flexbox_layout.dart';

Flexbox(
  flexDirection: FlexDirection.row,
  flexWrap: FlexWrap.wrap,
  justifyContent: JustifyContent.spaceBetween,
  alignItems: AlignItems.center,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  children: [
    FlexItem(
      flexGrow: 1,
      child: Container(width: 100, height: 100, color: Colors.red),
    ),
    FlexItem(
      flexGrow: 2,
      child: Container(width: 100, height: 100, color: Colors.blue),
    ),
    FlexItem(
      flexGrow: 1,
      alignSelf: AlignSelf.flexEnd,
      child: Container(width: 100, height: 100, color: Colors.green),
    ),
  ],
)
```

### FlexboxList

```dart
FlexboxList.count(
  crossAxisCount: 3,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  padding: const EdgeInsets.all(8),
  children: List.generate(
    100,
    (index) => Card(
      child: Center(child: Text('Item $index')),
    ),
  ),
)
```

### FlexboxList with Max Extent

```dart
FlexboxList.extent(
  maxCrossAxisExtent: 200, // 每项的最大宽度
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  children: List.generate(
    100,
    (index) => Card(child: Center(child: Text('Item $index'))),
  ),
)
```

### CustomScrollView 中的 SliverFlexbox

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(title: Text('Flexbox')),
    SliverFlexbox(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Card(child: Text('Item $index')),
        childCount: 100,
      ),
      flexboxDelegate: SliverFlexboxDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
    ),
  ],
)
```

### 用于图片画廊的 DynamicFlexboxList

**开箱即用！** 图片会自动测量并排列以填充每一行。

```dart
DynamicFlexboxList(
  targetRowHeight: 200,
  mainAxisSpacing: 4,
  crossAxisSpacing: 4,
  itemBuilder: (context, index) {
    return Image.network(images[index].url, fit: BoxFit.cover);
  },
  itemCount: images.length,
)
```

### 带纵横比的 SliverDynamicFlexbox

```dart
CustomScrollView(
  slivers: [
    SliverDynamicFlexbox(
      flexboxDelegate: SliverDynamicFlexboxDelegate(
        targetRowHeight: 200,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      childDelegate: SliverChildBuilderDelegate(
        (context, index) => Image.network(images[index].url),
        childCount: images.length,
      ),
    ),
  ],
)
```

### 使用 DimensionResolver 预加载图片尺寸

```dart
class _GalleryState extends State<_Gallery> with DimensionResolverMixin {
  final List<String> imageUrls = [...];

  @override
  void initState() {
    super.initState();
    // 预加载所有图片尺寸
    for (int i = 0; i < imageUrls.length; i++) {
      resolveImageDimension(NetworkImage(imageUrls[i]), key: i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverFlexboxDelegateWithDynamicAspectRatios(
      childCount: imageUrls.length,
      aspectRatioProvider: getAspectRatio, // 来自 mixin
      defaultAspectRatio: 1.0,
      // ...
    );
  }
}
```

### 使用 DynamicFlexItem 处理有问题的组件

**使用场景**：如果您的子组件使用了带有 `StackFit.expand` 的 `Stack` 或其他在固有尺寸测量期间不能很好地处理无边界约束的组件。

```dart
SliverDynamicFlexbox(
  flexboxDelegate: SliverDynamicFlexboxDelegate(...),
  childDelegate: SliverChildBuilderDelegate(
    (context, index) => DynamicFlexItem(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(images[index], fit: BoxFit.cover),
          Positioned(bottom: 8, left: 8, child: Text('Label')),
        ],
      ),
    ),
    childCount: images.length,
  ),
)
```

**注意**：对于简单的 `Image` 组件，您不需要 `DynamicFlexItem` - 直接使用即可。

### 可缩放 Flexbox 支持捏合缩放

**Google Photos 风格**的捏合缩放体验：

```dart
class _ScalableGalleryState extends State<_ScalableGallery>
    with SingleTickerProviderStateMixin {
  late final controller = FlexboxScaleController(
    initialExtent: 150.0,
    minExtent: 80.0,
    maxExtent: 300.0,
    snapPoints: [80, 120, 160, 200, 250, 300],
    gridModeThreshold: 250.0, // 缩小时切换到 1:1 网格模式
  );

  @override
  void initState() {
    super.initState();
    controller.attachTickerProvider(this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: controller.onScaleStart,
      onScaleUpdate: controller.onScaleUpdate,
      onScaleEnd: controller.onScaleEnd,
      onDoubleTap: controller.onDoubleTap,
      child: CustomScrollView(
        slivers: [
          SliverScalableFlexbox(
            controller: controller,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
            delegate: SliverChildBuilderDelegate(
              (context, index) => Image.network(images[index].url, fit: BoxFit.cover),
              childCount: images.length,
            ),
          ),
        ],
      ),
    );
  }
}
```

**主要特性：**
- **响应式缩放**：实时跟随捏合手势
- **平滑吸附动画**：使用弹簧物理效果吸附到预定义点
- **模式切换**：自动在 1:1 网格和纵横比模式之间切换
- **基于速度的动量**：根据手势速度继续运动

## API 参考

### 枚举

| 枚举 | 值 | 描述 |
|------|--------|-------------|
| `FlexDirection` | `row`, `rowReverse`, `column`, `columnReverse` | 主轴的方向 |
| `FlexWrap` | `noWrap`, `wrap`, `wrapReverse` | 项目是否换行到多行 |
| `JustifyContent` | `flexStart`, `flexEnd`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly` | 沿主轴的对齐方式 |
| `AlignItems` | `flexStart`, `flexEnd`, `center`, `baseline`, `stretch` | 沿交叉轴的对齐方式 |
| `AlignSelf` | `auto`, `flexStart`, `flexEnd`, `center`, `baseline`, `stretch` | 覆盖父级的 `AlignItems` |
| `AlignContent` | `flexStart`, `flexEnd`, `center`, `spaceBetween`, `spaceAround`, `stretch` | flex 行的对齐方式 |
| `FlexboxScaleMode` | `grid1x1`, `aspectRatio` | 可缩放 flexbox 的显示模式 |

### FlexItem 属性

| 属性 | 类型 | 默认值 | 描述 |
|----------|------|---------|-------------|
| `order` | `int` | `1` | 项目在 flex 容器中的顺序 |
| `flexGrow` | `double` | `0.0` | 项目相对于其他项目的增长量 |
| `flexShrink` | `double` | `1.0` | 项目相对于其他项目的收缩量 |
| `alignSelf` | `AlignSelf` | `auto` | 交叉轴对齐覆盖 |
| `flexBasisPercent` | `double` | `-1.0` | 初始大小作为父级的百分比 (0.0-1.0) |
| `minWidth` | `double?` | `null` | 最小宽度约束 |
| `minHeight` | `double?` | `null` | 最小高度约束 |
| `maxWidth` | `double?` | `null` | 最大宽度约束 |
| `maxHeight` | `double?` | `null` | 最大高度约束 |
| `wrapBefore` | `bool` | `false` | 强制在此项目之前换行 |

### 可用组件

| 组件 | 描述 |
|--------|-------------|
| `Flexbox` | 基础 flexbox 布局组件（非滚动） |
| `FlexItem` | 带有 flex 属性的子组件包装器 |
| `FlexboxList` | 带有 flexbox 布局的可滚动列表 |
| `SliverFlexbox` | 用于 CustomScrollView 的 sliver 版本 |
| `DynamicFlexboxList` | 自动调整大小的 flexbox 列表（测量子组件） |
| `SliverDynamicFlexbox` | 用于 CustomScrollView 的动态 sliver |
| `DynamicFlexItem` | 具有无边界约束问题的子组件包装器 |
| `SliverScalableFlexbox` | 支持捏合缩放的可缩放 sliver（Google Photos 风格） |

### 尺寸解析工具

| 类/类型 | 描述 |
|------------|-------------|
| `DimensionResolver` | 用于图片和自定义内容的异步尺寸解析器 |
| `DimensionResolverMixin` | 用于 State 类中简化尺寸解析的 mixin |
| `BatchDimensionResolver` | 带有进度跟踪的批量尺寸解析 |
| `ItemDimension` | 表示宽度/高度且支持纵横比的不可变类 |
| `ImageProviderDimensionExtension` | 从 ImageProvider 获取尺寸的扩展 |

### 缩放控制器

| 类/类型 | 描述 |
|------------|-------------|
| `FlexboxScaleController` | 可缩放 flexbox 的控制器，支持捏合缩放（Google Photos 风格） |
| `FlexboxScaleMode` | 显示模式枚举（`grid1x1`、`aspectRatio`） |

### 可用委托

| 委托 | 描述 |
|----------|-------------|
| `SliverFlexboxDelegateWithFixedCrossAxisCount` | 类似网格的布局，固定每行/列的项目数 |
| `SliverFlexboxDelegateWithMaxCrossAxisExtent` | 带有最大项目大小的响应式布局 |
| `SliverFlexboxDelegateWithAspectRatios` | 可变纵横比（预先已知） |
| `SliverFlexboxDelegateWithDynamicAspectRatios` | 通过回调获取动态纵横比 |
| `SliverFlexboxDelegateWithFlexValues` | 每个项目的自定义 flex grow 值 |
| `SliverFlexboxDelegateWithBuilder` | 通过构建器回调完全可定制 |
| `SliverFlexboxDelegateWithDirectExtent` | 直接扩展控制，支持平滑过渡（用于捏合缩放） |

### SliverDynamicFlexboxDelegate 选项

| 属性 | 类型 | 默认值 | 描述 |
|----------|------|---------|-------------|
| `targetRowHeight` | `double` | `200.0` | 每行的目标高度 |
| `mainAxisSpacing` | `double` | `0.0` | 行之间的间距 |
| `crossAxisSpacing` | `double` | `0.0` | 行中项目之间的间距 |
| `minRowFillFactor` | `double` | `0.8` | 最后一行的最小填充比例 (0.0-1.0) |
| `defaultAspectRatio` | `double` | `1.0` | 未测量时的回退纵横比 |
| `debounceDuration` | `Duration` | `150ms` | 应用尺寸更新前的延迟 |
| `aspectRatioChangeThreshold` | `double` | `0.01` | 触发布局更新的最小变化 (1%) |
| `crossAxisExtentChangeThreshold` | `double` | `1.0` | 清除缓存的最小视口宽度变化 |
| `aspectRatioGetter` | `function?` | `null` | 提供纵横比的可选回调 |

## 架构

### 组件层次

```
Flexbox (RenderObjectWidget)
├── RenderFlexbox (RenderObject)
│   └── FlexboxParentData
│       └── FlexItemData
│
FlexItem (ParentDataWidget)
└── 将 FlexItemData 应用于子组件

FlexboxList (StatelessWidget)
└── CustomScrollView
    └── SliverFlexbox
        └── RenderSliverFlexbox
            └── SliverFlexboxParentData

DynamicFlexboxList (StatelessWidget)
└── CustomScrollView
    └── SliverDynamicFlexbox
        └── RenderSliverDynamicFlexbox
            └── SliverDynamicFlexboxParentData
```

### 布局算法

1. **测量子组件** 并确定其固有尺寸
2. **根据 flexWrap 和可用空间分组为 flex 行**
3. **使用 flexGrow/flexShrink 比率分配剩余空间**
4. **应用对齐** (justify-content, align-items, align-content)
5. **使用适当的偏移量定位子组件**

## 示例

查看 [example](example/) 目录以获取演示所有功能的完整示例应用：

- 基础 Flexbox 使用
- 带固定交叉轴计数的 FlexboxList
- 基于纵横比布局的 DynamicFlexbox
- 网络图片画廊
- 交互式 Playground

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

本项目在 MIT 许可证下发布 - 详见 [LICENSE](LICENSE) 文件。

Copyright (c) 2026 iota9star

## 致谢

本库灵感来源于 CSS Flexbox 布局和 Google 的 Android [flexbox-layout](https://github.com/google/flexbox-layout)。
