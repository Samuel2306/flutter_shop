// Provide也是借助了InheritWidget，将共享状态
// 放到顶层MaterialApp之上。底层部件通过Provier
// 获取该状态，并通过混合ChangeNotifier通知依赖
// 于该状态的组件刷新。


/// ProviderNode封装了InheritWidget，并且提供了一个providers容器用于放置状态；
/// ProviderScope 为Provider提供单独的类型空间，可以将多个相同类型的提供者放在一个空间里面；
/// 默认使用ProviderScope('_default'),存放的时候你可以通过ProviderScope("name")来指定放到哪个空间
///
/// 管理多个状态
/// providers
//    ..provide(Provider<Counter>.value(counter))
//    ..provide(Provider<Switcher>.value(switcher));

/// 当我们一个视图可能依赖于多个状态进行重建的时候，可以使用ProvideMulti小部件




import 'dart:async';

import 'package:flutter/widgets.dart';

/// [ProviderNode]提供了一组[providers]给当前部件下面的所有子部件
/// 如果当前部件没有自定义prividers，就会使用父部件提供的prividers
class ProviderNode extends StatefulWidget {
  /// 可使用[providers]的部件，它与他的子部件构成一个部件树
  final Widget child;

  /// The values made available to the [child].
  final Providers providers;

  /// 控制当节点从节点树中被移除时是否处理providers的变量
  final bool dispose;

  /// 构造函数
  const ProviderNode(
      {@required this.child, @required this.providers, this.dispose = true});

  @override
  State<StatefulWidget> createState() => _ProviderNodeState(
      child: child, providers: providers, disposeProviders: dispose);
}

class _ProviderNodeState extends State<ProviderNode> {
  /// 可使用[providers]的部件，它与他的子部件构成一个部件树
  final Widget child;

  /// The values made available to the [child].
  final Providers providers;

  /// 控制当节点从节点树中被移除时是否处理providers的变量
  final bool disposeProviders;

  _ProviderNodeState(
      {@required this.child,
        @required this.providers,
        @required this.disposeProviders});

  @override
  Widget build(BuildContext context) {
    return _InheritedProviders(
        child: child,
        providers: providers,
        parent: _InheritedProviders.of(context));
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    if (disposeProviders) {
      await providers.dispose();
    }
  }
}

/// A [ProviderScope] provides a separate type-space for a provider, thus
/// allowing more than one provider of the same type.
/// A [ProviderScope]提供了分离式的类型空间给每个provider，因此允许一个类型有多个provider
///
/// 应始终将其初始化为静态常量进行传递.
/// name 仅用于描述目的.
class ProviderScope {
  final String _name;

  /// Constructor
  const ProviderScope(this._name);

  @override
  String toString() {
    return "Scope ('$_name')";
  }
}

/// Providers are the values passed to the [ProviderNodes].
///
/// Providers can be added to using either convenience functions such as
/// [provideValue] or by passing in Providers.
/// Providers可以通过另外便捷的方式来添加，比如说[provideValue]或者直接通过Providers传递

class Providers {
  // The Provider for each given [Type] should return that type, but we can't
  // enforce that here directy. We can use APIs to make sure it's type-safe.
  //每个给定[类型]的提供者应返回该类型，但我们不能在这里强制执行。我们可以使用API​​来确保它是类型安全的
  final Map<ProviderScope, Map<Type, Provider<dynamic>>> _providers = {};

  /// Creates a new empty provider.
  Providers();

  /// 没有定义范围的任何类型所在的默认范围。
  static const ProviderScope defaultScope = ProviderScope('_default');

  /// Creates a provider with the included providers.
  /// 如果提供了范围，则值将在该范围内.
  factory Providers.withProviders(Map<Type, Provider<dynamic>> providers,
      {ProviderScope scope}) =>
      Providers()..provideAll(providers, scope: scope);

  /// 为单一类型添加提供provider
  /// Will override any existing provider of that type in this node with the
  /// given scope. If no [scope] is passed in, the default one will be used.
  /// 会覆盖给定scope下，当前node下相同类型的provider，如果没有指定scope，就是用默认的scope
  void provide<T>(Provider<T> provider, {ProviderScope scope}) {
    // This should never happen.
    assert(provider.type == T);

    _providersForScope(scope)[T] = provider;
  }

