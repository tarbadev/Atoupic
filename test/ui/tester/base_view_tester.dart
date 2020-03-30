import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class BaseViewTester {
  BaseViewTester(this.tester);

  final WidgetTester tester;

  bool widgetExists(String key) {
    try {
      tester.renderObject<RenderBox>(find.byKey(Key(key)));
      return true;
    } catch (_) {
      return false;
    }
  }

  String getTextByKey(String key) {
    var textFinder = find.byKey(Key(key));
    expect(textFinder, findsOneWidget);

    Text text = tester.widget(textFinder);
    return text.data;
  }

  Future<void> tapOnButtonByKey(String key) async {
    await tester.tap(find.byKey(Key(key)));
  }

  Future<void> tapOnButtonByWidgetAndText(Type widget, String text) async {
    await tester.tap(find.widgetWithText(widget, text));
  }
}
