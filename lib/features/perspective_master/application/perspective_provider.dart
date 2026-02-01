import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/perspective_master/data/perspective_repository.dart';
import 'package:perf_evaluation/features/perspective_master/models/perspective_master_model.dart';

final Map<String,String> requestHeaders = {'Content-type':'application/json'};

final perspectiveMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final perspectiveList = await ref
        .watch(perspectiveMasterRepositoryProvider)
        .getPerspectives();

    final perspective = perspectiveList.perspective;

    ref.watch(perspectiveMasterListNotifier.notifier).clearPerspective();

    for (var i = 0; i < perspective!.length; i++) {
      ref.watch(perspectiveMasterListNotifier.notifier).addPerspective(perspective[i]);
    }

    return 'Success';
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final savePerspectiveMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(perspectiveBody);
    final response = await ref
        .watch(perspectiveMasterRepositoryProvider)
        .postPerspective(requestBody: requestBody, requestHeaders: requestHeaders);

    final perspectiveList = await ref
        .read(perspectiveMasterRepositoryProvider)
        .getPerspectives();

    final perspective = perspectiveList.perspective;

    ref.read(perspectiveMasterListNotifier.notifier).clearPerspective();

    for (var i = 0; i < perspective!.length; i++) {
      ref.read(perspectiveMasterListNotifier.notifier).addPerspective(perspective[i]);
    }
    return response;

  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final updatePerspectiveMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updatePerspectiveBody);
    final response = await ref
        .watch(perspectiveMasterRepositoryProvider)
        .updatePerspective(requestHeaders: requestHeaders, requestBody: requestBody);

    final perspectiveList = await ref
        .read(perspectiveMasterRepositoryProvider).getPerspectives();

    final perspective = perspectiveList.perspective;

    ref.read(perspectiveMasterListNotifier.notifier).clearPerspective();

    for (var i = 0; i < perspective!.length; i++) {
      ref.read(perspectiveMasterListNotifier.notifier).addPerspective(perspective[i]);
    }
    return response;

  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final deletePerspectiveMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(deletePerspectiveBody); 
    final response = await ref
        .watch(perspectiveMasterRepositoryProvider)
        .deletePerspective(requestBody: requestBody, requestHeaders: requestHeaders);

    final perspectiveList = await ref
        .read(perspectiveMasterRepositoryProvider)
        .getPerspectives();

    final perspective = perspectiveList.perspective;

    ref.read(perspectiveMasterListNotifier.notifier).clearPerspective();

    for (var i = 0; i < perspective!.length; i++) {
      ref.read(perspectiveMasterListNotifier.notifier).addPerspective(perspective[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final perspectiveMasterListNotifier =
    StateNotifierProvider<PerspectiveMasterNotifier, List<PerspectiveMaster>>((ref) {
  return PerspectiveMasterNotifier();
});

final perspectiveBody = StateProvider<Map>((ref) {
  return {};
});

final updatePerspectiveBody = StateProvider<Map>((ref) {
  return {};
});

final deletePerspectiveBody = StateProvider<String>((ref) {
  return "";
});

