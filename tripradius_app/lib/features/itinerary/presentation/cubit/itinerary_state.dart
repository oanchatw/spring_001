part of 'itinerary_cubit.dart';

abstract class ItineraryState extends Equatable {
  const ItineraryState();
  @override
  List<Object?> get props => [];
}

class ItineraryInitial extends ItineraryState {}
class ItineraryLoading extends ItineraryState {}

class ItineraryLoaded extends ItineraryState {
  final List<RouteModel> routes;
  const ItineraryLoaded(this.routes);
  @override
  List<Object?> get props => [routes];
}

class ItineraryError extends ItineraryState {
  final String message;
  const ItineraryError(this.message);
  @override
  List<Object?> get props => [message];
}
