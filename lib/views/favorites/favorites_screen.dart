import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/location_list_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.onLocationSelected,
    required this.onNavigateToSearch,
  });

  final VoidCallback onLocationSelected;
  final VoidCallback onNavigateToSearch;

  Future<void> _selectFavorite(
    BuildContext context,
    LocationModel location,
  ) async {
    final weatherVm = context.read<WeatherViewModel>();
    onLocationSelected();
    await weatherVm.selectLocation(location);
  }

  Future<void> _removeFavorite(
    BuildContext context,
    FavoritesViewModel favoritesVm,
    LocationModel location,
  ) async {
    await favoritesVm.removeFavorite(location);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${location.name} dihapus dari favorit.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi Favorit')),
      body: SafeArea(
        child: Consumer<FavoritesViewModel>(
          builder: (context, favoritesVm, _) {
            if (favoritesVm.isLoading) {
              return const LoadingWidget(message: 'Memuat lokasi favorit...');
            }

            if (favoritesVm.favoriteLocations.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.favorite_border_rounded,
                title: 'Belum Ada Lokasi Favorit',
                subtitle: 'Simpan kota favorit Anda agar lebih mudah memantau prakiraan cuaca kapan saja.',
                actionLabel: 'Cari Kota',
                onAction: onNavigateToSearch,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: favoritesVm.favoriteLocations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final location = favoritesVm.favoriteLocations[index];
                return LocationListTile(
                  location: location,
                  isFavorite: true,
                  leadingIcon: Icons.location_on_rounded,
                  onTap: () => _selectFavorite(context, location),
                  onToggleFavorite: () =>
                      _removeFavorite(context, favoritesVm, location),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
