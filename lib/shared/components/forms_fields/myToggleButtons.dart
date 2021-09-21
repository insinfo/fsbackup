// widgets/myToggleButtons.dart ********************

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyToggleButtons<T> extends StatelessWidget {
  MyToggleButtons({
    Key key,
    @required this.items,
    @required this.itemBuilder,
    @required this.selectedItemBuilder,
    this.value,
    this.onPressed,
    this.textStyle,
    this.constraints,
    this.color,
    this.selectedColor,
    this.disabledColor,
    this.fillColor,
    this.focusColor,
    this.highlightColor,
    this.hoverColor,
    this.splashColor,
    this.focusNodes,
    this.renderBorder = true,
    this.borderColor,
    this.selectedBorderColor,
    this.disabledBorderColor,
    this.borderRadius,
    this.borderWidth,
  })  : assert(renderBorder != null),
        assert(items != null),
        assert(itemBuilder != null),
        assert(selectedItemBuilder != null),
        assert(value == null || items.contains(value)),
        super(key: key);

  static const double _defaultBorderWidth = 1.0;

  final List<T> items;
  final T value;
  final Widget Function(BuildContext, T) itemBuilder;
  final Widget Function(BuildContext, T) selectedItemBuilder;
  final ValueChanged<T> onPressed;
  final TextStyle textStyle;
  final BoxConstraints constraints;
  final Color color;
  final Color selectedColor;
  final Color disabledColor;
  final Color fillColor;
  final Color focusColor;
  final Color highlightColor;
  final Color splashColor;
  final Color hoverColor;
  final List<FocusNode> focusNodes;
  final bool renderBorder;
  final Color borderColor;
  final Color selectedBorderColor;
  final Color disabledBorderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  bool _isFirstIndex(int index, int length, TextDirection textDirection) {
    return index == 0 && textDirection == TextDirection.ltr ||
        index == length - 1 && textDirection == TextDirection.rtl;
  }

  bool _isLastIndex(int index, int length, TextDirection textDirection) {
    return index == length - 1 && textDirection == TextDirection.ltr ||
        index == 0 && textDirection == TextDirection.rtl;
  }

  bool _isSelected(int index) {
    return items[index] == value;
  }

  BorderRadius _getEdgeBorderRadius(
    int index,
    int length,
    TextDirection textDirection,
    ToggleButtonsThemeData toggleButtonsTheme,
  ) {
    final BorderRadius resultingBorderRadius = borderRadius ?? toggleButtonsTheme.borderRadius ?? BorderRadius.zero;

    if (_isFirstIndex(index, length, textDirection)) {
      return BorderRadius.only(
        topLeft: resultingBorderRadius.topLeft,
        bottomLeft: resultingBorderRadius.bottomLeft,
      );
    } else if (_isLastIndex(index, length, textDirection)) {
      return BorderRadius.only(
        topRight: resultingBorderRadius.topRight,
        bottomRight: resultingBorderRadius.bottomRight,
      );
    }
    return BorderRadius.zero;
  }

  BorderRadius _getClipBorderRadius(
    int index,
    int length,
    TextDirection textDirection,
    ToggleButtonsThemeData toggleButtonsTheme,
  ) {
    final BorderRadius resultingBorderRadius = borderRadius ?? toggleButtonsTheme.borderRadius ?? BorderRadius.zero;
    final double resultingBorderWidth = borderWidth ?? toggleButtonsTheme.borderWidth ?? _defaultBorderWidth;

    if (_isFirstIndex(index, length, textDirection)) {
      return BorderRadius.only(
        topLeft: resultingBorderRadius.topLeft - Radius.circular(resultingBorderWidth / 2.0),
        bottomLeft: resultingBorderRadius.bottomLeft - Radius.circular(resultingBorderWidth / 2.0),
      );
    } else if (_isLastIndex(index, length, textDirection)) {
      return BorderRadius.only(
        topRight: resultingBorderRadius.topRight - Radius.circular(resultingBorderWidth / 2.0),
        bottomRight: resultingBorderRadius.bottomRight - Radius.circular(resultingBorderWidth / 2.0),
      );
    }
    return BorderRadius.zero;
  }

  BorderSide _getLeadingBorderSide(
    int index,
    ThemeData theme,
    ToggleButtonsThemeData toggleButtonsTheme,
  ) {
    if (!renderBorder) return BorderSide.none;

    final double resultingBorderWidth = borderWidth ?? toggleButtonsTheme.borderWidth ?? _defaultBorderWidth;
    if (onPressed != null && (_isSelected(index) || (index != 0 && _isSelected(index - 1)))) {
      return BorderSide(
        color: selectedBorderColor ??
            toggleButtonsTheme.selectedBorderColor ??
            theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    } else if (onPressed != null && !_isSelected(index)) {
      return BorderSide(
        color: borderColor ?? toggleButtonsTheme.borderColor ?? theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    } else {
      return BorderSide(
        color: disabledBorderColor ??
            toggleButtonsTheme.disabledBorderColor ??
            theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    }
  }

  BorderSide _getHorizontalBorderSide(
    int index,
    ThemeData theme,
    ToggleButtonsThemeData toggleButtonsTheme,
  ) {
    if (!renderBorder) return BorderSide.none;

    final double resultingBorderWidth = borderWidth ?? toggleButtonsTheme.borderWidth ?? _defaultBorderWidth;
    if (onPressed != null && _isSelected(index)) {
      return BorderSide(
        color: selectedBorderColor ??
            toggleButtonsTheme.selectedBorderColor ??
            theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    } else if (onPressed != null && !_isSelected(index)) {
      return BorderSide(
        color: borderColor ?? toggleButtonsTheme.borderColor ?? theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    } else {
      return BorderSide(
        color: disabledBorderColor ??
            toggleButtonsTheme.disabledBorderColor ??
            theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    }
  }

  BorderSide _getTrailingBorderSide(
    int index,
    ThemeData theme,
    ToggleButtonsThemeData toggleButtonsTheme,
  ) {
    if (!renderBorder) return BorderSide.none;

    if (index != items.length - 1) return null;

    final double resultingBorderWidth = borderWidth ?? toggleButtonsTheme.borderWidth ?? _defaultBorderWidth;
    if (onPressed != null && (_isSelected(index))) {
      return BorderSide(
        color: selectedBorderColor ??
            toggleButtonsTheme.selectedBorderColor ??
            theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    } else if (onPressed != null && !_isSelected(index)) {
      return BorderSide(
        color: borderColor ?? toggleButtonsTheme.borderColor ?? theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    } else {
      return BorderSide(
        color: disabledBorderColor ??
            toggleButtonsTheme.disabledBorderColor ??
            theme.colorScheme.onSurface.withOpacity(0.12),
        width: resultingBorderWidth,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(value == null || items.contains(value), 'Selected value should be null or part of the item options');

    final ThemeData theme = Theme.of(context);
    final ToggleButtonsThemeData toggleButtonsTheme = ToggleButtonsTheme.of(context);
    final TextDirection textDirection = Directionality.of(context);

    return Row(
      children: items
          .asMap()
          .map((int itemIndex, T item) {
            final BorderRadius edgeBorderRadius =
                _getEdgeBorderRadius(itemIndex, items.length, textDirection, toggleButtonsTheme);
            final BorderRadius clipBorderRadius =
                _getClipBorderRadius(itemIndex, items.length, textDirection, toggleButtonsTheme);

            final BorderSide leadingBorderSide = _getLeadingBorderSide(itemIndex, theme, toggleButtonsTheme);
            final BorderSide horizontalBorderSide = _getHorizontalBorderSide(itemIndex, theme, toggleButtonsTheme);
            final BorderSide trailingBorderSide = _getTrailingBorderSide(itemIndex, theme, toggleButtonsTheme);

            return MapEntry(
              itemIndex,
              Expanded(
                  child: _MyToggleButton(
                selected: _isSelected(itemIndex),
                textStyle: textStyle,
                constraints: constraints,
                color: color,
                selectedColor: selectedColor,
                disabledColor: disabledColor,
                fillColor: fillColor ?? toggleButtonsTheme.fillColor,
                focusColor: focusColor ?? toggleButtonsTheme.focusColor,
                highlightColor: highlightColor ?? toggleButtonsTheme.highlightColor,
                hoverColor: hoverColor ?? toggleButtonsTheme.hoverColor,
                splashColor: splashColor ?? toggleButtonsTheme.splashColor,
                focusNode: focusNodes != null ? focusNodes[itemIndex] : null,
                leadingBorderSide: leadingBorderSide,
                horizontalBorderSide: horizontalBorderSide,
                trailingBorderSide: trailingBorderSide,
                borderRadius: edgeBorderRadius,
                clipRadius: clipBorderRadius,
                onPressed: onPressed != null
                    ? () {
                        onPressed(item);
                      }
                    : null,
                isFirstButton: _isFirstIndex(itemIndex, items.length, textDirection),
                isLastButton: _isLastIndex(itemIndex, items.length, textDirection),
                child: _isSelected(itemIndex) ? selectedItemBuilder(context, item) : itemBuilder(context, item),
              )),
            );
          })
          .values
          .toList(),
    );
  }
}

class _MyToggleButton extends StatelessWidget {
  const _MyToggleButton({
    Key key,
    this.selected = false,
    this.textStyle,
    this.constraints,
    this.color,
    this.selectedColor,
    this.disabledColor,
    this.fillColor,
    this.focusColor,
    this.highlightColor,
    this.hoverColor,
    this.splashColor,
    this.focusNode,
    this.onPressed,
    this.leadingBorderSide,
    this.horizontalBorderSide,
    this.trailingBorderSide,
    this.borderRadius,
    this.clipRadius,
    this.isFirstButton,
    this.isLastButton,
    this.child,
  }) : super(key: key);

  final bool selected;
  final TextStyle textStyle;
  final BoxConstraints constraints;
  final Color color;
  final Color selectedColor;
  final Color disabledColor;
  final Color fillColor;
  final Color focusColor;
  final Color hoverColor;
  final Color highlightColor;
  final Color splashColor;
  final FocusNode focusNode;
  final VoidCallback onPressed;
  final BorderSide leadingBorderSide;
  final BorderSide horizontalBorderSide;
  final BorderSide trailingBorderSide;
  final BorderRadius borderRadius;
  final BorderRadius clipRadius;
  final bool isFirstButton;
  final bool isLastButton;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    Color currentColor;
    Color currentFillColor;
    Color currentFocusColor;
    Color currentHoverColor;
    Color currentSplashColor;
    final ThemeData theme = Theme.of(context);
    final ToggleButtonsThemeData toggleButtonsTheme = ToggleButtonsTheme.of(context);

    if (onPressed != null && selected) {
      currentColor = selectedColor ?? toggleButtonsTheme.selectedColor ?? theme.colorScheme.primary;
      currentFillColor = fillColor ?? theme.colorScheme.primary.withOpacity(0.12);
      currentFocusColor = focusColor ?? toggleButtonsTheme.focusColor ?? theme.colorScheme.primary.withOpacity(0.12);
      currentHoverColor = hoverColor ?? toggleButtonsTheme.hoverColor ?? theme.colorScheme.primary.withOpacity(0.04);
      currentSplashColor = splashColor ?? toggleButtonsTheme.splashColor ?? theme.colorScheme.primary.withOpacity(0.16);
    } else if (onPressed != null && !selected) {
      currentColor = color ?? toggleButtonsTheme.color ?? theme.colorScheme.onSurface.withOpacity(0.87);
      currentFillColor = theme.colorScheme.surface.withOpacity(0.0);
      currentFocusColor = focusColor ?? toggleButtonsTheme.focusColor ?? theme.colorScheme.onSurface.withOpacity(0.12);
      currentHoverColor = hoverColor ?? toggleButtonsTheme.hoverColor ?? theme.colorScheme.onSurface.withOpacity(0.04);
      currentSplashColor =
          splashColor ?? toggleButtonsTheme.splashColor ?? theme.colorScheme.onSurface.withOpacity(0.16);
    } else {
      currentColor = disabledColor ?? toggleButtonsTheme.disabledColor ?? theme.colorScheme.onSurface.withOpacity(0.38);
      currentFillColor = theme.colorScheme.surface.withOpacity(0.0);
    }

    final TextStyle currentTextStyle = textStyle ?? toggleButtonsTheme.textStyle ?? theme.textTheme.bodyText2;
    final BoxConstraints currentConstraints = constraints ??
        toggleButtonsTheme.constraints ??
        const BoxConstraints(minWidth: kMinInteractiveDimension, minHeight: kMinInteractiveDimension);

    final result = ClipRRect(
      borderRadius: clipRadius,
      child: RawMaterialButton(
        textStyle: currentTextStyle.copyWith(
          color: currentColor,
        ),
        constraints: currentConstraints,
        elevation: 0.0,
        highlightElevation: 0.0,
        fillColor: currentFillColor,
        focusColor: currentFocusColor,
        highlightColor: highlightColor ?? theme.colorScheme.surface.withOpacity(0.0),
        hoverColor: currentHoverColor,
        splashColor: currentSplashColor,
        focusNode: focusNode,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: onPressed,
        child: child,
      ),
    );

    return _SelectToggleButton(
      key: key,
      leadingBorderSide: leadingBorderSide,
      horizontalBorderSide: horizontalBorderSide,
      trailingBorderSide: trailingBorderSide,
      borderRadius: borderRadius,
      isFirstButton: isFirstButton,
      isLastButton: isLastButton,
      child: result,
    );
  }
}

class _SelectToggleButton extends SingleChildRenderObjectWidget {
  const _SelectToggleButton({
    Key key,
    Widget child,
    this.leadingBorderSide,
    this.horizontalBorderSide,
    this.trailingBorderSide,
    this.borderRadius,
    this.isFirstButton,
    this.isLastButton,
  }) : super(
          key: key,
          child: child,
        );

  // The width and color of the button's leading side border.
  final BorderSide leadingBorderSide;

  // The width and color of the button's top and bottom side borders.
  final BorderSide horizontalBorderSide;

  // The width and color of the button's trailing side border.
  final BorderSide trailingBorderSide;

  // The border radii of each corner of the button.
  final BorderRadius borderRadius;

  // Whether or not this toggle button is the first button in the list.
  final bool isFirstButton;

  // Whether or not this toggle button is the last button in the list.
  final bool isLastButton;

  @override
  _SelectToggleButtonRenderObject createRenderObject(BuildContext context) => _SelectToggleButtonRenderObject(
        leadingBorderSide,
        horizontalBorderSide,
        trailingBorderSide,
        borderRadius,
        isFirstButton,
        isLastButton,
        Directionality.of(context),
      );

  @override
  void updateRenderObject(BuildContext context, _SelectToggleButtonRenderObject renderObject) {
    renderObject
      ..leadingBorderSide = leadingBorderSide
      ..horizontalBorderSide = horizontalBorderSide
      ..trailingBorderSide = trailingBorderSide
      ..borderRadius = borderRadius
      ..isFirstButton = isFirstButton
      ..isLastButton = isLastButton
      ..textDirection = Directionality.of(context);
  }
}

class _SelectToggleButtonRenderObject extends RenderShiftedBox {
  _SelectToggleButtonRenderObject(
    this._leadingBorderSide,
    this._horizontalBorderSide,
    this._trailingBorderSide,
    this._borderRadius,
    this._isFirstButton,
    this._isLastButton,
    this._textDirection, [
    RenderBox child,
  ]) : super(child);

  // The width and color of the button's leading side border.
  BorderSide get leadingBorderSide => _leadingBorderSide;
  BorderSide _leadingBorderSide;
  set leadingBorderSide(BorderSide value) {
    if (_leadingBorderSide == value) return;
    _leadingBorderSide = value;
    markNeedsLayout();
  }

  // The width and color of the button's top and bottom side borders.
  BorderSide get horizontalBorderSide => _horizontalBorderSide;
  BorderSide _horizontalBorderSide;
  set horizontalBorderSide(BorderSide value) {
    if (_horizontalBorderSide == value) return;
    _horizontalBorderSide = value;
    markNeedsLayout();
  }

  // The width and color of the button's trailing side border.
  BorderSide get trailingBorderSide => _trailingBorderSide;
  BorderSide _trailingBorderSide;
  set trailingBorderSide(BorderSide value) {
    if (_trailingBorderSide == value) return;
    _trailingBorderSide = value;
    markNeedsLayout();
  }

  // The border radii of each corner of the button.
  BorderRadius get borderRadius => _borderRadius;
  BorderRadius _borderRadius;
  set borderRadius(BorderRadius value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsLayout();
  }

  // Whether or not this toggle button is the first button in the list.
  bool get isFirstButton => _isFirstButton;
  bool _isFirstButton;
  set isFirstButton(bool value) {
    if (_isFirstButton == value) return;
    _isFirstButton = value;
    markNeedsLayout();
  }

  // Whether or not this toggle button is the last button in the list.
  bool get isLastButton => _isLastButton;
  bool _isLastButton;
  set isLastButton(bool value) {
    if (_isLastButton == value) return;
    _isLastButton = value;
    markNeedsLayout();
  }

  // The direction in which text flows for this application.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  static double _maxHeight(RenderBox box, double width) {
    return box == null ? 0.0 : box.getMaxIntrinsicHeight(width);
  }

  static double _minWidth(RenderBox box, double height) {
    return box == null ? 0.0 : box.getMinIntrinsicWidth(height);
  }

  static double _maxWidth(RenderBox box, double height) {
    return box == null ? 0.0 : box.getMaxIntrinsicWidth(height);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    // The baseline of this widget is the baseline of its child
    return child.computeDistanceToActualBaseline(baseline) + horizontalBorderSide.width;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return horizontalBorderSide.width + _maxHeight(child, width) + horizontalBorderSide.width;
  }

  @override
  double computeMinIntrinsicHeight(double width) => computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double trailingWidth = trailingBorderSide == null ? 0.0 : trailingBorderSide.width;
    return leadingBorderSide.width + _maxWidth(child, height) + trailingWidth;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final double trailingWidth = trailingBorderSide == null ? 0.0 : trailingBorderSide.width;
    return leadingBorderSide.width + _minWidth(child, height) + trailingWidth;
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.constrain(Size(
        leadingBorderSide.width + trailingBorderSide.width,
        horizontalBorderSide.width * 2.0,
      ));
      return;
    }

    final double trailingBorderOffset = isLastButton ? trailingBorderSide.width : 0.0;
    double leftConstraint;
    double rightConstraint;

    switch (textDirection) {
      case TextDirection.ltr:
        rightConstraint = trailingBorderOffset;
        leftConstraint = leadingBorderSide.width;

        final BoxConstraints innerConstraints = constraints.deflate(
          EdgeInsets.only(
            left: leftConstraint,
            top: horizontalBorderSide.width,
            right: rightConstraint,
            bottom: horizontalBorderSide.width,
          ),
        );

        child.layout(innerConstraints, parentUsesSize: true);
        final BoxParentData childParentData = child.parentData;
        childParentData.offset = Offset(leadingBorderSide.width, leadingBorderSide.width);

        size = constraints.constrain(Size(
          leftConstraint + child.size.width + rightConstraint,
          horizontalBorderSide.width * 2.0 + child.size.height,
        ));
        break;
      case TextDirection.rtl:
        rightConstraint = leadingBorderSide.width;
        leftConstraint = trailingBorderOffset;

        final BoxConstraints innerConstraints = constraints.deflate(
          EdgeInsets.only(
            left: leftConstraint,
            top: horizontalBorderSide.width,
            right: rightConstraint,
            bottom: horizontalBorderSide.width,
          ),
        );

        child.layout(innerConstraints, parentUsesSize: true);
        final BoxParentData childParentData = child.parentData;

        if (isLastButton) {
          childParentData.offset = Offset(trailingBorderOffset, trailingBorderOffset);
        } else {
          childParentData.offset = Offset(0, horizontalBorderSide.width);
        }

        size = constraints.constrain(Size(
          leftConstraint + child.size.width + rightConstraint,
          horizontalBorderSide.width * 2.0 + child.size.height,
        ));
        break;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final Offset bottomRight = size.bottomRight(offset);
    final Rect outer = Rect.fromLTRB(offset.dx, offset.dy, bottomRight.dx, bottomRight.dy);
    final Rect center = outer.deflate(horizontalBorderSide.width / 2.0);
    const double sweepAngle = pi / 2.0;

    final RRect rrect = RRect.fromRectAndCorners(
      center,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    ).scaleRadii();

    final Rect tlCorner = Rect.fromLTWH(
      rrect.left,
      rrect.top,
      rrect.tlRadiusX * 2.0,
      rrect.tlRadiusY * 2.0,
    );
    final Rect blCorner = Rect.fromLTWH(
      rrect.left,
      rrect.bottom - (rrect.blRadiusY * 2.0),
      rrect.blRadiusX * 2.0,
      rrect.blRadiusY * 2.0,
    );
    final Rect trCorner = Rect.fromLTWH(
      rrect.right - (rrect.trRadiusX * 2),
      rrect.top,
      rrect.trRadiusX * 2,
      rrect.trRadiusY * 2,
    );
    final Rect brCorner = Rect.fromLTWH(
      rrect.right - (rrect.brRadiusX * 2),
      rrect.bottom - (rrect.brRadiusY * 2),
      rrect.brRadiusX * 2,
      rrect.brRadiusY * 2,
    );

    final Paint leadingPaint = leadingBorderSide.toPaint();
    switch (textDirection) {
      case TextDirection.ltr:
        if (isLastButton) {
          final Path leftPath = Path()
            ..moveTo(rrect.left, rrect.bottom + leadingBorderSide.width / 2)
            ..lineTo(rrect.left, rrect.top - leadingBorderSide.width / 2);
          context.canvas.drawPath(leftPath, leadingPaint);

          final Paint endingPaint = trailingBorderSide.toPaint();
          final Path endingPath = Path()
            ..moveTo(rrect.left + horizontalBorderSide.width / 2.0, rrect.top)
            ..lineTo(rrect.right - rrect.trRadiusX, rrect.top)
            ..addArc(trCorner, pi * 3.0 / 2.0, sweepAngle)
            ..lineTo(rrect.right, rrect.bottom - rrect.brRadiusY)
            ..addArc(brCorner, 0, sweepAngle)
            ..lineTo(rrect.left + horizontalBorderSide.width / 2.0, rrect.bottom);
          context.canvas.drawPath(endingPath, endingPaint);
        } else if (isFirstButton) {
          final Path leadingPath = Path()
            ..moveTo(outer.right, rrect.bottom)
            ..lineTo(rrect.left + rrect.blRadiusX, rrect.bottom)
            ..addArc(blCorner, pi / 2.0, sweepAngle)
            ..lineTo(rrect.left, rrect.top + rrect.tlRadiusY)
            ..addArc(tlCorner, pi, sweepAngle)
            ..lineTo(outer.right, rrect.top);
          context.canvas.drawPath(leadingPath, leadingPaint);
        } else {
          final Path leadingPath = Path()
            ..moveTo(rrect.left, rrect.bottom + leadingBorderSide.width / 2)
            ..lineTo(rrect.left, rrect.top - leadingBorderSide.width / 2);
          context.canvas.drawPath(leadingPath, leadingPaint);

          final Paint horizontalPaint = horizontalBorderSide.toPaint();
          final Path horizontalPaths = Path()
            ..moveTo(rrect.left + horizontalBorderSide.width / 2.0, rrect.top)
            ..lineTo(outer.right - rrect.trRadiusX, rrect.top)
            ..moveTo(rrect.left + horizontalBorderSide.width / 2.0 + rrect.tlRadiusX, rrect.bottom)
            ..lineTo(outer.right - rrect.trRadiusX, rrect.bottom);
          context.canvas.drawPath(horizontalPaths, horizontalPaint);
        }
        break;
      case TextDirection.rtl:
        if (isLastButton) {
          final Path leadingPath = Path()
            ..moveTo(rrect.right, rrect.bottom + leadingBorderSide.width / 2)
            ..lineTo(rrect.right, rrect.top - leadingBorderSide.width / 2);
          context.canvas.drawPath(leadingPath, leadingPaint);

          final Paint endingPaint = trailingBorderSide.toPaint();
          final Path endingPath = Path()
            ..moveTo(rrect.right - horizontalBorderSide.width / 2.0, rrect.top)
            ..lineTo(rrect.left + rrect.tlRadiusX, rrect.top)
            ..addArc(tlCorner, pi * 3.0 / 2.0, -sweepAngle)
            ..lineTo(rrect.left, rrect.bottom - rrect.blRadiusY)
            ..addArc(blCorner, pi, -sweepAngle)
            ..lineTo(rrect.right - horizontalBorderSide.width / 2.0, rrect.bottom);
          context.canvas.drawPath(endingPath, endingPaint);
        } else if (isFirstButton) {
          final Path leadingPath = Path()
            ..moveTo(outer.left, rrect.bottom)
            ..lineTo(rrect.right - rrect.brRadiusX, rrect.bottom)
            ..addArc(brCorner, pi / 2.0, -sweepAngle)
            ..lineTo(rrect.right, rrect.top + rrect.trRadiusY)
            ..addArc(trCorner, 0, -sweepAngle)
            ..lineTo(outer.left, rrect.top);
          context.canvas.drawPath(leadingPath, leadingPaint);
        } else {
          final Path leadingPath = Path()
            ..moveTo(rrect.right, rrect.bottom + leadingBorderSide.width / 2)
            ..lineTo(rrect.right, rrect.top - leadingBorderSide.width / 2);
          context.canvas.drawPath(leadingPath, leadingPaint);

          final Paint horizontalPaint = horizontalBorderSide.toPaint();
          final Path horizontalPaths = Path()
            ..moveTo(rrect.right - horizontalBorderSide.width / 2.0, rrect.top)
            ..lineTo(outer.left - rrect.tlRadiusX, rrect.top)
            ..moveTo(rrect.right - horizontalBorderSide.width / 2.0 + rrect.trRadiusX, rrect.bottom)
            ..lineTo(outer.left - rrect.tlRadiusX, rrect.bottom);
          context.canvas.drawPath(horizontalPaths, horizontalPaint);
        }
        break;
    }
  }
}
