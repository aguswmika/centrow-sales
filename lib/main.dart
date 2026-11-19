import 'package:centrow_sales/app/app.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();
  runApp(const CentrowSalesApp());
}
