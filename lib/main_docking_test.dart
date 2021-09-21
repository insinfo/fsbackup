import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final editorRegion = Dock(widgetBuilder: (context, w, h) {
      return VerticalSplitter(
          width: w,
          height: h,
          initialLayoutMask: '0.10, 0.68, 0.22',
          docks: <Dock>[
            Dock(widget: Panel('Toolbar', Container())),
            Dock(widgetBuilder: (context, w, h) {
              return HorizontalSplitter(width: w, height: h, docks: <Dock>[
                Dock(widget: Panel('Editor 1', ColorDemo())),
                Dock(widgetBuilder: (_, w, h) {
                  return VerticalSplitter(width: w, height: h, docks: <Dock>[
                    Dock(
                        widget: Panel(
                      'Horizontal scroll',
                      HorizontalScrollableDemo(),
                    )),
                    Dock(
                        widget: Panel(
                      'Bidirectional scroll - WIP',
                      BigFlutterLogoDemo(),
                    ))
                  ]);
                })
              ]);
            }),
            Dock(widget: Panel('Console', ColorDemo())),
          ]);
    });

    return DockManager(builder: (context, availableWidth, availableHeight) {
      return HorizontalSplitter(
          width: availableWidth,
          height: availableHeight,
          initialLayoutMask: '0.20, 0.62, 0.18',
          docks: <Dock>[
            Dock(widget: Panel('Explorer', ColorDemo())),
            editorRegion,
            Dock(widget: Panel('Properties', ColorDemo()))
          ]);
    });
  }
}

/// ===================================================================
/// Dock Manager
/// ===================================================================

typedef DockContentBuilder = Widget Function(
    BuildContext context, double width, double height);

class DockManager extends StatelessWidget {
  final DockContentBuilder builder;

  const DockManager({Key key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// textDirection is mandatory property that need to be declared on
    /// the very top ancestor in the widget tree.
    ///
    /// https://github.com/flutter/flutter/issues/19039
    return MediaQuery(
      data: MediaQueryData.fromWindow(window),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // guess the available width & height to build the layout.
              final w = constraints.minWidth;
              final h = constraints.minHeight;
              print('Size Constraints {w:$w, h: $h}');
              assert(w != 0 && h != 0);
              return builder(context, w, h);
            },
          ),
        ),
      ),
    );
  }
}

/// Dock represents for a region in the layout. This region can be placed
/// a Panel or another layouts (horizontal layout or vertical layout).
class Dock {
  final Widget widget;
  final DockContentBuilder widgetBuilder;

  Dock({this.widget, this.widgetBuilder})
      : assert(widget != null || widgetBuilder != null);
}

class Panel extends StatefulWidget {
  final String title;
  final Widget child;