  /// Provide many providers at once.
  ///
  /// Prefer using [provide] and [provideFrom] because that catches type
  /// errors at compile-time.
  /// 首选使用[provide]和[provideFrom]，因为这样会捕获类型编译时的错误
  void provideAll(Map<Type, Provider> providers, {ProviderScope scope}) {
    for (var entry in providers.entries) {
      if (entry.key != entry.value.type) {
        if (entry.value.type == dynamic) {
          throw ArgumentError('Not able to infer the type of provider for'
              ' ${entry.key} automatically. Add type argument to provider.');
        }
        throw ArgumentError('Type mismatch between ${entry.key} and provider '
            'of ${entry.value.type}.');
      }
    }

    _providersForScope(scope).addAll(providers);
  }

  /// Add in all the providers from another Providers.
  /// 添加其他Providers的所有provider
  void provideFrom(Providers other) {
    for (final scope in other._providers.keys) {
      provideAll(other._providersForScope(scope), scope: scope);
    }
  }

  /// 添加基于值的提供者的语法糖。
  ///
  /// If this value is [Listenable], widgets that use this value can be rebuilt
  /// on change. If no [scope] is passed in, the default one will be used.
  void provideValue<T>(T value, {ProviderScope scope}) {
    provide(Provider.value(value), scope: scope);
  }

  /// Disposes of any streams or stored values in the providers.
  /// 处理providers中的任何流或者存储值
  Future<void> dispose() async {
    for (final scopeMap in _providers.values) {
      for (final provider in scopeMap.values) {
        await provider.dispose();
      }
    }
  }

  /// Provider in this case will always be of the provider type, but there is no
  /// way to make this type safe.
  ///
  /// 内部用户应尽可能地抛出它.
  @visibleForTesting
  Provider getFromType(Type type, {ProviderScope scope}) {
    return _providersForScope(scope)[type];
  }

  Map<Type, Provider<dynamic>> _providersForScope(scope) =>
      _providers[scope ?? defaultScope] ??= {};
}

/// A Provider provides a value on request.
///
/// If a provider implements [Listenable], it will be listened to by the
/// [Provide] widget to rebuild on change. Other than the built in providers,
/// one can implement Provider to provide caching or linkages.
/// 如果一个provider实现了[Listenable]，它就会被[Provide] 部件监听，当Listenable更改时，部件就会重建
/// 除了内置的providers，可以实现Provider来提供缓存或链接。
///
/// When a Provider is instantiated within a [providers.provide] call, the type
/// can be inferred and therefore the type can be ommited, but otherwise,
/// [T] is required.
/// 当一个Provider是在一个[providers.provide]调用中被实例化的，那么它的类型可以被推断，因此可以省略；但除此之外，[T]是必需的。
///
/// Provider should be implemented and not extended.
abstract class Provider<T> {
  /// Returns the value provided by the provider.
  ///
  /// Because providers could potentially initialize the value each time [get]
  /// is called, this should be called as infrequently as possible.
  T get(BuildContext context);

  /// Returns a stream of changes to the underlying value.
  Stream<T> stream(BuildContext context);

  /// Disposes of any resources or listeners held on by the provider.
  Future<void> dispose();

  /// The type that is provided by the provider.
  Type get type;

  /// Creates a provider with the value provided to it.
  factory Provider.value(T value) => _ValueProvider(value);

  /// Creates a provider which will initialize using the [ProviderFunction]
  /// the first time the value is requested.
  ///
  /// The context can be used to obtain other values from the provider. However,
  /// care should be taken with this to not have circular dependencies.
  factory Provider.function(ProviderFunction<T> function) =>
      _LazyProvider<T>(function);

  /// Creates a provider that provides a new value for each
  /// requestor of the value.
  factory Provider.withFactory(ProviderFunction<T> function) =>
      _FactoryProvider<T>(function);

  /// Creates a provider that listens to a stream and caches the last
  /// received value of the stream.
  ///
  /// This provider notifies for rebuild after every release.
  factory Provider.stream(Stream<T> stream, {T initialValue}) =>
      _StreamProvider<T>(stream, initialValue: initialValue);
}

/// Base mixin for providers.
abstract class TypedProvider<T> implements Provider<T> {
  /// The type of the provider
  @override
  Type get type => T;
}

