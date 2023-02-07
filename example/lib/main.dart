import 'package:flutter/material.dart';
import 'package:log_calico/log_calico.dart';

import 'filters/action_filter.dart';
import 'filters/no_filter.dart';
import 'filters/page_view_filter.dart';
import 'outputs/analytics_output.dart';
import 'outputs/my_log_output.dart';
import 'outputs/print_output.dart';

final logger = Logger(
  filters: [
    PageViewFilter('page_view'),
    ActionFilter('action'),
    NoFilter(),
  ],
  outputs: [
    MyLogOutput('my.**'),
    AnalyticsOutput('ga.**'),
    PrintOutput(
      '**',
      shouldEmit: (log) {
        return !['my', 'ga'].contains(log.tag.split('.').first);
      },
    ),
  ],
);

void main() {
  logger.start();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [MyNavigatorObserver()],
      initialRoute: 'page1',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'page1':
            return MaterialPageRoute(
                builder: (_) => Page1(), settings: settings);
          case 'page2':
            return MaterialPageRoute(
                builder: (_) => Page2(), settings: settings);
          case 'page3':
            return MaterialPageRoute(
                builder: (_) => Page3(), settings: settings);
          default:
            throw UnimplementedError();
        }
      },
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final pageName = route.settings.name;
    if (pageName != null) {
      logger.globalParams['page'] = pageName;
      logger.post({'name': pageName, 'event': 'push'}, tag: 'page_view');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final pageName = previousRoute?.settings.name;
    if (pageName != null) {
      logger.globalParams['page'] = pageName;
      logger.post({'name': pageName, 'event': 'pop'}, tag: 'page_view');
    }
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Calico')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('event'),
              onPressed: () {
                logger.post({
                  'type': 'click',
                  'target': 'event_button',
                }, tag: 'action');
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Page 2'),
              onPressed: () => Navigator.of(context).pushNamed('page2'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Page 3'),
              onPressed: () => Navigator.of(context).pushNamed('page3'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 2')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('event'),
              onPressed: () {
                logger.post({
                  'type': 'click',
                  'target': 'event_button',
                }, tag: 'action');
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Page 3'),
              onPressed: () => Navigator.of(context).pushNamed('page3'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 3')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('conversion'),
              onPressed: () {
                logger.post({
                  'type': 'click',
                  'target': 'conversion_button',
                  'foo': 123,
                  'bar': 'abc',
                }, tag: 'action');
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('no tag event'),
              onPressed: () {
                logger.post({
                  'type': 'click',
                  'target': 'no_tag_button',
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Back'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