  const Panel(this.title, this.child, {Key key}) : super(key: key);

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: SolarizedColor.base3,
      padding: const EdgeInsets.all(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 20,
            child: Container(
              color: SolarizedColor.base2,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(
                      widget.title,
                      style: TextStyle(color: SolarizedColor.base00),
                    ),
                  )),
            ),
          ),
          Expanded(
            child: Container(
              color: SolarizedColor.base3,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================================================================
/// Splitters
/// ===================================================================

/// The horizontal/vertical layouts are represented by a pseudo string as
/// format below:
///
/// 0.20, 0.62, 0.18.
///
/// The fraction number represented for the width of a panel in the layout.
/// They are separated by ', '.
const MASK_SEPARATOR = ', ';

class SplitterProvider extends InheritedWidget {
  final ValueNotifier<String> layoutMask;
  final ValueNotifier<double> dividerPosition;

  @override
  final Widget child;

  SplitterProvider({this.layoutMask, this.dividerPosition, this.child});

  @override
  bool updateShouldNotify(SplitterProvider oldWidget) {
    return true;
  }

  static SplitterProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType();
}

abstract class Splitter extends StatefulWidget {
  final double width;
  final double height;
  final List<Dock> docks;
  final String initialLayoutMask;
  final bool stackedVertical;

  double get layoutSize {
    if (stackedVertical) {
      return height;
    }
    return width;
  }

  const Splitter(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.docks,
      this.initialLayoutMask,
      @required this.stackedVertical})
      : super(key: key);
}

mixin SplitterStateMixin<T extends Splitter> on State<T> {
  String _lastLayoutMask;
  ValueNotifier<String> layoutMask;

  double _lastDividerPosition;
  ValueNotifier<double> dividerPosition;

  double estDividerPosition;

  @override
  void initState() {
    if (widget.initialLayoutMask == null) {
      // By default, the dock layout should fill panel equally.
      //
      // Below are few default layout mask if we don't specify
      // the initialLayoutMask:
      //
      // 2 panels: 0.5, 0.5
      // 3 panels: 0.33, 0.33, 0.33
      final numOfDocks = widget.docks.length;
      _lastLayoutMask =
          List.filled(numOfDocks, 1 / numOfDocks).join(MASK_SEPARATOR);
    } else {
      _lastLayoutMask = widget.initialLayoutMask;
    }

    layoutMask = ValueNotifier<String>(_lastLayoutMask);
    layoutMask.addListener(_layoutMaskChanged);

    dividerPosition = ValueNotifier<double>(null);
    dividerPosition.addListener(_dividerPositionChanged);

    super.initState();
  }

  @override
  void dispose() {
    layoutMask.removeListener(_layoutMaskChanged);
    dividerPosition.removeListener(_dividerPositionChanged);
    super.dispose();
  }

  void _layoutMaskChanged() {
    setState(() {
      _lastLayoutMask = layoutMask.value;
    });
  }

  void _dividerPositionChanged() {
    setState(() {
      _lastDividerPosition = dividerPosition.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplitterProvider(
      layoutMask: layoutMask,
      dividerPosition: dividerPosition,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(children: <Widget>[
          buildLayout(_buildContent()),
          if (_lastDividerPosition != null)
            _buildDividerShadow(_lastDividerPosition),
        ]),
      ),
    );
  }

  /// Leaving the decision to build a layout widget to the concrete class.
  /// This layout widget will contains all the dock widgets inside.
  Widget buildLayout(List<Widget> children);

  List<Widget> _buildContent() {
    var children = <Widget>[];

    for (var i = 0; i < widget.docks.length; i++) {
      final dock = widget.docks[i];

      final numOfSplitters = (widget.docks.length / 2).ceil();
      final sizeQuota = widget.layoutSize - numOfSplitters * Divider.FAT;

      // build the children with layout mask from the state
      final ratio = double.parse(_lastLayoutMask.split(MASK_SEPARATOR)[i]);
      final dockSize = ratio * sizeQuota;

      Widget dockWidget;
      if (dock.widgetBuilder == null) {
        if (widget.stackedVertical) {
          dockWidget = SizedBox(height: dockSize, child: dock.widget);
        } else {
          dockWidget = SizedBox(width: dockSize, child: dock.widget);
        }
      } else {
        if (widget.stackedVertical) {
          dockWidget = dock.widgetBuilder(context, widget.width, dockSize);
        } else {
          dockWidget = dock.widgetBuilder(context, dockSize, widget.height);
        }
      }
      children.add(dockWidget);

      // don't add splitter bar at the edge.
      if (i == widget.docks.length - 1) {
        break;
      }

      final splitterBar = Divider(
        index: i,
        stackedVertical: widget.stackedVertical,
        layoutSize: sizeQuota,
      );
      children.add(splitterBar);
    }
    return children;
  }

  Widget _buildDividerShadow(double offset) {
    if (widget.stackedVertical) {
      return Positioned(
          top: offset,
          child: Container(
              color: SolarizedColor.orange,
              child: SizedBox(width: widget.width, height: 2)));
    } else {
      return Positioned(
          left: offset,
          child: Container(
            color: SolarizedColor.orange,
            child: SizedBox(width: 2, height: widget.height),
          ));
    }
  }
}

/// ===================================================================
/// Horizontal Splitter
/// ===================================================================

class HorizontalSplitter extends Splitter {
  HorizontalSplitter({
    Key key,
    @required width,
    @required height,
    @required docks,
    initialLayoutMask,
  }) : super(
          width: width,
          height: height,
          docks: docks,
          initialLayoutMask: initialLayoutMask,
          stackedVertical: false,
        );

  @override
  _HorizontalSplitterState createState() => _HorizontalSplitterState();
}

class _HorizontalSplitterState extends State<HorizontalSplitter>
    with SingleTickerProviderStateMixin, SplitterStateMixin {
  @override
  Widget buildLayout(List<Widget> children) {
    return Row(children: children);
  }
}

/// ===================================================================
/// Vertical Splitter
/// ===================================================================

class VerticalSplitter extends Splitter {
  VerticalSplitter({
    Key key,
    @required width,
    @required height,
    @required docks,
    initialLayoutMask,
  }) : super(
          width: width,
          height: height,
          docks: docks,
          initialLayoutMask: initialLayoutMask,
          stackedVertical: true,
        );
  @override
  _VerticalSplitterState createState() => _VerticalSplitterState();
}

class _VerticalSplitterState extends State<VerticalSplitter>
    with SingleTickerProviderStateMixin, SplitterStateMixin {
  @override
  Widget buildLayout(List<Widget> children) {
    return Column(children: children);
  }
}

/// ===================================================================
/// Divider
/// ===================================================================

class Divider extends StatefulWidget {
  final bool stackedVertical;

  /// Total width or height of the layout in which this splitter is placed.
  final double layoutSize;

  /// indicates the location of the Divider in the layout.
  final int index;

  const Divider(
      {Key key,
      @required this.index,
      @required this.stackedVertical,
      @required this.layoutSize})
      : super(key: key);

  @override
  _DividerState createState() => _DividerState();

  // UX
  static const double FAT = 8;
  static const double PADDING = 3;
}

class _DividerState extends State<Divider> {
  // The amount the splitter bar has move in the main axis in
  // the coordinate space of the event receiver since started.
  double _delta;

  @override
  Widget build(BuildContext context) {
    // find the layout mask that this splitter can manipulate by dragging.
    final splitter = SplitterProvider.of(context);
    final layoutMask = splitter.layoutMask;
    final dividerPosition = splitter.dividerPosition;

    return GestureDetector(
      onPanStart: (details) {
        _delta = 0;
        _dividerPositionChanged(_delta, layoutMask, dividerPosition);
      },
      onPanUpdate: (details) {
        var changed;
        if (widget.stackedVertical) {
          changed = details.delta.dy;
        } else {
          changed = details.delta.dx;
        }

        // if there is no change on the main axis then not notify.
        if (changed == 0) return;

        _delta += changed;
        _dividerPositionChanged(_delta, layoutMask, dividerPosition);
      },
      onPanEnd: (_) {
        /// Take the delta while the resizer is dragged and transform it to
        /// the layout mask for the dock layout manager to rebuild.
        final ratio = (_delta / widget.layoutSize).toPrecision(2);

        // unbox the layout mask from string to easier format to read.
        var currentMask =
            layoutMask.value.split(MASK_SEPARATOR).map(double.parse).toList();
        currentMask[widget.index] = currentMask[widget.index] + ratio;
        currentMask[widget.index + 1] = currentMask[widget.index + 1] - ratio;

        layoutMask.value = currentMask.join(MASK_SEPARATOR);

        // clean placeholder
        dividerPosition.value = null;
      },
      child: Container(
        color: SolarizedColor.base3,
        padding: const EdgeInsets.all(Divider.PADDING),
        width: widget.stackedVertical ? null : Divider.FAT,
        height: widget.stackedVertical ? Divider.FAT : null,
        child: Container(color: SolarizedColor.base1.withOpacity(0.6)),
      ),
    );
  }

  void _dividerPositionChanged(
    double delta,
    ValueNotifier<String> layoutMask,
    ValueNotifier<double> dividerPosition,
  ) {
    // unbox the layout mask from string to easier format to read.
    final currentMask =
        layoutMask.value.split(MASK_SEPARATOR).map(double.parse).toList();

    var centerOffset = 0.0;
    for (var i = 0; i <= widget.index; i++) {
      // panel width
      centerOffset += currentMask[i] * widget.layoutSize;
      // divider width
      centerOffset += Divider.FAT;
    }
    // adjust it to the center offset
    centerOffset -= Divider.FAT / 2;

    dividerPosition.value = centerOffset + delta;
  }
}

/// ===================================================================
/// Demos
/// ===================================================================

class HorizontalScrollableDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverToBoxAdapter(
          child: Container(
        width: 500,
        height: 500,
        decoration: FlutterLogoDecoration(),
      ))
    ]);
  }
}