/// A widget that obtains the given value from the nearest provider and rebuilds
/// using the [builder] whenever it changes.
///
/// Either the provider or the value must implement [Listenable]. To obtain a
/// value without listening to changes, the static [Provide.value<T>] function
/// should be used instead.
///
/// To improve performance by having less rebuilds, the part of the tree rebuilt
/// by builder should be minimized by putting as much of the tree in [child] as
/// possible, or using the static function.
/// If no scope is provided, the default one will be used.
class Provide<T> extends StatelessWidget {
  /// Called whenever there is a change.
  final ValueBuilder<T> builder;

  /// The part of the widget tree not rebuilt on change.
  final Widget child;

  /// The scope from which the type is requested
  final ProviderScope scope;

  /// Constructor.
  const Provide({@required this.builder, this.child, this.scope});

  /// Used to obtain provided values without listening to their changes.
  static T value<T>(BuildContext context, {ProviderScope scope}) {
    final provider = _InheritedProviders.of(context).getValue<T>(scope: scope);
    assert(provider != null);

    return provider.get(context);
  }

  /// Used to obtain provided values in the form of a stream that sends its
  /// value on change.
  static Stream<T> stream<T>(BuildContext context, {ProviderScope scope}) {
    final provider = _InheritedProviders.of(context).getValue<T>(scope: scope);
    assert(provider != null);

    return provider.stream(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _InheritedProviders.of(context).getValue<T>(scope: scope);
    final value = provider.get(context);
    final listenable = _getListenable(provider, value);

    if (provider is Listenable) {
      return ListeningBuilder(
        listenable: listenable,
        child: child,
        builder: (buildContext, child) =>
            builder(buildContext, child, provider.get(context)),
      );
    } else if (value is Listenable) {
      return ListeningBuilder(
        listenable: listenable,
        child: child,
        builder: (buildContext, child) => builder(buildContext, child, value),
      );
    }

    throw ArgumentError('Either the type or the provider of it must'
        ' implement listenable. To get a non-listenable value, use the static'
        ' Provide.value<T>.');
  }
}

/// Pass in value as well to avoid calling provider.get multiple times because
/// that could have side effects for some provider types.
Listenable _getListenable(Provider provider, dynamic value) =>
    provider is Listenable ? provider : value is Listenable ? value : null;

/// Widget that rebuilds on change using multiple values provided by a
/// [ProviderNode].
///
/// [ProvideMulti] is the functional equivalent of chained [Provide] widgets.
/// It will call builder whenever any of the requested values changes.
///
/// As with [Provide], the builder should just build as little as possible to
/// optimize performance.
class ProvideMulti extends StatelessWidget {
  /// A set of requested values per scope
  final Map<ProviderScope, List<Type>> requestedScopedValues;

  /// Is called each time any of the [requestedValues] changes
  final MultiValueBuilder builder;

  /// The part of the widget tree not rebuilt on change.
  final Widget child;

  /// Both [requestedValues] and [requestedScopedValues] can be passed
  /// in at the same time.
  ProvideMulti({
    @required this.builder,
    this.child,
    List<Type> requestedValues,
    Map<ProviderScope, List<Type>> requestedScopedValues,
  }) : requestedScopedValues = {}
    ..addAll(requestedScopedValues ?? {})
    ..putIfAbsent(Providers.defaultScope, () => requestedValues ?? []);

  @override
  Widget build(BuildContext context) {
    final providers = _InheritedProviders.of(context);

    final values = <ProviderScope, Map<Type, dynamic>>{};
    final listenables = <Listenable>[];

    for (final providerScope in requestedScopedValues.keys) {
      for (final type in requestedScopedValues[providerScope]) {
        final provider = providers.getFromType(type, scope: providerScope);
        final value = provider.get(context);
        listenables.add(_getListenable(provider, value));
        (values[providerScope] ??= {})[type] = value;
      }
    }

    return ListeningBuilder(
      listenable: _MergedListenable(listenables),
      child: child,
      builder: (buildContext, child) =>
          builder(buildContext, child, _update(context, values)),
    );
  }

