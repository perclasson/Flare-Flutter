import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import "package:flare_flutter/flare_actor.dart";
import "package:flare_flutter/flare_cache_builder.dart";
import 'package:flare_flutter/flare_controller.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flare_flutter/provider/asset_flare.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flare Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Flare-Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with FlareController, SingleTickerProviderStateMixin {
  final lightAsset =
      AssetFlare(bundle: rootBundle, name: "assets/settings_light.flr");
  final darkAsset =
      AssetFlare(bundle: rootBundle, name: "assets/settings_dark.flr");
  FlareAnimationLayer _animationLayer;
  FlutterActorArtboard _artboard;
  AnimationController animationController;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _artboard = artboard;
    initAnimationLayer();
  }

  @override
  void setViewTransform(Mat2D viewTransform) {
    // This is a necessary override for the [FlareController] mixin.
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if (_animationLayer != null) {
      FlareAnimationLayer layer = _animationLayer;
      layer.time = animationController.value * layer.duration;
      layer.animation.apply(layer.time, _artboard, 1);
      if (layer.isDone || layer.time == 0) {
        _animationLayer = null;
      }
    }
    return _animationLayer != null;
  }

  void initAnimationLayer() {
    if (_artboard != null) {
      final animationName = "Animations";
      ActorAnimation animation = _artboard.getAnimation(animationName);
      _animationLayer = FlareAnimationLayer()
        ..name = animationName
        ..animation = animation;
    }
  }

  void toggleSettings() {
    // Animate the settings panel to open or close.
    animationController.fling(velocity: isOpen ? -1 : 1);
    setState(() {
      isOpen = !isOpen;
    });
    // Animate the settings icon.
    initAnimationLayer();
    isActive.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FlareCacheBuilder(
                  [lightAsset, darkAsset],
                  builder: (BuildContext context, bool isWarm) {
                    return !isWarm
                        ? Container(child: Text("NO"))
                        : GestureDetector(
                            onTap: () {
                              toggleSettings();
                            },
                            child: FlareActor(
                              Theme.of(context).colorScheme.brightness ==
                                      Brightness.light
                                  ? lightAsset.name
                                  : darkAsset.name,
                              fit: BoxFit.contain,
                              controller: this,
                            ),
                          );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
