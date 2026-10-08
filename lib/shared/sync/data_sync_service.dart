import 'dart:async';
import 'package:centrow_sales/shared/sync/data_sync_event.dart';

abstract interface class DataSyncService {
  Stream<DataSyncEvent> get events;
  void emit(DataSyncEvent event);
  void dispose();
}

class DataSyncServiceImpl implements DataSyncService {
  final StreamController<DataSyncEvent> _controller =
      StreamController<DataSyncEvent>.broadcast();

  @override
  Stream<DataSyncEvent> get events => _controller.stream;

  @override
  void emit(DataSyncEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
