import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../widgets/current_weather_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/forecast_list.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/weather_details_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigateToSearch});

  final VoidCallback onNavigateToSearch;

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeatherViewModel, FavoritesViewModel>(
      builder: (context, weatherVm, favoritesVm, _) {
        final selectedLocation = weatherVm.selectedLocation;
        final isFav =
            selectedLocation != null &&
            favoritesVm.isFavorite(selectedLocation);

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConstants.appName),
            actions: [
              if (selectedLocation != null)
                IconButton(
                  tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
                  onPressed: () async {
                    final added = await favoritesVm.toggleFavorite(
                      selectedLocation,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            added
                                ? '${selectedLocation.name} ditambahkan ke favorit.'
                                : '${selectedLocation.name} dihapus dari favorit.',
                          ),
                        ),
                      );
                  },
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : null,
                  ),
                ),
              IconButton(
                tooltip: 'Cari kota',
                onPressed: onNavigateToSearch,
                icon: const Icon(Icons.search_rounded),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(child: _buildBody(context, weatherVm)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel weatherVm) {
    if (weatherVm.isLoading && !weatherVm.hasWeatherData) {
      return const LoadingWidget(message: 'Memuat data cuaca terkini...');
    }

    if (weatherVm.errorMessage != null && !weatherVm.hasWeatherData) {
      return WeatherErrorWidget(
        title: 'Gagal Memuat Cuaca',
        message: weatherVm.errorMessage!,
        onRetry: weatherVm.refreshWeather,
      );
    }

    final location = weatherVm.selectedLocation;
    final currentWeather = weatherVm.currentWeather;

    if (location == null || currentWeather == null) {
      return EmptyStateWidget(
        icon: Icons.wb_sunny_outlined,
        title: 'Belum Ada Lokasi Dipilih',
        subtitle: 'Cari dan pilih kota untuk melihat prakiraan cuaca terkini.',
        actionLabel: 'Cari Kota',
        onAction: onNavigateToSearch,
      );
    }

    final theme = Theme.of(context);
    final forecasts = weatherVm.dailyForecast;

    return RefreshIndicator(
      onRefresh: weatherVm.refreshWeather,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (weatherVm.errorMessage != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      weatherVm.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: weatherVm.refreshWeather,
                    child: const Text('Ulangi'),
                  ),
                ],
              ),
            ),
          ],
          CurrentWeatherCard(
            location: location,
            currentWeather: currentWeather,
            lastUpdated: weatherVm.lastUpdated,
          ),
          const SizedBox(height: 22),
          Text(
            'Detail Cuaca',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          WeatherDetailsGrid(
            currentWeather: currentWeather,
            todayPrecipitationProbabilityMax:
                weatherVm.todayPrecipitationProbabilityMax,
            todayForecast: forecasts.isNotEmpty ? forecasts.first : null,
          ),
          const SizedBox(height: 22),
          Text(
            'Prakiraan 7 Hari',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ForecastList(forecasts: forecasts),
        ],
      ),
    );
  }
}