/// ===================================================================
/// Custom Sliver widget
/// ===================================================================

class BigFlutterLogoDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        BigFlutterLogo(
            child: Container(
          width: 500,
          height: 500,
          decoration: FlutterLogoDecoration(),
        ))
      ],
    );
  }
}

class RenderBigFlutterLogo extends RenderSliverSingleBoxAdapter {
  RenderBigFlutterLogo({RenderBox child}) : super(child: child);

  @override
  void performLayout() {
    final constraints = this.constraints;
    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child.size.width;
        break;
      case Axis.vertical:
        childExtent = child.size.height;
        break;
    }
    assert(childExtent != null);
    final paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      maxPaintExtent: childExtent,
      cacheExtent: 0,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child, constraints, geometry);
  }
}

class BigFlutterLogo extends SingleChildRenderObjectWidget {
  const BigFlutterLogo({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  RenderBigFlutterLogo createRenderObject(BuildContext context) =>
      RenderBigFlutterLogo();
}

/// ===================================================================
/// Color Demo
/// ===================================================================

class ColorDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(children: <Widget>[
        for (var c in genRainbowColors())
          Container(
            color: c,
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 2),
                Container(
                  color: SolarizedColor.base3,
                  child: Text(
                    c.toString(),
                    style: TextStyle(fontSize: 10, color: SolarizedColor.blue),
                  ),
                ),
                SizedBox(height: 2),
              ],
            ),
          )
      ]),
    );
  }

  /// https://krazydad.com/tutorials/makecolors.php
  static Iterable<Color> genRainbowColors() sync* {
    final length = 200;
    final center = 128;
    final width = 127;
    final frequency = pi * 2 / length;
    for (var i = 0; i < length; ++i) {
      final r = (sin(frequency * i + 2) * width + center).toInt();
      final g = (sin(frequency * i + 0) * width + center).toInt();
      final b = (sin(frequency * i + 4) * width + center).toInt();
      yield Color.fromRGBO(r, g, b, 1);
    }
  }
}

