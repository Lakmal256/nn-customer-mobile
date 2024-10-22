///This file contains data stores & related items
import 'package:flutter/foundation.dart';

import 'dto.dart';

abstract class DataFilter<T> {
  List<T> filter(List<T> data);
}

/// Builders

class BuildersDataStore {
  List<BuilderDto> data;

  List<DataFilter<BuilderDto>> filters;

  BuildersDataStore(this.data, {List<DataFilter<BuilderDto>>? filters})
      : filters = List.from(filters ?? [], growable: true);

  _getFilteredData() {
    List<BuilderDto> data = this.data;
    for (var filter in filters) {
      data = filter.filter(data);
    }
    return data;
  }

  List<BuilderDto> get withFilters => _getFilteredData();
}

class BuildersValueNotifier extends ValueNotifier<BuildersDataStore> {
  BuildersValueNotifier(super.value);

  setData(List<BuilderDto> data) {
    value.data = data;
    notifyListeners();
  }

  addFilter(DataFilter<BuilderDto> filter) {
    value.filters.add(filter);
    notifyListeners();
  }

  toggleFilter(DataFilter<BuilderDto> filter) {
    if (value.filters.contains(filter)) {
      removeFilter(filter);
    } else {
      addFilter(filter);
    }
  }

  replaceFilter(DataFilter<BuilderDto> filter, DataFilter<BuilderDto> next) {
    int index = value.filters.indexOf(filter);
    if (index != -1) value.filters[index] = next;
    notifyListeners();
  }

  removeFilter(DataFilter<BuilderDto> filter) {
    value.filters.removeWhere((element) => element == filter);
    notifyListeners();
  }

  clearFilters() {
    value.filters.clear();
    notifyListeners();
  }
}

class FilterByBuilderName implements DataFilter<BuilderDto> {
  String text;

  FilterByBuilderName(this.text);

  @override
  List<BuilderDto> filter(List<BuilderDto> data) {
    return data.where((element) => element.displayName.toLowerCase().contains(text.toLowerCase())).toList();
  }
}

class FilterByBuilderJobTypes implements DataFilter<BuilderDto> {
  List<String> jobTypes;

  FilterByBuilderJobTypes(this.jobTypes);

  add(String type) {
    jobTypes.add(type);
    return this;
  }

  remove(String type) {
    jobTypes.remove(type);
    return this;
  }

  toggle(String type) {
    if (jobTypes.contains(type)) {
      remove(type);
    } else {
      add(type);
    }
    return this;
  }

  @override
  List<BuilderDto> filter(List<BuilderDto> data) {
    if (jobTypes.isEmpty) return data;
    return data
        .where((element) => jobTypes.any((type) => jobTypes.any((type) => (element.jobType ?? "").contains(type))))
        .toList();
  }

  bool contains(String? jobType) => jobTypes.contains(jobType);
}

class BuilderJobTypesValueNotifier extends ValueNotifier<List<JobTypeDto>> {
  BuilderJobTypesValueNotifier(super.value);

  setData(List<JobTypeDto> value) {
    this.value = value;
    notifyListeners();
  }
}

/// My Jobs

class MyJobPostsStore {
  List<JobDto> data;
  List<JobTypeDto> types;

  List<DataFilter<JobDto>> filters;

  MyJobPostsStore({
    required this.data,
    this.types = const [],
    List<DataFilter<JobDto>>? filters,
  }) : filters = List.from(filters ?? [], growable: true);

  _getFilteredData() {
    List<JobDto> data = this.data;
    for (var filter in filters) {
      data = filter.filter(data);
    }
    return data;
  }

  List<JobDto> get withFilters => _getFilteredData();
}

class MyJobPostsValueNotifier extends ValueNotifier<MyJobPostsStore> {
  MyJobPostsValueNotifier(super.value);

  setData(List<JobDto> data) {
    value.data = data;
    notifyListeners();
  }

  setTypes(List<JobTypeDto> types) {
    value.types = types;
    notifyListeners();
  }

  JobTypeDto getJobType(JobDto job) => value.types.singleWhere((type) => type.jobTypeName == job.jobType);
}

/// E-commerce

class ProductsDataStore {
  ProductsDataStore.empty() : products = [];

  List<ProductDto> products;
}

class ProductsDataValueNotifier extends ValueNotifier<ProductsDataStore> {
  ProductsDataValueNotifier(super.value);
}

/// Flash Sale

class FlashSaleValueNotifier extends ValueNotifier<FlashSaleResponseDto> {
  FlashSaleValueNotifier(super.value);

  setValue(FlashSaleResponseDto value) {
    this.value = value;
  }

  double getDiscountAmount(ProductDto product) {
    return value.products.fold(0.0, (pv, e) {
      if (e.id == product.id) {
        return pv + ((e.price ?? 0.0) * (value.percentageValue / 100));
      }
      return pv;
    });
  }

  bool isOnFlashSale(ProductDto product) {
    return value.products.any((e) => e.id == product.id) && DateTime.now().isBefore(value.expiryDate!);
  }
}
