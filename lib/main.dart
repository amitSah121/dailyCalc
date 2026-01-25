import 'package:dailycalc/consts.dart';
import 'package:dailycalc/data/datasources/card_hive_datasource.dart';
import 'package:dailycalc/data/datasources/history_hive_datasource.dart';
import 'package:dailycalc/data/datasources/home_hive_datasource.dart';
import 'package:dailycalc/data/datasources/settings_hive_datasource.dart';
import 'package:dailycalc/data/datasources/spreadsheet_hive_datasource.dart';
import 'package:dailycalc/data/hive_init.dart';
import 'package:dailycalc/data/models/calc_history_model.dart';
import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:dailycalc/data/models/theme_settings_model.dart';
import 'package:dailycalc/local_storage.dart';
import 'package:dailycalc/logic/blocs/blocs/calculator_bloc.dart';
import 'package:dailycalc/logic/blocs/blocs/card_bloc.dart';
import 'package:dailycalc/logic/blocs/blocs/home_bloc.dart';
import 'package:dailycalc/logic/blocs/blocs/settings_bloc.dart';
import 'package:dailycalc/logic/blocs/blocs/spreadsheet_bloc.dart';
import 'package:dailycalc/logic/blocs/states/settings_state.dart';
import 'package:dailycalc/repository/card_repository.dart';
import 'package:dailycalc/repository/history_repository.dart';
import 'package:dailycalc/repository/home_repository.dart';
import 'package:dailycalc/repository/settings_repository.dart';
import 'package:dailycalc/repository/spreadsheet_repository.dart';
import 'package:dailycalc/ui/mainapp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive(); // registers adapters and opens boxes
  await setup();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );

  final savedLocale = await LocaleStorage.load();

  runApp(MyApp(initialLocale: savedLocale,));
}

class MyApp extends StatefulWidget {
  final Locale? initialLocale;
  const MyApp({this.initialLocale,super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void _changeLocale(Locale? locale) async {
    setState(() => _locale = locale);
    if (locale == null) {
      await LocaleStorage.clear();
    } else {
      await LocaleStorage.save(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>(
        create: (_) {
          final box = Hive.box<ThemeSettingsModel>('settings');
          return SettingsRepository(
            SettingsHiveDataSource(box),
            );
          },
        ),
        RepositoryProvider<CardRepository>(
        create: (_) {
          final box = Hive.box<CardModel>('cards');
          return CardRepository(
            CardHiveDataSource(box),
            );
          },
        ),
        RepositoryProvider<HomeRepository>(
        create: (_) {
          final box = Hive.box<HomeModel>('homes');
          return HomeRepository(
            HomeHiveDataSource(box),
            );
          },
        ),
        RepositoryProvider<HistoryRepository>(
        create: (_) {
          final box = Hive.box<CalcHistoryModel>('history');
          return HistoryRepository(
            HistoryHiveDataSource(box),
            );
          },
        ),
        RepositoryProvider<SpreadSheetRepository>(
        create: (_) {
          final box = Hive.box<SpreadSheetModel>('sheets');
          return SpreadSheetRepository(
            SpreadSheetHiveDataSource(box),
            );
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(create: (context) => SettingsBloc(
            context.read<SettingsRepository>(),
            context.read<CardRepository>(),
            context.read<HomeRepository>(),
            context.read<HistoryRepository>(),
            context.read<SpreadSheetRepository>(),
          )),
          BlocProvider<CardBloc>(create: (context) => CardBloc(
            context.read<CardRepository>(),
          )),
          BlocProvider<CalculatorBloc>(create: (context) => CalculatorBloc(
            context.read<HistoryRepository>(),
          )),
          BlocProvider<HomeBloc>(create: (context) => HomeBloc(
            context.read<HomeRepository>(),
          )),
          BlocProvider<SpreadsheetBloc>(create: (context) => SpreadsheetBloc(
            context.read<SpreadSheetRepository>(),
            context.read<HomeRepository>(),
          )),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            // Pick ThemeData based on theme string
            ThemeData themeData;

            if (state.themeSettings.theme == 'orange-bluegray') {
              themeData = themeDataFromColors(orangeBlueGrayTheme);
            } else if (state.themeSettings.theme == 'teal-blue') {
              themeData = themeDataFromColors(tealBlueTheme);
            } else if (state.themeSettings.theme == 'amber-red') {
              themeData = themeDataFromColors(amberRedTheme);
            } else {
              themeData = ThemeData.light(); // default fallback
            }

            return MaterialApp(
              title: 'DailyCalc',
              theme: themeData,
              darkTheme: ThemeData.dark(),
              themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              locale: _locale, // 👈 override or null = system
              supportedLocales: const [
                Locale('en'),
                Locale('ne'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              home: MainAppScreen(onLocaleChange: _changeLocale),
            );
          },
        ),
      ),
    );
  }
}