/// ===================================================================
/// Misc
/// ===================================================================

/// Round a double to a given degree of precision after decimal point.
/// https://stackoverflow.com/a/59522007
extension Precision on double {
  double toPrecision(int fractionDigits) {
    double mod = pow(10, fractionDigits.toDouble());
    return ((this * mod).round().toDouble() / mod);
  }
}

class SolarizedColor {
  static const base03 = Color.fromRGBO(0, 43, 54, 1);
  static const base02 = Color.fromRGBO(7, 54, 66, 1);
  static const base01 = Color.fromRGBO(88, 110, 117, 1);
  static const base00 = Color.fromRGBO(101, 123, 131, 1);
  static const base0 = Color.fromRGBO(131, 148, 150, 1);
  static const base1 = Color.fromRGBO(147, 161, 161, 1);
  static const base2 = Color.fromRGBO(238, 232, 213, 1);
  static const base3 = Color.fromRGBO(253, 246, 227, 1);
  static const yellow = Color.fromRGBO(181, 137, 0, 1);
  static const orange = Color.fromRGBO(203, 75, 22, 1);
  static const red = Color.fromRGBO(211, 1, 2, 1);
  static const magenta = Color.fromRGBO(211, 54, 130, 1);
  static const violet = Color.fromRGBO(108, 113, 196, 1);
  static const blue = Color.fromRGBO(38, 139, 210, 1);
  static const cyan = Color.fromRGBO(42, 161, 152, 1);
  static const green = Color.fromRGBO(133, 153, 0, 1);
}
