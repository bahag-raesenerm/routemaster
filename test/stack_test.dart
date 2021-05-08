import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can push and pop a page via delegate pop()', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);

    await delegate.popRoute();
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can push and pop a page via Navigator', (tester) async {
    final page2Key = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo(key: page2Key)),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);

    Navigator.of(page2Key.currentContext!).pop();
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can push and pop a page via delegate', (tester) async {
    final page1Key = GlobalKey();
    final page2Key = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne(key: page1Key)),
        '/two': (_) => MaterialPage<void>(child: PageTwo(key: page2Key)),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    Routemaster.of(page1Key.currentContext!).push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);

    await Routemaster.of(page2Key.currentContext!).pop();
    await tester.pump();

    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can push and pop a page via system back button', (tester) async {
    final page1Key = GlobalKey();
    final page2Key = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne(key: page1Key)),
        '/two': (_) => MaterialPage<void>(child: PageTwo(key: page2Key)),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);

    await invokeSystemBack();
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can push and pop a page with query string', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.push('two?query=string');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two?query=string'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can push a page with query string', (tester) async {
    late RouteData routeData;
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (info) {
          routeData = info;
          return MaterialPage<void>(child: PageTwo());
        },
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('two', queryParameters: {'query': 'string'});
    await tester.pump();

    expect(routeData.queryParameters['query'], 'string');
  });

  test('Stack.maybePop() pops with no navigator', () async {
    final lastRouteData = RouteData('/last');
    final stack = PageStack(
      routes: [
        StatelessPage(
          page: MaterialPageOne(),
          routeData: RouteData('/'),
        ),
        StatelessPage(
          page: MaterialPageTwo(),
          routeData: lastRouteData,
        ),
      ],
    );

    expect(await stack.maybePop(), isTrue);
  });

  test('Stack.maybePop() returns false with one child', () async {
    final stack = PageStack(
      routes: [
        StatelessPage(page: MaterialPageOne(), routeData: RouteData('/')),
      ],
    );

    expect(await stack.maybePop(), isFalse);
  });

  testWidgets('Can pop stack within tabs via system back', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) => TabPage(child: MyTabPage(), paths: ['one', 'two']),
          '/tabs/one': (_) => MaterialPageOne(),
          '/tabs/one/subpage': (_) => MaterialPageThree(),
          '/tabs/two': (_) => MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
            location: '/tabs/one/subpage',
          ),
        ),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageThree), findsOneWidget);
    await invokeSystemBack();
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageThree), findsNothing);
  });

  test('Removes listener from routes on replace', () {
    final page1 = TestPageWrapper();
    final page2 = TestPageWrapper();
    final stack = PageStack(routes: [page1]);

    // ignore: invalid_use_of_protected_member
    expect(page1.hasListeners, isTrue);
    stack.maybeSetChildPages([page2]);

    // ignore: invalid_use_of_protected_member
    expect(page1.hasListeners, isFalse);
    // ignore: invalid_use_of_protected_member
    expect(page2.hasListeners, isTrue);
  });

  testWidgets('Asserts if unable to find StackNavigationState', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(builder: (c) {
        context = c;
        return SizedBox();
      }),
    );

    expect(
      () => StackNavigator.of(context),
      throwsA(predicate((e) =>
          e is AssertionError &&
          e.message == "Couldn't find a StackNavigatorState")),
    );
  });

  testWidgets('Can update StackNavigator with a new stack', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: StackSwapPage()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.text('Stack 1'), findsOneWidget);
    final state =
        tester.state(find.byType(StackSwapPage)) as StackSwapPageState;
    state._swapNavigators();
    await tester.pump();
    expect(find.text('Stack 2'), findsOneWidget);
  });
}

class StackSwapPage extends StatefulWidget {
  @override
  StackSwapPageState createState() => StackSwapPageState();
}

class StackSwapPageState extends State<StackSwapPage> {
  bool _firstNavigator = true;
  void _swapNavigators() {
    setState(() {
      _firstNavigator = false;
    });
  }

  final _stack1 = PageStack(routes: [
    StatelessPage(
      page: MaterialPage<void>(child: Text('Stack 1')),
      routeData: RouteData('/'),
    )
  ]);

  final _stack2 = PageStack(routes: [
    StatelessPage(
      page: MaterialPage<void>(child: Text('Stack 2')),
      routeData: RouteData('/'),
    )
  ]);

  @override
  Widget build(BuildContext context) {
    return StackNavigator(stack: _firstNavigator ? _stack1 : _stack2);
  }
}

class TestPageWrapper extends PageWrapper with ChangeNotifier {
  @override
  Page createPage() {
    throw UnimplementedError();
  }

  @override
  Iterable<List<PageWrapper>> getCurrentPages() {
    throw UnimplementedError();
  }

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) {
    throw UnimplementedError();
  }

  @override
  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    throw UnimplementedError();
  }

  @override
  RouteData get routeData => throw UnimplementedError();
}

class MyTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stack = TabPage.of(context).stacks[0];

    return Container(
      height: 300,
      child: StackNavigator(stack: stack),
    );
  }
}
