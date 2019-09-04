import 'package:flutter/material.dart';

class StarDisplayWidget extends StatelessWidget {
  final int value;
  final Widget filledStar;
  final Widget unfilledStar;
  final double size;
  final Color color;
  final int marginFactor;

  const StarDisplayWidget({
    Key key,
    this.value = 0,
    this.filledStar,
    this.unfilledStar,
    this.color = Colors.orange,
    this.size = 20,
    this.marginFactor = 5,
  })  : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (index) {
        return Container(
          width: size - size / marginFactor,
          height: size,
          child: Icon(
            index < value
                ? filledStar ?? Icons.star
                : unfilledStar ?? Icons.star_border,
            color: color,
            size: size,
          ),
        );
      }),
    );
  }
}

class StarRating extends StatelessWidget {
  final void Function(int index) changeStar;
  final int value;
  final IconData filledStar;
  final IconData unfilledStar;
  final double size;
  final Color color;
  final int marginFactor;
  final bool reviewed;

  const StarRating({
    Key key,
    @required this.changeStar,
    @required this.value,
    @required this.reviewed,
    this.filledStar,
    this.unfilledStar,
    this.color = Colors.orange,
    this.size = 20,
    this.marginFactor = 5,
  })  : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return RawMaterialButton(
            child: Icon(
              index < value
                  ? filledStar ?? Icons.star
                  : unfilledStar ?? Icons.star_border,
              color: color,
              size: size,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: CircleBorder(),
            constraints: BoxConstraints.expand(
                width: size - size / marginFactor, height: size),
            padding: EdgeInsets.zero,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: changeStar != null
                ? () {
                    changeStar(value == index + 1 ? index : index + 1);
                  }
                : null,
          );
        }),
      ),
      this.reviewed ? Text("Reviewed") : Text(""),
    ]);
  }
}