  // When the provider is the one that is changing instead of the value,
  // the values in the map returned need to be updated.
  ProvidedValues _update(
      BuildContext context, Map<ProviderScope, Map<Type, dynamic>> values) {
    final providers = _InheritedProviders.of(context);

    for (final providerScope in requestedScopedValues.keys) {
      for (final type in requestedScopedValues[providerScope]) {
        final provider = providers.getFromType(type, scope: providerScope);
        if (provider is Listenable) {
          final value = provider.get(context);
          values[providerScope][type] = value;
        }
      }
    }

    return ProvidedValues._(values);
  }
}

/// A container for the values passed to the [MultiValueBuilder].
class ProvidedValues {
  final Map<ProviderScope, Map<Type, dynamic>> _values;

  /// Should only be called by ProvideMulti.
  ProvidedValues._(this._values);

  /// Gets the value in question.
  /// [T] must be a type passed in as part of [requestedValues].
  T get<T>({ProviderScope scope}) =>
      _values[scope ?? Providers.defaultScope][T];
}

/// Builds a child for a [Provide] widget.
typedef ValueBuilder<T> = Widget Function(
    BuildContext context,
    Widget child,
    T value,
    );

/// Builds a child for a [ProvideMulti] widget.
typedef MultiValueBuilder = Widget Function(
    BuildContext context,
    Widget child,
    ProvidedValues values,
    );

/// Contains a value which will never be disposed.
class _ValueProvider<T> extends TypedProvider<T> {
  final T _value;
  StreamController _streamController;

  @override
  T get(BuildContext context) => _value;

  @override
  Stream<T> stream(BuildContext context) {
    final value = _value;
    if (value is Listenable) {
      _streamController ??= StreamController<T>.broadcast();
      value.addListener(_streamListener);
    } else {
      throw UnsupportedError(
          'Cannot create stream from a value that is not Listenable');
    }

    return _streamController.stream;
  }

  _ValueProvider(this._value);

  @override
  Future<void> dispose() async {
    final value = _value;
    if (value is Listenable) {
      value.removeListener(_streamListener);
    }
    await _streamController?.close();
  }

  void _streamListener() {
    _streamController?.add(_value);
  }
}

/// Function that returns an instance of T when called.
typedef ProviderFunction<T> = T Function(BuildContext context);

/// Is initialized on demand, and disposed when no longer needed
/// if [dispose] is set to true.
/// When obtained statically, the value will never be disposed.
class _LazyProvider<T> extends ChangeNotifier with TypedProvider<T> {
  final ProviderFunction<T> _initalizer;

  T _value;
  StreamController _streamController;

  _LazyProvider(this._initalizer);

  @override
  Future<void> dispose() async {
    final value = _value;
    if (value is Listenable) {
      value..removeListener(_streamListener)..removeListener(notifyListeners);
    }
    await _streamController?.close();
    _value = null;
    super.dispose();
  }

  @override
  T get(BuildContext context) {
    // Need to have a local copy for casting because
    // dart requires it.
    T value;
    if (_value == null) {
      value = _value ??= _initalizer(context);
      if (value is Listenable) {
        value.addListener(notifyListeners);
      }
    }
    return _value;
  }

  @override
  Stream<T> stream(BuildContext context) {
    final value = _value;
    if (value is Listenable) {
      _streamController ??= StreamController<T>.broadcast();
      value.addListener(_streamListener);
    } else {
      throw UnsupportedError(
          'Cannot create stream from a value that is not Listenable');
    }

    return _streamController.stream;
  }

  void _streamListener() {
    _streamController?.add(_value);
  }
}

/// A provider who's value is obtained from providerFunction for each time the
/// value is requested.
///
/// This provider doesn't keep any values itself, so those values are disposed
/// when the containing widget is disposed.
class _FactoryProvider<T> with TypedProvider<T> {
  final ProviderFunction<T> providerFunction;

  _FactoryProvider(this.providerFunction);

  @override
  T get(BuildContext context) => providerFunction(context);

  @override
  Stream<T> stream(BuildContext context) =>
      throw UnsupportedError('Stream not supported for factory providers');

  @override
  Future<void> dispose() async {}
}

/// Provider that takes a stream.
///
/// This provider will always listen and cache the last value received from
/// the stream, and notify listeners when there's a change.
class _StreamProvider<T> extends ChangeNotifier with TypedProvider<T> {
  final Stream<T> _stream;
  T _lastValue;
  StreamSubscription _listener;

