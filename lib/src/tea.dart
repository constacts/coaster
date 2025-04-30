import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class Cmd<Msg> {
  Future<Msg?> execute();

  static Cmd<Msg> none<Msg>() => _NoneCmd<Msg>();

  static Cmd<Msg> batch<Msg>(List<Cmd<Msg>> cmds) => _BatchCmd.batch(cmds);
}

class _BatchCmd<Msg> extends Cmd<Msg> {
  final List<Cmd<Msg>> cmds;

  _BatchCmd.batch(this.cmds);

  @override
  Future<Msg?> execute() async => null;
}

class _NoneCmd<Msg> extends Cmd<Msg> {
  @override
  Future<Msg?> execute() async => null;
}

abstract class Update<Model, Msg> {
  (Model, Cmd<Msg>) update(Msg msg, Model model);
}

abstract class Sub<Msg> {
  StreamSubscription<dynamic>? start(void Function(Msg) dispatch);

  static Sub<Msg> none<Msg>() => _NoneSub<Msg>();
  static Sub<Msg> batch<Msg>(List<Sub<Msg>> subs) => _BatchSub(subs);
}

class _NoneSub<Msg> extends Sub<Msg> {
  @override
  StreamSubscription<dynamic>? start(void Function(Msg) dispatch) => null;
}

class _BatchSub<Msg> extends Sub<Msg> {
  final List<Sub<Msg>> subs;
  _BatchSub(this.subs);

  @override
  StreamSubscription<dynamic>? start(void Function(Msg) dispatch) {
    // 모든 구독 시작
    for (var sub in subs) {
      sub.start(dispatch);
    }
    return null;
  }
}

class Program<Model, Msg, Update> {
  final Model model;
  final Update update;
  late Cmd<Msg>? cmd;
  final Sub<Msg> Function(Model)? subscriptions;
  Program(
    this.model,
    this.update, {
    this.subscriptions,
    this.cmd,
  });
}

abstract class TeaState<T extends StatefulWidget, Model, Msg,
    Updater extends Update<Model, Msg>> extends State<T> {
  late Model _model;
  late Updater _update;
  StreamSubscription<dynamic>? _subscription;

  Program<Model, Msg, Updater> init();

  Model get model => _model;

  @override
  initState() {
    super.initState();

    final program = init();
    _model = program.model;
    _update = program.update;

    if (program.subscriptions != null) {
      _setupSubscription();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 즉시 커맨드를 시작하면 화면 전환 애니메이션에 영향을 줄 수 있어서 100ms 뒤에 실행
      Future.delayed(const Duration(milliseconds: 100), () {
        final cmd = program.cmd;
        if (cmd != null) {
          _executeCmd(cmd);
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupSubscription() {
    _subscription?.cancel();
    final program = init();
    if (program.subscriptions != null) {
      final sub = program.subscriptions!(_model);
      _subscription = sub.start(dispatch);
    }
  }

  void _executeCmd(Cmd<Msg> cmd) async {
    if (cmd.runtimeType == _BatchCmd<Msg>) {
      for (var cmd in (cmd as _BatchCmd<Msg>).cmds) {
        Future.delayed(Duration.zero, () => _executeSingleCmd(cmd));
      }
    } else {
      Future.delayed(Duration.zero, () => _executeSingleCmd(cmd));
    }
  }

  void _executeSingleCmd(Cmd<Msg> cmd) async {
    final cmdMsg = await cmd.execute();
    if (cmdMsg != null) {
      dispatch(cmdMsg);
    }
  }

  void dispatch(Msg msg) {
    if (!mounted) {
      return;
    }
    final (model, cmd) = _update.update(msg, _model);

    setState(() {
      _model = model;
      if (init().subscriptions != null) {
        _setupSubscription();
      }
    });

    _executeCmd(cmd);
  }
}
