import 'package:flutter/material.dart';

/// スライダーの共通設定値
class SliderConfig {
  /// トラックの高さ
  static const trackHeight = 8.0;

  /// Thumbの幅（縦線バーの場合）
  static const thumbWidth = 4.0;

  /// Thumbの高さ（縦線バーの場合）
  static const thumbHeight = 24.0;

  /// Overlay（タップ時の波紋）の半径
  static const overlayRadius = 22.0;

  /// tick markの位置をtrackの始点からずらすためのオフセット
  static const tickMarkOffset = 10.0;

  /// tick markのドットのサイズ
  static const tickMarkDotSize = 4.0;

  /// tick markのラベルの幅
  static const tickMarkLabelWidth = 25.0;

  /// tick markのドットとラベルの間隔
  static const tickMarkLabelSpacing = 8.0;
}

class CustomRangeSlider extends StatelessWidget {
  const CustomRangeSlider({
    super.key,
    required this.min,
    required this.max,
    required this.currentStartValue,
    required this.currentEndValue,
    this.onChanged,
    required this.labels,
    this.allowSameValues = false,
  });

  final double min;
  final double max;
  final double currentStartValue;
  final double currentEndValue;
  final void Function(RangeValues values)? onChanged;
  final List<String> labels;
  final bool allowSameValues;

  int get _divisions => labels.length - 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // フレームワークの始点のtick markから10px擬似的にずらした位置に配置するため、Slider自体にPaddingをかけて調整
          padding: const EdgeInsets.symmetric(
            horizontal: SliderConfig.tickMarkOffset,
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: SliderConfig.trackHeight,
              activeTrackColor: colorScheme.primary,
              rangeThumbShape: _CustomeRangeSliderThumbShape(
                thumbColor: colorScheme.primary,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: SliderConfig.overlayRadius,
              ),
              rangeTrackShape: _CustomRangeSliderTrackShape(
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.secondaryContainer,
              ),
              // 標準のtickMarkは非表示にする
              rangeTickMarkShape: const RoundRangeSliderTickMarkShape(
                tickMarkRadius: 0,
              ),
            ),
            child: RangeSlider(
              min: min,
              max: max,
              values: RangeValues(currentStartValue, currentEndValue),
              divisions: _divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        // 目盛りのドットとラベル
        // RangeSliderと同じ計算式でtick markを配置
        // padding = trackHeight (8px)
        // adjustedTrackWidth = trackWidth - padding
        // dx = value * adjustedTrackWidth + padding / 2
        // 外側のPadding(10px)でtrackの始点からtick markをずらす
        //
        // Flutter公式 RangeSliderのtick mark配置ロジックを参考に実装
        // ref: https://github.com/flutter/flutter/blob/f159b58f96e4bc4f97666b6c76127015268373e3/packages/flutter/lib/src/material/range_slider.dart#L1678-L1706
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SliderConfig.tickMarkOffset,
          ),
          child: LayoutBuilder(
            builder: (_, constraints) {
              const padding = SliderConfig.trackHeight;
              final trackWidth = constraints.maxWidth;
              final adjustedTrackWidth = trackWidth - padding;

              return SizedBox(
                height: 20,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(_divisions + 1, (index) {
                    final value = index / _divisions;
                    final label = labels[index];
                    // Paddingウィジェット内は相対座標（0から開始）
                    // フレームワークの計算式と同じだが、trackLeftは不要
                    final dx = value * adjustedTrackWidth + padding / 2;

                    return [
                      // tickMark(ドット)
                      Positioned(
                        left: dx - SliderConfig.tickMarkDotSize / 2,
                        top: 0,
                        child: Container(
                          width: SliderConfig.tickMarkDotSize,
                          height: SliderConfig.tickMarkDotSize,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // ラベル
                      Positioned(
                        left: dx - SliderConfig.tickMarkLabelWidth / 2,
                        top: SliderConfig.tickMarkLabelSpacing,
                        child: SizedBox(
                          width: SliderConfig.tickMarkLabelWidth,
                          child: Text(
                            label,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ];
                  }).expand((widgets) => widgets).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CustomeRangeSliderThumbShape extends RangeSliderThumbShape {
  const _CustomeRangeSliderThumbShape({required this.thumbColor});

  final Color thumbColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromHeight(SliderConfig.thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    // 縦線の矩形を作成
    final rect = Rect.fromCenter(
      center: center,
      width: SliderConfig.thumbWidth,
      height: SliderConfig.thumbHeight,
    );

    // 縦線を描画
    final rRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(SliderConfig.thumbWidth / 2),
    );

    final paint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(rRect, paint);
  }
}

class _CustomRangeSliderTrackShape extends RangeSliderTrackShape {
  const _CustomRangeSliderTrackShape({
    required this.activeColor,
    required this.inactiveColor,
  });

  final Color activeColor;
  final Color inactiveColor;

  /// trackの角丸矩形を描画
  void _paintTrackSegment({
    required Canvas canvas,
    required double left,
    required double top,
    required double right,
    required double bottom,
    required Color color,
    required double borderRadius,
  }) {
    final rect = Rect.fromLTRB(left, top, right, bottom);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paint = Paint()..color = color;
    canvas.drawRRect(rRect, paint);
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    // trackを親ボックスの垂直方向の中央に配置
    // offset.dy: 親ボックスの描画開始位置のy座標（通常は0）
    // (parentBox.size.height - trackHeight) / 2: 上下の余白を均等に配分した上側の余白
    final trackHeight = sliderTheme.trackHeight ?? SliderConfig.trackHeight;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;

    return Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
    double additionalActiveTrackHeight = 2,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // インアクティブトラック(左サイド)
    _paintTrackSegment(
      canvas: context.canvas,
      left: rect.left - SliderConfig.tickMarkOffset,
      top: rect.top,
      right: startThumbCenter.dx,
      bottom: rect.bottom,
      color: inactiveColor,
      borderRadius: 8.0,
    );

    // アクティブトラック（選択範囲）
    _paintTrackSegment(
      canvas: context.canvas,
      left: startThumbCenter.dx,
      top: rect.top,
      right: endThumbCenter.dx,
      bottom: rect.bottom,
      color: sliderTheme.activeTrackColor ?? activeColor,
      borderRadius: 8.0,
    );

    // インアクティブトラック(右サイド)
    _paintTrackSegment(
      canvas: context.canvas,
      left: endThumbCenter.dx,
      top: rect.top,
      right: rect.right + SliderConfig.tickMarkOffset,
      bottom: rect.bottom,
      color: inactiveColor,
      borderRadius: 8.0,
    );
  }
}
