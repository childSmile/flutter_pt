import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class BasicEvent {
  String method;
  dynamic arguments;
  BasicEvent(this.method, this.arguments);
}
