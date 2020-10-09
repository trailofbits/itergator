# Itergator

A [CodeQL](https://securitylab.github.com/tools/codeql) library for detecting and analyzing iterator invalidation in C++ codebases.

## Getting started

Set up CodeQL in Visual Studio Code. We recommend using the [starter workspace](https://help.semmle.com/codeql/codeql-for-vscode/procedures/setting-up.html#using-the-starter-workspace).

Download Itergator and [add it to your workspace](https://code.visualstudio.com/docs/editor/multi-root-workspaces#_adding-folders).

```
git clone https://github.com/trailofbits/itergator
```

[Open and run](https://help.semmle.com/codeql/codeql-for-vscode/procedures/using-extension.html#running-a-query) the desired queries.

To use the classes in your own queries, add Itergator to your `qlpack.yml`:

```yaml
name: codeql-custom-queries-cpp
version: 0.0.0
libraryPathDependencies:
    - codeql-cpp
    - trailofbits-itergator
```

Then import the libraries:

```codeql
import trailofbits.itergator.iterators
import trailofbits.itergator.dataflow
import trailofbits.itergator.invalidations.Destructor
import trailofbits.itergator.invalidations.STL
```

## Queries

### `IteratedTypes.ql`

Returns a list of iterated types.

There may be false positives, such as when an iterator is used in an expression that is assigned to another:

```cpp
iterator __pos = __position._M_const_cast()
```

### `InvalidationFlows.ql`

Returns a list of potential invalidations.

Results contain the [iterator](#Iterator) that may be invalidated, the [access](#Iterated) of the iterated variable, the top-level potentially invalidating [function call](#Invalidator), and the [method call](#Invalidation) on the iterated variable. There is also an integer column `significance`. Lower values are expected to have less noise in their results.

This query has a high false positive rate. Analyzing the path of the function calls is useful to confirm a potential invalidation. An example of a path query can be seen in [examples/LLVMPath.ql](ql/examples/LLVMPath.ql).

## Libraries

### `trailofbits.itergator.iterators`

Classes representing iterators and invalidations in the codebase.

<a name="Iterator"></a>

```codeql
class Iterator extends Variable
```

> A variable that stores an iterator.

<a name="Iterated"></a>

```codeql
class Iterated extends VariableAccess
```

> The access of a container where it is being iterated over, e.g. `vec.begin()`.
>
> Member predicate `Iterator iterator()` returns a variable the resulting iterator is stored in.

<a name="Invalidator"></a>

```codeql
class Invalidator extends InvalidatorT
```

> A function call within the scope of an iterator that could trigger an invalidation.
>
> Member predicate `Iterated iterated()` returns an `Iterated` element in the assignment of an iterator with the same scope as this `Invalidator`.
>
> Member predicate `Invalidation invalidation()` returns a function call that could invalidate an iterator in the scope of this invalidator.

<a name="Invalidation"></a>

```codeql
class Invalidation extends InvalidatorT
```

> A function call that is a potential invalidation and could be reached from an `Invalidator`.
>
> Member predicate `Invalidator invalidator()` returns an `Invalidator` function call within the scope of a correctly typed iterator that this is reachable from.

<a name="InvalidatorT"></a>

```codeql
class InvalidatorT extends FunctionCallR
```

> A class of function call that composes the path from an `Invalidator` to an `Invalidation`.
>
> This is primarily an internal class, but it may be useful in some queries. View the [implementation](ql/src/trailofbits/itergator/iterators.qll#L47) for details.

### `trailofbits.itergator.dataflow`

[Global data flow](https://help.semmle.com/QL/learn-ql/cpp/dataflow.html#global-data-flow) configurations for Itergator's classes.

```codeql
class IteratorFlow extends DataFlow::Configuration
```

```codeql
class IteratedFlow extends DataFlow::Configuration
```

```codeql
class InvalidationFlow extends DataFlow::Configuration
```

```codeql
class InvalidatorFlow extends DataFlow::Configuration
```

### `trailofbits.itergator.invalidations`

A framework for designating functions as potentially invalidating.

```codeql
abstract class PotentialInvalidation extends Function
```

> This class can be extended to define potential invalidations.
>
> Member predicate `invalidates(Iterated i)` holds if a call to the function could invalidate an iterator of the type of the parameter `i`.

Two potential invalidation definitions are already written:

```codeql
import trailofbits.itergator.invalidations.Destructor
```

> Destructors of the iterated type.

```codeql
import trailofbits.itergator.invalidations.STL
```

> Member functions of STL types based on the C++ specification. This does not include destructors.

[These classes](ql/src/trailofbits/itergator/invalidations) may be used as examples when writing custom invalidation conditions.

## License

Itergator is licensed and distributed under the [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license. [Contact us](mailto:opensource@trailofbits.com) if you're looking for an exception to the terms.
