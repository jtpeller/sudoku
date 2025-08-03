import 'package:flutter/material.dart';
import '../theme/styles.dart';

///////////////////////////////
///       SHOW DIALOGS      ///
///////////////////////////////

void showYesNoDialog(BuildContext context, String title, String message, VoidCallback onYes) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message)
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onYes();
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
        ],
      );
    },
  );
}

void showInfoDialog(BuildContext context, String title, Widget content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

///////////////////////////////
///   CUSTOM GAME WIDGETS   /// 
///////////////////////////////

class TooltipIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const TooltipIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      textStyle: ThemeStyle.tooltip(context),
      child: IconButton(
        icon: Icon(icon),
        style: ThemeStyle.iconButtonThemeData(context).style,
        iconSize: ThemeStyle.option(context).fontSize! * 1.25,
        onPressed: onPressed,
      ),
    );
  }
}
