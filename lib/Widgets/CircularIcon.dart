import 'package:flutter/cupertino.dart';

class CircularIcon extends StatelessWidget {
  
  final Widget icon ;
  final Color circleColor ;

  CircularIcon({
    @required
    this.circleColor,
    @required
    this.icon
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: this.circleColor
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: this.icon,  
      ),
    );
  }

}