abstract class Partial<T, U extends Partial<T, U>> {
  Partial<T, U> toPartial();
}