import 'package:flutter/material.dart';

class CateogoriesScreen extends StatefulWidget {
  const CateogoriesScreen({super.key});

  @override
  State<CateogoriesScreen> createState() => _CateogoriesScreenState();
}

class _CateogoriesScreenState extends State<CateogoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Text("Categories Screen"),
      )
    );
  }
}
