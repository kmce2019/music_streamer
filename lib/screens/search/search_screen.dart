import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/search/search_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search tracks'),
              onChanged: context.read<SearchCubit>().search,
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state.query.isEmpty) {
                  return const Center(child: Text('Start typing to search your local library.'));
                }
                if (state.results.isEmpty) {
                  return const Center(child: Text('No matches found.'));
                }
                return ListView.builder(
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    final track = state.results[index];
                    return ListTile(
                      leading: const Icon(Icons.music_note_outlined),
                      title: Text(track.title),
                      subtitle: Text(track.source),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
