import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' as injectable;
import 'package:rxdart/rxdart.dart';
import '../../models/order.dart';
import '../../repositories/orders_repository.dart';

// Events
abstract class OrdersEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadOrders extends OrdersEvent {}

class ResetFilters extends OrdersEvent {}

class FilterOrders extends OrdersEvent {
  final String searchQuery;
  final bool? isActive;
  final String status;
  final double? minPrice;
  final double? maxPrice;
  final String company;

  FilterOrders({
    this.searchQuery = '',
    this.isActive,
    this.status = '',
    this.minPrice,
    this.maxPrice,
    this.company = '',
  });

  @override
  List<Object> get props => [
        searchQuery,
        status,
        company,
        isActive ?? false,
        minPrice ?? 0.0,
        maxPrice ?? double.infinity,
      ];
}

// States
abstract class OrdersState extends Equatable {
  final bool isLoading;

  const OrdersState({this.isLoading = false});

  @override
  List<Object?> get props => [isLoading];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial() : super();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading() : super(isLoading: true);
}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final List<Order> filteredOrders;
  final String searchQuery;
  final bool? isActive;
  final String status;
  final double? minPrice;
  final double? maxPrice;
  final String company;

  const OrdersLoaded(
    this.orders, {
    required this.filteredOrders,
    this.searchQuery = '',
    this.isActive,
    this.status = '',
    this.minPrice,
    this.maxPrice,
    this.company = '',
    bool isLoading = false,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [
        orders,
        filteredOrders,
        searchQuery,
        isActive,
        status,
        minPrice,
        maxPrice,
        company,
        isLoading,
      ];

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      isActive != null ||
      status.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      company.isNotEmpty;

  OrdersLoaded copyWith({
    List<Order>? orders,
    List<Order>? filteredOrders,
    String? searchQuery,
    bool? isActive,
    String? status,
    double? minPrice,
    double? maxPrice,
    String? company,
    bool? isLoading,
  }) {
    return OrdersLoaded(
      orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      company: company ?? this.company,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  double get averageOrderPrice {
    final List<Order> ordersToUse =
        filteredOrders.isEmpty ? orders : filteredOrders;
    if (ordersToUse.isEmpty) return 0;
    return ordersToUse.fold<double>(0, (sum, order) => sum + order.price) /
        ordersToUse.length;
  }

  int get totalOrders =>
      filteredOrders.isEmpty ? orders.length : filteredOrders.length;

  int get returnsCount {
    final List<Order> ordersToUse =
        filteredOrders.isEmpty ? orders : filteredOrders;
    return ordersToUse.where((order) => order.status == 'RETURNED').length;
  }
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message) : super();

  @override
  List<Object?> get props => [message];
}

// Bloc
@injectable.injectable
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository ordersRepository;

  OrdersBloc({required this.ordersRepository}) : super(const OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<FilterOrders>(
      _onFilterOrders,
      transformer: (events, mapper) {
        return events
            .debounceTime(const Duration(milliseconds: 500))
            .distinct()
            .switchMap(mapper);
      },
    );
    on<ResetFilters>(_onResetFilters);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      final orders = await ordersRepository.getOrders();
      emit(OrdersLoaded(
        orders,
        filteredOrders: orders,
        isLoading: false,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  void _onFilterOrders(
    FilterOrders event,
    Emitter<OrdersState> emit,
  ) async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;

      // First emit loading state
      emit(currentState.copyWith(isLoading: true));

      // Add artificial delay to show loading state
      await Future.delayed(const Duration(milliseconds: 100));

      // If all filters are empty, return all orders
      if (event.searchQuery.isEmpty &&
          event.status.isEmpty &&
          event.isActive == null &&
          event.minPrice == null &&
          event.maxPrice == null &&
          event.company.isEmpty) {
        emit(OrdersLoaded(
          currentState.orders,
          filteredOrders: currentState.orders,
          searchQuery: '',
          isActive: null,
          status: '',
          minPrice: null,
          maxPrice: null,
          company: '',
          isLoading: false,
        ));
        return;
      }

      final filteredOrders = currentState.orders.where((order) {
        bool matchesSearch = true;
        bool matchesStatus = true;
        bool matchesActive = true;
        bool matchesPrice = true;
        bool matchesCompany = true;

        // Search query filter
        if (event.searchQuery.isNotEmpty) {
          matchesSearch = order.buyer
                  .toLowerCase()
                  .contains(event.searchQuery.toLowerCase()) ||
              order.company
                  .toLowerCase()
                  .contains(event.searchQuery.toLowerCase()) ||
              order.tags.any((tag) =>
                  tag.toLowerCase().contains(event.searchQuery.toLowerCase()));
        }

        // Status filter
        if (event.status.isNotEmpty) {
          matchesStatus =
              order.status.toLowerCase() == event.status.toLowerCase();
        }

        // Active filter
        if (event.isActive != null) {
          matchesActive = order.isActive == event.isActive;
        }

        // Price filter
        if (event.minPrice != null && event.maxPrice != null) {
          matchesPrice =
              order.price >= event.minPrice! && order.price <= event.maxPrice!;
        }

        // Company filter
        if (event.company.isNotEmpty) {
          matchesCompany =
              order.company.toLowerCase().contains(event.company.toLowerCase());
        }

        return matchesSearch &&
            matchesStatus &&
            matchesActive &&
            matchesPrice &&
            matchesCompany;
      }).toList();

      emit(OrdersLoaded(
        currentState.orders,
        filteredOrders: filteredOrders,
        searchQuery: event.searchQuery,
        isActive: event.isActive,
        status: event.status,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        company: event.company,
        isLoading: false,
      ));
    }
  }

  void _onResetFilters(
    ResetFilters event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(OrdersLoaded(
        currentState.orders,
        filteredOrders: currentState.orders,
        searchQuery: '',
        isActive: null,
        status: '',
        minPrice: null,
        maxPrice: null,
        company: '',
        isLoading: false,
      ));
    }
  }
}
