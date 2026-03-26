import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/route_model.dart';
import '../../data/repositories/itinerary_repository.dart';

part 'itinerary_state.dart';

class ItineraryCubit extends Cubit<ItineraryState> {
  final ItineraryRepository _repository;
  ItineraryCubit(this._repository) : super(ItineraryInitial());

  Future<void> loadRoutes() async {
    emit(ItineraryLoading());
    try {
      final routes = await _repository.getRoutes();
      emit(ItineraryLoaded(routes));
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }

  Future<void> createRoute(RouteModel route) async {
    try {
      await _repository.createRoute(route);
      await loadRoutes();
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }

  Future<void> deleteRoute(int id) async {
    try {
      await _repository.deleteRoute(id);
      if (state is ItineraryLoaded) {
        final current = (state as ItineraryLoaded).routes;
        emit(ItineraryLoaded(current.where((r) => r.id != id).toList()));
      }
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }
}
