import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/media_models.dart';
import '../../repository/library_repository.dart';

class SearchState extends Equatable {
  const SearchState({this.query = '', this.results = const []});

  final String query;
  final List<Track> results;

  SearchState copyWith({String? query, List<Track>? results}) =>
      SearchState(query: query ?? this.query, results: results ?? this.results);

  @override
  List<Object?> get props => [query, results];
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchState());

  final LibraryRepository _repository;

  void search(String query) {
    emit(state.copyWith(query: query, results: _repository.search(query)));
  }
}