  /// Immediately starts listening to the stream and caching values.
  _StreamProvider(Stream<T> stream, {T initialValue})
      : _lastValue = initialValue,
        _stream = stream.isBroadcast ? stream : stream.asBroadcastStream() {
    _listener = _stream.listen((data) {
      if (_lastValue != data) {
        _lastValue = data;
        notifyListeners();
      }
    });
  }

  @override
  Stream<T> stream(BuildContext context) => _stream;

  @override
  T get(BuildContext context) => _lastValue;

  @override
  Future<void> dispose() async {
    await _listener.cancel();
    super.dispose();
  }
}

/// 通过[ProviderNode]放入到部件树里面

/// InheritedWidget是flutter原生提供用于在Widget间共享数据的类
/// 当InheritedWidget发生变化时，它的子树中所有依赖了它的数据的Widget都会
/// 进行rebuild，这使得开发者省去了维护数据同步逻辑的麻烦。

class _InheritedProviders extends InheritedWidget {
  /// 小部件树中的下一个_InheritedProvider（父级_InheritedProvider）.
  /// 最顶层的将始终为null.
  final _InheritedProviders parent;

  final Providers providers;

  const _InheritedProviders({Widget child, this.providers, this.parent})
      : super(child: child);

  /// 查找离当前部件最近的_InheritedProviders部件
  static _InheritedProviders of(BuildContext context) {
    final widget = context.inheritFromWidgetOfExactType(_InheritedProviders);
    return widget is _InheritedProviders ? widget : null;
  }

  @override
  bool updateShouldNotify(_InheritedProviders oldWidget) {
    return parent?.updateShouldNotify(oldWidget.parent) ??
        false || providers != oldWidget.providers;
  }

  /// 这是比getFromType更安全的方式
  Provider<T> getValue<T>({ProviderScope scope}) {
    return providers.getFromType(T, scope: scope) ??
        parent?.getValue<T>(scope: scope);
  }

  /// 在runtime，ProvideMulti需要用到getFromType
  Provider getFromType(Type type, {ProviderScope scope}) {
    return providers.getFromType(type, scope: scope) ??
        parent?.getFromType(type, scope: scope);
  }
}

/// 当部件的listenable属性更改时，就会重新构建部件树内的部分组件
/// [builder] is called on [listenable] changing.
/// [child] is not rebuilt, but is passed to the [builder].
/// 这个跟[AnimatedBuilder]有相同的行为, 但是意图更清晰.
class ListeningBuilder extends AnimatedWidget {
  /// 构造一个新的 [ListeningBuilder].
  const ListeningBuilder({
    @required Listenable listenable,
    @required this.builder,
    Key key,
    this.child,
  })  : assert(builder != null),
        super(key: key, listenable: listenable);

  /// 每次listenable改变值都会调用该方法
  final TransitionBuilder builder;

  /// The child widget to pass to the [builder].
  ///
  /// If a [builder] callback's return value contains a subtree that does not
  /// depend on the listenable, it's more efficient to build that subtree once
  /// instead of rebuilding it on every change.
  /// 如果一个builder的回调函数返回值是一个不依赖listenable值的子树，那么build这个树会比rebuilding它更高效；
  ///
  /// If the pre-built subtree is passed as the [child] parameter, the
  /// [ListeningBuilder] will pass it back to the [builder] function so that it
  /// can be incorporated into the build.
  /// 如果预建的子树作为[child]参数传递，则[ListeningBuilder]会将它传递给[builder]函数以便它可以合并到构建中。
  ///
  /// Using this pre-built child is entirely optional, but can improve
  /// performance significantly in some cases and is therefore a good practice.
  /// 预先构建child是完全可选的，但是在某些情况下可以提高效率，因此这是一个很好的做法
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

/// 当它有监听器时，只能监听子部件
/// listenable.merge的默认实现只在处理时移除，而监听小部件不调用该处理，可能会导致潜在的内存泄漏。
class _MergedListenable extends ChangeNotifier {
  final List<Listenable> _children;

  _MergedListenable(this._children);

  @override
  void dispose() {
    if (hasListeners) {
      _unlisten();
    }
    super.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      for (final child in _children) {
        child?.addListener(notifyListeners);
      }
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _unlisten();
    }
  }

  void _unlisten() {
    for (final child in _children) {
      child?.removeListener(notifyListeners);
    }
  }
}