private import cpp
private import trailofbits.itergator.iterators

abstract class PotentialInvalidation extends Function {
    cached abstract predicate invalidates(Iterated i);
}
