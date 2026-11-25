import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'services/geocoding_service.dart';
import 'services/local_storage_service.dart';
import 'services/weather_service.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/favorites/favorites_screen.dart';
import 'views/home/home_screen.dart';
import 'views/search/search_screen.dart';

class AtmosWeatherApp extends StatelessWidget {
  const AtmosWeatherApp({
    super.key,
    this.weatherService,
    this.geocodingService,
    this.localStorageService,
  });

  final WeatherService? weatherService;
  final GeocodingService? geocodingService;
  final LocalStorageService? localStorageService;

  @override
  Widget build(BuildContext context) {
    final storage = localStorageService ?? LocalStorageService();
    final weather = weatherService ?? WeatherService();
    final geocoding = geocodingService ?? GeocodingService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            weatherService: weather,
            localStorageService: storage,
          )..initialize(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(
            geocodingService: geocoding,
            localStorageService: storage,
          )..loadSearchHistory(),
        ),
        ChangeNotifierProvider<FavoritesViewModel>(
          create: (_) =>
              FavoritesViewModel(localStorageService: storage)..loadFavorites(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainNavigationShell(),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(onNavigateToSearch: () => _selectTab(1)),
          SearchScreen(onLocationSelected: () => _selectTab(0)),
          FavoritesScreen(
            onLocationSelected: () => _selectTab(0),
            onNavigateToSearch: () => _selectTab(1),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny_rounded),
            label: 'Cuaca',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }
}
