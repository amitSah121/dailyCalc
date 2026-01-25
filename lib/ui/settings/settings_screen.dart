

import 'package:dailycalc/consts.dart';
import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/field_model.dart';
import 'package:dailycalc/data/models/formula_model.dart';
import 'package:dailycalc/logic/blocs/blocs/card_bloc.dart';
import 'package:dailycalc/logic/blocs/blocs/settings_bloc.dart';
import 'package:dailycalc/logic/blocs/events/card_events.dart';
import 'package:dailycalc/logic/blocs/events/settings_events.dart';
import 'package:dailycalc/logic/blocs/states/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SettingsScreen extends StatelessWidget {
  final void Function(Locale?) onLocaleChange;
  const SettingsScreen({required this.onLocaleChange,super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (prev, curr) => prev.message != curr.message,
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final theme = state.themeSettings;
            final themeOptions = ['orange-bluegray', 'teal-blue', 'amber-red'];
            // final fontOptions = ['Roboto', 'Open Sans', 'Lato', 'Montserrat'];
            return ListView(
              children: [
                /// Dark mode
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: state.isDarkMode,
                  onChanged: null 
                  // (_) {
                  //   context.read<SettingsBloc>().add(ToggleDarkMode());
                  // },
                  
                ),

                const Divider(),

                ListTile(
                  title: const Text('Color Theme'),
                  subtitle: Text(theme.theme),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final bloc = context.read<SettingsBloc>();
                    final selected = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Select Color Theme'),
                        children: themeOptions
                            .map(
                              (t) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, t),
                                child: Text(t),
                              ),
                            )
                            .toList(),
                      ),
                    );

                    if (selected != null) {
                      bloc.add(ChangeTheme(selected));
                    }
                  },
                ),

                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(Localizations.localeOf(context).languageCode),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    // final bloc = context.read<SettingsBloc>();
                    await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Select Language'),
                        children: ["en-English","ne-Nepali"]
                            .map(
                              (t) => SimpleDialogOption(
                                onPressed: (){
                                  onLocaleChange(Locale(t.split("-")[0]));
                                  Navigator.pop(context);
                                },
                                child: Text(t),
                              ),
                            )
                            .toList(),
                      ),
                    );

                    // if (selected != null) {
                    //   bloc.add(ChangeTheme(selected));
                    // }
                  },
                ),

                // ListTile(
                //   title: const Text('Font'),
                //   subtitle: Text(theme.font),
                //   trailing: const Icon(Icons.chevron_right),
                //   onTap: () async {
                //     final bloc = context.read<SettingsBloc>();
                //     final selected = await showDialog<String>(
                //       context: context,
                //       builder: (context) => SimpleDialog(
                //         title: const Text('Select Font'),
                //         children: fontOptions
                //             .map(
                //               (f) => SimpleDialogOption(
                //                 onPressed: () => Navigator.pop(context, f),
                //                 child: Text(f),
                //               ),
                //             )
                //             .toList(),
                //       ),
                //     );

                //     if (selected != null) {
                //       bloc.add(ChangeFont(selected));
                //     }
                //   },
                // ),


                // /// 🔠 Font Size Input
                // ListTile(
                //   title: const Text('Font size'),
                //   subtitle: Text('${theme.fontSize.toInt()}'),
                //   trailing: IconButton(
                //     icon: const Icon(Icons.edit),
                //     onPressed: () async {
                //       final bloc = context.read<SettingsBloc>();
                //       final controller =
                //           TextEditingController(text: theme.fontSize.toInt().toString());

                //       final newFontSize = await showDialog<int>(
                //         context: context,
                //         builder: (context) => AlertDialog(
                //           title: const Text('Enter Font Size'),
                //           content: TextField(
                //             controller: controller,
                //             keyboardType: TextInputType.number,
                //             decoration: const InputDecoration(
                //               hintText: 'Font size',
                //             ),
                //           ),
                //           actions: [
                //             TextButton(
                //                 onPressed: () => Navigator.pop(context),
                //                 child: const Text('Cancel')),
                //             TextButton(
                //               onPressed: () {
                //                 final value = int.tryParse(controller.text);
                //                 Navigator.pop(context, value);
                //               },
                //               child: const Text('OK'),
                //             ),
                //           ],
                //         ),
                //       );

                //       if (newFontSize != null && newFontSize > 0) {
                //         bloc.add(ChangeFontSize(newFontSize.toDouble()));
                //       }
                //     },
                //   ),
                // ),

                // /// 🔍 Preview
                // Padding(
                //   padding: const EdgeInsets.all(16),
                //   child: Text(
                //     'Preview text',
                //     style: TextStyle(
                //       fontFamily: theme.font,
                //       fontSize: theme.fontSize,
                //     ),
                //   ),
                // ),
                const Divider(),
                /// Export
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text("Export Data"),
                  onTap: state.isBusy
                      ? null
                      : () async{
                          final bloc = context.read<SettingsBloc>();
                          bloc.add(StartExport(""));
                        },
                ),

                /// Import
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text("Import Data"),
                  onTap: state.isBusy
                      ? null
                      : () {
                          _showImportDialog(context);
                        },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text("Restore Factory Cards"),
                  subtitle: const Text("It won't delet any custom cards."),
                  onTap: state.isBusy
                      ? null
                      : () {
                          for(int i=0 ; i<cardsConst.length ; i++){
                            context.read<CardBloc>().add(SaveCard(cardsConst[i]));
                          }
                        },
                ),

                if (state.isBusy)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Import Data'),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: controller,
              maxLines: 12,
              decoration: const InputDecoration(
                hintText: 'Paste exported JSON here',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();

                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nothing to import')),
                  );
                  return;
                }

                try {
                  // final Map<String, dynamic> data =
                  //     Map<String, dynamic>.from(jsonDecode(text));

                  context.read<SettingsBloc>().add(StartImport(text));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid JSON')),
                  );
                }
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

}
