# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-15

### Added
- `FlexboxScaleController` - Controller for scalable flexbox with pinch-to-zoom support
  - Responsive scaling that follows pinch gestures in real-time
  - Smooth snap animation with spring physics
  - Mode switching between 1:1 grid and aspect ratio modes
  - Velocity-based momentum for natural gesture continuation
  - Configurable snap points, min/max extent, and grid mode threshold
- `FlexboxScaleMode` enum - Display mode for scalable flexbox (`grid1x1`, `aspectRatio`)
- `SliverFlexboxDelegateWithDirectExtent` - Delegate with direct extent control
  - Supports smooth continuous scaling without discrete column jumps
  - Fill factor interpolation for smooth layout transitions
  - Ideal for Google Photos-like pinch-to-zoom experience
- `SliverScalableFlexbox` - Scalable sliver widget with pinch-to-zoom support
  - Automatically rebuilds when controller's extent changes
  - Integrates with CustomScrollView for seamless scrolling

### Features
- Pinch-to-zoom gesture support for flexbox layouts
- Spring physics animations for smooth snap transitions
- Fill factor animation for smooth layout state transitions
- Automatic display mode switching based on zoom level
- Double-tap to zoom between predefined levels
- Programmatic zoom control with `zoomIn()` and `zoomOut()` methods
- Velocity-based gesture momentum for natural feel

### Example
- Added `ScalableFlexboxPage` demonstrating pinch-to-zoom gallery
- Network image gallery example with multiple image sources (Nekosia, Yande, Zerochan)

## [1.0.0] - 2026-01-14

### Added
- Initial release of the Flutter Flexbox library
- `Flexbox` widget - full CSS Flexbox layout implementation
- `FlexItem` widget - wrapper for flex item properties
- `FlexboxList` - scrollable list with flexbox layout capabilities
- `SliverFlexbox` - sliver version for CustomScrollView
- `DynamicFlexboxList` - auto-sizing flexbox list for variable content
- `SliverDynamicFlexbox` - dynamic sliver for CustomScrollView
- `DimensionResolver` - utility for measuring child dimensions
- Multiple delegate types for different layout scenarios:
  - `SliverFlexboxDelegateWithFixedCrossAxisCount`
  - `SliverFlexboxDelegateWithMaxCrossAxisExtent`
  - `SliverFlexboxDelegateWithAspectRatios`
  - `SliverFlexboxDelegateWithDynamicAspectRatios`
  - `SliverFlexboxDelegateWithFlexValues`
  - `SliverFlexboxDelegateWithBuilder`

### Features
- Full CSS Flexbox layout algorithm implementation
- Support for `flexDirection`, `flexWrap`, `justifyContent`, `alignItems`, `alignContent`
- Flex item properties: `order`, `flexGrow`, `flexShrink`, `alignSelf`, `flexBasisPercent`
- Size constraints: `minWidth`, `minHeight`, `maxWidth`, `maxHeight`
- `wrapBefore` property for explicit line breaks
- Main axis and cross axis spacing
- Item recycling for efficient scrolling
- Dynamic sizing based on aspect ratios
- Text direction support (LTR/RTL)
- Max lines limitation for wrapped layouts
- Configurable thresholds for layout updates:
  - `aspectRatioChangeThreshold` - minimum aspect ratio change to trigger update
  - `crossAxisExtentChangeThreshold` - viewport width change to clear cache
- `FlexboxList` extends `BoxScrollView` for better framework integration
- Comprehensive Dart documentation with examples for all public APIs

### Example
- Complete example app with interactive playground
- Demonstrations of all major features
- Network image gallery example
