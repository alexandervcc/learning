typedef FilterWhereFunction<T> = bool Function(T);

extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(FilterWhereFunction where) =>
      map((items) => items.where(where).toList());
}
