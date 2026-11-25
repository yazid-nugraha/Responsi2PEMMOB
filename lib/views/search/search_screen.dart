import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/location_list_tile.dart';
import '../../widgets/location_search_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.onLocationSelected});

  final VoidCallback onLocationSelected;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSelectLocation(LocationModel location) async {
    FocusScope.of(context).unfocus();
    final searchVm = context.read<SearchViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await searchVm.addToHistory(location);
    widget.onLocationSelected();
    await weatherVm.selectLocation(location);
  }

  Future<void> _handleToggleFavorite(LocationModel location) async {
    final favoritesVm = context.read<FavoritesViewModel>();
    final added = await favoritesVm.toggleFavorite(location);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${location.name} ditambahkan ke favorit.'
                : '${location.name} dihapus dari favorit.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cari Lokasi')),
        body: SafeArea(
          child: Consumer2<SearchViewModel, FavoritesViewModel>(
            builder: (context, searchVm, favoritesVm, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: LocationSearchField(
                      controller: _controller,
                      hasText: searchVm.searchQuery.isNotEmpty,
                      onChanged: searchVm.onQueryChanged,
                      onSubmitted: searchVm.searchLocations,
                      onClear: () {
                        _controller.clear();
                        searchVm.clearSearch();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildContent(context, searchVm, favoritesVm),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SearchViewModel searchVm,
    FavoritesViewModel favoritesVm,
  ) {
    if (searchVm.isSearching) {
      return const LoadingWidget(message: 'Mencari kota...');
    }

    if (searchVm.errorMessage != null) {
      return WeatherErrorWidget(
        title: 'Pencarian Gagal',
        message: searchVm.errorMessage!,
        onRetry: () => searchVm.searchLocations(searchVm.searchQuery),
      );
    }

    if (searchVm.searchQuery.trim().isNotEmpty) {
      if (searchVm.hasSearched && searchVm.searchResults.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.location_off_rounded,
          title: 'Kota Tidak Ditemukan',
          subtitle:
              'Tidak ada hasil untuk "${searchVm.searchQuery.trim()}". Coba periksa ejaan atau gunakan nama kota lain.',
        );
      }

      if (searchVm.searchResults.isEmpty) {
        return const LoadingWidget(message: 'Menunggu hasil pencarian...');
      }

      return ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: searchVm.searchResults.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final location = searchVm.searchResults[index];
          return LocationListTile(
            location: location,
            isFavorite: favoritesVm.isFavorite(location),
            onTap: () => _handleSelectLocation(location),
            onToggleFavorite: () => _handleToggleFavorite(location),
          );
        },
      );
    }

    // Empty query: show search history if available, otherwise empty prompt.
    if (searchVm.searchHistory.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.travel_explore_rounded,
        title: 'Cari Kota',
        subtitle: 'Ketik nama kota untuk melihat prakiraan cuaca real-time dari Open-Meteo.',
      );
    }

    final theme = Theme.of(context);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Pencarian',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () async {
                await searchVm.clearHistory();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Riwayat pencarian telah dihapus.'),
                    ),
                  );
              },
              child: const Text('Hapus Semua'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...searchVm.searchHistory.map(
          (location) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LocationListTile(
              location: location,
              leadingIcon: Icons.history_rounded,
              isFavorite: favoritesVm.isFavorite(location),
              onTap: () => _handleSelectLocation(location),
              onToggleFavorite: () => _handleToggleFavorite(location),
            ),
          ),
        ),
      ],
    );
  }
}
