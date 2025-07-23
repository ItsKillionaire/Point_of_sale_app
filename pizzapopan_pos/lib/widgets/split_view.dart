import 'package:flutter/material.dart';

class SplitView extends StatefulWidget {
  final Widget left;
  final Widget right;
  final double initialRatio;

  const SplitView({
    Key? key,
    required this.left,
    required this.right,
    this.initialRatio = 0.3,
  }) : super(key: key);

  @override
  _SplitViewState createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          SizedBox(
            width: constraints.maxWidth * _ratio,
            child: widget.left,
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _ratio += details.delta.dx / constraints.maxWidth;
                _ratio = _ratio.clamp(0.15, 0.85);
              });
            },
            child: Container(
              width: 10,
              color: Colors.grey.withOpacity(0.5),
              child: const Center(
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: widget.right,
          ),
        ],
      );
    });
  }
}
